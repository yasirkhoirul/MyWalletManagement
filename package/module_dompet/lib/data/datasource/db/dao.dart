import 'package:drift/drift.dart';
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
  Future<int> deleteTransaction(int transactionId){
    return (delete(transactions)..where((tbl) => tbl.id.equals(transactionId),)).go();
  }
}
