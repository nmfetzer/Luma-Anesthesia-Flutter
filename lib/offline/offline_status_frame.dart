import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/medication_repository.dart';
import 'offline_cache.dart';
import 'offline_library.dart';

class OfflineStatusFrame extends StatefulWidget {
  const OfflineStatusFrame({
    super.key,
    required this.child,
    required this.navigatorKey,
  });
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  @override
  State<OfflineStatusFrame> createState() => _OfflineStatusFrameState();
}

class _OfflineStatusFrameState extends State<OfflineStatusFrame>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    OfflineCache.instance.reconnect();
    MedicationRepository.instance.clearCache();
    unawaited(_recheck());
  }

  Future<void> _recheck() async {
    // Remove retained protected screens immediately while revalidation runs.
    OfflineLibrary.accessChanged.add(null);
    try {
      await OfflineLibrary(Supabase.instance.client).refreshAccess();
    } catch (_) {
      /* Missing/expired access stays denied; public cache remains. */
    }
    OfflineLibrary.accessChanged.add(null);
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ValueListenableBuilder<String?>(
        valueListenable: OfflineCache.instance.notice,
        builder: (context, notice, _) => notice == null
            ? const SizedBox.shrink()
            : Material(
                color: const Color(0xFF0F2A3D),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            notice,
                            style: const TextStyle(
                              color: Color(0xFFF7F1E6),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => widget.navigatorKey.currentState
                              ?.pushNamed('/offline-downloads'),
                          child: const Text(
                            'Downloads',
                            style: TextStyle(color: Color(0xFFE6CF9C)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
      Expanded(child: widget.child),
    ],
  );
}
