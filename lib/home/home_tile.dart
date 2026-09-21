import 'package:flutter/material.dart';
import 'home_screen.dart';

enum HomeTileStyle { cream, featured, darkHero, parchment, crisis }

class HomeTile extends StatelessWidget {
  final HomeTileData data;
  const HomeTile({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final palette = _paletteFor(data.style);

    return InkWell(
      onTap: () => Navigator.pushNamed(context, data.route),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          gradient: palette.gradient,
          borderRadius: BorderRadius.circular(14),
          border: palette.border,
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4))],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -12, left: 4, right: 4,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, palette.hairline, palette.hairline, Colors.transparent],
                    stops: const [0.0, 0.2, 0.8, 1.0],
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (data.eyebrow.isNotEmpty)
                  Text(data.eyebrow.toUpperCase(), style: TextStyle(fontFamily: 'Inter', fontSize: 9, letterSpacing: 1.8, color: palette.eyebrow, fontWeight: FontWeight.w500))
                else
                  const SizedBox.shrink(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TitleText(plain: data.titlePlain, accent: data.titleAccent, textColor: palette.title, accentColor: palette.accent, style: data.style),
                    if (data.subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(data.subtitle!, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: palette.subtitle, height: 1.35), maxLines: 3, overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleText extends StatelessWidget {
  final String plain;
  final String accent;
  final Color textColor;
  final Color accentColor;
  final HomeTileStyle style;

  const _TitleText({required this.plain, required this.accent, required this.textColor, required this.accentColor, required this.style});

  @override
  Widget build(BuildContext context) {
    final double size;
    switch (style) {
      case HomeTileStyle.featured: size = 30; break;
      case HomeTileStyle.darkHero: size = 22; break;
      case HomeTileStyle.crisis: size = 18; break;
      default: size = 16;
    }
    final accentWeight = (style == HomeTileStyle.crisis) ? FontWeight.w600 : FontWeight.w500;

    return RichText(
      text: TextSpan(
        style: TextStyle(fontFamily: 'Fraunces', fontSize: size, color: textColor, fontWeight: FontWeight.w500, height: 1.05, letterSpacing: -0.2),
        children: [
          if (plain.isNotEmpty) TextSpan(text: '$plain '),
          TextSpan(text: accent, style: TextStyle(fontStyle: FontStyle.italic, color: accentColor, fontWeight: accentWeight)),
        ],
      ),
    );
  }
}

class _TilePalette {
  final Gradient gradient;
  final BoxBorder? border;
  final Color title, accent, eyebrow, subtitle, hairline;
  const _TilePalette({required this.gradient, required this.title, required this.accent, required this.eyebrow, required this.subtitle, required this.hairline, this.border});
}

_TilePalette _paletteFor(HomeTileStyle style) {
  switch (style) {
    case HomeTileStyle.featured:
      return const _TilePalette(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFBF6EC), Color(0xFFF0E4C7), Color(0xFFE6CF9C)], stops: [0.0, 0.55, 1.0]),
        title: Color(0xFF0F2A3D), accent: Color(0xFFB8864A), eyebrow: Color(0x8C0F2A3D), subtitle: Color(0xA00F2A3D), hairline: Color(0xFFB8864A),
      );
    case HomeTileStyle.darkHero:
      return _TilePalette(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F2A3D), Color(0xFF08192B)]),
        border: Border.all(color: const Color(0xFFD4A95A).withValues(alpha: 0.55), width: 0.5),
        title: const Color(0xFFF7F1E6), accent: const Color(0xFFE6CF9C), eyebrow: const Color(0xB8E6CF9C), subtitle: const Color(0xADF7F1E6), hairline: const Color(0xFFE6CF9C),
      );
    case HomeTileStyle.parchment:
      return const _TilePalette(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF5EDD8), Color(0xFFEADEBC)]),
        title: Color(0xFF0F2A3D), accent: Color(0xFF8B5A2B), eyebrow: Color(0xB88B5A2B), subtitle: Color(0xA00F2A3D), hairline: Color(0xFF8B5A2B),
      );
    case HomeTileStyle.crisis:
      return _TilePalette(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFBF6EC), Color(0xFFF5E0DA)]),
        border: Border.all(color: const Color(0xFFB43C37).withValues(alpha: 0.45), width: 0.5),
        title: const Color(0xFF8B2A26), accent: const Color(0xFFB43C37), eyebrow: const Color(0xCCB43C37), subtitle: const Color(0xB88B2A26), hairline: const Color(0xFFB43C37),
      );
    case HomeTileStyle.cream:
      return const _TilePalette(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFBF6EC), Color(0xFFF2E9D5)]),
        title: Color(0xFF0F2A3D), accent: Color(0xFFB8864A), eyebrow: Color(0x800F2A3D), subtitle: Color(0x9E0F2A3D), hairline: Color(0xFFD4A95A),
      );
  }
}
