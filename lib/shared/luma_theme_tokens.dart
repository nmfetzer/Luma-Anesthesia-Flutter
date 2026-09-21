import 'package:flutter/material.dart';

/// Shared design tokens for the clinical-reference aesthetic.
class LumaTokens {
  LumaTokens._();

  static const Color navyDeep = Color(0xFF08192B);
  static const Color navyMid = Color(0xFF0F2A3D);
  static const Color navyLight = Color(0xFF133451);
  static const Color cream = Color(0xFFFBF6EC);
  static const Color creamSoft = Color(0xFFF7F1E6);
  static const Color creamDeep = Color(0xFFF2E9D5);
  static const Color parchment = Color(0xFFF5EDD8);

  static const Color goldPrimary = Color(0xFFD4A95A);
  static const Color goldLight = Color(0xFFE6CF9C);
  static const Color goldDeep = Color(0xFFB8864A);

  static const Color alertRed = Color(0xFFB43C37);
  static const Color alertRedDeep = Color(0xFF8B2A26);
  static const Color alertRedBg = Color(0xFFF5E0DA);

  static const Color textPrimary = Color(0xFF0F2A3D);
  static const Color textSecondary = Color(0x990F2A3D);
  static const Color textMuted = Color(0x660F2A3D);
  static const Color textOnDark = Color(0xFFF7F1E6);
  static const Color textOnDarkMuted = Color(0xB8F7F1E6);

  static Color hairlineGold = goldLight.withValues(alpha: 0.4);
  static Color hairlineNavy = navyMid.withValues(alpha: 0.12);
  static Color hairlineRed = alertRed.withValues(alpha: 0.45);

  static const String fontSerif = 'Fraunces';
  static const String fontSans = 'Inter';

  static const TextStyle eyebrow = TextStyle(
    fontFamily: fontSans, fontSize: 10, letterSpacing: 1.6,
    fontWeight: FontWeight.w500, color: textSecondary,
  );
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontSerif, fontSize: 15, fontWeight: FontWeight.w500,
    color: textPrimary, letterSpacing: -0.1,
  );
  static const TextStyle body = TextStyle(
    fontFamily: fontSans, fontSize: 13, height: 1.45, color: textPrimary,
  );
  static const TextStyle bodyMuted = TextStyle(
    fontFamily: fontSans, fontSize: 13, height: 1.45, color: textSecondary,
  );
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontSans, fontSize: 11.5, height: 1.4, color: textSecondary,
  );
  static const TextStyle drugName = TextStyle(
    fontFamily: fontSerif, fontSize: 18, fontWeight: FontWeight.w500,
    color: textPrimary, letterSpacing: -0.2,
  );
  static const TextStyle drugTitle = TextStyle(
    fontFamily: fontSerif, fontSize: 26, fontWeight: FontWeight.w500,
    color: textPrimary, letterSpacing: -0.4, height: 1.1,
  );
  static const TextStyle classLabel = TextStyle(
    fontFamily: fontSans, fontSize: 10.5, letterSpacing: 1.4,
    fontWeight: FontWeight.w500, color: goldDeep,
  );
  static const TextStyle highAlertLabel = TextStyle(
    fontFamily: fontSans, fontSize: 10, letterSpacing: 1.8,
    fontWeight: FontWeight.w600, color: alertRed,
  );
  static const TextStyle filterInactive = TextStyle(
    fontFamily: fontSans, fontSize: 11, letterSpacing: 1.3,
    fontWeight: FontWeight.w500, color: textSecondary,
  );
  static const TextStyle filterActive = TextStyle(
    fontFamily: fontSans, fontSize: 11, letterSpacing: 1.3,
    fontWeight: FontWeight.w600, color: textPrimary,
  );
  static const TextStyle dosingValue = TextStyle(
    fontFamily: fontSans, fontSize: 13.5, fontWeight: FontWeight.w500,
    color: textPrimary, fontFeatures: [FontFeature.tabularFigures()],
  );
  static const TextStyle dosingLabel = TextStyle(
    fontFamily: fontSans, fontSize: 11, letterSpacing: 1.2,
    fontWeight: FontWeight.w500, color: textSecondary,
  );
}

/// Cream card with a thin uniform hairline. High-alert variant paints
/// a red left rail as a child, not as part of the border (Flutter
/// requires uniform border colors when borderRadius is set).
class LumaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final bool highAlert;
  final VoidCallback? onTap;

  const LumaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(18, 16, 18, 16),
    this.highAlert = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = highAlert
        ? LumaTokens.hairlineRed
        : LumaTokens.hairlineNavy;

    Widget card = Container(
      decoration: BoxDecoration(
        color: LumaTokens.cream,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (highAlert)
            Positioned(
              left: 0, top: 0, bottom: 0,
              child: Container(width: 3, color: LumaTokens.alertRed),
            ),
          Padding(
            padding: EdgeInsets.only(left: highAlert ? padding.left + 3 : padding.left)
                .add(EdgeInsets.only(
                  right: padding.right,
                  top: padding.top,
                  bottom: padding.bottom,
                )),
            child: child,
          ),
        ],
      ),
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: card,
      ),
    );
  }
}

class LumaSectionHeader extends StatelessWidget {
  final String label;
  const LumaSectionHeader(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: LumaTokens.eyebrow.copyWith(color: LumaTokens.goldDeep)),
          const SizedBox(height: 6),
          Container(height: 0.5, color: LumaTokens.hairlineGold),
        ],
      ),
    );
  }
}

class LumaKeyValue extends StatelessWidget {
  final String label;
  final String value;
  final String? note;

  const LumaKeyValue({
    super.key,
    required this.label,
    required this.value,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: LumaTokens.dosingLabel),
          const SizedBox(height: 3),
          Text(value, style: LumaTokens.dosingValue),
          if (note != null) ...[
            const SizedBox(height: 3),
            Text(note!, style: LumaTokens.bodySmall),
          ],
        ],
      ),
    );
  }
}
