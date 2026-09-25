import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'luma_buttons.dart';

/// First-launch rationale sheet (SPEC 8, 39).
///
/// Returns true when onboarding is complete (either path) so callers can
/// persist `onboardingDone`.
Future<bool> showOnboardingSheet(
  BuildContext context, {
  required Future<bool> Function() onEnableDetection,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    builder: (context) => SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.plum,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.sms_outlined,
                color: AppColors.peach,
                size: 24,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Never miss an expense',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 24,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Luma reads incoming transaction SMS messages so it can automatically detect expenses and remind you to record them.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Row(
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Everything stays on this device. Nothing is uploaded.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: _EnableButton(onEnableDetection: onEnableDetection),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Continue manually'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

class _EnableButton extends StatefulWidget {
  const _EnableButton({required this.onEnableDetection});

  final Future<bool> Function() onEnableDetection;

  @override
  State<_EnableButton> createState() => _EnableButtonState();
}

class _EnableButtonState extends State<_EnableButton> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) => PrimaryButton(
        label: _busy ? 'Requesting…' : 'Enable detection',
        icon: Icons.sms_outlined,
        onPressed: _busy
            ? null
            : () async {
                setState(() => _busy = true);
                try {
                  final granted = await widget.onEnableDetection();
                  if (!context.mounted) return;
                  if (granted) {
                    Navigator.pop(context, true);
                  }
                } finally {
                  if (mounted) setState(() => _busy = false);
                }
              },
      );
}

/// Sideloaded-app restricted-settings guidance (SPEC 40).
Future<void> showRestrictedSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Allow restricted settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Android blocks SMS access for sideloaded apps until you allow it. Luma cannot bypass this — it takes about 20 seconds.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            const _Step(
              number: '1',
              text: 'Open Android Settings → Apps → Luma.',
            ),
            const _Step(
              number: '2',
              text: 'Tap the ⋮ menu → Allow restricted settings.',
            ),
            const _Step(
              number: '3',
              text: 'Come back here and tap Enable detection again.',
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Done',
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.plum,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                number,
                style: const TextStyle(
                  color: AppColors.peach,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      );
}
