import 'package:drift/drift.dart';
import 'package:module_core/constant/constant.dart';

class DompetTabel extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userid => text().unique()();
  RealColumn get amount => real()();
  RealColumn get pengeluaran => real()();
  RealColumn get pemasukkan => real()();
}

class DompetMonth extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get pemasukkan => real()();
  RealColumn get pengeluaran => real()();
  IntColumn get month => integer()();
  IntColumn get year => integer()();

  IntColumn get dompetid =>
      integer().references(DompetTabel, #id, onDelete: KeyAction.cascade)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {dompetid, month, year},
  ];
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// UUID for Firestore sync - auto-generated when created offline
  TextColumn get uuid => text().unique()();

  RealColumn get amount => real()();
  DateTimeColumn get tanggal => dateTime()();
  BoolColumn get isUpload => boolean().withDefault(const Constant(false))();

  /// Soft delete flag - when true, will be deleted from Firestore on next sync
  BoolColumn get wantToDelete => boolean().withDefault(const Constant(false))();

  /// Last update timestamp for sync conflict resolution
  DateTimeColumn get updatedAt => dateTime()();

  IntColumn get type => intEnum<TypeTransaction>()();

  /// Description for the transaction
  TextColumn get description => text().nullable()();

  /// Expense category (only applicable for pengeluaran type)
  IntColumn get expenseCategory => intEnum<ExpenseCategory>().nullable()();

  TextColumn get receiptImagePath => text().nullable()();
  TextColumn get voiceNotePath => text().nullable()();

  IntColumn get dompetmonthid =>
      integer().references(DompetMonth, #id, onDelete: KeyAction.cascade)();
}

class Tempat extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  TextColumn get countryCode => text()();
  TextColumn get areaCode => text()();
  TextColumn get areaSource => text()();

  IntColumn get transactionId =>
      integer().references(Transactions, #id, onDelete: KeyAction.cascade)();
}

/// Budget limits for each expense category per month
class BudgetLimits extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get dompetId =>
      integer().references(DompetTabel, #id, onDelete: KeyAction.cascade)();
  IntColumn get category => intEnum<ExpenseCategory>()();
  RealColumn get limitAmount => real()();
  IntColumn get month => integer()();
  IntColumn get year => integer()();
  BoolColumn get isNotified => boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {dompetId, category, month, year},
  ];
}
