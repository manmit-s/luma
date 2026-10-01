enum ExpectedPaymentStatus {
  upcoming,
  matched,
  missed,
  cancelled;

  String get label => switch (this) {
        ExpectedPaymentStatus.upcoming => 'Upcoming',
        ExpectedPaymentStatus.matched => 'Matched',
        ExpectedPaymentStatus.missed => 'Missed',
        ExpectedPaymentStatus.cancelled => 'Cancelled',
      };
}

class ExpectedPayment {
  ExpectedPayment({
    required this.id,
    required this.subscriptionId,
    required this.expectedDate,
    required this.expectedAmountMinor,
    this.status = ExpectedPaymentStatus.upcoming,
    this.matchedExpenseId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? expectedDate,
        updatedAt = updatedAt ?? expectedDate;

  final int id;
  final int subscriptionId;
  final DateTime expectedDate;
  final int expectedAmountMinor;
  final ExpectedPaymentStatus status;
  final int? matchedExpenseId;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isUpcoming => status == ExpectedPaymentStatus.upcoming;
  bool get isMatched => status == ExpectedPaymentStatus.matched;
  bool get isMissed => status == ExpectedPaymentStatus.missed;
  bool get isCancelled => status == ExpectedPaymentStatus.cancelled;

  ExpectedPayment copyWith({
    int? id,
    int? subscriptionId,
    DateTime? expectedDate,
    int? expectedAmountMinor,
    ExpectedPaymentStatus? status,
    int? matchedExpenseId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      ExpectedPayment(
        id: id ?? this.id,
        subscriptionId: subscriptionId ?? this.subscriptionId,
        expectedDate: expectedDate ?? this.expectedDate,
        expectedAmountMinor: expectedAmountMinor ?? this.expectedAmountMinor,
        status: status ?? this.status,
        matchedExpenseId: matchedExpenseId ?? this.matchedExpenseId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
      );
}
