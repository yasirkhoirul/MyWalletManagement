import 'package:drift/drift.dart';
import 'package:module_core/constant/constant.dart';
import 'package:module_dompet/data/datasource/db/database.dart';
import 'package:module_dompet/data/datasource/db/table.dart';
import 'package:module_dompet/data/model/transaction_detail_model.dart';

part 'dao.g.dart';

@DriftAccessor(
  tables: [DompetTabel, DompetMonth, Transactions, Tempat, BudgetLimits],
)
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(AppDatabase db) : super(db);

  //Read
  Stream<List<Transaction>> watchTransactions() {
    return select(transactions).watch();
  }

  Future<TypedResult> getTransactionDetail(int idTransaksi) async {
    final query = select(transactions)
      ..where((tbl) => tbl.id.equals(idTransaksi));
    final result = query.join([
      leftOuterJoin(tempat, tempat.transactionId.equalsExp(transactions.id)),
    ]).getSingle();
    return await result;
  }

  Stream<List<Transaction>> watchTransactionsWithPlace() {
    // Transactions that have a related Tempat row
    final query = (select(transactions).join([
      innerJoin(tempat, tempat.transactionId.equalsExp(transactions.id)),
    ]));

    return query.watch().map((rows) {
      // 3. Konversi List<TypedResult> menjadi List<Transaction>
      return rows.map((row) {
        // Ambil hanya data dari tabel 'transactions'
        return row.readTable(transactions);
      }).toList();
    });
    // Note: To filter only those with place, you'd need a subquery or join
  }

  Stream<List<Transaction>> watchTransactionsWithOutPlace() {
    // Transactions without a related Tempat row
    return (select(transactions)..where(
          (tbl) => notExistsQuery(
            select(tempat)
              ..where((tbl) => tbl.transactionId.equalsExp(transactions.id)),
          ),
        ))
        .watch();
    // Note: To filter those without place, you'd need a subquery or join
  }

  //update
  Future<void> updateTransaction(TransactionDetailModel data) async {
    if (data.id == null) {
      throw ArgumentError('Transaction id is required for update');
    }

    await transaction(() async {
      // Fetch OLD transaction data to adjust DompetMonth
      final oldTx = await (select(
        transactions,
      )..where((t) => t.id.equals(data.id!))).getSingleOrNull();
      if (oldTx == null) {
        throw ArgumentError('Transaction not found for update');
      }

      // Update the transaction row - mark as not uploaded for sync
      await (update(transactions)..where((t) => t.id.equals(data.id!))).write(
        TransactionsCompanion(
          amount: Value(data.amount),
          tanggal: Value(data.tanggal),
          isUpload: const Value(false), // Mark for re-upload on sync
          type: Value(data.type),
          description: Value(data.description),
          expenseCategory: Value(data.expenseCategory),
          receiptImagePath: Value(data.receiptImagePath),
          voiceNotePath: Value(data.voiceNotePath),
          dompetmonthid: Value(data.dompetmonthid),
          updatedAt: Value(DateTime.now()), // Update timestamp for sync
        ),
      );

      // Adjust DompetMonth: subtract old amount, add new amount
      final dompetMonthId = oldTx.dompetmonthid;
      if (dompetMonthId != null) {
        final dm = await (select(
          dompetMonth,
        )..where((d) => d.id.equals(dompetMonthId))).getSingleOrNull();
        if (dm != null) {
          final oldIsPemasukkan = oldTx.type == TypeTransaction.pemasukkan;
          final newIsPemasukkan = data.type == TypeTransaction.pemasukkan;

          // Subtract old amount
          var adjustedPemasukkan =
              dm.pemasukkan - (oldIsPemasukkan ? oldTx.amount : 0.0);
          var adjustedPengeluaran =
              dm.pengeluaran - (oldIsPemasukkan ? 0.0 : oldTx.amount);

          // Add new amount
          adjustedPemasukkan += (newIsPemasukkan ? data.amount : 0.0);
          adjustedPengeluaran += (newIsPemasukkan ? 0.0 : data.amount);

          // Safety: ensure non-negative
          adjustedPemasukkan = adjustedPemasukkan < 0
              ? 0.0
              : adjustedPemasukkan;
          adjustedPengeluaran = adjustedPengeluaran < 0
              ? 0.0
              : adjustedPengeluaran;

          await (update(
            dompetMonth,
          )..where((d) => d.id.equals(dompetMonthId))).write(
            DompetMonthCompanion(
              pemasukkan: Value(adjustedPemasukkan),
              pengeluaran: Value(adjustedPengeluaran),
            ),
          );
        }
      }

      // Handle place (Tempat) as a child record
      if (data.place != null) {
        final p = data.place!;
        // Use upsert: insert if new, update if exists
        await into(tempat).insertOnConflictUpdate(
          TempatCompanion(
            id: p.id == null ? const Value.absent() : Value(p.id!),
            lat: Value(p.lat),
            lng: Value(p.lng),
            countryCode: Value(p.countryCode),
            areaCode: Value(p.areaCode),
            areaSource: Value(p.areaSource),
            transactionId: Value(data.id!),
          ),
        );
      }

      // Recalculate dompet totals after transaction update
      if (dompetMonthId != null) {
        final dm = await (select(
          dompetMonth,
        )..where((d) => d.id.equals(dompetMonthId))).getSingleOrNull();
        if (dm != null) {
          await recalculateDompetTotals(dm.dompetid);
        }
      }
    });
  }

  //create
  Future<int> insertTransaction(TransactionsCompanion entry) {
    return into(transactions).insert(entry);
  }

  //delete
  Future<int> deleteTransaction(int transactionId) async {
    return await transaction(() async {
      // Fetch the transaction to know amount, type and dompetMonth reference
      final tx = await (select(
        transactions,
      )..where((t) => t.id.equals(transactionId))).getSingleOrNull();
      if (tx == null) return 0;

      final dompetMonthId = tx.dompetmonthid;
      final amount = tx.amount;
      final isPemasukkan = tx.type == TypeTransaction.pemasukkan;

      // Delete the transaction (this cascades to Tempat due to FK)
      final deletedCount = await (delete(
        transactions,
      )..where((t) => t.id.equals(transactionId))).go();

      // Adjust the DompetMonth aggregates if applicable
      if (dompetMonthId != null) {
        final dm = await (select(
          dompetMonth,
        )..where((d) => d.id.equals(dompetMonthId))).getSingleOrNull();
        if (dm != null) {
          final dompetId = dm.dompetid; // Save dompetId before any changes
          final newPemasukkan = dm.pemasukkan - (isPemasukkan ? amount : 0.0);
          final newPengeluaran = dm.pengeluaran - (isPemasukkan ? 0.0 : amount);

          final safePemasukkan = newPemasukkan < 0 ? 0.0 : newPemasukkan;
          final safePengeluaran = newPengeluaran < 0 ? 0.0 : newPengeluaran;

          if (safePemasukkan == 0.0 && safePengeluaran == 0.0) {
            // If both totals are zero, remove the month row
            await (delete(
              dompetMonth,
            )..where((d) => d.id.equals(dompetMonthId))).go();
          } else {
            // Otherwise update the aggregates
            await (update(
              dompetMonth,
            )..where((d) => d.id.equals(dompetMonthId))).write(
              DompetMonthCompanion(
                pemasukkan: Value(safePemasukkan),
                pengeluaran: Value(safePengeluaran),
              ),
            );
          }

          // Recalculate dompet totals after transaction delete
          await recalculateDompetTotals(dompetId);
        }
      }

      return deletedCount;
    });
  }

  Future<int> deleteDompetMonth(int dompetMonthId) async {
    // Get dompetId before deleting
    final monthData = await (select(
      dompetMonth,
    )..where((tbl) => tbl.id.equals(dompetMonthId))).getSingleOrNull();

    if (monthData == null) return 0;

    final dompetId = monthData.dompetid;

    // Delete the month
    final deletedCount = await (delete(
      dompetMonth,
    )..where((tbl) => tbl.id.equals(dompetMonthId))).go();

    // Recalculate dompet totals from remaining months
    await recalculateDompetTotals(dompetId);

    return deletedCount;
  }

  // DompetMonth operations
  Stream<List<DompetMonthData>> watchDompetMonths(int dompetId) {
    return (select(dompetMonth)
          ..where((tbl) => tbl.dompetid.equals(dompetId))
          ..orderBy([
            (tbl) =>
                OrderingTerm(expression: tbl.year, mode: OrderingMode.desc),
            (tbl) =>
                OrderingTerm(expression: tbl.month, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<DompetMonthData?> getDompetMonthByDate(
    int dompetId,
    int month,
    int year,
  ) async {
    final query = select(dompetMonth)
      ..where(
        (tbl) =>
            tbl.dompetid.equals(dompetId) &
            tbl.month.equals(month) &
            tbl.year.equals(year),
      );
    return query.getSingleOrNull();
  }

  Future<int> upsertDompetMonth({
    required int dompetId,
    required int month,
    required int year,
    required double amount,
    required bool isPemasukkan,
  }) async {
    return await transaction(() async {
      // Ensure DompetTabel record exists
      await _ensureDompetExists(dompetId);

      // Get existing record
      final existing = await getDompetMonthByDate(dompetId, month, year);
      int resultId;

      if (existing == null) {
        // Create new record
        resultId = await into(dompetMonth).insert(
          DompetMonthCompanion.insert(
            pemasukkan: isPemasukkan ? amount : 0.0,
            pengeluaran: isPemasukkan ? 0.0 : amount,
            month: month,
            year: year,
            dompetid: dompetId,
          ),
        );
      } else {
        // Update existing record
        final newPemasukkan = isPemasukkan
            ? existing.pemasukkan + amount
            : existing.pemasukkan;
        final newPengeluaran = isPemasukkan
            ? existing.pengeluaran
            : existing.pengeluaran + amount;

        await (update(
          dompetMonth,
        )..where((tbl) => tbl.id.equals(existing.id))).write(
          DompetMonthCompanion(
            pemasukkan: Value(newPemasukkan),
            pengeluaran: Value(newPengeluaran),
          ),
        );

        resultId = existing.id;
      }

      // Recalculate dompet totals
      await recalculateDompetTotals(dompetId);

      return resultId;
    });
  }

  // Ensure DompetTabel record exists for the given dompetId
  Future<void> _ensureDompetExists(int dompetId) async {
    final existing = await (select(
      dompetTabel,
    )..where((tbl) => tbl.id.equals(dompetId))).getSingleOrNull();

    if (existing == null) {
      // Create a default dompet record
      await into(dompetTabel).insert(
        DompetTabelCompanion.insert(
          id: Value(dompetId),
          userid: 'default_user',
          amount: 0.0,
          pengeluaran: 0.0,
          pemasukkan: 0.0,
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
  }

  // ============ DOMPET CRUD OPERATIONS ============

  /// Get dompet by Firebase user ID
  Future<DompetTabelData?> getDompetByUserId(String userId) async {
    final query = select(dompetTabel)
      ..where((tbl) => tbl.userid.equals(userId));
    return query.getSingleOrNull();
  }

  /// Create new dompet for user with initial amount
  Future<int> createDompet(String userId, double initialAmount) async {
    return await into(dompetTabel).insert(
      DompetTabelCompanion.insert(
        userid: userId,
        amount: initialAmount,
        pengeluaran: 0.0,
        pemasukkan: 0.0,
      ),
    );
  }

  /// Watch dompet for reactive updates
  Stream<DompetTabelData?> watchDompetByUserId(String userId) {
    final query = select(dompetTabel)
      ..where((tbl) => tbl.userid.equals(userId));
    return query.watchSingleOrNull();
  }

  /// Update dompet totals (amount, pengeluaran, pemasukkan)
  Future<void> updateDompetTotals({
    required int dompetId,
    required double amount,
    required double pengeluaran,
    required double pemasukkan,
  }) async {
    await (update(dompetTabel)..where((tbl) => tbl.id.equals(dompetId))).write(
      DompetTabelCompanion(
        amount: Value(amount),
        pengeluaran: Value(pengeluaran),
        pemasukkan: Value(pemasukkan),
      ),
    );
  }

  /// Get dompet by ID
  Future<DompetTabelData?> getDompetById(int dompetId) async {
    final query = select(dompetTabel)..where((tbl) => tbl.id.equals(dompetId));
    return query.getSingleOrNull();
  }

  /// Recalculate DompetTabel totals from sum of all DompetMonth records
  /// Call this after any DompetMonth insert/update/delete
  Future<void> recalculateDompetTotals(int dompetId) async {
    // Sum all DompetMonth records for this dompetId
    final months = await (select(
      dompetMonth,
    )..where((tbl) => tbl.dompetid.equals(dompetId))).get();

    double totalPemasukkan = 0.0;
    double totalPengeluaran = 0.0;

    for (final m in months) {
      totalPemasukkan += m.pemasukkan;
      totalPengeluaran += m.pengeluaran;
    }

    // Get current dompet to preserve initial amount
    final currentDompet = await getDompetById(dompetId);
    if (currentDompet == null) return;

    // Balance = initial amount + pemasukkan - pengeluaran
    // Note: initial amount is stored separately, we update pemasukkan/pengeluaran from months
    await updateDompetTotals(
      dompetId: dompetId,
      amount: currentDompet.amount, // Keep initial amount unchanged
      pengeluaran: totalPengeluaran,
      pemasukkan: totalPemasukkan,
    );
  }

  /// Watch transactions that belong to a specific dompet (via DompetMonth)
  Stream<List<Transaction>> watchTransactionsByDompetId(int dompetId) {
    // Get all DompetMonth IDs for this dompet, then get transactions
    final query = select(transactions).join([
      innerJoin(
        dompetMonth,
        dompetMonth.id.equalsExp(transactions.dompetmonthid),
      ),
    ])..where(dompetMonth.dompetid.equals(dompetId));

    return query.watch().map((rows) {
      return rows.map((row) => row.readTable(transactions)).toList();
    });
  }

  /// Get list of DompetMonth IDs for a dompet
  Future<List<int>> getDompetMonthIds(int dompetId) async {
    final months = await (select(
      dompetMonth,
    )..where((tbl) => tbl.dompetid.equals(dompetId))).get();
    return months.map((m) => m.id).toList();
  }

  /// Get spending grouped by category for a dompet (for pie chart)
  Future<Map<ExpenseCategory, double>> getSpendingByCategory(
    int dompetId,
  ) async {
    // Get transactions for this dompet that are pengeluaran type
    final query =
        select(transactions).join([
            innerJoin(
              dompetMonth,
              dompetMonth.id.equalsExp(transactions.dompetmonthid),
            ),
          ])
          ..where(dompetMonth.dompetid.equals(dompetId))
          ..where(transactions.type.equals(TypeTransaction.pengeluaran.index));

    final rows = await query.get();

    final Map<ExpenseCategory, double> result = {};
    for (final row in rows) {
      final tx = row.readTable(transactions);
      final category = tx.expenseCategory ?? ExpenseCategory.lainnya;
      result[category] = (result[category] ?? 0) + tx.amount;
    }

    return result;
  }

  /// Watch spending by category for real-time updates
  Stream<Map<ExpenseCategory, double>> watchSpendingByCategory(int dompetId) {
    final query =
        select(transactions).join([
            innerJoin(
              dompetMonth,
              dompetMonth.id.equalsExp(transactions.dompetmonthid),
            ),
          ])
          ..where(dompetMonth.dompetid.equals(dompetId))
          ..where(transactions.type.equals(TypeTransaction.pengeluaran.index));

    return query.watch().map((rows) {
      final Map<ExpenseCategory, double> result = {};
      for (final row in rows) {
        final tx = row.readTable(transactions);
        final category = tx.expenseCategory ?? ExpenseCategory.lainnya;
        result[category] = (result[category] ?? 0) + tx.amount;
      }
      return result;
    });
  }

  /// Get daily spending for current month (for area chart)
  Future<Map<int, double>> getDailySpendingForMonth(
    int dompetId,
    int month,
    int year,
  ) async {
    final query =
        select(transactions).join([
            innerJoin(
              dompetMonth,
              dompetMonth.id.equalsExp(transactions.dompetmonthid),
            ),
          ])
          ..where(dompetMonth.dompetid.equals(dompetId))
          ..where(dompetMonth.month.equals(month))
          ..where(dompetMonth.year.equals(year))
          ..where(transactions.type.equals(TypeTransaction.pengeluaran.index));

    final rows = await query.get();

    final Map<int, double> dailySpending = {};
    for (final row in rows) {
      final tx = row.readTable(transactions);
      final day = tx.tanggal.day;
      dailySpending[day] = (dailySpending[day] ?? 0) + tx.amount;
    }

    return dailySpending;
  }

  /// Watch daily spending for real-time updates
  Stream<Map<int, double>> watchDailySpendingForMonth(
    int dompetId,
    int month,
    int year,
  ) {
    final query =
        select(transactions).join([
            innerJoin(
              dompetMonth,
              dompetMonth.id.equalsExp(transactions.dompetmonthid),
            ),
          ])
          ..where(dompetMonth.dompetid.equals(dompetId))
          ..where(dompetMonth.month.equals(month))
          ..where(dompetMonth.year.equals(year))
          ..where(transactions.type.equals(TypeTransaction.pengeluaran.index));

    return query.watch().map((rows) {
      final Map<int, double> dailySpending = {};
      for (final row in rows) {
        final tx = row.readTable(transactions);
        final day = tx.tanggal.day;
        dailySpending[day] = (dailySpending[day] ?? 0) + tx.amount;
      }
      return dailySpending;
    });
  }

  /// Get spending by category for a specific month
  Future<Map<ExpenseCategory, double>> getSpendingByCategoryForMonth(
    int dompetId,
    int month,
    int year,
  ) async {
    final query =
        select(transactions).join([
            innerJoin(
              dompetMonth,
              dompetMonth.id.equalsExp(transactions.dompetmonthid),
            ),
          ])
          ..where(dompetMonth.dompetid.equals(dompetId))
          ..where(dompetMonth.month.equals(month))
          ..where(dompetMonth.year.equals(year))
          ..where(transactions.type.equals(TypeTransaction.pengeluaran.index));

    final rows = await query.get();

    final Map<ExpenseCategory, double> result = {};
    for (final row in rows) {
      final tx = row.readTable(transactions);
      final category = tx.expenseCategory ?? ExpenseCategory.lainnya;
      result[category] = (result[category] ?? 0) + tx.amount;
    }

    return result;
  }

  // ==================== BUDGET LIMITS ====================

  /// Get all budget limits for a specific month
  Future<List<BudgetLimit>> getBudgetLimitsForMonth(
    int dompetId,
    int month,
    int year,
  ) {
    return (select(budgetLimits)
          ..where((b) => b.dompetId.equals(dompetId))
          ..where((b) => b.month.equals(month))
          ..where((b) => b.year.equals(year)))
        .get();
  }

  /// Watch budget limits for a specific month
  Stream<List<BudgetLimit>> watchBudgetLimitsForMonth(
    int dompetId,
    int month,
    int year,
  ) {
    return (select(budgetLimits)
          ..where((b) => b.dompetId.equals(dompetId))
          ..where((b) => b.month.equals(month))
          ..where((b) => b.year.equals(year)))
        .watch();
  }

  /// Insert or update a budget limit
  Future<int> insertOrUpdateBudgetLimit(BudgetLimitsCompanion limit) async {
    return into(budgetLimits).insertOnConflictUpdate(limit);
  }

  /// Delete a budget limit
  Future<int> deleteBudgetLimit(int id) {
    return (delete(budgetLimits)..where((b) => b.id.equals(id))).go();
  }

  /// Mark a budget limit as notified
  Future<void> markBudgetAsNotified(int id) async {
    await (update(budgetLimits)..where((b) => b.id.equals(id))).write(
      const BudgetLimitsCompanion(isNotified: Value(true)),
    );
  }

  /// Get budget limit for a specific category
  Future<BudgetLimit?> getBudgetLimitForCategory(
    int dompetId,
    ExpenseCategory category,
    int month,
    int year,
  ) {
    return (select(budgetLimits)
          ..where((b) => b.dompetId.equals(dompetId))
          ..where((b) => b.category.equals(category.index))
          ..where((b) => b.month.equals(month))
          ..where((b) => b.year.equals(year)))
        .getSingleOrNull();
  }

  /// Get or create a DompetMonth record for the given month/year
  Future<int> getOrCreateDompetMonth(int dompetId, int month, int year) async {
    // Try to find existing
    final existing =
        await (select(dompetMonth)
              ..where((d) => d.dompetid.equals(dompetId))
              ..where((d) => d.month.equals(month))
              ..where((d) => d.year.equals(year)))
            .getSingleOrNull();

    if (existing != null) {
      return existing.id;
    }

    // Create new
    await _ensureDompetExists(dompetId);
    return await into(dompetMonth).insert(
      DompetMonthCompanion.insert(
        pemasukkan: 0.0,
        pengeluaran: 0.0,
        month: month,
        year: year,
        dompetid: dompetId,
      ),
    );
  }

  // ========== SYNC METHODS ==========

  /// Get all transactions pending upload (isUpload = false, wantToDelete = false)
  Future<List<Transaction>> getPendingUploads() {
    return (select(transactions)
          ..where((t) => t.isUpload.equals(false))
          ..where((t) => t.wantToDelete.equals(false)))
        .get();
  }

  /// Get all transactions marked for deletion (wantToDelete = true)
  Future<List<Transaction>> getPendingDeletes() {
    return (select(
      transactions,
    )..where((t) => t.wantToDelete.equals(true))).get();
  }

  /// Get transaction by UUID
  Future<Transaction?> getByUuid(String uuid) {
    return (select(
      transactions,
    )..where((t) => t.uuid.equals(uuid))).getSingleOrNull();
  }

  /// Mark transaction as uploaded
  Future<void> markAsUploaded(String uuid) async {
    await (update(transactions)..where((t) => t.uuid.equals(uuid))).write(
      const TransactionsCompanion(isUpload: Value(true)),
    );
  }

  /// Soft delete - mark for deletion on next sync AND adjust totals immediately
  Future<void> softDeleteTransaction(int id) async {
    await transaction(() async {
      // Fetch the transaction to know amount, type and dompetMonth reference
      final tx = await (select(
        transactions,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (tx == null) return;

      // Mark as want to delete
      await (update(transactions)..where((t) => t.id.equals(id))).write(
        TransactionsCompanion(
          wantToDelete: const Value(true),
          isUpload: const Value(false), // Mark for sync
          updatedAt: Value(DateTime.now()),
        ),
      );

      // Adjust the DompetMonth aggregates immediately (so UI updates)
      final dompetMonthId = tx.dompetmonthid;
      final amount = tx.amount;
      final isPemasukkan = tx.type == TypeTransaction.pemasukkan;

      if (dompetMonthId != null) {
        final dm = await (select(
          dompetMonth,
        )..where((d) => d.id.equals(dompetMonthId))).getSingleOrNull();
        if (dm != null) {
          final dompetId = dm.dompetid;
          final newPemasukkan = dm.pemasukkan - (isPemasukkan ? amount : 0.0);
          final newPengeluaran = dm.pengeluaran - (isPemasukkan ? 0.0 : amount);

          final safePemasukkan = newPemasukkan < 0 ? 0.0 : newPemasukkan;
          final safePengeluaran = newPengeluaran < 0 ? 0.0 : newPengeluaran;

          // Update the aggregates (don't delete the month row yet)
          await (update(
            dompetMonth,
          )..where((d) => d.id.equals(dompetMonthId))).write(
            DompetMonthCompanion(
              pemasukkan: Value(safePemasukkan),
              pengeluaran: Value(safePengeluaran),
            ),
          );

          // Recalculate dompet totals
          await recalculateDompetTotals(dompetId);
        }
      }
    });
  }

  /// Hard delete by UUID - after Firestore deletion is confirmed
  Future<int> hardDeleteByUuid(String uuid) {
    return (delete(transactions)..where((t) => t.uuid.equals(uuid))).go();
  }

  /// Upsert transaction from Firestore data
  Future<void> upsertFromFirestore({
    required String uuid,
    required double amount,
    required DateTime tanggal,
    required TypeTransaction type,
    required int dompetMonthId,
    String? description,
    ExpenseCategory? expenseCategory,
    required DateTime updatedAt,
  }) async {
    final existing = await getByUuid(uuid);
    final isPemasukkan = type == TypeTransaction.pemasukkan;

    if (existing != null) {
      // Update if Firestore version is newer
      if (updatedAt.isAfter(existing.updatedAt)) {
        // Calculate amount difference for dompet month adjustment
        final oldAmount = existing.amount;
        final oldIsPemasukkan = existing.type == TypeTransaction.pemasukkan;

        await (update(transactions)..where((t) => t.uuid.equals(uuid))).write(
          TransactionsCompanion(
            amount: Value(amount),
            tanggal: Value(tanggal),
            type: Value(type),
            description: Value(description),
            expenseCategory: Value(expenseCategory),
            updatedAt: Value(updatedAt),
            isUpload: const Value(true),
          ),
        );

        // Adjust dompet month for the difference
        final dm = await (select(
          dompetMonth,
        )..where((d) => d.id.equals(dompetMonthId))).getSingleOrNull();
        if (dm != null) {
          // Subtract old
          var adjustedPemasukkan =
              dm.pemasukkan - (oldIsPemasukkan ? oldAmount : 0.0);
          var adjustedPengeluaran =
              dm.pengeluaran - (oldIsPemasukkan ? 0.0 : oldAmount);
          // Add new
          adjustedPemasukkan += (isPemasukkan ? amount : 0.0);
          adjustedPengeluaran += (isPemasukkan ? 0.0 : amount);

          await (update(
            dompetMonth,
          )..where((d) => d.id.equals(dompetMonthId))).write(
            DompetMonthCompanion(
              pemasukkan: Value(
                adjustedPemasukkan < 0 ? 0.0 : adjustedPemasukkan,
              ),
              pengeluaran: Value(
                adjustedPengeluaran < 0 ? 0.0 : adjustedPengeluaran,
              ),
            ),
          );
          await recalculateDompetTotals(dm.dompetid);
        }
      }
    } else {
      // Insert new transaction from Firestore
      await into(transactions).insert(
        TransactionsCompanion(
          uuid: Value(uuid),
          amount: Value(amount),
          tanggal: Value(tanggal),
          type: Value(type),
          dompetmonthid: Value(dompetMonthId),
          description: Value(description),
          expenseCategory: Value(expenseCategory),
          updatedAt: Value(updatedAt),
          isUpload: const Value(true),
          wantToDelete: const Value(false),
        ),
      );

      // Update dompet month totals for the new transaction
      final dm = await (select(
        dompetMonth,
      )..where((d) => d.id.equals(dompetMonthId))).getSingleOrNull();
      if (dm != null) {
        final newPemasukkan = dm.pemasukkan + (isPemasukkan ? amount : 0.0);
        final newPengeluaran = dm.pengeluaran + (isPemasukkan ? 0.0 : amount);

        await (update(
          dompetMonth,
        )..where((d) => d.id.equals(dompetMonthId))).write(
          DompetMonthCompanion(
            pemasukkan: Value(newPemasukkan),
            pengeluaran: Value(newPengeluaran),
          ),
        );
        await recalculateDompetTotals(dm.dompetid);
      }
    }
  }

  /// Get all transactions for a user (for full download)
  Future<List<Transaction>> getAllTransactionsForDompet(int dompetId) async {
    // Get all dompet months for this dompet
    final months = await (select(
      dompetMonth,
    )..where((m) => m.dompetid.equals(dompetId))).get();

    if (months.isEmpty) return [];

    final monthIds = months.map((m) => m.id).toList();

    return (select(transactions)
          ..where((t) => t.dompetmonthid.isIn(monthIds))
          ..where((t) => t.wantToDelete.equals(false)))
        .get();
  }

  /// Clear all data from the database (for logout)
  /// This ensures data from previous user doesn't leak to new user
  Future<void> clearAllData() async {
    await delete(transactions).go();
    await delete(dompetMonth).go();
    await delete(dompetTabel).go();
    await delete(tempat).go();
    await delete(budgetLimits).go();
  }
}
