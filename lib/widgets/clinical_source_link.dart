import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shared by both medication detail routes. Invalid URLs remain readable text.
class ClinicalSourceLink extends StatelessWidget {
  const ClinicalSourceLink({
    super.key,
    required this.url,
    required this.child,
  });

  final String? url;
  final Widget child;

  static Uri? validUri(String? value) {
    final uri = Uri.tryParse(value?.trim() ?? '');
    if (uri == null ||
        uri.host.isEmpty ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      return null;
    }
    return uri;
  }

  static Future<void> open(BuildContext context, String? url) async {
    final uri = validUri(url);
    if (uri == null) return;
    var opened = false;
    try {
      opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
    } catch (_) {
      // A missing browser handler must not crash the reference screen.
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $uri')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uri = validUri(url);
    if (uri == null) return child;
    return Semantics(
      link: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () => open(context, url),
        child: child,
      ),
    );
  }
}
