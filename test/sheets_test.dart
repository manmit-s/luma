import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:luma/main.dart';
import 'package:luma/app/widgets/luma_nav_bar.dart';

/// Regression tests for the bottom-sheet controller lifecycle bug:
/// sheet TextEditingControllers used to be disposed synchronously on pop
/// while the exit transition still rebuilt the sheet's TextFields
/// (red screen on save). Sheets now own their controllers via StatefulWidgets.
void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const ProviderScope(child: LumaApp()));
    await tester.pumpAndSettle();
  }

  Future<void> openAddSheet(WidgetTester tester) async {
    await tester.tap(
      find.descendant(
        of: find.byType(LumaNavBar),
        matching: find.byIcon(Icons.add_rounded),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Add expense'), findsWidgets);
  }

  testWidgets('saving a manual expense does not throw', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await openAddSheet(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Amount').first,
      '250',
    );
    await tester.pump();
    await tester.tap(find.text('Save expense'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    // Sheet closed (FAB tooltip still reads 'Add expense', so assert on Save).
    expect(find.text('Save expense'), findsNothing);
  });

  testWidgets('validation error keeps the sheet alive without throwing', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await openAddSheet(tester);

    await tester.tap(find.text('Save expense'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Enter an amount greater than ₹0'), findsOneWidget);
  });

  testWidgets('completing a pending expense does not throw', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Uber').first);
    await tester.pumpAndSettle();
    expect(find.text('Complete expense'), findsOneWidget);

    await tester.tap(find.text('Travel'));
    await tester.pump();
    await tester.tap(find.text('Save expense'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Complete expense'), findsNothing);
  });
}
