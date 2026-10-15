import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:async';

import '../application/expense_controller.dart';
import '../core/utils/format.dart';
import '../domain/entities/category.dart';
import '../domain/entities/expense.dart';
import '../domain/services/sms_transaction_parser.dart';
import '../services/export/export_service.dart';
import '../services/notification/notification_service.dart';
import '../services/permissions/sms_permission_service.dart';
import '../services/sms/sms_ingest.dart'
    show
        drainSmsQueue,
        openAutostartSettings,
        scanInboxSms,
        smsQueueSize;
import 'providers.dart';
import 'theme/app_theme.dart';
import 'widgets/amount_display.dart';
import 'widgets/balance_card.dart';
import 'widgets/category_chip.dart';
import 'widgets/expense_cards.dart';
import 'widgets/expense_sheets.dart';
import 'widgets/first_launch_flow.dart';
import 'widgets/luma_buttons.dart';
import 'widgets/luma_nav_bar.dart';
import 'widgets/onboarding_sheet.dart';
import 'widgets/section_header.dart';
import 'widgets/sms_permission_flow.dart';
import 'widgets/splash_screen.dart';
import 'widgets/subscription_views.dart';
import 'widgets/summary_card.dart';

final lumaNavigatorKey = GlobalKey<NavigatorState>();

class LumaApp extends ConsumerStatefulWidget {
  const LumaApp({super.key, this.skipSplash = false});

  final bool skipSplash;

  @override
  ConsumerState<LumaApp> createState() => _LumaAppState();
}

class _LumaAppState extends ConsumerState<LumaApp> {
  late bool _showSplash = !widget.skipSplash;
  bool _needsOnboarding = false;

  @override
  void initState() {
    super.initState();
    if (widget.skipSplash) {
      _checkOnboardingFast();
    }
  }

  Future<void> _checkOnboardingFast() async {
    final store = ref.read(appSettingsStoreProvider);
    final done = await store.isOnboardingDone();
    if (mounted && !done) {
      setState(() => _needsOnboarding = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeId = ref.watch(themeProvider);
    return MaterialApp(
      title: 'Luma',
      navigatorKey: lumaNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: buildLumaTheme(themeId: currentThemeId),
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: _showSplash
            ? LumaSplashScreen(
                key: const ValueKey('splash'),
                onComplete: () async {
                  final store = ref.read(appSettingsStoreProvider);
                  final done = await store.isOnboardingDone();
                  if (mounted) {
                    setState(() {
                      _needsOnboarding = !done;
                      _showSplash = false;
                    });
                  }
                },
              )
            : _needsOnboarding
                ? FirstLaunchFlow(
                    key: const ValueKey('first_launch_flow'),
                    onComplete: (name, initialBalanceMinor) async {
                      final store = ref.read(appSettingsStoreProvider);
                      await store.setUserName(name);
                      ref.read(userNameProvider.notifier).state = name;
                      await store.setInitialBalanceMinor(initialBalanceMinor);
                      ref
                          .read(expenseControllerProvider)
                          .setInitialBalance(initialBalanceMinor);
                      await store.markOnboardingDone();
                      if (mounted) {
                        setState(() => _needsOnboarding = false);
                      }
                    },
                  )
                : const _MainShell(key: ValueKey('main_shell')),
      ),
    );
  }
}

class _MainShell extends ConsumerStatefulWidget {
  const _MainShell({super.key});

  @override
  ConsumerState<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<_MainShell>
    with WidgetsBindingObserver {
  LumaTab tab = LumaTab.home;
  late final PageController _pageController;
  ExpenseController? _observedController;
  bool _draining = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: tab.index);
    WidgetsBinding.instance.addObserver(this);
    notificationService.onTap = _handleNotificationTap;
    _observedController = ref.read(expenseControllerProvider);
    _observedController!.addListener(_syncPendingSummary);
    Future.microtask(_loadInitialData);
  }

  @override
  void dispose() {
    _pageController.dispose();
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

  void _switchTab(LumaTab newTab) {
    if (tab != newTab) {
      setState(() => tab = newTab);
    }
    if (_pageController.hasClients &&
        _pageController.page?.round() != newTab.index) {
      _pageController.animateToPage(
        newTab.index,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _handleNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) return;
    if (payload == 'pending') {
      _switchTab(LumaTab.home);
      return;
    }
    final id = int.tryParse(payload);
    if (id == null) return;
    final context = lumaNavigatorKey.currentContext;
    if (context == null) return;
    final controller = ref.read(expenseControllerProvider);
    final matches = controller.expenses.where((e) => e.id == id).toList();
    if (matches.isEmpty) {
      _switchTab(LumaTab.home);
      return;
    }
    _switchTab(LumaTab.home);
    final target = matches.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = lumaNavigatorKey.currentContext;
      if (ctx == null) return;
      openExpense(ctx, ref, target);
    });
  }

  Future<void> _loadInitialData() async {
    final controller = ref.read(expenseControllerProvider);
    final store = ref.read(appSettingsStoreProvider);
    final initialBalance = await store.initialBalanceMinor();
    controller.setInitialBalance(initialBalance);
    final savedName = await store.userName();
    if (mounted && savedName.isNotEmpty) {
      ref.read(userNameProvider.notifier).state = savedName;
    }
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
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: PageView(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          onPageChanged: (index) {
            final newTab = LumaTab.values[index];
            if (tab != newTab) {
              setState(() => tab = newTab);
            }
          },
          children: [
            _HomePage(onHistory: () => _switchTab(LumaTab.history)),
            const _HistoryPage(),
            const _ExportPage(),
            const _SettingsPage(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: LumaNavBar(
            current: tab,
            pendingCount: pendingCount,
            onSelect: _switchTab,
            onAdd: () => showAddExpense(context, ref),
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
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  SmsPermissionState? _smsState;
  String _userName = '';

  @override
  bool get wantKeepAlive => true;

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
    if (state == AppLifecycleState.resumed) {
      _refreshSmsState();
      _refreshUserName();
    }
  }

  Future<void> _refreshSmsState() async {
    final state = await ref.read(smsPermissionServiceProvider).status();
    if (mounted) setState(() => _smsState = state);
  }

  Future<void> _refreshUserName() async {
    final name = await ref.read(appSettingsStoreProvider).userName();
    if (mounted) {
      setState(() => _userName = name);
      ref.read(userNameProvider.notifier).state = name;
    }
  }

  Widget _buildGreeting(BuildContext context, TextTheme textTheme, String name) {
    final palette = context.lumaPalette;
    final base = greetingFor(DateTime.now());
    final baseStyle = textTheme.headlineSmall?.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: palette.textPrimary,
      letterSpacing: -0.3,
    );

    if (name.isEmpty) {
      return Text(
        base,
        style: baseStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Text.rich(
      TextSpan(
        text: '$base, ',
        style: baseStyle,
        children: [
          TextSpan(
            text: name,
            style: TextStyle(
              color: palette.primaryAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final controller = ref.watch(expenseControllerProvider);
    final pending = controller.pending;
    final recent = controller.expenses
        .where((expense) => !expense.isPending)
        .take(4)
        .toList();
    final textTheme = Theme.of(context).textTheme;
    final watchedName = ref.watch(userNameProvider);
    final effectiveName = watchedName.isNotEmpty ? watchedName : _userName;
    final showSmsBanner = _smsState == SmsPermissionState.denied ||
        _smsState == SmsPermissionState.permanentlyDenied ||
        _smsState == SmsPermissionState.restricted;

    return ListView(
      padding: AppSpacing.screenPadding.copyWith(bottom: 128),
      children: [
        Row(
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 14,
              color: context.lumaPalette.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              'SECURE · PRIVATE',
              style: TextStyle(
                color: context.lumaPalette.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: .8,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _buildGreeting(context, textTheme, effectiveName),
        if (showSmsBanner) ...[
          const SizedBox(height: AppSpacing.lg),
          const SmsDisabledBanner(),
        ],
        const SizedBox(height: AppSpacing.xxl),
        BalanceCard(
          currentBalanceMinor: controller.currentBalanceMinor,
          initialBalanceMinor: controller.initialBalanceMinor,
        ),
        const SizedBox(height: AppSpacing.md),
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
        const UpcomingSubscriptionsSection(),
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

class _HistoryPageState extends ConsumerState<_HistoryPage>
    with AutomaticKeepAliveClientMixin {
  String query = '';
  String? selectedCategory;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                      style: TextStyle(
                        color: context.lumaPalette.textSecondary,
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
  Widget build(BuildContext context) {
    final palette = context.lumaPalette;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
        selectedColor: palette.chipSelectedBackground,
        backgroundColor: palette.chipUnselectedBackground,
        side: BorderSide(
          color: selected
              ? palette.chipSelectedBackground
              : palette.chipUnselectedBorder,
        ),
        labelStyle: TextStyle(
          color: selected ? palette.chipSelectedText : palette.chipUnselectedText,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

class _SettingsPage extends ConsumerStatefulWidget {
  const _SettingsPage();

  @override
  ConsumerState<_SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<_SettingsPage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  bool dailyAudit = true;
  int _auditHour = 21;
  int _auditMinute = 0;
  SmsPermissionState? _smsState;
  bool _checkingSms = true;
  bool _loadingAudit = true;
  String _userName = '';
  bool _loadingName = true;
  int _initialBalanceMinor = 0;
  bool _loadingBalance = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshSmsState();
    _loadAuditState();
    _loadUserName();
    _loadInitialBalance();
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
    final store = ref.read(appSettingsStoreProvider);
    final enabled = await store.isDailyAuditEnabled();
    final (hour, minute) = await store.auditTime();
    if (mounted) {
      setState(() {
        dailyAudit = enabled;
        _auditHour = hour;
        _auditMinute = minute;
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
      ref.read(userNameProvider.notifier).state = name;
    }
  }

  Future<void> _loadInitialBalance() async {
    final balance =
        await ref.read(appSettingsStoreProvider).initialBalanceMinor();
    if (mounted) {
      setState(() {
        _initialBalanceMinor = balance;
        _loadingBalance = false;
      });
    }
  }

  Future<void> _editName() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _EditNameDialog(initialName: _userName),
    );
    if (name == null || !mounted) return;
    await ref.read(appSettingsStoreProvider).setUserName(name);
    ref.read(userNameProvider.notifier).state = name;
    if (mounted) setState(() => _userName = name);
  }

  Future<void> _editInitialBalance() async {
    final newBalanceMinor = await showDialog<int>(
      context: context,
      builder: (context) =>
          _EditBalanceDialog(initialMinor: _initialBalanceMinor),
    );
    if (newBalanceMinor == null || !mounted) return;
    await ref
        .read(appSettingsStoreProvider)
        .setInitialBalanceMinor(newBalanceMinor);
    ref.read(expenseControllerProvider).setInitialBalance(newBalanceMinor);
    if (mounted) setState(() => _initialBalanceMinor = newBalanceMinor);
  }

  Future<void> _confirmResetAll() async {
    final palette = context.lumaPalette;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: palette.elevated,
        title: const Text('Reset all records?'),
        content: const Text(
          'This will permanently delete all expenses and pending items. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: palette.error,
              foregroundColor: palette.textPrimary,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(expenseControllerProvider).clearAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All records have been reset.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _setAudit(bool enabled) async {
    setState(() => dailyAudit = enabled);
    await ref.read(appSettingsStoreProvider).setDailyAuditEnabled(enabled);
    final audit = ref.read(dailyAuditServiceProvider);
    if (enabled) {
      await audit.schedule(_auditHour, _auditMinute);
    } else {
      await audit.cancel();
    }
  }

  Future<void> _setAuditTime(int hour, int minute) async {
    setState(() {
      _auditHour = hour;
      _auditMinute = minute;
    });
    await ref.read(appSettingsStoreProvider).setAuditTime(hour, minute);
    if (dailyAudit) {
      await ref.read(dailyAuditServiceProvider).schedule(hour, minute);
    }
  }

  String _formatAuditTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    final mStr = minute.toString().padLeft(2, '0');
    return '$h12:$mStr $period';
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
    if (_smsState != SmsPermissionState.granted) {
      final proceed = await showSmsDisclosureDialog(context);
      if (!proceed || !mounted) return;
    }
    await requestSmsPermissionFlow(context, ref);
    await _refreshSmsState();
  }

  Future<void> _showDailyAuditSheet() async {
    final palette = context.lumaPalette;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.85,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: palette.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            color: palette.primaryAccent,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Daily audit',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Luma can send a gentle reminder to review your day’s transactions and keep your balance accurate.',
                        style: TextStyle(
                          fontSize: 14,
                          color: palette.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: palette.elevated,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: palette.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Daily reminder',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: palette.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    dailyAudit
                                        ? 'Every day at ${_formatAuditTime(_auditHour, _auditMinute)}'
                                        : 'Disabled',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: dailyAudit ? palette.primaryAccent : palette.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: dailyAudit,
                              onChanged: _loadingAudit
                                  ? null
                                  : (val) async {
                                      setSheetState(() => dailyAudit = val);
                                      await _setAudit(val);
                                    },
                              activeThumbColor: palette.primaryAccent,
                              activeTrackColor: palette.secondaryAccent,
                            ),
                          ],
                        ),
                      ),
                      if (dailyAudit) ...[
                        const SizedBox(height: 12),
                        Material(
                          color: palette.elevated,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () async {
                              final initial = TimeOfDay(
                                hour: _auditHour,
                                minute: _auditMinute,
                              );
                              final picked = await showTimePicker(
                                context: sheetContext,
                                initialTime: initial,
                                builder: (pickerContext, child) {
                                  return Theme(
                                    data: Theme.of(pickerContext).copyWith(
                                      colorScheme: ColorScheme.dark(
                                        primary: palette.primaryAccent,
                                        onPrimary: palette.onPrimaryAccent,
                                        surface: palette.elevated,
                                        onSurface: palette.textPrimary,
                                      ),
                                      timePickerTheme: TimePickerThemeData(
                                        backgroundColor: palette.elevated,
                                        hourMinuteColor: palette.surface,
                                        hourMinuteTextColor: palette.textPrimary,
                                        dayPeriodColor: palette.surface,
                                        dayPeriodTextColor: palette.textPrimary,
                                        dialBackgroundColor: palette.surface,
                                        dialHandColor: palette.primaryAccent,
                                        dialTextColor: palette.textPrimary,
                                        entryModeIconColor: palette.primaryAccent,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setSheetState(() {
                                  _auditHour = picked.hour;
                                  _auditMinute = picked.minute;
                                });
                                await _setAuditTime(picked.hour, picked.minute);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: palette.border),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 20,
                                    color: palette.primaryAccent,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Audit time',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: palette.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Tap to customize reminder time',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: palette.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: palette.surface,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: palette.border),
                                    ),
                                    child: Text(
                                      _formatAuditTime(_auditHour, _auditMinute),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: palette.primaryAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Consumer(
                        builder: (ctx, watchRef, _) {
                          final controller = watchRef.watch(expenseControllerProvider);
                          final pendingItems = controller.pendingOrUncategorized;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Pending & uncategorized',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: palette.textPrimary,
                                      letterSpacing: .3,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: pendingItems.isEmpty
                                          ? palette.success.withValues(alpha: 0.15)
                                          : palette.primaryAccent.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      pendingItems.isEmpty
                                          ? 'All clear'
                                          : '${pendingItems.length} to audit',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: pendingItems.isEmpty
                                            ? palette.success
                                            : palette.primaryAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (pendingItems.isEmpty) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: palette.elevated,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: palette.border),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: palette.success,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'No pending or uncategorized transactions. All up to date!',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: palette.textSecondary,
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                Container(
                                  decoration: BoxDecoration(
                                    color: palette.elevated,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: palette.border),
                                  ),
                                  child: Column(
                                    children: [
                                      ...pendingItems.take(4).map((expense) {
                                        final isFirst = expense == pendingItems.first;
                                        return Container(
                                          decoration: BoxDecoration(
                                            border: isFirst
                                                ? null
                                                : Border(top: BorderSide(color: palette.border)),
                                          ),
                                          child: ListTile(
                                            dense: true,
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 2,
                                            ),
                                            title: Text(
                                              expense.merchant?.isNotEmpty == true
                                                  ? expense.merchant!
                                                  : (expense.isDebit ? 'Expense' : 'Income'),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                color: palette.textPrimary,
                                              ),
                                            ),
                                            subtitle: Text(
                                              expense.isPending
                                                  ? 'Pending review'
                                                  : 'Uncategorized',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: palette.primaryAccent,
                                              ),
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  '₹${(expense.amountMinor / 100).toStringAsFixed(expense.amountMinor % 100 == 0 ? 0 : 2)}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                    color: palette.textPrimary,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(
                                                  Icons.chevron_right_rounded,
                                                  size: 18,
                                                  color: palette.textSecondary,
                                                ),
                                              ],
                                            ),
                                            onTap: () async {
                                              Navigator.pop(sheetContext);
                                              await openExpense(context, ref, expense);
                                            },
                                          ),
                                        );
                                      }),
                                      if (pendingItems.length > 4) ...[
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            border: Border(top: BorderSide(color: palette.border)),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '+${pendingItems.length - 4} more waiting for review',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: palette.textSecondary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    if (mounted) setState(() {});
  }

  Future<void> _showPrivacySheet() async {
    final palette = context.lumaPalette;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: palette.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: palette.primaryAccent,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Private by design',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Everything stays on this device.\n\n'
                  '• SMS messages are parsed locally on your phone using on-device regex rules.\n'
                  '• No financial data, account numbers, or balances are ever uploaded to any cloud server.\n'
                  '• Exports are generated directly onto your device storage and shared only when you choose.',
                  style: TextStyle(
                    fontSize: 14,
                    color: palette.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Got it',
                    onPressed: () => Navigator.pop(sheetContext),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final textTheme = Theme.of(context).textTheme;
    final palette = context.lumaPalette;
    final currentTheme = ref.watch(themeProvider);
    final smsOn = _smsState == SmsPermissionState.granted;
    final activeSubs = ref
        .watch(subscriptionControllerProvider)
        .subscriptions
        .where((s) => s.status.isOngoing)
        .length;

    return ListView(
      padding: AppSpacing.screenPadding.copyWith(bottom: 140),
      children: [
        Text(
          'Settings',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Keep Luma working quietly in the background',
          style: textTheme.bodyMedium?.copyWith(
            color: palette.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
        const _SettingsSectionHeader('AUTOMATION'),
        _SettingsSectionCard(
          children: [
            _SettingsRow(
              icon: Icons.sms_outlined,
              title: 'SMS detection',
              subtitle: smsOn ? 'Watching transaction SMS' : _smsSubtitle,
              trailing: Switch(
                value: smsOn,
                onChanged: (_) => _onSmsTap(),
                activeThumbColor: palette.primaryAccent,
                activeTrackColor: palette.secondaryAccent,
              ),
              onTap: _onSmsTap,
            ),
            const _SettingsRowDivider(),
            _SettingsRow(
              icon: Icons.schedule_rounded,
              title: 'Daily audit',
              subtitle: dailyAudit
                  ? 'Every day at ${_formatAuditTime(_auditHour, _auditMinute)}'
                  : 'Off',
              onTap: _showDailyAuditSheet,
            ),
          ],
        ),
        const _SettingsSectionHeader('APPEARANCE'),
        _SettingsSectionCard(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: LumaThemeId.values.map((themeId) {
                  final isSelected = currentTheme == themeId;
                  final previewPalette = LumaPalette.of(themeId);
                  return _ThemeOptionTile(
                    themeId: themeId,
                    palette: previewPalette,
                    isSelected: isSelected,
                    onSelect: () =>
                        ref.read(themeProvider.notifier).setTheme(themeId),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const _SettingsSectionHeader('PERSONAL'),
        _SettingsSectionCard(
          children: [
            _SettingsRow(
              icon: Icons.person_outline_rounded,
              title: 'Your name',
              subtitle: _loadingName
                  ? 'Loading…'
                  : _userName.isEmpty
                      ? 'Not set — tap to add'
                      : _userName,
              onTap: _editName,
            ),
            const _SettingsRowDivider(),
            _SettingsRow(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Starting balance',
              subtitle: _loadingBalance
                  ? 'Loading…'
                  : formatAmount(_initialBalanceMinor),
              onTap: _editInitialBalance,
            ),
            const _SettingsRowDivider(),
            _SettingsRow(
              icon: Icons.repeat_rounded,
              title: 'Subscriptions',
              subtitle: '$activeSubs active',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SubscriptionsPage(),
                ),
              ),
            ),
          ],
        ),
        const _SettingsSectionHeader('PRIVACY'),
        _SettingsSectionCard(
          children: [
            _SettingsRow(
              icon: Icons.shield_outlined,
              title: 'Private by design',
              subtitle: 'Everything stays on this device',
              onTap: _showPrivacySheet,
            ),
          ],
        ),
        const _SettingsSectionHeader('ADVANCED'),
        _SettingsSectionCard(
          children: [
            _SettingsRow(
              icon: Icons.bug_report_outlined,
              title: 'SMS diagnostics',
              subtitle: 'Troubleshoot SMS detection and processing',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SmsDiagnosticsPage(),
                ),
              ),
            ),
          ],
        ),
        const _SettingsSectionHeader('DANGER ZONE'),
        _SettingsSectionCard(
          children: [
            _SettingsRow(
              icon: Icons.delete_outline_rounded,
              iconColor: palette.error,
              title: 'Reset all records',
              titleColor: palette.error,
              subtitle: 'Wipe all transactions and start completely fresh',
              trailing: Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: palette.error,
              ),
              onTap: _confirmResetAll,
            ),
          ],
        ),
      ],
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  const _ThemeOptionTile({
    required this.themeId,
    required this.palette,
    required this.isSelected,
    required this.onSelect,
  });

  final LumaThemeId themeId;
  final LumaPalette palette;
  final bool isSelected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final activePalette = context.lumaPalette;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onSelect,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? activePalette.primaryAccent.withAlpha(25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? activePalette.primaryAccent
                : activePalette.border.withAlpha(120),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected
                  ? activePalette.primaryAccent
                  : activePalette.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    themeId.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: activePalette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    themeId.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: activePalette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: palette.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: palette.border, width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SwatchDot(palette.surface),
                  const SizedBox(width: 4),
                  _SwatchDot(palette.primaryAccent),
                  const SizedBox(width: 4),
                  _SwatchDot(palette.secondaryAccent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwatchDot extends StatelessWidget {
  const _SwatchDot(this.color);
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      );
}

class _SettingsSectionHeader extends StatelessWidget {
  const _SettingsSectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final palette = context.lumaPalette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: palette.textSecondary.withAlpha(180),
        ),
      ),
    );
  }
}

class _SettingsSectionCard extends StatelessWidget {
  const _SettingsSectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = context.lumaPalette;
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: palette.border.withAlpha(160),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: children,
      ),
    );
  }
}

class _SettingsRowDivider extends StatelessWidget {
  const _SettingsRowDivider();

  @override
  Widget build(BuildContext context) {
    final palette = context.lumaPalette;
    return Divider(
      height: 1,
      thickness: 1,
      color: palette.border,
      indent: 54,
      endIndent: 16,
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.lumaPalette;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: iconColor ?? palette.textSecondary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: titleColor ?? palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: palette.textSecondary,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditNameDialog extends StatefulWidget {
  const _EditNameDialog({required this.initialName});

  final String initialName;

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.lumaPalette.elevated,
      title: const Text('Your name'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        maxLength: 24,
        decoration: const InputDecoration(
          hintText: 'What should Luma call you?',
        ),
        onSubmitted: (value) => Navigator.pop(context, value.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _EditBalanceDialog extends StatefulWidget {
  const _EditBalanceDialog({required this.initialMinor});

  final int initialMinor;

  @override
  State<_EditBalanceDialog> createState() => _EditBalanceDialogState();
}

class _EditBalanceDialogState extends State<_EditBalanceDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initialRupees = widget.initialMinor / 100;
    _controller = TextEditingController(
      text: initialRupees == 0
          ? '0'
          : (initialRupees % 1 == 0
              ? initialRupees.toInt().toString()
              : initialRupees.toStringAsFixed(2)),
    );
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double? get _parsed {
    final text = _controller.text.trim().replaceAll(',', '');
    if (text.isEmpty) return null;
    final val = double.tryParse(text);
    if (val == null || val < 0 || val.isNaN || val.isInfinite) return null;
    return val;
  }

  void _submit() {
    final val = _parsed;
    if (val != null) {
      Navigator.pop(context, (val * 100).round());
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.lumaPalette;
    return AlertDialog(
      backgroundColor: palette.elevated,
      title: const Text('Starting balance'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Luma calculates your running balance and export summary from this starting amount.',
            style: TextStyle(fontSize: 13, color: palette.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: palette.textPrimary,
            ),
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: palette.primaryAccent,
              ),
              hintText: '0.00',
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _parsed != null ? _submit : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// Shows where an SMS can get stuck: permission → phone queue → parse.
///
/// Each row maps to one stage of the watch chain, so a missed transaction
/// can be localized without a computer.
/// Dedicated SMS diagnostics screen for troubleshooting SMS detection,
/// native queue inspection, inbox scanning, and background permissions.
class SmsDiagnosticsPage extends ConsumerStatefulWidget {
  const SmsDiagnosticsPage({super.key});

  @override
  ConsumerState<SmsDiagnosticsPage> createState() =>
      _SmsDiagnosticsPageState();
}

class _SmsDiagnosticsPageState extends ConsumerState<SmsDiagnosticsPage> {
  int? _queued;
  bool _checkingQueue = false;
  bool _processing = false;
  bool _scanning = false;

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

  Future<void> _scanInbox({int? targetCount, DateTime? cutoffDate}) async {
    setState(() => _scanning = true);
    try {
      final result = await scanInboxSms(
        ref,
        targetCount: targetCount,
        cutoffDate: cutoffDate,
      );
      await _refreshQueue();
      if (!mounted) return;
      final String message;
      if (cutoffDate != null) {
        final dateLabel =
            '${cutoffDate.year}-${cutoffDate.month.toString().padLeft(2, '0')}-${cutoffDate.day.toString().padLeft(2, '0')}';
        if (result.validParsed > 0) {
          message =
              'Scanned inbox up to $dateLabel: ${result.validParsed} found (${result.newlyCreated} imported).';
        } else {
          message = 'No matching transaction SMS found up to $dateLabel.';
        }
      } else if (targetCount != null) {
        if (result.validParsed > 0) {
          message =
              'Scanned ${result.validParsed} latest transaction SMS (${result.newlyCreated} added to Needs Attention).';
        } else {
          message = 'No matching transaction SMS found in inbox.';
        }
      } else {
        if (result.newlyCreated > 0) {
          message =
              'Found & imported ${result.newlyCreated} transactions from inbox.';
        } else {
          message = 'No new transactions found in SMS inbox.';
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning SMS: $e')),
      );
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  void _showSelectedScanDialog() {
    final countController = TextEditingController(text: '4');
    var selectedPreset = 4;
    var scanMode = 0; // 0: by count, 1: up to date
    DateTime? selectedCutoffDate;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final palette = context.lumaPalette;
          return AlertDialog(
            backgroundColor: palette.elevated,
            title: const Text('Scan Recent SMS'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('By count'),
                        selected: scanMode == 0,
                        onSelected: (selected) {
                          if (selected) {
                            setDialogState(() => scanMode = 0);
                          }
                        },
                        selectedColor: palette.primaryAccent.withAlpha(50),
                        labelStyle: TextStyle(
                          color: scanMode == 0
                              ? palette.primaryAccent
                              : palette.textSecondary,
                          fontWeight: scanMode == 0
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Up to date'),
                        selected: scanMode == 1,
                        onSelected: (selected) {
                          if (selected) {
                            setDialogState(() => scanMode = 1);
                          }
                        },
                        selectedColor: palette.primaryAccent.withAlpha(50),
                        labelStyle: TextStyle(
                          color: scanMode == 1
                              ? palette.primaryAccent
                              : palette.textSecondary,
                          fontWeight: scanMode == 1
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (scanMode == 0) ...[
                    Text(
                      'Specify how many latest transaction SMS to scan from inbox and import into Needs Attention:',
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: 8,
                      children: [2, 3, 4, 5, 10].map((preset) {
                        final isSelected = selectedPreset == preset;
                        return ChoiceChip(
                          label: Text('$preset SMS'),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setDialogState(() {
                                selectedPreset = preset;
                                countController.text = '$preset';
                              });
                            }
                          },
                          selectedColor: palette.primaryAccent.withAlpha(50),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? palette.primaryAccent
                                : palette.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: countController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Number of recent SMS',
                        hintText: 'e.g. 4',
                      ),
                      onChanged: (val) {
                        final parsed = int.tryParse(val);
                        setDialogState(() {
                          selectedPreset = parsed ?? -1;
                        });
                      },
                    ),
                  ] else ...[
                    Text(
                      'Process eligible transaction SMS from the inbox up to and including the selected date:',
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (selectedCutoffDate != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: palette.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: palette.primaryAccent.withAlpha(120),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 18,
                              color: palette.primaryAccent,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cutoff date (inclusive)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: palette.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    formatDayLabel(selectedCutoffDate!),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: palette.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: selectedCutoffDate ??
                                      DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setDialogState(
                                      () => selectedCutoffDate = picked);
                                }
                              },
                              child: const Text('Change'),
                            ),
                            IconButton(
                              tooltip: 'Clear',
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () => setDialogState(
                                  () => selectedCutoffDate = null),
                            ),
                          ],
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setDialogState(
                                  () => selectedCutoffDate = picked);
                            }
                          },
                          icon: const Icon(Icons.date_range_rounded, size: 18),
                          label: const Text('Select cutoff date'),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel'),
              ),
              if (scanMode == 0)
                PrimaryButton(
                  label: 'Scan recent',
                  onPressed: () {
                    final count =
                        int.tryParse(countController.text.trim()) ?? 4;
                    Navigator.pop(dialogCtx);
                    _scanInbox(targetCount: count.clamp(1, 50));
                  },
                )
              else
                PrimaryButton(
                  label: 'Scan up to date',
                  onPressed: selectedCutoffDate == null
                      ? null
                      : () {
                          final date = selectedCutoffDate!;
                          Navigator.pop(dialogCtx);
                          _scanInbox(cutoffDate: date);
                        },
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openBackgroundStart() async {
    final opened = await openAutostartSettings();
    if (!mounted) return;
    if (!opened) {
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        useSafeArea: true,
        builder: (context) => SafeArea(
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
                  style: TextStyle(color: context.lumaPalette.textSecondary),
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
    final palette = context.lumaPalette;
    final queueLabel = _checkingQueue
        ? 'Checking…'
        : _queued == null
            ? 'Unknown on this device'
            : _queued == 0
                ? 'Empty — receiver caught up'
                : '$_queued waiting — tap Process now';

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: palette.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'SMS diagnostics',
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _checkingQueue ? null : _refreshQueue,
            icon: Icon(Icons.refresh_rounded, size: 22, color: palette.textPrimary),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.screenPadding.copyWith(bottom: 40),
        children: [
          Text(
            'Troubleshoot SMS detection, drain the native Android queue, or scan your inbox for missed transactions.',
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          const _SettingsSectionHeader('PHONE QUEUE'),
          _SettingsSectionCard(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.inbox_outlined, color: palette.primaryAccent, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Queue Status',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: palette.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      queueLabel,
                      style: TextStyle(color: palette.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _processing ? null : _processNow,
                            icon: const Icon(Icons.download_rounded, size: 18),
                            label: Text(_processing ? 'Working…' : 'Process now'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _scanning ? null : _scanInbox,
                            icon: const Icon(Icons.mark_email_read_outlined, size: 18),
                            label: Text(_scanning ? 'Scanning…' : 'Scan Inbox'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _SettingsSectionHeader('SELECTIVE SCANNING'),
          _SettingsSectionCard(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan Recent Transactions',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Specify how many latest transaction SMS messages to scan and import into Needs Attention.',
                      style: TextStyle(color: palette.textSecondary, fontSize: 13, height: 1.3),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _scanning ? null : _showSelectedScanDialog,
                        icon: const Icon(Icons.filter_list_rounded, size: 18),
                        label: const Text('Scan recent'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _SettingsSectionHeader('BACKGROUND PERMISSIONS'),
          _SettingsSectionCard(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Autostart & Battery Optimization',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ensure your phone manufacturer does not block Luma from running SMS background receivers.',
                      style: TextStyle(color: palette.textSecondary, fontSize: 13, height: 1.3),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _openBackgroundStart,
                        icon: const Icon(Icons.battery_saver_outlined, size: 18),
                        label: const Text('Autostart'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _TestSmsSheet extends ConsumerStatefulWidget {
  const _TestSmsSheet({required this.onIngest});
  final void Function(Expense expense) onIngest;

  @override
  ConsumerState<_TestSmsSheet> createState() => _TestSmsSheetState();
}

class _TestSmsSheetState extends ConsumerState<_TestSmsSheet> {
  final _controller = TextEditingController();
  ParsedTransaction? _parsed;
  bool _tested = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _analyze() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _parsed = SmsTransactionParser().parse(text);
      _tested = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.lumaPalette;
    return Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Test SMS Parser',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Paste a bank SMS below to test how Luma parses it.',
              style: TextStyle(color: palette.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. Paid Rs. 250 to Starbucks on 28 Sep. UPI Ref 123456...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _analyze,
                    child: const Text('Parse SMS'),
                  ),
                ),
                if (_parsed != null && _parsed!.transactionType == TransactionType.debit) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final controller = ref.read(expenseControllerProvider);
                        final expense =
                            await controller.processSms(_controller.text.trim());
                        if (expense != null) {
                          widget.onIngest(expense);
                        }
                      },
                      child: const Text('Ingest into Luma'),
                    ),
                  ),
                ],
              ],
            ),
            if (_tested) ...[
              const SizedBox(height: 16),
              if (_parsed == null)
                const Text(
                  '❌ Parser did not recognize this as a debit transaction.',
                  style: TextStyle(color: Colors.redAccent),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: palette.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amount: ₹${(_parsed!.amountMinor / 100).toStringAsFixed(2)}'),
                      Text('Merchant: ${_parsed!.merchant ?? "None (tap to add)"}'),
                      Text('Type: ${_parsed!.transactionType.name}'),
                      Text('Ref: ${_parsed!.referenceNumber ?? "None"}'),
                      Text('Confidence: ${(_parsed!.confidence * 100).toInt()}%'),
                    ],
                  ),
                ),
            ],
          ],
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
    showDragHandle: true,
    useSafeArea: true,
    builder: (context) {
      final palette = context.lumaPalette;
      return SafeArea(
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
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 13,
              ),
            ),
            if (expense.note.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  border: Border.all(color: palette.border),
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
                title: Text(
                  'Raw SMS (debug)',
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 13,
                  ),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    padding: AppSpacing.cardPadding,
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(AppRadii.card),
                      border: Border.all(color: palette.border),
                    ),
                    child: Text(
                      expense.rawSms!,
                      style: TextStyle(
                        color: palette.textSecondary,
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
                      foregroundColor: palette.error,
                      side: BorderSide(color: palette.error),
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
    );
    },
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
              style: TextStyle(color: context.lumaPalette.textSecondary),
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
  final palette = context.lumaPalette;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: palette.elevated,
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
          style: TextButton.styleFrom(foregroundColor: palette.error),
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

class _ExportPageState extends ConsumerState<_ExportPage>
    with AutomaticKeepAliveClientMixin {
  ExportMode? _busy;

  @override
  bool get wantKeepAlive => true;

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
    super.build(context);
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
                    Text(
                      'Recommended',
                      style: TextStyle(
                        color: context.lumaPalette.primaryAccent,
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
