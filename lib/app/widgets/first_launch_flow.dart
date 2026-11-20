import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/external_links.dart';
import 'luma_buttons.dart';

/// Serene, first-launch onboarding flow for Luma.
///
/// Flow:
/// 1. Welcome ("Remember where your money went.")
/// 2. Preferred Name ("What should Luma call you?")
/// 3. Setup ("Choose how to get started" — Import from backup or Proceed)
class FirstLaunchFlow extends StatefulWidget {
  const FirstLaunchFlow({
    super.key,
    required this.onComplete,
    this.onImportBackup,
  });

  final Future<void> Function(String name, int initialBalanceMinor) onComplete;
  final Future<bool> Function(BuildContext context)? onImportBackup;

  @override
  State<FirstLaunchFlow> createState() => _FirstLaunchFlowState();
}

class _FirstLaunchFlowState extends State<FirstLaunchFlow> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();

  int _currentPage = 0;
  bool _isSubmitting = false;
  bool _consentAccepted = false;

  late final TapGestureRecognizer _privacyRecognizer;
  late final TapGestureRecognizer _termsRecognizer;

  @override
  void initState() {
    super.initState();
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () {
        ExternalLinks.openUrl(context, ExternalLinks.privacyPolicyUrl);
      };
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () {
        ExternalLinks.openUrl(context, ExternalLinks.termsUrl);
      };
    _nameController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _privacyRecognizer.dispose();
    _termsRecognizer.dispose();
    _pageController.dispose();
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  void _nextPage() {
    if (_currentPage < 2) {
      final next = _currentPage + 1;
      setState(() => _currentPage = next);
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      if (next == 1) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) _nameFocus.requestFocus();
        });
      } else {
        FocusScope.of(context).unfocus();
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      final prev = _currentPage - 1;
      setState(() => _currentPage = prev);
      _pageController.animateToPage(
        prev,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
      if (prev == 1) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) _nameFocus.requestFocus();
        });
      } else {
        FocusScope.of(context).unfocus();
      }
    }
  }

  bool get _isNameValid => _nameController.text.trim().isNotEmpty;

  Future<void> _handleProceed() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      await widget.onComplete(name, 0);
    } catch (_) {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleImport() async {
    final name = _nameController.text.trim();
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      if (widget.onImportBackup != null) {
        final success = await widget.onImportBackup!(context);
        if (success && mounted) {
          await widget.onComplete(name.isEmpty ? 'Friend' : name, 0);
          return;
        }
      } else {
        final success = await _showFallbackImportDialog(context);
        if (success && mounted) {
          await widget.onComplete(name.isEmpty ? 'Friend' : name, 0);
          return;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to import backup: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<bool> _showFallbackImportDialog(BuildContext context) async {
    final palette = context.lumaPalette;
    final pathController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: palette.elevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        title: const Text('Import from Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Specify the path to your Luma Excel backup (.xlsx) file to restore:',
              style: TextStyle(color: palette.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: pathController,
              decoration: const InputDecoration(
                hintText: '/path/to/backup.xlsx',
                prefixIcon: Icon(Icons.folder_open_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final p = pathController.text.trim();
              if (p.isNotEmpty) {
                final file = File(p);
                if (file.existsSync()) {
                  Navigator.pop(ctx, true);
                  return;
                }
              }
              Navigator.pop(ctx, false);
            },
            child: const Text('Import File'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.lumaPalette;
    return PopScope(
      canPop: _currentPage == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _previousPage();
      },
      child: Scaffold(
        backgroundColor: palette.background,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(palette),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildWelcomeStep(palette),
                    _buildNameStep(palette),
                    _buildSetupStep(palette),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(LumaPalette palette) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _currentPage > 0
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: palette.textPrimary,
                  ),
                  onPressed: _previousPage,
                  tooltip: 'Back',
                )
              : const SizedBox(width: 48, height: 48),
          if (_currentPage > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(AppRadii.control),
                border: Border.all(color: palette.border),
              ),
              child: Text(
                'Step $_currentPage of 2',
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          const SizedBox(width: 48, height: 48),
        ],
      ),
    );
  }

  Widget _buildWelcomeStep(LumaPalette palette) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          // Quiet, distinctive brand emblem
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: palette.secondaryAccent.withValues(alpha: 0.4),
                  blurRadius: 36,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Image.asset('assets/logo/luma.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            'Luma',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w700,
              color: palette.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Remember where your money went.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: palette.primaryAccent,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              'Luma keeps track of your spending as it happens, so you don\'t have to remember it later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: palette.textSecondary,
              ),
            ),
          ),
          const Spacer(flex: 3),
          // Subtle memory timeline motif
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimelineDot(palette, isFilled: true),
              _buildTimelineLine(palette),
              _buildTimelineDot(palette, isFilled: false),
              _buildTimelineLine(palette),
              _buildTimelineDot(palette, isFilled: false),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Privacy policy and terms consent
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Semantics(
                label: 'I agree to the Privacy Policy and Terms & Conditions',
                checked: _consentAccepted,
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: Checkbox(
                    value: _consentAccepted,
                    onChanged: (val) {
                      setState(() => _consentAccepted = val ?? false);
                    },
                    activeColor: palette.primaryAccent,
                    checkColor: palette.onPrimaryAccent,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    side: BorderSide(
                      color: _consentAccepted
                          ? palette.primaryAccent
                          : palette.border,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'I agree to the ',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: palette.textSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: palette.primaryAccent,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: palette.primaryAccent,
                        ),
                        recognizer: _privacyRecognizer,
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Terms & Conditions',
                        style: TextStyle(
                          color: palette.primaryAccent,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: palette.primaryAccent,
                        ),
                        recognizer: _termsRecognizer,
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: PrimaryButton(
              label: 'Get started',
              onPressed: _consentAccepted ? _nextPage : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineDot(LumaPalette palette, {required bool isFilled}) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: isFilled ? palette.primaryAccent : palette.border,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildTimelineLine(LumaPalette palette) {
    return Container(width: 24, height: 1.5, color: palette.border);
  }

  Widget _buildNameStep(LumaPalette palette) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                constraints.maxHeight - AppSpacing.screenPadding.vertical,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'What should Luma\ncall you?',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary,
                      height: 1.25,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'This name is only used for your personal greeting.',
                    style: TextStyle(
                      fontSize: 15,
                      color: palette.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  TextField(
                    controller: _nameController,
                    focusNode: _nameFocus,
                    autofocus: false,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) {
                      if (_isNameValid) _nextPage();
                    },
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: palette.textPrimary,
                    ),
                    cursorColor: palette.primaryAccent,
                    decoration: InputDecoration(
                      hintText: 'Enter your preferred name',
                      hintStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: palette.textMuted,
                      ),
                      filled: true,
                      fillColor: palette.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.lg,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.card),
                        borderSide: BorderSide(color: palette.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.card),
                        borderSide: BorderSide(color: palette.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.card),
                        borderSide: BorderSide(
                          color: palette.primaryAccent,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xxl),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: PrimaryButton(
                    label: 'Continue',
                    onPressed: _isNameValid ? _nextPage : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetupStep(LumaPalette palette) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                constraints.maxHeight - AppSpacing.screenPadding.vertical,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Choose how to\nget started',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary,
                      height: 1.25,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'You can restore your accounts and history from a backup file, or start fresh and configure your sources anytime.',
                    style: TextStyle(
                      fontSize: 15,
                      color: palette.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Option 1: Import from backup
                  Container(
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(AppRadii.card),
                      border: Border.all(color: palette.border),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.card),
                      ),
                      leading: CircleAvatar(
                        backgroundColor:
                            palette.primaryAccent.withValues(alpha: 0.15),
                        child: Icon(
                          Icons.file_upload_outlined,
                          color: palette.primaryAccent,
                        ),
                      ),
                      title: const Text(
                        'Import from backup file',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Restore your accounts, wallets, categories, and past transactions from an Excel (.xlsx) file.',
                          style: TextStyle(
                            fontSize: 12,
                            color: palette.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                      ),
                      onTap: _isSubmitting ? null : _handleImport,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Option 2: Proceed fresh
                  Container(
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(AppRadii.card),
                      border: Border.all(color: palette.border),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.card),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: palette.elevated,
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: palette.textPrimary,
                        ),
                      ),
                      title: const Text(
                        'Proceed with fresh start',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Start with a clean slate. Manage your physical cash wallet and add bank accounts in Source of Money.',
                          style: TextStyle(
                            fontSize: 12,
                            color: palette.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                      ),
                      onTap: _isSubmitting ? null : _handleProceed,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xxl),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: PrimaryButton(
                    label: _isSubmitting ? 'Setting up...' : 'Proceed to Luma',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _isSubmitting ? null : _handleProceed,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
