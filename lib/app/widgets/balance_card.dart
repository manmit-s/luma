import 'package:flutter/material.dart';

import '../../core/utils/format.dart';
import '../theme/app_theme.dart';
import 'amount_display.dart';

/// Card showing the user's running account balance and starting snapshot.
///
/// Designed to coexist peacefully with [SummaryCard] (which displays
/// monthly/daily expense totals) without visual confusion.
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.currentBalanceMinor,
    required this.initialBalanceMinor,
  });

  final int currentBalanceMinor;
  final int initialBalanceMinor;

  @override
  Widget build(BuildContext context) {
    final palette = context.lumaPalette;
    final isNegative = currentBalanceMinor < 0;

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
            currentBalanceMinor,
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
                'Started with ${formatAmount(initialBalanceMinor)}',
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
