import '../../core/utils/format.dart';
import '../../services/notification/notification_service.dart';
import '../entities/subscription.dart';
import 'subscription_calculator.dart';

class SubscriptionScheduler {
  SubscriptionScheduler({NotificationService? notifications})
      : _notifications = notifications ?? notificationService;

  final NotificationService _notifications;

  static int cancellationReminderId(int subscriptionId) =>
      subscriptionId * 10 + 1;
  static int paymentReminderId(int subscriptionId) => subscriptionId * 10 + 2;

  /// Returns the date when the cancellation reminder should fire.
  static DateTime? cancellationReminderDate(Subscription subscription) {
    if (!subscription.cancellationReminderEnabled) return null;
    return subscription.nextRenewalDate.subtract(
      Duration(days: subscription.cancellationReminderDaysBefore),
    );
  }

  /// Returns the date when the payment reminder should fire.
  static DateTime? paymentReminderDate(Subscription subscription) {
    if (!subscription.paymentReminderEnabled) return null;
    return subscription.nextRenewalDate.subtract(
      Duration(days: subscription.paymentReminderDaysBefore),
    );
  }

  /// Cancellation reminder message per SPEC.
  static String cancellationReminderMessage(Subscription subscription) {
    final days = subscription.cancellationReminderDaysBefore;
    final dateStr = formatDayLabel(subscription.nextRenewalDate);
    final amountStr = formatAmount(subscription.amountMinor);
    if (subscription.isAutopay) {
      return '${subscription.name} renews in $days days. $amountStr will be charged on $dateStr. Autopay is enabled. Review subscription.';
    } else {
      return '${subscription.name} renews in $days days. $amountStr is due on $dateStr.';
    }
  }

  /// Payment reminder message per SPEC.
  static String paymentReminderMessage(Subscription subscription) {
    final amountStr = formatAmount(subscription.amountMinor);
    if (subscription.isAutopay) {
      return 'Expected payment tomorrow ($amountStr).';
    } else {
      return '${subscription.name} renews tomorrow. $amountStr payment is due.';
    }
  }

  /// Checks if any reminders are due today for [subscriptions] and displays them.
  Future<int> checkAndFireDueReminders(
    List<Subscription> subscriptions, {
    DateTime? now,
  }) async {
    final today = now ?? DateTime.now();
    var fired = 0;

    for (final sub in subscriptions) {
      if (!sub.status.isOngoing) continue;

      // Cancellation reminder check
      if (sub.cancellationReminderEnabled) {
        final remDate = cancellationReminderDate(sub);
        if (remDate != null && SubscriptionDateUtils.isSameDay(remDate, today)) {
          await _notifications.showSubscriptionReminder(
            id: cancellationReminderId(sub.id),
            title: sub.name,
            body: cancellationReminderMessage(sub),
          );
          fired++;
        }
      }

      // Payment reminder check
      if (sub.paymentReminderEnabled) {
        final payDate = paymentReminderDate(sub);
        if (payDate != null && SubscriptionDateUtils.isSameDay(payDate, today)) {
          await _notifications.showSubscriptionReminder(
            id: paymentReminderId(sub.id),
            title: sub.name,
            body: paymentReminderMessage(sub),
          );
          fired++;
        }
      }
    }
    return fired;
  }

  /// Cancels all scheduled reminders for [subscriptionId].
  Future<void> cancelReminders(int subscriptionId) async {
    await _notifications.cancelSubscriptionReminders(subscriptionId);
  }
}
