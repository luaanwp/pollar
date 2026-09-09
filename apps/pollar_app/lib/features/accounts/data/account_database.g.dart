// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_database.dart';

// ignore_for_file: type=lint
class $AccountEntriesTable extends AccountEntries
    with TableInfo<$AccountEntriesTable, StoredAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyDecimalDigitsMeta =
      const VerificationMeta('currencyDecimalDigits');
  @override
  late final GeneratedColumn<int> currencyDecimalDigits = GeneratedColumn<int>(
    'currency_decimal_digits',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencySymbolMeta = const VerificationMeta(
    'currencySymbol',
  );
  @override
  late final GeneratedColumn<String> currencySymbol = GeneratedColumn<String>(
    'currency_symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openingBalanceMinorMeta =
      const VerificationMeta('openingBalanceMinor');
  @override
  late final GeneratedColumn<int> openingBalanceMinor = GeneratedColumn<int>(
    'opening_balance_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creditLimitMinorMeta = const VerificationMeta(
    'creditLimitMinor',
  );
  @override
  late final GeneratedColumn<int> creditLimitMinor = GeneratedColumn<int>(
    'credit_limit_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closingDayMeta = const VerificationMeta(
    'closingDay',
  );
  @override
  late final GeneratedColumn<int> closingDay = GeneratedColumn<int>(
    'closing_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueDayMeta = const VerificationMeta('dueDay');
  @override
  late final GeneratedColumn<int> dueDay = GeneratedColumn<int>(
    'due_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    currencyCode,
    currencyDecimalDigits,
    currencySymbol,
    openingBalanceMinor,
    status,
    creditLimitMinor,
    closingDay,
    dueDay,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredAccount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('currency_decimal_digits')) {
      context.handle(
        _currencyDecimalDigitsMeta,
        currencyDecimalDigits.isAcceptableOrUnknown(
          data['currency_decimal_digits']!,
          _currencyDecimalDigitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyDecimalDigitsMeta);
    }
    if (data.containsKey('currency_symbol')) {
      context.handle(
        _currencySymbolMeta,
        currencySymbol.isAcceptableOrUnknown(
          data['currency_symbol']!,
          _currencySymbolMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencySymbolMeta);
    }
    if (data.containsKey('opening_balance_minor')) {
      context.handle(
        _openingBalanceMinorMeta,
        openingBalanceMinor.isAcceptableOrUnknown(
          data['opening_balance_minor']!,
          _openingBalanceMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_openingBalanceMinorMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('credit_limit_minor')) {
      context.handle(
        _creditLimitMinorMeta,
        creditLimitMinor.isAcceptableOrUnknown(
          data['credit_limit_minor']!,
          _creditLimitMinorMeta,
        ),
      );
    }
    if (data.containsKey('closing_day')) {
      context.handle(
        _closingDayMeta,
        closingDay.isAcceptableOrUnknown(data['closing_day']!, _closingDayMeta),
      );
    }
    if (data.containsKey('due_day')) {
      context.handle(
        _dueDayMeta,
        dueDay.isAcceptableOrUnknown(data['due_day']!, _dueDayMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoredAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredAccount(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      currencyDecimalDigits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}currency_decimal_digits'],
      )!,
      currencySymbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_symbol'],
      )!,
      openingBalanceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opening_balance_minor'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      creditLimitMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credit_limit_minor'],
      ),
      closingDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}closing_day'],
      ),
      dueDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_day'],
      ),
    );
  }

  @override
  $AccountEntriesTable createAlias(String alias) {
    return $AccountEntriesTable(attachedDatabase, alias);
  }
}

class StoredAccount extends DataClass implements Insertable<StoredAccount> {
  final String id;
  final String name;
  final String type;
  final String currencyCode;
  final int currencyDecimalDigits;
  final String currencySymbol;
  final int openingBalanceMinor;
  final String status;
  final int? creditLimitMinor;
  final int? closingDay;
  final int? dueDay;
  const StoredAccount({
    required this.id,
    required this.name,
    required this.type,
    required this.currencyCode,
    required this.currencyDecimalDigits,
    required this.currencySymbol,
    required this.openingBalanceMinor,
    required this.status,
    this.creditLimitMinor,
    this.closingDay,
    this.dueDay,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['currency_code'] = Variable<String>(currencyCode);
    map['currency_decimal_digits'] = Variable<int>(currencyDecimalDigits);
    map['currency_symbol'] = Variable<String>(currencySymbol);
    map['opening_balance_minor'] = Variable<int>(openingBalanceMinor);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || creditLimitMinor != null) {
      map['credit_limit_minor'] = Variable<int>(creditLimitMinor);
    }
    if (!nullToAbsent || closingDay != null) {
      map['closing_day'] = Variable<int>(closingDay);
    }
    if (!nullToAbsent || dueDay != null) {
      map['due_day'] = Variable<int>(dueDay);
    }
    return map;
  }

  AccountEntriesCompanion toCompanion(bool nullToAbsent) {
    return AccountEntriesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      currencyCode: Value(currencyCode),
      currencyDecimalDigits: Value(currencyDecimalDigits),
      currencySymbol: Value(currencySymbol),
      openingBalanceMinor: Value(openingBalanceMinor),
      status: Value(status),
      creditLimitMinor: creditLimitMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(creditLimitMinor),
      closingDay: closingDay == null && nullToAbsent
          ? const Value.absent()
          : Value(closingDay),
      dueDay: dueDay == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDay),
    );
  }

  factory StoredAccount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredAccount(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      currencyDecimalDigits: serializer.fromJson<int>(
        json['currencyDecimalDigits'],
      ),
      currencySymbol: serializer.fromJson<String>(json['currencySymbol']),
      openingBalanceMinor: serializer.fromJson<int>(
        json['openingBalanceMinor'],
      ),
      status: serializer.fromJson<String>(json['status']),
      creditLimitMinor: serializer.fromJson<int?>(json['creditLimitMinor']),
      closingDay: serializer.fromJson<int?>(json['closingDay']),
      dueDay: serializer.fromJson<int?>(json['dueDay']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'currencyDecimalDigits': serializer.toJson<int>(currencyDecimalDigits),
      'currencySymbol': serializer.toJson<String>(currencySymbol),
      'openingBalanceMinor': serializer.toJson<int>(openingBalanceMinor),
      'status': serializer.toJson<String>(status),
      'creditLimitMinor': serializer.toJson<int?>(creditLimitMinor),
      'closingDay': serializer.toJson<int?>(closingDay),
      'dueDay': serializer.toJson<int?>(dueDay),
    };
  }

  StoredAccount copyWith({
    String? id,
    String? name,
    String? type,
    String? currencyCode,
    int? currencyDecimalDigits,
    String? currencySymbol,
    int? openingBalanceMinor,
    String? status,
    Value<int?> creditLimitMinor = const Value.absent(),
    Value<int?> closingDay = const Value.absent(),
    Value<int?> dueDay = const Value.absent(),
  }) => StoredAccount(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    currencyCode: currencyCode ?? this.currencyCode,
    currencyDecimalDigits: currencyDecimalDigits ?? this.currencyDecimalDigits,
    currencySymbol: currencySymbol ?? this.currencySymbol,
    openingBalanceMinor: openingBalanceMinor ?? this.openingBalanceMinor,
    status: status ?? this.status,
    creditLimitMinor: creditLimitMinor.present
        ? creditLimitMinor.value
        : this.creditLimitMinor,
    closingDay: closingDay.present ? closingDay.value : this.closingDay,
    dueDay: dueDay.present ? dueDay.value : this.dueDay,
  );
  StoredAccount copyWithCompanion(AccountEntriesCompanion data) {
    return StoredAccount(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      currencyDecimalDigits: data.currencyDecimalDigits.present
          ? data.currencyDecimalDigits.value
          : this.currencyDecimalDigits,
      currencySymbol: data.currencySymbol.present
          ? data.currencySymbol.value
          : this.currencySymbol,
      openingBalanceMinor: data.openingBalanceMinor.present
          ? data.openingBalanceMinor.value
          : this.openingBalanceMinor,
      status: data.status.present ? data.status.value : this.status,
      creditLimitMinor: data.creditLimitMinor.present
          ? data.creditLimitMinor.value
          : this.creditLimitMinor,
      closingDay: data.closingDay.present
          ? data.closingDay.value
          : this.closingDay,
      dueDay: data.dueDay.present ? data.dueDay.value : this.dueDay,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredAccount(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('currencyDecimalDigits: $currencyDecimalDigits, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('openingBalanceMinor: $openingBalanceMinor, ')
          ..write('status: $status, ')
          ..write('creditLimitMinor: $creditLimitMinor, ')
          ..write('closingDay: $closingDay, ')
          ..write('dueDay: $dueDay')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    currencyCode,
    currencyDecimalDigits,
    currencySymbol,
    openingBalanceMinor,
    status,
    creditLimitMinor,
    closingDay,
    dueDay,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredAccount &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.currencyCode == this.currencyCode &&
          other.currencyDecimalDigits == this.currencyDecimalDigits &&
          other.currencySymbol == this.currencySymbol &&
          other.openingBalanceMinor == this.openingBalanceMinor &&
          other.status == this.status &&
          other.creditLimitMinor == this.creditLimitMinor &&
          other.closingDay == this.closingDay &&
          other.dueDay == this.dueDay);
}

class AccountEntriesCompanion extends UpdateCompanion<StoredAccount> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String> currencyCode;
  final Value<int> currencyDecimalDigits;
  final Value<String> currencySymbol;
  final Value<int> openingBalanceMinor;
  final Value<String> status;
  final Value<int?> creditLimitMinor;
  final Value<int?> closingDay;
  final Value<int?> dueDay;
  final Value<int> rowid;
  const AccountEntriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.currencyDecimalDigits = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.openingBalanceMinor = const Value.absent(),
    this.status = const Value.absent(),
    this.creditLimitMinor = const Value.absent(),
    this.closingDay = const Value.absent(),
    this.dueDay = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountEntriesCompanion.insert({
    required String id,
    required String name,
    required String type,
    required String currencyCode,
    required int currencyDecimalDigits,
    required String currencySymbol,
    required int openingBalanceMinor,
    required String status,
    this.creditLimitMinor = const Value.absent(),
    this.closingDay = const Value.absent(),
    this.dueDay = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       currencyCode = Value(currencyCode),
       currencyDecimalDigits = Value(currencyDecimalDigits),
       currencySymbol = Value(currencySymbol),
       openingBalanceMinor = Value(openingBalanceMinor),
       status = Value(status);
  static Insertable<StoredAccount> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? currencyCode,
    Expression<int>? currencyDecimalDigits,
    Expression<String>? currencySymbol,
    Expression<int>? openingBalanceMinor,
    Expression<String>? status,
    Expression<int>? creditLimitMinor,
    Expression<int>? closingDay,
    Expression<int>? dueDay,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (currencyDecimalDigits != null)
        'currency_decimal_digits': currencyDecimalDigits,
      if (currencySymbol != null) 'currency_symbol': currencySymbol,
      if (openingBalanceMinor != null)
        'opening_balance_minor': openingBalanceMinor,
      if (status != null) 'status': status,
      if (creditLimitMinor != null) 'credit_limit_minor': creditLimitMinor,
      if (closingDay != null) 'closing_day': closingDay,
      if (dueDay != null) 'due_day': dueDay,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<String>? currencyCode,
    Value<int>? currencyDecimalDigits,
    Value<String>? currencySymbol,
    Value<int>? openingBalanceMinor,
    Value<String>? status,
    Value<int?>? creditLimitMinor,
    Value<int?>? closingDay,
    Value<int?>? dueDay,
    Value<int>? rowid,
  }) {
    return AccountEntriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      currencyCode: currencyCode ?? this.currencyCode,
      currencyDecimalDigits:
          currencyDecimalDigits ?? this.currencyDecimalDigits,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      openingBalanceMinor: openingBalanceMinor ?? this.openingBalanceMinor,
      status: status ?? this.status,
      creditLimitMinor: creditLimitMinor ?? this.creditLimitMinor,
      closingDay: closingDay ?? this.closingDay,
      dueDay: dueDay ?? this.dueDay,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (currencyDecimalDigits.present) {
      map['currency_decimal_digits'] = Variable<int>(
        currencyDecimalDigits.value,
      );
    }
    if (currencySymbol.present) {
      map['currency_symbol'] = Variable<String>(currencySymbol.value);
    }
    if (openingBalanceMinor.present) {
      map['opening_balance_minor'] = Variable<int>(openingBalanceMinor.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (creditLimitMinor.present) {
      map['credit_limit_minor'] = Variable<int>(creditLimitMinor.value);
    }
    if (closingDay.present) {
      map['closing_day'] = Variable<int>(closingDay.value);
    }
    if (dueDay.present) {
      map['due_day'] = Variable<int>(dueDay.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountEntriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('currencyDecimalDigits: $currencyDecimalDigits, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('openingBalanceMinor: $openingBalanceMinor, ')
          ..write('status: $status, ')
          ..write('creditLimitMinor: $creditLimitMinor, ')
          ..write('closingDay: $closingDay, ')
          ..write('dueDay: $dueDay, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AccountDatabase extends GeneratedDatabase {
  _$AccountDatabase(QueryExecutor e) : super(e);
  $AccountDatabaseManager get managers => $AccountDatabaseManager(this);
  late final $AccountEntriesTable accountEntries = $AccountEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [accountEntries];
}

typedef $$AccountEntriesTableCreateCompanionBuilder =
    AccountEntriesCompanion Function({
      required String id,
      required String name,
      required String type,
      required String currencyCode,
      required int currencyDecimalDigits,
      required String currencySymbol,
      required int openingBalanceMinor,
      required String status,
      Value<int?> creditLimitMinor,
      Value<int?> closingDay,
      Value<int?> dueDay,
      Value<int> rowid,
    });
typedef $$AccountEntriesTableUpdateCompanionBuilder =
    AccountEntriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> type,
      Value<String> currencyCode,
      Value<int> currencyDecimalDigits,
      Value<String> currencySymbol,
      Value<int> openingBalanceMinor,
      Value<String> status,
      Value<int?> creditLimitMinor,
      Value<int?> closingDay,
      Value<int?> dueDay,
      Value<int> rowid,
    });

class $$AccountEntriesTableFilterComposer
    extends Composer<_$AccountDatabase, $AccountEntriesTable> {
  $$AccountEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currencyDecimalDigits => $composableBuilder(
    column: $table.currencyDecimalDigits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencySymbol => $composableBuilder(
    column: $table.currencySymbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openingBalanceMinor => $composableBuilder(
    column: $table.openingBalanceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creditLimitMinor => $composableBuilder(
    column: $table.creditLimitMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get closingDay => $composableBuilder(
    column: $table.closingDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueDay => $composableBuilder(
    column: $table.dueDay,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AccountEntriesTableOrderingComposer
    extends Composer<_$AccountDatabase, $AccountEntriesTable> {
  $$AccountEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currencyDecimalDigits => $composableBuilder(
    column: $table.currencyDecimalDigits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencySymbol => $composableBuilder(
    column: $table.currencySymbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openingBalanceMinor => $composableBuilder(
    column: $table.openingBalanceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creditLimitMinor => $composableBuilder(
    column: $table.creditLimitMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get closingDay => $composableBuilder(
    column: $table.closingDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueDay => $composableBuilder(
    column: $table.dueDay,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountEntriesTableAnnotationComposer
    extends Composer<_$AccountDatabase, $AccountEntriesTable> {
  $$AccountEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currencyDecimalDigits => $composableBuilder(
    column: $table.currencyDecimalDigits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencySymbol => $composableBuilder(
    column: $table.currencySymbol,
    builder: (column) => column,
  );

  GeneratedColumn<int> get openingBalanceMinor => $composableBuilder(
    column: $table.openingBalanceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get creditLimitMinor => $composableBuilder(
    column: $table.creditLimitMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get closingDay => $composableBuilder(
    column: $table.closingDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dueDay =>
      $composableBuilder(column: $table.dueDay, builder: (column) => column);
}

class $$AccountEntriesTableTableManager
    extends
        RootTableManager<
          _$AccountDatabase,
          $AccountEntriesTable,
          StoredAccount,
          $$AccountEntriesTableFilterComposer,
          $$AccountEntriesTableOrderingComposer,
          $$AccountEntriesTableAnnotationComposer,
          $$AccountEntriesTableCreateCompanionBuilder,
          $$AccountEntriesTableUpdateCompanionBuilder,
          (
            StoredAccount,
            BaseReferences<
              _$AccountDatabase,
              $AccountEntriesTable,
              StoredAccount
            >,
          ),
          StoredAccount,
          PrefetchHooks Function()
        > {
  $$AccountEntriesTableTableManager(
    _$AccountDatabase db,
    $AccountEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<int> currencyDecimalDigits = const Value.absent(),
                Value<String> currencySymbol = const Value.absent(),
                Value<int> openingBalanceMinor = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> creditLimitMinor = const Value.absent(),
                Value<int?> closingDay = const Value.absent(),
                Value<int?> dueDay = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountEntriesCompanion(
                id: id,
                name: name,
                type: type,
                currencyCode: currencyCode,
                currencyDecimalDigits: currencyDecimalDigits,
                currencySymbol: currencySymbol,
                openingBalanceMinor: openingBalanceMinor,
                status: status,
                creditLimitMinor: creditLimitMinor,
                closingDay: closingDay,
                dueDay: dueDay,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String type,
                required String currencyCode,
                required int currencyDecimalDigits,
                required String currencySymbol,
                required int openingBalanceMinor,
                required String status,
                Value<int?> creditLimitMinor = const Value.absent(),
                Value<int?> closingDay = const Value.absent(),
                Value<int?> dueDay = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountEntriesCompanion.insert(
                id: id,
                name: name,
                type: type,
                currencyCode: currencyCode,
                currencyDecimalDigits: currencyDecimalDigits,
                currencySymbol: currencySymbol,
                openingBalanceMinor: openingBalanceMinor,
                status: status,
                creditLimitMinor: creditLimitMinor,
                closingDay: closingDay,
                dueDay: dueDay,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AccountEntriesTable, StoredAccount>(table),
                  BaseReferences<
                    _$AccountDatabase,
                    $AccountEntriesTable,
                    StoredAccount
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccountEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AccountDatabase,
      $AccountEntriesTable,
      StoredAccount,
      $$AccountEntriesTableFilterComposer,
      $$AccountEntriesTableOrderingComposer,
      $$AccountEntriesTableAnnotationComposer,
      $$AccountEntriesTableCreateCompanionBuilder,
      $$AccountEntriesTableUpdateCompanionBuilder,
      (
        StoredAccount,
        BaseReferences<_$AccountDatabase, $AccountEntriesTable, StoredAccount>,
      ),
      StoredAccount,
      PrefetchHooks Function()
    >;

class $AccountDatabaseManager {
  final _$AccountDatabase _db;
  $AccountDatabaseManager(this._db);
  $$AccountEntriesTableTableManager get accountEntries =>
      $$AccountEntriesTableTableManager(_db, _db.accountEntries);
}
