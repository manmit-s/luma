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
    return PopScope(
      canPop: _currentPage == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _previousPage();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildWelcomeStep(),
                    _buildNameStep(),
                    _buildBalanceStep(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _currentPage > 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                  onPressed: _previousPage,
                  tooltip: 'Back',
                )
              : const SizedBox(width: 48, height: 48),
          if (_currentPage > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.control),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                'Step $_currentPage of 2',
                style: const TextStyle(
                  color: AppColors.textSecondary,
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

  Widget _buildWelcomeStep() {
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
                  color: AppColors.plum.withValues(alpha: 0.4),
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
          const Text(
            'Luma',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Remember where your money went.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.peach,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              'Luma keeps track of your spending as it happens, so you don\'t have to remember it later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Spacer(flex: 3),
          // Subtle memory timeline motif
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimelineDot(isFilled: true),
              _buildTimelineLine(),
              _buildTimelineDot(isFilled: false),
              _buildTimelineLine(),
              _buildTimelineDot(isFilled: false),
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

  Widget _buildTimelineDot({required bool isFilled}) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: isFilled ? AppColors.peach : AppColors.border,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildTimelineLine() {
    return Container(
      width: 24,
      height: 1.5,
      color: AppColors.border,
    );
  }

  Widget _buildNameStep() {
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
                  const Text(
                    'What should Luma\ncall you?',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.25,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'This name is only used for your personal greeting.',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
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
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    cursorColor: AppColors.peach,
                    decoration: InputDecoration(
                      hintText: 'Enter your preferred name',
                      hintStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.lg,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.card),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.card),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.card),
                        borderSide: const BorderSide(color: AppColors.peach, width: 1.5),
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

  Widget _buildBalanceStep() {
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
                  const Text(
                    'What\'s your\ncurrent balance?',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.25,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Enter the balance in your account right now. Luma will update it as transactions are recorded.',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
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
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    cursorColor: AppColors.peach,
                    decoration: InputDecoration(
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.sm),
                        child: Text(
                          '₹',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.peach,
                          ),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                      hintText: '0.00',
                      hintStyle: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.lg,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.card),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.card),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.card),
                        borderSide: const BorderSide(color: AppColors.peach, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Your starting point. Luma will update it as transactions are recorded.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
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
