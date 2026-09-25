import 'package:flutter/material.dart';

/// Central Luma design tokens.
///
/// Deviations / decisions:
/// - Peach CTAs are kept as the primary call-to-action style per user choice
///   (SPEC 44.4 strictly says Primary=#542A52/white, Secondary=#FFB39A/#121212).
///   Here [AppColors.cta] (= peach) is the primary button background so every
///   Save/Add/Generate action stays peach-on-dark. Plum remains the brand
///   surface for selection, badges and nav indicator.
abstract final class AppColors {
  static const background = Color(0xFF121212);
  static const surfaceLowest = Color(0xFF121212);
  static const surfaceLow = Color(0xFF1E1E1E);
  static const surface = Color(0xFF1E1E1E);
  static const elevated = Color(0xFF2C2C2C);
  static const surfaceHighest = Color(0xFF2C2C2C);

  /// Brand surface (selection, badges, nav indicator, avatars).
  static const plum = Color(0xFF542A52);

  /// High-emphasis / CTA background (peach).
  static const peach = Color(0xFFFFB39A);

  /// Alias kept for compatibility: primary CTA == peach.
  static const primary = Color(0xFFFFB39A);
  static const secondary = Color(0xFFFFB39A);

  /// Text on peach CTA buttons.
  static const onCta = Color(0xFF121212);

  /// Text on plum surfaces.
  static const onPlum = Color(0xFFFFFFFF);

  static const textPrimary = Color(0xFFF0F0F0);
  static const textSecondary = Color(0xFFA0A0A0);
  static const textMuted = Color(0xFF666666);
  static const textDisabled = Color(0xFF666666);
  static const border = Color(0xFF333333);
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFCF6679);

  /// Legacy alias — do not introduce new uses.
  static const cta = peach;
}

abstract final class AppRadii {
  /// Cards, primary buttons, inputs, sheets.
  static const card = 16.0;

  /// Pills: chips, badges, nav bar, small confirm buttons.
  static const control = 24.0;

  /// Dense tiles.
  static const compact = 12.0;
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;

  static const screenPadding = EdgeInsets.fromLTRB(xl, xxl, xl, xxxl);
  static const cardPadding = EdgeInsets.all(lg);
  static const tileGap = sm;
  static const sectionGap = md;
}

ThemeData buildLumaTheme() {
  const shapeCard = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppRadii.card)),
    side: BorderSide(color: AppColors.border),
  );
  const shapePill = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppRadii.control)),
  );

  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    // Intentionally no bundled font: use platform/system typography (SPEC 45).
    colorScheme: const ColorScheme.dark(
      primary: AppColors.peach,
      onPrimary: AppColors.onCta,
      primaryContainer: AppColors.plum,
      onPrimaryContainer: AppColors.onPlum,
      secondary: AppColors.peach,
      onSecondary: AppColors.onCta,
      secondaryContainer: AppColors.plum,
      onSecondaryContainer: AppColors.onPlum,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.elevated,
      error: AppColors.error,
      onError: AppColors.onPlum,
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontSize: 32,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.64,
        color: AppColors.textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 28,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.28,
        color: AppColors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.5,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.45,
        color: AppColors.textSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        height: 1.4,
        color: AppColors.textSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        height: 1.25,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.plum,
      height: 72,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? AppColors.peach : AppColors.textSecondary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? AppColors.peach : AppColors.textSecondary,
        );
      }),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: shapeCard,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.elevated,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadii.card),
        ),
      ),
      showDragHandle: true,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.peach,
        foregroundColor: AppColors.onCta,
        minimumSize: const Size.fromHeight(48),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.card)),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.peach,
        side: const BorderSide(color: AppColors.border),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.control)),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.peach,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.plum,
      secondarySelectedColor: AppColors.plum,
      disabledColor: AppColors.surface,
      side: BorderSide(color: AppColors.border),
      labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
      secondaryLabelStyle: TextStyle(
        color: AppColors.peach,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      shape: shapePill,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      showCheckmark: false,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.peach
            : AppColors.textSecondary,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.plum
            : AppColors.border,
      ),
    ),
    listTileTheme: const ListTileThemeData(
      tileColor: AppColors.surface,
      textColor: AppColors.textPrimary,
      iconColor: AppColors.peach,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.compact)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.elevated,
      hintStyle: const TextStyle(color: AppColors.textMuted),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        borderSide: const BorderSide(color: AppColors.peach),
      ),
    ),
    dividerColor: AppColors.border,
    useMaterial3: true,
  );
}
