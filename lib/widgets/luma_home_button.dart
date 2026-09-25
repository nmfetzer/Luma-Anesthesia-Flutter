import 'package:flutter/material.dart';

/// Always returns to the tile dashboard, not the welcome carousel.
class LumaHomeButton extends StatelessWidget {
  const LumaHomeButton({super.key, this.color});
  final Color? color;

  @override
  Widget build(BuildContext context) => TextButton.icon(
        onPressed: () =>
            Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false),
        icon: const Icon(Icons.home_outlined, size: 20),
        label: const Text('Home'),
        style: TextButton.styleFrom(
          foregroundColor: color,
          minimumSize: const Size(48, 48),
        ),
      );
}
