import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import 'package:luma/app/providers.dart';
import 'package:luma/application/expense_controller.dart';
import 'package:luma/app/widgets/luma_nav_bar.dart';
import 'package:luma/data/repositories/memory_expense_repository.dart';
import 'package:luma/domain/services/merchant_learning.dart';
import 'package:luma/main.dart';
import 'package:luma/services/export/export_service.dart';

/// share_plus has no test double and its channel call never resolves under
/// flutter_test, so the UI test stubs out only the share step — generation,
/// marks and wiring are all real.
///
/// NOTE: real dart:io awaits deadlock inside testWidgets bodies on this
/// setup (FakeAsync zone), so the temp dir is created in setUpAll (normal
/// async zone) and file writes go through a synchronous writer.
class _NoShareExportService extends ExportService {
  _NoShareExportService(
    super.repo,
    super.db, {
    required Directory dir,
  }) : super(
          outputDir: () async => dir,
          writeFile: (target, filename, bytes) async {
            final file = File(p.join(target.path, filename));
            file.writeAsBytesSync(bytes, flush: true);
            if (!file.existsSync()) {
              throw ExportException('Could not create the Excel file.');
            }
            return file;
          },
        );

  @override
  Future<void> share(ExportResult result) async {}
}

/// End-to-end UI wiring: Export page + real ExportService (temp dir).
void main() {
  late Directory dir;

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('luma_export_ui');
  });

  tearDownAll(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  testWidgets('Generate XLSX produces a file and reports success', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = MemoryExpenseRepository();
    final controller = ExpenseController(
      repository: repo,
      learning: MerchantLearning(),
    );
    await controller.load();
    expect(controller.expenses, isNotEmpty,
        reason: 'seed data drives the export');

    final service = _NoShareExportService(repo, null, dir: dir);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          expenseControllerProvider.overrideWith((ref) => controller),
          exportServiceProvider.overrideWith((ref) => service),
        ],
        child: const LumaApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(LumaNavBar),
        matching: find.text('Export'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Export expenses'), findsOneWidget);

    // Since-last-export is enabled: seeds are unexported.
    await tester.tap(find.text('Generate XLSX').first);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Exported'), findsOneWidget);
    expect(
      dir.listSync().whereType<File>().where((f) => f.path.endsWith('.xlsx')),
      isNotEmpty,
    );
    // Marks persisted: incremental scope drops to zero.
    expect(await repo.queryUnexported(), isEmpty);
  });
}
