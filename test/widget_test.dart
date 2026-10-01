import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:luma/main.dart';
import 'package:luma/app/providers.dart';
import 'package:luma/app/widgets/luma_nav_bar.dart';
import 'package:luma/data/services/app_settings_store.dart';

void main() {
  testWidgets('Luma opens its primary navigation destinations', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: LumaApp()));
    await tester.pumpAndSettle();
    expect(find.byType(LumaNavBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Export'), findsWidgets);
    expect(find.text('Settings'), findsOneWidget);
    // No name set in tests: bare time-of-day greeting, no hardcoded name.
    expect(
      find.textContaining(RegExp(r'Good (morning|afternoon|evening)$')),
      findsOneWidget,
    );
  });

  testWidgets('Pill dock switches tabs and opens Add expense', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: LumaApp()));
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(LumaNavBar),
        matching: find.text('History'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Every expense, in one place'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(LumaNavBar),
        matching: find.text('Export'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Export expenses'), findsOneWidget);
    expect(find.text('Since last export'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(LumaNavBar),
        matching: find.byIcon(Icons.add_rounded),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Add expense'), findsWidgets);
  });

  testWidgets('Completed expense opens detail with edit affordance', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const ProviderScope(child: LumaApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Urban Company').first);
    await tester.pumpAndSettle();
    expect(find.text('Expense detail'), findsOneWidget);
    expect(find.text('Monthly home service'), findsOneWidget);
    expect(find.text('SMS detected'), findsOneWidget);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Edit expense'), findsOneWidget);
  });

  testWidgets('Greeting uses the name from Settings', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = AppSettingsStore(null);
    await store.setUserName('Rey');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsStoreProvider.overrideWith((ref) => store),
        ],
        child: const LumaApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Rey'), findsOneWidget);
  });

  testWidgets('History groups expenses under day headers', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const ProviderScope(child: LumaApp()));
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(LumaNavBar),
        matching: find.text('History'),
      ),
    );
    await tester.pumpAndSettle();
    // Seed data spans three days; grouped headers render alongside rows.
    expect(find.text('College Canteen'), findsWidgets);
    expect(
      find.textContaining(RegExp(r'Sep|Today|Yesterday')),
      findsWidgets,
    );
  });

  testWidgets('Settings allows selected SMS scanning with custom count dialog', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const ProviderScope(child: LumaApp()));
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(LumaNavBar),
        matching: find.text('Settings'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SMS diagnostics'), findsOneWidget);
    await tester.tap(find.text('SMS diagnostics'));
    await tester.pumpAndSettle();

    expect(find.text('Scan recent'), findsOneWidget);

    await tester.tap(find.text('Scan recent'));
    await tester.pumpAndSettle();

    expect(find.text('Scan Recent SMS'), findsOneWidget);
    expect(find.text('4 SMS'), findsOneWidget);
    expect(
      find.widgetWithText(TextField, 'Number of recent SMS'),
      findsOneWidget,
    );

    // Tap preset chip '2 SMS'
    await tester.tap(find.text('2 SMS'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Scan Recent SMS'), findsNothing);
  });
}

