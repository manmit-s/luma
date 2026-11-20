import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/source_controller.dart';
import '../../core/utils/format.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/payment_source.dart';
import '../providers.dart';
import '../theme/app_theme.dart';
import 'amount_display.dart';
import 'expense_cards.dart';
import 'expense_sheets.dart';
import 'luma_buttons.dart';

class SourceOfMoneyPage extends ConsumerWidget {
  const SourceOfMoneyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourceController = ref.watch(sourceControllerProvider);
    final expenseController = ref.watch(expenseControllerProvider);

    final palette = context.lumaPalette;
    final breakdown = sourceController.breakdownFor(expenseController.expenses);
    final sources = sourceController.sources;
    final cashWallet = sourceController.cashWallet;
    final bankAccounts = sources.where((s) => s.isBank).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Source of Money'),
        actions: [
          IconButton(
            tooltip: 'Transfer Money',
            icon: const Icon(Icons.swap_horiz_rounded),
            onPressed: () => _showTransferSheet(context, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _pickBankFromCatalogue(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Bank Account'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          // Overview Combined Balance Card
          _CombinedBalanceHeaderCard(
            breakdown: breakdown,
            onTransfer: () => _showTransferSheet(context, ref),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Cash Wallet Section
          _SectionTitle(
            title: 'PHYSICAL CASH WALLET',
            actionLabel: 'Edit Wallet',
            onAction: cashWallet == null
                ? null
                : () => _editWallet(context, ref, cashWallet),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (cashWallet != null)
            _SourceCard(
              source: cashWallet,
              balanceMinor: breakdown.individualBalances[cashWallet.id] ?? 0,
              onTap: () => _openAccountDetails(context, ref, cashWallet),
              onEdit: () => _editWallet(context, ref, cashWallet),
            )
          else
            Card(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Text(
                  'Physical cash wallet is enabled by default.',
                  style: TextStyle(color: palette.textSecondary),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.xl),

          // Bank Accounts Section
          _SectionTitle(
            title: 'BANK ACCOUNTS (${bankAccounts.length})',
            actionLabel: 'Add Bank',
            onAction: () => _pickBankFromCatalogue(context, ref),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (bankAccounts.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.account_balance_outlined,
                        size: 40,
                        color: palette.textSecondary,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        'No bank accounts configured',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add popular Indian banks to automatically identify and track transactions.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      PrimaryButton(
                        label: 'Select Bank',
                        icon: Icons.add_rounded,
                        onPressed: () => _pickBankFromCatalogue(context, ref),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...bankAccounts.map(
              (acc) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _SourceCard(
                  source: acc,
                  balanceMinor: breakdown.individualBalances[acc.id] ?? 0,
                  onTap: () => _openAccountDetails(context, ref, acc),
                  onEdit: () => _editBankAccount(context, ref, acc),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openAccountDetails(
      BuildContext context, WidgetRef ref, PaymentSource source) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AccountDetailsPage(sourceId: source.id),
      ),
    );
  }

  Future<void> _editWallet(
      BuildContext context, WidgetRef ref, PaymentSource wallet) async {
    final result = await showModalBottomSheet<PaymentSource>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => _WalletEditorSheet(wallet: wallet),
    );
    if (result != null) {
      await ref.read(sourceControllerProvider).saveSource(result);
    }
  }

  Future<void> _editBankAccount(
      BuildContext context, WidgetRef ref, PaymentSource account) async {
    final result = await showModalBottomSheet<PaymentSource>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => _BankDetailsEditorSheet(existing: account),
    );
    if (result != null) {
      await ref.read(sourceControllerProvider).saveSource(result);
    }
  }

  Future<void> _pickBankFromCatalogue(
      BuildContext context, WidgetRef ref) async {
    final selectedBank = await showModalBottomSheet<BankCatalogueItem>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => const _BankCataloguePickerSheet(),
    );
    if (selectedBank != null && context.mounted) {
      final newSource = await showModalBottomSheet<PaymentSource>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        useSafeArea: true,
        builder: (_) => _BankDetailsEditorSheet(bank: selectedBank),
      );
      if (newSource != null) {
        await ref.read(sourceControllerProvider).saveSource(newSource);
      }
    }
  }

  Future<void> _showTransferSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => const _TransferMoneySheet(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final palette = context.lumaPalette;
    return Row(
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
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),
            child: Text(
              actionLabel!,
              style: TextStyle(
                color: palette.primaryAccent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _CombinedBalanceHeaderCard extends StatelessWidget {
  const _CombinedBalanceHeaderCard({
    required this.breakdown,
    required this.onTransfer,
  });

  final SourceBreakdown breakdown;
  final VoidCallback onTransfer;

  @override
  Widget build(BuildContext context) {
    final palette = context.lumaPalette;
    final isNegative = breakdown.combinedBalanceMinor < 0;

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
                'COMBINED ACTIVE BALANCE',
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
              OutlinedButton.icon(
                onPressed: onTransfer,
                icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                label: const Text('Transfer'),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AmountDisplay(
            breakdown.combinedBalanceMinor,
            fontSize: 32,
            color: isNegative ? palette.error : palette.textPrimary,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: palette.elevated,
              borderRadius: BorderRadius.circular(AppRadii.compact),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MiniStat(
                  icon: Icons.account_balance_outlined,
                  label: 'Bank Accounts',
                  amountMinor: breakdown.totalBankBalanceMinor,
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: palette.border,
                ),
                _MiniStat(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Physical Cash',
                  amountMinor: breakdown.cashBalanceMinor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.amountMinor,
  });

  final IconData icon;
  final String label;
  final int amountMinor;

  @override
  Widget build(BuildContext context) {
    final palette = context.lumaPalette;
    return Row(
      children: [
        Icon(icon, size: 16, color: palette.textSecondary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: palette.textSecondary, fontSize: 11),
            ),
            Text(
              formatAmount(amountMinor),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.source,
    required this.balanceMinor,
    required this.onTap,
    required this.onEdit,
  });

  final PaymentSource source;
  final int balanceMinor;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final palette = context.lumaPalette;
    final isNegative = balanceMinor < 0;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.card),
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: source.isActive
                        ? palette.primaryAccent.withValues(alpha: 0.15)
                        : palette.elevated,
                    child: Icon(
                      source.isBank
                          ? Icons.account_balance_rounded
                          : Icons.account_balance_wallet_rounded,
                      color: source.isActive
                          ? palette.primaryAccent
                          : palette.textSecondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                source.displayName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: source.isActive
                                      ? palette.textPrimary
                                      : palette.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (!source.isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: palette.elevated,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Inactive',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: palette.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          source.isBank
                              ? (source.accountNumberLast4 != null
                                  ? 'Account ending in ${source.accountNumberLast4}'
                                  : 'Account configured')
                              : 'Default physical wallet',
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    tooltip: 'Edit account details',
                    onPressed: onEdit,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OPENING BALANCE',
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        formatAmount(source.openingBalanceMinor),
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'CALCULATED BALANCE',
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                      AmountDisplay(
                        balanceMinor,
                        fontSize: 17,
                        color: isNegative ? palette.error : palette.textPrimary,
                      ),
                    ],
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

class AccountDetailsPage extends ConsumerWidget {
  const AccountDetailsPage({super.key, required this.sourceId});

  final int sourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourceController = ref.watch(sourceControllerProvider);
    final expenseController = ref.watch(expenseControllerProvider);
    final source = sourceController.byId(sourceId);
    final palette = context.lumaPalette;

    if (source == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Account Details')),
        body: const Center(child: Text('Account not found')),
      );
    }

    final summary = sourceController.summaryFor(source, expenseController.expenses);
    final balance = sourceController.balanceFor(source.id, expenseController.expenses);
    final isNegative = balance < 0;

    // Filter transactions for this specific account
    final txs = expenseController.expenses
        .where((e) => e.sourceId == source.id)
        .toList();
    final sortedTxs = List<Expense>.from(txs)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Also get transfers related to this account
    final accountTransfers = sourceController.transfers
        .where((t) => t.fromSourceId == source.id || t.toSourceId == source.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(source.displayName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Account',
            onPressed: () async {
              final result = await showModalBottomSheet<PaymentSource>(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                useSafeArea: true,
                builder: (_) => source.isWallet
                    ? _WalletEditorSheet(wallet: source)
                    : _BankDetailsEditorSheet(existing: source),
              );
              if (result != null) {
                await ref.read(sourceControllerProvider).saveSource(result);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          // Balance Overview Card
          Container(
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
                      'CURRENT LEDGER BALANCE',
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: source.isActive
                            ? palette.success.withValues(alpha: 0.15)
                            : palette.elevated,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        source.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: source.isActive
                              ? palette.success
                              : palette.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                AmountDisplay(
                  balance,
                  fontSize: 32,
                  color: isNegative ? palette.error : palette.textPrimary,
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(),
                const SizedBox(height: AppSpacing.xs),
                _LedgerStatRow(
                  label: 'Opening balance',
                  amountMinor: summary.openingBalanceMinor,
                ),
                _LedgerStatRow(
                  label: 'Total confirmed income',
                  amountMinor: summary.incomeMinor,
                  prefix: '+',
                  color: palette.success,
                ),
                _LedgerStatRow(
                  label: 'Total confirmed expenses',
                  amountMinor: summary.expensesMinor,
                  prefix: '-',
                  color: palette.error,
                ),
                _LedgerStatRow(
                  label: 'Transfers received',
                  amountMinor: summary.transfersReceivedMinor,
                  prefix: '+',
                  color: palette.primaryAccent,
                ),
                _LedgerStatRow(
                  label: 'Transfers sent',
                  amountMinor: summary.transfersSentMinor,
                  prefix: '-',
                  color: palette.primaryAccent,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Transaction History Header
          Text(
            'ACCOUNT TRANSACTION HISTORY (${sortedTxs.length})',
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          if (sortedTxs.isEmpty && accountTransfers.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No transactions recorded for this account yet.',
                    style: TextStyle(color: palette.textSecondary),
                  ),
                ),
              ),
            )
          else ...[
            ...groupExpensesByDay(sortedTxs).map(
              (group) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.sm,
                        left: 4,
                      ),
                      child: Text(
                        formatDayLabel(group.$1),
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    ...group.$2.map(
                      (expense) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ExpenseCard(
                          expense: expense,
                          onTap: () =>
                              showCompleteExpense(context, ref, expense),
                        ),
                      ),
                    ),
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

class _LedgerStatRow extends StatelessWidget {
  const _LedgerStatRow({
    required this.label,
    required this.amountMinor,
    this.prefix = '',
    this.color,
  });

  final String label;
  final int amountMinor;
  final String prefix;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = context.lumaPalette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: palette.textSecondary, fontSize: 13),
          ),
          Text(
            '$prefix${formatAmount(amountMinor)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: color ?? palette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal picker sheet showing only predefined catalogue banks.
/// Custom bank creation is strictly disallowed.
class _BankCataloguePickerSheet extends StatefulWidget {
  const _BankCataloguePickerSheet();

  @override
  State<_BankCataloguePickerSheet> createState() =>
      _BankCataloguePickerSheetState();
}

class _BankCataloguePickerSheetState extends State<_BankCataloguePickerSheet> {
  String search = '';
  BankTier? selectedTier;

  @override
  Widget build(BuildContext context) {
    final palette = context.lumaPalette;
    final normalizedSearch = search.trim().toLowerCase();

    final filtered = indianBankCatalogue.where((bank) {
      if (selectedTier != null && bank.tier != selectedTier) return false;
      if (normalizedSearch.isEmpty) return true;
      return bank.name.toLowerCase().contains(normalizedSearch) ||
          bank.shortName.toLowerCase().contains(normalizedSearch) ||
          bank.senderCodes.any((c) => c.toLowerCase().contains(normalizedSearch));
    }).toList();

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Bank',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Choose your bank from popular Indian banks catalogue',
              style: TextStyle(color: palette.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              onChanged: (val) => setState(() => search = val),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Search SBI, HDFC, ICICI, Kotak…',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              child: Row(
                children: [
                  ChoiceChip(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                    label: const Text('All Banks'),
                    selected: selectedTier == null,
                    onSelected: (_) => setState(() => selectedTier = null),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ChoiceChip(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                    label: const Text('Major Banks'),
                    selected: selectedTier == BankTier.major,
                    onSelected: (_) =>
                        setState(() => selectedTier = BankTier.major),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ChoiceChip(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                    label: const Text('Mid-Tier Banks'),
                    selected: selectedTier == BankTier.midTier,
                    onSelected: (_) =>
                        setState(() => selectedTier = BankTier.midTier),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ChoiceChip(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                    label: const Text('Small Finance'),
                    selected: selectedTier == BankTier.smallFinance,
                    onSelected: (_) =>
                        setState(() => selectedTier = BankTier.smallFinance),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.45,
              ),
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final bank = filtered[index];
                  return ListTile(
                    tileColor: palette.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.card),
                      side: BorderSide(color: palette.border),
                    ),
                    leading: CircleAvatar(
                        backgroundColor: palette.elevated,
                        child: Text(
                          bank.shortName.length > 3
                              ? bank.shortName.substring(0, 3)
                              : bank.shortName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: palette.primaryAccent,
                          ),
                        ),
                      ),
                      title: Text(bank.name),
                      subtitle: Text(
                        '${bank.shortName} · ${bank.senderCodes.take(2).join(', ')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: palette.textSecondary,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 14),
                      onTap: () => Navigator.pop(context, bank),
                    );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sheet for editing or configuring bank account details (nickname, last4, opening balance, active toggle).
class _BankDetailsEditorSheet extends StatefulWidget {
  const _BankDetailsEditorSheet({
    this.bank,
    this.existing,
  });

  final BankCatalogueItem? bank;
  final PaymentSource? existing;

  @override
  State<_BankDetailsEditorSheet> createState() =>
      _BankDetailsEditorSheetState();
}

class _BankDetailsEditorSheetState extends State<_BankDetailsEditorSheet> {
  late TextEditingController nicknameCtrl;
  late TextEditingController last4Ctrl;
  late TextEditingController openingBalanceCtrl;
  late bool isActive;
  String? error;

  @override
  void initState() {
    super.initState();
    nicknameCtrl = TextEditingController(text: widget.existing?.nickname ?? '');
    last4Ctrl = TextEditingController(
        text: widget.existing?.accountNumberLast4 ?? '');
    openingBalanceCtrl = TextEditingController(
      text: widget.existing != null
          ? minorToInput(widget.existing!.openingBalanceMinor)
          : '0',
    );
    isActive = widget.existing?.isActive ?? true;
  }

  @override
  void dispose() {
    nicknameCtrl.dispose();
    last4Ctrl.dispose();
    openingBalanceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.lumaPalette;
    final bankName =
        widget.existing?.bankName ?? widget.bank?.name ?? 'Bank Account';
    final bankIdentifier = widget.existing?.bankIdentifier ?? widget.bank?.id;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existing != null ? 'Edit Bank Account' : 'Account Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              bankName,
              style: TextStyle(
                color: palette.primaryAccent,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: nicknameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Account Nickname (Optional)',
                hintText: 'e.g. Salary, Emergency, Savings',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: last4Ctrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: 'Last 4 digits of Account Number (Optional)',
                hintText: 'e.g. 4589',
                counterText: '',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: openingBalanceCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Opening Balance',
                prefixText: '₹ ',
                errorText: error,
                helperText: 'Initial amount available in this account',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile(
              tileColor: palette.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.card),
                side: BorderSide(color: palette.border),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: const Text('Account Active'),
              subtitle: Text(
                'Include in combined homepage balance calculation',
                style: TextStyle(color: palette.textSecondary, fontSize: 12),
              ),
              value: isActive,
              onChanged: (val) => setState(() => isActive = val),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Save Account',
                onPressed: () {
                  final parsedBalance =
                      parseAmountToMinor(openingBalanceCtrl.text);
                  final last4Text = last4Ctrl.text.trim();
                  if (last4Text.isNotEmpty &&
                      !RegExp(r'^\d{3,4}$').hasMatch(last4Text)) {
                    setState(
                        () => error = 'Enter valid 3 or 4 digits if provided');
                    return;
                  }

                  final now = DateTime.now();
                  final result = PaymentSource(
                    id: widget.existing?.id ?? 0,
                    type: PaymentSourceType.bank,
                    bankName: bankName,
                    bankIdentifier: bankIdentifier,
                    nickname: nicknameCtrl.text.trim().isEmpty
                        ? null
                        : nicknameCtrl.text.trim(),
                    accountNumberLast4:
                        last4Text.isEmpty ? null : last4Text,
                    openingBalanceMinor: parsedBalance,
                    isActive: isActive,
                    createdAt: widget.existing?.createdAt ?? now,
                    updatedAt: now,
                  );
                  Navigator.pop(context, result);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletEditorSheet extends StatefulWidget {
  const _WalletEditorSheet({required this.wallet});

  final PaymentSource wallet;

  @override
  State<_WalletEditorSheet> createState() => _WalletEditorSheetState();
}

class _WalletEditorSheetState extends State<_WalletEditorSheet> {
  late TextEditingController nameCtrl;
  late TextEditingController openingBalanceCtrl;
  late bool isActive;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.wallet.nickname ?? 'Cash Wallet');
    openingBalanceCtrl = TextEditingController(
      text: minorToInput(widget.wallet.openingBalanceMinor),
    );
    isActive = widget.wallet.isActive;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    openingBalanceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.lumaPalette;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage Physical Cash Wallet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Physical cash in hand and wallet balance tracking',
              style: TextStyle(color: palette.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Wallet Name',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: openingBalanceCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Opening Cash Balance',
                prefixText: '₹ ',
                helperText: 'Initial cash in hand before tracked transactions',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile(
              tileColor: palette.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.card),
                side: BorderSide(color: palette.border),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: const Text('Wallet Active'),
              subtitle: Text(
                'Include in combined homepage balance calculation',
                style: TextStyle(color: palette.textSecondary, fontSize: 12),
              ),
              value: isActive,
              onChanged: (val) => setState(() => isActive = val),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Save Cash Wallet',
                onPressed: () {
                  final parsedBalance =
                      parseAmountToMinor(openingBalanceCtrl.text);
                  final updated = widget.wallet.copyWith(
                    nickname: nameCtrl.text.trim().isEmpty
                        ? 'Cash Wallet'
                        : nameCtrl.text.trim(),
                    openingBalanceMinor: parsedBalance,
                    isActive: isActive,
                    updatedAt: DateTime.now(),
                  );
                  Navigator.pop(context, updated);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransferMoneySheet extends ConsumerStatefulWidget {
  const _TransferMoneySheet();

  @override
  ConsumerState<_TransferMoneySheet> createState() =>
      _TransferMoneySheetState();
}

class _TransferMoneySheetState extends ConsumerState<_TransferMoneySheet> {
  int? fromSourceId;
  int? toSourceId;
  final amountCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  String? error;

  @override
  void dispose() {
    amountCtrl.dispose();
    noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.lumaPalette;
    final sourceController = ref.watch(sourceControllerProvider);
    final activeSources = sourceController.activeSources;

    if (activeSources.length < 2) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline_rounded, size: 40),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Need at least 2 active sources',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              'Add another bank account or enable cash wallet to transfer between sources.',
              textAlign: TextAlign.center,
              style: TextStyle(color: palette.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      );
    }

    fromSourceId ??= activeSources.first.id;
    toSourceId ??=
        activeSources.firstWhere((s) => s.id != fromSourceId).id;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transfer Money',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Move money between bank accounts or ATM cash withdrawal. Internal transfers never inflate income or expenses.',
              style: TextStyle(color: palette.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: fromSourceId,
                    decoration: const InputDecoration(labelText: 'From Source'),
                    items: activeSources.map((s) {
                      return DropdownMenuItem(
                        value: s.id,
                        child: Text(s.shortLabel, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        fromSourceId = val;
                        if (toSourceId == fromSourceId) {
                          toSourceId = activeSources
                              .firstWhere((s) => s.id != fromSourceId)
                              .id;
                        }
                      });
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward_rounded, size: 20),
                ),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: toSourceId,
                    decoration: const InputDecoration(labelText: 'To Source'),
                    items: activeSources
                        .where((s) => s.id != fromSourceId)
                        .map((s) {
                      return DropdownMenuItem(
                        value: s.id,
                        child: Text(s.shortLabel, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => toSourceId = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Transfer Amount',
                prefixText: '₹ ',
                errorText: error,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: noteCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Note (Optional)',
                hintText: 'e.g. ATM cash withdrawal, self transfer',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Confirm Transfer',
                onPressed: () async {
                  final amount = parseAmountToMinor(amountCtrl.text);
                  if (amount <= 0) {
                    setState(
                        () => error = 'Enter an amount greater than ₹0');
                    return;
                  }
                  if (fromSourceId == null ||
                      toSourceId == null ||
                      fromSourceId == toSourceId) {
                    setState(() => error = 'Choose two different sources');
                    return;
                  }

                  final sController = ref.read(sourceControllerProvider);
                  final eController = ref.read(expenseControllerProvider);
                  final fromSource = sController.byId(fromSourceId);
                  if (fromSource != null) {
                    final fromBal = sController.balanceFor(
                      fromSource.id,
                      eController.expenses,
                    );
                    if (fromBal < amount) {
                      final proceed = await confirmInsufficientBalance(
                        context: context,
                        source: fromSource,
                        currentBalanceMinor: fromBal,
                        amountMinor: amount,
                      );
                      if (!proceed) return;
                    }
                  }

                  await ref.read(sourceControllerProvider).createTransfer(
                        fromSourceId: fromSourceId!,
                        toSourceId: toSourceId!,
                        amountMinor: amount,
                        note: noteCtrl.text.trim(),
                      );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Transfer recorded successfully.')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
