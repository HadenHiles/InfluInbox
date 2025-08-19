import 'package:flutter/material.dart';

// Custom color extension
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color brand;
  final Color accent;

  const AppColors({required this.brand, required this.accent});

  @override
  AppColors copyWith({Color? brand, Color? accent}) => AppColors(brand: brand ?? this.brand, accent: accent ?? this.accent);

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(brand: Color.lerp(brand, other.brand, t)!, accent: Color.lerp(accent, other.accent, t)!);
  }

  static const light = AppColors(brand: Color(0xFF9ECCFE), accent: Color(0xFF173A6F));
  static const dark = AppColors(brand: Color(0xFF9ECCFE), accent: Color(0xFF173A6F));
}

// Custom typography extension
@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  final TextStyle logo;
  final TextStyle sectionTitle;

  const AppTypography({required this.logo, required this.sectionTitle});

  @override
  AppTypography copyWith({TextStyle? logo, TextStyle? sectionTitle}) => AppTypography(logo: logo ?? this.logo, sectionTitle: sectionTitle ?? this.sectionTitle);

  @override
  AppTypography lerp(ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) return this;
    return AppTypography(logo: TextStyle.lerp(logo, other.logo, t)!, sectionTitle: TextStyle.lerp(sectionTitle, other.sectionTitle, t)!);
  }

  static AppTypography light = AppTypography(
    logo: const TextStyle(
      fontFamily: 'Orbitron',
      fontSize: 36,
      fontWeight: FontWeight.w900,
      letterSpacing: 2.5,
      color: Color(0xFF173A6F), // accent
      shadows: [Shadow(blurRadius: 8, color: Color(0xFF9ECCFE), offset: Offset(0, 2))],
    ),
    sectionTitle: const TextStyle(
      fontFamily: 'Orbitron',
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: Color(0xFF173A6F), // accent
      letterSpacing: 1.2,
    ),
  );
  static AppTypography dark = AppTypography(
    logo: const TextStyle(
      fontFamily: 'Orbitron',
      fontSize: 36,
      fontWeight: FontWeight.w900,
      letterSpacing: 2.5,
      color: Color(0xFF9ECCFE), // brand
      shadows: [Shadow(blurRadius: 12, color: Color(0xFF173A6F), offset: Offset(0, 2))],
    ),
    sectionTitle: const TextStyle(
      fontFamily: 'Orbitron',
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: Color(0xFF9ECCFE), // brand
      letterSpacing: 1.2,
    ),
  );
}

// Custom shape extension
@immutable
class AppShapes extends ThemeExtension<AppShapes> {
  final RoundedRectangleBorder cardShape;
  final StadiumBorder buttonShape;

  const AppShapes({required this.cardShape, required this.buttonShape});

  @override
  AppShapes copyWith({RoundedRectangleBorder? cardShape, StadiumBorder? buttonShape}) => AppShapes(cardShape: cardShape ?? this.cardShape, buttonShape: buttonShape ?? this.buttonShape);

  @override
  AppShapes lerp(ThemeExtension<AppShapes>? other, double t) {
    if (other is! AppShapes) return this;
    final lerped = BorderRadius.lerp(cardShape.borderRadius as BorderRadius?, other.cardShape.borderRadius as BorderRadius?, t);
    return AppShapes(
      cardShape: RoundedRectangleBorder(borderRadius: lerped ?? BorderRadius.zero),
      buttonShape: buttonShape,
    );
  }

  static const light = AppShapes(
    cardShape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
    buttonShape: StadiumBorder(),
  );
  static const dark = AppShapes(
    cardShape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
    buttonShape: StadiumBorder(),
  );
}

// Easily editable theme data
ThemeData appTheme(BuildContext context, {bool dark = false}) {
  final colorScheme = ColorScheme(
    brightness: dark ? Brightness.dark : Brightness.light,
    primary: const Color(0xFF9ECCFE), // brand
    onPrimary: Colors.white,
    secondary: const Color(0xFF173A6F), // accent
    onSecondary: Colors.white,
    error: Colors.redAccent,
    onError: Colors.white,
    surface: dark ? const Color(0xFF101624) : const Color(0xFFF5F8FF),
    onSurface: dark ? Colors.white : const Color(0xFF173A6F),
  );
  return ThemeData(
    brightness: dark ? Brightness.dark : Brightness.light,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    cardColor: colorScheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 2,
      titleTextStyle: dark ? AppTypography.dark.logo : AppTypography.light.logo,
      iconTheme: IconThemeData(color: colorScheme.primary),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: colorScheme.primary, foregroundColor: colorScheme.onPrimary, shape: const StadiumBorder()),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? const Color(0xFF1B2335) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      labelStyle: TextStyle(color: dark ? colorScheme.primary : colorScheme.secondary, fontWeight: FontWeight.w600),
      floatingLabelStyle: TextStyle(color: dark ? colorScheme.primary : colorScheme.secondary, fontWeight: FontWeight.w700),
      hintStyle: TextStyle(color: dark ? Colors.white.withValues(alpha: 0.65) : colorScheme.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.w400),
      helperStyle: TextStyle(color: dark ? Colors.white70 : colorScheme.secondary.withValues(alpha: 0.8)),
      errorStyle: TextStyle(color: colorScheme.error, fontWeight: FontWeight.w600),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: (dark ? colorScheme.primary : colorScheme.secondary).withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: (dark ? colorScheme.primary : colorScheme.secondary).withValues(alpha: 0.35)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.error.withValues(alpha: 0.9), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      prefixIconColor: dark ? colorScheme.primary.withValues(alpha: 0.85) : colorScheme.secondary.withValues(alpha: 0.85),
      suffixIconColor: dark ? colorScheme.primary.withValues(alpha: 0.85) : colorScheme.secondary.withValues(alpha: 0.85),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: dark ? AppTypography.dark.sectionTitle : AppTypography.light.sectionTitle,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: dark ? AppTypography.dark.sectionTitle : AppTypography.light.sectionTitle,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: dark ? colorScheme.primary : colorScheme.secondary,
        side: BorderSide(color: dark ? colorScheme.primary : colorScheme.secondary, width: 1.5),
        backgroundColor: dark ? colorScheme.primary.withValues(alpha: 0.12) : null,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: dark ? AppTypography.dark.sectionTitle : AppTypography.light.sectionTitle,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: dark ? colorScheme.primary : colorScheme.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: dark ? AppTypography.dark.sectionTitle : AppTypography.light.sectionTitle,
      ),
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    ),
    extensions: <ThemeExtension<dynamic>>[dark ? AppColors.dark : AppColors.light, dark ? AppTypography.dark : AppTypography.light, dark ? AppShapes.dark : AppShapes.light],
    fontFamily: 'Orbitron',
    useMaterial3: true,
  );
}
