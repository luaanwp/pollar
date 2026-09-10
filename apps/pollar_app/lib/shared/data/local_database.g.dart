// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

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

class $TransactionEntriesTable extends TransactionEntries
    with TableInfo<$TransactionEntriesTable, StoredTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
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
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES account_entries (id)',
    ),
  );
  static const VerificationMeta _counterAccountIdMeta = const VerificationMeta(
    'counterAccountId',
  );
  @override
  late final GeneratedColumn<String> counterAccountId = GeneratedColumn<String>(
    'counter_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES account_entries (id)',
    ),
  );
  static const VerificationMeta _occurredAtMicrosMeta = const VerificationMeta(
    'occurredAtMicros',
  );
  @override
  late final GeneratedColumn<int> occurredAtMicros = GeneratedColumn<int>(
    'occurred_at_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _installmentGroupIdMeta =
      const VerificationMeta('installmentGroupId');
  @override
  late final GeneratedColumn<String> installmentGroupId =
      GeneratedColumn<String>(
        'installment_group_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _installmentNumberMeta = const VerificationMeta(
    'installmentNumber',
  );
  @override
  late final GeneratedColumn<int> installmentNumber = GeneratedColumn<int>(
    'installment_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _installmentCountMeta = const VerificationMeta(
    'installmentCount',
  );
  @override
  late final GeneratedColumn<int> installmentCount = GeneratedColumn<int>(
    'installment_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purchaseTotalMinorMeta =
      const VerificationMeta('purchaseTotalMinor');
  @override
  late final GeneratedColumn<int> purchaseTotalMinor = GeneratedColumn<int>(
    'purchase_total_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statementIdMeta = const VerificationMeta(
    'statementId',
  );
  @override
  late final GeneratedColumn<String> statementId = GeneratedColumn<String>(
    'statement_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    description,
    type,
    status,
    amountMinor,
    currencyCode,
    currencyDecimalDigits,
    currencySymbol,
    accountId,
    counterAccountId,
    occurredAtMicros,
    category,
    note,
    installmentGroupId,
    installmentNumber,
    installmentCount,
    purchaseTotalMinor,
    statementId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
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
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('counter_account_id')) {
      context.handle(
        _counterAccountIdMeta,
        counterAccountId.isAcceptableOrUnknown(
          data['counter_account_id']!,
          _counterAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('occurred_at_micros')) {
      context.handle(
        _occurredAtMicrosMeta,
        occurredAtMicros.isAcceptableOrUnknown(
          data['occurred_at_micros']!,
          _occurredAtMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMicrosMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('installment_group_id')) {
      context.handle(
        _installmentGroupIdMeta,
        installmentGroupId.isAcceptableOrUnknown(
          data['installment_group_id']!,
          _installmentGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('installment_number')) {
      context.handle(
        _installmentNumberMeta,
        installmentNumber.isAcceptableOrUnknown(
          data['installment_number']!,
          _installmentNumberMeta,
        ),
      );
    }
    if (data.containsKey('installment_count')) {
      context.handle(
        _installmentCountMeta,
        installmentCount.isAcceptableOrUnknown(
          data['installment_count']!,
          _installmentCountMeta,
        ),
      );
    }
    if (data.containsKey('purchase_total_minor')) {
      context.handle(
        _purchaseTotalMinorMeta,
        purchaseTotalMinor.isAcceptableOrUnknown(
          data['purchase_total_minor']!,
          _purchaseTotalMinorMeta,
        ),
      );
    }
    if (data.containsKey('statement_id')) {
      context.handle(
        _statementIdMeta,
        statementId.isAcceptableOrUnknown(
          data['statement_id']!,
          _statementIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoredTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
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
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      counterAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}counter_account_id'],
      ),
      occurredAtMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at_micros'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      installmentGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}installment_group_id'],
      ),
      installmentNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}installment_number'],
      ),
      installmentCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}installment_count'],
      ),
      purchaseTotalMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}purchase_total_minor'],
      ),
      statementId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}statement_id'],
      ),
    );
  }

  @override
  $TransactionEntriesTable createAlias(String alias) {
    return $TransactionEntriesTable(attachedDatabase, alias);
  }
}

class StoredTransaction extends DataClass
    implements Insertable<StoredTransaction> {
  final String id;
  final String description;
  final String type;
  final String status;
  final int amountMinor;
  final String currencyCode;
  final int currencyDecimalDigits;
  final String currencySymbol;
  final String accountId;
  final String? counterAccountId;
  final int occurredAtMicros;
  final String? category;
  final String? note;
  final String? installmentGroupId;
  final int? installmentNumber;
  final int? installmentCount;
  final int? purchaseTotalMinor;
  final String? statementId;
  const StoredTransaction({
    required this.id,
    required this.description,
    required this.type,
    required this.status,
    required this.amountMinor,
    required this.currencyCode,
    required this.currencyDecimalDigits,
    required this.currencySymbol,
    required this.accountId,
    this.counterAccountId,
    required this.occurredAtMicros,
    this.category,
    this.note,
    this.installmentGroupId,
    this.installmentNumber,
    this.installmentCount,
    this.purchaseTotalMinor,
    this.statementId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['description'] = Variable<String>(description);
    map['type'] = Variable<String>(type);
    map['status'] = Variable<String>(status);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    map['currency_decimal_digits'] = Variable<int>(currencyDecimalDigits);
    map['currency_symbol'] = Variable<String>(currencySymbol);
    map['account_id'] = Variable<String>(accountId);
    if (!nullToAbsent || counterAccountId != null) {
      map['counter_account_id'] = Variable<String>(counterAccountId);
    }
    map['occurred_at_micros'] = Variable<int>(occurredAtMicros);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || installmentGroupId != null) {
      map['installment_group_id'] = Variable<String>(installmentGroupId);
    }
    if (!nullToAbsent || installmentNumber != null) {
      map['installment_number'] = Variable<int>(installmentNumber);
    }
    if (!nullToAbsent || installmentCount != null) {
      map['installment_count'] = Variable<int>(installmentCount);
    }
    if (!nullToAbsent || purchaseTotalMinor != null) {
      map['purchase_total_minor'] = Variable<int>(purchaseTotalMinor);
    }
    if (!nullToAbsent || statementId != null) {
      map['statement_id'] = Variable<String>(statementId);
    }
    return map;
  }

  TransactionEntriesCompanion toCompanion(bool nullToAbsent) {
    return TransactionEntriesCompanion(
      id: Value(id),
      description: Value(description),
      type: Value(type),
      status: Value(status),
      amountMinor: Value(amountMinor),
      currencyCode: Value(currencyCode),
      currencyDecimalDigits: Value(currencyDecimalDigits),
      currencySymbol: Value(currencySymbol),
      accountId: Value(accountId),
      counterAccountId: counterAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(counterAccountId),
      occurredAtMicros: Value(occurredAtMicros),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      installmentGroupId: installmentGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(installmentGroupId),
      installmentNumber: installmentNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(installmentNumber),
      installmentCount: installmentCount == null && nullToAbsent
          ? const Value.absent()
          : Value(installmentCount),
      purchaseTotalMinor: purchaseTotalMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseTotalMinor),
      statementId: statementId == null && nullToAbsent
          ? const Value.absent()
          : Value(statementId),
    );
  }

  factory StoredTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredTransaction(
      id: serializer.fromJson<String>(json['id']),
      description: serializer.fromJson<String>(json['description']),
      type: serializer.fromJson<String>(json['type']),
      status: serializer.fromJson<String>(json['status']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      currencyDecimalDigits: serializer.fromJson<int>(
        json['currencyDecimalDigits'],
      ),
      currencySymbol: serializer.fromJson<String>(json['currencySymbol']),
      accountId: serializer.fromJson<String>(json['accountId']),
      counterAccountId: serializer.fromJson<String?>(json['counterAccountId']),
      occurredAtMicros: serializer.fromJson<int>(json['occurredAtMicros']),
      category: serializer.fromJson<String?>(json['category']),
      note: serializer.fromJson<String?>(json['note']),
      installmentGroupId: serializer.fromJson<String?>(
        json['installmentGroupId'],
      ),
      installmentNumber: serializer.fromJson<int?>(json['installmentNumber']),
      installmentCount: serializer.fromJson<int?>(json['installmentCount']),
      purchaseTotalMinor: serializer.fromJson<int?>(json['purchaseTotalMinor']),
      statementId: serializer.fromJson<String?>(json['statementId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'description': serializer.toJson<String>(description),
      'type': serializer.toJson<String>(type),
      'status': serializer.toJson<String>(status),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'currencyDecimalDigits': serializer.toJson<int>(currencyDecimalDigits),
      'currencySymbol': serializer.toJson<String>(currencySymbol),
      'accountId': serializer.toJson<String>(accountId),
      'counterAccountId': serializer.toJson<String?>(counterAccountId),
      'occurredAtMicros': serializer.toJson<int>(occurredAtMicros),
      'category': serializer.toJson<String?>(category),
      'note': serializer.toJson<String?>(note),
      'installmentGroupId': serializer.toJson<String?>(installmentGroupId),
      'installmentNumber': serializer.toJson<int?>(installmentNumber),
      'installmentCount': serializer.toJson<int?>(installmentCount),
      'purchaseTotalMinor': serializer.toJson<int?>(purchaseTotalMinor),
      'statementId': serializer.toJson<String?>(statementId),
    };
  }

  StoredTransaction copyWith({
    String? id,
    String? description,
    String? type,
    String? status,
    int? amountMinor,
    String? currencyCode,
    int? currencyDecimalDigits,
    String? currencySymbol,
    String? accountId,
    Value<String?> counterAccountId = const Value.absent(),
    int? occurredAtMicros,
    Value<String?> category = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<String?> installmentGroupId = const Value.absent(),
    Value<int?> installmentNumber = const Value.absent(),
    Value<int?> installmentCount = const Value.absent(),
    Value<int?> purchaseTotalMinor = const Value.absent(),
    Value<String?> statementId = const Value.absent(),
  }) => StoredTransaction(
    id: id ?? this.id,
    description: description ?? this.description,
    type: type ?? this.type,
    status: status ?? this.status,
    amountMinor: amountMinor ?? this.amountMinor,
    currencyCode: currencyCode ?? this.currencyCode,
    currencyDecimalDigits: currencyDecimalDigits ?? this.currencyDecimalDigits,
    currencySymbol: currencySymbol ?? this.currencySymbol,
    accountId: accountId ?? this.accountId,
    counterAccountId: counterAccountId.present
        ? counterAccountId.value
        : this.counterAccountId,
    occurredAtMicros: occurredAtMicros ?? this.occurredAtMicros,
    category: category.present ? category.value : this.category,
    note: note.present ? note.value : this.note,
    installmentGroupId: installmentGroupId.present
        ? installmentGroupId.value
        : this.installmentGroupId,
    installmentNumber: installmentNumber.present
        ? installmentNumber.value
        : this.installmentNumber,
    installmentCount: installmentCount.present
        ? installmentCount.value
        : this.installmentCount,
    purchaseTotalMinor: purchaseTotalMinor.present
        ? purchaseTotalMinor.value
        : this.purchaseTotalMinor,
    statementId: statementId.present ? statementId.value : this.statementId,
  );
  StoredTransaction copyWithCompanion(TransactionEntriesCompanion data) {
    return StoredTransaction(
      id: data.id.present ? data.id.value : this.id,
      description: data.description.present
          ? data.description.value
          : this.description,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      currencyDecimalDigits: data.currencyDecimalDigits.present
          ? data.currencyDecimalDigits.value
          : this.currencyDecimalDigits,
      currencySymbol: data.currencySymbol.present
          ? data.currencySymbol.value
          : this.currencySymbol,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      counterAccountId: data.counterAccountId.present
          ? data.counterAccountId.value
          : this.counterAccountId,
      occurredAtMicros: data.occurredAtMicros.present
          ? data.occurredAtMicros.value
          : this.occurredAtMicros,
      category: data.category.present ? data.category.value : this.category,
      note: data.note.present ? data.note.value : this.note,
      installmentGroupId: data.installmentGroupId.present
          ? data.installmentGroupId.value
          : this.installmentGroupId,
      installmentNumber: data.installmentNumber.present
          ? data.installmentNumber.value
          : this.installmentNumber,
      installmentCount: data.installmentCount.present
          ? data.installmentCount.value
          : this.installmentCount,
      purchaseTotalMinor: data.purchaseTotalMinor.present
          ? data.purchaseTotalMinor.value
          : this.purchaseTotalMinor,
      statementId: data.statementId.present
          ? data.statementId.value
          : this.statementId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredTransaction(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('currencyDecimalDigits: $currencyDecimalDigits, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('accountId: $accountId, ')
          ..write('counterAccountId: $counterAccountId, ')
          ..write('occurredAtMicros: $occurredAtMicros, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('installmentGroupId: $installmentGroupId, ')
          ..write('installmentNumber: $installmentNumber, ')
          ..write('installmentCount: $installmentCount, ')
          ..write('purchaseTotalMinor: $purchaseTotalMinor, ')
          ..write('statementId: $statementId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    description,
    type,
    status,
    amountMinor,
    currencyCode,
    currencyDecimalDigits,
    currencySymbol,
    accountId,
    counterAccountId,
    occurredAtMicros,
    category,
    note,
    installmentGroupId,
    installmentNumber,
    installmentCount,
    purchaseTotalMinor,
    statementId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredTransaction &&
          other.id == this.id &&
          other.description == this.description &&
          other.type == this.type &&
          other.status == this.status &&
          other.amountMinor == this.amountMinor &&
          other.currencyCode == this.currencyCode &&
          other.currencyDecimalDigits == this.currencyDecimalDigits &&
          other.currencySymbol == this.currencySymbol &&
          other.accountId == this.accountId &&
          other.counterAccountId == this.counterAccountId &&
          other.occurredAtMicros == this.occurredAtMicros &&
          other.category == this.category &&
          other.note == this.note &&
          other.installmentGroupId == this.installmentGroupId &&
          other.installmentNumber == this.installmentNumber &&
          other.installmentCount == this.installmentCount &&
          other.purchaseTotalMinor == this.purchaseTotalMinor &&
          other.statementId == this.statementId);
}

class TransactionEntriesCompanion extends UpdateCompanion<StoredTransaction> {
  final Value<String> id;
  final Value<String> description;
  final Value<String> type;
  final Value<String> status;
  final Value<int> amountMinor;
  final Value<String> currencyCode;
  final Value<int> currencyDecimalDigits;
  final Value<String> currencySymbol;
  final Value<String> accountId;
  final Value<String?> counterAccountId;
  final Value<int> occurredAtMicros;
  final Value<String?> category;
  final Value<String?> note;
  final Value<String?> installmentGroupId;
  final Value<int?> installmentNumber;
  final Value<int?> installmentCount;
  final Value<int?> purchaseTotalMinor;
  final Value<String?> statementId;
  final Value<int> rowid;
  const TransactionEntriesCompanion({
    this.id = const Value.absent(),
    this.description = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.currencyDecimalDigits = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.accountId = const Value.absent(),
    this.counterAccountId = const Value.absent(),
    this.occurredAtMicros = const Value.absent(),
    this.category = const Value.absent(),
    this.note = const Value.absent(),
    this.installmentGroupId = const Value.absent(),
    this.installmentNumber = const Value.absent(),
    this.installmentCount = const Value.absent(),
    this.purchaseTotalMinor = const Value.absent(),
    this.statementId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionEntriesCompanion.insert({
    required String id,
    required String description,
    required String type,
    required String status,
    required int amountMinor,
    required String currencyCode,
    required int currencyDecimalDigits,
    required String currencySymbol,
    required String accountId,
    this.counterAccountId = const Value.absent(),
    required int occurredAtMicros,
    this.category = const Value.absent(),
    this.note = const Value.absent(),
    this.installmentGroupId = const Value.absent(),
    this.installmentNumber = const Value.absent(),
    this.installmentCount = const Value.absent(),
    this.purchaseTotalMinor = const Value.absent(),
    this.statementId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       description = Value(description),
       type = Value(type),
       status = Value(status),
       amountMinor = Value(amountMinor),
       currencyCode = Value(currencyCode),
       currencyDecimalDigits = Value(currencyDecimalDigits),
       currencySymbol = Value(currencySymbol),
       accountId = Value(accountId),
       occurredAtMicros = Value(occurredAtMicros);
  static Insertable<StoredTransaction> custom({
    Expression<String>? id,
    Expression<String>? description,
    Expression<String>? type,
    Expression<String>? status,
    Expression<int>? amountMinor,
    Expression<String>? currencyCode,
    Expression<int>? currencyDecimalDigits,
    Expression<String>? currencySymbol,
    Expression<String>? accountId,
    Expression<String>? counterAccountId,
    Expression<int>? occurredAtMicros,
    Expression<String>? category,
    Expression<String>? note,
    Expression<String>? installmentGroupId,
    Expression<int>? installmentNumber,
    Expression<int>? installmentCount,
    Expression<int>? purchaseTotalMinor,
    Expression<String>? statementId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (currencyDecimalDigits != null)
        'currency_decimal_digits': currencyDecimalDigits,
      if (currencySymbol != null) 'currency_symbol': currencySymbol,
      if (accountId != null) 'account_id': accountId,
      if (counterAccountId != null) 'counter_account_id': counterAccountId,
      if (occurredAtMicros != null) 'occurred_at_micros': occurredAtMicros,
      if (category != null) 'category': category,
      if (note != null) 'note': note,
      if (installmentGroupId != null)
        'installment_group_id': installmentGroupId,
      if (installmentNumber != null) 'installment_number': installmentNumber,
      if (installmentCount != null) 'installment_count': installmentCount,
      if (purchaseTotalMinor != null)
        'purchase_total_minor': purchaseTotalMinor,
      if (statementId != null) 'statement_id': statementId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? description,
    Value<String>? type,
    Value<String>? status,
    Value<int>? amountMinor,
    Value<String>? currencyCode,
    Value<int>? currencyDecimalDigits,
    Value<String>? currencySymbol,
    Value<String>? accountId,
    Value<String?>? counterAccountId,
    Value<int>? occurredAtMicros,
    Value<String?>? category,
    Value<String?>? note,
    Value<String?>? installmentGroupId,
    Value<int?>? installmentNumber,
    Value<int?>? installmentCount,
    Value<int?>? purchaseTotalMinor,
    Value<String?>? statementId,
    Value<int>? rowid,
  }) {
    return TransactionEntriesCompanion(
      id: id ?? this.id,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      currencyDecimalDigits:
          currencyDecimalDigits ?? this.currencyDecimalDigits,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      accountId: accountId ?? this.accountId,
      counterAccountId: counterAccountId ?? this.counterAccountId,
      occurredAtMicros: occurredAtMicros ?? this.occurredAtMicros,
      category: category ?? this.category,
      note: note ?? this.note,
      installmentGroupId: installmentGroupId ?? this.installmentGroupId,
      installmentNumber: installmentNumber ?? this.installmentNumber,
      installmentCount: installmentCount ?? this.installmentCount,
      purchaseTotalMinor: purchaseTotalMinor ?? this.purchaseTotalMinor,
      statementId: statementId ?? this.statementId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
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
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (counterAccountId.present) {
      map['counter_account_id'] = Variable<String>(counterAccountId.value);
    }
    if (occurredAtMicros.present) {
      map['occurred_at_micros'] = Variable<int>(occurredAtMicros.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (installmentGroupId.present) {
      map['installment_group_id'] = Variable<String>(installmentGroupId.value);
    }
    if (installmentNumber.present) {
      map['installment_number'] = Variable<int>(installmentNumber.value);
    }
    if (installmentCount.present) {
      map['installment_count'] = Variable<int>(installmentCount.value);
    }
    if (purchaseTotalMinor.present) {
      map['purchase_total_minor'] = Variable<int>(purchaseTotalMinor.value);
    }
    if (statementId.present) {
      map['statement_id'] = Variable<String>(statementId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionEntriesCompanion(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('currencyDecimalDigits: $currencyDecimalDigits, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('accountId: $accountId, ')
          ..write('counterAccountId: $counterAccountId, ')
          ..write('occurredAtMicros: $occurredAtMicros, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('installmentGroupId: $installmentGroupId, ')
          ..write('installmentNumber: $installmentNumber, ')
          ..write('installmentCount: $installmentCount, ')
          ..write('purchaseTotalMinor: $purchaseTotalMinor, ')
          ..write('statementId: $statementId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetEntriesTable extends BudgetEntries
    with TableInfo<$BudgetEntriesTable, StoredBudget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthMicrosMeta = const VerificationMeta(
    'monthMicros',
  );
  @override
  late final GeneratedColumn<int> monthMicros = GeneratedColumn<int>(
    'month_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _limitMinorMeta = const VerificationMeta(
    'limitMinor',
  );
  @override
  late final GeneratedColumn<int> limitMinor = GeneratedColumn<int>(
    'limit_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _alertThresholdMeta = const VerificationMeta(
    'alertThreshold',
  );
  @override
  late final GeneratedColumn<int> alertThreshold = GeneratedColumn<int>(
    'alert_threshold',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(85),
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    category,
    monthMicros,
    limitMinor,
    currencyCode,
    currencyDecimalDigits,
    currencySymbol,
    alertThreshold,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredBudget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('month_micros')) {
      context.handle(
        _monthMicrosMeta,
        monthMicros.isAcceptableOrUnknown(
          data['month_micros']!,
          _monthMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_monthMicrosMeta);
    }
    if (data.containsKey('limit_minor')) {
      context.handle(
        _limitMinorMeta,
        limitMinor.isAcceptableOrUnknown(data['limit_minor']!, _limitMinorMeta),
      );
    } else if (isInserting) {
      context.missing(_limitMinorMeta);
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
    if (data.containsKey('alert_threshold')) {
      context.handle(
        _alertThresholdMeta,
        alertThreshold.isAcceptableOrUnknown(
          data['alert_threshold']!,
          _alertThresholdMeta,
        ),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoredBudget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredBudget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      monthMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month_micros'],
      )!,
      limitMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}limit_minor'],
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
      alertThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}alert_threshold'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $BudgetEntriesTable createAlias(String alias) {
    return $BudgetEntriesTable(attachedDatabase, alias);
  }
}

class StoredBudget extends DataClass implements Insertable<StoredBudget> {
  final String id;
  final String category;
  final int monthMicros;
  final int limitMinor;
  final String currencyCode;
  final int currencyDecimalDigits;
  final String currencySymbol;
  final int alertThreshold;
  final bool active;
  const StoredBudget({
    required this.id,
    required this.category,
    required this.monthMicros,
    required this.limitMinor,
    required this.currencyCode,
    required this.currencyDecimalDigits,
    required this.currencySymbol,
    required this.alertThreshold,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category'] = Variable<String>(category);
    map['month_micros'] = Variable<int>(monthMicros);
    map['limit_minor'] = Variable<int>(limitMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    map['currency_decimal_digits'] = Variable<int>(currencyDecimalDigits);
    map['currency_symbol'] = Variable<String>(currencySymbol);
    map['alert_threshold'] = Variable<int>(alertThreshold);
    map['active'] = Variable<bool>(active);
    return map;
  }

  BudgetEntriesCompanion toCompanion(bool nullToAbsent) {
    return BudgetEntriesCompanion(
      id: Value(id),
      category: Value(category),
      monthMicros: Value(monthMicros),
      limitMinor: Value(limitMinor),
      currencyCode: Value(currencyCode),
      currencyDecimalDigits: Value(currencyDecimalDigits),
      currencySymbol: Value(currencySymbol),
      alertThreshold: Value(alertThreshold),
      active: Value(active),
    );
  }

  factory StoredBudget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredBudget(
      id: serializer.fromJson<String>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      monthMicros: serializer.fromJson<int>(json['monthMicros']),
      limitMinor: serializer.fromJson<int>(json['limitMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      currencyDecimalDigits: serializer.fromJson<int>(
        json['currencyDecimalDigits'],
      ),
      currencySymbol: serializer.fromJson<String>(json['currencySymbol']),
      alertThreshold: serializer.fromJson<int>(json['alertThreshold']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'category': serializer.toJson<String>(category),
      'monthMicros': serializer.toJson<int>(monthMicros),
      'limitMinor': serializer.toJson<int>(limitMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'currencyDecimalDigits': serializer.toJson<int>(currencyDecimalDigits),
      'currencySymbol': serializer.toJson<String>(currencySymbol),
      'alertThreshold': serializer.toJson<int>(alertThreshold),
      'active': serializer.toJson<bool>(active),
    };
  }

  StoredBudget copyWith({
    String? id,
    String? category,
    int? monthMicros,
    int? limitMinor,
    String? currencyCode,
    int? currencyDecimalDigits,
    String? currencySymbol,
    int? alertThreshold,
    bool? active,
  }) => StoredBudget(
    id: id ?? this.id,
    category: category ?? this.category,
    monthMicros: monthMicros ?? this.monthMicros,
    limitMinor: limitMinor ?? this.limitMinor,
    currencyCode: currencyCode ?? this.currencyCode,
    currencyDecimalDigits: currencyDecimalDigits ?? this.currencyDecimalDigits,
    currencySymbol: currencySymbol ?? this.currencySymbol,
    alertThreshold: alertThreshold ?? this.alertThreshold,
    active: active ?? this.active,
  );
  StoredBudget copyWithCompanion(BudgetEntriesCompanion data) {
    return StoredBudget(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      monthMicros: data.monthMicros.present
          ? data.monthMicros.value
          : this.monthMicros,
      limitMinor: data.limitMinor.present
          ? data.limitMinor.value
          : this.limitMinor,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      currencyDecimalDigits: data.currencyDecimalDigits.present
          ? data.currencyDecimalDigits.value
          : this.currencyDecimalDigits,
      currencySymbol: data.currencySymbol.present
          ? data.currencySymbol.value
          : this.currencySymbol,
      alertThreshold: data.alertThreshold.present
          ? data.alertThreshold.value
          : this.alertThreshold,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredBudget(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('monthMicros: $monthMicros, ')
          ..write('limitMinor: $limitMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('currencyDecimalDigits: $currencyDecimalDigits, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('alertThreshold: $alertThreshold, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    category,
    monthMicros,
    limitMinor,
    currencyCode,
    currencyDecimalDigits,
    currencySymbol,
    alertThreshold,
    active,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredBudget &&
          other.id == this.id &&
          other.category == this.category &&
          other.monthMicros == this.monthMicros &&
          other.limitMinor == this.limitMinor &&
          other.currencyCode == this.currencyCode &&
          other.currencyDecimalDigits == this.currencyDecimalDigits &&
          other.currencySymbol == this.currencySymbol &&
          other.alertThreshold == this.alertThreshold &&
          other.active == this.active);
}

class BudgetEntriesCompanion extends UpdateCompanion<StoredBudget> {
  final Value<String> id;
  final Value<String> category;
  final Value<int> monthMicros;
  final Value<int> limitMinor;
  final Value<String> currencyCode;
  final Value<int> currencyDecimalDigits;
  final Value<String> currencySymbol;
  final Value<int> alertThreshold;
  final Value<bool> active;
  final Value<int> rowid;
  const BudgetEntriesCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.monthMicros = const Value.absent(),
    this.limitMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.currencyDecimalDigits = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.alertThreshold = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetEntriesCompanion.insert({
    required String id,
    required String category,
    required int monthMicros,
    required int limitMinor,
    required String currencyCode,
    required int currencyDecimalDigits,
    required String currencySymbol,
    this.alertThreshold = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       category = Value(category),
       monthMicros = Value(monthMicros),
       limitMinor = Value(limitMinor),
       currencyCode = Value(currencyCode),
       currencyDecimalDigits = Value(currencyDecimalDigits),
       currencySymbol = Value(currencySymbol);
  static Insertable<StoredBudget> custom({
    Expression<String>? id,
    Expression<String>? category,
    Expression<int>? monthMicros,
    Expression<int>? limitMinor,
    Expression<String>? currencyCode,
    Expression<int>? currencyDecimalDigits,
    Expression<String>? currencySymbol,
    Expression<int>? alertThreshold,
    Expression<bool>? active,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (monthMicros != null) 'month_micros': monthMicros,
      if (limitMinor != null) 'limit_minor': limitMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (currencyDecimalDigits != null)
        'currency_decimal_digits': currencyDecimalDigits,
      if (currencySymbol != null) 'currency_symbol': currencySymbol,
      if (alertThreshold != null) 'alert_threshold': alertThreshold,
      if (active != null) 'active': active,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? category,
    Value<int>? monthMicros,
    Value<int>? limitMinor,
    Value<String>? currencyCode,
    Value<int>? currencyDecimalDigits,
    Value<String>? currencySymbol,
    Value<int>? alertThreshold,
    Value<bool>? active,
    Value<int>? rowid,
  }) {
    return BudgetEntriesCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      monthMicros: monthMicros ?? this.monthMicros,
      limitMinor: limitMinor ?? this.limitMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      currencyDecimalDigits:
          currencyDecimalDigits ?? this.currencyDecimalDigits,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      active: active ?? this.active,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (monthMicros.present) {
      map['month_micros'] = Variable<int>(monthMicros.value);
    }
    if (limitMinor.present) {
      map['limit_minor'] = Variable<int>(limitMinor.value);
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
    if (alertThreshold.present) {
      map['alert_threshold'] = Variable<int>(alertThreshold.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetEntriesCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('monthMicros: $monthMicros, ')
          ..write('limitMinor: $limitMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('currencyDecimalDigits: $currencyDecimalDigits, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('alertThreshold: $alertThreshold, ')
          ..write('active: $active, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringRuleEntriesTable extends RecurringRuleEntries
    with TableInfo<$RecurringRuleEntriesTable, StoredRecurringRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringRuleEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES account_entries (id)',
    ),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstDueAtMicrosMeta = const VerificationMeta(
    'firstDueAtMicros',
  );
  @override
  late final GeneratedColumn<int> firstDueAtMicros = GeneratedColumn<int>(
    'first_due_at_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remindDaysBeforeMeta = const VerificationMeta(
    'remindDaysBefore',
  );
  @override
  late final GeneratedColumn<int> remindDaysBefore = GeneratedColumn<int>(
    'remind_days_before',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    description,
    kind,
    frequency,
    amountMinor,
    currencyCode,
    currencyDecimalDigits,
    currencySymbol,
    accountId,
    category,
    firstDueAtMicros,
    remindDaysBefore,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_rule_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredRecurringRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
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
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('first_due_at_micros')) {
      context.handle(
        _firstDueAtMicrosMeta,
        firstDueAtMicros.isAcceptableOrUnknown(
          data['first_due_at_micros']!,
          _firstDueAtMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstDueAtMicrosMeta);
    }
    if (data.containsKey('remind_days_before')) {
      context.handle(
        _remindDaysBeforeMeta,
        remindDaysBefore.isAcceptableOrUnknown(
          data['remind_days_before']!,
          _remindDaysBeforeMeta,
        ),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoredRecurringRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredRecurringRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
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
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      firstDueAtMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_due_at_micros'],
      )!,
      remindDaysBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remind_days_before'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $RecurringRuleEntriesTable createAlias(String alias) {
    return $RecurringRuleEntriesTable(attachedDatabase, alias);
  }
}

class StoredRecurringRule extends DataClass
    implements Insertable<StoredRecurringRule> {
  final String id;
  final String description;
  final String kind;
  final String frequency;
  final int amountMinor;
  final String currencyCode;
  final int currencyDecimalDigits;
  final String currencySymbol;
  final String accountId;
  final String? category;
  final int firstDueAtMicros;
  final int remindDaysBefore;
  final bool active;
  const StoredRecurringRule({
    required this.id,
    required this.description,
    required this.kind,
    required this.frequency,
    required this.amountMinor,
    required this.currencyCode,
    required this.currencyDecimalDigits,
    required this.currencySymbol,
    required this.accountId,
    this.category,
    required this.firstDueAtMicros,
    required this.remindDaysBefore,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['description'] = Variable<String>(description);
    map['kind'] = Variable<String>(kind);
    map['frequency'] = Variable<String>(frequency);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    map['currency_decimal_digits'] = Variable<int>(currencyDecimalDigits);
    map['currency_symbol'] = Variable<String>(currencySymbol);
    map['account_id'] = Variable<String>(accountId);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['first_due_at_micros'] = Variable<int>(firstDueAtMicros);
    map['remind_days_before'] = Variable<int>(remindDaysBefore);
    map['active'] = Variable<bool>(active);
    return map;
  }

  RecurringRuleEntriesCompanion toCompanion(bool nullToAbsent) {
    return RecurringRuleEntriesCompanion(
      id: Value(id),
      description: Value(description),
      kind: Value(kind),
      frequency: Value(frequency),
      amountMinor: Value(amountMinor),
      currencyCode: Value(currencyCode),
      currencyDecimalDigits: Value(currencyDecimalDigits),
      currencySymbol: Value(currencySymbol),
      accountId: Value(accountId),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      firstDueAtMicros: Value(firstDueAtMicros),
      remindDaysBefore: Value(remindDaysBefore),
      active: Value(active),
    );
  }

  factory StoredRecurringRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredRecurringRule(
      id: serializer.fromJson<String>(json['id']),
      description: serializer.fromJson<String>(json['description']),
      kind: serializer.fromJson<String>(json['kind']),
      frequency: serializer.fromJson<String>(json['frequency']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      currencyDecimalDigits: serializer.fromJson<int>(
        json['currencyDecimalDigits'],
      ),
      currencySymbol: serializer.fromJson<String>(json['currencySymbol']),
      accountId: serializer.fromJson<String>(json['accountId']),
      category: serializer.fromJson<String?>(json['category']),
      firstDueAtMicros: serializer.fromJson<int>(json['firstDueAtMicros']),
      remindDaysBefore: serializer.fromJson<int>(json['remindDaysBefore']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'description': serializer.toJson<String>(description),
      'kind': serializer.toJson<String>(kind),
      'frequency': serializer.toJson<String>(frequency),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'currencyDecimalDigits': serializer.toJson<int>(currencyDecimalDigits),
      'currencySymbol': serializer.toJson<String>(currencySymbol),
      'accountId': serializer.toJson<String>(accountId),
      'category': serializer.toJson<String?>(category),
      'firstDueAtMicros': serializer.toJson<int>(firstDueAtMicros),
      'remindDaysBefore': serializer.toJson<int>(remindDaysBefore),
      'active': serializer.toJson<bool>(active),
    };
  }

  StoredRecurringRule copyWith({
    String? id,
    String? description,
    String? kind,
    String? frequency,
    int? amountMinor,
    String? currencyCode,
    int? currencyDecimalDigits,
    String? currencySymbol,
    String? accountId,
    Value<String?> category = const Value.absent(),
    int? firstDueAtMicros,
    int? remindDaysBefore,
    bool? active,
  }) => StoredRecurringRule(
    id: id ?? this.id,
    description: description ?? this.description,
    kind: kind ?? this.kind,
    frequency: frequency ?? this.frequency,
    amountMinor: amountMinor ?? this.amountMinor,
    currencyCode: currencyCode ?? this.currencyCode,
    currencyDecimalDigits: currencyDecimalDigits ?? this.currencyDecimalDigits,
    currencySymbol: currencySymbol ?? this.currencySymbol,
    accountId: accountId ?? this.accountId,
    category: category.present ? category.value : this.category,
    firstDueAtMicros: firstDueAtMicros ?? this.firstDueAtMicros,
    remindDaysBefore: remindDaysBefore ?? this.remindDaysBefore,
    active: active ?? this.active,
  );
  StoredRecurringRule copyWithCompanion(RecurringRuleEntriesCompanion data) {
    return StoredRecurringRule(
      id: data.id.present ? data.id.value : this.id,
      description: data.description.present
          ? data.description.value
          : this.description,
      kind: data.kind.present ? data.kind.value : this.kind,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      currencyDecimalDigits: data.currencyDecimalDigits.present
          ? data.currencyDecimalDigits.value
          : this.currencyDecimalDigits,
      currencySymbol: data.currencySymbol.present
          ? data.currencySymbol.value
          : this.currencySymbol,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      category: data.category.present ? data.category.value : this.category,
      firstDueAtMicros: data.firstDueAtMicros.present
          ? data.firstDueAtMicros.value
          : this.firstDueAtMicros,
      remindDaysBefore: data.remindDaysBefore.present
          ? data.remindDaysBefore.value
          : this.remindDaysBefore,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredRecurringRule(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('kind: $kind, ')
          ..write('frequency: $frequency, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('currencyDecimalDigits: $currencyDecimalDigits, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('accountId: $accountId, ')
          ..write('category: $category, ')
          ..write('firstDueAtMicros: $firstDueAtMicros, ')
          ..write('remindDaysBefore: $remindDaysBefore, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    description,
    kind,
    frequency,
    amountMinor,
    currencyCode,
    currencyDecimalDigits,
    currencySymbol,
    accountId,
    category,
    firstDueAtMicros,
    remindDaysBefore,
    active,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredRecurringRule &&
          other.id == this.id &&
          other.description == this.description &&
          other.kind == this.kind &&
          other.frequency == this.frequency &&
          other.amountMinor == this.amountMinor &&
          other.currencyCode == this.currencyCode &&
          other.currencyDecimalDigits == this.currencyDecimalDigits &&
          other.currencySymbol == this.currencySymbol &&
          other.accountId == this.accountId &&
          other.category == this.category &&
          other.firstDueAtMicros == this.firstDueAtMicros &&
          other.remindDaysBefore == this.remindDaysBefore &&
          other.active == this.active);
}

class RecurringRuleEntriesCompanion
    extends UpdateCompanion<StoredRecurringRule> {
  final Value<String> id;
  final Value<String> description;
  final Value<String> kind;
  final Value<String> frequency;
  final Value<int> amountMinor;
  final Value<String> currencyCode;
  final Value<int> currencyDecimalDigits;
  final Value<String> currencySymbol;
  final Value<String> accountId;
  final Value<String?> category;
  final Value<int> firstDueAtMicros;
  final Value<int> remindDaysBefore;
  final Value<bool> active;
  final Value<int> rowid;
  const RecurringRuleEntriesCompanion({
    this.id = const Value.absent(),
    this.description = const Value.absent(),
    this.kind = const Value.absent(),
    this.frequency = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.currencyDecimalDigits = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.accountId = const Value.absent(),
    this.category = const Value.absent(),
    this.firstDueAtMicros = const Value.absent(),
    this.remindDaysBefore = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringRuleEntriesCompanion.insert({
    required String id,
    required String description,
    required String kind,
    required String frequency,
    required int amountMinor,
    required String currencyCode,
    required int currencyDecimalDigits,
    required String currencySymbol,
    required String accountId,
    this.category = const Value.absent(),
    required int firstDueAtMicros,
    this.remindDaysBefore = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       description = Value(description),
       kind = Value(kind),
       frequency = Value(frequency),
       amountMinor = Value(amountMinor),
       currencyCode = Value(currencyCode),
       currencyDecimalDigits = Value(currencyDecimalDigits),
       currencySymbol = Value(currencySymbol),
       accountId = Value(accountId),
       firstDueAtMicros = Value(firstDueAtMicros);
  static Insertable<StoredRecurringRule> custom({
    Expression<String>? id,
    Expression<String>? description,
    Expression<String>? kind,
    Expression<String>? frequency,
    Expression<int>? amountMinor,
    Expression<String>? currencyCode,
    Expression<int>? currencyDecimalDigits,
    Expression<String>? currencySymbol,
    Expression<String>? accountId,
    Expression<String>? category,
    Expression<int>? firstDueAtMicros,
    Expression<int>? remindDaysBefore,
    Expression<bool>? active,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (description != null) 'description': description,
      if (kind != null) 'kind': kind,
      if (frequency != null) 'frequency': frequency,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (currencyDecimalDigits != null)
        'currency_decimal_digits': currencyDecimalDigits,
      if (currencySymbol != null) 'currency_symbol': currencySymbol,
      if (accountId != null) 'account_id': accountId,
      if (category != null) 'category': category,
      if (firstDueAtMicros != null) 'first_due_at_micros': firstDueAtMicros,
      if (remindDaysBefore != null) 'remind_days_before': remindDaysBefore,
      if (active != null) 'active': active,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringRuleEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? description,
    Value<String>? kind,
    Value<String>? frequency,
    Value<int>? amountMinor,
    Value<String>? currencyCode,
    Value<int>? currencyDecimalDigits,
    Value<String>? currencySymbol,
    Value<String>? accountId,
    Value<String?>? category,
    Value<int>? firstDueAtMicros,
    Value<int>? remindDaysBefore,
    Value<bool>? active,
    Value<int>? rowid,
  }) {
    return RecurringRuleEntriesCompanion(
      id: id ?? this.id,
      description: description ?? this.description,
      kind: kind ?? this.kind,
      frequency: frequency ?? this.frequency,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      currencyDecimalDigits:
          currencyDecimalDigits ?? this.currencyDecimalDigits,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      accountId: accountId ?? this.accountId,
      category: category ?? this.category,
      firstDueAtMicros: firstDueAtMicros ?? this.firstDueAtMicros,
      remindDaysBefore: remindDaysBefore ?? this.remindDaysBefore,
      active: active ?? this.active,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
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
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (firstDueAtMicros.present) {
      map['first_due_at_micros'] = Variable<int>(firstDueAtMicros.value);
    }
    if (remindDaysBefore.present) {
      map['remind_days_before'] = Variable<int>(remindDaysBefore.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRuleEntriesCompanion(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('kind: $kind, ')
          ..write('frequency: $frequency, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('currencyDecimalDigits: $currencyDecimalDigits, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('accountId: $accountId, ')
          ..write('category: $category, ')
          ..write('firstDueAtMicros: $firstDueAtMicros, ')
          ..write('remindDaysBefore: $remindDaysBefore, ')
          ..write('active: $active, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $AccountEntriesTable accountEntries = $AccountEntriesTable(this);
  late final $TransactionEntriesTable transactionEntries =
      $TransactionEntriesTable(this);
  late final $BudgetEntriesTable budgetEntries = $BudgetEntriesTable(this);
  late final $RecurringRuleEntriesTable recurringRuleEntries =
      $RecurringRuleEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accountEntries,
    transactionEntries,
    budgetEntries,
    recurringRuleEntries,
  ];
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

final class $$AccountEntriesTableReferences
    extends
        BaseReferences<_$LocalDatabase, $AccountEntriesTable, StoredAccount> {
  $$AccountEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TransactionEntriesTable, List<StoredTransaction>>
  _sourceTransactionsTable(_$LocalDatabase db) => MultiTypedResultKey.fromTable(
    db.transactionEntries,
    aliasName: 'account_entries__id__transaction_entries__account_id',
  );

  $$TransactionEntriesTableProcessedTableManager get sourceTransactions {
    final manager = $$TransactionEntriesTableTableManager(
      $_db,
      $_db.transactionEntries,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sourceTransactionsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransactionEntriesTable, List<StoredTransaction>>
  _counterTransactionsTable(_$LocalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transactionEntries,
        aliasName:
            'account_entries__id__transaction_entries__counter_account_id',
      );

  $$TransactionEntriesTableProcessedTableManager get counterTransactions {
    final manager =
        $$TransactionEntriesTableTableManager(
          $_db,
          $_db.transactionEntries,
        ).filter(
          (f) => f.counterAccountId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _counterTransactionsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $RecurringRuleEntriesTable,
    List<StoredRecurringRule>
  >
  _recurringRuleEntriesRefsTable(_$LocalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recurringRuleEntries,
        aliasName: 'account_entries__id__recurring_rule_entries__account_id',
      );

  $$RecurringRuleEntriesTableProcessedTableManager
  get recurringRuleEntriesRefs {
    final manager = $$RecurringRuleEntriesTableTableManager(
      $_db,
      $_db.recurringRuleEntries,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recurringRuleEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AccountEntriesTableFilterComposer
    extends Composer<_$LocalDatabase, $AccountEntriesTable> {
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

  Expression<bool> sourceTransactions(
    Expression<bool> Function($$TransactionEntriesTableFilterComposer f) f,
  ) {
    final $$TransactionEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionEntries,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionEntriesTableFilterComposer(
            $db: $db,
            $table: $db.transactionEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> counterTransactions(
    Expression<bool> Function($$TransactionEntriesTableFilterComposer f) f,
  ) {
    final $$TransactionEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionEntries,
      getReferencedColumn: (t) => t.counterAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionEntriesTableFilterComposer(
            $db: $db,
            $table: $db.transactionEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recurringRuleEntriesRefs(
    Expression<bool> Function($$RecurringRuleEntriesTableFilterComposer f) f,
  ) {
    final $$RecurringRuleEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recurringRuleEntries,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringRuleEntriesTableFilterComposer(
            $db: $db,
            $table: $db.recurringRuleEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountEntriesTableOrderingComposer
    extends Composer<_$LocalDatabase, $AccountEntriesTable> {
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
    extends Composer<_$LocalDatabase, $AccountEntriesTable> {
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

  Expression<T> sourceTransactions<T extends Object>(
    Expression<T> Function($$TransactionEntriesTableAnnotationComposer a) f,
  ) {
    final $$TransactionEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transactionEntries,
          getReferencedColumn: (t) => t.accountId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.transactionEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> counterTransactions<T extends Object>(
    Expression<T> Function($$TransactionEntriesTableAnnotationComposer a) f,
  ) {
    final $$TransactionEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transactionEntries,
          getReferencedColumn: (t) => t.counterAccountId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.transactionEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> recurringRuleEntriesRefs<T extends Object>(
    Expression<T> Function($$RecurringRuleEntriesTableAnnotationComposer a) f,
  ) {
    final $$RecurringRuleEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringRuleEntries,
          getReferencedColumn: (t) => t.accountId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringRuleEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringRuleEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AccountEntriesTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $AccountEntriesTable,
          StoredAccount,
          $$AccountEntriesTableFilterComposer,
          $$AccountEntriesTableOrderingComposer,
          $$AccountEntriesTableAnnotationComposer,
          $$AccountEntriesTableCreateCompanionBuilder,
          $$AccountEntriesTableUpdateCompanionBuilder,
          (StoredAccount, $$AccountEntriesTableReferences),
          StoredAccount,
          PrefetchHooks Function({
            bool sourceTransactions,
            bool counterTransactions,
            bool recurringRuleEntriesRefs,
          })
        > {
  $$AccountEntriesTableTableManager(
    _$LocalDatabase db,
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
                  $$AccountEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sourceTransactions = false,
                counterTransactions = false,
                recurringRuleEntriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sourceTransactions) db.transactionEntries,
                    if (counterTransactions) db.transactionEntries,
                    if (recurringRuleEntriesRefs) db.recurringRuleEntries,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sourceTransactions)
                        await $_getPrefetchedData<
                          StoredAccount,
                          $AccountEntriesTable,
                          StoredTransaction
                        >(
                          currentTable: table,
                          referencedTable: $$AccountEntriesTableReferences
                              ._sourceTransactionsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).sourceTransactions,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (counterTransactions)
                        await $_getPrefetchedData<
                          StoredAccount,
                          $AccountEntriesTable,
                          StoredTransaction
                        >(
                          currentTable: table,
                          referencedTable: $$AccountEntriesTableReferences
                              ._counterTransactionsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).counterTransactions,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.counterAccountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recurringRuleEntriesRefs)
                        await $_getPrefetchedData<
                          StoredAccount,
                          $AccountEntriesTable,
                          StoredRecurringRule
                        >(
                          currentTable: table,
                          referencedTable: $$AccountEntriesTableReferences
                              ._recurringRuleEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).recurringRuleEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
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

typedef $$AccountEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $AccountEntriesTable,
      StoredAccount,
      $$AccountEntriesTableFilterComposer,
      $$AccountEntriesTableOrderingComposer,
      $$AccountEntriesTableAnnotationComposer,
      $$AccountEntriesTableCreateCompanionBuilder,
      $$AccountEntriesTableUpdateCompanionBuilder,
      (StoredAccount, $$AccountEntriesTableReferences),
      StoredAccount,
      PrefetchHooks Function({
        bool sourceTransactions,
        bool counterTransactions,
        bool recurringRuleEntriesRefs,
      })
    >;
typedef $$TransactionEntriesTableCreateCompanionBuilder =
    TransactionEntriesCompanion Function({
      required String id,
      required String description,
      required String type,
      required String status,
      required int amountMinor,
      required String currencyCode,
      required int currencyDecimalDigits,
      required String currencySymbol,
      required String accountId,
      Value<String?> counterAccountId,
      required int occurredAtMicros,
      Value<String?> category,
      Value<String?> note,
      Value<String?> installmentGroupId,
      Value<int?> installmentNumber,
      Value<int?> installmentCount,
      Value<int?> purchaseTotalMinor,
      Value<String?> statementId,
      Value<int> rowid,
    });
typedef $$TransactionEntriesTableUpdateCompanionBuilder =
    TransactionEntriesCompanion Function({
      Value<String> id,
      Value<String> description,
      Value<String> type,
      Value<String> status,
      Value<int> amountMinor,
      Value<String> currencyCode,
      Value<int> currencyDecimalDigits,
      Value<String> currencySymbol,
      Value<String> accountId,
      Value<String?> counterAccountId,
      Value<int> occurredAtMicros,
      Value<String?> category,
      Value<String?> note,
      Value<String?> installmentGroupId,
      Value<int?> installmentNumber,
      Value<int?> installmentCount,
      Value<int?> purchaseTotalMinor,
      Value<String?> statementId,
      Value<int> rowid,
    });

final class $$TransactionEntriesTableReferences
    extends
        BaseReferences<
          _$LocalDatabase,
          $TransactionEntriesTable,
          StoredTransaction
        > {
  $$TransactionEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AccountEntriesTable _accountIdTable(_$LocalDatabase db) => db
      .accountEntries
      .createAlias('transaction_entries__account_id__account_entries__id');

  $$AccountEntriesTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountEntriesTableTableManager(
      $_db,
      $_db.accountEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountEntriesTable _counterAccountIdTable(_$LocalDatabase db) =>
      db.accountEntries.createAlias(
        'transaction_entries__counter_account_id__account_entries__id',
      );

  $$AccountEntriesTableProcessedTableManager? get counterAccountId {
    final $_column = $_itemColumn<String>('counter_account_id');
    if ($_column == null) return null;
    final manager = $$AccountEntriesTableTableManager(
      $_db,
      $_db.accountEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_counterAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionEntriesTableFilterComposer
    extends Composer<_$LocalDatabase, $TransactionEntriesTable> {
  $$TransactionEntriesTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
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

  ColumnFilters<int> get occurredAtMicros => $composableBuilder(
    column: $table.occurredAtMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get installmentGroupId => $composableBuilder(
    column: $table.installmentGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get installmentCount => $composableBuilder(
    column: $table.installmentCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get purchaseTotalMinor => $composableBuilder(
    column: $table.purchaseTotalMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statementId => $composableBuilder(
    column: $table.statementId,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountEntriesTableFilterComposer get accountId {
    final $$AccountEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accountEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountEntriesTableFilterComposer(
            $db: $db,
            $table: $db.accountEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountEntriesTableFilterComposer get counterAccountId {
    final $$AccountEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.counterAccountId,
      referencedTable: $db.accountEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountEntriesTableFilterComposer(
            $db: $db,
            $table: $db.accountEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionEntriesTableOrderingComposer
    extends Composer<_$LocalDatabase, $TransactionEntriesTable> {
  $$TransactionEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
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

  ColumnOrderings<int> get occurredAtMicros => $composableBuilder(
    column: $table.occurredAtMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get installmentGroupId => $composableBuilder(
    column: $table.installmentGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get installmentCount => $composableBuilder(
    column: $table.installmentCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get purchaseTotalMinor => $composableBuilder(
    column: $table.purchaseTotalMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statementId => $composableBuilder(
    column: $table.statementId,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountEntriesTableOrderingComposer get accountId {
    final $$AccountEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accountEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.accountEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountEntriesTableOrderingComposer get counterAccountId {
    final $$AccountEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.counterAccountId,
      referencedTable: $db.accountEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.accountEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionEntriesTableAnnotationComposer
    extends Composer<_$LocalDatabase, $TransactionEntriesTable> {
  $$TransactionEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

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

  GeneratedColumn<int> get occurredAtMicros => $composableBuilder(
    column: $table.occurredAtMicros,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get installmentGroupId => $composableBuilder(
    column: $table.installmentGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get installmentCount => $composableBuilder(
    column: $table.installmentCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get purchaseTotalMinor => $composableBuilder(
    column: $table.purchaseTotalMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get statementId => $composableBuilder(
    column: $table.statementId,
    builder: (column) => column,
  );

  $$AccountEntriesTableAnnotationComposer get accountId {
    final $$AccountEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accountEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.accountEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountEntriesTableAnnotationComposer get counterAccountId {
    final $$AccountEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.counterAccountId,
      referencedTable: $db.accountEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.accountEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionEntriesTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $TransactionEntriesTable,
          StoredTransaction,
          $$TransactionEntriesTableFilterComposer,
          $$TransactionEntriesTableOrderingComposer,
          $$TransactionEntriesTableAnnotationComposer,
          $$TransactionEntriesTableCreateCompanionBuilder,
          $$TransactionEntriesTableUpdateCompanionBuilder,
          (StoredTransaction, $$TransactionEntriesTableReferences),
          StoredTransaction,
          PrefetchHooks Function({bool accountId, bool counterAccountId})
        > {
  $$TransactionEntriesTableTableManager(
    _$LocalDatabase db,
    $TransactionEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<int> currencyDecimalDigits = const Value.absent(),
                Value<String> currencySymbol = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String?> counterAccountId = const Value.absent(),
                Value<int> occurredAtMicros = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> installmentGroupId = const Value.absent(),
                Value<int?> installmentNumber = const Value.absent(),
                Value<int?> installmentCount = const Value.absent(),
                Value<int?> purchaseTotalMinor = const Value.absent(),
                Value<String?> statementId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionEntriesCompanion(
                id: id,
                description: description,
                type: type,
                status: status,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                currencyDecimalDigits: currencyDecimalDigits,
                currencySymbol: currencySymbol,
                accountId: accountId,
                counterAccountId: counterAccountId,
                occurredAtMicros: occurredAtMicros,
                category: category,
                note: note,
                installmentGroupId: installmentGroupId,
                installmentNumber: installmentNumber,
                installmentCount: installmentCount,
                purchaseTotalMinor: purchaseTotalMinor,
                statementId: statementId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String description,
                required String type,
                required String status,
                required int amountMinor,
                required String currencyCode,
                required int currencyDecimalDigits,
                required String currencySymbol,
                required String accountId,
                Value<String?> counterAccountId = const Value.absent(),
                required int occurredAtMicros,
                Value<String?> category = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> installmentGroupId = const Value.absent(),
                Value<int?> installmentNumber = const Value.absent(),
                Value<int?> installmentCount = const Value.absent(),
                Value<int?> purchaseTotalMinor = const Value.absent(),
                Value<String?> statementId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionEntriesCompanion.insert(
                id: id,
                description: description,
                type: type,
                status: status,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                currencyDecimalDigits: currencyDecimalDigits,
                currencySymbol: currencySymbol,
                accountId: accountId,
                counterAccountId: counterAccountId,
                occurredAtMicros: occurredAtMicros,
                category: category,
                note: note,
                installmentGroupId: installmentGroupId,
                installmentNumber: installmentNumber,
                installmentCount: installmentCount,
                purchaseTotalMinor: purchaseTotalMinor,
                statementId: statementId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TransactionEntriesTable, StoredTransaction>(
                    table,
                  ),
                  $$TransactionEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({accountId = false, counterAccountId = false}) {
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
                        if (accountId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.accountId,
                            referencedTable: $$TransactionEntriesTableReferences
                                ._accountIdTable(db),
                            referencedColumn:
                                $$TransactionEntriesTableReferences
                                    ._accountIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (counterAccountId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.counterAccountId,
                            referencedTable: $$TransactionEntriesTableReferences
                                ._counterAccountIdTable(db),
                            referencedColumn:
                                $$TransactionEntriesTableReferences
                                    ._counterAccountIdTable(db)
                                    .id,
                          ) as T;
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

typedef $$TransactionEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $TransactionEntriesTable,
      StoredTransaction,
      $$TransactionEntriesTableFilterComposer,
      $$TransactionEntriesTableOrderingComposer,
      $$TransactionEntriesTableAnnotationComposer,
      $$TransactionEntriesTableCreateCompanionBuilder,
      $$TransactionEntriesTableUpdateCompanionBuilder,
      (StoredTransaction, $$TransactionEntriesTableReferences),
      StoredTransaction,
      PrefetchHooks Function({bool accountId, bool counterAccountId})
    >;
typedef $$BudgetEntriesTableCreateCompanionBuilder =
    BudgetEntriesCompanion Function({
      required String id,
      required String category,
      required int monthMicros,
      required int limitMinor,
      required String currencyCode,
      required int currencyDecimalDigits,
      required String currencySymbol,
      Value<int> alertThreshold,
      Value<bool> active,
      Value<int> rowid,
    });
typedef $$BudgetEntriesTableUpdateCompanionBuilder =
    BudgetEntriesCompanion Function({
      Value<String> id,
      Value<String> category,
      Value<int> monthMicros,
      Value<int> limitMinor,
      Value<String> currencyCode,
      Value<int> currencyDecimalDigits,
      Value<String> currencySymbol,
      Value<int> alertThreshold,
      Value<bool> active,
      Value<int> rowid,
    });

class $$BudgetEntriesTableFilterComposer
    extends Composer<_$LocalDatabase, $BudgetEntriesTable> {
  $$BudgetEntriesTableFilterComposer({
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

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthMicros => $composableBuilder(
    column: $table.monthMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get limitMinor => $composableBuilder(
    column: $table.limitMinor,
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

  ColumnFilters<int> get alertThreshold => $composableBuilder(
    column: $table.alertThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetEntriesTableOrderingComposer
    extends Composer<_$LocalDatabase, $BudgetEntriesTable> {
  $$BudgetEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthMicros => $composableBuilder(
    column: $table.monthMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get limitMinor => $composableBuilder(
    column: $table.limitMinor,
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

  ColumnOrderings<int> get alertThreshold => $composableBuilder(
    column: $table.alertThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetEntriesTableAnnotationComposer
    extends Composer<_$LocalDatabase, $BudgetEntriesTable> {
  $$BudgetEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get monthMicros => $composableBuilder(
    column: $table.monthMicros,
    builder: (column) => column,
  );

  GeneratedColumn<int> get limitMinor => $composableBuilder(
    column: $table.limitMinor,
    builder: (column) => column,
  );

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

  GeneratedColumn<int> get alertThreshold => $composableBuilder(
    column: $table.alertThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);
}

class $$BudgetEntriesTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $BudgetEntriesTable,
          StoredBudget,
          $$BudgetEntriesTableFilterComposer,
          $$BudgetEntriesTableOrderingComposer,
          $$BudgetEntriesTableAnnotationComposer,
          $$BudgetEntriesTableCreateCompanionBuilder,
          $$BudgetEntriesTableUpdateCompanionBuilder,
          (
            StoredBudget,
            BaseReferences<_$LocalDatabase, $BudgetEntriesTable, StoredBudget>,
          ),
          StoredBudget,
          PrefetchHooks Function()
        > {
  $$BudgetEntriesTableTableManager(
    _$LocalDatabase db,
    $BudgetEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> monthMicros = const Value.absent(),
                Value<int> limitMinor = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<int> currencyDecimalDigits = const Value.absent(),
                Value<String> currencySymbol = const Value.absent(),
                Value<int> alertThreshold = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetEntriesCompanion(
                id: id,
                category: category,
                monthMicros: monthMicros,
                limitMinor: limitMinor,
                currencyCode: currencyCode,
                currencyDecimalDigits: currencyDecimalDigits,
                currencySymbol: currencySymbol,
                alertThreshold: alertThreshold,
                active: active,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String category,
                required int monthMicros,
                required int limitMinor,
                required String currencyCode,
                required int currencyDecimalDigits,
                required String currencySymbol,
                Value<int> alertThreshold = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetEntriesCompanion.insert(
                id: id,
                category: category,
                monthMicros: monthMicros,
                limitMinor: limitMinor,
                currencyCode: currencyCode,
                currencyDecimalDigits: currencyDecimalDigits,
                currencySymbol: currencySymbol,
                alertThreshold: alertThreshold,
                active: active,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BudgetEntriesTable, StoredBudget>(table),
                  BaseReferences<
                    _$LocalDatabase,
                    $BudgetEntriesTable,
                    StoredBudget
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $BudgetEntriesTable,
      StoredBudget,
      $$BudgetEntriesTableFilterComposer,
      $$BudgetEntriesTableOrderingComposer,
      $$BudgetEntriesTableAnnotationComposer,
      $$BudgetEntriesTableCreateCompanionBuilder,
      $$BudgetEntriesTableUpdateCompanionBuilder,
      (
        StoredBudget,
        BaseReferences<_$LocalDatabase, $BudgetEntriesTable, StoredBudget>,
      ),
      StoredBudget,
      PrefetchHooks Function()
    >;
typedef $$RecurringRuleEntriesTableCreateCompanionBuilder =
    RecurringRuleEntriesCompanion Function({
      required String id,
      required String description,
      required String kind,
      required String frequency,
      required int amountMinor,
      required String currencyCode,
      required int currencyDecimalDigits,
      required String currencySymbol,
      required String accountId,
      Value<String?> category,
      required int firstDueAtMicros,
      Value<int> remindDaysBefore,
      Value<bool> active,
      Value<int> rowid,
    });
typedef $$RecurringRuleEntriesTableUpdateCompanionBuilder =
    RecurringRuleEntriesCompanion Function({
      Value<String> id,
      Value<String> description,
      Value<String> kind,
      Value<String> frequency,
      Value<int> amountMinor,
      Value<String> currencyCode,
      Value<int> currencyDecimalDigits,
      Value<String> currencySymbol,
      Value<String> accountId,
      Value<String?> category,
      Value<int> firstDueAtMicros,
      Value<int> remindDaysBefore,
      Value<bool> active,
      Value<int> rowid,
    });

final class $$RecurringRuleEntriesTableReferences
    extends
        BaseReferences<
          _$LocalDatabase,
          $RecurringRuleEntriesTable,
          StoredRecurringRule
        > {
  $$RecurringRuleEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AccountEntriesTable _accountIdTable(_$LocalDatabase db) => db
      .accountEntries
      .createAlias('recurring_rule_entries__account_id__account_entries__id');

  $$AccountEntriesTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountEntriesTableTableManager(
      $_db,
      $_db.accountEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecurringRuleEntriesTableFilterComposer
    extends Composer<_$LocalDatabase, $RecurringRuleEntriesTable> {
  $$RecurringRuleEntriesTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
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

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstDueAtMicros => $composableBuilder(
    column: $table.firstDueAtMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remindDaysBefore => $composableBuilder(
    column: $table.remindDaysBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountEntriesTableFilterComposer get accountId {
    final $$AccountEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accountEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountEntriesTableFilterComposer(
            $db: $db,
            $table: $db.accountEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringRuleEntriesTableOrderingComposer
    extends Composer<_$LocalDatabase, $RecurringRuleEntriesTable> {
  $$RecurringRuleEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
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

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstDueAtMicros => $composableBuilder(
    column: $table.firstDueAtMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remindDaysBefore => $composableBuilder(
    column: $table.remindDaysBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountEntriesTableOrderingComposer get accountId {
    final $$AccountEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accountEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.accountEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringRuleEntriesTableAnnotationComposer
    extends Composer<_$LocalDatabase, $RecurringRuleEntriesTable> {
  $$RecurringRuleEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

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

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get firstDueAtMicros => $composableBuilder(
    column: $table.firstDueAtMicros,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remindDaysBefore => $composableBuilder(
    column: $table.remindDaysBefore,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  $$AccountEntriesTableAnnotationComposer get accountId {
    final $$AccountEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accountEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.accountEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringRuleEntriesTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $RecurringRuleEntriesTable,
          StoredRecurringRule,
          $$RecurringRuleEntriesTableFilterComposer,
          $$RecurringRuleEntriesTableOrderingComposer,
          $$RecurringRuleEntriesTableAnnotationComposer,
          $$RecurringRuleEntriesTableCreateCompanionBuilder,
          $$RecurringRuleEntriesTableUpdateCompanionBuilder,
          (StoredRecurringRule, $$RecurringRuleEntriesTableReferences),
          StoredRecurringRule,
          PrefetchHooks Function({bool accountId})
        > {
  $$RecurringRuleEntriesTableTableManager(
    _$LocalDatabase db,
    $RecurringRuleEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringRuleEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringRuleEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RecurringRuleEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<int> currencyDecimalDigits = const Value.absent(),
                Value<String> currencySymbol = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<int> firstDueAtMicros = const Value.absent(),
                Value<int> remindDaysBefore = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringRuleEntriesCompanion(
                id: id,
                description: description,
                kind: kind,
                frequency: frequency,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                currencyDecimalDigits: currencyDecimalDigits,
                currencySymbol: currencySymbol,
                accountId: accountId,
                category: category,
                firstDueAtMicros: firstDueAtMicros,
                remindDaysBefore: remindDaysBefore,
                active: active,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String description,
                required String kind,
                required String frequency,
                required int amountMinor,
                required String currencyCode,
                required int currencyDecimalDigits,
                required String currencySymbol,
                required String accountId,
                Value<String?> category = const Value.absent(),
                required int firstDueAtMicros,
                Value<int> remindDaysBefore = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringRuleEntriesCompanion.insert(
                id: id,
                description: description,
                kind: kind,
                frequency: frequency,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                currencyDecimalDigits: currencyDecimalDigits,
                currencySymbol: currencySymbol,
                accountId: accountId,
                category: category,
                firstDueAtMicros: firstDueAtMicros,
                remindDaysBefore: remindDaysBefore,
                active: active,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecurringRuleEntriesTable, StoredRecurringRule>(
                    table,
                  ),
                  $$RecurringRuleEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
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
                    if (accountId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.accountId,
                        referencedTable: $$RecurringRuleEntriesTableReferences
                            ._accountIdTable(db),
                        referencedColumn: $$RecurringRuleEntriesTableReferences
                            ._accountIdTable(db)
                            .id,
                      ) as T;
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

typedef $$RecurringRuleEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $RecurringRuleEntriesTable,
      StoredRecurringRule,
      $$RecurringRuleEntriesTableFilterComposer,
      $$RecurringRuleEntriesTableOrderingComposer,
      $$RecurringRuleEntriesTableAnnotationComposer,
      $$RecurringRuleEntriesTableCreateCompanionBuilder,
      $$RecurringRuleEntriesTableUpdateCompanionBuilder,
      (StoredRecurringRule, $$RecurringRuleEntriesTableReferences),
      StoredRecurringRule,
      PrefetchHooks Function({bool accountId})
    >;

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$AccountEntriesTableTableManager get accountEntries =>
      $$AccountEntriesTableTableManager(_db, _db.accountEntries);
  $$TransactionEntriesTableTableManager get transactionEntries =>
      $$TransactionEntriesTableTableManager(_db, _db.transactionEntries);
  $$BudgetEntriesTableTableManager get budgetEntries =>
      $$BudgetEntriesTableTableManager(_db, _db.budgetEntries);
  $$RecurringRuleEntriesTableTableManager get recurringRuleEntries =>
      $$RecurringRuleEntriesTableTableManager(_db, _db.recurringRuleEntries);
}
