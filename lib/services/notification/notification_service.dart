import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../core/utils/format.dart';
import '../../domain/entities/expense.dart';

/// Local-only notification service (SPEC 17-19, PRD 10-11).
///
/// Channels:
/// - `expense_alerts` (High): new detected expense, payload = expense id.
/// - `daily_audit` (Default, reserved for Phase 5 exact 21:00 alarm).
/// - `pending_summary` (Low, ongoing): "N need attention" while pending exist.
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const expenseChannelId = 'expense_alerts';
  static const dailyAuditChannelId = 'daily_audit';
  static const pendingSummaryId = 9001;

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;
  void Function(String? payload)? onTap;

  Future<void> init({void Function(String? payload)? onTap}) async {
    this.onTap = onTap;
    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const settings = InitializationSettings(android: android);
      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (response) =>
            this.onTap?.call(response.payload),
      );
      const expenseChannel = AndroidNotificationChannel(
        expenseChannelId,
        'Expense alerts',
        description: 'New detected expense',
        importance: Importance.high,
      );
      const auditChannel = AndroidNotificationChannel(
        dailyAuditChannelId,
        'Daily audit',
        description: 'Daily pending-expense reminder',
        importance: Importance.defaultImportance,
      );
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(expenseChannel);
      await androidPlugin?.createNotificationChannel(auditChannel);
      await androidPlugin?.requestNotificationsPermission();
      _ready = true;
    } catch (_) {
      // Tests, desktop, or unavailable platform — stay silent no-op.
      _ready = false;
    }
  }

  bool get isReady => _ready;

  /// Returns the cold-start payload once (app launched from notification),
  /// then clears it. Null when not launched from a notification or when
  /// the plugin is unavailable (tests/desktop).
  Future<String?> consumeLaunchPayload() async {
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details == null || !details.didNotificationLaunchApp) return null;
      return details.notificationResponse?.payload;
    } catch (_) {
      return null;
    }
  }

  /// Payload is the local expense id string. Never throws — expense must
  /// remain stored even if notify fails (SPEC 38).
  Future<void> showExpenseDetected(Expense expense) async {
    if (!_ready) return;
    try {
      final merchant = (expense.merchant ?? '').trim();
      final body = merchant.isEmpty
          ? '${formatAmount(expense.amountMinor)} spent — tap to categorize'
          : '${formatAmount(expense.amountMinor)} spent at $merchant — tap to categorize';
      await _plugin.show(
        id: expense.id,
        title: 'Luma',
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            expenseChannelId,
            'Expense alerts',
            channelDescription: 'New detected expense',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: '${expense.id}',
      );
    } catch (_) {
      // Swallow: store already succeeded.
    }
  }

  Future<void> syncPendingSummary(int pendingCount) async {
    if (!_ready) return;
    try {
      if (pendingCount <= 0) {
        await _plugin.cancel(id: pendingSummaryId);
        return;
      }
      await _plugin.show(
        id: pendingSummaryId,
        title: 'Luma',
        body:
            '$pendingCount ${pendingCount == 1 ? 'expense needs' : 'expenses need'} attention',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            expenseChannelId,
            'Expense alerts',
            channelDescription: 'New detected expense',
            importance: Importance.low,
            priority: Priority.low,
            ongoing: true,
            autoCancel: false,
          ),
        ),
        payload: 'pending',
      );
    } catch (_) {
      // Best-effort only.
    }
  }

  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (_) {
      // Best-effort only.
    }
  }
}

final notificationService = NotificationService();
