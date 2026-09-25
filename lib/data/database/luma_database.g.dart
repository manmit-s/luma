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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dailyAuditEnabled,
    auditHour,
    auditMinute,
    onboardingDone,
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
  const AppSetting({
    required this.id,
    required this.dailyAuditEnabled,
    required this.auditHour,
    required this.auditMinute,
    required this.onboardingDone,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['daily_audit_enabled'] = Variable<bool>(dailyAuditEnabled);
    map['audit_hour'] = Variable<int>(auditHour);
    map['audit_minute'] = Variable<int>(auditMinute);
    map['onboarding_done'] = Variable<bool>(onboardingDone);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      dailyAuditEnabled: Value(dailyAuditEnabled),
      auditHour: Value(auditHour),
      auditMinute: Value(auditMinute),
      onboardingDone: Value(onboardingDone),
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
    };
  }

  AppSetting copyWith({
    int? id,
    bool? dailyAuditEnabled,
    int? auditHour,
    int? auditMinute,
    bool? onboardingDone,
  }) => AppSetting(
    id: id ?? this.id,
    dailyAuditEnabled: dailyAuditEnabled ?? this.dailyAuditEnabled,
    auditHour: auditHour ?? this.auditHour,
    auditMinute: auditMinute ?? this.auditMinute,
    onboardingDone: onboardingDone ?? this.onboardingDone,
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
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('dailyAuditEnabled: $dailyAuditEnabled, ')
          ..write('auditHour: $auditHour, ')
          ..write('auditMinute: $auditMinute, ')
          ..write('onboardingDone: $onboardingDone')
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
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.dailyAuditEnabled == this.dailyAuditEnabled &&
          other.auditHour == this.auditHour &&
          other.auditMinute == this.auditMinute &&
          other.onboardingDone == this.onboardingDone);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<bool> dailyAuditEnabled;
  final Value<int> auditHour;
  final Value<int> auditMinute;
  final Value<bool> onboardingDone;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.dailyAuditEnabled = const Value.absent(),
    this.auditHour = const Value.absent(),
    this.auditMinute = const Value.absent(),
    this.onboardingDone = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.dailyAuditEnabled = const Value.absent(),
    this.auditHour = const Value.absent(),
    this.auditMinute = const Value.absent(),
    this.onboardingDone = const Value.absent(),
  });
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<bool>? dailyAuditEnabled,
    Expression<int>? auditHour,
    Expression<int>? auditMinute,
    Expression<bool>? onboardingDone,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dailyAuditEnabled != null) 'daily_audit_enabled': dailyAuditEnabled,
      if (auditHour != null) 'audit_hour': auditHour,
      if (auditMinute != null) 'audit_minute': auditMinute,
      if (onboardingDone != null) 'onboarding_done': onboardingDone,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<bool>? dailyAuditEnabled,
    Value<int>? auditHour,
    Value<int>? auditMinute,
    Value<bool>? onboardingDone,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      dailyAuditEnabled: dailyAuditEnabled ?? this.dailyAuditEnabled,
      auditHour: auditHour ?? this.auditHour,
      auditMinute: auditMinute ?? this.auditMinute,
      onboardingDone: onboardingDone ?? this.onboardingDone,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('dailyAuditEnabled: $dailyAuditEnabled, ')
          ..write('auditHour: $auditHour, ')
          ..write('auditMinute: $auditMinute, ')
          ..write('onboardingDone: $onboardingDone')
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
          (Expense, BaseReferences<_$LumaDatabase, $ExpensesTable, Expense>),
          Expense,
          PrefetchHooks Function()
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
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (Expense, BaseReferences<_$LumaDatabase, $ExpensesTable, Expense>),
      Expense,
      PrefetchHooks Function()
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
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<bool> dailyAuditEnabled,
      Value<int> auditHour,
      Value<int> auditMinute,
      Value<bool> onboardingDone,
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
              }) => AppSettingsCompanion(
                id: id,
                dailyAuditEnabled: dailyAuditEnabled,
                auditHour: auditHour,
                auditMinute: auditMinute,
                onboardingDone: onboardingDone,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> dailyAuditEnabled = const Value.absent(),
                Value<int> auditHour = const Value.absent(),
                Value<int> auditMinute = const Value.absent(),
                Value<bool> onboardingDone = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                dailyAuditEnabled: dailyAuditEnabled,
                auditHour: auditHour,
                auditMinute: auditMinute,
                onboardingDone: onboardingDone,
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
}
