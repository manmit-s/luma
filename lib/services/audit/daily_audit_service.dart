import 'package:flutter/services.dart';

/// Dart bridge to the native exact daily audit (SPEC 42).
///
/// Scheduling, firing, counting and boot-reschedule all live in
/// `DailyAudit.kt`; this class only forwards the toggle/time and exposes a
/// pure next-fire-time helper for tests. All channel calls are best-effort:
/// audit must never crash the app (SPEC 38).
class DailyAuditService {
  DailyAuditService({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('luma/sms');

  final MethodChannel _channel;

  Future<void> schedule(int hour, int minute) async {
    try {
      await _channel.invokeMethod<void>(
        'scheduleAudit',
        {'hour': hour, 'minute': minute},
      );
    } on MissingPluginException {
      // Desktop/tests: no Android channel.
    } catch (_) {
      // Best effort only.
    }
  }

  Future<void> cancel() async {
    try {
      await _channel.invokeMethod<void>('cancelAudit');
    } on MissingPluginException {
      // Desktop/tests: no Android channel.
    } catch (_) {
      // Best effort only.
    }
  }

  /// Next 21:00-style fire strictly after [from]. Pure — unit tested.
  static DateTime nextAuditTime(DateTime from, int hour, int minute) {
    final candidate = DateTime(from.year, from.month, from.day, hour, minute);
    if (!candidate.isAfter(from)) {
      return candidate.add(const Duration(days: 1));
    }
    return candidate;
  }
}
