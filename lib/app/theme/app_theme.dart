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

/// Identifiers for selectable Luma themes.
enum LumaThemeId {
  lumaOriginal('luma_original', 'Luma Original', 'Plum × Peach'),
  roseOlive('rose_olive', 'Rosé Grove', 'Warm, calm and refined'),
  lavenderBeige('lavender_beige', 'Lavender Latte', 'Creative, soft and timeless'),
  sageCream('sage_cream', 'Sage Soufflé', 'Natural, calm and elegant');

  const LumaThemeId(this.id, this.label, this.description);
  final String id;
  final String label;
  final String description;

  static LumaThemeId fromId(String? id) {
    if (id == null) return LumaThemeId.lumaOriginal;
    for (final theme in LumaThemeId.values) {
      if (theme.id == id || theme.name == id) return theme;
    }
    return LumaThemeId.lumaOriginal;
  }
}

/// Design tokens for each selectable theme palette.
class LumaPalette extends ThemeExtension<LumaPalette> {
  const LumaPalette({
    required this.id,
    required this.name,
    required this.background,
    required this.surface,
    required this.elevated,
    required this.primaryAccent,
    required this.secondaryAccent,
    required this.onPrimaryAccent,
    required this.onSecondaryAccent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.success,
    required this.error,
    required this.navIndicatorBackground,
    required this.navIndicatorBorder,
    required this.chipSelectedBackground,
    required this.chipSelectedText,
    required this.chipUnselectedBackground,
    required this.chipUnselectedText,
    required this.chipUnselectedBorder,
  });

  final LumaThemeId id;
  final String name;
  final Color background;
  final Color surface;
  final Color elevated;
  final Color primaryAccent;
  final Color secondaryAccent;
  final Color onPrimaryAccent;
  final Color onSecondaryAccent;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final Color success;
  final Color error;

  /// Semantic navigation indicator colors
  final Color navIndicatorBackground;
  final Color navIndicatorBorder;

  /// Semantic chip / filter / badge selection colors
  final Color chipSelectedBackground;
  final Color chipSelectedText;
  final Color chipUnselectedBackground;
  final Color chipUnselectedText;
  final Color chipUnselectedBorder;

  // A. Luma Original: current canonical Plum × Peach palette
  static const original = LumaPalette(
    id: LumaThemeId.lumaOriginal,
    name: 'Luma Original',
    background: AppColors.background,
    surface: AppColors.surface,
    elevated: AppColors.elevated,
    primaryAccent: AppColors.peach,
    secondaryAccent: AppColors.plum,
    onPrimaryAccent: AppColors.onCta,
    onSecondaryAccent: AppColors.onPlum,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textMuted: AppColors.textMuted,
    border: AppColors.border,
    success: AppColors.success,
    error: AppColors.error,
    navIndicatorBackground: Color(0xB2542A52), // AppColors.plum @ 0.70
    navIndicatorBorder: Color(0x59FFB39A), // AppColors.peach @ 0.35
    chipSelectedBackground: AppColors.plum,
    chipSelectedText: AppColors.peach,
    chipUnselectedBackground: AppColors.surface,
    chipUnselectedText: AppColors.textSecondary,
    chipUnselectedBorder: AppColors.border,
  );

  // B. Rose × Olive: warm, calm and refined -> Rosé Grove
  static const roseOlive = LumaPalette(
    id: LumaThemeId.roseOlive,
    name: 'Rosé Grove',
    background: Color(0xFF1A1514),
    surface: Color(0xFF2C2421),
    elevated: Color(0xFF3B312D),
    primaryAccent: Color(0xFFC9A0A0),
    secondaryAccent: Color(0xFF8A8F68),
    onPrimaryAccent: Color(0xFF1A1514),
    onSecondaryAccent: Color(0xFFFFFFFF),
    textPrimary: Color(0xFFF4EBE8),
    textSecondary: Color(0xFF9E8D8A),
    textMuted: Color(0xFF6B5E5B),
    border: Color(0xFF433733),
    success: Color(0xFF4CAF50),
    error: Color(0xFFCF6679),
    navIndicatorBackground: Color(0x29C9A0A0), // Rose @ 0.16
    navIndicatorBorder: Color(0x59C9A0A0), // Rose @ 0.35
    chipSelectedBackground: Color(0xFF8A8F68),
    chipSelectedText: Color(0xFFFFFFFF),
    chipUnselectedBackground: Color(0xFF2C2421),
    chipUnselectedText: Color(0xFF9E8D8A),
    chipUnselectedBorder: Color(0xFF433733),
  );

  // C. Lavender × Beige: creative, soft and timeless -> Lavender Latte
  static const lavenderBeige = LumaPalette(
    id: LumaThemeId.lavenderBeige,
    name: 'Lavender Latte',
    background: Color(0xFF14121A),
    surface: Color(0xFF23202B),
    elevated: Color(0xFF302C3C),
    primaryAccent: Color(0xFFA89BBE),
    secondaryAccent: Color(0xFFD8C3A8),
    onPrimaryAccent: Color(0xFF14121A),
    onSecondaryAccent: Color(0xFF14121A),
    textPrimary: Color(0xFFF2F0F7),
    textSecondary: Color(0xFF8D859E),
    textMuted: Color(0xFF625B71),
    border: Color(0xFF393448),
    success: Color(0xFF4CAF50),
    error: Color(0xFFCF6679),
    navIndicatorBackground: Color(0x29A89BBE), // Lavender @ 0.16
    navIndicatorBorder: Color(0x59A89BBE), // Lavender @ 0.35
    chipSelectedBackground: Color(0xFFD8C3A8),
    chipSelectedText: Color(0xFF14121A),
    chipUnselectedBackground: Color(0xFF23202B),
    chipUnselectedText: Color(0xFF8D859E),
    chipUnselectedBorder: Color(0xFF393448),
  );

  // D. Sage × Cream: natural, calm and elegant -> Sage Soufflé
  static const sageCream = LumaPalette(
    id: LumaThemeId.sageCream,
    name: 'Sage Soufflé',
    background: Color(0xFF111511),
    surface: Color(0xFF1D241D),
    elevated: Color(0xFF2B362B),
    primaryAccent: Color(0xFFA3B18A),
    secondaryAccent: Color(0xFFF2E8CF),
    onPrimaryAccent: Color(0xFF111511),
    onSecondaryAccent: Color(0xFF111511),
    textPrimary: Color(0xFFF7F9F4),
    textSecondary: Color(0xFF7E8A75),
    textMuted: Color(0xFF566250),
    border: Color(0xFF303C30),
    success: Color(0xFF4CAF50),
    error: Color(0xFFCF6679),
    navIndicatorBackground: Color(0x29A3B18A), // Sage @ 0.16
    navIndicatorBorder: Color(0x59A3B18A), // Sage @ 0.35
    chipSelectedBackground: Color(0xFFF2E8CF),
    chipSelectedText: Color(0xFF111511),
    chipUnselectedBackground: Color(0xFF1D241D),
    chipUnselectedText: Color(0xFF7E8A75),
    chipUnselectedBorder: Color(0xFF303C30),
  );

  static LumaPalette of(LumaThemeId id) => switch (id) {
        LumaThemeId.lumaOriginal => original,
        LumaThemeId.roseOlive => roseOlive,
        LumaThemeId.lavenderBeige => lavenderBeige,
        LumaThemeId.sageCream => sageCream,
      };

  Color get peach => primaryAccent;
  Color get plum => secondaryAccent;
  Color get onCta => onPrimaryAccent;
  Color get onPlum => onSecondaryAccent;

  @override
  LumaPalette copyWith({
    LumaThemeId? id,
    String? name,
    Color? background,
    Color? surface,
    Color? elevated,
    Color? primaryAccent,
    Color? secondaryAccent,
    Color? onPrimaryAccent,
    Color? onSecondaryAccent,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? border,
    Color? success,
    Color? error,
    Color? navIndicatorBackground,
    Color? navIndicatorBorder,
    Color? chipSelectedBackground,
    Color? chipSelectedText,
    Color? chipUnselectedBackground,
    Color? chipUnselectedText,
    Color? chipUnselectedBorder,
  }) =>
      LumaPalette(
        id: id ?? this.id,
        name: name ?? this.name,
        background: background ?? this.background,
        surface: surface ?? this.surface,
        elevated: elevated ?? this.elevated,
        primaryAccent: primaryAccent ?? this.primaryAccent,
        secondaryAccent: secondaryAccent ?? this.secondaryAccent,
        onPrimaryAccent: onPrimaryAccent ?? this.onPrimaryAccent,
        onSecondaryAccent: onSecondaryAccent ?? this.onSecondaryAccent,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        textMuted: textMuted ?? this.textMuted,
        border: border ?? this.border,
        success: success ?? this.success,
        error: error ?? this.error,
        navIndicatorBackground:
            navIndicatorBackground ?? this.navIndicatorBackground,
        navIndicatorBorder: navIndicatorBorder ?? this.navIndicatorBorder,
        chipSelectedBackground:
            chipSelectedBackground ?? this.chipSelectedBackground,
        chipSelectedText: chipSelectedText ?? this.chipSelectedText,
        chipUnselectedBackground:
            chipUnselectedBackground ?? this.chipUnselectedBackground,
        chipUnselectedText: chipUnselectedText ?? this.chipUnselectedText,
        chipUnselectedBorder:
            chipUnselectedBorder ?? this.chipUnselectedBorder,
      );

  @override
  ThemeExtension<LumaPalette> lerp(
    ThemeExtension<LumaPalette>? other,
    double t,
  ) {
    if (other is! LumaPalette) return this;
    return LumaPalette(
      id: t < 0.5 ? id : other.id,
      name: t < 0.5 ? name : other.name,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      elevated: Color.lerp(elevated, other.elevated, t)!,
      primaryAccent: Color.lerp(primaryAccent, other.primaryAccent, t)!,
      secondaryAccent: Color.lerp(secondaryAccent, other.secondaryAccent, t)!,
      onPrimaryAccent: Color.lerp(onPrimaryAccent, other.onPrimaryAccent, t)!,
      onSecondaryAccent: Color.lerp(onSecondaryAccent, other.onSecondaryAccent, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      navIndicatorBackground: Color.lerp(
          navIndicatorBackground, other.navIndicatorBackground, t)!,
      navIndicatorBorder:
          Color.lerp(navIndicatorBorder, other.navIndicatorBorder, t)!,
      chipSelectedBackground:
          Color.lerp(chipSelectedBackground, other.chipSelectedBackground, t)!,
      chipSelectedText:
          Color.lerp(chipSelectedText, other.chipSelectedText, t)!,
      chipUnselectedBackground: Color.lerp(
          chipUnselectedBackground, other.chipUnselectedBackground, t)!,
      chipUnselectedText:
          Color.lerp(chipUnselectedText, other.chipUnselectedText, t)!,
      chipUnselectedBorder:
          Color.lerp(chipUnselectedBorder, other.chipUnselectedBorder, t)!,
    );
  }
}

extension LumaThemeContext on BuildContext {
  LumaPalette get lumaPalette =>
      Theme.of(this).extension<LumaPalette>() ?? LumaPalette.original;
}

ThemeData buildLumaTheme({LumaThemeId themeId = LumaThemeId.lumaOriginal}) {
  final palette = LumaPalette.of(themeId);

  final shapeCard = RoundedRectangleBorder(
    borderRadius: const BorderRadius.all(Radius.circular(AppRadii.card)),
    side: BorderSide(color: palette.border),
  );
  const shapePill = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppRadii.control)),
  );

  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: palette.background,
    // Intentionally no bundled font: use platform/system typography (SPEC 45).
    colorScheme: ColorScheme.dark(
      primary: palette.primaryAccent,
      onPrimary: palette.onPrimaryAccent,
      primaryContainer: palette.secondaryAccent,
      onPrimaryContainer: palette.onSecondaryAccent,
      secondary: palette.primaryAccent,
      onSecondary: palette.onPrimaryAccent,
      secondaryContainer: palette.secondaryAccent,
      onSecondaryContainer: palette.onSecondaryAccent,
      surface: palette.surface,
      onSurface: palette.textPrimary,
      surfaceContainerHighest: palette.elevated,
      error: palette.error,
      onError: Colors.white,
    ),
    extensions: [palette],
    textTheme: TextTheme(
      displaySmall: TextStyle(
        fontSize: 32,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.64,
        color: palette.textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 28,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.28,
        color: palette.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.5,
        color: palette.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.45,
        color: palette.textSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        height: 1.4,
        color: palette.textSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        height: 1.25,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: palette.textSecondary,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.elevated,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.card)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: palette.surface,
      indicatorColor: palette.navIndicatorBackground,
      height: 72,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? palette.primaryAccent : palette.textSecondary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? palette.primaryAccent : palette.textSecondary,
        );
      }),
    ),
    cardTheme: CardThemeData(
      color: palette.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: shapeCard,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: palette.elevated,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadii.card),
        ),
      ),
      showDragHandle: true,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: palette.primaryAccent,
        foregroundColor: palette.onPrimaryAccent,
        minimumSize: const Size.fromHeight(48),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.card)),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: palette.primaryAccent,
        side: BorderSide(color: palette.border),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.control)),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: palette.primaryAccent,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: palette.chipUnselectedBackground,
      selectedColor: palette.chipSelectedBackground,
      secondarySelectedColor: palette.chipSelectedBackground,
      disabledColor: palette.chipUnselectedBackground,
      side: BorderSide(color: palette.chipUnselectedBorder),
      labelStyle: TextStyle(color: palette.chipUnselectedText, fontSize: 13),
      secondaryLabelStyle: TextStyle(
        color: palette.chipSelectedText,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      shape: shapePill,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      showCheckmark: false,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? palette.primaryAccent
            : palette.textSecondary,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? palette.secondaryAccent
            : palette.border,
      ),
    ),
    listTileTheme: ListTileThemeData(
      tileColor: palette.surface,
      textColor: palette.textPrimary,
      iconColor: palette.primaryAccent,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.compact)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.elevated,
      hintStyle: TextStyle(color: palette.textMuted),
      labelStyle: TextStyle(color: palette.textSecondary),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        borderSide: BorderSide(color: palette.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        borderSide: BorderSide(color: palette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        borderSide: BorderSide(color: palette.primaryAccent),
      ),
    ),
    dividerColor: palette.border,
    useMaterial3: true,
  );
}
