import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'luma_buttons.dart';

/// Serene, 3-step first-launch onboarding flow for Luma.
///
/// Flow:
/// 1. Welcome ("Remember where your money went.")
/// 2. Preferred Name ("What should Luma call you?")
/// 3. Current Account Balance ("What's your current balance?")
///
/// Free of generic SaaS carousels, feature ads, and marketing fluff.
class FirstLaunchFlow extends StatefulWidget {
  const FirstLaunchFlow({
    super.key,
    required this.onComplete,
  });

  final Future<void> Function(String name, int initialBalanceMinor) onComplete;

  @override
  State<FirstLaunchFlow> createState() => _FirstLaunchFlowState();
}

class _FirstLaunchFlowState extends State<FirstLaunchFlow> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _balanceFocus = FocusNode();

  int _currentPage = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFieldChanged);
    _balanceController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _balanceController.dispose();
    _nameFocus.dispose();
    _balanceFocus.dispose();
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
      } else if (next == 2) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) _balanceFocus.requestFocus();
        });
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

  double? get _parsedBalance {
    final text = _balanceController.text.trim().replaceAll(',', '');
    if (text.isEmpty) return null;
    final val = double.tryParse(text);
    if (val == null || val < 0 || val.isNaN || val.isInfinite) return null;
    return val;
  }

  bool get _isBalanceValid => _parsedBalance != null;

  Future<void> _handleFinish() async {
    final name = _nameController.text.trim();
    final balanceVal = _parsedBalance;
    if (name.isEmpty || balanceVal == null || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    final balanceMinor = (balanceVal * 100).round();
    try {
      await widget.onComplete(name, balanceMinor);
    } catch (_) {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
                    _buildBalanceStep(palette),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _currentPage > 0
              ? IconButton(
                  icon: Icon(Icons.arrow_back_rounded, color: palette.textPrimary),
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
              child: Image.asset(
                'assets/logo/luma.png',
                fit: BoxFit.cover,
              ),
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
          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: PrimaryButton(
              label: 'Get started',
              onPressed: _nextPage,
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
    return Container(
      width: 24,
      height: 1.5,
      color: palette.border,
    );
  }

  Widget _buildNameStep(LumaPalette palette) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight - AppSpacing.screenPadding.vertical),
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
                        borderSide: BorderSide(color: palette.primaryAccent, width: 1.5),
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

  Widget _buildBalanceStep(LumaPalette palette) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight - AppSpacing.screenPadding.vertical),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'What\'s your\ncurrent balance?',
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
                    'Enter the balance in your account right now. Luma will update it as transactions are recorded.',
                    style: TextStyle(
                      fontSize: 15,
                      color: palette.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  TextField(
                    controller: _balanceController,
                    focusNode: _balanceFocus,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (_isBalanceValid) _handleFinish();
                    },
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary,
                    ),
                    cursorColor: palette.primaryAccent,
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.sm),
                        child: Text(
                          '₹',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: palette.primaryAccent,
                          ),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                      hintText: '0.00',
                      hintStyle: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
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
                        borderSide: BorderSide(color: palette.primaryAccent, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: palette.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Your starting point. Luma will update it as transactions are recorded.',
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xxl),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: PrimaryButton(
                    label: _isSubmitting ? 'Setting up...' : 'Start using Luma',
                    onPressed: (_isBalanceValid && !_isSubmitting) ? _handleFinish : null,
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
