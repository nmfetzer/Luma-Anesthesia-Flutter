import 'package:flutter/material.dart';

import 'home_screen.dart';

enum HomeTileStyle { cream, featured, darkHero, parchment, crisis }

/// Layout B: natural-height cards, with no clipped titles or fixed text boxes.
class HomeTile extends StatelessWidget {
  const HomeTile({super.key, required this.data, this.wide = false});
  final HomeTileData data;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final dark = data.style == HomeTileStyle.darkHero;
    final featured = data.style == HomeTileStyle.featured;
    final background = dark
        ? const Color(0xFF213B4C)
        : featured
        ? const Color(0xFFEFE2C8)
        : const Color(0xFFF7F1E6);
    final titleColor = dark ? const Color(0xFFE6CF9C) : const Color(0xFF153247);
    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: dark ? const Color(0xFF9C875E) : const Color(0xFFE2DAC8),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, data.route),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: wide ? 76 : 100),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${data.titlePlain} ${data.titleAccent}'.trim(),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
                if (data.subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    data.subtitle!,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      height: 1.4,
                      color: dark
                          ? const Color(0xFFD6DCE0)
                          : const Color(0xFF536471),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
