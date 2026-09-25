import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config.dart';

/// Protected prose is fetched separately, never from the public drug model.
class MedicationDeepDive extends StatefulWidget {
  const MedicationDeepDive({
    super.key,
    required this.medicationId,
    this.load,
    this.authChanges,
  });
  final String medicationId;
  final Future<Map<String, dynamic>> Function()? load;
  final Stream<void>? authChanges;

  @override
  State<MedicationDeepDive> createState() => _MedicationDeepDiveState();
}

class _MedicationDeepDiveState extends State<MedicationDeepDive> {
  StreamSubscription<void>? _subscription;
  bool _busy = false;
  String? _body;
  String? _message;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    final changes = widget.authChanges ??
        (widget.load == null && LumaConfig.supabaseConfigured
            ? Supabase.instance.client.auth.onAuthStateChange.map((_) {})
            : null);
    _subscription = changes?.listen((_) {
      if (!mounted) return;
      setState(() {
        _generation++;
        _body = null;
        _message = null;
        _busy = false;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetch() async {
    if (widget.load != null) return widget.load!();
    if (!LumaConfig.supabaseConfigured) return {'allowed': false};
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null || user.isAnonymous) return {'allowed': false};
    return Map<String, dynamic>.from(await client.rpc(
      'medication_deep_dive',
      params: {'p_medication_id': widget.medicationId},
    ));
  }

  Future<void> _open() async {
    final generation = _generation;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final result = await _fetch();
      if (!mounted || generation != _generation) return;
      if (result['allowed'] != true) {
        await Navigator.of(context).pushNamed('/subscribe');
      } else {
        setState(() {
          _body = result['body'] as String?;
          if (_body == null || _body!.trim().isEmpty) {
            _message = 'No Deep Dive is available for this medication yet.';
          }
        });
      }
    } catch (_) {
      if (mounted && generation == _generation) {
        setState(() => _message =
            'Unable to check access. Check your connection and try again.');
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_body?.trim().isNotEmpty ?? false)
            SelectableText(_body!)
          else ...[
            const Text(
              'Deep Dives are included with Luma Premium or authorized '
              'complimentary app access. All other Drug Library content is free.',
            ),
            if (_message != null) ...[
              const SizedBox(height: 8),
              Text(_message!),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _busy ? null : _open,
              icon: const Icon(Icons.lock_outline),
              label: Text(_busy ? 'Checking access…' : 'Open Deep Dive'),
            ),
          ],
        ],
      );
}
