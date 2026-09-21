// Luma brand tokens — single source of truth for the welcome flow.
// Update colors, fonts, and spacing here; the whole flow follows.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LumaColors {
  const LumaColors._();

  // Core palette
  static const Color navyDeep = Color(0xFF08192B);
  static const Color navy     = Color(0xFF0F2A3D);
  static const Color navyMid  = Color(0xFF1E4A6B);
  static const Color navyEdge = Color(0xFF06131F);

  static const Color cream    = Color(0xFFF7F1E6);
  static const Color gold     = Color(0xFFD4A95A);
  static const Color goldHot  = Color(0xFFF0D48A);
  static const Color goldSoft = Color(0xFFE6CF9C);

  // Text
  static const Color textPrimary   = cream;
  static Color get textSecondary => cream.withOpacity(0.68);
  static Color get textTertiary  => cream.withOpacity(0.45);
}

class LumaText {
  const LumaText._();

  static TextStyle title({double size = 32, Color? color, FontStyle? style}) =>
      GoogleFonts.fraunces(
        fontSize: size,
        height: 1.12,
        letterSpacing: -0.3,
        fontWeight: FontWeight.w400,
        fontStyle: style ?? FontStyle.normal,
        color: color ?? LumaColors.textPrimary,
      );

  static TextStyle body({double size = 14, Color? color}) => GoogleFonts.inter(
        fontSize: size,
        height: 1.55,
        color: color ?? LumaColors.textSecondary,
      );

  static TextStyle eyebrow() => GoogleFonts.inter(
        fontSize: 11,
        letterSpacing: 2.2,
        fontWeight: FontWeight.w500,
        color: LumaColors.goldSoft,
      );

  static TextStyle brandLine() => GoogleFonts.fraunces(
        fontSize: 12,
        letterSpacing: 3.4,
        fontWeight: FontWeight.w500,
        color: LumaColors.goldSoft,
      );

  static TextStyle brandLineItalic() => GoogleFonts.fraunces(
        fontSize: 13,
        letterSpacing: 0.8,
        fontStyle: FontStyle.italic,
        color: LumaColors.cream,
      );

  static TextStyle featureTitle() => GoogleFonts.fraunces(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: LumaColors.cream,
      );

  static TextStyle featureSub() => GoogleFonts.inter(
        fontSize: 10.5,
        height: 1.35,
        color: LumaColors.cream.withOpacity(0.55),
      );

  static TextStyle chip() => GoogleFonts.inter(
        fontSize: 10,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w500,
        color: LumaColors.goldSoft,
      );

  static TextStyle wordmark() => GoogleFonts.fraunces(
        fontSize: 15,
        letterSpacing: 0.3,
        color: LumaColors.cream,
      );

  static TextStyle cta() => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: LumaColors.navy,
      );

  static TextStyle note() => GoogleFonts.inter(
        fontSize: 11,
        height: 1.45,
        color: LumaColors.cream.withOpacity(0.45),
      );
}
