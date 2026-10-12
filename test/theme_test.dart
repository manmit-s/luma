import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma/app/app.dart';
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
    expect(find.text('Rose × Olive'), findsOneWidget);
    expect(find.text('Lavender × Beige'), findsOneWidget);
    expect(find.text('Sage × Cream'), findsOneWidget);

    // Select Rose × Olive
    await tester.tap(find.text('Rose × Olive'));
    await tester.pumpAndSettle();

    // Get the element and verify the theme applied on MaterialApp
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme?.extension<LumaPalette>()?.id, LumaThemeId.roseOlive);

    // Select Lavender × Beige
    await tester.tap(find.text('Lavender × Beige'));
    await tester.pumpAndSettle();

    final materialAppLavender = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialAppLavender.theme?.extension<LumaPalette>()?.id, LumaThemeId.lavenderBeige);

    // Navigate back to Home and verify expenses are unaffected
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Needs attention'), findsOneWidget);
  });
}
