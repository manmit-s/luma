import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/format.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';
import '../providers.dart';
import '../theme/app_theme.dart';
import 'amount_display.dart';
import 'expense_cards.dart' show categoryIcon;
import 'luma_buttons.dart';

int parseAmountToMinor(String raw) {
  final cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '').trim();
  if (cleaned.isEmpty) return 0;
  final parts = cleaned.split('.');
  final rupees = int.tryParse(parts[0].isEmpty ? '0' : parts[0]) ?? 0;
  var paise = 0;
  if (parts.length > 1) {
    final fraction = '${parts[1]}00'.substring(0, 2);
    paise = int.tryParse(fraction) ?? 0;
  }
  if (rupees <= 0 && paise <= 0) return 0;
  return rupees * 100 + paise;
}

String minorToInput(int minor) {
  final rupees = minor ~/ 100;
  final paise = minor % 100;
  if (paise == 0) return '$rupees';
  return '$rupees.${paise.toString().padLeft(2, '0')}';
}

EdgeInsets _sheetPadding(BuildContext context) => EdgeInsets.fromLTRB(
      AppSpacing.xl,
      AppSpacing.lg,
      AppSpacing.xl,
      MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xxl,
    );

/// Sleek segmented selector for toggling between Debit (Expense) and Credit (Income).
class _TransactionTypeSelector extends StatelessWidget {
  const _TransactionTypeSelector({
    required this.selectedType,
    required this.onChanged,
  });

  final TransactionType selectedType;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDebit = selectedType == TransactionType.debit;
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(TransactionType.debit),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: isDebit ? const Color(0xFF3E1C27) : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadii.compact),
                  border: isDebit
                      ? Border.all(color: AppColors.peach, width: 1.2)
                      : null,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_outward_rounded,
                      size: 16,
                      color: isDebit ? AppColors.peach : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Debit (Expense)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isDebit ? FontWeight.w600 : FontWeight.w500,
                        color: isDebit
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(TransactionType.credit),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: !isDebit ? const Color(0xFF1B3828) : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadii.compact),
                  border: !isDebit
                      ? Border.all(color: AppColors.success, width: 1.2)
                      : null,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_downward_rounded,
                      size: 16,
                      color:
                          !isDebit ? AppColors.success : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Credit (Income)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            !isDebit ? FontWeight.w600 : FontWeight.w500,
                        color: !isDebit
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal swipable category cards with vector icon and label.
class _CategoryCardSelector extends StatelessWidget {
  const _CategoryCardSelector({
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final String selectedCategoryId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: defaultCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final item = defaultCategories[index];
          final isSelected = selectedCategoryId == item.id;
          return GestureDetector(
            onTap: () => onSelected(item.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 80,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.plum : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.card),
                border: Border.all(
                  color: isSelected ? AppColors.peach : AppColors.border,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.peach.withValues(alpha: 0.2)
                          : AppColors.surfaceLow,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      categoryIcon(item.id),
                      size: 20,
                      color: isSelected
                          ? AppColors.peach
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

Future<void> showCompleteExpense(
  BuildContext context,
  WidgetRef ref,
  Expense expense,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => _CompleteExpenseSheet(expense: expense),
  );
}

class _CompleteExpenseSheet extends ConsumerStatefulWidget {
  const _CompleteExpenseSheet({required this.expense});

  final Expense expense;

  @override
  ConsumerState<_CompleteExpenseSheet> createState() =>
      _CompleteExpenseSheetState();
}

class _CompleteExpenseSheetState
    extends ConsumerState<_CompleteExpenseSheet> {
  late String category;
  late TextEditingController note;
  late TransactionType transactionType;

  @override
  void initState() {
    super.initState();
    category = widget.expense.categoryId ?? '';
    note = TextEditingController(text: widget.expense.note);
    transactionType = widget.expense.transactionType;
  }

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.elevated,
        title: const Text('Delete expense?'),
        content: Text(
          '${merchantLabel(widget.expense.merchant)} (${formatAmount(widget.expense.amountMinor)}) will be removed from Needs Attention.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref
          .read(expenseControllerProvider)
          .deleteExpense(widget.expense.id);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense deleted.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: _sheetPadding(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Complete expense',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.error),
                    tooltip: 'Delete expense',
                    onPressed: () => _confirmDelete(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AmountDisplay(widget.expense.amountMinor, fontSize: 36),
              const SizedBox(height: AppSpacing.xs),
              Text(
                merchantLabel(widget.expense.merchant),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              Text(
                formatTime(widget.expense.timestamp),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Transaction type',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              _TransactionTypeSelector(
                selectedType: transactionType,
                onChanged: (val) => setState(() => transactionType = val),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'What was this for?',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              _CategoryCardSelector(
                selectedCategoryId: category,
                onSelected: (val) => setState(() => category = val),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: note,
                maxLines: 2,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Add a note (optional)',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: transactionType == TransactionType.debit
                      ? 'Save expense'
                      : 'Save credit',
                  onPressed: category.isEmpty
                      ? null
                      : () {
                          ref
                              .read(expenseControllerProvider)
                              .complete(
                                widget.expense,
                                categoryId: category,
                                note: note.text.trim(),
                                transactionType: transactionType,
                              );
                          Navigator.pop(context);
                        },
                ),
              ),
              if (category.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    'Pick a category to save.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.error, size: 18),
                  label: const Text(
                    'Delete this expense',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

Future<void> showAddExpense(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => const _AddExpenseSheet(),
  );
}

class _AddExpenseSheet extends ConsumerStatefulWidget {
  const _AddExpenseSheet();

  @override
  ConsumerState<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<_AddExpenseSheet> {
  final amount = TextEditingController();
  final merchant = TextEditingController();
  final note = TextEditingController();
  String category = 'other';
  TransactionType transactionType = TransactionType.debit;
  String? error;

  @override
  void dispose() {
    amount.dispose();
    merchant.dispose();
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: _sheetPadding(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transactionType == TransactionType.debit
                    ? 'Add expense'
                    : 'Add credit / income',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              _TransactionTypeSelector(
                selectedType: transactionType,
                onChanged: (val) => setState(() => transactionType = val),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                  errorText: error,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: merchant,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: transactionType == TransactionType.debit
                      ? 'Merchant or description'
                      : 'Source or description (e.g. Salary, Refund)',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Category',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              _CategoryCardSelector(
                selectedCategoryId: category,
                onSelected: (val) => setState(() => category = val),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: note,
                maxLines: 2,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Add a note (optional)',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: transactionType == TransactionType.debit
                      ? 'Save expense'
                      : 'Save credit',
                  onPressed: () {
                    final parsed = parseAmountToMinor(amount.text);
                    if (parsed <= 0) {
                      setState(
                        () => error = 'Enter an amount greater than ₹0',
                      );
                      return;
                    }
                    ref.read(expenseControllerProvider).addManual(
                          amountMinor: parsed,
                          merchant: merchant.text.trim(),
                          categoryId: category,
                          note: note.text.trim(),
                          transactionType: transactionType,
                        );
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      );
}

Future<void> showEditExpense(
  BuildContext context,
  WidgetRef ref,
  Expense expense,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => _EditExpenseSheet(expense: expense),
  );
}

class _EditExpenseSheet extends ConsumerStatefulWidget {
  const _EditExpenseSheet({required this.expense});

  final Expense expense;

  @override
  ConsumerState<_EditExpenseSheet> createState() => _EditExpenseSheetState();
}

class _EditExpenseSheetState extends ConsumerState<_EditExpenseSheet> {
  late TextEditingController amount;
  late TextEditingController merchant;
  late TextEditingController note;
  late String category;
  late TransactionType transactionType;
  String? error;

  @override
  void initState() {
    super.initState();
    amount =
        TextEditingController(text: minorToInput(widget.expense.amountMinor));
    merchant = TextEditingController(text: widget.expense.merchant ?? '');
    note = TextEditingController(text: widget.expense.note);
    category = widget.expense.categoryId ?? 'other';
    transactionType = widget.expense.transactionType;
  }

  @override
  void dispose() {
    amount.dispose();
    merchant.dispose();
    note.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.elevated,
        title: const Text('Delete expense?'),
        content: Text(
          '${merchantLabel(widget.expense.merchant)} (${formatAmount(widget.expense.amountMinor)}) will be removed permanently.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref
          .read(expenseControllerProvider)
          .deleteExpense(widget.expense.id);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense deleted.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: _sheetPadding(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit expense',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.error),
                    tooltip: 'Delete expense',
                    onPressed: () => _confirmDelete(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _TransactionTypeSelector(
                selectedType: transactionType,
                onChanged: (val) => setState(() => transactionType = val),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                  errorText: error,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: merchant,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Merchant or description',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Category',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              _CategoryCardSelector(
                selectedCategoryId: category,
                onSelected: (val) => setState(() => category = val),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: note,
                maxLines: 2,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Add a note (optional)',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Save changes',
                  onPressed: () async {
                    final parsed = parseAmountToMinor(amount.text);
                    if (parsed <= 0) {
                      setState(
                        () => error = 'Enter an amount greater than ₹0',
                      );
                      return;
                    }
                    final merchantText = merchant.text.trim();
                    final expense = widget.expense;
                    final updated = Expense(
                      id: expense.id,
                      amountMinor: parsed,
                      merchant: merchantText.isEmpty ? null : merchantText,
                      categoryId: category,
                      note: note.text.trim(),
                      timestamp: expense.timestamp,
                      transactionType: transactionType,
                      status: expense.status,
                      referenceNumber: expense.referenceNumber,
                      smsFingerprint: expense.smsFingerprint,
                      rawSms: expense.rawSms,
                      source: expense.source,
                      createdAt: expense.createdAt,
                      updatedAt: DateTime.now(),
                      lastExportedAt: expense.lastExportedAt,
                    );
                    await ref
                        .read(expenseControllerProvider)
                        .updateExpense(updated);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.error, size: 18),
                  label: const Text(
                    'Delete this expense',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
