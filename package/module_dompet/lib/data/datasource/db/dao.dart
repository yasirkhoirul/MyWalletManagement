import 'package:drift/drift.dart';
import 'package:module_core/constant/constant.dart';
import 'package:module_dompet/data/datasource/db/database.dart';
import 'package:module_dompet/data/datasource/db/table.dart';
import 'package:module_dompet/data/model/transaction_detail_model.dart';

part 'dao.g.dart';

@DriftAccessor(tables: [DompetTabel, DompetMonth, Transactions, Tempat])
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
      final oldTx = await (select(transactions)..where((t) => t.id.equals(data.id!))).getSingleOrNull();
      if (oldTx == null) {
        throw ArgumentError('Transaction not found for update');
      }

      // Update the transaction row
      await (update(transactions)..where((t) => t.id.equals(data.id!))).write(
        TransactionsCompanion(
          amount: Value(data.amount),
          tanggal: Value(data.tanggal),
          isUpload: Value(data.isUpload),
          type: Value(data.type),
          receiptImagePath: Value(data.receiptImagePath),
          voiceNotePath: Value(data.voiceNotePath),
          dompetmonthid: Value(data.dompetmonthid),
        ),
      );

      // Adjust DompetMonth: subtract old amount, add new amount
      final dompetMonthId = oldTx.dompetmonthid;
      if (dompetMonthId != null) {
        final dm = await (select(dompetMonth)..where((d) => d.id.equals(dompetMonthId))).getSingleOrNull();
        if (dm != null) {
          final oldIsPemasukkan = oldTx.type == TypeTransaction.pemasukkan;
          final newIsPemasukkan = data.type == TypeTransaction.pemasukkan;

          // Subtract old amount
          var adjustedPemasukkan = dm.pemasukkan - (oldIsPemasukkan ? oldTx.amount : 0.0);
          var adjustedPengeluaran = dm.pengeluaran - (oldIsPemasukkan ? 0.0 : oldTx.amount);

          // Add new amount
          adjustedPemasukkan += (newIsPemasukkan ? data.amount : 0.0);
          adjustedPengeluaran += (newIsPemasukkan ? 0.0 : data.amount);

          // Safety: ensure non-negative
          adjustedPemasukkan = adjustedPemasukkan < 0 ? 0.0 : adjustedPemasukkan;
          adjustedPengeluaran = adjustedPengeluaran < 0 ? 0.0 : adjustedPengeluaran;

          await (update(dompetMonth)..where((d) => d.id.equals(dompetMonthId))).write(
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
      final tx = await (select(transactions)..where((t) => t.id.equals(transactionId))).getSingleOrNull();
      if (tx == null) return 0;

      final dompetMonthId = tx.dompetmonthid;
      final amount = tx.amount;
      final isPemasukkan = tx.type == TypeTransaction.pemasukkan;

      // Delete the transaction (this cascades to Tempat due to FK)
      final deletedCount = await (delete(transactions)..where((t) => t.id.equals(transactionId))).go();

      // Adjust the DompetMonth aggregates if applicable
      if (dompetMonthId != null) {
        final dm = await (select(dompetMonth)..where((d) => d.id.equals(dompetMonthId))).getSingleOrNull();
        if (dm != null) {
          final newPemasukkan = dm.pemasukkan - (isPemasukkan ? amount : 0.0);
          final newPengeluaran = dm.pengeluaran - (isPemasukkan ? 0.0 : amount);

          final safePemasukkan = newPemasukkan < 0 ? 0.0 : newPemasukkan;
          final safePengeluaran = newPengeluaran < 0 ? 0.0 : newPengeluaran;

          if (safePemasukkan == 0.0 && safePengeluaran == 0.0) {
            // If both totals are zero, remove the month row
            await (delete(dompetMonth)..where((d) => d.id.equals(dompetMonthId))).go();
          } else {
            // Otherwise update the aggregates
            await (update(dompetMonth)..where((d) => d.id.equals(dompetMonthId))).write(
              DompetMonthCompanion(
                pemasukkan: Value(safePemasukkan),
                pengeluaran: Value(safePengeluaran),
              ),
            );
          }
        }
      }

      return deletedCount;
    });
  }

  Future<int> deleteDompetMonth(int dompetMonthId){
    return (delete(dompetMonth)..where((tbl) => tbl.id.equals(dompetMonthId),)).go();
  }

  // DompetMonth operations
  Stream<List<DompetMonthData>> watchDompetMonths(int dompetId) {
    return (select(dompetMonth)
      ..where((tbl) => tbl.dompetid.equals(dompetId))
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.year, mode: OrderingMode.desc),
                 (tbl) => OrderingTerm(expression: tbl.month, mode: OrderingMode.desc)]))
      .watch();
  }

  Future<DompetMonthData?> getDompetMonthByDate(int dompetId, int month, int year) async {
    final query = select(dompetMonth)
      ..where((tbl) => tbl.dompetid.equals(dompetId) & 
                       tbl.month.equals(month) & 
                       tbl.year.equals(year));
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

      if (existing == null) {
        // Create new record
        return await into(dompetMonth).insert(
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

        await (update(dompetMonth)..where((tbl) => tbl.id.equals(existing.id)))
          .write(DompetMonthCompanion(
            pemasukkan: Value(newPemasukkan),
            pengeluaran: Value(newPengeluaran),
          ));
        
        return existing.id;
      }
    });
  }

  // Ensure DompetTabel record exists for the given dompetId
  Future<void> _ensureDompetExists(int dompetId) async {
    final existing = await (select(dompetTabel)
      ..where((tbl) => tbl.id.equals(dompetId)))
      .getSingleOrNull();
    
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
}
