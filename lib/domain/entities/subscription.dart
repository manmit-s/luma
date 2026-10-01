enum BillingCycle {
  monthly,
  yearly;

  String get label => switch (this) {
        BillingCycle.monthly => 'Monthly',
        BillingCycle.yearly => 'Yearly',
      };
}

enum PaymentMethod {
  autopay,
  manual;

  String get label => switch (this) {
        PaymentMethod.autopay => 'Autopay',
        PaymentMethod.manual => 'Manual',
      };
}

enum SubscriptionStatus {
  active,
  trial,
  cancelled,
  expired;

  String get label => switch (this) {
        SubscriptionStatus.active => 'Active',
        SubscriptionStatus.trial => 'Trial',
        SubscriptionStatus.cancelled => 'Cancelled',
        SubscriptionStatus.expired => 'Expired',
      };

  bool get isOngoing =>
      this == SubscriptionStatus.active || this == SubscriptionStatus.trial;
}

class Subscription {
  Subscription({
    required this.id,
    required this.name,
    this.merchantPattern,
    required this.amountMinor,
    this.billingCycle = BillingCycle.monthly,
    this.paymentMethod = PaymentMethod.autopay,
    this.status = SubscriptionStatus.active,
    required this.startDate,
    required this.nextRenewalDate,
    this.trialEndDate,
    this.endDate,
    this.cancellationReminderEnabled = false,
    this.cancellationReminderDaysBefore = 3,
    this.paymentReminderEnabled = false,
    this.paymentReminderDaysBefore = 1,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? startDate,
        updatedAt = updatedAt ?? startDate;

  final int id;
  final String name;
  final String? merchantPattern;
  final int amountMinor;
  final BillingCycle billingCycle;
  final PaymentMethod paymentMethod;
  final SubscriptionStatus status;
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

  bool get isMonthly => billingCycle == BillingCycle.monthly;
  bool get isYearly => billingCycle == BillingCycle.yearly;
  bool get isAutopay => paymentMethod == PaymentMethod.autopay;
  bool get isManual => paymentMethod == PaymentMethod.manual;
  bool get isActive => status == SubscriptionStatus.active;
  bool get isTrial => status == SubscriptionStatus.trial;
  bool get isCancelled => status == SubscriptionStatus.cancelled;
  bool get isExpired => status == SubscriptionStatus.expired;

  Subscription copyWith({
    int? id,
    String? name,
    String? merchantPattern,
    int? amountMinor,
    BillingCycle? billingCycle,
    PaymentMethod? paymentMethod,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? nextRenewalDate,
    DateTime? trialEndDate,
    DateTime? endDate,
    bool? cancellationReminderEnabled,
    int? cancellationReminderDaysBefore,
    bool? paymentReminderEnabled,
    int? paymentReminderDaysBefore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Subscription(
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
        cancellationReminderDaysBefore: cancellationReminderDaysBefore ??
            this.cancellationReminderDaysBefore,
        paymentReminderEnabled:
            paymentReminderEnabled ?? this.paymentReminderEnabled,
        paymentReminderDaysBefore:
            paymentReminderDaysBefore ?? this.paymentReminderDaysBefore,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
      );
}
