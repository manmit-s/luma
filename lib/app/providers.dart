import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/expense_controller.dart';
import '../data/services/app_settings_store.dart';
import '../services/audit/daily_audit_service.dart';
import '../services/export/export_service.dart';

final expenseControllerProvider = ChangeNotifierProvider<ExpenseController>(
  (ref) => ExpenseController(),
);

final appSettingsStoreProvider = Provider<AppSettingsStore>(
  (ref) => AppSettingsStore(null),
);

final exportServiceProvider = Provider<ExportService?>((ref) => null);

final dailyAuditServiceProvider = Provider<DailyAuditService>(
  (ref) => DailyAuditService(),
);
