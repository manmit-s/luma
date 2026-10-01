import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/format.dart';
import '../../domain/entities/subscription.dart';
import '../providers.dart';
import '../theme/app_theme.dart';
import 'amount_display.dart';
import 'category_chip.dart';
import 'expense_sheets.dart' show parseAmountToMinor, minorToInput;
import 'luma_buttons.dart';
import 'section_header.dart';

/// Section displayed on the Home screen showing the next 1-3 upcoming subscription renewals.
class UpcomingSubscriptionsSection extends ConsumerWidget {
  const UpcomingSubscriptionsSection({super.key});

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diffDays = target.difference(today).inDays;

    if (diffDays == 0) return 'Today';
    if (diffDays == 1) return 'Tomorrow';
    if (diffDays > 1 && diffDays <= 7) return 'In $diffDays days';
    return formatDate(date);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subController = ref.watch(subscriptionControllerProvider);
    final upcoming = subController.upcomingPayments.take(3).toList();
    if (upcoming.isEmpty) return const SizedBox.shrink();

    final subsById = {
      for (final s in subController.subscriptions) s.id: s,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xxl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Upcoming renewals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                CountBadge('${upcoming.length}'),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SubscriptionsPage(),
                  ),
                );
              },
              child: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ...upcoming.map((payment) {
          final sub = subsById[payment.subscriptionId];
          final name = sub?.name ?? 'Subscription';
          final isAutopay = sub?.paymentMethod == PaymentMethod.autopay;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.card),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  if (sub != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SubscriptionDetailPage(subscriptionId: sub.id),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.plum.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.repeat_rounded,
                          color: AppColors.peach,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  'Due ${_formatDueDate(payment.expectedDate)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                if (isAutopay) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.elevated,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Autopay',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.peach,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      AmountDisplay(payment.expectedAmountMinor, fontSize: 16),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

/// Full screen listing of all subscriptions (Active and Cancelled/Past).
class SubscriptionsPage extends ConsumerWidget {
  const SubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subController = ref.watch(subscriptionControllerProvider);
    final active = subController.subscriptions.where((s) => s.status.isOngoing).toList();
    final past = subController.subscriptions.where((s) => !s.status.isOngoing).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Subscriptions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.peach),
            tooltip: 'Add subscription',
            onPressed: () => showAddEditSubscription(context, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.peach,
        foregroundColor: AppColors.onCta,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Subscription'),
        onPressed: () => showAddEditSubscription(context, ref),
      ),
      body: subController.subscriptions.isEmpty
          ? Center(
              child: EmptyState(
                icon: Icons.repeat_rounded,
                title: 'No subscriptions yet',
                subtitle:
                    'Track your recurring Netflix, Spotify, or utility payments.',
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                if (active.isNotEmpty) ...[
                  Row(
                    children: [
                      const Text(
                        'Active Subscriptions',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CountBadge('${active.length}'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...active.map((sub) => _SubscriptionListCard(sub: sub)),
                  const SizedBox(height: 20),
                ],
                if (past.isNotEmpty) ...[
                  Row(
                    children: [
                      const Text(
                        'Past & Cancelled',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CountBadge('${past.length}'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...past.map((sub) => _SubscriptionListCard(sub: sub)),
                ],
              ],
            ),
    );
  }
}

class _SubscriptionListCard extends StatelessWidget {
  const _SubscriptionListCard({required this.sub});

  final Subscription sub;

  @override
  Widget build(BuildContext context) {
    final isCancelled = sub.isCancelled;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SubscriptionDetailPage(subscriptionId: sub.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isCancelled
                        ? AppColors.surfaceLow
                        : AppColors.plum.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppRadii.compact),
                  ),
                  child: Icon(
                    isCancelled ? Icons.pause_circle_outline_rounded : Icons.repeat_rounded,
                    color: isCancelled ? AppColors.textMuted : AppColors.peach,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sub.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isCancelled ? AppColors.textSecondary : AppColors.textPrimary,
                          decoration: isCancelled ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            sub.billingCycle.label,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('•', style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.5))),
                          const SizedBox(width: 6),
                          Text(
                            isCancelled
                                ? 'Cancelled'
                                : 'Next: ${formatDate(sub.nextRenewalDate)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isCancelled ? AppColors.error : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AmountDisplay(sub.amountMinor, fontSize: 16),
                    const SizedBox(height: 2),
                    Text(
                      sub.paymentMethod == PaymentMethod.autopay ? 'Autopay' : 'Manual',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: sub.paymentMethod == PaymentMethod.autopay
                            ? AppColors.peach
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Detailed view for a specific subscription.
class SubscriptionDetailPage extends ConsumerWidget {
  const SubscriptionDetailPage({super.key, required this.subscriptionId});

  final int subscriptionId;

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref, Subscription sub) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.elevated,
        title: const Text('Cancel subscription?'),
        content: Text(
          'Future expected payments and reminder notifications for "${sub.name}" will stop. All previous recorded expenses will remain intact.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Active'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Cancel Subscription'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(subscriptionControllerProvider).cancelSubscription(sub.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subscription "${sub.name}" cancelled.')),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Subscription sub) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.elevated,
        title: const Text('Delete subscription?'),
        content: Text(
          'This will permanently remove the subscription record and uncompleted upcoming schedule for "${sub.name}". Past actual expenses are unaffected.',
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
      await ref.read(subscriptionControllerProvider).deleteSubscription(sub.id);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subscription "${sub.name}" deleted.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subController = ref.watch(subscriptionControllerProvider);
    final expenseController = ref.watch(expenseControllerProvider);

    final sub = subController.subscriptions.cast<Subscription?>().firstWhere(
          (s) => s?.id == subscriptionId,
          orElse: () => null,
        );

    if (sub == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(),
        body: const Center(child: Text('Subscription not found')),
      );
    }

    final payments = subController.expectedPayments
        .where((p) => p.subscriptionId == sub.id)
        .toList()
      ..sort((a, b) => a.expectedDate.compareTo(b.expectedDate));

    final upcomingPayments = payments.where((p) => p.isUpcoming).toList();
    final matchedPayments = payments.where((p) => p.isMatched).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(sub.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit subscription',
            onPressed: () => showAddEditSubscription(context, ref, subscription: sub),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            tooltip: 'Delete subscription',
            onPressed: () => _confirmDelete(context, ref, sub),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        children: [
          // Hero Summary Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
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
                      sub.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: sub.status.isOngoing
                            ? AppColors.plum.withValues(alpha: 0.4)
                            : AppColors.surfaceLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: sub.status.isOngoing ? AppColors.peach : AppColors.border,
                        ),
                      ),
                      child: Text(
                        sub.status.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: sub.status.isOngoing ? AppColors.peach : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    AmountDisplay(sub.amountMinor, fontSize: 32),
                    const SizedBox(width: 8),
                    Text(
                      '/ ${sub.billingCycle.label.toLowerCase()}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.md),
                _DetailRow(
                  label: 'Payment Method',
                  value: sub.paymentMethod == PaymentMethod.autopay ? 'Autopay' : 'Manual Payment',
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  label: 'Next Renewal Date',
                  value: formatDate(sub.nextRenewalDate),
                ),
                if (sub.merchantPattern != null && sub.merchantPattern!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _DetailRow(
                    label: 'SMS Match Pattern',
                    value: sub.merchantPattern!,
                  ),
                ],
                const SizedBox(height: 8),
                _DetailRow(
                  label: 'Cancellation Reminder',
                  value: sub.cancellationReminderEnabled
                      ? '${sub.cancellationReminderDaysBefore} days before'
                      : 'Disabled',
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  label: 'Payment Reminder',
                  value: sub.paymentReminderEnabled
                      ? '${sub.paymentReminderDaysBefore} days before'
                      : 'Disabled',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Action button (Cancel subscription if active)
          if (sub.status.isOngoing)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.card),
                  ),
                ),
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text('Cancel Subscription'),
                onPressed: () => _confirmCancel(context, ref, sub),
              ),
            ),

          const SizedBox(height: AppSpacing.xl),

          // Upcoming Scheduled Payments
          const Text(
            'Upcoming Schedule',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (upcomingPayments.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.card),
              ),
              child: const Text(
                'No upcoming payments scheduled.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            )
          else
            ...upcomingPayments.map(
              (p) => Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatDate(p.expectedDate),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Expected',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.peach,
                          ),
                        ),
                      ],
                    ),
                    AmountDisplay(p.expectedAmountMinor, fontSize: 15),
                  ],
                ),
              ),
            ),

          const SizedBox(height: AppSpacing.xl),

          // Historical Matched Expenses
          const Text(
            'Payment History',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (matchedPayments.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.card),
              ),
              child: const Text(
                'No payments matched yet. Incoming debit SMS matching this subscription will appear here.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            )
          else
            ...matchedPayments.map((p) {
              final exp = p.matchedExpenseId != null
                  ? expenseController.expenses.cast<dynamic>().firstWhere(
                        (e) => e.id == p.matchedExpenseId,
                        orElse: () => null,
                      )
                  : null;

              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatDate(p.expectedDate),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 13,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              exp != null ? 'Paid via ${exp.source.name}' : 'Matched',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    AmountDisplay(
                      exp != null ? exp.amountMinor : p.expectedAmountMinor,
                      fontSize: 15,
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Modal bottom sheet to create or edit a subscription.
Future<void> showAddEditSubscription(
  BuildContext context,
  WidgetRef ref, {
  Subscription? subscription,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    builder: (_) => _AddEditSubscriptionSheet(subscription: subscription),
  );
}

class _AddEditSubscriptionSheet extends ConsumerStatefulWidget {
  const _AddEditSubscriptionSheet({this.subscription});

  final Subscription? subscription;

  @override
  ConsumerState<_AddEditSubscriptionSheet> createState() =>
      _AddEditSubscriptionSheetState();
}

class _AddEditSubscriptionSheetState
    extends ConsumerState<_AddEditSubscriptionSheet> {
  late TextEditingController nameController;
  late TextEditingController amountController;
  late TextEditingController patternController;

  late BillingCycle billingCycle;
  late PaymentMethod paymentMethod;
  late DateTime nextRenewalDate;
  late bool cancelReminder;
  late bool paymentReminder;

  String? error;

  @override
  void initState() {
    super.initState();
    final sub = widget.subscription;
    nameController = TextEditingController(text: sub?.name ?? '');
    amountController = TextEditingController(
      text: sub != null ? minorToInput(sub.amountMinor) : '',
    );
    patternController = TextEditingController(text: sub?.merchantPattern ?? '');
    billingCycle = sub?.billingCycle ?? BillingCycle.monthly;
    paymentMethod = sub?.paymentMethod ?? PaymentMethod.autopay;
    nextRenewalDate = sub?.nextRenewalDate ??
        DateTime.now().add(const Duration(days: 30));
    cancelReminder = sub?.cancellationReminderEnabled ?? false;
    paymentReminder = sub?.paymentReminderEnabled ?? true;
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    patternController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: nextRenewalDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.peach,
              onPrimary: AppColors.onCta,
              surface: AppColors.elevated,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => nextRenewalDate = picked);
    }
  }

  Future<void> _save() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      setState(() => error = 'Please enter a subscription name');
      return;
    }
    final amountMinor = parseAmountToMinor(amountController.text);
    if (amountMinor <= 0) {
      setState(() => error = 'Please enter a valid amount');
      return;
    }

    final subController = ref.read(subscriptionControllerProvider);

    if (widget.subscription == null) {
      await subController.createSubscription(
        name: name,
        merchantPattern: patternController.text.trim().isEmpty
            ? name
            : patternController.text.trim(),
        amountMinor: amountMinor,
        billingCycle: billingCycle,
        paymentMethod: paymentMethod,
        startDate: DateTime.now(),
        nextRenewalDate: nextRenewalDate,
        cancellationReminderEnabled: cancelReminder,
        paymentReminderEnabled: paymentReminder,
      );
    } else {
      final updated = widget.subscription!.copyWith(
        name: name,
        merchantPattern: patternController.text.trim().isEmpty
            ? name
            : patternController.text.trim(),
        amountMinor: amountMinor,
        billingCycle: billingCycle,
        paymentMethod: paymentMethod,
        nextRenewalDate: nextRenewalDate,
        cancellationReminderEnabled: cancelReminder,
        paymentReminderEnabled: paymentReminder,
        updatedAt: DateTime.now(),
      );
      await subController.updateSubscription(updated);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.subscription != null;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? 'Edit subscription' : 'New subscription',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (error != null) ...[
              Text(
                error!,
                style: const TextStyle(color: AppColors.error, fontSize: 13),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. YouTube Premium, Netflix, Spotify',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount (₹)',
                hintText: '129.00',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: patternController,
              decoration: const InputDecoration(
                labelText: 'SMS Merchant Keyword (Optional)',
                hintText: 'e.g. GOOGLE, YOUTUBE, NETFLIX',
                helperText: 'Used to auto-match bank debit SMS with this subscription',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Billing Cycle
            const Text(
              'Billing cycle',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: 8,
              children: BillingCycle.values.map((cycle) {
                final isSelected = billingCycle == cycle;
                return ChoiceChip(
                  label: Text(cycle.label),
                  selected: isSelected,
                  selectedColor: AppColors.plum,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => billingCycle = cycle);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),

            // Payment Method
            const Text(
              'Payment method',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: paymentMethod == PaymentMethod.autopay
                          ? AppColors.plum
                          : Colors.transparent,
                      side: BorderSide(
                        color: paymentMethod == PaymentMethod.autopay
                            ? AppColors.peach
                            : AppColors.border,
                      ),
                    ),
                    onPressed: () =>
                        setState(() => paymentMethod = PaymentMethod.autopay),
                    child: const Text('Autopay'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: paymentMethod == PaymentMethod.manual
                          ? AppColors.plum
                          : Colors.transparent,
                      side: BorderSide(
                        color: paymentMethod == PaymentMethod.manual
                            ? AppColors.peach
                            : AppColors.border,
                      ),
                    ),
                    onPressed: () =>
                        setState(() => paymentMethod = PaymentMethod.manual),
                    child: const Text('Manual'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Next Renewal Date
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Next renewal date'),
              subtitle: Text(formatDate(nextRenewalDate)),
              trailing: const Icon(Icons.calendar_today_rounded, size: 20),
              onTap: _pickDate,
            ),
            const Divider(height: 1),

            // Reminders
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: paymentReminder,
              onChanged: (val) => setState(() => paymentReminder = val),
              title: const Text('Payment reminder'),
              subtitle: const Text('Notify 1 day before scheduled renewal'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: cancelReminder,
              onChanged: (val) => setState(() => cancelReminder = val),
              title: const Text('Cancellation reminder'),
              subtitle: const Text('Notify 3 days before renewal'),
            ),
            const SizedBox(height: AppSpacing.lg),

            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: isEdit ? 'Save Changes' : 'Create Subscription',
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
