import 'package:flutter/material.dart';

import '../../core/utils/format.dart';
import '../../domain/entities/payment_source.dart';
import '../theme/app_theme.dart';
import 'amount_display.dart';

/// Card showing the user's running account balance, starting snapshot,
/// and breakdown of bank accounts, physical cash, and individual balances.
class BalanceCard extends StatefulWidget {
  const BalanceCard({
    super.key,
    required this.currentBalanceMinor,
    required this.initialBalanceMinor,
    this.totalBankBalanceMinor,
    this.cashBalanceMinor,
    this.sources,
    this.sourceBalances,
    this.onSourceTap,
  });

  final int currentBalanceMinor;
  final int initialBalanceMinor;
  final int? totalBankBalanceMinor;
  final int? cashBalanceMinor;
  final List<PaymentSource>? sources;
  final Map<int, int>? sourceBalances;
  final ValueChanged<PaymentSource>? onSourceTap;

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _iconRotationAnimation;
  late final Animation<double> _fadeAnimation;
  bool _showBreakdown = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    // Smooth cubic bezier curve for expansion and collapse
    const bezierCurve = Cubic(0.4, 0.0, 0.2, 1.0);
    final curved = CurvedAnimation(
      parent: _animController,
      curve: bezierCurve,
      reverseCurve: bezierCurve.flipped,
    );

    _expandAnimation = curved;
    _iconRotationAnimation =
        Tween<double>(begin: 0.0, end: 0.5).animate(curved);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 1.0, curve: bezierCurve),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggleBreakdown() {
    setState(() {
      _showBreakdown = !_showBreakdown;
      if (_showBreakdown) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.lumaPalette;
    final isNegative = widget.currentBalanceMinor < 0;
    final hasSources = widget.sources != null && widget.sources!.isNotEmpty;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CURRENT BALANCE',
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 16,
                color: palette.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AmountDisplay(
            widget.currentBalanceMinor,
            fontSize: 32,
            color: isNegative ? palette.error : palette.textPrimary,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(
                Icons.history_rounded,
                size: 14,
                color: palette.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                'Started with ${formatAmount(widget.initialBalanceMinor)}',
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),

          // Total Banks and Physical Cash breakdown bar
          if (widget.totalBankBalanceMinor != null ||
              widget.cashBalanceMinor != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: palette.elevated,
                borderRadius: BorderRadius.circular(AppRadii.compact),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _MiniSummaryTile(
                      icon: Icons.account_balance_rounded,
                      title: 'Bank Accounts',
                      amountMinor: widget.totalBankBalanceMinor ?? 0,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 22,
                    color: palette.border,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MiniSummaryTile(
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'Physical Cash',
                      amountMinor: widget.cashBalanceMinor ?? 0,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Expandable individual account balances list with bezier animation
          if (hasSources) ...[
            const SizedBox(height: AppSpacing.xs),
            InkWell(
              onTap: _toggleBreakdown,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _showBreakdown
                          ? 'Hide account breakdown'
                          : 'View individual accounts',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: palette.primaryAccent,
                      ),
                    ),
                    const SizedBox(width: 4),
                    RotationTransition(
                      turns: _iconRotationAnimation,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: palette.primaryAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizeTransition(
              sizeFactor: _expandAnimation,
              axisAlignment: -1.0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xs),
                    const Divider(height: 1),
                    const SizedBox(height: AppSpacing.xs),
                    ...widget.sources!.where((s) => s.isActive).map((source) {
                      final balance = widget.sourceBalances?[source.id] ?? 0;
                      return InkWell(
                        onTap: widget.onSourceTap != null
                            ? () => widget.onSourceTap!(source)
                            : null,
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 4),
                          child: Row(
                            children: [
                              Icon(
                                source.isBank
                                    ? Icons.account_balance_rounded
                                    : Icons.account_balance_wallet_rounded,
                                size: 14,
                                color: palette.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  source.displayName,
                                  style: const TextStyle(fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                formatAmount(balance),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: balance < 0
                                      ? palette.error
                                      : palette.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniSummaryTile extends StatelessWidget {
  const _MiniSummaryTile({
    required this.icon,
    required this.title,
    required this.amountMinor,
  });

  final IconData icon;
  final String title;
  final int amountMinor;

  @override
  Widget build(BuildContext context) {
    final palette = context.lumaPalette;
    return Row(
      children: [
        Icon(icon, size: 14, color: palette.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  color: palette.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                formatAmount(amountMinor),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
