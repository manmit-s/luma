import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../../core/utils/format.dart';
import '../../domain/entities/expense.dart';
import '../theme/app_theme.dart';
import 'amount_display.dart';
import 'category_chip.dart';
import 'category_icon.dart';

IconData categoryIcon(String? id) => categoryIconData(id);

/// Completed expense row — single card style used by Home + History.
class ExpenseCard extends ConsumerWidget {
  const ExpenseCard({super.key, required this.expense, required this.onTap});

  final Expense expense;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.lumaPalette;
    final categories = ref.watch(categoryControllerProvider).categories;
    final category = ref.read(categoryControllerProvider).byId(expense.categoryId);
    return Card(
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
                backgroundColor: palette.chipSelectedBackground,
                child: category != null
                    ? CategoryIcon(category: category, size: 19)
                    : Icon(
                        categoryIcon(expense.categoryId),
                        color: palette.chipSelectedText,
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
                      '${categoryName(expense.categoryId, categories)} · ${formatTime(expense.timestamp)}',
                      style: TextStyle(
                        color: palette.textSecondary,
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
}

/// Pending expense — elevated distinction from completed (SPEC 43).
class PendingExpenseCard extends ConsumerWidget {
  const PendingExpenseCard({
    super.key,
    required this.expense,
    required this.onTap,
  });

  final Expense expense;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.lumaPalette;
    final categories = ref.watch(categoryControllerProvider).categories;
    final isCredit = expense.transactionType == TransactionType.credit;
    return Material(
      color: palette.elevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: BorderSide(
          color: isCredit ? palette.success : palette.primaryAccent,
          width: 0.6,
        ),
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
                    child: Row(
                      children: [
                        AmountDisplay(
                          expense.amountMinor,
                          fontSize: 24,
                          color: isCredit ? palette.success : null,
                        ),
                        if (isCredit) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: palette.success.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: palette.success,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              'Credit',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: palette.success,
                              ),
                            ),
                          ),
                        ],
                      ],
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
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Text(
                    'Suggested:',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 6),
                  CategoryChip(
                    label: categoryName(expense.categoryId, categories),
                    compact: true,
                    categoryId: expense.categoryId,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
