import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/entities/expense.dart';
import '../notification/notification_service.dart';

const _smsChannel = MethodChannel('luma/sms');

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
        await notificationService.showExpenseDetected(expense);
        created++;
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
/// Requires SMS permission. Returns the number of newly created pending expenses.
Future<int> scanInboxSms(WidgetRef ref, {int limit = 50}) async {
  try {
    final controller = ref.read(expenseControllerProvider);
    final messages = await _smsChannel.invokeListMethod<String>(
          'scanInboxSms',
          {'limit': limit},
        ) ??
        [];
    var created = 0;
    for (final message in messages) {
      final existingCount = controller.expenses.length;
      final expense = await controller.processSms(message);
      final wasNewlyCreated = controller.expenses.length > existingCount;
      if (wasNewlyCreated &&
          expense != null &&
          expense.status == ExpenseStatus.pending) {
        created++;
      }
    }
    return created;
  } on MissingPluginException {
    return 0;
  } catch (_) {
    return 0;
  }
}
