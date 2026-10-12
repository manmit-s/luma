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
  Widget build(BuildContext context) {
    final palette = context.lumaPalette;
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
                title,
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
              if (expenseCount != null)
                Text(
                  '$expenseCount expenses',
                  style: TextStyle(color: palette.textSecondary),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AmountDisplay(monthTotal, fontSize: 32),
          if (todayTotal != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Text(
                  'Spent today',
                  style: TextStyle(color: palette.textSecondary),
                ),
                const SizedBox(width: AppSpacing.md),
                AmountDisplay(
                  todayTotal!,
                  fontSize: 15,
                  color: palette.primaryAccent,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
