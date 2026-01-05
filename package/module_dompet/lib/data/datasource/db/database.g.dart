// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DompetTabelTable extends DompetTabel
    with TableInfo<$DompetTabelTable, DompetTabelData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DompetTabelTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _useridMeta = const VerificationMeta('userid');
  @override
  late final GeneratedColumn<String> userid = GeneratedColumn<String>(
    'userid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pengeluaranMeta = const VerificationMeta(
    'pengeluaran',
  );
  @override
  late final GeneratedColumn<double> pengeluaran = GeneratedColumn<double>(
    'pengeluaran',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pemasukkanMeta = const VerificationMeta(
    'pemasukkan',
  );
  @override
  late final GeneratedColumn<double> pemasukkan = GeneratedColumn<double>(
    'pemasukkan',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userid,
    amount,
    pengeluaran,
    pemasukkan,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dompet_tabel';
  @override
  VerificationContext validateIntegrity(
    Insertable<DompetTabelData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('userid')) {
      context.handle(
        _useridMeta,
        userid.isAcceptableOrUnknown(data['userid']!, _useridMeta),
      );
    } else if (isInserting) {
      context.missing(_useridMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('pengeluaran')) {
      context.handle(
        _pengeluaranMeta,
        pengeluaran.isAcceptableOrUnknown(
          data['pengeluaran']!,
          _pengeluaranMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pengeluaranMeta);
    }
    if (data.containsKey('pemasukkan')) {
      context.handle(
        _pemasukkanMeta,
        pemasukkan.isAcceptableOrUnknown(data['pemasukkan']!, _pemasukkanMeta),
      );
    } else if (isInserting) {
      context.missing(_pemasukkanMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DompetTabelData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DompetTabelData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}userid'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      pengeluaran: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pengeluaran'],
      )!,
      pemasukkan: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pemasukkan'],
      )!,
    );
  }

  @override
  $DompetTabelTable createAlias(String alias) {
    return $DompetTabelTable(attachedDatabase, alias);
  }
}

class DompetTabelData extends DataClass implements Insertable<DompetTabelData> {
  final int id;
  final String userid;
  final double amount;
  final double pengeluaran;
  final double pemasukkan;
  const DompetTabelData({
    required this.id,
    required this.userid,
    required this.amount,
    required this.pengeluaran,
    required this.pemasukkan,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['userid'] = Variable<String>(userid);
    map['amount'] = Variable<double>(amount);
    map['pengeluaran'] = Variable<double>(pengeluaran);
    map['pemasukkan'] = Variable<double>(pemasukkan);
    return map;
  }

  DompetTabelCompanion toCompanion(bool nullToAbsent) {
    return DompetTabelCompanion(
      id: Value(id),
      userid: Value(userid),
      amount: Value(amount),
      pengeluaran: Value(pengeluaran),
      pemasukkan: Value(pemasukkan),
    );
  }

  factory DompetTabelData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DompetTabelData(
      id: serializer.fromJson<int>(json['id']),
      userid: serializer.fromJson<String>(json['userid']),
      amount: serializer.fromJson<double>(json['amount']),
      pengeluaran: serializer.fromJson<double>(json['pengeluaran']),
      pemasukkan: serializer.fromJson<double>(json['pemasukkan']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userid': serializer.toJson<String>(userid),
      'amount': serializer.toJson<double>(amount),
      'pengeluaran': serializer.toJson<double>(pengeluaran),
      'pemasukkan': serializer.toJson<double>(pemasukkan),
    };
  }

  DompetTabelData copyWith({
    int? id,
    String? userid,
    double? amount,
    double? pengeluaran,
    double? pemasukkan,
  }) => DompetTabelData(
    id: id ?? this.id,
    userid: userid ?? this.userid,
    amount: amount ?? this.amount,
    pengeluaran: pengeluaran ?? this.pengeluaran,
    pemasukkan: pemasukkan ?? this.pemasukkan,
  );
  DompetTabelData copyWithCompanion(DompetTabelCompanion data) {
    return DompetTabelData(
      id: data.id.present ? data.id.value : this.id,
      userid: data.userid.present ? data.userid.value : this.userid,
      amount: data.amount.present ? data.amount.value : this.amount,
      pengeluaran: data.pengeluaran.present
          ? data.pengeluaran.value
          : this.pengeluaran,
      pemasukkan: data.pemasukkan.present
          ? data.pemasukkan.value
          : this.pemasukkan,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DompetTabelData(')
          ..write('id: $id, ')
          ..write('userid: $userid, ')
          ..write('amount: $amount, ')
          ..write('pengeluaran: $pengeluaran, ')
          ..write('pemasukkan: $pemasukkan')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userid, amount, pengeluaran, pemasukkan);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DompetTabelData &&
          other.id == this.id &&
          other.userid == this.userid &&
          other.amount == this.amount &&
          other.pengeluaran == this.pengeluaran &&
          other.pemasukkan == this.pemasukkan);
}

class DompetTabelCompanion extends UpdateCompanion<DompetTabelData> {
  final Value<int> id;
  final Value<String> userid;
  final Value<double> amount;
  final Value<double> pengeluaran;
  final Value<double> pemasukkan;
  const DompetTabelCompanion({
    this.id = const Value.absent(),
    this.userid = const Value.absent(),
    this.amount = const Value.absent(),
    this.pengeluaran = const Value.absent(),
    this.pemasukkan = const Value.absent(),
  });
  DompetTabelCompanion.insert({
    this.id = const Value.absent(),
    required String userid,
    required double amount,
    required double pengeluaran,
    required double pemasukkan,
  }) : userid = Value(userid),
       amount = Value(amount),
       pengeluaran = Value(pengeluaran),
       pemasukkan = Value(pemasukkan);
  static Insertable<DompetTabelData> custom({
    Expression<int>? id,
    Expression<String>? userid,
    Expression<double>? amount,
    Expression<double>? pengeluaran,
    Expression<double>? pemasukkan,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userid != null) 'userid': userid,
      if (amount != null) 'amount': amount,
      if (pengeluaran != null) 'pengeluaran': pengeluaran,
      if (pemasukkan != null) 'pemasukkan': pemasukkan,
    });
  }

  DompetTabelCompanion copyWith({
    Value<int>? id,
    Value<String>? userid,
    Value<double>? amount,
    Value<double>? pengeluaran,
    Value<double>? pemasukkan,
  }) {
    return DompetTabelCompanion(
      id: id ?? this.id,
      userid: userid ?? this.userid,
      amount: amount ?? this.amount,
      pengeluaran: pengeluaran ?? this.pengeluaran,
      pemasukkan: pemasukkan ?? this.pemasukkan,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userid.present) {
      map['userid'] = Variable<String>(userid.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (pengeluaran.present) {
      map['pengeluaran'] = Variable<double>(pengeluaran.value);
    }
    if (pemasukkan.present) {
      map['pemasukkan'] = Variable<double>(pemasukkan.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DompetTabelCompanion(')
          ..write('id: $id, ')
          ..write('userid: $userid, ')
          ..write('amount: $amount, ')
          ..write('pengeluaran: $pengeluaran, ')
          ..write('pemasukkan: $pemasukkan')
          ..write(')'))
        .toString();
  }
}

class $DompetMonthTable extends DompetMonth
    with TableInfo<$DompetMonthTable, DompetMonthData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DompetMonthTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pemasukkanMeta = const VerificationMeta(
    'pemasukkan',
  );
  @override
  late final GeneratedColumn<double> pemasukkan = GeneratedColumn<double>(
    'pemasukkan',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pengeluaranMeta = const VerificationMeta(
    'pengeluaran',
  );
  @override
  late final GeneratedColumn<double> pengeluaran = GeneratedColumn<double>(
    'pengeluaran',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<int> month = GeneratedColumn<int>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dompetidMeta = const VerificationMeta(
    'dompetid',
  );
  @override
  late final GeneratedColumn<int> dompetid = GeneratedColumn<int>(
    'dompetid',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES dompet_tabel (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pemasukkan,
    pengeluaran,
    month,
    year,
    dompetid,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dompet_month';
  @override
  VerificationContext validateIntegrity(
    Insertable<DompetMonthData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pemasukkan')) {
      context.handle(
        _pemasukkanMeta,
        pemasukkan.isAcceptableOrUnknown(data['pemasukkan']!, _pemasukkanMeta),
      );
    } else if (isInserting) {
      context.missing(_pemasukkanMeta);
    }
    if (data.containsKey('pengeluaran')) {
      context.handle(
        _pengeluaranMeta,
        pengeluaran.isAcceptableOrUnknown(
          data['pengeluaran']!,
          _pengeluaranMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pengeluaranMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('dompetid')) {
      context.handle(
        _dompetidMeta,
        dompetid.isAcceptableOrUnknown(data['dompetid']!, _dompetidMeta),
      );
    } else if (isInserting) {
      context.missing(_dompetidMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {dompetid, month, year},
  ];
  @override
  DompetMonthData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DompetMonthData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pemasukkan: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pemasukkan'],
      )!,
      pengeluaran: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pengeluaran'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      dompetid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dompetid'],
      )!,
    );
  }

  @override
  $DompetMonthTable createAlias(String alias) {
    return $DompetMonthTable(attachedDatabase, alias);
  }
}

class DompetMonthData extends DataClass implements Insertable<DompetMonthData> {
  final int id;
  final double pemasukkan;
  final double pengeluaran;
  final int month;
  final int year;
  final int dompetid;
  const DompetMonthData({
    required this.id,
    required this.pemasukkan,
    required this.pengeluaran,
    required this.month,
    required this.year,
    required this.dompetid,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pemasukkan'] = Variable<double>(pemasukkan);
    map['pengeluaran'] = Variable<double>(pengeluaran);
    map['month'] = Variable<int>(month);
    map['year'] = Variable<int>(year);
    map['dompetid'] = Variable<int>(dompetid);
    return map;
  }

  DompetMonthCompanion toCompanion(bool nullToAbsent) {
    return DompetMonthCompanion(
      id: Value(id),
      pemasukkan: Value(pemasukkan),
      pengeluaran: Value(pengeluaran),
      month: Value(month),
      year: Value(year),
      dompetid: Value(dompetid),
    );
  }

  factory DompetMonthData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DompetMonthData(
      id: serializer.fromJson<int>(json['id']),
      pemasukkan: serializer.fromJson<double>(json['pemasukkan']),
      pengeluaran: serializer.fromJson<double>(json['pengeluaran']),
      month: serializer.fromJson<int>(json['month']),
      year: serializer.fromJson<int>(json['year']),
      dompetid: serializer.fromJson<int>(json['dompetid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pemasukkan': serializer.toJson<double>(pemasukkan),
      'pengeluaran': serializer.toJson<double>(pengeluaran),
      'month': serializer.toJson<int>(month),
      'year': serializer.toJson<int>(year),
      'dompetid': serializer.toJson<int>(dompetid),
    };
  }

  DompetMonthData copyWith({
    int? id,
    double? pemasukkan,
    double? pengeluaran,
    int? month,
    int? year,
    int? dompetid,
  }) => DompetMonthData(
    id: id ?? this.id,
    pemasukkan: pemasukkan ?? this.pemasukkan,
    pengeluaran: pengeluaran ?? this.pengeluaran,
    month: month ?? this.month,
    year: year ?? this.year,
    dompetid: dompetid ?? this.dompetid,
  );
  DompetMonthData copyWithCompanion(DompetMonthCompanion data) {
    return DompetMonthData(
      id: data.id.present ? data.id.value : this.id,
      pemasukkan: data.pemasukkan.present
          ? data.pemasukkan.value
          : this.pemasukkan,
      pengeluaran: data.pengeluaran.present
          ? data.pengeluaran.value
          : this.pengeluaran,
      month: data.month.present ? data.month.value : this.month,
      year: data.year.present ? data.year.value : this.year,
      dompetid: data.dompetid.present ? data.dompetid.value : this.dompetid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DompetMonthData(')
          ..write('id: $id, ')
          ..write('pemasukkan: $pemasukkan, ')
          ..write('pengeluaran: $pengeluaran, ')
          ..write('month: $month, ')
          ..write('year: $year, ')
          ..write('dompetid: $dompetid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, pemasukkan, pengeluaran, month, year, dompetid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DompetMonthData &&
          other.id == this.id &&
          other.pemasukkan == this.pemasukkan &&
          other.pengeluaran == this.pengeluaran &&
          other.month == this.month &&
          other.year == this.year &&
          other.dompetid == this.dompetid);
}

class DompetMonthCompanion extends UpdateCompanion<DompetMonthData> {
  final Value<int> id;
  final Value<double> pemasukkan;
  final Value<double> pengeluaran;
  final Value<int> month;
  final Value<int> year;
  final Value<int> dompetid;
  const DompetMonthCompanion({
    this.id = const Value.absent(),
    this.pemasukkan = const Value.absent(),
    this.pengeluaran = const Value.absent(),
    this.month = const Value.absent(),
    this.year = const Value.absent(),
    this.dompetid = const Value.absent(),
  });
  DompetMonthCompanion.insert({
    this.id = const Value.absent(),
    required double pemasukkan,
    required double pengeluaran,
    required int month,
    required int year,
    required int dompetid,
  }) : pemasukkan = Value(pemasukkan),
       pengeluaran = Value(pengeluaran),
       month = Value(month),
       year = Value(year),
       dompetid = Value(dompetid);
  static Insertable<DompetMonthData> custom({
    Expression<int>? id,
    Expression<double>? pemasukkan,
    Expression<double>? pengeluaran,
    Expression<int>? month,
    Expression<int>? year,
    Expression<int>? dompetid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pemasukkan != null) 'pemasukkan': pemasukkan,
      if (pengeluaran != null) 'pengeluaran': pengeluaran,
      if (month != null) 'month': month,
      if (year != null) 'year': year,
      if (dompetid != null) 'dompetid': dompetid,
    });
  }

  DompetMonthCompanion copyWith({
    Value<int>? id,
    Value<double>? pemasukkan,
    Value<double>? pengeluaran,
    Value<int>? month,
    Value<int>? year,
    Value<int>? dompetid,
  }) {
    return DompetMonthCompanion(
      id: id ?? this.id,
      pemasukkan: pemasukkan ?? this.pemasukkan,
      pengeluaran: pengeluaran ?? this.pengeluaran,
      month: month ?? this.month,
      year: year ?? this.year,
      dompetid: dompetid ?? this.dompetid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pemasukkan.present) {
      map['pemasukkan'] = Variable<double>(pemasukkan.value);
    }
    if (pengeluaran.present) {
      map['pengeluaran'] = Variable<double>(pengeluaran.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (dompetid.present) {
      map['dompetid'] = Variable<int>(dompetid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DompetMonthCompanion(')
          ..write('id: $id, ')
          ..write('pemasukkan: $pemasukkan, ')
          ..write('pengeluaran: $pengeluaran, ')
          ..write('month: $month, ')
          ..write('year: $year, ')
          ..write('dompetid: $dompetid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tanggalMeta = const VerificationMeta(
    'tanggal',
  );
  @override
  late final GeneratedColumn<DateTime> tanggal = GeneratedColumn<DateTime>(
    'tanggal',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isUploadMeta = const VerificationMeta(
    'isUpload',
  );
  @override
  late final GeneratedColumn<bool> isUpload = GeneratedColumn<bool>(
    'is_upload',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_upload" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TypeTransaction, int> type =
      GeneratedColumn<int>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<TypeTransaction>($TransactionsTable.$convertertype);
  static const VerificationMeta _receiptImagePathMeta = const VerificationMeta(
    'receiptImagePath',
  );
  @override
  late final GeneratedColumn<String> receiptImagePath = GeneratedColumn<String>(
    'receipt_image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voiceNotePathMeta = const VerificationMeta(
    'voiceNotePath',
  );
  @override
  late final GeneratedColumn<String> voiceNotePath = GeneratedColumn<String>(
    'voice_note_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dompetmonthidMeta = const VerificationMeta(
    'dompetmonthid',
  );
  @override
  late final GeneratedColumn<int> dompetmonthid = GeneratedColumn<int>(
    'dompetmonthid',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES dompet_month (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amount,
    tanggal,
    isUpload,
    type,
    receiptImagePath,
    voiceNotePath,
    dompetmonthid,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('tanggal')) {
      context.handle(
        _tanggalMeta,
        tanggal.isAcceptableOrUnknown(data['tanggal']!, _tanggalMeta),
      );
    } else if (isInserting) {
      context.missing(_tanggalMeta);
    }
    if (data.containsKey('is_upload')) {
      context.handle(
        _isUploadMeta,
        isUpload.isAcceptableOrUnknown(data['is_upload']!, _isUploadMeta),
      );
    } else if (isInserting) {
      context.missing(_isUploadMeta);
    }
    if (data.containsKey('receipt_image_path')) {
      context.handle(
        _receiptImagePathMeta,
        receiptImagePath.isAcceptableOrUnknown(
          data['receipt_image_path']!,
          _receiptImagePathMeta,
        ),
      );
    }
    if (data.containsKey('voice_note_path')) {
      context.handle(
        _voiceNotePathMeta,
        voiceNotePath.isAcceptableOrUnknown(
          data['voice_note_path']!,
          _voiceNotePathMeta,
        ),
      );
    }
    if (data.containsKey('dompetmonthid')) {
      context.handle(
        _dompetmonthidMeta,
        dompetmonthid.isAcceptableOrUnknown(
          data['dompetmonthid']!,
          _dompetmonthidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dompetmonthidMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      tanggal: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tanggal'],
      )!,
      isUpload: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_upload'],
      )!,
      type: $TransactionsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}type'],
        )!,
      ),
      receiptImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_image_path'],
      ),
      voiceNotePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voice_note_path'],
      ),
      dompetmonthid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dompetmonthid'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TypeTransaction, int, int> $convertertype =
      const EnumIndexConverter<TypeTransaction>(TypeTransaction.values);
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final double amount;
  final DateTime tanggal;
  final bool isUpload;
  final TypeTransaction type;
  final String? receiptImagePath;
  final String? voiceNotePath;
  final int dompetmonthid;
  const Transaction({
    required this.id,
    required this.amount,
    required this.tanggal,
    required this.isUpload,
    required this.type,
    this.receiptImagePath,
    this.voiceNotePath,
    required this.dompetmonthid,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount'] = Variable<double>(amount);
    map['tanggal'] = Variable<DateTime>(tanggal);
    map['is_upload'] = Variable<bool>(isUpload);
    {
      map['type'] = Variable<int>(
        $TransactionsTable.$convertertype.toSql(type),
      );
    }
    if (!nullToAbsent || receiptImagePath != null) {
      map['receipt_image_path'] = Variable<String>(receiptImagePath);
    }
    if (!nullToAbsent || voiceNotePath != null) {
      map['voice_note_path'] = Variable<String>(voiceNotePath);
    }
    map['dompetmonthid'] = Variable<int>(dompetmonthid);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      amount: Value(amount),
      tanggal: Value(tanggal),
      isUpload: Value(isUpload),
      type: Value(type),
      receiptImagePath: receiptImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptImagePath),
      voiceNotePath: voiceNotePath == null && nullToAbsent
          ? const Value.absent()
          : Value(voiceNotePath),
      dompetmonthid: Value(dompetmonthid),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      amount: serializer.fromJson<double>(json['amount']),
      tanggal: serializer.fromJson<DateTime>(json['tanggal']),
      isUpload: serializer.fromJson<bool>(json['isUpload']),
      type: $TransactionsTable.$convertertype.fromJson(
        serializer.fromJson<int>(json['type']),
      ),
      receiptImagePath: serializer.fromJson<String?>(json['receiptImagePath']),
      voiceNotePath: serializer.fromJson<String?>(json['voiceNotePath']),
      dompetmonthid: serializer.fromJson<int>(json['dompetmonthid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amount': serializer.toJson<double>(amount),
      'tanggal': serializer.toJson<DateTime>(tanggal),
      'isUpload': serializer.toJson<bool>(isUpload),
      'type': serializer.toJson<int>(
        $TransactionsTable.$convertertype.toJson(type),
      ),
      'receiptImagePath': serializer.toJson<String?>(receiptImagePath),
      'voiceNotePath': serializer.toJson<String?>(voiceNotePath),
      'dompetmonthid': serializer.toJson<int>(dompetmonthid),
    };
  }

  Transaction copyWith({
    int? id,
    double? amount,
    DateTime? tanggal,
    bool? isUpload,
    TypeTransaction? type,
    Value<String?> receiptImagePath = const Value.absent(),
    Value<String?> voiceNotePath = const Value.absent(),
    int? dompetmonthid,
  }) => Transaction(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    tanggal: tanggal ?? this.tanggal,
    isUpload: isUpload ?? this.isUpload,
    type: type ?? this.type,
    receiptImagePath: receiptImagePath.present
        ? receiptImagePath.value
        : this.receiptImagePath,
    voiceNotePath: voiceNotePath.present
        ? voiceNotePath.value
        : this.voiceNotePath,
    dompetmonthid: dompetmonthid ?? this.dompetmonthid,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      tanggal: data.tanggal.present ? data.tanggal.value : this.tanggal,
      isUpload: data.isUpload.present ? data.isUpload.value : this.isUpload,
      type: data.type.present ? data.type.value : this.type,
      receiptImagePath: data.receiptImagePath.present
          ? data.receiptImagePath.value
          : this.receiptImagePath,
      voiceNotePath: data.voiceNotePath.present
          ? data.voiceNotePath.value
          : this.voiceNotePath,
      dompetmonthid: data.dompetmonthid.present
          ? data.dompetmonthid.value
          : this.dompetmonthid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('tanggal: $tanggal, ')
          ..write('isUpload: $isUpload, ')
          ..write('type: $type, ')
          ..write('receiptImagePath: $receiptImagePath, ')
          ..write('voiceNotePath: $voiceNotePath, ')
          ..write('dompetmonthid: $dompetmonthid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amount,
    tanggal,
    isUpload,
    type,
    receiptImagePath,
    voiceNotePath,
    dompetmonthid,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.tanggal == this.tanggal &&
          other.isUpload == this.isUpload &&
          other.type == this.type &&
          other.receiptImagePath == this.receiptImagePath &&
          other.voiceNotePath == this.voiceNotePath &&
          other.dompetmonthid == this.dompetmonthid);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<double> amount;
  final Value<DateTime> tanggal;
  final Value<bool> isUpload;
  final Value<TypeTransaction> type;
  final Value<String?> receiptImagePath;
  final Value<String?> voiceNotePath;
  final Value<int> dompetmonthid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.tanggal = const Value.absent(),
    this.isUpload = const Value.absent(),
    this.type = const Value.absent(),
    this.receiptImagePath = const Value.absent(),
    this.voiceNotePath = const Value.absent(),
    this.dompetmonthid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required double amount,
    required DateTime tanggal,
    required bool isUpload,
    required TypeTransaction type,
    this.receiptImagePath = const Value.absent(),
    this.voiceNotePath = const Value.absent(),
    required int dompetmonthid,
  }) : amount = Value(amount),
       tanggal = Value(tanggal),
       isUpload = Value(isUpload),
       type = Value(type),
       dompetmonthid = Value(dompetmonthid);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<double>? amount,
    Expression<DateTime>? tanggal,
    Expression<bool>? isUpload,
    Expression<int>? type,
    Expression<String>? receiptImagePath,
    Expression<String>? voiceNotePath,
    Expression<int>? dompetmonthid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (tanggal != null) 'tanggal': tanggal,
      if (isUpload != null) 'is_upload': isUpload,
      if (type != null) 'type': type,
      if (receiptImagePath != null) 'receipt_image_path': receiptImagePath,
      if (voiceNotePath != null) 'voice_note_path': voiceNotePath,
      if (dompetmonthid != null) 'dompetmonthid': dompetmonthid,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<double>? amount,
    Value<DateTime>? tanggal,
    Value<bool>? isUpload,
    Value<TypeTransaction>? type,
    Value<String?>? receiptImagePath,
    Value<String?>? voiceNotePath,
    Value<int>? dompetmonthid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      tanggal: tanggal ?? this.tanggal,
      isUpload: isUpload ?? this.isUpload,
      type: type ?? this.type,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      voiceNotePath: voiceNotePath ?? this.voiceNotePath,
      dompetmonthid: dompetmonthid ?? this.dompetmonthid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (tanggal.present) {
      map['tanggal'] = Variable<DateTime>(tanggal.value);
    }
    if (isUpload.present) {
      map['is_upload'] = Variable<bool>(isUpload.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(
        $TransactionsTable.$convertertype.toSql(type.value),
      );
    }
    if (receiptImagePath.present) {
      map['receipt_image_path'] = Variable<String>(receiptImagePath.value);
    }
    if (voiceNotePath.present) {
      map['voice_note_path'] = Variable<String>(voiceNotePath.value);
    }
    if (dompetmonthid.present) {
      map['dompetmonthid'] = Variable<int>(dompetmonthid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('tanggal: $tanggal, ')
          ..write('isUpload: $isUpload, ')
          ..write('type: $type, ')
          ..write('receiptImagePath: $receiptImagePath, ')
          ..write('voiceNotePath: $voiceNotePath, ')
          ..write('dompetmonthid: $dompetmonthid')
          ..write(')'))
        .toString();
  }
}

class $TempatTable extends Tempat with TableInfo<$TempatTable, TempatData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TempatTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countryCodeMeta = const VerificationMeta(
    'countryCode',
  );
  @override
  late final GeneratedColumn<String> countryCode = GeneratedColumn<String>(
    'country_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areaCodeMeta = const VerificationMeta(
    'areaCode',
  );
  @override
  late final GeneratedColumn<String> areaCode = GeneratedColumn<String>(
    'area_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areaSourceMeta = const VerificationMeta(
    'areaSource',
  );
  @override
  late final GeneratedColumn<String> areaSource = GeneratedColumn<String>(
    'area_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lat,
    lng,
    countryCode,
    areaCode,
    areaSource,
    transactionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tempat';
  @override
  VerificationContext validateIntegrity(
    Insertable<TempatData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('country_code')) {
      context.handle(
        _countryCodeMeta,
        countryCode.isAcceptableOrUnknown(
          data['country_code']!,
          _countryCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_countryCodeMeta);
    }
    if (data.containsKey('area_code')) {
      context.handle(
        _areaCodeMeta,
        areaCode.isAcceptableOrUnknown(data['area_code']!, _areaCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_areaCodeMeta);
    }
    if (data.containsKey('area_source')) {
      context.handle(
        _areaSourceMeta,
        areaSource.isAcceptableOrUnknown(data['area_source']!, _areaSourceMeta),
      );
    } else if (isInserting) {
      context.missing(_areaSourceMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TempatData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TempatData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      )!,
      countryCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country_code'],
      )!,
      areaCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area_code'],
      )!,
      areaSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area_source'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaction_id'],
      )!,
    );
  }

  @override
  $TempatTable createAlias(String alias) {
    return $TempatTable(attachedDatabase, alias);
  }
}

class TempatData extends DataClass implements Insertable<TempatData> {
  final int id;
  final double lat;
  final double lng;
  final String countryCode;
  final String areaCode;
  final String areaSource;
  final int transactionId;
  const TempatData({
    required this.id,
    required this.lat,
    required this.lng,
    required this.countryCode,
    required this.areaCode,
    required this.areaSource,
    required this.transactionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    map['country_code'] = Variable<String>(countryCode);
    map['area_code'] = Variable<String>(areaCode);
    map['area_source'] = Variable<String>(areaSource);
    map['transaction_id'] = Variable<int>(transactionId);
    return map;
  }

  TempatCompanion toCompanion(bool nullToAbsent) {
    return TempatCompanion(
      id: Value(id),
      lat: Value(lat),
      lng: Value(lng),
      countryCode: Value(countryCode),
      areaCode: Value(areaCode),
      areaSource: Value(areaSource),
      transactionId: Value(transactionId),
    );
  }

  factory TempatData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TempatData(
      id: serializer.fromJson<int>(json['id']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      countryCode: serializer.fromJson<String>(json['countryCode']),
      areaCode: serializer.fromJson<String>(json['areaCode']),
      areaSource: serializer.fromJson<String>(json['areaSource']),
      transactionId: serializer.fromJson<int>(json['transactionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'countryCode': serializer.toJson<String>(countryCode),
      'areaCode': serializer.toJson<String>(areaCode),
      'areaSource': serializer.toJson<String>(areaSource),
      'transactionId': serializer.toJson<int>(transactionId),
    };
  }

  TempatData copyWith({
    int? id,
    double? lat,
    double? lng,
    String? countryCode,
    String? areaCode,
    String? areaSource,
    int? transactionId,
  }) => TempatData(
    id: id ?? this.id,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    countryCode: countryCode ?? this.countryCode,
    areaCode: areaCode ?? this.areaCode,
    areaSource: areaSource ?? this.areaSource,
    transactionId: transactionId ?? this.transactionId,
  );
  TempatData copyWithCompanion(TempatCompanion data) {
    return TempatData(
      id: data.id.present ? data.id.value : this.id,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      countryCode: data.countryCode.present
          ? data.countryCode.value
          : this.countryCode,
      areaCode: data.areaCode.present ? data.areaCode.value : this.areaCode,
      areaSource: data.areaSource.present
          ? data.areaSource.value
          : this.areaSource,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TempatData(')
          ..write('id: $id, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('countryCode: $countryCode, ')
          ..write('areaCode: $areaCode, ')
          ..write('areaSource: $areaSource, ')
          ..write('transactionId: $transactionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    lat,
    lng,
    countryCode,
    areaCode,
    areaSource,
    transactionId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TempatData &&
          other.id == this.id &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.countryCode == this.countryCode &&
          other.areaCode == this.areaCode &&
          other.areaSource == this.areaSource &&
          other.transactionId == this.transactionId);
}

class TempatCompanion extends UpdateCompanion<TempatData> {
  final Value<int> id;
  final Value<double> lat;
  final Value<double> lng;
  final Value<String> countryCode;
  final Value<String> areaCode;
  final Value<String> areaSource;
  final Value<int> transactionId;
  const TempatCompanion({
    this.id = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.countryCode = const Value.absent(),
    this.areaCode = const Value.absent(),
    this.areaSource = const Value.absent(),
    this.transactionId = const Value.absent(),
  });
  TempatCompanion.insert({
    this.id = const Value.absent(),
    required double lat,
    required double lng,
    required String countryCode,
    required String areaCode,
    required String areaSource,
    required int transactionId,
  }) : lat = Value(lat),
       lng = Value(lng),
       countryCode = Value(countryCode),
       areaCode = Value(areaCode),
       areaSource = Value(areaSource),
       transactionId = Value(transactionId);
  static Insertable<TempatData> custom({
    Expression<int>? id,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<String>? countryCode,
    Expression<String>? areaCode,
    Expression<String>? areaSource,
    Expression<int>? transactionId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (countryCode != null) 'country_code': countryCode,
      if (areaCode != null) 'area_code': areaCode,
      if (areaSource != null) 'area_source': areaSource,
      if (transactionId != null) 'transaction_id': transactionId,
    });
  }

  TempatCompanion copyWith({
    Value<int>? id,
    Value<double>? lat,
    Value<double>? lng,
    Value<String>? countryCode,
    Value<String>? areaCode,
    Value<String>? areaSource,
    Value<int>? transactionId,
  }) {
    return TempatCompanion(
      id: id ?? this.id,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      countryCode: countryCode ?? this.countryCode,
      areaCode: areaCode ?? this.areaCode,
      areaSource: areaSource ?? this.areaSource,
      transactionId: transactionId ?? this.transactionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (countryCode.present) {
      map['country_code'] = Variable<String>(countryCode.value);
    }
    if (areaCode.present) {
      map['area_code'] = Variable<String>(areaCode.value);
    }
    if (areaSource.present) {
      map['area_source'] = Variable<String>(areaSource.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<int>(transactionId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TempatCompanion(')
          ..write('id: $id, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('countryCode: $countryCode, ')
          ..write('areaCode: $areaCode, ')
          ..write('areaSource: $areaSource, ')
          ..write('transactionId: $transactionId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DompetTabelTable dompetTabel = $DompetTabelTable(this);
  late final $DompetMonthTable dompetMonth = $DompetMonthTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $TempatTable tempat = $TempatTable(this);
  late final TransactionDao transactionDao = TransactionDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    dompetTabel,
    dompetMonth,
    transactions,
    tempat,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'dompet_tabel',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('dompet_month', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'dompet_month',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transactions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'transactions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tempat', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$DompetTabelTableCreateCompanionBuilder =
    DompetTabelCompanion Function({
      Value<int> id,
      required String userid,
      required double amount,
      required double pengeluaran,
      required double pemasukkan,
    });
typedef $$DompetTabelTableUpdateCompanionBuilder =
    DompetTabelCompanion Function({
      Value<int> id,
      Value<String> userid,
      Value<double> amount,
      Value<double> pengeluaran,
      Value<double> pemasukkan,
    });

final class $$DompetTabelTableReferences
    extends BaseReferences<_$AppDatabase, $DompetTabelTable, DompetTabelData> {
  $$DompetTabelTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DompetMonthTable, List<DompetMonthData>>
  _dompetMonthRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dompetMonth,
    aliasName: $_aliasNameGenerator(db.dompetTabel.id, db.dompetMonth.dompetid),
  );

  $$DompetMonthTableProcessedTableManager get dompetMonthRefs {
    final manager = $$DompetMonthTableTableManager(
      $_db,
      $_db.dompetMonth,
    ).filter((f) => f.dompetid.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dompetMonthRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DompetTabelTableFilterComposer
    extends Composer<_$AppDatabase, $DompetTabelTable> {
  $$DompetTabelTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userid => $composableBuilder(
    column: $table.userid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pengeluaran => $composableBuilder(
    column: $table.pengeluaran,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pemasukkan => $composableBuilder(
    column: $table.pemasukkan,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> dompetMonthRefs(
    Expression<bool> Function($$DompetMonthTableFilterComposer f) f,
  ) {
    final $$DompetMonthTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dompetMonth,
      getReferencedColumn: (t) => t.dompetid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DompetMonthTableFilterComposer(
            $db: $db,
            $table: $db.dompetMonth,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DompetTabelTableOrderingComposer
    extends Composer<_$AppDatabase, $DompetTabelTable> {
  $$DompetTabelTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userid => $composableBuilder(
    column: $table.userid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pengeluaran => $composableBuilder(
    column: $table.pengeluaran,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pemasukkan => $composableBuilder(
    column: $table.pemasukkan,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DompetTabelTableAnnotationComposer
    extends Composer<_$AppDatabase, $DompetTabelTable> {
  $$DompetTabelTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userid =>
      $composableBuilder(column: $table.userid, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get pengeluaran => $composableBuilder(
    column: $table.pengeluaran,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pemasukkan => $composableBuilder(
    column: $table.pemasukkan,
    builder: (column) => column,
  );

  Expression<T> dompetMonthRefs<T extends Object>(
    Expression<T> Function($$DompetMonthTableAnnotationComposer a) f,
  ) {
    final $$DompetMonthTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dompetMonth,
      getReferencedColumn: (t) => t.dompetid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DompetMonthTableAnnotationComposer(
            $db: $db,
            $table: $db.dompetMonth,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DompetTabelTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DompetTabelTable,
          DompetTabelData,
          $$DompetTabelTableFilterComposer,
          $$DompetTabelTableOrderingComposer,
          $$DompetTabelTableAnnotationComposer,
          $$DompetTabelTableCreateCompanionBuilder,
          $$DompetTabelTableUpdateCompanionBuilder,
          (DompetTabelData, $$DompetTabelTableReferences),
          DompetTabelData,
          PrefetchHooks Function({bool dompetMonthRefs})
        > {
  $$DompetTabelTableTableManager(_$AppDatabase db, $DompetTabelTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DompetTabelTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DompetTabelTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DompetTabelTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userid = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<double> pengeluaran = const Value.absent(),
                Value<double> pemasukkan = const Value.absent(),
              }) => DompetTabelCompanion(
                id: id,
                userid: userid,
                amount: amount,
                pengeluaran: pengeluaran,
                pemasukkan: pemasukkan,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userid,
                required double amount,
                required double pengeluaran,
                required double pemasukkan,
              }) => DompetTabelCompanion.insert(
                id: id,
                userid: userid,
                amount: amount,
                pengeluaran: pengeluaran,
                pemasukkan: pemasukkan,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DompetTabelTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dompetMonthRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (dompetMonthRefs) db.dompetMonth],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dompetMonthRefs)
                    await $_getPrefetchedData<
                      DompetTabelData,
                      $DompetTabelTable,
                      DompetMonthData
                    >(
                      currentTable: table,
                      referencedTable: $$DompetTabelTableReferences
                          ._dompetMonthRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DompetTabelTableReferences(
                            db,
                            table,
                            p0,
                          ).dompetMonthRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.dompetid == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DompetTabelTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DompetTabelTable,
      DompetTabelData,
      $$DompetTabelTableFilterComposer,
      $$DompetTabelTableOrderingComposer,
      $$DompetTabelTableAnnotationComposer,
      $$DompetTabelTableCreateCompanionBuilder,
      $$DompetTabelTableUpdateCompanionBuilder,
      (DompetTabelData, $$DompetTabelTableReferences),
      DompetTabelData,
      PrefetchHooks Function({bool dompetMonthRefs})
    >;
typedef $$DompetMonthTableCreateCompanionBuilder =
    DompetMonthCompanion Function({
      Value<int> id,
      required double pemasukkan,
      required double pengeluaran,
      required int month,
      required int year,
      required int dompetid,
    });
typedef $$DompetMonthTableUpdateCompanionBuilder =
    DompetMonthCompanion Function({
      Value<int> id,
      Value<double> pemasukkan,
      Value<double> pengeluaran,
      Value<int> month,
      Value<int> year,
      Value<int> dompetid,
    });

final class $$DompetMonthTableReferences
    extends BaseReferences<_$AppDatabase, $DompetMonthTable, DompetMonthData> {
  $$DompetMonthTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DompetTabelTable _dompetidTable(_$AppDatabase db) =>
      db.dompetTabel.createAlias(
        $_aliasNameGenerator(db.dompetMonth.dompetid, db.dompetTabel.id),
      );

  $$DompetTabelTableProcessedTableManager get dompetid {
    final $_column = $_itemColumn<int>('dompetid')!;

    final manager = $$DompetTabelTableTableManager(
      $_db,
      $_db.dompetTabel,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dompetidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: $_aliasNameGenerator(
      db.dompetMonth.id,
      db.transactions.dompetmonthid,
    ),
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.dompetmonthid.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DompetMonthTableFilterComposer
    extends Composer<_$AppDatabase, $DompetMonthTable> {
  $$DompetMonthTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pemasukkan => $composableBuilder(
    column: $table.pemasukkan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pengeluaran => $composableBuilder(
    column: $table.pengeluaran,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  $$DompetTabelTableFilterComposer get dompetid {
    final $$DompetTabelTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dompetid,
      referencedTable: $db.dompetTabel,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DompetTabelTableFilterComposer(
            $db: $db,
            $table: $db.dompetTabel,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.dompetmonthid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DompetMonthTableOrderingComposer
    extends Composer<_$AppDatabase, $DompetMonthTable> {
  $$DompetMonthTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pemasukkan => $composableBuilder(
    column: $table.pemasukkan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pengeluaran => $composableBuilder(
    column: $table.pengeluaran,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  $$DompetTabelTableOrderingComposer get dompetid {
    final $$DompetTabelTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dompetid,
      referencedTable: $db.dompetTabel,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DompetTabelTableOrderingComposer(
            $db: $db,
            $table: $db.dompetTabel,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DompetMonthTableAnnotationComposer
    extends Composer<_$AppDatabase, $DompetMonthTable> {
  $$DompetMonthTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get pemasukkan => $composableBuilder(
    column: $table.pemasukkan,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pengeluaran => $composableBuilder(
    column: $table.pengeluaran,
    builder: (column) => column,
  );

  GeneratedColumn<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  $$DompetTabelTableAnnotationComposer get dompetid {
    final $$DompetTabelTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dompetid,
      referencedTable: $db.dompetTabel,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DompetTabelTableAnnotationComposer(
            $db: $db,
            $table: $db.dompetTabel,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.dompetmonthid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DompetMonthTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DompetMonthTable,
          DompetMonthData,
          $$DompetMonthTableFilterComposer,
          $$DompetMonthTableOrderingComposer,
          $$DompetMonthTableAnnotationComposer,
          $$DompetMonthTableCreateCompanionBuilder,
          $$DompetMonthTableUpdateCompanionBuilder,
          (DompetMonthData, $$DompetMonthTableReferences),
          DompetMonthData,
          PrefetchHooks Function({bool dompetid, bool transactionsRefs})
        > {
  $$DompetMonthTableTableManager(_$AppDatabase db, $DompetMonthTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DompetMonthTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DompetMonthTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DompetMonthTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> pemasukkan = const Value.absent(),
                Value<double> pengeluaran = const Value.absent(),
                Value<int> month = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<int> dompetid = const Value.absent(),
              }) => DompetMonthCompanion(
                id: id,
                pemasukkan: pemasukkan,
                pengeluaran: pengeluaran,
                month: month,
                year: year,
                dompetid: dompetid,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required double pemasukkan,
                required double pengeluaran,
                required int month,
                required int year,
                required int dompetid,
              }) => DompetMonthCompanion.insert(
                id: id,
                pemasukkan: pemasukkan,
                pengeluaran: pengeluaran,
                month: month,
                year: year,
                dompetid: dompetid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DompetMonthTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({dompetid = false, transactionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionsRefs) db.transactions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (dompetid) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.dompetid,
                                    referencedTable:
                                        $$DompetMonthTableReferences
                                            ._dompetidTable(db),
                                    referencedColumn:
                                        $$DompetMonthTableReferences
                                            ._dompetidTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          DompetMonthData,
                          $DompetMonthTable,
                          Transaction
                        >(
                          currentTable: table,
                          referencedTable: $$DompetMonthTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DompetMonthTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.dompetmonthid == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DompetMonthTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DompetMonthTable,
      DompetMonthData,
      $$DompetMonthTableFilterComposer,
      $$DompetMonthTableOrderingComposer,
      $$DompetMonthTableAnnotationComposer,
      $$DompetMonthTableCreateCompanionBuilder,
      $$DompetMonthTableUpdateCompanionBuilder,
      (DompetMonthData, $$DompetMonthTableReferences),
      DompetMonthData,
      PrefetchHooks Function({bool dompetid, bool transactionsRefs})
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      required double amount,
      required DateTime tanggal,
      required bool isUpload,
      required TypeTransaction type,
      Value<String?> receiptImagePath,
      Value<String?> voiceNotePath,
      required int dompetmonthid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<double> amount,
      Value<DateTime> tanggal,
      Value<bool> isUpload,
      Value<TypeTransaction> type,
      Value<String?> receiptImagePath,
      Value<String?> voiceNotePath,
      Value<int> dompetmonthid,
    });

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, Transaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DompetMonthTable _dompetmonthidTable(_$AppDatabase db) =>
      db.dompetMonth.createAlias(
        $_aliasNameGenerator(db.transactions.dompetmonthid, db.dompetMonth.id),
      );

  $$DompetMonthTableProcessedTableManager get dompetmonthid {
    final $_column = $_itemColumn<int>('dompetmonthid')!;

    final manager = $$DompetMonthTableTableManager(
      $_db,
      $_db.dompetMonth,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dompetmonthidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TempatTable, List<TempatData>> _tempatRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tempat,
    aliasName: $_aliasNameGenerator(
      db.transactions.id,
      db.tempat.transactionId,
    ),
  );

  $$TempatTableProcessedTableManager get tempatRefs {
    final manager = $$TempatTableTableManager(
      $_db,
      $_db.tempat,
    ).filter((f) => f.transactionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tempatRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tanggal => $composableBuilder(
    column: $table.tanggal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUpload => $composableBuilder(
    column: $table.isUpload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TypeTransaction, TypeTransaction, int>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get receiptImagePath => $composableBuilder(
    column: $table.receiptImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voiceNotePath => $composableBuilder(
    column: $table.voiceNotePath,
    builder: (column) => ColumnFilters(column),
  );

  $$DompetMonthTableFilterComposer get dompetmonthid {
    final $$DompetMonthTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dompetmonthid,
      referencedTable: $db.dompetMonth,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DompetMonthTableFilterComposer(
            $db: $db,
            $table: $db.dompetMonth,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tempatRefs(
    Expression<bool> Function($$TempatTableFilterComposer f) f,
  ) {
    final $$TempatTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tempat,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TempatTableFilterComposer(
            $db: $db,
            $table: $db.tempat,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tanggal => $composableBuilder(
    column: $table.tanggal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUpload => $composableBuilder(
    column: $table.isUpload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptImagePath => $composableBuilder(
    column: $table.receiptImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voiceNotePath => $composableBuilder(
    column: $table.voiceNotePath,
    builder: (column) => ColumnOrderings(column),
  );

  $$DompetMonthTableOrderingComposer get dompetmonthid {
    final $$DompetMonthTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dompetmonthid,
      referencedTable: $db.dompetMonth,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DompetMonthTableOrderingComposer(
            $db: $db,
            $table: $db.dompetMonth,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get tanggal =>
      $composableBuilder(column: $table.tanggal, builder: (column) => column);

  GeneratedColumn<bool> get isUpload =>
      $composableBuilder(column: $table.isUpload, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TypeTransaction, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get receiptImagePath => $composableBuilder(
    column: $table.receiptImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get voiceNotePath => $composableBuilder(
    column: $table.voiceNotePath,
    builder: (column) => column,
  );

  $$DompetMonthTableAnnotationComposer get dompetmonthid {
    final $$DompetMonthTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dompetmonthid,
      referencedTable: $db.dompetMonth,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DompetMonthTableAnnotationComposer(
            $db: $db,
            $table: $db.dompetMonth,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> tempatRefs<T extends Object>(
    Expression<T> Function($$TempatTableAnnotationComposer a) f,
  ) {
    final $$TempatTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tempat,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TempatTableAnnotationComposer(
            $db: $db,
            $table: $db.tempat,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (Transaction, $$TransactionsTableReferences),
          Transaction,
          PrefetchHooks Function({bool dompetmonthid, bool tempatRefs})
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> tanggal = const Value.absent(),
                Value<bool> isUpload = const Value.absent(),
                Value<TypeTransaction> type = const Value.absent(),
                Value<String?> receiptImagePath = const Value.absent(),
                Value<String?> voiceNotePath = const Value.absent(),
                Value<int> dompetmonthid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                amount: amount,
                tanggal: tanggal,
                isUpload: isUpload,
                type: type,
                receiptImagePath: receiptImagePath,
                voiceNotePath: voiceNotePath,
                dompetmonthid: dompetmonthid,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required double amount,
                required DateTime tanggal,
                required bool isUpload,
                required TypeTransaction type,
                Value<String?> receiptImagePath = const Value.absent(),
                Value<String?> voiceNotePath = const Value.absent(),
                required int dompetmonthid,
              }) => TransactionsCompanion.insert(
                id: id,
                amount: amount,
                tanggal: tanggal,
                isUpload: isUpload,
                type: type,
                receiptImagePath: receiptImagePath,
                voiceNotePath: voiceNotePath,
                dompetmonthid: dompetmonthid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dompetmonthid = false, tempatRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tempatRefs) db.tempat],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (dompetmonthid) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.dompetmonthid,
                                referencedTable: $$TransactionsTableReferences
                                    ._dompetmonthidTable(db),
                                referencedColumn: $$TransactionsTableReferences
                                    ._dompetmonthidTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tempatRefs)
                    await $_getPrefetchedData<
                      Transaction,
                      $TransactionsTable,
                      TempatData
                    >(
                      currentTable: table,
                      referencedTable: $$TransactionsTableReferences
                          ._tempatRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TransactionsTableReferences(
                            db,
                            table,
                            p0,
                          ).tempatRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.transactionId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (Transaction, $$TransactionsTableReferences),
      Transaction,
      PrefetchHooks Function({bool dompetmonthid, bool tempatRefs})
    >;
typedef $$TempatTableCreateCompanionBuilder =
    TempatCompanion Function({
      Value<int> id,
      required double lat,
      required double lng,
      required String countryCode,
      required String areaCode,
      required String areaSource,
      required int transactionId,
    });
typedef $$TempatTableUpdateCompanionBuilder =
    TempatCompanion Function({
      Value<int> id,
      Value<double> lat,
      Value<double> lng,
      Value<String> countryCode,
      Value<String> areaCode,
      Value<String> areaSource,
      Value<int> transactionId,
    });

final class $$TempatTableReferences
    extends BaseReferences<_$AppDatabase, $TempatTable, TempatData> {
  $$TempatTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias(
        $_aliasNameGenerator(db.tempat.transactionId, db.transactions.id),
      );

  $$TransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<int>('transaction_id')!;

    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TempatTableFilterComposer
    extends Composer<_$AppDatabase, $TempatTable> {
  $$TempatTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get areaCode => $composableBuilder(
    column: $table.areaCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get areaSource => $composableBuilder(
    column: $table.areaSource,
    builder: (column) => ColumnFilters(column),
  );

  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TempatTableOrderingComposer
    extends Composer<_$AppDatabase, $TempatTable> {
  $$TempatTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get areaCode => $composableBuilder(
    column: $table.areaCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get areaSource => $composableBuilder(
    column: $table.areaSource,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TempatTableAnnotationComposer
    extends Composer<_$AppDatabase, $TempatTable> {
  $$TempatTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get areaCode =>
      $composableBuilder(column: $table.areaCode, builder: (column) => column);

  GeneratedColumn<String> get areaSource => $composableBuilder(
    column: $table.areaSource,
    builder: (column) => column,
  );

  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TempatTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TempatTable,
          TempatData,
          $$TempatTableFilterComposer,
          $$TempatTableOrderingComposer,
          $$TempatTableAnnotationComposer,
          $$TempatTableCreateCompanionBuilder,
          $$TempatTableUpdateCompanionBuilder,
          (TempatData, $$TempatTableReferences),
          TempatData,
          PrefetchHooks Function({bool transactionId})
        > {
  $$TempatTableTableManager(_$AppDatabase db, $TempatTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TempatTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TempatTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TempatTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lng = const Value.absent(),
                Value<String> countryCode = const Value.absent(),
                Value<String> areaCode = const Value.absent(),
                Value<String> areaSource = const Value.absent(),
                Value<int> transactionId = const Value.absent(),
              }) => TempatCompanion(
                id: id,
                lat: lat,
                lng: lng,
                countryCode: countryCode,
                areaCode: areaCode,
                areaSource: areaSource,
                transactionId: transactionId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required double lat,
                required double lng,
                required String countryCode,
                required String areaCode,
                required String areaSource,
                required int transactionId,
              }) => TempatCompanion.insert(
                id: id,
                lat: lat,
                lng: lng,
                countryCode: countryCode,
                areaCode: areaCode,
                areaSource: areaSource,
                transactionId: transactionId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TempatTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({transactionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (transactionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.transactionId,
                                referencedTable: $$TempatTableReferences
                                    ._transactionIdTable(db),
                                referencedColumn: $$TempatTableReferences
                                    ._transactionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TempatTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TempatTable,
      TempatData,
      $$TempatTableFilterComposer,
      $$TempatTableOrderingComposer,
      $$TempatTableAnnotationComposer,
      $$TempatTableCreateCompanionBuilder,
      $$TempatTableUpdateCompanionBuilder,
      (TempatData, $$TempatTableReferences),
      TempatData,
      PrefetchHooks Function({bool transactionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DompetTabelTableTableManager get dompetTabel =>
      $$DompetTabelTableTableManager(_db, _db.dompetTabel);
  $$DompetMonthTableTableManager get dompetMonth =>
      $$DompetMonthTableTableManager(_db, _db.dompetMonth);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$TempatTableTableManager get tempat =>
      $$TempatTableTableManager(_db, _db.tempat);
}
