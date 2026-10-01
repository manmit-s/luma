import 'package:drift/drift.dart';

import '../../domain/entities/subscription.dart' as domain;
import '../../domain/repositories/subscription_repository.dart';
import '../database/luma_database.dart' as store;

int _cycleToInt(domain.BillingCycle c) => switch (c) {
      domain.BillingCycle.monthly => 0,
      domain.BillingCycle.yearly => 1,
    };

domain.BillingCycle _cycleFromInt(int v) => switch (v) {
      1 => domain.BillingCycle.yearly,
      _ => domain.BillingCycle.monthly,
    };

int _methodToInt(domain.PaymentMethod m) => switch (m) {
      domain.PaymentMethod.autopay => 0,
      domain.PaymentMethod.manual => 1,
    };

domain.PaymentMethod _methodFromInt(int v) => switch (v) {
      1 => domain.PaymentMethod.manual,
      _ => domain.PaymentMethod.autopay,
    };

int _statusToInt(domain.SubscriptionStatus s) => switch (s) {
      domain.SubscriptionStatus.active => 0,
      domain.SubscriptionStatus.trial => 1,
      domain.SubscriptionStatus.cancelled => 2,
      domain.SubscriptionStatus.expired => 3,
    };

domain.SubscriptionStatus _statusFromInt(int v) => switch (v) {
      1 => domain.SubscriptionStatus.trial,
      2 => domain.SubscriptionStatus.cancelled,
      3 => domain.SubscriptionStatus.expired,
      _ => domain.SubscriptionStatus.active,
    };

domain.Subscription _toEntity(store.Subscription row) => domain.Subscription(
      id: row.id,
      name: row.name,
      merchantPattern: row.merchantPattern,
      amountMinor: row.amountMinor,
      billingCycle: _cycleFromInt(row.billingCycle),
      paymentMethod: _methodFromInt(row.paymentMethod),
      status: _statusFromInt(row.status),
      startDate: row.startDate,
      nextRenewalDate: row.nextRenewalDate,
      trialEndDate: row.trialEndDate,
      endDate: row.endDate,
      cancellationReminderEnabled: row.cancellationReminderEnabled,
      cancellationReminderDaysBefore: row.cancellationReminderDaysBefore,
      paymentReminderEnabled: row.paymentReminderEnabled,
      paymentReminderDaysBefore: row.paymentReminderDaysBefore,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );

class DriftSubscriptionRepository implements SubscriptionRepository {
  DriftSubscriptionRepository(this.database);

  final store.LumaDatabase database;

  @override
  Future<List<domain.Subscription>> getAll() async {
    final rows = await (database.select(database.subscriptions)
          ..orderBy([(t) => OrderingTerm.asc(t.nextRenewalDate)]))
        .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<List<domain.Subscription>> getActive() async {
    final rows = await (database.select(database.subscriptions)
          ..where((t) => t.status.isIn([0, 1]))
          ..orderBy([(t) => OrderingTerm.asc(t.nextRenewalDate)]))
        .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<domain.Subscription?> findById(int id) async {
    final query = database.select(database.subscriptions)
      ..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<domain.Subscription> save(domain.Subscription subscription) async {
    if (subscription.id == 0) {
      final companion = store.SubscriptionsCompanion.insert(
        name: subscription.name,
        merchantPattern: Value(subscription.merchantPattern),
        amountMinor: subscription.amountMinor,
        billingCycle: Value(_cycleToInt(subscription.billingCycle)),
        paymentMethod: Value(_methodToInt(subscription.paymentMethod)),
        status: Value(_statusToInt(subscription.status)),
        startDate: subscription.startDate,
        nextRenewalDate: subscription.nextRenewalDate,
        trialEndDate: Value(subscription.trialEndDate),
        endDate: Value(subscription.endDate),
        cancellationReminderEnabled:
            Value(subscription.cancellationReminderEnabled),
        cancellationReminderDaysBefore:
            Value(subscription.cancellationReminderDaysBefore),
        paymentReminderEnabled: Value(subscription.paymentReminderEnabled),
        paymentReminderDaysBefore:
            Value(subscription.paymentReminderDaysBefore),
        createdAt: subscription.createdAt,
        updatedAt: subscription.updatedAt,
      );
      final id = await database.into(database.subscriptions).insert(companion);
      return subscription.copyWith(id: id);
    } else {
      final companion = store.SubscriptionsCompanion(
        id: Value(subscription.id),
        name: Value(subscription.name),
        merchantPattern: Value(subscription.merchantPattern),
        amountMinor: Value(subscription.amountMinor),
        billingCycle: Value(_cycleToInt(subscription.billingCycle)),
        paymentMethod: Value(_methodToInt(subscription.paymentMethod)),
        status: Value(_statusToInt(subscription.status)),
        startDate: Value(subscription.startDate),
        nextRenewalDate: Value(subscription.nextRenewalDate),
        trialEndDate: Value(subscription.trialEndDate),
        endDate: Value(subscription.endDate),
        cancellationReminderEnabled:
            Value(subscription.cancellationReminderEnabled),
        cancellationReminderDaysBefore:
            Value(subscription.cancellationReminderDaysBefore),
        paymentReminderEnabled: Value(subscription.paymentReminderEnabled),
        paymentReminderDaysBefore:
            Value(subscription.paymentReminderDaysBefore),
        createdAt: Value(subscription.createdAt),
        updatedAt: Value(subscription.updatedAt),
      );
      await database.update(database.subscriptions).replace(companion);
      return subscription;
    }
  }

  @override
  Future<void> delete(int id) async {
    await (database.delete(database.subscriptions)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  @override
  Future<void> clearAll() async {
    await database.delete(database.subscriptions).go();
  }
}
