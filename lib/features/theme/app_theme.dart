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

  static const light = AppColors(brand: Color(0xFF0057FF), accent: Color(0xFFFFC107));
  static const dark = AppColors(brand: Color(0xFF90CAF9), accent: Color(0xFFFFF59D));
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
    logo: const TextStyle(fontFamily: 'Montserrat', fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
    sectionTitle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
  );
  static AppTypography dark = AppTypography(
    logo: const TextStyle(fontFamily: 'Montserrat', fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
    sectionTitle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white70),
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
  return ThemeData(brightness: dark ? Brightness.dark : Brightness.light, colorScheme: dark ? ColorScheme.dark() : ColorScheme.light(), extensions: <ThemeExtension<dynamic>>[dark ? AppColors.dark : AppColors.light, dark ? AppTypography.dark : AppTypography.light, dark ? AppShapes.dark : AppShapes.light]);
}
