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

/// "Automatic transaction detection is disabled." banner (SPEC 39).
class SmsDisabledBanner extends ConsumerWidget {
  const SmsDisabledBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
        width: double.infinity,
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.sms_failed_outlined,
              color: AppColors.peach,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.md),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Automatic detection is disabled',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Allow SMS access to auto-catch expenses.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => requestSmsPermissionFlow(context, ref),
              child: const Text('Enable'),
            ),
          ],
        ),
      );
}
