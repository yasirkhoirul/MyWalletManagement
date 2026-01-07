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
  tables: [DompetTabel, DompetMonth, Transactions, Tempat, BudgetLimits],
  daos: [TransactionDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  // Migrasi untuk perubahan struktur
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        // PENTING: Aktifkan Foreign Keys agar 'onDelete: Cascade' jalan!
        await customStatement('PRAGMA foreign_keys = ON');
      },
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          // Add description and expense_category columns to transactions
          await customStatement(
            'ALTER TABLE transactions ADD COLUMN description TEXT',
          );
          await customStatement(
            'ALTER TABLE transactions ADD COLUMN expense_category INTEGER',
          );
        }
        if (from < 3) {
          // Create budget_limits table
          await customStatement('''
            CREATE TABLE IF NOT EXISTS budget_limits (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              dompet_id INTEGER NOT NULL REFERENCES dompet_tabel(id) ON DELETE CASCADE,
              category INTEGER NOT NULL,
              limit_amount REAL NOT NULL,
              month INTEGER NOT NULL,
              year INTEGER NOT NULL,
              is_notified INTEGER NOT NULL DEFAULT 0,
              UNIQUE(dompet_id, category, month, year)
            )
          ''');
        }
        if (from < 4) {
          // Add sync-related columns to transactions
          await customStatement(
            'ALTER TABLE transactions ADD COLUMN uuid TEXT',
          );
          await customStatement(
            'ALTER TABLE transactions ADD COLUMN want_to_delete INTEGER NOT NULL DEFAULT 0',
          );
          await customStatement(
            'ALTER TABLE transactions ADD COLUMN updated_at INTEGER',
          );
          // Generate UUIDs for existing transactions that don't have one
          await customStatement('''
            UPDATE transactions 
            SET uuid = hex(randomblob(16)), 
                updated_at = strftime('%s', 'now') * 1000
            WHERE uuid IS NULL
          ''');
          // Make uuid NOT NULL and UNIQUE after populating
          // Note: SQLite doesn't support ALTER COLUMN, so we work with nullable for now
          // The app will ensure all new transactions have UUIDs
        }
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
