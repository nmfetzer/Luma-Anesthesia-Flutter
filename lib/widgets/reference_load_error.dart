import 'package:flutter/material.dart';

/// A network failure is not an empty clinical library or a paywall.
class ReferenceLoadError extends StatelessWidget {
  const ReferenceLoadError({super.key, required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined),
          const SizedBox(height: 12),
          const Text(
            'Unable to load this reference library. An internet connection '
            'is currently required. Reconnect, then try again.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}
