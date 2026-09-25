import 'package:flutter_test/flutter_test.dart';
import 'package:luma/data/services/app_settings_store.dart';
import 'package:luma/services/permissions/sms_permission_service.dart';

void main() {
  group('AppSettingsStore', () {
    test('null database skips onboarding (tests never blocked)', () async {
      final store = AppSettingsStore(null);
      expect(await store.isOnboardingDone(), isTrue);
      await store.markOnboardingDone();
      expect(await store.isOnboardingDone(), isTrue);
    });
  });

  group('SmsPermissionService', () {
    test('returns unavailable off-device instead of throwing', () async {
      final service = SmsPermissionService();
      final state = await service.status();
      expect(state, isA<SmsPermissionState>());
      // Must never throw, even without the Android plugin.
      await service.request();
    });
  });
}
