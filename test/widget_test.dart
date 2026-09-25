import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:luma/main.dart';
import 'package:luma/app/widgets/luma_nav_bar.dart';

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
    expect(find.textContaining('Rey'), findsOneWidget);
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
}
