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
    await tester.enterText(
      find.byWidgetPredicate((w) =>
          w is TextField &&
          w.decoration?.hintText == 'Add a note (optional)'),
      'Snacks with team',
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

  testWidgets('manual transaction allows changing type to credit and category card selection', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await openAddSheet(tester);

    // Verify type selector is present
    expect(find.text('Debit (Expense)'), findsOneWidget);
    expect(find.text('Credit (Income)'), findsOneWidget);

    // Switch to Credit
    await tester.tap(find.text('Credit (Income)'));
    await tester.pumpAndSettle();

    // Verify button label reflects credit
    expect(find.text('Save credit'), findsOneWidget);

    // Enter amount
    await tester.enterText(
      find.widgetWithText(TextField, 'Amount').first,
      '5000',
    );
    await tester.pump();

    // Select category card (e.g. 'Investments' or 'Salary' or 'Food')
    await tester.tap(find.text('Food'));
    await tester.pump();

    await tester.tap(find.text('Save credit'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Save credit'), findsNothing);
  });

  testWidgets('completing parsed sms allows changing type to credit', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Uber').first);
    await tester.pumpAndSettle();
    expect(find.text('Complete expense'), findsOneWidget);

    // Switch to Credit
    await tester.tap(find.text('Credit (Income)'));
    await tester.pumpAndSettle();
    expect(find.text('Save credit'), findsOneWidget);

    // Select category
    await tester.tap(find.text('Travel'));
    await tester.pump();

    await tester.tap(find.text('Save credit'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Complete expense'), findsNothing);
  });

  testWidgets('completing parsed sms allows deleting the expense', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Uber').first);
    await tester.pumpAndSettle();
    expect(find.text('Complete expense'), findsOneWidget);

    // Tap delete affordance
    await tester.tap(find.text('Delete this expense'));
    await tester.pumpAndSettle();

    // Confirm dialog appears
    expect(find.text('Delete expense?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Complete expense'), findsNothing);
    expect(find.text('Uber'), findsNothing);
  });
}


