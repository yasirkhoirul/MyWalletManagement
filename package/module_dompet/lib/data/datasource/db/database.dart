import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:module_core/constant/constant.dart';
import 'package:module_dompet/data/datasource/db/dao.dart';
import 'package:module_dompet/data/datasource/db/table.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [DompetTabel, DompetMonth, Transactions, Tempat],
  daos: [TransactionDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Opsional: Migrasi jika nanti ada perubahan struktur
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        // PENTING: Aktifkan Foreign Keys agar 'onDelete: Cascade' jalan!
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Cari lokasi folder dokumen aplikasi
    final dbFolder = await getApplicationDocumentsDirectory();
    // Beri nama file database
    final file = File(join(dbFolder.path, 'keuangan_pribadi.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}
