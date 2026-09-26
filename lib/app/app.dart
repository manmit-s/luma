import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:async';

import '../application/expense_controller.dart';
import '../core/utils/format.dart';
import '../domain/entities/category.dart';
import '../domain/entities/expense.dart';
import '../services/export/export_service.dart';
import '../services/notification/notification_service.dart';
import '../services/permissions/sms_permission_service.dart';
import '../services/sms/sms_ingest.dart'
    show drainSmsQueue, openAutostartSettings, smsQueueSize;
import 'providers.dart';
import 'theme/app_theme.dart';
import 'widgets/amount_display.dart';
import 'widgets/category_chip.dart';
import 'widgets/expense_cards.dart';
import 'widgets/expense_sheets.dart';
import 'widgets/luma_buttons.dart';
import 'widgets/luma_nav_bar.dart';
import 'widgets/onboarding_sheet.dart';
import 'widgets/section_header.dart';
import 'widgets/sms_permission_flow.dart';
import 'widgets/summary_card.dart';

final lumaNavigatorKey = GlobalKey<NavigatorState>();

class LumaApp extends ConsumerStatefulWidget {
  const LumaApp({super.key});

  @override
  ConsumerState<LumaApp> createState() => _LumaAppState();
}

class _LumaAppState extends ConsumerState<LumaApp>
    with WidgetsBindingObserver {
  LumaTab tab = LumaTab.home;
  ExpenseController? _observedController;
  bool _draining = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    notificationService.onTap = _handleNotificationTap;
    _observedController = ref.read(expenseControllerProvider);
    _observedController!.addListener(_syncPendingSummary);
    Future.microtask(_loadInitialData);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _observedController?.removeListener(_syncPendingSummary);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_drainSmsQueue());
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
    final target = matches.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = lumaNavigatorKey.currentContext;
      if (ctx == null) return;
      openExpense(ctx, ref, target);
    });
  }

  Future<void> _loadInitialData() async {
    final controller = ref.read(expenseControllerProvider);
    await notificationService.init(onTap: _handleNotificationTap);
    // Cold start: app opened from a notification tap.
    final coldPayload =
        await notificationService.consumeLaunchPayload();
    await controller.load();
    await _drainSmsQueue();
    await notificationService
        .syncPendingSummary(controller.pending.length);
    if (coldPayload != null && coldPayload.isNotEmpty) {
      _handleNotificationTap(coldPayload);
    }
    await _ensureAuditScheduled();
    await _maybeShowOnboarding();
  }

  /// Pulls SMS queued by the native receiver into pending expenses.
  ///
  /// Runs on launch and on every foreground resume, so messages arriving
  /// while the app is backgrounded are picked up without a restart.
  /// Re-entrant calls collapse into one; duplicates are dropped by the
  /// repository's fingerprint/reference check.
  Future<void> _drainSmsQueue() async {
    if (_draining) return;
    _draining = true;
    try {
      await drainSmsQueue(ref);
    } finally {
      _draining = false;
    }
  }

  /// Re-asserts the exact alarm on every launch so a reboot (which wipes
  /// alarms) is healed as soon as the app opens. The native receiver also
  /// reschedules on BOOT_COMPLETED without needing the app open.
  Future<void> _ensureAuditScheduled() async {
    try {
      final store = ref.read(appSettingsStoreProvider);
      if (!await store.isDailyAuditEnabled()) return;
      final (hour, minute) = await store.auditTime();
      await ref.read(dailyAuditServiceProvider).schedule(hour, minute);
    } catch (_) {
      // Audit scheduling is best-effort.
    }
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
  String _userName = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshSmsState();
    _refreshUserName();
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

  Future<void> _refreshUserName() async {
    final name = await ref.read(appSettingsStoreProvider).userName();
    if (mounted) setState(() => _userName = name);
  }

  String _greeting() {
    final base = greetingFor(DateTime.now());
    return _userName.isEmpty ? base : '$base, $_userName';
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
              'SECURE · PRIVATE',
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
          _greeting(),
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
                onTap: () => openExpense(context, ref, expense),
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
              ...defaultCategories.map(
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
          ...groupExpensesByDay(expenses).map(
            (group) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppSpacing.sm, left: 4),
                    child: Text(
                      formatDayLabel(group.$1),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
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
                        onTap: () => openExpense(context, ref, expense),
                      ),
                    ),
                  ),
                ],
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
  bool _loadingAudit = true;
  String _userName = '';
  bool _loadingName = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshSmsState();
    _loadAuditState();
    _loadUserName();
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

  Future<void> _loadAuditState() async {
    final enabled =
        await ref.read(appSettingsStoreProvider).isDailyAuditEnabled();
    if (mounted) {
      setState(() {
        dailyAudit = enabled;
        _loadingAudit = false;
      });
    }
  }

  Future<void> _loadUserName() async {
    final name = await ref.read(appSettingsStoreProvider).userName();
    if (mounted) {
      setState(() {
        _userName = name;
        _loadingName = false;
      });
    }
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _userName);
    try {
      final saved = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.elevated,
          title: const Text('Your name'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            maxLength: 24,
            decoration: const InputDecoration(
              hintText: 'What should Luma call you?',
            ),
            onSubmitted: (_) => Navigator.pop(context, true),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        ),
      );
      if (saved != true || !mounted) return;
      final name = controller.text.trim();
      await ref.read(appSettingsStoreProvider).setUserName(name);
      if (mounted) setState(() => _userName = name);
    } finally {
      controller.dispose();
    }
  }

  Future<void> _setAudit(bool enabled) async {
    setState(() => dailyAudit = enabled);
    await ref.read(appSettingsStoreProvider).setDailyAuditEnabled(enabled);
    final audit = ref.read(dailyAuditServiceProvider);
    if (enabled) {
      final (hour, minute) =
          await ref.read(appSettingsStoreProvider).auditTime();
      await audit.schedule(hour, minute);
    } else {
      await audit.cancel();
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
                onChanged: _loadingAudit ? null : _setAudit,
                title: const Text('Daily audit'),
                subtitle: const Text('Every day at 9:00 PM'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const _SmsDiagnosticsCard(),
        const SizedBox(height: AppSpacing.lg),
        Card(
          color: AppColors.surface,
          child: ListTile(
            leading: const Icon(Icons.person_outline_rounded),
            title: const Text('Your name'),
            subtitle: Text(
              _loadingName
                  ? 'Loading…'
                  : _userName.isEmpty
                      ? 'Not set — tap to add'
                      : _userName,
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
            onTap: _editName,
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

/// Shows where an SMS can get stuck: permission → phone queue → parse.
///
/// Each row maps to one stage of the watch chain, so a missed transaction
/// can be localized without a computer.
class _SmsDiagnosticsCard extends ConsumerStatefulWidget {
  const _SmsDiagnosticsCard();

  @override
  ConsumerState<_SmsDiagnosticsCard> createState() =>
      _SmsDiagnosticsCardState();
}

class _SmsDiagnosticsCardState extends ConsumerState<_SmsDiagnosticsCard> {
  int? _queued;
  bool _checkingQueue = false;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _refreshQueue();
  }

  Future<void> _refreshQueue() async {
    setState(() => _checkingQueue = true);
    final count = await smsQueueSize();
    if (mounted) {
      setState(() {
        _queued = count;
        _checkingQueue = false;
      });
    }
  }

  Future<void> _processNow() async {
    setState(() => _processing = true);
    try {
      final created = await drainSmsQueue(ref);
      await _refreshQueue();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            created > 0
                ? 'Imported $created pending ${created == 1 ? 'expense' : 'expenses'}.'
                : 'Queue empty — nothing new to import.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _openBackgroundStart() async {
    final opened = await openAutostartSettings();
    if (!mounted) return;
    if (!opened) {
      showModalBottomSheet<void>(
        context: context,
        builder: (context) => const SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Let Luma start in background',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Xiaomi / Oppo / Vivo / Realme / Samsung block background '
                  'receivers by default. Open system Settings → Apps → Luma '
                  'and enable Autostart (or “Allow background activity” / '
                  '“Unrestricted” battery), then return here.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final queueLabel = _checkingQueue
        ? 'Checking…'
        : _queued == null
            ? 'Unknown on this device'
            : _queued == 0
                ? 'Empty — receiver caught up'
                : '$_queued waiting — tap Process now';
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SMS diagnostics',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  onPressed: _checkingQueue ? null : _refreshQueue,
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Phone queue: $queueLabel',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _processing ? null : _processNow,
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: Text(
                      _processing ? 'Working…' : 'Process now',
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openBackgroundStart,
                    icon: const Icon(Icons.battery_saver_outlined, size: 18),
                    label: const Text('Background start'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Opens the right sheet for an expense: complete-flow for pending,
/// read-only detail (SPEC 28) for everything else.
Future<void> openExpense(BuildContext context, WidgetRef ref, Expense expense) {
  if (expense.isPending) return showCompleteExpense(context, ref, expense);
  return showExpenseDetail(context, ref, expense);
}

String _sourceLabel(ExpenseSource source) => switch (source) {
      ExpenseSource.sms => 'SMS detected',
      ExpenseSource.manual => 'Manually added',
    };

String _txLabel(Expense e) => switch (e.transactionType) {
      TransactionType.debit => 'Expense',
      TransactionType.credit => 'Income',
      TransactionType.unknown => 'Unknown',
    };

Future<void> showExpenseDetail(
  BuildContext context,
  WidgetRef ref,
  Expense expense,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Expense detail',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                CategoryChip(
                  label: categoryName(expense.categoryId),
                  compact: true,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AmountDisplay(expense.amountMinor, fontSize: 36),
            const SizedBox(height: AppSpacing.xs),
            Text(
              merchantLabel(expense.merchant),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${formatDayLabel(expense.timestamp)} · ${formatTime(expense.timestamp)}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            if (expense.note.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(expense.note.trim()),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            _DetailRow(
              label: 'Type',
              value: _txLabel(expense),
            ),
            if (expense.referenceNumber?.isNotEmpty ?? false)
              _DetailRow(label: 'Reference', value: expense.referenceNumber!),
            _DetailRow(label: 'Source', value: _sourceLabel(expense.source)),
            if ((expense.lastExportedAt) != null)
              const _DetailRow(label: 'Export', value: 'Included in an export'),
            if (expense.rawSms?.isNotEmpty ?? false)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text(
                  'Raw SMS (debug)',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    padding: AppSpacing.cardPadding,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadii.card),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      expense.rawSms!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'Edit',
                    icon: Icons.edit_outlined,
                    onPressed: () {
                      Navigator.pop(context);
                      showEditExpense(context, ref, expense);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _confirmDelete(context, ref, expense),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadii.card),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(width: AppSpacing.lg),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  Expense expense,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.elevated,
      title: const Text('Delete expense?'),
      content: Text(
        '${formatAmount(expense.amountMinor)} · ${merchantLabel(expense.merchant)} will be removed permanently.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  await ref.read(expenseControllerProvider).deleteExpense(expense.id);
  if (!context.mounted) return;
  Navigator.pop(context);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Expense deleted.')),
  );
}

class _ExportPage extends ConsumerStatefulWidget {
  const _ExportPage();

  @override
  ConsumerState<_ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends ConsumerState<_ExportPage> {
  ExportMode? _busy;

  Future<void> _runExport(ExportMode mode) async {
    final service = ref.read(exportServiceProvider);
    if (_busy != null) return;
    if (service == null) {
      debugPrint('Luma export: no ExportService provided');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export is unavailable right now.')),
      );
      return;
    }
    setState(() => _busy = mode);
    try {
      final result = await service.generate(mode);
      // Refresh counts so "since last export" drops to zero.
      await ref.read(expenseControllerProvider).load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Exported ${result.count} ${result.count == 1 ? 'expense' : 'expenses'} — choose an app to share.',
          ),
        ),
      );
      try {
        await service.share(result);
      } catch (e) {
        debugPrint('Luma export: share failed: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File saved: ${result.file.path.split('/').last}. '
                'Sharing failed — find it in the app temp folder.'),
          ),
        );
      }
    } on ExportException catch (e) {
      debugPrint('Luma export: ${e.userMessage}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.userMessage)),
      );
    } catch (e) {
      debugPrint('Luma export: unexpected failure: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not create the Excel file.')),
      );
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(expenseControllerProvider);
    final sinceLast = controller.unexported;
    final sinceTotal = sinceLast.fold(0, (sum, item) => sum + item.amountMinor);
    final fullTotal =
        controller.expenses.fold(0, (sum, item) => sum + item.amountMinor);
    final textTheme = Theme.of(context).textTheme;

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
          actionLabel:
              _busy == ExportMode.incremental ? 'Generating…' : 'Generate XLSX',
          onPressed: sinceLast.isEmpty || _busy != null
              ? null
              : () => _runExport(ExportMode.incremental),
        ),
        const SizedBox(height: AppSpacing.md),
        _ExportOption(
          title: 'Full history',
          subtitle: 'Export every recorded expense.',
          detail:
              '${controller.expenses.length} total ${controller.expenses.length == 1 ? 'expense' : 'expenses'} · ${formatAmount(fullTotal)}',
          actionLabel:
              _busy == ExportMode.full ? 'Generating…' : 'Generate XLSX',
          onPressed: controller.expenses.isEmpty || _busy != null
              ? null
              : () => _runExport(ExportMode.full),
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
