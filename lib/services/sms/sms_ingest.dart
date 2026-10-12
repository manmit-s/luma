import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/entities/expense.dart';
import '../../domain/services/sms_transaction_parser.dart';
import '../notification/notification_service.dart';

const _smsChannel = MethodChannel('luma/sms');

/// Result of scanning SMS inbox.
class SmsScanResult {
  const SmsScanResult({
    required this.validParsed,
    required this.newlyCreated,
  });

  final int validParsed;
  final int newlyCreated;
}

/// Reads (without draining) how many receiver-queued SMS are still waiting.
/// Null off-device (tests/desktop) where the channel doesn't exist.
Future<int?> smsQueueSize() async {
  try {
    return await _smsChannel.invokeMethod<int>('smsQueueSize');
  } on MissingPluginException {
    return null;
  } catch (_) {
    return null;
  }
}

/// Best-effort jump to the OEM autostart/background-start screen.
/// Returns true when an OEM screen was opened, false when the device has no
/// known screen (caller should show manual steps instead).
Future<bool> openAutostartSettings() async {
  try {
    return await _smsChannel.invokeMethod<bool>('openAutostartSettings') ??
        false;
  } on MissingPluginException {
    return false;
  } catch (_) {
    return false;
  }
}

/// Pulls SMS queued by the native receiver into pending expenses.
///
/// Shared by launch, foreground-resume and the Settings "process now"
/// action. Returns the number of newly created pending expenses.
/// Duplicates are dropped by the repository's fingerprint/reference check.
Future<int> drainSmsQueue(WidgetRef ref) async {
  try {
    final controller = ref.read(expenseControllerProvider);
    final queued =
        await _smsChannel.invokeListMethod<String>('drainSmsQueue') ?? [];
    var created = 0;
    for (final message in queued) {
      final existingCount = controller.expenses.length;
      final expense = await controller.processSms(message);
      final wasNewlyCreated = controller.expenses.length > existingCount;
      if (wasNewlyCreated &&
          expense != null &&
          expense.status == ExpenseStatus.pending) {
        final subController = ref.read(subscriptionControllerProvider);
        final match = await subController.matchAndReconcile(expense);
        if (match.isHighConfidence && match.subscription != null) {
          await controller.complete(
            expense,
            categoryId: 'subscriptions',
            note: match.subscription!.name,
          );
        } else {
          await notificationService.showExpenseDetected(expense);
          created++;
        }
      }
    }
    return created;
  } on MissingPluginException {
    // Desktop and widget-test environments do not have the Android channel.
    return 0;
  }
}

/// Reads recent financial SMS directly from the phone's SMS inbox.
///
/// If [targetCount] is provided, scanning evaluates candidate SMS in reverse
/// chronological order (newest first) and stops once [targetCount] valid
/// debit/credit transaction SMS have been processed.
///
/// If [cutoffDate] is provided, scanning only processes eligible transactions
/// up to and including the local calendar day of [cutoffDate].
///
/// Requires SMS permission. Returns an [SmsScanResult] with count of valid
/// parsed transactions and newly created pending expenses.
Future<SmsScanResult> scanInboxSms(
  WidgetRef ref, {
  int limit = 50,
  int? targetCount,
  DateTime? cutoffDate,
}) async {
  try {
    final controller = ref.read(expenseControllerProvider);
    final parser = SmsTransactionParser();
    final queryLimit = targetCount != null
        ? (targetCount * 4).clamp(20, 200)
        : (cutoffDate != null ? 200 : limit);

    final endOfDay = cutoffDate != null
        ? DateTime(cutoffDate.year, cutoffDate.month, cutoffDate.day, 23, 59, 59, 999)
        : null;

    final rawList = await _smsChannel.invokeMethod<List<dynamic>>(
          'scanInboxSms',
          {
            'limit': queryLimit,
            if (endOfDay != null) 'beforeDate': endOfDay.millisecondsSinceEpoch,
          },
        ) ??
        [];

    var newlyCreated = 0;
    var validParsed = 0;
    for (final item in rawList) {
      if (targetCount != null && validParsed >= targetCount) {
        break;
      }

      final String message;
      final DateTime? receivedAt;
      if (item is Map) {
        message = item['body'] as String? ?? '';
        final dateVal = item['date'];
        final dateMs = dateVal is int
            ? dateVal
            : (dateVal is num ? dateVal.toInt() : null);
        receivedAt =
            dateMs != null ? DateTime.fromMillisecondsSinceEpoch(dateMs) : null;
      } else {
        message = item.toString();
        receivedAt = null;
      }

      if (message.isEmpty) continue;

      final parsed = parser.parse(message, receivedAt: receivedAt);
      if (parsed == null) {
        continue;
      }

      // Cutoff date filter: inclusive of messages on the selected day up to 23:59:59.999
      if (endOfDay != null) {
        final txTime = parsed.timestamp ?? receivedAt;
        if (txTime != null && txTime.isAfter(endOfDay)) {
          continue;
        }
      }

      validParsed++;
      final existingCount = controller.expenses.length;
      final expense =
          await controller.processSms(message, receivedAt: receivedAt);
      final wasNewlyCreated = controller.expenses.length > existingCount;
      if (wasNewlyCreated &&
          expense != null &&
          expense.status == ExpenseStatus.pending) {
        final subController = ref.read(subscriptionControllerProvider);
        final match = await subController.matchAndReconcile(expense);
        if (match.isHighConfidence && match.subscription != null) {
          await controller.complete(
            expense,
            categoryId: 'subscriptions',
            note: match.subscription!.name,
          );
        } else {
          newlyCreated++;
        }
      }
    }
    return SmsScanResult(
      validParsed: validParsed,
      newlyCreated: newlyCreated,
    );
  } on MissingPluginException {
    return const SmsScanResult(validParsed: 0, newlyCreated: 0);
  } catch (_) {
    return const SmsScanResult(validParsed: 0, newlyCreated: 0);
  }
}

