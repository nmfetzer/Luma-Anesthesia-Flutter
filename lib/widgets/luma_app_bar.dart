// -----------------------------------------------------------------------------
// LumaAppBar — the shared top bar used across primary screens.
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../theme/luma_theme.dart';
import 'luma_home_button.dart';

class LumaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const LumaAppBar({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 52,
      leadingWidth: 48,
      leading: Scaffold.of(context).hasDrawer
          ? IconButton(
              icon: const Icon(Icons.menu, size: 20),
              tooltip: 'Menu',
              onPressed: () => Scaffold.of(context).openDrawer(),
            )
          : BackButton(
              onPressed: () {
                final navigator = Navigator.of(context);
                if (navigator.canPop()) {
                  navigator.pop();
                } else {
                  navigator.pushReplacementNamed('/home');
                }
              },
            ),
      automaticallyImplyLeading: false,
      title: Text(title, style: lumaDisplay(size: 15, weight: FontWeight.w600)),
      actions: [
        const LumaHomeButton(),
        IconButton(
          tooltip: 'Account',
          onPressed: () => Navigator.pushNamed(context, '/account'),
          icon: Image.asset(
            'assets/branding/luma_symbol_halo.png',
            width: 32,
            height: 32,
          ),
        ),
      ],
    );
  }
}
