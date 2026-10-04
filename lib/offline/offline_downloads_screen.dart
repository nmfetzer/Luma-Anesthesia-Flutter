import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/medication_repository.dart';
import '../theme/luma_theme.dart';
import '../widgets/luma_home_button.dart';
import 'offline_cache.dart';
import 'offline_library.dart';

class OfflineDownloadsScreen extends StatefulWidget {
  const OfflineDownloadsScreen({super.key});
  @override
  State<OfflineDownloadsScreen> createState() => _OfflineDownloadsScreenState();
}

class _OfflineDownloadsScreenState extends State<OfflineDownloadsScreen> {
  StreamSubscription<String>? _progress;
  String? _message;
  String? _completed;
  bool _busy = false;
  final _cache = OfflineCache.instance;

  @override
  void initState() {
    super.initState();
    _busy = OfflineLibrary.downloading;
    _progress = OfflineLibrary.progress.stream.listen((value) {
      if (mounted)
        setState(() {
          if (OfflineLibrary.downloading) _message = value;
          _busy = OfflineLibrary.downloading;
        });
      if (!OfflineLibrary.downloading) unawaited(_status());
    });
    unawaited(_status());
  }

  Future<void> _status() async {
    String? completed;
    try {
      // Status must not itself change the clinical downloaded-copy banner.
      final previous = _cache.notice.value;
      final data = await _cache.saved('download_complete') as Map;
      _cache.notice.value = previous;
      completed =
          'Last complete download: ${DateTime.parse(data['saved_at'] as String).toLocal().toString().substring(0, 16)}';
    } catch (_) {}
    if (mounted) setState(() => _completed = completed);
  }

  Future<void> _download() async {
    setState(() {
      _busy = true;
      _message = 'Checking access and preparing downloads…';
    });
    try {
      final message = await OfflineLibrary(Supabase.instance.client).download();
      MedicationRepository.instance.clearCache();
      if (mounted) setState(() => _message = message);
    } catch (error) {
      if (mounted)
        setState(
          () => _message =
              'Download incomplete. Check your connection and available device storage, '
              'then try again. Previously saved references remain available. '
              '${error is StateError ? error.message : ''}',
        );
    } finally {
      if (mounted) setState(() => _busy = false);
      await _status();
    }
  }

  Future<void> _clear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove downloaded references?'),
        content: const Text(
          'This removes saved clinical references from this device, '
          'not your account or purchases. You will need internet to download them again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep downloads'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove downloads'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _cache.clear();
    MedicationRepository.instance.clearCache();
    OfflineLibrary.accessChanged.add(null);
    if (mounted)
      setState(() {
        _completed = null;
        _message = 'Downloads removed from this device.';
      });
  }

  Widget _bullet(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('•  '),
        Expanded(child: Text(text, style: lumaBody())),
      ],
    ),
  );

  @override
  void dispose() {
    _progress?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: LumaColors.cream,
    appBar: AppBar(
      title: const Text('Offline downloads'),
      actions: const [LumaHomeButton()],
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Your references, ready before you need them',
                style: lumaDisplay(size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                'Download while connected, then open saved clinical references '
                'without internet in the installed app. Update regularly so you have the latest content.',
                style: lumaBody(),
              ),
              const SizedBox(height: 24),
              _bullet(
                'Drug Library, vasopressors, infusions, transfusions, Quick References, '
                'and free Crisis Hub references can be saved. Mental Health & Recovery '
                'resources are included with the app and remain free.',
              ),
              _bullet(
                'With verified paid or complimentary access, published Crisis Hub, '
                'Pathophysiology & Anesthesia Considerations, and available Deep Dives '
                'can also be downloaded in the installed app.',
              ),
              _bullet(
                'Paid downloads are encrypted and tied to your account. Connect at '
                'least every 72 hours to recheck access, or sooner if your access expires. '
                'Signing out removes paid downloads.',
              ),
              _bullet(
                'Diagnostics and Regional & Procedures reference text is included in the installed app; '
                'no separate content download is needed. Open the app online first '
                'to verify paid or complimentary access. Offline access to these references '
                'uses the same maximum 72-hour access check, or ends sooner if your access expires.',
              ),
              _bullet(
                'The Practice Guidelines directory is also included in the app. '
                'Its linked publisher documents are not stored offline.',
              ),
              _bullet(
                'Internet is still required for account actions, purchases and Restore '
                'Purchases, external sources and algorithm PDFs, CE progress sync, '
                'completion and certificates. CE course downloads are not included here.',
              ),
              if (kIsWeb)
                _bullet(
                  'Browser: only free reference data can be saved. Embedded previews '
                  'keep downloads only for the current page session. Reloading may '
                  'need internet. Use the installed iOS or Android app for reliable '
                  'offline access and protected downloads.',
                ),
              const Divider(height: 32),
              Text(
                _completed ?? 'No complete download recorded on this device.',
                style: lumaBody(weight: FontWeight.w600),
              ),
              if (_cache.privateAllowed) ...[
                const SizedBox(height: 8),
                Text(
                  'Paid access recheck due: ${_cache.privateUntil!.toLocal().toString().substring(0, 16)}',
                  style: lumaBody(size: 14),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _busy ? null : _download,
                icon: const Icon(Icons.download_for_offline_outlined),
                label: Text(
                  _busy ? 'Downloading…' : 'Download / update references',
                ),
              ),
              if (_busy)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: LinearProgressIndicator(),
                ),
              if (_message != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(_message!, style: lumaBody()),
                  ),
                ),
              TextButton(
                onPressed: _busy ? null : _clear,
                child: const Text('Remove downloads from this device'),
              ),
              const SizedBox(height: 16),
              Text(
                'Downloaded content is a dated reference copy, not a live update. '
                'Always verify dosing and follow current institutional protocols.',
                style: lumaBody(size: 14, color: LumaColors.inkSecondary),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
