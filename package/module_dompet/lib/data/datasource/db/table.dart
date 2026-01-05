import 'package:drift/drift.dart';
import 'package:module_core/constant/constant.dart';

class DompetTabel extends Table{
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userid => text().unique()();
  RealColumn get amount => real()();
  RealColumn get pengeluaran => real()();
  RealColumn get pemasukkan => real()();
}

class DompetMonth extends Table{
  IntColumn get id=> integer().autoIncrement()();
  RealColumn get pemasukkan => real()();
  RealColumn get pengeluaran => real()();
  IntColumn get month => integer()();
  IntColumn get year => integer()();

  IntColumn get dompetid => integer().references(DompetTabel, #id,onDelete: KeyAction.cascade)();

  @override
  List<Set<Column>> get uniqueKeys => [{dompetid, month, year}];
}

class Transactions extends Table{
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  DateTimeColumn get tanggal => dateTime()();
  BoolColumn get isUpload => boolean()();

  IntColumn get type  => intEnum<TypeTransaction>()();

  TextColumn get receiptImagePath => text().nullable()();
  TextColumn get voiceNotePath => text().nullable()();

  IntColumn get dompetmonthid => integer().references(DompetMonth,#id,onDelete: KeyAction.cascade)();
}

class Tempat extends Table{
  IntColumn get id =>  integer().autoIncrement()();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  TextColumn get countryCode => text()();
  TextColumn get areaCode => text()();
  TextColumn get areaSource => text()();
  
  IntColumn get transactionId => integer().references(Transactions, #id, onDelete: KeyAction.cascade)();
}