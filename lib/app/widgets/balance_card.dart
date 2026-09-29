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
    final isNegative = currentBalanceMinor < 0;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CURRENT BALANCE',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 16,
                color: AppColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AmountDisplay(
            currentBalanceMinor,
            fontSize: 32,
            color: isNegative ? AppColors.error : AppColors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(
                Icons.history_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                'Started with ${formatAmount(initialBalanceMinor)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
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
