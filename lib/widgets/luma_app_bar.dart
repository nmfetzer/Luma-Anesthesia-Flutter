// -----------------------------------------------------------------------------
// LumaAppBar — the shared top bar used across primary screens.
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../theme/luma_theme.dart';

class LumaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String initials;
  const LumaAppBar({super.key, required this.title, this.initials = 'NF'});

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 52,
      leadingWidth: 88,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, size: 20),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 16),
            onPressed: () {},
          ),
        ],
      ),
      title: Text(title, style: lumaDisplay(size: 15, weight: FontWeight.w600)),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, size: 20),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.home_outlined, size: 20),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
          child: CircleAvatar(
            radius: 14,
            backgroundColor: LumaColors.inkNavy,
            child: Text(initials,
                style: lumaBody(
                  size: 10.5,
                  weight: FontWeight.w600,
                  color: LumaColors.cream,
                )),
          ),
        ),
      ],
    );
  }
}
