// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'luma_database.dart';

// ignore_for_file: type=lint
class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _merchantMeta = const VerificationMeta(
    'merchant',
  );
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
    'merchant',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _referenceNumberMeta = const VerificationMeta(
    'referenceNumber',
  );
  @override
  late final GeneratedColumn<String> referenceNumber = GeneratedColumn<String>(
    'reference_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _smsFingerprintMeta = const VerificationMeta(
    'smsFingerprint',
  );
  @override
  late final GeneratedColumn<String> smsFingerprint = GeneratedColumn<String>(
    'sms_fingerprint',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawSmsMeta = const VerificationMeta('rawSms');
  @override
  late final GeneratedColumn<String> rawSms = GeneratedColumn<String>(
    'raw_sms',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionTypeMeta = const VerificationMeta(
    'transactionType',
  );
  @override
  late final GeneratedColumn<int> transactionType = GeneratedColumn<int>(
    'transaction_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<int> source = GeneratedColumn<int>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastExportedAtMeta = const VerificationMeta(
    'lastExportedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastExportedAt =
      GeneratedColumn<DateTime>(
        'last_exported_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amountMinor,
    merchant,
    categoryId,
    note,
    referenceNumber,
    smsFingerprint,
    rawSms,
    timestamp,
    transactionType,
    status,
    source,
    createdAt,
    updatedAt,
    lastExportedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Expense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('merchant')) {
      context.handle(
        _merchantMeta,
        merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('reference_number')) {
      context.handle(
        _referenceNumberMeta,
        referenceNumber.isAcceptableOrUnknown(
          data['reference_number']!,
          _referenceNumberMeta,
        ),
      );
    }
    if (data.containsKey('sms_fingerprint')) {
      context.handle(
        _smsFingerprintMeta,
        smsFingerprint.isAcceptableOrUnknown(
          data['sms_fingerprint']!,
          _smsFingerprintMeta,
        ),
      );
    }
    if (data.containsKey('raw_sms')) {
      context.handle(
        _rawSmsMeta,
        rawSms.isAcceptableOrUnknown(data['raw_sms']!, _rawSmsMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
        _transactionTypeMeta,
        transactionType.isAcceptableOrUnknown(
          data['transaction_type']!,
          _transactionTypeMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_exported_at')) {
      context.handle(
        _lastExportedAtMeta,
        lastExportedAt.isAcceptableOrUnknown(
          data['last_exported_at']!,
          _lastExportedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      merchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      referenceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_number'],
      ),
      smsFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sms_fingerprint'],
      ),
      rawSms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_sms'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      transactionType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaction_type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastExportedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_exported_at'],
      ),
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final int id;
  final int amountMinor;
  final String? merchant;
  final String? categoryId;
  final String note;
  final String? referenceNumber;
  final String? smsFingerprint;
  final String? rawSms;
  final DateTime timestamp;
  final int transactionType;
  final int status;
  final int source;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastExportedAt;
  const Expense({
    required this.id,
    required this.amountMinor,
    this.merchant,
    this.categoryId,
    required this.note,
    this.referenceNumber,
    this.smsFingerprint,
    this.rawSms,
    required this.timestamp,
    required this.transactionType,
    required this.status,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    this.lastExportedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount_minor'] = Variable<int>(amountMinor);
    if (!nullToAbsent || merchant != null) {
      map['merchant'] = Variable<String>(merchant);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['note'] = Variable<String>(note);
    if (!nullToAbsent || referenceNumber != null) {
      map['reference_number'] = Variable<String>(referenceNumber);
    }
    if (!nullToAbsent || smsFingerprint != null) {
      map['sms_fingerprint'] = Variable<String>(smsFingerprint);
    }
    if (!nullToAbsent || rawSms != null) {
      map['raw_sms'] = Variable<String>(rawSms);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['transaction_type'] = Variable<int>(transactionType);
    map['status'] = Variable<int>(status);
    map['source'] = Variable<int>(source);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastExportedAt != null) {
      map['last_exported_at'] = Variable<DateTime>(lastExportedAt);
    }
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      amountMinor: Value(amountMinor),
      merchant: merchant == null && nullToAbsent
          ? const Value.absent()
          : Value(merchant),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      note: Value(note),
      referenceNumber: referenceNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceNumber),
      smsFingerprint: smsFingerprint == null && nullToAbsent
          ? const Value.absent()
          : Value(smsFingerprint),
      rawSms: rawSms == null && nullToAbsent
          ? const Value.absent()
          : Value(rawSms),
      timestamp: Value(timestamp),
      transactionType: Value(transactionType),
      status: Value(status),
      source: Value(source),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastExportedAt: lastExportedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastExportedAt),
    );
  }

  factory Expense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<int>(json['id']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      merchant: serializer.fromJson<String?>(json['merchant']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      note: serializer.fromJson<String>(json['note']),
      referenceNumber: serializer.fromJson<String?>(json['referenceNumber']),
      smsFingerprint: serializer.fromJson<String?>(json['smsFingerprint']),
      rawSms: serializer.fromJson<String?>(json['rawSms']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      transactionType: serializer.fromJson<int>(json['transactionType']),
      status: serializer.fromJson<int>(json['status']),
      source: serializer.fromJson<int>(json['source']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastExportedAt: serializer.fromJson<DateTime?>(json['lastExportedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'merchant': serializer.toJson<String?>(merchant),
      'categoryId': serializer.toJson<String?>(categoryId),
      'note': serializer.toJson<String>(note),
      'referenceNumber': serializer.toJson<String?>(referenceNumber),
      'smsFingerprint': serializer.toJson<String?>(smsFingerprint),
      'rawSms': serializer.toJson<String?>(rawSms),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'transactionType': serializer.toJson<int>(transactionType),
      'status': serializer.toJson<int>(status),
      'source': serializer.toJson<int>(source),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastExportedAt': serializer.toJson<DateTime?>(lastExportedAt),
    };
  }

  Expense copyWith({
    int? id,
    int? amountMinor,
    Value<String?> merchant = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    String? note,
    Value<String?> referenceNumber = const Value.absent(),
    Value<String?> smsFingerprint = const Value.absent(),
    Value<String?> rawSms = const Value.absent(),
    DateTime? timestamp,
    int? transactionType,
    int? status,
    int? source,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastExportedAt = const Value.absent(),
  }) => Expense(
    id: id ?? this.id,
    amountMinor: amountMinor ?? this.amountMinor,
    merchant: merchant.present ? merchant.value : this.merchant,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    note: note ?? this.note,
    referenceNumber: referenceNumber.present
        ? referenceNumber.value
        : this.referenceNumber,
    smsFingerprint: smsFingerprint.present
        ? smsFingerprint.value
        : this.smsFingerprint,
    rawSms: rawSms.present ? rawSms.value : this.rawSms,
    timestamp: timestamp ?? this.timestamp,
    transactionType: transactionType ?? this.transactionType,
    status: status ?? this.status,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastExportedAt: lastExportedAt.present
        ? lastExportedAt.value
        : this.lastExportedAt,
  );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      note: data.note.present ? data.note.value : this.note,
      referenceNumber: data.referenceNumber.present
          ? data.referenceNumber.value
          : this.referenceNumber,
      smsFingerprint: data.smsFingerprint.present
          ? data.smsFingerprint.value
          : this.smsFingerprint,
      rawSms: data.rawSms.present ? data.rawSms.value : this.rawSms,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      status: data.status.present ? data.status.value : this.status,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastExportedAt: data.lastExportedAt.present
          ? data.lastExportedAt.value
          : this.lastExportedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('merchant: $merchant, ')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('smsFingerprint: $smsFingerprint, ')
          ..write('rawSms: $rawSms, ')
          ..write('timestamp: $timestamp, ')
          ..write('transactionType: $transactionType, ')
          ..write('status: $status, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastExportedAt: $lastExportedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amountMinor,
    merchant,
    categoryId,
    note,
    referenceNumber,
    smsFingerprint,
    rawSms,
    timestamp,
    transactionType,
    status,
    source,
    createdAt,
    updatedAt,
    lastExportedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.amountMinor == this.amountMinor &&
          other.merchant == this.merchant &&
          other.categoryId == this.categoryId &&
          other.note == this.note &&
          other.referenceNumber == this.referenceNumber &&
          other.smsFingerprint == this.smsFingerprint &&
          other.rawSms == this.rawSms &&
          other.timestamp == this.timestamp &&
          other.transactionType == this.transactionType &&
          other.status == this.status &&
          other.source == this.source &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastExportedAt == this.lastExportedAt);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<int> id;
  final Value<int> amountMinor;
  final Value<String?> merchant;
  final Value<String?> categoryId;
  final Value<String> note;
  final Value<String?> referenceNumber;
  final Value<String?> smsFingerprint;
  final Value<String?> rawSms;
  final Value<DateTime> timestamp;
  final Value<int> transactionType;
  final Value<int> status;
  final Value<int> source;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastExportedAt;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.merchant = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.note = const Value.absent(),
    this.referenceNumber = const Value.absent(),
    this.smsFingerprint = const Value.absent(),
    this.rawSms = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.status = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastExportedAt = const Value.absent(),
  });
  ExpensesCompanion.insert({
    this.id = const Value.absent(),
    required int amountMinor,
    this.merchant = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.note = const Value.absent(),
    this.referenceNumber = const Value.absent(),
    this.smsFingerprint = const Value.absent(),
    this.rawSms = const Value.absent(),
    required DateTime timestamp,
    this.transactionType = const Value.absent(),
    this.status = const Value.absent(),
    this.source = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.lastExportedAt = const Value.absent(),
  }) : amountMinor = Value(amountMinor),
       timestamp = Value(timestamp),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Expense> custom({
    Expression<int>? id,
    Expression<int>? amountMinor,
    Expression<String>? merchant,
    Expression<String>? categoryId,
    Expression<String>? note,
    Expression<String>? referenceNumber,
    Expression<String>? smsFingerprint,
    Expression<String>? rawSms,
    Expression<DateTime>? timestamp,
    Expression<int>? transactionType,
    Expression<int>? status,
    Expression<int>? source,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastExportedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (merchant != null) 'merchant': merchant,
      if (categoryId != null) 'category_id': categoryId,
      if (note != null) 'note': note,
      if (referenceNumber != null) 'reference_number': referenceNumber,
      if (smsFingerprint != null) 'sms_fingerprint': smsFingerprint,
      if (rawSms != null) 'raw_sms': rawSms,
      if (timestamp != null) 'timestamp': timestamp,
      if (transactionType != null) 'transaction_type': transactionType,
      if (status != null) 'status': status,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastExportedAt != null) 'last_exported_at': lastExportedAt,
    });
  }

  ExpensesCompanion copyWith({
    Value<int>? id,
    Value<int>? amountMinor,
    Value<String?>? merchant,
    Value<String?>? categoryId,
    Value<String>? note,
    Value<String?>? referenceNumber,
    Value<String?>? smsFingerprint,
    Value<String?>? rawSms,
    Value<DateTime>? timestamp,
    Value<int>? transactionType,
    Value<int>? status,
    Value<int>? source,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastExportedAt,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      amountMinor: amountMinor ?? this.amountMinor,
      merchant: merchant ?? this.merchant,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      smsFingerprint: smsFingerprint ?? this.smsFingerprint,
      rawSms: rawSms ?? this.rawSms,
      timestamp: timestamp ?? this.timestamp,
      transactionType: transactionType ?? this.transactionType,
      status: status ?? this.status,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastExportedAt: lastExportedAt ?? this.lastExportedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (referenceNumber.present) {
      map['reference_number'] = Variable<String>(referenceNumber.value);
    }
    if (smsFingerprint.present) {
      map['sms_fingerprint'] = Variable<String>(smsFingerprint.value);
    }
    if (rawSms.present) {
      map['raw_sms'] = Variable<String>(rawSms.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<int>(transactionType.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (source.present) {
      map['source'] = Variable<int>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastExportedAt.present) {
      map['last_exported_at'] = Variable<DateTime>(lastExportedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('merchant: $merchant, ')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('smsFingerprint: $smsFingerprint, ')
          ..write('rawSms: $rawSms, ')
          ..write('timestamp: $timestamp, ')
          ..write('transactionType: $transactionType, ')
          ..write('status: $status, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastExportedAt: $lastExportedAt')
          ..write(')'))
        .toString();
  }
}

class $MerchantProfilesTable extends MerchantProfiles
    with TableInfo<$MerchantProfilesTable, MerchantProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MerchantProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _normalizedMerchantMeta =
      const VerificationMeta('normalizedMerchant');
  @override
  late final GeneratedColumn<String> normalizedMerchant =
      GeneratedColumn<String>(
        'normalized_merchant',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _displayMerchantMeta = const VerificationMeta(
    'displayMerchant',
  );
  @override
  late final GeneratedColumn<String> displayMerchant = GeneratedColumn<String>(
    'display_merchant',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryCountsMeta = const VerificationMeta(
    'categoryCounts',
  );
  @override
  late final GeneratedColumn<String> categoryCounts = GeneratedColumn<String>(
    'category_counts',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _lastUsedCategoryMeta = const VerificationMeta(
    'lastUsedCategory',
  );
  @override
  late final GeneratedColumn<String> lastUsedCategory = GeneratedColumn<String>(
    'last_used_category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalTransactionsMeta = const VerificationMeta(
    'totalTransactions',
  );
  @override
  late final GeneratedColumn<int> totalTransactions = GeneratedColumn<int>(
    'total_transactions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    normalizedMerchant,
    displayMerchant,
    categoryCounts,
    lastUsedCategory,
    totalTransactions,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'merchant_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<MerchantProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('normalized_merchant')) {
      context.handle(
        _normalizedMerchantMeta,
        normalizedMerchant.isAcceptableOrUnknown(
          data['normalized_merchant']!,
          _normalizedMerchantMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedMerchantMeta);
    }
    if (data.containsKey('display_merchant')) {
      context.handle(
        _displayMerchantMeta,
        displayMerchant.isAcceptableOrUnknown(
          data['display_merchant']!,
          _displayMerchantMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayMerchantMeta);
    }
    if (data.containsKey('category_counts')) {
      context.handle(
        _categoryCountsMeta,
        categoryCounts.isAcceptableOrUnknown(
          data['category_counts']!,
          _categoryCountsMeta,
        ),
      );
    }
    if (data.containsKey('last_used_category')) {
      context.handle(
        _lastUsedCategoryMeta,
        lastUsedCategory.isAcceptableOrUnknown(
          data['last_used_category']!,
          _lastUsedCategoryMeta,
        ),
      );
    }
    if (data.containsKey('total_transactions')) {
      context.handle(
        _totalTransactionsMeta,
        totalTransactions.isAcceptableOrUnknown(
          data['total_transactions']!,
          _totalTransactionsMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {normalizedMerchant};
  @override
  MerchantProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MerchantProfile(
      normalizedMerchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_merchant'],
      )!,
      displayMerchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_merchant'],
      )!,
      categoryCounts: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_counts'],
      )!,
      lastUsedCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_used_category'],
      ),
      totalTransactions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_transactions'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MerchantProfilesTable createAlias(String alias) {
    return $MerchantProfilesTable(attachedDatabase, alias);
  }
}

class MerchantProfile extends DataClass implements Insertable<MerchantProfile> {
  final String normalizedMerchant;
  final String displayMerchant;
  final String categoryCounts;
  final String? lastUsedCategory;
  final int totalTransactions;
  final DateTime updatedAt;
  const MerchantProfile({
    required this.normalizedMerchant,
    required this.displayMerchant,
    required this.categoryCounts,
    this.lastUsedCategory,
    required this.totalTransactions,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['normalized_merchant'] = Variable<String>(normalizedMerchant);
    map['display_merchant'] = Variable<String>(displayMerchant);
    map['category_counts'] = Variable<String>(categoryCounts);
    if (!nullToAbsent || lastUsedCategory != null) {
      map['last_used_category'] = Variable<String>(lastUsedCategory);
    }
    map['total_transactions'] = Variable<int>(totalTransactions);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MerchantProfilesCompanion toCompanion(bool nullToAbsent) {
    return MerchantProfilesCompanion(
      normalizedMerchant: Value(normalizedMerchant),
      displayMerchant: Value(displayMerchant),
      categoryCounts: Value(categoryCounts),
      lastUsedCategory: lastUsedCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsedCategory),
      totalTransactions: Value(totalTransactions),
      updatedAt: Value(updatedAt),
    );
  }

  factory MerchantProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MerchantProfile(
      normalizedMerchant: serializer.fromJson<String>(
        json['normalizedMerchant'],
      ),
      displayMerchant: serializer.fromJson<String>(json['displayMerchant']),
      categoryCounts: serializer.fromJson<String>(json['categoryCounts']),
      lastUsedCategory: serializer.fromJson<String?>(json['lastUsedCategory']),
      totalTransactions: serializer.fromJson<int>(json['totalTransactions']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'normalizedMerchant': serializer.toJson<String>(normalizedMerchant),
      'displayMerchant': serializer.toJson<String>(displayMerchant),
      'categoryCounts': serializer.toJson<String>(categoryCounts),
      'lastUsedCategory': serializer.toJson<String?>(lastUsedCategory),
      'totalTransactions': serializer.toJson<int>(totalTransactions),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MerchantProfile copyWith({
    String? normalizedMerchant,
    String? displayMerchant,
    String? categoryCounts,
    Value<String?> lastUsedCategory = const Value.absent(),
    int? totalTransactions,
    DateTime? updatedAt,
  }) => MerchantProfile(
    normalizedMerchant: normalizedMerchant ?? this.normalizedMerchant,
    displayMerchant: displayMerchant ?? this.displayMerchant,
    categoryCounts: categoryCounts ?? this.categoryCounts,
    lastUsedCategory: lastUsedCategory.present
        ? lastUsedCategory.value
        : this.lastUsedCategory,
    totalTransactions: totalTransactions ?? this.totalTransactions,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MerchantProfile copyWithCompanion(MerchantProfilesCompanion data) {
    return MerchantProfile(
      normalizedMerchant: data.normalizedMerchant.present
          ? data.normalizedMerchant.value
          : this.normalizedMerchant,
      displayMerchant: data.displayMerchant.present
          ? data.displayMerchant.value
          : this.displayMerchant,
      categoryCounts: data.categoryCounts.present
          ? data.categoryCounts.value
          : this.categoryCounts,
      lastUsedCategory: data.lastUsedCategory.present
          ? data.lastUsedCategory.value
          : this.lastUsedCategory,
      totalTransactions: data.totalTransactions.present
          ? data.totalTransactions.value
          : this.totalTransactions,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MerchantProfile(')
          ..write('normalizedMerchant: $normalizedMerchant, ')
          ..write('displayMerchant: $displayMerchant, ')
          ..write('categoryCounts: $categoryCounts, ')
          ..write('lastUsedCategory: $lastUsedCategory, ')
          ..write('totalTransactions: $totalTransactions, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    normalizedMerchant,
    displayMerchant,
    categoryCounts,
    lastUsedCategory,
    totalTransactions,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MerchantProfile &&
          other.normalizedMerchant == this.normalizedMerchant &&
          other.displayMerchant == this.displayMerchant &&
          other.categoryCounts == this.categoryCounts &&
          other.lastUsedCategory == this.lastUsedCategory &&
          other.totalTransactions == this.totalTransactions &&
          other.updatedAt == this.updatedAt);
}

class MerchantProfilesCompanion extends UpdateCompanion<MerchantProfile> {
  final Value<String> normalizedMerchant;
  final Value<String> displayMerchant;
  final Value<String> categoryCounts;
  final Value<String?> lastUsedCategory;
  final Value<int> totalTransactions;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MerchantProfilesCompanion({
    this.normalizedMerchant = const Value.absent(),
    this.displayMerchant = const Value.absent(),
    this.categoryCounts = const Value.absent(),
    this.lastUsedCategory = const Value.absent(),
    this.totalTransactions = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MerchantProfilesCompanion.insert({
    required String normalizedMerchant,
    required String displayMerchant,
    this.categoryCounts = const Value.absent(),
    this.lastUsedCategory = const Value.absent(),
    this.totalTransactions = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : normalizedMerchant = Value(normalizedMerchant),
       displayMerchant = Value(displayMerchant),
       updatedAt = Value(updatedAt);
  static Insertable<MerchantProfile> custom({
    Expression<String>? normalizedMerchant,
    Expression<String>? displayMerchant,
    Expression<String>? categoryCounts,
    Expression<String>? lastUsedCategory,
    Expression<int>? totalTransactions,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (normalizedMerchant != null) 'normalized_merchant': normalizedMerchant,
      if (displayMerchant != null) 'display_merchant': displayMerchant,
      if (categoryCounts != null) 'category_counts': categoryCounts,
      if (lastUsedCategory != null) 'last_used_category': lastUsedCategory,
      if (totalTransactions != null) 'total_transactions': totalTransactions,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MerchantProfilesCompanion copyWith({
    Value<String>? normalizedMerchant,
    Value<String>? displayMerchant,
    Value<String>? categoryCounts,
    Value<String?>? lastUsedCategory,
    Value<int>? totalTransactions,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MerchantProfilesCompanion(
      normalizedMerchant: normalizedMerchant ?? this.normalizedMerchant,
      displayMerchant: displayMerchant ?? this.displayMerchant,
      categoryCounts: categoryCounts ?? this.categoryCounts,
      lastUsedCategory: lastUsedCategory ?? this.lastUsedCategory,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (normalizedMerchant.present) {
      map['normalized_merchant'] = Variable<String>(normalizedMerchant.value);
    }
    if (displayMerchant.present) {
      map['display_merchant'] = Variable<String>(displayMerchant.value);
    }
    if (categoryCounts.present) {
      map['category_counts'] = Variable<String>(categoryCounts.value);
    }
    if (lastUsedCategory.present) {
      map['last_used_category'] = Variable<String>(lastUsedCategory.value);
    }
    if (totalTransactions.present) {
      map['total_transactions'] = Variable<int>(totalTransactions.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MerchantProfilesCompanion(')
          ..write('normalizedMerchant: $normalizedMerchant, ')
          ..write('displayMerchant: $displayMerchant, ')
          ..write('categoryCounts: $categoryCounts, ')
          ..write('lastUsedCategory: $lastUsedCategory, ')
          ..write('totalTransactions: $totalTransactions, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, icon, sortOrder, isDefault];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
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
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String name;
  final String icon;
  final int sortOrder;
  final bool isDefault;
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.sortOrder,
    required this.isDefault,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_default'] = Variable<bool>(isDefault);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      sortOrder: Value(sortOrder),
      isDefault: Value(isDefault),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isDefault': serializer.toJson<bool>(isDefault),
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? icon,
    int? sortOrder,
    bool? isDefault,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    sortOrder: sortOrder ?? this.sortOrder,
    isDefault: isDefault ?? this.isDefault,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isDefault: $isDefault')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, icon, sortOrder, isDefault);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.sortOrder == this.sortOrder &&
          other.isDefault == this.isDefault);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> icon;
  final Value<int> sortOrder;
  final Value<bool> isDefault;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required String icon,
    required int sortOrder,
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       icon = Value(icon),
       sortOrder = Value(sortOrder);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<int>? sortOrder,
    Expression<bool>? isDefault,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isDefault != null) 'is_default': isDefault,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? icon,
    Value<int>? sortOrder,
    Value<bool>? isDefault,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault ?? this.isDefault,
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
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isDefault: $isDefault, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dailyAuditEnabledMeta = const VerificationMeta(
    'dailyAuditEnabled',
  );
  @override
  late final GeneratedColumn<bool> dailyAuditEnabled = GeneratedColumn<bool>(
    'daily_audit_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("daily_audit_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _auditHourMeta = const VerificationMeta(
    'auditHour',
  );
  @override
  late final GeneratedColumn<int> auditHour = GeneratedColumn<int>(
    'audit_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(21),
  );
  static const VerificationMeta _auditMinuteMeta = const VerificationMeta(
    'auditMinute',
  );
  @override
  late final GeneratedColumn<int> auditMinute = GeneratedColumn<int>(
    'audit_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _onboardingDoneMeta = const VerificationMeta(
    'onboardingDone',
  );
  @override
  late final GeneratedColumn<bool> onboardingDone = GeneratedColumn<bool>(
    'onboarding_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _userNameMeta = const VerificationMeta(
    'userName',
  );
  @override
  late final GeneratedColumn<String> userName = GeneratedColumn<String>(
    'user_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _initialBalanceMinorMeta =
      const VerificationMeta('initialBalanceMinor');
  @override
  late final GeneratedColumn<int> initialBalanceMinor = GeneratedColumn<int>(
    'initial_balance_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dailyAuditEnabled,
    auditHour,
    auditMinute,
    onboardingDone,
    userName,
    initialBalanceMinor,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('daily_audit_enabled')) {
      context.handle(
        _dailyAuditEnabledMeta,
        dailyAuditEnabled.isAcceptableOrUnknown(
          data['daily_audit_enabled']!,
          _dailyAuditEnabledMeta,
        ),
      );
    }
    if (data.containsKey('audit_hour')) {
      context.handle(
        _auditHourMeta,
        auditHour.isAcceptableOrUnknown(data['audit_hour']!, _auditHourMeta),
      );
    }
    if (data.containsKey('audit_minute')) {
      context.handle(
        _auditMinuteMeta,
        auditMinute.isAcceptableOrUnknown(
          data['audit_minute']!,
          _auditMinuteMeta,
        ),
      );
    }
    if (data.containsKey('onboarding_done')) {
      context.handle(
        _onboardingDoneMeta,
        onboardingDone.isAcceptableOrUnknown(
          data['onboarding_done']!,
          _onboardingDoneMeta,
        ),
      );
    }
    if (data.containsKey('user_name')) {
      context.handle(
        _userNameMeta,
        userName.isAcceptableOrUnknown(data['user_name']!, _userNameMeta),
      );
    }
    if (data.containsKey('initial_balance_minor')) {
      context.handle(
        _initialBalanceMinorMeta,
        initialBalanceMinor.isAcceptableOrUnknown(
          data['initial_balance_minor']!,
          _initialBalanceMinorMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dailyAuditEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}daily_audit_enabled'],
      )!,
      auditHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}audit_hour'],
      )!,
      auditMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}audit_minute'],
      )!,
      onboardingDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_done'],
      )!,
      userName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_name'],
      ),
      initialBalanceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}initial_balance_minor'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final int id;
  final bool dailyAuditEnabled;
  final int auditHour;
  final int auditMinute;
  final bool onboardingDone;
  final String? userName;
  final int initialBalanceMinor;
  const AppSetting({
    required this.id,
    required this.dailyAuditEnabled,
    required this.auditHour,
    required this.auditMinute,
    required this.onboardingDone,
    this.userName,
    required this.initialBalanceMinor,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['daily_audit_enabled'] = Variable<bool>(dailyAuditEnabled);
    map['audit_hour'] = Variable<int>(auditHour);
    map['audit_minute'] = Variable<int>(auditMinute);
    map['onboarding_done'] = Variable<bool>(onboardingDone);
    if (!nullToAbsent || userName != null) {
      map['user_name'] = Variable<String>(userName);
    }
    map['initial_balance_minor'] = Variable<int>(initialBalanceMinor);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      dailyAuditEnabled: Value(dailyAuditEnabled),
      auditHour: Value(auditHour),
      auditMinute: Value(auditMinute),
      onboardingDone: Value(onboardingDone),
      userName: userName == null && nullToAbsent
          ? const Value.absent()
          : Value(userName),
      initialBalanceMinor: Value(initialBalanceMinor),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<int>(json['id']),
      dailyAuditEnabled: serializer.fromJson<bool>(json['dailyAuditEnabled']),
      auditHour: serializer.fromJson<int>(json['auditHour']),
      auditMinute: serializer.fromJson<int>(json['auditMinute']),
      onboardingDone: serializer.fromJson<bool>(json['onboardingDone']),
      userName: serializer.fromJson<String?>(json['userName']),
      initialBalanceMinor: serializer.fromJson<int>(
        json['initialBalanceMinor'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dailyAuditEnabled': serializer.toJson<bool>(dailyAuditEnabled),
      'auditHour': serializer.toJson<int>(auditHour),
      'auditMinute': serializer.toJson<int>(auditMinute),
      'onboardingDone': serializer.toJson<bool>(onboardingDone),
      'userName': serializer.toJson<String?>(userName),
      'initialBalanceMinor': serializer.toJson<int>(initialBalanceMinor),
    };
  }

  AppSetting copyWith({
    int? id,
    bool? dailyAuditEnabled,
    int? auditHour,
    int? auditMinute,
    bool? onboardingDone,
    Value<String?> userName = const Value.absent(),
    int? initialBalanceMinor,
  }) => AppSetting(
    id: id ?? this.id,
    dailyAuditEnabled: dailyAuditEnabled ?? this.dailyAuditEnabled,
    auditHour: auditHour ?? this.auditHour,
    auditMinute: auditMinute ?? this.auditMinute,
    onboardingDone: onboardingDone ?? this.onboardingDone,
    userName: userName.present ? userName.value : this.userName,
    initialBalanceMinor: initialBalanceMinor ?? this.initialBalanceMinor,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      dailyAuditEnabled: data.dailyAuditEnabled.present
          ? data.dailyAuditEnabled.value
          : this.dailyAuditEnabled,
      auditHour: data.auditHour.present ? data.auditHour.value : this.auditHour,
      auditMinute: data.auditMinute.present
          ? data.auditMinute.value
          : this.auditMinute,
      onboardingDone: data.onboardingDone.present
          ? data.onboardingDone.value
          : this.onboardingDone,
      userName: data.userName.present ? data.userName.value : this.userName,
      initialBalanceMinor: data.initialBalanceMinor.present
          ? data.initialBalanceMinor.value
          : this.initialBalanceMinor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('dailyAuditEnabled: $dailyAuditEnabled, ')
          ..write('auditHour: $auditHour, ')
          ..write('auditMinute: $auditMinute, ')
          ..write('onboardingDone: $onboardingDone, ')
          ..write('userName: $userName, ')
          ..write('initialBalanceMinor: $initialBalanceMinor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dailyAuditEnabled,
    auditHour,
    auditMinute,
    onboardingDone,
    userName,
    initialBalanceMinor,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.dailyAuditEnabled == this.dailyAuditEnabled &&
          other.auditHour == this.auditHour &&
          other.auditMinute == this.auditMinute &&
          other.onboardingDone == this.onboardingDone &&
          other.userName == this.userName &&
          other.initialBalanceMinor == this.initialBalanceMinor);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<bool> dailyAuditEnabled;
  final Value<int> auditHour;
  final Value<int> auditMinute;
  final Value<bool> onboardingDone;
  final Value<String?> userName;
  final Value<int> initialBalanceMinor;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.dailyAuditEnabled = const Value.absent(),
    this.auditHour = const Value.absent(),
    this.auditMinute = const Value.absent(),
    this.onboardingDone = const Value.absent(),
    this.userName = const Value.absent(),
    this.initialBalanceMinor = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.dailyAuditEnabled = const Value.absent(),
    this.auditHour = const Value.absent(),
    this.auditMinute = const Value.absent(),
    this.onboardingDone = const Value.absent(),
    this.userName = const Value.absent(),
    this.initialBalanceMinor = const Value.absent(),
  });
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<bool>? dailyAuditEnabled,
    Expression<int>? auditHour,
    Expression<int>? auditMinute,
    Expression<bool>? onboardingDone,
    Expression<String>? userName,
    Expression<int>? initialBalanceMinor,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dailyAuditEnabled != null) 'daily_audit_enabled': dailyAuditEnabled,
      if (auditHour != null) 'audit_hour': auditHour,
      if (auditMinute != null) 'audit_minute': auditMinute,
      if (onboardingDone != null) 'onboarding_done': onboardingDone,
      if (userName != null) 'user_name': userName,
      if (initialBalanceMinor != null)
        'initial_balance_minor': initialBalanceMinor,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<bool>? dailyAuditEnabled,
    Value<int>? auditHour,
    Value<int>? auditMinute,
    Value<bool>? onboardingDone,
    Value<String?>? userName,
    Value<int>? initialBalanceMinor,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      dailyAuditEnabled: dailyAuditEnabled ?? this.dailyAuditEnabled,
      auditHour: auditHour ?? this.auditHour,
      auditMinute: auditMinute ?? this.auditMinute,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      userName: userName ?? this.userName,
      initialBalanceMinor: initialBalanceMinor ?? this.initialBalanceMinor,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dailyAuditEnabled.present) {
      map['daily_audit_enabled'] = Variable<bool>(dailyAuditEnabled.value);
    }
    if (auditHour.present) {
      map['audit_hour'] = Variable<int>(auditHour.value);
    }
    if (auditMinute.present) {
      map['audit_minute'] = Variable<int>(auditMinute.value);
    }
    if (onboardingDone.present) {
      map['onboarding_done'] = Variable<bool>(onboardingDone.value);
    }
    if (userName.present) {
      map['user_name'] = Variable<String>(userName.value);
    }
    if (initialBalanceMinor.present) {
      map['initial_balance_minor'] = Variable<int>(initialBalanceMinor.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('dailyAuditEnabled: $dailyAuditEnabled, ')
          ..write('auditHour: $auditHour, ')
          ..write('auditMinute: $auditMinute, ')
          ..write('onboardingDone: $onboardingDone, ')
          ..write('userName: $userName, ')
          ..write('initialBalanceMinor: $initialBalanceMinor')
          ..write(')'))
        .toString();
  }
}

class $ExportRecordsTable extends ExportRecords
    with TableInfo<$ExportRecordsTable, ExportRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExportRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, type, createdAt, fileName, count];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'export_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExportRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExportRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExportRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
    );
  }

  @override
  $ExportRecordsTable createAlias(String alias) {
    return $ExportRecordsTable(attachedDatabase, alias);
  }
}

class ExportRecord extends DataClass implements Insertable<ExportRecord> {
  final int id;
  final String type;
  final DateTime createdAt;
  final String fileName;
  final int count;
  const ExportRecord({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.fileName,
    required this.count,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['file_name'] = Variable<String>(fileName);
    map['count'] = Variable<int>(count);
    return map;
  }

  ExportRecordsCompanion toCompanion(bool nullToAbsent) {
    return ExportRecordsCompanion(
      id: Value(id),
      type: Value(type),
      createdAt: Value(createdAt),
      fileName: Value(fileName),
      count: Value(count),
    );
  }

  factory ExportRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExportRecord(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      fileName: serializer.fromJson<String>(json['fileName']),
      count: serializer.fromJson<int>(json['count']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'fileName': serializer.toJson<String>(fileName),
      'count': serializer.toJson<int>(count),
    };
  }

  ExportRecord copyWith({
    int? id,
    String? type,
    DateTime? createdAt,
    String? fileName,
    int? count,
  }) => ExportRecord(
    id: id ?? this.id,
    type: type ?? this.type,
    createdAt: createdAt ?? this.createdAt,
    fileName: fileName ?? this.fileName,
    count: count ?? this.count,
  );
  ExportRecord copyWithCompanion(ExportRecordsCompanion data) {
    return ExportRecord(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      count: data.count.present ? data.count.value : this.count,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExportRecord(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt, ')
          ..write('fileName: $fileName, ')
          ..write('count: $count')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, createdAt, fileName, count);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExportRecord &&
          other.id == this.id &&
          other.type == this.type &&
          other.createdAt == this.createdAt &&
          other.fileName == this.fileName &&
          other.count == this.count);
}

class ExportRecordsCompanion extends UpdateCompanion<ExportRecord> {
  final Value<int> id;
  final Value<String> type;
  final Value<DateTime> createdAt;
  final Value<String> fileName;
  final Value<int> count;
  const ExportRecordsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.fileName = const Value.absent(),
    this.count = const Value.absent(),
  });
  ExportRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required DateTime createdAt,
    required String fileName,
    required int count,
  }) : type = Value(type),
       createdAt = Value(createdAt),
       fileName = Value(fileName),
       count = Value(count);
  static Insertable<ExportRecord> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<DateTime>? createdAt,
    Expression<String>? fileName,
    Expression<int>? count,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (createdAt != null) 'created_at': createdAt,
      if (fileName != null) 'file_name': fileName,
      if (count != null) 'count': count,
    });
  }

  ExportRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<DateTime>? createdAt,
    Value<String>? fileName,
    Value<int>? count,
  }) {
    return ExportRecordsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      fileName: fileName ?? this.fileName,
      count: count ?? this.count,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExportRecordsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt, ')
          ..write('fileName: $fileName, ')
          ..write('count: $count')
          ..write(')'))
        .toString();
  }
}

class $SubscriptionsTable extends Subscriptions
    with TableInfo<$SubscriptionsTable, Subscription> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscriptionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _merchantPatternMeta = const VerificationMeta(
    'merchantPattern',
  );
  @override
  late final GeneratedColumn<String> merchantPattern = GeneratedColumn<String>(
    'merchant_pattern',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _billingCycleMeta = const VerificationMeta(
    'billingCycle',
  );
  @override
  late final GeneratedColumn<int> billingCycle = GeneratedColumn<int>(
    'billing_cycle',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<int> paymentMethod = GeneratedColumn<int>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextRenewalDateMeta = const VerificationMeta(
    'nextRenewalDate',
  );
  @override
  late final GeneratedColumn<DateTime> nextRenewalDate =
      GeneratedColumn<DateTime>(
        'next_renewal_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _trialEndDateMeta = const VerificationMeta(
    'trialEndDate',
  );
  @override
  late final GeneratedColumn<DateTime> trialEndDate = GeneratedColumn<DateTime>(
    'trial_end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cancellationReminderEnabledMeta =
      const VerificationMeta('cancellationReminderEnabled');
  @override
  late final GeneratedColumn<bool> cancellationReminderEnabled =
      GeneratedColumn<bool>(
        'cancellation_reminder_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("cancellation_reminder_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _cancellationReminderDaysBeforeMeta =
      const VerificationMeta('cancellationReminderDaysBefore');
  @override
  late final GeneratedColumn<int> cancellationReminderDaysBefore =
      GeneratedColumn<int>(
        'cancellation_reminder_days_before',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(3),
      );
  static const VerificationMeta _paymentReminderEnabledMeta =
      const VerificationMeta('paymentReminderEnabled');
  @override
  late final GeneratedColumn<bool> paymentReminderEnabled =
      GeneratedColumn<bool>(
        'payment_reminder_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("payment_reminder_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _paymentReminderDaysBeforeMeta =
      const VerificationMeta('paymentReminderDaysBefore');
  @override
  late final GeneratedColumn<int> paymentReminderDaysBefore =
      GeneratedColumn<int>(
        'payment_reminder_days_before',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(1),
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    merchantPattern,
    amountMinor,
    billingCycle,
    paymentMethod,
    status,
    startDate,
    nextRenewalDate,
    trialEndDate,
    endDate,
    cancellationReminderEnabled,
    cancellationReminderDaysBefore,
    paymentReminderEnabled,
    paymentReminderDaysBefore,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscriptions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Subscription> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('merchant_pattern')) {
      context.handle(
        _merchantPatternMeta,
        merchantPattern.isAcceptableOrUnknown(
          data['merchant_pattern']!,
          _merchantPatternMeta,
        ),
      );
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
    if (data.containsKey('billing_cycle')) {
      context.handle(
        _billingCycleMeta,
        billingCycle.isAcceptableOrUnknown(
          data['billing_cycle']!,
          _billingCycleMeta,
        ),
      );
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('next_renewal_date')) {
      context.handle(
        _nextRenewalDateMeta,
        nextRenewalDate.isAcceptableOrUnknown(
          data['next_renewal_date']!,
          _nextRenewalDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextRenewalDateMeta);
    }
    if (data.containsKey('trial_end_date')) {
      context.handle(
        _trialEndDateMeta,
        trialEndDate.isAcceptableOrUnknown(
          data['trial_end_date']!,
          _trialEndDateMeta,
        ),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('cancellation_reminder_enabled')) {
      context.handle(
        _cancellationReminderEnabledMeta,
        cancellationReminderEnabled.isAcceptableOrUnknown(
          data['cancellation_reminder_enabled']!,
          _cancellationReminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('cancellation_reminder_days_before')) {
      context.handle(
        _cancellationReminderDaysBeforeMeta,
        cancellationReminderDaysBefore.isAcceptableOrUnknown(
          data['cancellation_reminder_days_before']!,
          _cancellationReminderDaysBeforeMeta,
        ),
      );
    }
    if (data.containsKey('payment_reminder_enabled')) {
      context.handle(
        _paymentReminderEnabledMeta,
        paymentReminderEnabled.isAcceptableOrUnknown(
          data['payment_reminder_enabled']!,
          _paymentReminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('payment_reminder_days_before')) {
      context.handle(
        _paymentReminderDaysBeforeMeta,
        paymentReminderDaysBefore.isAcceptableOrUnknown(
          data['payment_reminder_days_before']!,
          _paymentReminderDaysBeforeMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subscription map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subscription(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      merchantPattern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant_pattern'],
      ),
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      billingCycle: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}billing_cycle'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_method'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      nextRenewalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_renewal_date'],
      )!,
      trialEndDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}trial_end_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      cancellationReminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}cancellation_reminder_enabled'],
      )!,
      cancellationReminderDaysBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cancellation_reminder_days_before'],
      )!,
      paymentReminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}payment_reminder_enabled'],
      )!,
      paymentReminderDaysBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_reminder_days_before'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SubscriptionsTable createAlias(String alias) {
    return $SubscriptionsTable(attachedDatabase, alias);
  }
}

class Subscription extends DataClass implements Insertable<Subscription> {
  final int id;
  final String name;
  final String? merchantPattern;
  final int amountMinor;
  final int billingCycle;
  final int paymentMethod;
  final int status;
  final DateTime startDate;
  final DateTime nextRenewalDate;
  final DateTime? trialEndDate;
  final DateTime? endDate;
  final bool cancellationReminderEnabled;
  final int cancellationReminderDaysBefore;
  final bool paymentReminderEnabled;
  final int paymentReminderDaysBefore;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Subscription({
    required this.id,
    required this.name,
    this.merchantPattern,
    required this.amountMinor,
    required this.billingCycle,
    required this.paymentMethod,
    required this.status,
    required this.startDate,
    required this.nextRenewalDate,
    this.trialEndDate,
    this.endDate,
    required this.cancellationReminderEnabled,
    required this.cancellationReminderDaysBefore,
    required this.paymentReminderEnabled,
    required this.paymentReminderDaysBefore,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || merchantPattern != null) {
      map['merchant_pattern'] = Variable<String>(merchantPattern);
    }
    map['amount_minor'] = Variable<int>(amountMinor);
    map['billing_cycle'] = Variable<int>(billingCycle);
    map['payment_method'] = Variable<int>(paymentMethod);
    map['status'] = Variable<int>(status);
    map['start_date'] = Variable<DateTime>(startDate);
    map['next_renewal_date'] = Variable<DateTime>(nextRenewalDate);
    if (!nullToAbsent || trialEndDate != null) {
      map['trial_end_date'] = Variable<DateTime>(trialEndDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['cancellation_reminder_enabled'] = Variable<bool>(
      cancellationReminderEnabled,
    );
    map['cancellation_reminder_days_before'] = Variable<int>(
      cancellationReminderDaysBefore,
    );
    map['payment_reminder_enabled'] = Variable<bool>(paymentReminderEnabled);
    map['payment_reminder_days_before'] = Variable<int>(
      paymentReminderDaysBefore,
    );
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SubscriptionsCompanion toCompanion(bool nullToAbsent) {
    return SubscriptionsCompanion(
      id: Value(id),
      name: Value(name),
      merchantPattern: merchantPattern == null && nullToAbsent
          ? const Value.absent()
          : Value(merchantPattern),
      amountMinor: Value(amountMinor),
      billingCycle: Value(billingCycle),
      paymentMethod: Value(paymentMethod),
      status: Value(status),
      startDate: Value(startDate),
      nextRenewalDate: Value(nextRenewalDate),
      trialEndDate: trialEndDate == null && nullToAbsent
          ? const Value.absent()
          : Value(trialEndDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      cancellationReminderEnabled: Value(cancellationReminderEnabled),
      cancellationReminderDaysBefore: Value(cancellationReminderDaysBefore),
      paymentReminderEnabled: Value(paymentReminderEnabled),
      paymentReminderDaysBefore: Value(paymentReminderDaysBefore),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Subscription.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subscription(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      merchantPattern: serializer.fromJson<String?>(json['merchantPattern']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      billingCycle: serializer.fromJson<int>(json['billingCycle']),
      paymentMethod: serializer.fromJson<int>(json['paymentMethod']),
      status: serializer.fromJson<int>(json['status']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      nextRenewalDate: serializer.fromJson<DateTime>(json['nextRenewalDate']),
      trialEndDate: serializer.fromJson<DateTime?>(json['trialEndDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      cancellationReminderEnabled: serializer.fromJson<bool>(
        json['cancellationReminderEnabled'],
      ),
      cancellationReminderDaysBefore: serializer.fromJson<int>(
        json['cancellationReminderDaysBefore'],
      ),
      paymentReminderEnabled: serializer.fromJson<bool>(
        json['paymentReminderEnabled'],
      ),
      paymentReminderDaysBefore: serializer.fromJson<int>(
        json['paymentReminderDaysBefore'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'merchantPattern': serializer.toJson<String?>(merchantPattern),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'billingCycle': serializer.toJson<int>(billingCycle),
      'paymentMethod': serializer.toJson<int>(paymentMethod),
      'status': serializer.toJson<int>(status),
      'startDate': serializer.toJson<DateTime>(startDate),
      'nextRenewalDate': serializer.toJson<DateTime>(nextRenewalDate),
      'trialEndDate': serializer.toJson<DateTime?>(trialEndDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'cancellationReminderEnabled': serializer.toJson<bool>(
        cancellationReminderEnabled,
      ),
      'cancellationReminderDaysBefore': serializer.toJson<int>(
        cancellationReminderDaysBefore,
      ),
      'paymentReminderEnabled': serializer.toJson<bool>(paymentReminderEnabled),
      'paymentReminderDaysBefore': serializer.toJson<int>(
        paymentReminderDaysBefore,
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Subscription copyWith({
    int? id,
    String? name,
    Value<String?> merchantPattern = const Value.absent(),
    int? amountMinor,
    int? billingCycle,
    int? paymentMethod,
    int? status,
    DateTime? startDate,
    DateTime? nextRenewalDate,
    Value<DateTime?> trialEndDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    bool? cancellationReminderEnabled,
    int? cancellationReminderDaysBefore,
    bool? paymentReminderEnabled,
    int? paymentReminderDaysBefore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Subscription(
    id: id ?? this.id,
    name: name ?? this.name,
    merchantPattern: merchantPattern.present
        ? merchantPattern.value
        : this.merchantPattern,
    amountMinor: amountMinor ?? this.amountMinor,
    billingCycle: billingCycle ?? this.billingCycle,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    status: status ?? this.status,
    startDate: startDate ?? this.startDate,
    nextRenewalDate: nextRenewalDate ?? this.nextRenewalDate,
    trialEndDate: trialEndDate.present ? trialEndDate.value : this.trialEndDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    cancellationReminderEnabled:
        cancellationReminderEnabled ?? this.cancellationReminderEnabled,
    cancellationReminderDaysBefore:
        cancellationReminderDaysBefore ?? this.cancellationReminderDaysBefore,
    paymentReminderEnabled:
        paymentReminderEnabled ?? this.paymentReminderEnabled,
    paymentReminderDaysBefore:
        paymentReminderDaysBefore ?? this.paymentReminderDaysBefore,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Subscription copyWithCompanion(SubscriptionsCompanion data) {
    return Subscription(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      merchantPattern: data.merchantPattern.present
          ? data.merchantPattern.value
          : this.merchantPattern,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      billingCycle: data.billingCycle.present
          ? data.billingCycle.value
          : this.billingCycle,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      status: data.status.present ? data.status.value : this.status,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      nextRenewalDate: data.nextRenewalDate.present
          ? data.nextRenewalDate.value
          : this.nextRenewalDate,
      trialEndDate: data.trialEndDate.present
          ? data.trialEndDate.value
          : this.trialEndDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      cancellationReminderEnabled: data.cancellationReminderEnabled.present
          ? data.cancellationReminderEnabled.value
          : this.cancellationReminderEnabled,
      cancellationReminderDaysBefore:
          data.cancellationReminderDaysBefore.present
          ? data.cancellationReminderDaysBefore.value
          : this.cancellationReminderDaysBefore,
      paymentReminderEnabled: data.paymentReminderEnabled.present
          ? data.paymentReminderEnabled.value
          : this.paymentReminderEnabled,
      paymentReminderDaysBefore: data.paymentReminderDaysBefore.present
          ? data.paymentReminderDaysBefore.value
          : this.paymentReminderDaysBefore,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subscription(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('merchantPattern: $merchantPattern, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('billingCycle: $billingCycle, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('status: $status, ')
          ..write('startDate: $startDate, ')
          ..write('nextRenewalDate: $nextRenewalDate, ')
          ..write('trialEndDate: $trialEndDate, ')
          ..write('endDate: $endDate, ')
          ..write('cancellationReminderEnabled: $cancellationReminderEnabled, ')
          ..write(
            'cancellationReminderDaysBefore: $cancellationReminderDaysBefore, ',
          )
          ..write('paymentReminderEnabled: $paymentReminderEnabled, ')
          ..write('paymentReminderDaysBefore: $paymentReminderDaysBefore, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    merchantPattern,
    amountMinor,
    billingCycle,
    paymentMethod,
    status,
    startDate,
    nextRenewalDate,
    trialEndDate,
    endDate,
    cancellationReminderEnabled,
    cancellationReminderDaysBefore,
    paymentReminderEnabled,
    paymentReminderDaysBefore,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subscription &&
          other.id == this.id &&
          other.name == this.name &&
          other.merchantPattern == this.merchantPattern &&
          other.amountMinor == this.amountMinor &&
          other.billingCycle == this.billingCycle &&
          other.paymentMethod == this.paymentMethod &&
          other.status == this.status &&
          other.startDate == this.startDate &&
          other.nextRenewalDate == this.nextRenewalDate &&
          other.trialEndDate == this.trialEndDate &&
          other.endDate == this.endDate &&
          other.cancellationReminderEnabled ==
              this.cancellationReminderEnabled &&
          other.cancellationReminderDaysBefore ==
              this.cancellationReminderDaysBefore &&
          other.paymentReminderEnabled == this.paymentReminderEnabled &&
          other.paymentReminderDaysBefore == this.paymentReminderDaysBefore &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SubscriptionsCompanion extends UpdateCompanion<Subscription> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> merchantPattern;
  final Value<int> amountMinor;
  final Value<int> billingCycle;
  final Value<int> paymentMethod;
  final Value<int> status;
  final Value<DateTime> startDate;
  final Value<DateTime> nextRenewalDate;
  final Value<DateTime?> trialEndDate;
  final Value<DateTime?> endDate;
  final Value<bool> cancellationReminderEnabled;
  final Value<int> cancellationReminderDaysBefore;
  final Value<bool> paymentReminderEnabled;
  final Value<int> paymentReminderDaysBefore;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const SubscriptionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.merchantPattern = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.billingCycle = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.status = const Value.absent(),
    this.startDate = const Value.absent(),
    this.nextRenewalDate = const Value.absent(),
    this.trialEndDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.cancellationReminderEnabled = const Value.absent(),
    this.cancellationReminderDaysBefore = const Value.absent(),
    this.paymentReminderEnabled = const Value.absent(),
    this.paymentReminderDaysBefore = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SubscriptionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.merchantPattern = const Value.absent(),
    required int amountMinor,
    this.billingCycle = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime startDate,
    required DateTime nextRenewalDate,
    this.trialEndDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.cancellationReminderEnabled = const Value.absent(),
    this.cancellationReminderDaysBefore = const Value.absent(),
    this.paymentReminderEnabled = const Value.absent(),
    this.paymentReminderDaysBefore = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : name = Value(name),
       amountMinor = Value(amountMinor),
       startDate = Value(startDate),
       nextRenewalDate = Value(nextRenewalDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Subscription> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? merchantPattern,
    Expression<int>? amountMinor,
    Expression<int>? billingCycle,
    Expression<int>? paymentMethod,
    Expression<int>? status,
    Expression<DateTime>? startDate,
    Expression<DateTime>? nextRenewalDate,
    Expression<DateTime>? trialEndDate,
    Expression<DateTime>? endDate,
    Expression<bool>? cancellationReminderEnabled,
    Expression<int>? cancellationReminderDaysBefore,
    Expression<bool>? paymentReminderEnabled,
    Expression<int>? paymentReminderDaysBefore,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (merchantPattern != null) 'merchant_pattern': merchantPattern,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (billingCycle != null) 'billing_cycle': billingCycle,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (status != null) 'status': status,
      if (startDate != null) 'start_date': startDate,
      if (nextRenewalDate != null) 'next_renewal_date': nextRenewalDate,
      if (trialEndDate != null) 'trial_end_date': trialEndDate,
      if (endDate != null) 'end_date': endDate,
      if (cancellationReminderEnabled != null)
        'cancellation_reminder_enabled': cancellationReminderEnabled,
      if (cancellationReminderDaysBefore != null)
        'cancellation_reminder_days_before': cancellationReminderDaysBefore,
      if (paymentReminderEnabled != null)
        'payment_reminder_enabled': paymentReminderEnabled,
      if (paymentReminderDaysBefore != null)
        'payment_reminder_days_before': paymentReminderDaysBefore,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SubscriptionsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? merchantPattern,
    Value<int>? amountMinor,
    Value<int>? billingCycle,
    Value<int>? paymentMethod,
    Value<int>? status,
    Value<DateTime>? startDate,
    Value<DateTime>? nextRenewalDate,
    Value<DateTime?>? trialEndDate,
    Value<DateTime?>? endDate,
    Value<bool>? cancellationReminderEnabled,
    Value<int>? cancellationReminderDaysBefore,
    Value<bool>? paymentReminderEnabled,
    Value<int>? paymentReminderDaysBefore,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return SubscriptionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      merchantPattern: merchantPattern ?? this.merchantPattern,
      amountMinor: amountMinor ?? this.amountMinor,
      billingCycle: billingCycle ?? this.billingCycle,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      nextRenewalDate: nextRenewalDate ?? this.nextRenewalDate,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      endDate: endDate ?? this.endDate,
      cancellationReminderEnabled:
          cancellationReminderEnabled ?? this.cancellationReminderEnabled,
      cancellationReminderDaysBefore:
          cancellationReminderDaysBefore ?? this.cancellationReminderDaysBefore,
      paymentReminderEnabled:
          paymentReminderEnabled ?? this.paymentReminderEnabled,
      paymentReminderDaysBefore:
          paymentReminderDaysBefore ?? this.paymentReminderDaysBefore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (merchantPattern.present) {
      map['merchant_pattern'] = Variable<String>(merchantPattern.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (billingCycle.present) {
      map['billing_cycle'] = Variable<int>(billingCycle.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<int>(paymentMethod.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (nextRenewalDate.present) {
      map['next_renewal_date'] = Variable<DateTime>(nextRenewalDate.value);
    }
    if (trialEndDate.present) {
      map['trial_end_date'] = Variable<DateTime>(trialEndDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (cancellationReminderEnabled.present) {
      map['cancellation_reminder_enabled'] = Variable<bool>(
        cancellationReminderEnabled.value,
      );
    }
    if (cancellationReminderDaysBefore.present) {
      map['cancellation_reminder_days_before'] = Variable<int>(
        cancellationReminderDaysBefore.value,
      );
    }
    if (paymentReminderEnabled.present) {
      map['payment_reminder_enabled'] = Variable<bool>(
        paymentReminderEnabled.value,
      );
    }
    if (paymentReminderDaysBefore.present) {
      map['payment_reminder_days_before'] = Variable<int>(
        paymentReminderDaysBefore.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('merchantPattern: $merchantPattern, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('billingCycle: $billingCycle, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('status: $status, ')
          ..write('startDate: $startDate, ')
          ..write('nextRenewalDate: $nextRenewalDate, ')
          ..write('trialEndDate: $trialEndDate, ')
          ..write('endDate: $endDate, ')
          ..write('cancellationReminderEnabled: $cancellationReminderEnabled, ')
          ..write(
            'cancellationReminderDaysBefore: $cancellationReminderDaysBefore, ',
          )
          ..write('paymentReminderEnabled: $paymentReminderEnabled, ')
          ..write('paymentReminderDaysBefore: $paymentReminderDaysBefore, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ExpectedPaymentsTable extends ExpectedPayments
    with TableInfo<$ExpectedPaymentsTable, ExpectedPayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpectedPaymentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _subscriptionIdMeta = const VerificationMeta(
    'subscriptionId',
  );
  @override
  late final GeneratedColumn<int> subscriptionId = GeneratedColumn<int>(
    'subscription_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subscriptions (id)',
    ),
  );
  static const VerificationMeta _expectedDateMeta = const VerificationMeta(
    'expectedDate',
  );
  @override
  late final GeneratedColumn<DateTime> expectedDate = GeneratedColumn<DateTime>(
    'expected_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedAmountMinorMeta =
      const VerificationMeta('expectedAmountMinor');
  @override
  late final GeneratedColumn<int> expectedAmountMinor = GeneratedColumn<int>(
    'expected_amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _matchedExpenseIdMeta = const VerificationMeta(
    'matchedExpenseId',
  );
  @override
  late final GeneratedColumn<int> matchedExpenseId = GeneratedColumn<int>(
    'matched_expense_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES expenses (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    subscriptionId,
    expectedDate,
    expectedAmountMinor,
    status,
    matchedExpenseId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expected_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpectedPayment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('subscription_id')) {
      context.handle(
        _subscriptionIdMeta,
        subscriptionId.isAcceptableOrUnknown(
          data['subscription_id']!,
          _subscriptionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subscriptionIdMeta);
    }
    if (data.containsKey('expected_date')) {
      context.handle(
        _expectedDateMeta,
        expectedDate.isAcceptableOrUnknown(
          data['expected_date']!,
          _expectedDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expectedDateMeta);
    }
    if (data.containsKey('expected_amount_minor')) {
      context.handle(
        _expectedAmountMinorMeta,
        expectedAmountMinor.isAcceptableOrUnknown(
          data['expected_amount_minor']!,
          _expectedAmountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expectedAmountMinorMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('matched_expense_id')) {
      context.handle(
        _matchedExpenseIdMeta,
        matchedExpenseId.isAcceptableOrUnknown(
          data['matched_expense_id']!,
          _matchedExpenseIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpectedPayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpectedPayment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      subscriptionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subscription_id'],
      )!,
      expectedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expected_date'],
      )!,
      expectedAmountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_amount_minor'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      matchedExpenseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}matched_expense_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ExpectedPaymentsTable createAlias(String alias) {
    return $ExpectedPaymentsTable(attachedDatabase, alias);
  }
}

class ExpectedPayment extends DataClass implements Insertable<ExpectedPayment> {
  final int id;
  final int subscriptionId;
  final DateTime expectedDate;
  final int expectedAmountMinor;
  final int status;
  final int? matchedExpenseId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ExpectedPayment({
    required this.id,
    required this.subscriptionId,
    required this.expectedDate,
    required this.expectedAmountMinor,
    required this.status,
    this.matchedExpenseId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['subscription_id'] = Variable<int>(subscriptionId);
    map['expected_date'] = Variable<DateTime>(expectedDate);
    map['expected_amount_minor'] = Variable<int>(expectedAmountMinor);
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || matchedExpenseId != null) {
      map['matched_expense_id'] = Variable<int>(matchedExpenseId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ExpectedPaymentsCompanion toCompanion(bool nullToAbsent) {
    return ExpectedPaymentsCompanion(
      id: Value(id),
      subscriptionId: Value(subscriptionId),
      expectedDate: Value(expectedDate),
      expectedAmountMinor: Value(expectedAmountMinor),
      status: Value(status),
      matchedExpenseId: matchedExpenseId == null && nullToAbsent
          ? const Value.absent()
          : Value(matchedExpenseId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ExpectedPayment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpectedPayment(
      id: serializer.fromJson<int>(json['id']),
      subscriptionId: serializer.fromJson<int>(json['subscriptionId']),
      expectedDate: serializer.fromJson<DateTime>(json['expectedDate']),
      expectedAmountMinor: serializer.fromJson<int>(
        json['expectedAmountMinor'],
      ),
      status: serializer.fromJson<int>(json['status']),
      matchedExpenseId: serializer.fromJson<int?>(json['matchedExpenseId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'subscriptionId': serializer.toJson<int>(subscriptionId),
      'expectedDate': serializer.toJson<DateTime>(expectedDate),
      'expectedAmountMinor': serializer.toJson<int>(expectedAmountMinor),
      'status': serializer.toJson<int>(status),
      'matchedExpenseId': serializer.toJson<int?>(matchedExpenseId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ExpectedPayment copyWith({
    int? id,
    int? subscriptionId,
    DateTime? expectedDate,
    int? expectedAmountMinor,
    int? status,
    Value<int?> matchedExpenseId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ExpectedPayment(
    id: id ?? this.id,
    subscriptionId: subscriptionId ?? this.subscriptionId,
    expectedDate: expectedDate ?? this.expectedDate,
    expectedAmountMinor: expectedAmountMinor ?? this.expectedAmountMinor,
    status: status ?? this.status,
    matchedExpenseId: matchedExpenseId.present
        ? matchedExpenseId.value
        : this.matchedExpenseId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ExpectedPayment copyWithCompanion(ExpectedPaymentsCompanion data) {
    return ExpectedPayment(
      id: data.id.present ? data.id.value : this.id,
      subscriptionId: data.subscriptionId.present
          ? data.subscriptionId.value
          : this.subscriptionId,
      expectedDate: data.expectedDate.present
          ? data.expectedDate.value
          : this.expectedDate,
      expectedAmountMinor: data.expectedAmountMinor.present
          ? data.expectedAmountMinor.value
          : this.expectedAmountMinor,
      status: data.status.present ? data.status.value : this.status,
      matchedExpenseId: data.matchedExpenseId.present
          ? data.matchedExpenseId.value
          : this.matchedExpenseId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpectedPayment(')
          ..write('id: $id, ')
          ..write('subscriptionId: $subscriptionId, ')
          ..write('expectedDate: $expectedDate, ')
          ..write('expectedAmountMinor: $expectedAmountMinor, ')
          ..write('status: $status, ')
          ..write('matchedExpenseId: $matchedExpenseId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    subscriptionId,
    expectedDate,
    expectedAmountMinor,
    status,
    matchedExpenseId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpectedPayment &&
          other.id == this.id &&
          other.subscriptionId == this.subscriptionId &&
          other.expectedDate == this.expectedDate &&
          other.expectedAmountMinor == this.expectedAmountMinor &&
          other.status == this.status &&
          other.matchedExpenseId == this.matchedExpenseId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ExpectedPaymentsCompanion extends UpdateCompanion<ExpectedPayment> {
  final Value<int> id;
  final Value<int> subscriptionId;
  final Value<DateTime> expectedDate;
  final Value<int> expectedAmountMinor;
  final Value<int> status;
  final Value<int?> matchedExpenseId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ExpectedPaymentsCompanion({
    this.id = const Value.absent(),
    this.subscriptionId = const Value.absent(),
    this.expectedDate = const Value.absent(),
    this.expectedAmountMinor = const Value.absent(),
    this.status = const Value.absent(),
    this.matchedExpenseId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ExpectedPaymentsCompanion.insert({
    this.id = const Value.absent(),
    required int subscriptionId,
    required DateTime expectedDate,
    required int expectedAmountMinor,
    this.status = const Value.absent(),
    this.matchedExpenseId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : subscriptionId = Value(subscriptionId),
       expectedDate = Value(expectedDate),
       expectedAmountMinor = Value(expectedAmountMinor),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ExpectedPayment> custom({
    Expression<int>? id,
    Expression<int>? subscriptionId,
    Expression<DateTime>? expectedDate,
    Expression<int>? expectedAmountMinor,
    Expression<int>? status,
    Expression<int>? matchedExpenseId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subscriptionId != null) 'subscription_id': subscriptionId,
      if (expectedDate != null) 'expected_date': expectedDate,
      if (expectedAmountMinor != null)
        'expected_amount_minor': expectedAmountMinor,
      if (status != null) 'status': status,
      if (matchedExpenseId != null) 'matched_expense_id': matchedExpenseId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ExpectedPaymentsCompanion copyWith({
    Value<int>? id,
    Value<int>? subscriptionId,
    Value<DateTime>? expectedDate,
    Value<int>? expectedAmountMinor,
    Value<int>? status,
    Value<int?>? matchedExpenseId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ExpectedPaymentsCompanion(
      id: id ?? this.id,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      expectedDate: expectedDate ?? this.expectedDate,
      expectedAmountMinor: expectedAmountMinor ?? this.expectedAmountMinor,
      status: status ?? this.status,
      matchedExpenseId: matchedExpenseId ?? this.matchedExpenseId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (subscriptionId.present) {
      map['subscription_id'] = Variable<int>(subscriptionId.value);
    }
    if (expectedDate.present) {
      map['expected_date'] = Variable<DateTime>(expectedDate.value);
    }
    if (expectedAmountMinor.present) {
      map['expected_amount_minor'] = Variable<int>(expectedAmountMinor.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (matchedExpenseId.present) {
      map['matched_expense_id'] = Variable<int>(matchedExpenseId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpectedPaymentsCompanion(')
          ..write('id: $id, ')
          ..write('subscriptionId: $subscriptionId, ')
          ..write('expectedDate: $expectedDate, ')
          ..write('expectedAmountMinor: $expectedAmountMinor, ')
          ..write('status: $status, ')
          ..write('matchedExpenseId: $matchedExpenseId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$LumaDatabase extends GeneratedDatabase {
  _$LumaDatabase(QueryExecutor e) : super(e);
  $LumaDatabaseManager get managers => $LumaDatabaseManager(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $MerchantProfilesTable merchantProfiles = $MerchantProfilesTable(
    this,
  );
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $ExportRecordsTable exportRecords = $ExportRecordsTable(this);
  late final $SubscriptionsTable subscriptions = $SubscriptionsTable(this);
  late final $ExpectedPaymentsTable expectedPayments = $ExpectedPaymentsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    expenses,
    merchantProfiles,
    categories,
    appSettings,
    exportRecords,
    subscriptions,
    expectedPayments,
  ];
}

typedef $$ExpensesTableCreateCompanionBuilder =
    ExpensesCompanion Function({
      Value<int> id,
      required int amountMinor,
      Value<String?> merchant,
      Value<String?> categoryId,
      Value<String> note,
      Value<String?> referenceNumber,
      Value<String?> smsFingerprint,
      Value<String?> rawSms,
      required DateTime timestamp,
      Value<int> transactionType,
      Value<int> status,
      Value<int> source,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> lastExportedAt,
    });
typedef $$ExpensesTableUpdateCompanionBuilder =
    ExpensesCompanion Function({
      Value<int> id,
      Value<int> amountMinor,
      Value<String?> merchant,
      Value<String?> categoryId,
      Value<String> note,
      Value<String?> referenceNumber,
      Value<String?> smsFingerprint,
      Value<String?> rawSms,
      Value<DateTime> timestamp,
      Value<int> transactionType,
      Value<int> status,
      Value<int> source,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastExportedAt,
    });

final class $$ExpensesTableReferences
    extends BaseReferences<_$LumaDatabase, $ExpensesTable, Expense> {
  $$ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExpectedPaymentsTable, List<ExpectedPayment>>
  _expectedPaymentsRefsTable(_$LumaDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.expectedPayments,
        aliasName: $_aliasNameGenerator(
          db.expenses.id,
          db.expectedPayments.matchedExpenseId,
        ),
      );

  $$ExpectedPaymentsTableProcessedTableManager get expectedPaymentsRefs {
    final manager = $$ExpectedPaymentsTableTableManager(
      $_db,
      $_db.expectedPayments,
    ).filter((f) => f.matchedExpenseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _expectedPaymentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExpensesTableFilterComposer
    extends Composer<_$LumaDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
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

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get smsFingerprint => $composableBuilder(
    column: $table.smsFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawSms => $composableBuilder(
    column: $table.rawSms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastExportedAt => $composableBuilder(
    column: $table.lastExportedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> expectedPaymentsRefs(
    Expression<bool> Function($$ExpectedPaymentsTableFilterComposer f) f,
  ) {
    final $$ExpectedPaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expectedPayments,
      getReferencedColumn: (t) => t.matchedExpenseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpectedPaymentsTableFilterComposer(
            $db: $db,
            $table: $db.expectedPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$LumaDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
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

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get smsFingerprint => $composableBuilder(
    column: $table.smsFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawSms => $composableBuilder(
    column: $table.rawSms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastExportedAt => $composableBuilder(
    column: $table.lastExportedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$LumaDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get smsFingerprint => $composableBuilder(
    column: $table.smsFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawSms =>
      $composableBuilder(column: $table.rawSms, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastExportedAt => $composableBuilder(
    column: $table.lastExportedAt,
    builder: (column) => column,
  );

  Expression<T> expectedPaymentsRefs<T extends Object>(
    Expression<T> Function($$ExpectedPaymentsTableAnnotationComposer a) f,
  ) {
    final $$ExpectedPaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expectedPayments,
      getReferencedColumn: (t) => t.matchedExpenseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpectedPaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.expectedPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$LumaDatabase,
          $ExpensesTable,
          Expense,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (Expense, $$ExpensesTableReferences),
          Expense,
          PrefetchHooks Function({bool expectedPaymentsRefs})
        > {
  $$ExpensesTableTableManager(_$LumaDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String?> merchant = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String?> referenceNumber = const Value.absent(),
                Value<String?> smsFingerprint = const Value.absent(),
                Value<String?> rawSms = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> transactionType = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int> source = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastExportedAt = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                amountMinor: amountMinor,
                merchant: merchant,
                categoryId: categoryId,
                note: note,
                referenceNumber: referenceNumber,
                smsFingerprint: smsFingerprint,
                rawSms: rawSms,
                timestamp: timestamp,
                transactionType: transactionType,
                status: status,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastExportedAt: lastExportedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int amountMinor,
                Value<String?> merchant = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String?> referenceNumber = const Value.absent(),
                Value<String?> smsFingerprint = const Value.absent(),
                Value<String?> rawSms = const Value.absent(),
                required DateTime timestamp,
                Value<int> transactionType = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int> source = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> lastExportedAt = const Value.absent(),
              }) => ExpensesCompanion.insert(
                id: id,
                amountMinor: amountMinor,
                merchant: merchant,
                categoryId: categoryId,
                note: note,
                referenceNumber: referenceNumber,
                smsFingerprint: smsFingerprint,
                rawSms: rawSms,
                timestamp: timestamp,
                transactionType: transactionType,
                status: status,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastExportedAt: lastExportedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExpensesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({expectedPaymentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (expectedPaymentsRefs) db.expectedPayments,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (expectedPaymentsRefs)
                    await $_getPrefetchedData<
                      Expense,
                      $ExpensesTable,
                      ExpectedPayment
                    >(
                      currentTable: table,
                      referencedTable: $$ExpensesTableReferences
                          ._expectedPaymentsRefsTable(db),
                      managerFromTypedResult: (p0) => $$ExpensesTableReferences(
                        db,
                        table,
                        p0,
                      ).expectedPaymentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.matchedExpenseId == item.id,
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

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$LumaDatabase,
      $ExpensesTable,
      Expense,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (Expense, $$ExpensesTableReferences),
      Expense,
      PrefetchHooks Function({bool expectedPaymentsRefs})
    >;
typedef $$MerchantProfilesTableCreateCompanionBuilder =
    MerchantProfilesCompanion Function({
      required String normalizedMerchant,
      required String displayMerchant,
      Value<String> categoryCounts,
      Value<String?> lastUsedCategory,
      Value<int> totalTransactions,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MerchantProfilesTableUpdateCompanionBuilder =
    MerchantProfilesCompanion Function({
      Value<String> normalizedMerchant,
      Value<String> displayMerchant,
      Value<String> categoryCounts,
      Value<String?> lastUsedCategory,
      Value<int> totalTransactions,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$MerchantProfilesTableFilterComposer
    extends Composer<_$LumaDatabase, $MerchantProfilesTable> {
  $$MerchantProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get normalizedMerchant => $composableBuilder(
    column: $table.normalizedMerchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayMerchant => $composableBuilder(
    column: $table.displayMerchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryCounts => $composableBuilder(
    column: $table.categoryCounts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastUsedCategory => $composableBuilder(
    column: $table.lastUsedCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalTransactions => $composableBuilder(
    column: $table.totalTransactions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MerchantProfilesTableOrderingComposer
    extends Composer<_$LumaDatabase, $MerchantProfilesTable> {
  $$MerchantProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get normalizedMerchant => $composableBuilder(
    column: $table.normalizedMerchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayMerchant => $composableBuilder(
    column: $table.displayMerchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryCounts => $composableBuilder(
    column: $table.categoryCounts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastUsedCategory => $composableBuilder(
    column: $table.lastUsedCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalTransactions => $composableBuilder(
    column: $table.totalTransactions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MerchantProfilesTableAnnotationComposer
    extends Composer<_$LumaDatabase, $MerchantProfilesTable> {
  $$MerchantProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get normalizedMerchant => $composableBuilder(
    column: $table.normalizedMerchant,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayMerchant => $composableBuilder(
    column: $table.displayMerchant,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryCounts => $composableBuilder(
    column: $table.categoryCounts,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastUsedCategory => $composableBuilder(
    column: $table.lastUsedCategory,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalTransactions => $composableBuilder(
    column: $table.totalTransactions,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MerchantProfilesTableTableManager
    extends
        RootTableManager<
          _$LumaDatabase,
          $MerchantProfilesTable,
          MerchantProfile,
          $$MerchantProfilesTableFilterComposer,
          $$MerchantProfilesTableOrderingComposer,
          $$MerchantProfilesTableAnnotationComposer,
          $$MerchantProfilesTableCreateCompanionBuilder,
          $$MerchantProfilesTableUpdateCompanionBuilder,
          (
            MerchantProfile,
            BaseReferences<
              _$LumaDatabase,
              $MerchantProfilesTable,
              MerchantProfile
            >,
          ),
          MerchantProfile,
          PrefetchHooks Function()
        > {
  $$MerchantProfilesTableTableManager(
    _$LumaDatabase db,
    $MerchantProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MerchantProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MerchantProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MerchantProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> normalizedMerchant = const Value.absent(),
                Value<String> displayMerchant = const Value.absent(),
                Value<String> categoryCounts = const Value.absent(),
                Value<String?> lastUsedCategory = const Value.absent(),
                Value<int> totalTransactions = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MerchantProfilesCompanion(
                normalizedMerchant: normalizedMerchant,
                displayMerchant: displayMerchant,
                categoryCounts: categoryCounts,
                lastUsedCategory: lastUsedCategory,
                totalTransactions: totalTransactions,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String normalizedMerchant,
                required String displayMerchant,
                Value<String> categoryCounts = const Value.absent(),
                Value<String?> lastUsedCategory = const Value.absent(),
                Value<int> totalTransactions = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MerchantProfilesCompanion.insert(
                normalizedMerchant: normalizedMerchant,
                displayMerchant: displayMerchant,
                categoryCounts: categoryCounts,
                lastUsedCategory: lastUsedCategory,
                totalTransactions: totalTransactions,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MerchantProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$LumaDatabase,
      $MerchantProfilesTable,
      MerchantProfile,
      $$MerchantProfilesTableFilterComposer,
      $$MerchantProfilesTableOrderingComposer,
      $$MerchantProfilesTableAnnotationComposer,
      $$MerchantProfilesTableCreateCompanionBuilder,
      $$MerchantProfilesTableUpdateCompanionBuilder,
      (
        MerchantProfile,
        BaseReferences<_$LumaDatabase, $MerchantProfilesTable, MerchantProfile>,
      ),
      MerchantProfile,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String name,
      required String icon,
      required int sortOrder,
      Value<bool> isDefault,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> icon,
      Value<int> sortOrder,
      Value<bool> isDefault,
      Value<int> rowid,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$LumaDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
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

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$LumaDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$LumaDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
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

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$LumaDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (
            Category,
            BaseReferences<_$LumaDatabase, $CategoriesTable, Category>,
          ),
          Category,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$LumaDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                icon: icon,
                sortOrder: sortOrder,
                isDefault: isDefault,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String icon,
                required int sortOrder,
                Value<bool> isDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                icon: icon,
                sortOrder: sortOrder,
                isDefault: isDefault,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$LumaDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, BaseReferences<_$LumaDatabase, $CategoriesTable, Category>),
      Category,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<bool> dailyAuditEnabled,
      Value<int> auditHour,
      Value<int> auditMinute,
      Value<bool> onboardingDone,
      Value<String?> userName,
      Value<int> initialBalanceMinor,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<bool> dailyAuditEnabled,
      Value<int> auditHour,
      Value<int> auditMinute,
      Value<bool> onboardingDone,
      Value<String?> userName,
      Value<int> initialBalanceMinor,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$LumaDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
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

  ColumnFilters<bool> get dailyAuditEnabled => $composableBuilder(
    column: $table.dailyAuditEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get auditHour => $composableBuilder(
    column: $table.auditHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get auditMinute => $composableBuilder(
    column: $table.auditMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboardingDone => $composableBuilder(
    column: $table.onboardingDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get initialBalanceMinor => $composableBuilder(
    column: $table.initialBalanceMinor,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$LumaDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
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

  ColumnOrderings<bool> get dailyAuditEnabled => $composableBuilder(
    column: $table.dailyAuditEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get auditHour => $composableBuilder(
    column: $table.auditHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get auditMinute => $composableBuilder(
    column: $table.auditMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingDone => $composableBuilder(
    column: $table.onboardingDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get initialBalanceMinor => $composableBuilder(
    column: $table.initialBalanceMinor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$LumaDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get dailyAuditEnabled => $composableBuilder(
    column: $table.dailyAuditEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get auditHour =>
      $composableBuilder(column: $table.auditHour, builder: (column) => column);

  GeneratedColumn<int> get auditMinute => $composableBuilder(
    column: $table.auditMinute,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get onboardingDone => $composableBuilder(
    column: $table.onboardingDone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userName =>
      $composableBuilder(column: $table.userName, builder: (column) => column);

  GeneratedColumn<int> get initialBalanceMinor => $composableBuilder(
    column: $table.initialBalanceMinor,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$LumaDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$LumaDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$LumaDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> dailyAuditEnabled = const Value.absent(),
                Value<int> auditHour = const Value.absent(),
                Value<int> auditMinute = const Value.absent(),
                Value<bool> onboardingDone = const Value.absent(),
                Value<String?> userName = const Value.absent(),
                Value<int> initialBalanceMinor = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                dailyAuditEnabled: dailyAuditEnabled,
                auditHour: auditHour,
                auditMinute: auditMinute,
                onboardingDone: onboardingDone,
                userName: userName,
                initialBalanceMinor: initialBalanceMinor,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> dailyAuditEnabled = const Value.absent(),
                Value<int> auditHour = const Value.absent(),
                Value<int> auditMinute = const Value.absent(),
                Value<bool> onboardingDone = const Value.absent(),
                Value<String?> userName = const Value.absent(),
                Value<int> initialBalanceMinor = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                dailyAuditEnabled: dailyAuditEnabled,
                auditHour: auditHour,
                auditMinute: auditMinute,
                onboardingDone: onboardingDone,
                userName: userName,
                initialBalanceMinor: initialBalanceMinor,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$LumaDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$LumaDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$ExportRecordsTableCreateCompanionBuilder =
    ExportRecordsCompanion Function({
      Value<int> id,
      required String type,
      required DateTime createdAt,
      required String fileName,
      required int count,
    });
typedef $$ExportRecordsTableUpdateCompanionBuilder =
    ExportRecordsCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<DateTime> createdAt,
      Value<String> fileName,
      Value<int> count,
    });

class $$ExportRecordsTableFilterComposer
    extends Composer<_$LumaDatabase, $ExportRecordsTable> {
  $$ExportRecordsTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExportRecordsTableOrderingComposer
    extends Composer<_$LumaDatabase, $ExportRecordsTable> {
  $$ExportRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExportRecordsTableAnnotationComposer
    extends Composer<_$LumaDatabase, $ExportRecordsTable> {
  $$ExportRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);
}

class $$ExportRecordsTableTableManager
    extends
        RootTableManager<
          _$LumaDatabase,
          $ExportRecordsTable,
          ExportRecord,
          $$ExportRecordsTableFilterComposer,
          $$ExportRecordsTableOrderingComposer,
          $$ExportRecordsTableAnnotationComposer,
          $$ExportRecordsTableCreateCompanionBuilder,
          $$ExportRecordsTableUpdateCompanionBuilder,
          (
            ExportRecord,
            BaseReferences<_$LumaDatabase, $ExportRecordsTable, ExportRecord>,
          ),
          ExportRecord,
          PrefetchHooks Function()
        > {
  $$ExportRecordsTableTableManager(_$LumaDatabase db, $ExportRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExportRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExportRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExportRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<int> count = const Value.absent(),
              }) => ExportRecordsCompanion(
                id: id,
                type: type,
                createdAt: createdAt,
                fileName: fileName,
                count: count,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                required DateTime createdAt,
                required String fileName,
                required int count,
              }) => ExportRecordsCompanion.insert(
                id: id,
                type: type,
                createdAt: createdAt,
                fileName: fileName,
                count: count,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExportRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$LumaDatabase,
      $ExportRecordsTable,
      ExportRecord,
      $$ExportRecordsTableFilterComposer,
      $$ExportRecordsTableOrderingComposer,
      $$ExportRecordsTableAnnotationComposer,
      $$ExportRecordsTableCreateCompanionBuilder,
      $$ExportRecordsTableUpdateCompanionBuilder,
      (
        ExportRecord,
        BaseReferences<_$LumaDatabase, $ExportRecordsTable, ExportRecord>,
      ),
      ExportRecord,
      PrefetchHooks Function()
    >;
typedef $$SubscriptionsTableCreateCompanionBuilder =
    SubscriptionsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> merchantPattern,
      required int amountMinor,
      Value<int> billingCycle,
      Value<int> paymentMethod,
      Value<int> status,
      required DateTime startDate,
      required DateTime nextRenewalDate,
      Value<DateTime?> trialEndDate,
      Value<DateTime?> endDate,
      Value<bool> cancellationReminderEnabled,
      Value<int> cancellationReminderDaysBefore,
      Value<bool> paymentReminderEnabled,
      Value<int> paymentReminderDaysBefore,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$SubscriptionsTableUpdateCompanionBuilder =
    SubscriptionsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> merchantPattern,
      Value<int> amountMinor,
      Value<int> billingCycle,
      Value<int> paymentMethod,
      Value<int> status,
      Value<DateTime> startDate,
      Value<DateTime> nextRenewalDate,
      Value<DateTime?> trialEndDate,
      Value<DateTime?> endDate,
      Value<bool> cancellationReminderEnabled,
      Value<int> cancellationReminderDaysBefore,
      Value<bool> paymentReminderEnabled,
      Value<int> paymentReminderDaysBefore,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$SubscriptionsTableReferences
    extends BaseReferences<_$LumaDatabase, $SubscriptionsTable, Subscription> {
  $$SubscriptionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ExpectedPaymentsTable, List<ExpectedPayment>>
  _expectedPaymentsRefsTable(_$LumaDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.expectedPayments,
        aliasName: $_aliasNameGenerator(
          db.subscriptions.id,
          db.expectedPayments.subscriptionId,
        ),
      );

  $$ExpectedPaymentsTableProcessedTableManager get expectedPaymentsRefs {
    final manager = $$ExpectedPaymentsTableTableManager(
      $_db,
      $_db.expectedPayments,
    ).filter((f) => f.subscriptionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _expectedPaymentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SubscriptionsTableFilterComposer
    extends Composer<_$LumaDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchantPattern => $composableBuilder(
    column: $table.merchantPattern,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get billingCycle => $composableBuilder(
    column: $table.billingCycle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextRenewalDate => $composableBuilder(
    column: $table.nextRenewalDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get trialEndDate => $composableBuilder(
    column: $table.trialEndDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get cancellationReminderEnabled => $composableBuilder(
    column: $table.cancellationReminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cancellationReminderDaysBefore => $composableBuilder(
    column: $table.cancellationReminderDaysBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get paymentReminderEnabled => $composableBuilder(
    column: $table.paymentReminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paymentReminderDaysBefore => $composableBuilder(
    column: $table.paymentReminderDaysBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> expectedPaymentsRefs(
    Expression<bool> Function($$ExpectedPaymentsTableFilterComposer f) f,
  ) {
    final $$ExpectedPaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expectedPayments,
      getReferencedColumn: (t) => t.subscriptionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpectedPaymentsTableFilterComposer(
            $db: $db,
            $table: $db.expectedPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubscriptionsTableOrderingComposer
    extends Composer<_$LumaDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchantPattern => $composableBuilder(
    column: $table.merchantPattern,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get billingCycle => $composableBuilder(
    column: $table.billingCycle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextRenewalDate => $composableBuilder(
    column: $table.nextRenewalDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get trialEndDate => $composableBuilder(
    column: $table.trialEndDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get cancellationReminderEnabled => $composableBuilder(
    column: $table.cancellationReminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cancellationReminderDaysBefore => $composableBuilder(
    column: $table.cancellationReminderDaysBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get paymentReminderEnabled => $composableBuilder(
    column: $table.paymentReminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paymentReminderDaysBefore => $composableBuilder(
    column: $table.paymentReminderDaysBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubscriptionsTableAnnotationComposer
    extends Composer<_$LumaDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get merchantPattern => $composableBuilder(
    column: $table.merchantPattern,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get billingCycle => $composableBuilder(
    column: $table.billingCycle,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRenewalDate => $composableBuilder(
    column: $table.nextRenewalDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get trialEndDate => $composableBuilder(
    column: $table.trialEndDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get cancellationReminderEnabled => $composableBuilder(
    column: $table.cancellationReminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cancellationReminderDaysBefore => $composableBuilder(
    column: $table.cancellationReminderDaysBefore,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get paymentReminderEnabled => $composableBuilder(
    column: $table.paymentReminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paymentReminderDaysBefore => $composableBuilder(
    column: $table.paymentReminderDaysBefore,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> expectedPaymentsRefs<T extends Object>(
    Expression<T> Function($$ExpectedPaymentsTableAnnotationComposer a) f,
  ) {
    final $$ExpectedPaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expectedPayments,
      getReferencedColumn: (t) => t.subscriptionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpectedPaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.expectedPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubscriptionsTableTableManager
    extends
        RootTableManager<
          _$LumaDatabase,
          $SubscriptionsTable,
          Subscription,
          $$SubscriptionsTableFilterComposer,
          $$SubscriptionsTableOrderingComposer,
          $$SubscriptionsTableAnnotationComposer,
          $$SubscriptionsTableCreateCompanionBuilder,
          $$SubscriptionsTableUpdateCompanionBuilder,
          (Subscription, $$SubscriptionsTableReferences),
          Subscription,
          PrefetchHooks Function({bool expectedPaymentsRefs})
        > {
  $$SubscriptionsTableTableManager(_$LumaDatabase db, $SubscriptionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscriptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubscriptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubscriptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> merchantPattern = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<int> billingCycle = const Value.absent(),
                Value<int> paymentMethod = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime> nextRenewalDate = const Value.absent(),
                Value<DateTime?> trialEndDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> cancellationReminderEnabled = const Value.absent(),
                Value<int> cancellationReminderDaysBefore =
                    const Value.absent(),
                Value<bool> paymentReminderEnabled = const Value.absent(),
                Value<int> paymentReminderDaysBefore = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SubscriptionsCompanion(
                id: id,
                name: name,
                merchantPattern: merchantPattern,
                amountMinor: amountMinor,
                billingCycle: billingCycle,
                paymentMethod: paymentMethod,
                status: status,
                startDate: startDate,
                nextRenewalDate: nextRenewalDate,
                trialEndDate: trialEndDate,
                endDate: endDate,
                cancellationReminderEnabled: cancellationReminderEnabled,
                cancellationReminderDaysBefore: cancellationReminderDaysBefore,
                paymentReminderEnabled: paymentReminderEnabled,
                paymentReminderDaysBefore: paymentReminderDaysBefore,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> merchantPattern = const Value.absent(),
                required int amountMinor,
                Value<int> billingCycle = const Value.absent(),
                Value<int> paymentMethod = const Value.absent(),
                Value<int> status = const Value.absent(),
                required DateTime startDate,
                required DateTime nextRenewalDate,
                Value<DateTime?> trialEndDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> cancellationReminderEnabled = const Value.absent(),
                Value<int> cancellationReminderDaysBefore =
                    const Value.absent(),
                Value<bool> paymentReminderEnabled = const Value.absent(),
                Value<int> paymentReminderDaysBefore = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => SubscriptionsCompanion.insert(
                id: id,
                name: name,
                merchantPattern: merchantPattern,
                amountMinor: amountMinor,
                billingCycle: billingCycle,
                paymentMethod: paymentMethod,
                status: status,
                startDate: startDate,
                nextRenewalDate: nextRenewalDate,
                trialEndDate: trialEndDate,
                endDate: endDate,
                cancellationReminderEnabled: cancellationReminderEnabled,
                cancellationReminderDaysBefore: cancellationReminderDaysBefore,
                paymentReminderEnabled: paymentReminderEnabled,
                paymentReminderDaysBefore: paymentReminderDaysBefore,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SubscriptionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({expectedPaymentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (expectedPaymentsRefs) db.expectedPayments,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (expectedPaymentsRefs)
                    await $_getPrefetchedData<
                      Subscription,
                      $SubscriptionsTable,
                      ExpectedPayment
                    >(
                      currentTable: table,
                      referencedTable: $$SubscriptionsTableReferences
                          ._expectedPaymentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SubscriptionsTableReferences(
                            db,
                            table,
                            p0,
                          ).expectedPaymentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.subscriptionId == item.id,
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

typedef $$SubscriptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$LumaDatabase,
      $SubscriptionsTable,
      Subscription,
      $$SubscriptionsTableFilterComposer,
      $$SubscriptionsTableOrderingComposer,
      $$SubscriptionsTableAnnotationComposer,
      $$SubscriptionsTableCreateCompanionBuilder,
      $$SubscriptionsTableUpdateCompanionBuilder,
      (Subscription, $$SubscriptionsTableReferences),
      Subscription,
      PrefetchHooks Function({bool expectedPaymentsRefs})
    >;
typedef $$ExpectedPaymentsTableCreateCompanionBuilder =
    ExpectedPaymentsCompanion Function({
      Value<int> id,
      required int subscriptionId,
      required DateTime expectedDate,
      required int expectedAmountMinor,
      Value<int> status,
      Value<int?> matchedExpenseId,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$ExpectedPaymentsTableUpdateCompanionBuilder =
    ExpectedPaymentsCompanion Function({
      Value<int> id,
      Value<int> subscriptionId,
      Value<DateTime> expectedDate,
      Value<int> expectedAmountMinor,
      Value<int> status,
      Value<int?> matchedExpenseId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$ExpectedPaymentsTableReferences
    extends
        BaseReferences<
          _$LumaDatabase,
          $ExpectedPaymentsTable,
          ExpectedPayment
        > {
  $$ExpectedPaymentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SubscriptionsTable _subscriptionIdTable(_$LumaDatabase db) =>
      db.subscriptions.createAlias(
        $_aliasNameGenerator(
          db.expectedPayments.subscriptionId,
          db.subscriptions.id,
        ),
      );

  $$SubscriptionsTableProcessedTableManager get subscriptionId {
    final $_column = $_itemColumn<int>('subscription_id')!;

    final manager = $$SubscriptionsTableTableManager(
      $_db,
      $_db.subscriptions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subscriptionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExpensesTable _matchedExpenseIdTable(_$LumaDatabase db) =>
      db.expenses.createAlias(
        $_aliasNameGenerator(
          db.expectedPayments.matchedExpenseId,
          db.expenses.id,
        ),
      );

  $$ExpensesTableProcessedTableManager? get matchedExpenseId {
    final $_column = $_itemColumn<int>('matched_expense_id');
    if ($_column == null) return null;
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_matchedExpenseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExpectedPaymentsTableFilterComposer
    extends Composer<_$LumaDatabase, $ExpectedPaymentsTable> {
  $$ExpectedPaymentsTableFilterComposer({
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

  ColumnFilters<DateTime> get expectedDate => $composableBuilder(
    column: $table.expectedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedAmountMinor => $composableBuilder(
    column: $table.expectedAmountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SubscriptionsTableFilterComposer get subscriptionId {
    final $$SubscriptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subscriptionId,
      referencedTable: $db.subscriptions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscriptionsTableFilterComposer(
            $db: $db,
            $table: $db.subscriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExpensesTableFilterComposer get matchedExpenseId {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchedExpenseId,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpectedPaymentsTableOrderingComposer
    extends Composer<_$LumaDatabase, $ExpectedPaymentsTable> {
  $$ExpectedPaymentsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get expectedDate => $composableBuilder(
    column: $table.expectedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedAmountMinor => $composableBuilder(
    column: $table.expectedAmountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SubscriptionsTableOrderingComposer get subscriptionId {
    final $$SubscriptionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subscriptionId,
      referencedTable: $db.subscriptions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscriptionsTableOrderingComposer(
            $db: $db,
            $table: $db.subscriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExpensesTableOrderingComposer get matchedExpenseId {
    final $$ExpensesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchedExpenseId,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableOrderingComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpectedPaymentsTableAnnotationComposer
    extends Composer<_$LumaDatabase, $ExpectedPaymentsTable> {
  $$ExpectedPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get expectedDate => $composableBuilder(
    column: $table.expectedDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expectedAmountMinor => $composableBuilder(
    column: $table.expectedAmountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$SubscriptionsTableAnnotationComposer get subscriptionId {
    final $$SubscriptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subscriptionId,
      referencedTable: $db.subscriptions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscriptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.subscriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExpensesTableAnnotationComposer get matchedExpenseId {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchedExpenseId,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpectedPaymentsTableTableManager
    extends
        RootTableManager<
          _$LumaDatabase,
          $ExpectedPaymentsTable,
          ExpectedPayment,
          $$ExpectedPaymentsTableFilterComposer,
          $$ExpectedPaymentsTableOrderingComposer,
          $$ExpectedPaymentsTableAnnotationComposer,
          $$ExpectedPaymentsTableCreateCompanionBuilder,
          $$ExpectedPaymentsTableUpdateCompanionBuilder,
          (ExpectedPayment, $$ExpectedPaymentsTableReferences),
          ExpectedPayment,
          PrefetchHooks Function({bool subscriptionId, bool matchedExpenseId})
        > {
  $$ExpectedPaymentsTableTableManager(
    _$LumaDatabase db,
    $ExpectedPaymentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpectedPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpectedPaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpectedPaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> subscriptionId = const Value.absent(),
                Value<DateTime> expectedDate = const Value.absent(),
                Value<int> expectedAmountMinor = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int?> matchedExpenseId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ExpectedPaymentsCompanion(
                id: id,
                subscriptionId: subscriptionId,
                expectedDate: expectedDate,
                expectedAmountMinor: expectedAmountMinor,
                status: status,
                matchedExpenseId: matchedExpenseId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int subscriptionId,
                required DateTime expectedDate,
                required int expectedAmountMinor,
                Value<int> status = const Value.absent(),
                Value<int?> matchedExpenseId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => ExpectedPaymentsCompanion.insert(
                id: id,
                subscriptionId: subscriptionId,
                expectedDate: expectedDate,
                expectedAmountMinor: expectedAmountMinor,
                status: status,
                matchedExpenseId: matchedExpenseId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExpectedPaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({subscriptionId = false, matchedExpenseId = false}) {
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
                        if (subscriptionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.subscriptionId,
                                    referencedTable:
                                        $$ExpectedPaymentsTableReferences
                                            ._subscriptionIdTable(db),
                                    referencedColumn:
                                        $$ExpectedPaymentsTableReferences
                                            ._subscriptionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (matchedExpenseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.matchedExpenseId,
                                    referencedTable:
                                        $$ExpectedPaymentsTableReferences
                                            ._matchedExpenseIdTable(db),
                                    referencedColumn:
                                        $$ExpectedPaymentsTableReferences
                                            ._matchedExpenseIdTable(db)
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

typedef $$ExpectedPaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$LumaDatabase,
      $ExpectedPaymentsTable,
      ExpectedPayment,
      $$ExpectedPaymentsTableFilterComposer,
      $$ExpectedPaymentsTableOrderingComposer,
      $$ExpectedPaymentsTableAnnotationComposer,
      $$ExpectedPaymentsTableCreateCompanionBuilder,
      $$ExpectedPaymentsTableUpdateCompanionBuilder,
      (ExpectedPayment, $$ExpectedPaymentsTableReferences),
      ExpectedPayment,
      PrefetchHooks Function({bool subscriptionId, bool matchedExpenseId})
    >;

class $LumaDatabaseManager {
  final _$LumaDatabase _db;
  $LumaDatabaseManager(this._db);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$MerchantProfilesTableTableManager get merchantProfiles =>
      $$MerchantProfilesTableTableManager(_db, _db.merchantProfiles);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$ExportRecordsTableTableManager get exportRecords =>
      $$ExportRecordsTableTableManager(_db, _db.exportRecords);
  $$SubscriptionsTableTableManager get subscriptions =>
      $$SubscriptionsTableTableManager(_db, _db.subscriptions);
  $$ExpectedPaymentsTableTableManager get expectedPayments =>
      $$ExpectedPaymentsTableTableManager(_db, _db.expectedPayments);
}
