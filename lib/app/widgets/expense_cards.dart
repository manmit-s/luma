import 'package:flutter/material.dart';

import '../../core/utils/format.dart';
import '../../domain/entities/expense.dart';
import '../theme/app_theme.dart';
import 'amount_display.dart';
import 'category_chip.dart';

IconData categoryIcon(String? id) => switch (id) {
      'food' => Icons.restaurant_rounded,
      'travel' => Icons.directions_car_rounded,
      'shopping' => Icons.shopping_bag_outlined,
      'subscriptions' => Icons.autorenew_rounded,
      'bills' => Icons.receipt_long_rounded,
      'entertainment' => Icons.movie_outlined,
      'health' => Icons.favorite_outline,
      'education' => Icons.school_outlined,
      'personal' => Icons.person_outline,
      _ => Icons.wallet_outlined,
    };

/// Completed expense row — single card style used by Home + History.
class ExpenseCard extends StatelessWidget {
  const ExpenseCard({super.key, required this.expense, required this.onTap});

  final Expense expense;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.card),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.plum,
                  child: Icon(
                    categoryIcon(expense.categoryId),
                    color: AppColors.peach,
                    size: 19,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        merchantLabel(expense.merchant),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${categoryName(expense.categoryId)} · ${formatTime(expense.timestamp)}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                AmountDisplay(
                  expense.amountMinor,
                  fontSize: 15,
                ),
              ],
            ),
          ),
        ),
      );
}

/// Pending expense — elevated distinction from completed (SPEC 43).
class PendingExpenseCard extends StatelessWidget {
  const PendingExpenseCard({
    super.key,
    required this.expense,
    required this.onTap,
  });

  final Expense expense;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.elevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: const BorderSide(color: AppColors.peach, width: 0.6),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.card),
          onTap: onTap,
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: AmountDisplay(
                        expense.amountMinor,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    OutlinedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Confirm'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  merchantLabel(expense.merchant),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${formatDayLabel(expense.timestamp)} · ${formatTime(expense.timestamp)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    const Text(
                      'Suggested:',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    CategoryChip(
                      label: categoryName(expense.categoryId),
                      compact: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
