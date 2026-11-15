class InternalTransfer {
  const InternalTransfer({
    required this.id,
    required this.fromSourceId,
    required this.toSourceId,
    required this.amountMinor,
    required this.timestamp,
    this.note = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? timestamp,
        updatedAt = updatedAt ?? timestamp;

  final int id;
  final int fromSourceId;
  final int toSourceId;
  final int amountMinor;
  final DateTime timestamp;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  InternalTransfer copyWith({
    int? id,
    int? fromSourceId,
    int? toSourceId,
    int? amountMinor,
    DateTime? timestamp,
    String? note,
    DateTime? updatedAt,
  }) =>
      InternalTransfer(
        id: id ?? this.id,
        fromSourceId: fromSourceId ?? this.fromSourceId,
        toSourceId: toSourceId ?? this.toSourceId,
        amountMinor: amountMinor ?? this.amountMinor,
        timestamp: timestamp ?? this.timestamp,
        note: note ?? this.note,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
      );
}
