enum ExpenseStatus { pending, completed, ignored }

enum TransactionType { debit, credit, unknown }

enum ExpenseSource { sms, manual }

class Expense {
  Expense({
    required this.id,
    required this.amountMinor,
    required this.merchant,
    required this.categoryId,
    required this.timestamp,
    required this.status,
    required this.transactionType,
    required this.source,
    this.note = '',
    this.referenceNumber,
    this.smsFingerprint,
    this.rawSms,
    this.lastExportedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? timestamp,
        updatedAt = updatedAt ?? timestamp;

  final int id;
  int amountMinor;
  String? merchant;
  String? categoryId;
  String note;
  String? referenceNumber;
  String? smsFingerprint;
  DateTime timestamp;
  TransactionType transactionType;
  ExpenseStatus status;
  String? rawSms;
  ExpenseSource source;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? lastExportedAt;

  bool get isPending => status == ExpenseStatus.pending;
  bool get isDebit => transactionType == TransactionType.debit;

  Expense copyWith({
    int? amountMinor,
    String? merchant,
    String? categoryId,
    String? note,
    DateTime? timestamp,
    TransactionType? transactionType,
    ExpenseStatus? status,
    DateTime? updatedAt,
  }) => Expense(
    id: id,
    amountMinor: amountMinor ?? this.amountMinor,
    merchant: merchant ?? this.merchant,
    categoryId: categoryId ?? this.categoryId,
    note: note ?? this.note,
    timestamp: timestamp ?? this.timestamp,
    transactionType: transactionType ?? this.transactionType,
    status: status ?? this.status,
    referenceNumber: referenceNumber,
    smsFingerprint: smsFingerprint,
    rawSms: rawSms,
    source: source,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
    lastExportedAt: lastExportedAt,
  );
}
