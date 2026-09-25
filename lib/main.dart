import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'application/expense_controller.dart';
import 'data/database/luma_database.dart';
import 'data/database/seed.dart';
import 'data/repositories/drift_expense_repository.dart';
import 'data/repositories/memory_expense_repository.dart';
import 'data/services/app_settings_store.dart';
import 'data/services/drift_merchant_learning.dart';
import 'domain/services/merchant_learning.dart';

export 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final db = LumaDatabase();
    await seedLumaDatabase(db);
    final learning = DriftMerchantLearning(db);
    await learning.load();
    final repository = DriftExpenseRepository(db);
    final controller = ExpenseController(
      repository: repository,
      learning: learning,
    );
    await controller.load();
    runApp(
      ProviderScope(
        overrides: [
          expenseControllerProvider.overrideWith((ref) => controller),
          appSettingsStoreProvider
              .overrideWith((ref) => AppSettingsStore(db)),
        ],
        child: const LumaApp(),
      ),
    );
  } catch (_) {
    final fallback = ExpenseController(
      repository: MemoryExpenseRepository(),
      learning: MerchantLearning(),
    );
    await fallback.load();
    runApp(
      ProviderScope(
        overrides: [
          expenseControllerProvider.overrideWith((ref) => fallback),
        ],
        child: const LumaApp(),
      ),
    );
  }
}
