import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma/app/app.dart';
import 'package:luma/app/providers.dart';
import 'package:luma/app/theme/app_theme.dart';
import 'package:luma/data/services/app_settings_store.dart';

void main() {
  group('Luma Theme System & Palettes', () {
    test('LumaThemeId.fromId returns lumaOriginal for null, empty or invalid strings', () {
      expect(LumaThemeId.fromId(null), LumaThemeId.lumaOriginal);
      expect(LumaThemeId.fromId(''), LumaThemeId.lumaOriginal);
      expect(LumaThemeId.fromId('unknown_theme'), LumaThemeId.lumaOriginal);
      expect(LumaThemeId.fromId('corrupted_data_123'), LumaThemeId.lumaOriginal);

      expect(LumaThemeId.fromId('luma_original'), LumaThemeId.lumaOriginal);
      expect(LumaThemeId.fromId('rose_olive'), LumaThemeId.roseOlive);
      expect(LumaThemeId.fromId('lavender_beige'), LumaThemeId.lavenderBeige);
      expect(LumaThemeId.fromId('sage_cream'), LumaThemeId.sageCream);
    });

    test('Luma Original palette strictly preserves canonical Plum × Peach colors', () {
      final palette = LumaPalette.of(LumaThemeId.lumaOriginal);
      expect(palette.background, const Color(0xFF121212));
      expect(palette.surface, const Color(0xFF1E1E1E));
      expect(palette.elevated, const Color(0xFF2C2C2C));
      expect(palette.primaryAccent, const Color(0xFFFFB39A)); // Peach
      expect(palette.secondaryAccent, const Color(0xFF542A52)); // Plum
      expect(palette.onPrimaryAccent, const Color(0xFF121212));
      expect(palette.onSecondaryAccent, const Color(0xFFFFFFFF));
      expect(palette.textPrimary, const Color(0xFFF0F0F0));
      expect(palette.textSecondary, const Color(0xFFA0A0A0));
    });

    test('Rose × Olive palette strictly matches specification', () {
      final palette = LumaPalette.of(LumaThemeId.roseOlive);
      expect(palette.background, const Color(0xFF1A1514));
      expect(palette.surface, const Color(0xFF2C2421));
      expect(palette.primaryAccent, const Color(0xFFC9A0A0));
      expect(palette.secondaryAccent, const Color(0xFF8A8F68));
      expect(palette.textPrimary, const Color(0xFFF4EBE8));
      expect(palette.textSecondary, const Color(0xFF9E8D8A));
    });

    test('Lavender × Beige palette strictly matches specification', () {
      final palette = LumaPalette.of(LumaThemeId.lavenderBeige);
      expect(palette.background, const Color(0xFF14121A));
      expect(palette.surface, const Color(0xFF23202B));
      expect(palette.primaryAccent, const Color(0xFFA89BBE));
      expect(palette.secondaryAccent, const Color(0xFFD8C3A8));
      expect(palette.textPrimary, const Color(0xFFF2F0F7));
      expect(palette.textSecondary, const Color(0xFF8D859E));
    });

    test('Sage × Cream palette strictly matches specification', () {
      final palette = LumaPalette.of(LumaThemeId.sageCream);
      expect(palette.background, const Color(0xFF111511));
      expect(palette.surface, const Color(0xFF1D241D));
      expect(palette.primaryAccent, const Color(0xFFA3B18A));
      expect(palette.secondaryAccent, const Color(0xFFF2E8CF));
      expect(palette.textPrimary, const Color(0xFFF7F9F4));
      expect(palette.textSecondary, const Color(0xFF7E8A75));
    });

    test('buildLumaTheme configures ThemeData with corresponding palette extension', () {
      for (final themeId in LumaThemeId.values) {
        final theme = buildLumaTheme(themeId: themeId);
        final palette = theme.extension<LumaPalette>();
        expect(palette, isNotNull);
        expect(palette!.id, themeId);
        expect(theme.scaffoldBackgroundColor, palette.background);
        expect(theme.colorScheme.primary, palette.primaryAccent);
      }
    });

    test('All 4 palettes have valid semantic contrast tokens', () {
      for (final themeId in LumaThemeId.values) {
        final palette = LumaPalette.of(themeId);
        expect(palette.navIndicatorBackground, isNotNull);
        expect(palette.navIndicatorBorder, isNotNull);
        expect(palette.chipSelectedBackground, isNotNull);
        expect(palette.chipSelectedText, isNotNull);
        expect(palette.chipUnselectedBackground, isNotNull);
        expect(palette.chipUnselectedText, isNotNull);
        expect(palette.chipUnselectedBorder, isNotNull);

        // Ensure selected text contrast is not equal to selected background
        expect(palette.chipSelectedText, isNot(equals(palette.chipSelectedBackground)));
      }

      // Check Luma Original regression baseline
      final original = LumaPalette.of(LumaThemeId.lumaOriginal);
      expect(original.navIndicatorBackground, const Color(0xB2542A52));
      expect(original.navIndicatorBorder, const Color(0x59FFB39A));
      expect(original.chipSelectedBackground, const Color(0xFF542A52));
      expect(original.chipSelectedText, const Color(0xFFFFB39A));
    });

    test('AppSettingsStore persists themeId and safely returns lumaOriginal by default', () async {
      final store = AppSettingsStore(null);
      final defaultTheme = await store.themeId();
      expect(defaultTheme, 'luma_original');
      expect(LumaThemeId.fromId(defaultTheme), LumaThemeId.lumaOriginal);

      await store.setThemeId(LumaThemeId.roseOlive.id);
      final updatedTheme = await store.themeId();
      expect(updatedTheme, 'rose_olive');
      expect(LumaThemeId.fromId(updatedTheme), LumaThemeId.roseOlive);
    });
  });

  testWidgets('Theme selection in Settings immediately changes theme without modifying expenses', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: LumaApp(skipSplash: true)));
    await tester.pumpAndSettle();

    // Verify initial expenses exist
    final expenseFinder = find.text('Needs attention');
    expect(expenseFinder, findsOneWidget);

    // Switch to Settings tab
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // Verify APPEARANCE section is visible with all 4 themes
    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.text('Luma Original'), findsOneWidget);
    expect(find.text('Rosé Grove'), findsOneWidget);
    expect(find.text('Lavender Latte'), findsOneWidget);
    expect(find.text('Sage Soufflé'), findsOneWidget);

    // Select Rosé Grove
    await tester.tap(find.text('Rosé Grove'));
    await tester.pumpAndSettle();

    // Get the element and verify the theme applied on MaterialApp
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme?.extension<LumaPalette>()?.id, LumaThemeId.roseOlive);

    // Select Lavender Latte
    await tester.tap(find.text('Lavender Latte'));
    await tester.pumpAndSettle();

    final materialAppLavender = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialAppLavender.theme?.extension<LumaPalette>()?.id, LumaThemeId.lavenderBeige);

    // Select Sage Soufflé
    await tester.tap(find.text('Sage Soufflé'));
    await tester.pumpAndSettle();

    final materialAppSage = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialAppSage.theme?.extension<LumaPalette>()?.id, LumaThemeId.sageCream);

    // Navigate back to Home and verify expenses are unaffected
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Needs attention'), findsOneWidget);
  });

  testWidgets('Greeting and user name adapt to theme primaryAccent', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = AppSettingsStore(null);
    await store.setUserName('Alex');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsStoreProvider.overrideWith((ref) => store),
        ],
        child: const LumaApp(skipSplash: true),
      ),
    );
    await tester.pumpAndSettle();

    // In Luma Original, Alex should be styled with Peach
    final textFinder = find.textContaining('Alex');
    expect(textFinder, findsOneWidget);
    final initialText = tester.widget<Text>(textFinder);
    final initialSpan = initialText.textSpan as TextSpan;
    final initialNameSpan = initialSpan.children!.first as TextSpan;
    expect(initialNameSpan.style?.color, const Color(0xFFFFB39A)); // Peach

    // Switch to Sage Soufflé
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sage Soufflé'));
    await tester.pumpAndSettle();

    // Return to Home
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    final sageText = tester.widget<Text>(textFinder);
    final textSpan = sageText.textSpan as TextSpan;
    final nameSpan = textSpan.children!.first as TextSpan;
    expect(nameSpan.style?.color, const Color(0xFFA3B18A)); // Sage primaryAccent
  });

  testWidgets('History category filters reflect selected theme chip tokens', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: LumaApp(skipSplash: true)));
    await tester.pumpAndSettle();

    // Go to Settings and select Lavender Latte
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lavender Latte'));
    await tester.pumpAndSettle();

    // Navigate to History
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    // Verify filter chip exists and uses palette token
    final allChipFinder = find.widgetWithText(FilterChip, 'All');
    expect(allChipFinder, findsOneWidget);
    final allChip = tester.widget<FilterChip>(allChipFinder);
    final lavenderPalette = LumaPalette.of(LumaThemeId.lavenderBeige);
    expect(allChip.selectedColor, lavenderPalette.chipSelectedBackground);
    expect(allChip.backgroundColor, lavenderPalette.chipUnselectedBackground);
  });
}
