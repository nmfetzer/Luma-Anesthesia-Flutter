import 'package:flutter/material.dart';

import '../widgets/luma_home_button.dart';

/// No deferred clinical data, sign-up, subscription or AI controls are loaded.
class DeferredSectionScreen extends StatelessWidget {
  const DeferredSectionScreen({
    super.key,
    required this.title,
    this.showComingSoon = false,
  });
  final String title;
  final bool showComingSoon;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF7F1E6),
    appBar: AppBar(
      title: Text(showComingSoon ? title : 'Section unavailable'),
      actions: const [LumaHomeButton()],
    ),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                showComingSoon ? 'Coming soon' : 'Not in this version',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Fraunces',
                  fontSize: 30,
                  color: Color(0xFF0F2A3D),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                showComingSoon
                    ? '$title is planned for a future update. It is not '
                          'available or included with a subscription in this version.'
                    : 'This section is not available in this version of Luma. '
                          'Return home to explore the available references.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 24),
              const LumaHomeButton(),
            ],
          ),
        ),
      ),
    ),
  );
}
