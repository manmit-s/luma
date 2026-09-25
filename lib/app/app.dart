import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'dart:async';

import '../application/expense_controller.dart';
import '../core/utils/format.dart';
import '../data/services/app_settings_store.dart';
import '../domain/entities/category.dart';
import '../domain/entities/expense.dart';
import '../services/notification/notification_service.dart';
import '../services/permissions/sms_permission_service.dart';
import 'theme/app_theme.dart';
import 'widgets/amount_display.dart';
import 'widgets/category_chip.dart';
import 'widgets/expense_cards.dart';
import 'widgets/luma_buttons.dart';
import 'widgets/luma_nav_bar.dart';
import 'widgets/onboarding_sheet.dart';
import 'widgets/section_header.dart';
import 'widgets/sms_permission_flow.dart';
import 'widgets/summary_card.dart';

final expenseControllerProvider = ChangeNotifierProvider<ExpenseController>(
  (ref) => ExpenseController(),
);

final appSettingsStoreProvider = Provider<AppSettingsStore>(
  (ref) => AppSettingsStore(null),
);

final lumaNavigatorKey = GlobalKey<NavigatorState>();

class LumaApp extends ConsumerStatefulWidget {
  const LumaApp({super.key});

  @override
  ConsumerState<LumaApp> createState() => _LumaAppState();
}

class _LumaAppState extends ConsumerState<LumaApp> {
  LumaTab tab = LumaTab.home;
  ExpenseController? _observedController;

  @override
  void initState() {
    super.initState();
    notificationService.onTap = _handleNotificationTap;
    _observedController = ref.read(expenseControllerProvider);
    _observedController!.addListener(_syncPendingSummary);
    Future.microtask(_loadInitialData);
  }

  @override
  void dispose() {
    _observedController?.removeListener(_syncPendingSummary);
    super.dispose();
  }

  void _syncPendingSummary() {
    final count = ref.read(expenseControllerProvider).pending.length;
    unawaited(notificationService.syncPendingSummary(count));
  }

  void _handleNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) return;
    if (payload == 'pending') {
      setState(() => tab = LumaTab.home);
      return;
    }
    final id = int.tryParse(payload);
    if (id == null) return;
    final context = lumaNavigatorKey.currentContext;
    if (context == null) return;
    final controller = ref.read(expenseControllerProvider);
    final matches = controller.expenses.where((e) => e.id == id).toList();
    if (matches.isEmpty) {
      setState(() => tab = LumaTab.home);
      return;
    }
    setState(() => tab = LumaTab.home);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = lumaNavigatorKey.currentContext;
      if (ctx == null) return;
      showCompleteExpense(ctx, ref, matches.first);
    });
  }

  Future<void> _loadInitialData() async {
    final controller = ref.read(expenseControllerProvider);
    await notificationService.init(onTap: _handleNotificationTap);
    // Cold start: app opened from a notification tap.
    final coldPayload =
        await notificationService.consumeLaunchPayload();
    await controller.load();
    try {
      final queued =
          await const MethodChannel(
            'luma/sms',
          ).invokeListMethod<String>('drainSmsQueue') ??
          [];
      for (final message in queued) {
        final created = await controller.processSms(message);
        if (created != null &&
            created.status == ExpenseStatus.pending) {
          await notificationService.showExpenseDetected(created);
        }
      }
    } on MissingPluginException {
      // Desktop and widget-test environments do not have the Android channel.
    }
    await notificationService
        .syncPendingSummary(controller.pending.length);
    if (coldPayload != null && coldPayload.isNotEmpty) {
      _handleNotificationTap(coldPayload);
    }
    await _maybeShowOnboarding();
  }

  Future<void> _maybeShowOnboarding() async {
    final store = ref.read(appSettingsStoreProvider);
    if (await store.isOnboardingDone()) return;
    final context = lumaNavigatorKey.currentContext;
    if (context == null) {
      await store.markOnboardingDone();
      return;
    }
    // Let the first frame settle so the sheet animates over real content.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    final contextNow = lumaNavigatorKey.currentContext;
    if (contextNow == null || !contextNow.mounted) return;
    final done = await showOnboardingSheet(
      contextNow,
      onEnableDetection: () => requestSmsPermissionFlow(contextNow, ref),
    );
    if (done) await store.markOnboardingDone();
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = ref.watch(expenseControllerProvider).pending.length;
    return MaterialApp(
      title: 'Luma',
      navigatorKey: lumaNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: buildLumaTheme(),
      home: Builder(
        builder: (innerContext) => Scaffold(
          extendBody: true,
          body: SafeArea(
            bottom: false,
          child: switch (tab) {
            LumaTab.home =>
              _HomePage(onHistory: () => setState(() => tab = LumaTab.history)),
            LumaTab.history => const _HistoryPage(),
            LumaTab.export => const _ExportPage(),
            LumaTab.settings => const _SettingsPage(),
          },
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LumaNavBar(
                current: tab,
                pendingCount: pendingCount,
                onSelect: (value) => setState(() => tab = value),
                onAdd: () => showAddExpense(innerContext, ref),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomePage extends ConsumerStatefulWidget {
  const _HomePage({required this.onHistory});

  final VoidCallback onHistory;

  @override
  ConsumerState<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<_HomePage>
    with WidgetsBindingObserver {
  SmsPermissionState? _smsState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshSmsState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshSmsState();
  }

  Future<void> _refreshSmsState() async {
    final state = await ref.read(smsPermissionServiceProvider).status();
    if (mounted) setState(() => _smsState = state);
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(expenseControllerProvider);
    final pending = controller.pending;
    final recent = controller.expenses
        .where((expense) => !expense.isPending)
        .take(4)
        .toList();
    final textTheme = Theme.of(context).textTheme;
    final showSmsBanner = _smsState == SmsPermissionState.denied ||
        _smsState == SmsPermissionState.permanentlyDenied ||
        _smsState == SmsPermissionState.restricted;

    return ListView(
      padding: AppSpacing.screenPadding.copyWith(bottom: 128),
      children: [
        const Row(
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 14,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: 6),
            Text(
              'OFFLINE · PRIVATE',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: .8,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          '${greetingFor(DateTime.now())}, Rey',
          style: textTheme.headlineSmall,
        ),
        if (showSmsBanner) ...[
          const SizedBox(height: AppSpacing.lg),
          const SmsDisabledBanner(),
        ],
        const SizedBox(height: AppSpacing.xxl),
        SummaryCard(
          monthTotal: controller.monthTotal,
          todayTotal: controller.todayTotal,
        ),
        const SizedBox(height: AppSpacing.xxxl),
        SectionHeader(
          title: 'Needs attention',
          badge: pending.isNotEmpty
              ? CountBadge('${pending.length} pending')
              : null,
        ),
        const SizedBox(height: AppSpacing.md),
        if (pending.isEmpty)
          const EmptyState(
            icon: Icons.check_circle_outline_rounded,
            title: 'All caught up',
            subtitle: 'New transaction SMS will appear here for review.',
          )
        else
          ...pending.map(
            (expense) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: PendingExpenseCard(
                expense: expense,
                onTap: () => showCompleteExpense(context, ref, expense),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.xxl),
        SectionHeader(
          title: 'Recent expenses',
          trailing:
              TextButton(onPressed: widget.onHistory, child: const Text('View all')),
        ),
        const SizedBox(height: AppSpacing.md),
        if (recent.isEmpty)
          const EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No expenses yet',
            subtitle: 'Add your first expense to start your memory.',
          )
        else
          ...recent.map(
            (expense) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ExpenseCard(
                expense: expense,
                onTap: () => showCompleteExpense(context, ref, expense),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: 'Add expense',
          icon: Icons.add_rounded,
          onPressed: () => showAddExpense(context, ref),
        ),
      ],
    );
  }
}

class _HistoryPage extends ConsumerStatefulWidget {
  const _HistoryPage();

  @override
  ConsumerState<_HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<_HistoryPage> {
  String query = '';
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(expenseControllerProvider);
    final textTheme = Theme.of(context).textTheme;
    final normalizedQuery = query.trim().toLowerCase();
    final expenses = controller.expenses.where((expense) {
      final matchesCategory =
          selectedCategory == null || expense.categoryId == selectedCategory;
      if (!matchesCategory) return false;
      if (normalizedQuery.isEmpty) return true;
      final merchant = (expense.merchant ?? '').toLowerCase();
      final note = expense.note.toLowerCase();
      return merchant.contains(normalizedQuery) ||
          note.contains(normalizedQuery);
    }).toList();

    return ListView(
      padding: AppSpacing.screenPadding.copyWith(bottom: 128),
      children: [
        Text('History', style: textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          'Every expense, in one place',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        SummaryCard(
          monthTotal: controller.monthTotal,
          expenseCount: controller.expenses.length,
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          onChanged: (value) => setState(() => query = value),
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search_rounded),
            hintText: 'Search merchant or note...',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(right: AppSpacing.xl),
          child: Row(
            children: [
              _SelectableFilterChip(
                label: 'All',
                selected: selectedCategory == null,
                onSelected: (_) => setState(() => selectedCategory = null),
              ),
              ...defaultCategories.take(5).map(
                    (category) => _SelectableFilterChip(
                      label: category.name,
                      selected: selectedCategory == category.id,
                      onSelected: (_) => setState(() => selectedCategory =
                          selectedCategory == category.id ? null : category.id),
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          '${expenses.length} ${expenses.length == 1 ? 'expense' : 'expenses'}',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (expenses.isEmpty)
          const EmptyState(
            icon: Icons.search_off_rounded,
            title: 'Nothing found',
            subtitle: 'Try a different search or category filter.',
          )
        else
          ...expenses.map(
            (expense) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ExpenseCard(
                expense: expense,
                onTap: () => showCompleteExpense(context, ref, expense),
              ),
            ),
          ),
      ],
    );
  }
}

class _SelectableFilterChip extends StatelessWidget {
  const _SelectableFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: AppSpacing.sm),
        child: FilterChip(
          label: Text(label),
          selected: selected,
          onSelected: onSelected,
          selectedColor: AppColors.plum,
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.border),
          labelStyle: TextStyle(
            color: selected ? AppColors.peach : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      );
}

class _SettingsPage extends ConsumerStatefulWidget {
  const _SettingsPage();

  @override
  ConsumerState<_SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<_SettingsPage>
    with WidgetsBindingObserver {
  bool dailyAudit = true;
  SmsPermissionState? _smsState;
  bool _checkingSms = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshSmsState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshSmsState();
  }

  Future<void> _refreshSmsState() async {
    final state = await ref.read(smsPermissionServiceProvider).status();
    if (mounted) {
      setState(() {
        _smsState = state;
        _checkingSms = false;
      });
    }
  }

  String get _smsSubtitle {
    if (_checkingSms) return 'Checking permission…';
    return switch (_smsState) {
      SmsPermissionState.granted => 'On — watching transaction SMS',
      SmsPermissionState.denied => 'Off — tap to enable',
      SmsPermissionState.permanentlyDenied =>
        'Blocked — tap for setup steps',
      SmsPermissionState.restricted =>
        'Needs restricted-settings approval — tap',
      _ => 'Not available on this device',
    };
  }

  Future<void> _onSmsTap() async {
    await requestSmsPermissionFlow(context, ref);
    await _refreshSmsState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final smsOn = _smsState == SmsPermissionState.granted;
    return ListView(
      padding: AppSpacing.screenPadding.copyWith(bottom: 128),
      children: [
        Text('Settings', style: textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          'Keep Luma working quietly in the background',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xxxl),
        Card(
          color: AppColors.surface,
          child: Column(
            children: [
              SwitchListTile(
                value: smsOn,
                onChanged: (_) => _onSmsTap(),
                title: const Text('SMS detection'),
                subtitle: Text(_smsSubtitle),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              SwitchListTile(
                value: dailyAudit,
                onChanged: (value) => setState(() => dailyAudit = value),
                title: const Text('Daily audit'),
                subtitle: const Text('Every day at 9:00 PM'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Card(
          color: AppColors.surface,
          child: ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Private by design'),
            subtitle: const Text(
              'Everything stays on this device. Exports are shared only when you choose to.',
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> showCompleteExpense(
  BuildContext context,
  WidgetRef ref,
  Expense expense,
) async {
  String category = expense.categoryId ?? '';
  final note = TextEditingController(text: expense.note);
  try {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
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
                  'Complete expense',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                AmountDisplay(expense.amountMinor, fontSize: 36),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  merchantLabel(expense.merchant),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                Text(
                  formatTime(expense.timestamp),
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
                              setModalState(() => category = item.id),
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
                                  expense,
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
        ),
      ),
    );
  } finally {
    note.dispose();
  }
}

int _parseAmountToMinor(String raw) {
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

Future<void> showAddExpense(BuildContext context, WidgetRef ref) async {
  final amount = TextEditingController();
  final merchant = TextEditingController();
  String category = 'other';
  String? error;
  try {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
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
                      setModalState(() => category = value ?? 'other'),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Save expense',
                    onPressed: () {
                      final parsed = _parseAmountToMinor(amount.text);
                      if (parsed <= 0) {
                        setModalState(
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
        ),
      ),
    );
  } finally {
    amount.dispose();
    merchant.dispose();
  }
}

class _ExportPage extends ConsumerWidget {
  const _ExportPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(expenseControllerProvider);
    final sinceLast = controller.expenses
        .where((expense) => expense.lastExportedAt == null)
        .toList();
    final sinceTotal = sinceLast.fold(0, (sum, item) => sum + item.amountMinor);
    final fullTotal =
        controller.expenses.fold(0, (sum, item) => sum + item.amountMinor);
    final textTheme = Theme.of(context).textTheme;

    void showPendingExportNotice() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'XLSX export lands next — persistence ships first.',
          ),
        ),
      );
    }

    return ListView(
      padding: AppSpacing.screenPadding.copyWith(bottom: 128),
      children: [
        Text(
          'Export expenses',
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: 6),
        Text(
          'Generate a local Excel file to share from Android.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xl),
        _ExportOption(
          title: 'Since last export',
          subtitle:
              'Export only expenses not included in a previous export.',
          detail:
              '${sinceLast.length} new ${sinceLast.length == 1 ? 'expense' : 'expenses'} · ${formatAmount(sinceTotal)}',
          emphasized: true,
          actionLabel: 'Generate XLSX',
          onPressed: sinceLast.isEmpty ? null : showPendingExportNotice,
        ),
        const SizedBox(height: AppSpacing.md),
        _ExportOption(
          title: 'Full history',
          subtitle: 'Export every recorded expense.',
          detail:
              '${controller.expenses.length} total ${controller.expenses.length == 1 ? 'expense' : 'expenses'} · ${formatAmount(fullTotal)}',
          actionLabel: 'Generate XLSX',
          onPressed:
              controller.expenses.isEmpty ? null : showPendingExportNotice,
        ),
      ],
    );
  }
}

class _ExportOption extends StatelessWidget {
  const _ExportOption({
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.actionLabel,
    this.emphasized = false,
    this.onPressed,
  });

  final String title;
  final String subtitle;
  final String detail;
  final String actionLabel;
  final bool emphasized;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (emphasized)
                    const Text(
                      'Recommended',
                      style: TextStyle(
                        color: AppColors.peach,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(detail, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: emphasized
                    ? PrimaryButton(
                        label: actionLabel,
                        icon: Icons.table_view_rounded,
                        onPressed: onPressed,
                      )
                    : PlumButton(
                        label: actionLabel,
                        icon: Icons.table_view_rounded,
                        onPressed: onPressed,
                      ),
              ),
            ],
          ),
        ),
      );
}
