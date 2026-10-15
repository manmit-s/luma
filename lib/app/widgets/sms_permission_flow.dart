import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/permissions/sms_permission_service.dart';
import '../theme/app_theme.dart';
import 'onboarding_sheet.dart';

final smsPermissionServiceProvider = Provider<SmsPermissionService>(
  (ref) => SmsPermissionService(),
);

/// Shared SMS-permission request flow used by onboarding, Home banner and
/// Settings retry.
///
/// Returns true when detection is granted. Permanently-denied results open
/// the restricted-settings guidance (SPEC 40) and app settings.
Future<bool> requestSmsPermissionFlow(
  BuildContext context,
  WidgetRef ref,
) async {
  final service = ref.read(smsPermissionServiceProvider);
  final result = await service.request();
  if (!context.mounted) return result == SmsPermissionState.granted;
  switch (result) {
    case SmsPermissionState.granted:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Automatic detection is on.'),
        ),
      );
      return true;
    case SmsPermissionState.permanentlyDenied:
    case SmsPermissionState.restricted:
      await showRestrictedSettingsSheet(context);
      if (!context.mounted) return false;
      await service.openSettings();
      return false;
    case SmsPermissionState.denied:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Automatic detection is disabled. You can still add expenses manually.',
          ),
        ),
      );
      return false;
    case SmsPermissionState.unavailable:
      return false;
  }
}

/// Prominent disclosure dialog for runtime SMS permission (Google Play policy).
Future<bool> showSmsDisclosureDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      final palette = context.lumaPalette;
      return AlertDialog(
        title: const Text('SMS Permission Disclosure'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Luma reads incoming and recent transaction SMS messages (RECEIVE_SMS and READ_SMS) to automatically detect bank/UPI expenses, calculate running balance, and match subscriptions.',
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 16,
                  color: palette.primaryAccent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'All SMS processing happens 100% locally on the device in an offline database; Luma has no internet access and never uploads or shares SMS or financial data with any server or third party.',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}

/// "Automatic transaction detection is disabled." banner (SPEC 39).
class SmsDisabledBanner extends ConsumerWidget {
  const SmsDisabledBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.lumaPalette;
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.sms_failed_outlined,
            color: palette.primaryAccent,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Automatic detection is disabled',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  'Allow SMS access to auto-catch expenses.',
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              final proceed = await showSmsDisclosureDialog(context);
              if (proceed && context.mounted) {
                await requestSmsPermissionFlow(context, ref);
              }
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }
}
