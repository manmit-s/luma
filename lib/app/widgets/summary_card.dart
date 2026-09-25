import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'amount_display.dart';

/// Month + today summary card — one implementation for Home + History.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.monthTotal,
    this.todayTotal,
    this.expenseCount,
    this.title = 'THIS MONTH',
  });

  final int monthTotal;
  final int? todayTotal;
  final int? expenseCount;
  final String title;

  @override
  Widget build(BuildContext context) => Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
                if (expenseCount != null)
                  Text(
                    '$expenseCount expenses',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            AmountDisplay(monthTotal, fontSize: 32),
            if (todayTotal != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  const Text(
                    'Spent today',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  AmountDisplay(
                    todayTotal!,
                    fontSize: 15,
                    color: AppColors.peach,
                  ),
                ],
              ),
            ],
          ],
        ),
      );
}
