import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'application/expense_controller.dart';
import 'application/subscription_controller.dart';
import 'data/database/luma_database.dart';
import 'data/database/seed.dart';
import 'data/repositories/drift_expense_repository.dart';
import 'data/repositories/drift_subscription_repository.dart';
import 'data/repositories/drift_expected_payment_repository.dart';
import 'data/repositories/memory_expense_repository.dart';
import 'data/repositories/memory_subscription_repository.dart';
import 'data/repositories/memory_expected_payment_repository.dart';
import 'data/services/app_settings_store.dart';
import 'data/services/drift_merchant_learning.dart';
import 'domain/services/merchant_learning.dart';
import 'services/export/export_service.dart';

export 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LumaDatabase? db;
  try {
    db = LumaDatabase();
    await seedLumaDatabase(db);
    final learning = DriftMerchantLearning(db);
    await learning.load();
    final repository = DriftExpenseRepository(db);
    final subRepo = DriftSubscriptionRepository(db);
    final paymentRepo = DriftExpectedPaymentRepository(db);
    final subController = SubscriptionController(
      subscriptionRepository: subRepo,
      expectedPaymentRepository: paymentRepo,
    );
    await subController.load();
    final controller = ExpenseController(
      repository: repository,
      learning: learning,
    );
    final store = AppSettingsStore(db);
    final initialBalance = await store.initialBalanceMinor();
    controller.setInitialBalance(initialBalance);
    final name = await store.userName();
    final exportService = ExportService(
      repository,
      db,
      settingsStore: store,
      subscriptionRepository: subRepo,
    );
    runApp(
      ProviderScope(
        overrides: [
          expenseControllerProvider.overrideWith((ref) => controller),
          subscriptionControllerProvider.overrideWith((ref) => subController),
          appSettingsStoreProvider.overrideWith((ref) => store),
          exportServiceProvider.overrideWith((ref) => exportService),
          if (name.isNotEmpty) userNameProvider.overrideWith((ref) => name),
        ],
        child: const LumaApp(),
      ),
    );
  } catch (e, st) {
    debugPrint('Database initialization failed: $e\n$st');
    // If opening the database failed due to corruption from previous runs,
    // delete the corrupt file and recreate a clean SQLite database so persistence works.
    try {
      await db?.close();
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'luma.sqlite'));
      if (await file.exists()) {
        await file.delete();
      }
      final cleanDb = LumaDatabase();
      await seedLumaDatabase(cleanDb);
      final learning = DriftMerchantLearning(cleanDb);
      await learning.load();
      final repository = DriftExpenseRepository(cleanDb);
      final subRepo = DriftSubscriptionRepository(cleanDb);
      final paymentRepo = DriftExpectedPaymentRepository(cleanDb);
      final subController = SubscriptionController(
        subscriptionRepository: subRepo,
        expectedPaymentRepository: paymentRepo,
      );
      await subController.load();
      final controller = ExpenseController(
        repository: repository,
        learning: learning,
      );
      await controller.load();
      final store = AppSettingsStore(cleanDb);
      final initialBalance = await store.initialBalanceMinor();
      controller.setInitialBalance(initialBalance);
      final name = await store.userName();
      final exportService = ExportService(
        repository,
        cleanDb,
        settingsStore: store,
        subscriptionRepository: subRepo,
      );
      runApp(
        ProviderScope(
          overrides: [
            expenseControllerProvider.overrideWith((ref) => controller),
            subscriptionControllerProvider
                .overrideWith((ref) => subController),
            appSettingsStoreProvider.overrideWith((ref) => store),
            exportServiceProvider.overrideWith((ref) => exportService),
            if (name.isNotEmpty) userNameProvider.overrideWith((ref) => name),
          ],
          child: const LumaApp(),
        ),
      );
      return;
    } catch (recoveryError, recoverySt) {
      debugPrint('Database recovery failed: $recoveryError\n$recoverySt');
    }

    final memoryRepo = MemoryExpenseRepository(seed: false);
    final memorySubRepo = MemorySubscriptionRepository();
    final memoryPaymentRepo = MemoryExpectedPaymentRepository();
    final subController = SubscriptionController(
      subscriptionRepository: memorySubRepo,
      expectedPaymentRepository: memoryPaymentRepo,
    );
    await subController.load();
    final fallback = ExpenseController(
      repository: memoryRepo,
      learning: MerchantLearning(),
    );
    await fallback.load();
    runApp(
      ProviderScope(
        overrides: [
          expenseControllerProvider.overrideWith((ref) => fallback),
          subscriptionControllerProvider
              .overrideWith((ref) => subController),
          appSettingsStoreProvider
              .overrideWith((ref) => AppSettingsStore(null)),
          // Same repo instance the controller holds, so marks stay in sync.
          exportServiceProvider.overrideWith((ref) => ExportService(
                memoryRepo,
                null,
                subscriptionRepository: memorySubRepo,
              )),
        ],
        child: const LumaApp(),
      ),
    );
  }
}
