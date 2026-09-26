import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/format.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';
import '../providers.dart';
import '../theme/app_theme.dart';
import 'amount_display.dart';
import 'category_chip.dart';
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

Future<void> showCompleteExpense(
  BuildContext context,
  WidgetRef ref,
  Expense expense,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
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

  @override
  void initState() {
    super.initState();
    category = widget.expense.categoryId ?? '';
    note = TextEditingController(text: widget.expense.note);
  }

  @override
  void dispose() {
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
                'Complete expense',
                style: Theme.of(context).textTheme.titleLarge,
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
              const SizedBox(height: AppSpacing.xxl),
              const Text('What was this for?'),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: defaultCategories
                    .map(
                      (item) => CategoryChip(
                        label: item.name,
                        selected: category == item.id,
                        onSelected: (_) =>
                            setState(() => category = item.id),
                      ),
                    )
                    .toList(),
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
                  label: 'Save expense',
                  onPressed: category.isEmpty
                      ? null
                      : () {
                          ref
                              .read(expenseControllerProvider)
                              .complete(
                                widget.expense,
                                categoryId: category,
                                note: note.text.trim(),
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
            ],
          ),
        ),
      );
}

Future<void> showAddExpense(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
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
  String category = 'other';
  String? error;

  @override
  void dispose() {
    amount.dispose();
    merchant.dispose();
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
                'Add expense',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
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
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: defaultCategories
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.id,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => category = value ?? 'other'),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Save expense',
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
  String? error;

  @override
  void initState() {
    super.initState();
    amount =
        TextEditingController(text: minorToInput(widget.expense.amountMinor));
    merchant = TextEditingController(text: widget.expense.merchant ?? '');
    note = TextEditingController(text: widget.expense.note);
    category = widget.expense.categoryId ?? 'other';
  }

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
                'Edit expense',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
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
              const Text('Category'),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: defaultCategories
                    .map(
                      (item) => CategoryChip(
                        label: item.name,
                        selected: category == item.id,
                        onSelected: (_) =>
                            setState(() => category = item.id),
                      ),
                    )
                    .toList(),
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
                      transactionType: expense.transactionType,
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
            ],
          ),
        ),
      );
}
