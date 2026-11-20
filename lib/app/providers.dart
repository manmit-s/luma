import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/expense_controller.dart';
import '../application/category_controller.dart';
import '../application/source_controller.dart';
import '../application/subscription_controller.dart';
import '../data/repositories/memory_source_repository.dart';
import '../data/services/app_settings_store.dart';
import '../domain/repositories/source_repository.dart';
import '../services/audit/daily_audit_service.dart';
import '../services/export/export_service.dart';
import 'theme/app_theme.dart';

final categoryControllerProvider = ChangeNotifierProvider<CategoryController>(
  (ref) => CategoryController()..load(),
);

final sourceRepositoryProvider = Provider<SourceRepository>((ref) {
  return MemorySourceRepository();
});

final sourceControllerProvider =
    ChangeNotifierProvider<SourceController>((ref) {
  final repo = ref.watch(sourceRepositoryProvider);
  final controller = SourceController(repository: repo)..load();
  controller.updateExpenses(ref.read(expenseControllerProvider).expenses);
  ref.listen<ExpenseController>(expenseControllerProvider, (_, next) {
    controller.updateExpenses(next.expenses);
  });
  return controller;
});

final expenseControllerProvider = ChangeNotifierProvider<ExpenseController>(
  (ref) => ExpenseController(),
);

final subscriptionControllerProvider =
    ChangeNotifierProvider<SubscriptionController>(
  (ref) => SubscriptionController(),
);

final appSettingsStoreProvider = Provider<AppSettingsStore>(
  (ref) => AppSettingsStore(null),
);

final userNameProvider = StateProvider<String>((ref) => '');

final exportServiceProvider = Provider<ExportService?>((ref) => null);

final dailyAuditServiceProvider = Provider<DailyAuditService>(
  (ref) => DailyAuditService(),
);

class ThemeNotifier extends StateNotifier<LumaThemeId> {
  ThemeNotifier(this._store) : super(LumaThemeId.lumaOriginal) {
    load();
  }

  final AppSettingsStore _store;

  Future<void> load() async {
    try {
      final saved = await _store.themeId();
      state = LumaThemeId.fromId(saved);
    } catch (_) {
      state = LumaThemeId.lumaOriginal;
    }
  }

  Future<void> setTheme(LumaThemeId id) async {
    state = id;
    try {
      await _store.setThemeId(id.id);
    } catch (_) {}
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, LumaThemeId>((ref) {
  final store = ref.watch(appSettingsStoreProvider);
  return ThemeNotifier(store);
});
