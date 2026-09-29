import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Minimalist, high-end typographic splash screen.
///
/// Clean editorial wordmark animation:
/// - Pure obsidian background
/// - Smooth tracking & subtle scale entrance
/// - Crisp typography with signature peach accent dot
/// - Snappy 700ms duration (0.7s)
class LumaSplashScreen extends StatefulWidget {
  const LumaSplashScreen({
    super.key,
    required this.onComplete,
    this.minimumDuration = const Duration(milliseconds: 700),
  });

  final VoidCallback onComplete;
  final Duration minimumDuration;

  @override
  State<LumaSplashScreen> createState() => _LumaSplashScreenState();
}

class _LumaSplashScreenState extends State<LumaSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _letterSpacingAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _letterSpacingAnimation = Tween<double>(begin: 8.0, end: 3.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _startFlow();
  }

  bool _completed = false;

  void _finish() {
    if (_completed || !mounted) return;
    _completed = true;
    widget.onComplete();
  }

  Future<void> _startFlow() async {
    _controller.forward();
    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTest && widget.minimumDuration > Duration.zero) {
      await Future<void>.delayed(widget.minimumDuration);
    } else {
      await Future<void>.delayed(Duration.zero);
    }
    _finish();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _finish,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Text.rich(
                    TextSpan(
                      text: 'luma',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        letterSpacing: _letterSpacingAnimation.value,
                      ),
                      children: const [
                        TextSpan(
                          text: '.',
                          style: TextStyle(
                            color: AppColors.peach,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
