// -----------------------------------------------------------------------------
// Luma Anesthesia — theme system
//
// Every color, radius, and typography choice comes directly from your
// brand-kit.json. Change values here and the whole app updates.
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LumaColors {
  // Backgrounds
  static const cream = Color(0xFFF7F4EF);
  static const creamElevated = Color(0xFFFBF8F3);
  static const white = Color(0xFFFFFFFF);

  // Ink
  static const inkNavy = Color(0xFF1F2937);
  static const inkPrimary = Color(0xFF1F1F1F);
  static const inkSecondary = Color(0xFF4A4A48);
  static const inkMuted = Color(0xFF69655E);

  // Brand accents
  static const haloGold = Color(0xFFD4A574);
  static const haloGoldLight = Color(0xFFF5E3C4);
  static const sage = Color(0xFF5B7A6E);

  // Semantic clinical
  static const highAlert = Color(0xFFB84A3E);
  static const caution = Color(0xFFC99A2E);

  // Dividers
  static const divider = Color(0xFFE5DFD5);
  static const dividerStrong = Color(0xFFD6CFC3);
}

class LumaSpacing {
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
}

class LumaRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double full = 9999;
}

/// Fraunces — display font (drug names, section headers, screen titles)
TextStyle lumaDisplay({
  double size = 17,
  FontWeight weight = FontWeight.w600,
  Color? color,
}) {
  return GoogleFonts.fraunces(
    fontSize: size,
    fontWeight: weight,
    color: color ?? LumaColors.inkNavy,
    height: 1.2,
    letterSpacing: -0.01 * size,
  );
}

/// Inter — body font (labels, buttons, prose)
TextStyle lumaBody({
  double size = 15,
  FontWeight weight = FontWeight.w400,
  Color? color,
  double? height,
}) {
  return GoogleFonts.inter(
    fontSize: size,
    fontWeight: weight,
    color: color ?? LumaColors.inkPrimary,
    height: height ?? 1.4,
  );
}

/// JetBrains Mono — numbers only (doses, timers, vitals)
TextStyle lumaMono({
  double size = 13.5,
  FontWeight weight = FontWeight.w500,
  Color? color,
}) {
  return GoogleFonts.jetBrainsMono(
    fontSize: size,
    fontWeight: weight,
    color: color ?? LumaColors.inkPrimary,
    height: 1.5,
  );
}

/// Global ThemeData for MaterialApp.
ThemeData buildLumaTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: LumaColors.cream,
    colorScheme: ColorScheme.fromSeed(
      seedColor: LumaColors.inkNavy,
      brightness: Brightness.light,
      primary: LumaColors.inkNavy,
      onPrimary: LumaColors.cream,
      secondary: LumaColors.haloGold,
      onSecondary: LumaColors.inkNavy,
      error: LumaColors.highAlert,
      surface: LumaColors.cream,
      onSurface: LumaColors.inkPrimary,
    ),
    textTheme: GoogleFonts.interTextTheme().apply(
      bodyColor: LumaColors.inkPrimary,
      displayColor: LumaColors.inkNavy,
    ),
    splashFactory: InkSparkle.splashFactory,
    dividerColor: LumaColors.divider,
    appBarTheme: AppBarTheme(
      backgroundColor: LumaColors.cream,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: LumaColors.inkNavy, size: 20),
      titleTextStyle: lumaDisplay(size: 16, weight: FontWeight.w600),
    ),
  );
}
