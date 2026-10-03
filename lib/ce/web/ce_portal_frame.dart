import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

import '../../theme/luma_theme.dart';

/// Website-only navigation, outside the Navigator so every portal route has it.
/// A new tab preserves the learner's open course or unfinished form.
class CePortalFrame extends StatelessWidget {
  const CePortalFrame({super.key, required this.child});

  final Widget child;
  static final websiteUrl = Uri.parse('https://cehalo.com/');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: const Color(0xFF0B1234),
          child: SafeArea(
            bottom: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Link(
                  uri: websiteUrl,
                  target: LinkTarget.blank,
                  builder: (context, followLink) => TextButton.icon(
                    onPressed: followLink,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFF7F3EA),
                      minimumSize: const Size(48, 48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      textStyle: lumaBody(size: 14),
                    ),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text(
                      'Back to CE HALO',
                      semanticsLabel: 'Back to CE HALO, opens in a new tab',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
