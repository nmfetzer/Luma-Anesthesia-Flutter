import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/luma_home_button.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/luma_theme.dart';
import 'special_consideration.dart';
import 'special_consideration_repository.dart';

class SpecialConsiderationDetailScreen extends StatefulWidget {
  const SpecialConsiderationDetailScreen({
    super.key,
    required this.entry,
    required this.repository,
    this.onSignIn,
    this.onSubscribe,
    this.onCrisisTopic,
  });
  final SpecialConsiderationEntry entry;
  final SpecialConsiderationDataSource repository;
  final VoidCallback? onSignIn;
  final VoidCallback? onSubscribe;
  final ValueChanged<String>? onCrisisTopic;

  @override
  State<SpecialConsiderationDetailScreen> createState() =>
      _SpecialConsiderationDetailScreenState();
}

class _SpecialConsiderationDetailScreenState
    extends State<SpecialConsiderationDetailScreen> {
  late Future<SpecialConsiderationDetail?> _detail;
  StreamSubscription<void>? _authSubscription;
  String? _deepDive;
  bool _deepBusy = false;
  String? _deepStatus;
  int _generation = 0;
  bool _paywallShown = false;

  @override
  void initState() {
    super.initState();
    _detail = _load();
    _authSubscription = widget.repository.authChanges.listen((_) {
      if (!mounted) return;
      setState(() {
        _generation++;
        _deepDive = null;
        _deepStatus = null;
        _deepBusy = false;
        _detail = _load();
      });
    });
  }

  Future<SpecialConsiderationDetail?> _load() async {
    if (!widget.entry.isPublished) return null;
    final generation = _generation;
    final detail = await widget.repository.detail(widget.entry.slug);
    if (detail == null && mounted && generation == _generation && !_paywallShown) {
      _paywallShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && generation == _generation) widget.onSubscribe?.call();
      });
    }
    return detail;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _openSource(String? value) async {
    final uri = Uri.tryParse(value ?? '');
    if (uri == null ||
        !['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty) {
      return;
    }
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw StateError('Could not open URL');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open this reference.')),
        );
      }
    }
  }

  Future<void> _loadDeepDive() async {
    final generation = _generation;
    setState(() {
      _deepBusy = true;
      _deepStatus = null;
    });
    try {
      final body = await widget.repository.deepDive(widget.entry.slug);
      if (!mounted || generation != _generation) return;
      setState(() {
        _deepDive = body;
        if (body == null || body.trim().isEmpty) {
          _deepStatus = 'This deep dive is not available to this account. '
              'Explore Luma Premium for extended clinical content.';
        }
      });
      if (body == null || body.trim().isEmpty) {
        widget.onSubscribe?.call();
      }
    } catch (_) {
      if (mounted && generation == _generation) {
        setState(
          () => _deepStatus =
              'Unable to load this deep dive. Check your connection and try again.',
        );
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _deepBusy = false);
      }
    }
  }

  Widget _markdown(String text) => MarkdownBody(
        data: text,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          p: lumaBody(size: 15, height: 1.6),
          strong: const TextStyle(fontWeight: FontWeight.w600),
          listBullet: lumaBody(size: 15),
          blockSpacing: 12,
        ),
        onTapLink: (_, href, __) => _openSource(href),
      );

  Widget _accessMessage(
    String title,
    String body, {
    String? action,
    VoidCallback? onAction,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: lumaDisplay(size: 24)),
            const SizedBox(height: 12),
            Text(body, style: lumaBody(color: LumaColors.inkSecondary)),
            if (onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(action!)),
            ],
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Special Considerations'),
        actions: const [LumaHomeButton()],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.category,
                    style: lumaBody(size: 13, color: LumaColors.inkMuted),
                  ),
                  const SizedBox(height: 10),
                  Text(entry.title, style: lumaDisplay(size: 30)),
                  const SizedBox(height: 16),
                  const Divider(),
                  if (!entry.isPublished)
                    _accessMessage(
                      'Clinical review pending',
                      'This entry is a Luma content draft. Its clinical text and deep dive '
                          'are held for review before release. '
                          'It is not yet available as a clinical reference.',
                    )
                  else
                    // A new keyed subtree prevents old protected prose from
                    // remaining visible while a changed session is rechecked.
                    FutureBuilder<SpecialConsiderationDetail?>(
                      key: ValueKey(_generation),
                      future: _detail,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (snapshot.hasError) {
                          return _accessMessage(
                            'Unable to load this entry',
                            'Check your connection and try again.',
                            action: 'Try again',
                            onAction: () => setState(() {
                              _detail = _load();
                            }),
                          );
                        }
                        final detail = snapshot.data;
                        if (detail == null) {
                          return _accessMessage(
                            'Luma Premium content',
                            'An active subscription or authorized complimentary '
                                'app access is required. Creating an account alone '
                                'does not unlock this content.',
                            action: 'View subscription options',
                            onAction: widget.onSubscribe,
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (detail.subtitle.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _markdown(detail.subtitle),
                            ],
                            const SizedBox(height: 16),
                            Text(
                              'Clinical reference only. Use patient-specific '
                              'assessment, current guidance and local protocols.',
                              style: lumaBody(
                                size: 12,
                                color: LumaColors.inkMuted,
                              ),
                            ),
                            const SizedBox(height: 20),
                            for (final section
                                in specialConsiderationSections.entries)
                              if ((detail.sections[section.key] ?? '')
                                  .trim()
                                  .isNotEmpty)
                                ExpansionTile(
                                  tilePadding: EdgeInsets.zero,
                                  childrenPadding:
                                      const EdgeInsets.only(bottom: 20),
                                  expandedCrossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  initiallyExpanded: section.key == 'snapshot',
                                  title: Text(
                                    section.value,
                                    style: lumaDisplay(size: 19),
                                  ),
                                  children: [
                                    _markdown(detail.sections[section.key]!),
                                  ],
                                ),
                            const SizedBox(height: 20),
                            Text('Deep dive', style: lumaDisplay(size: 21)),
                            const SizedBox(height: 10),
                            if (_deepDive?.isNotEmpty ?? false)
                              _markdown(_deepDive!)
                            else ...[
                              Text(
                                _deepStatus ??
                                    'Extended clinical content is included with '
                                        'Luma Premium or complimentary app access.',
                                style: lumaBody(
                                  size: 14,
                                  color: LumaColors.inkSecondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (widget.repository.hasAccount)
                                OutlinedButton(
                                  onPressed: _deepBusy ? null : _loadDeepDive,
                                  child: Text(
                                    _deepBusy
                                        ? 'Checking access…'
                                        : 'Open deep dive',
                                  ),
                                )
                              else if (widget.onSubscribe != null)
                                OutlinedButton(
                                  onPressed: widget.onSubscribe,
                                  child: const Text('View subscription options'),
                                ),
                              if (widget.repository.hasAccount &&
                                  widget.onSubscribe != null)
                                TextButton(
                                  onPressed: widget.onSubscribe,
                                  child:
                                      const Text('View subscription options'),
                                ),
                            ],
                            if (detail.crisisTopics.isNotEmpty) ...[
                              const SizedBox(height: 28),
                              Text(
                                'Related crisis topics',
                                style: lumaDisplay(size: 21),
                              ),
                              const SizedBox(height: 8),
                              if (widget.onCrisisTopic == null)
                                Text(
                                  'Cross-links will open once Crisis Hub is connected.',
                                  style: lumaBody(
                                    size: 12,
                                    color: LumaColors.inkMuted,
                                  ),
                                ),
                              for (final topic in detail.crisisTopics)
                                widget.onCrisisTopic == null
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        child: Text(
                                          topic,
                                          style: lumaBody(size: 14),
                                        ),
                                      )
                                    : TextButton(
                                        onPressed: () =>
                                            widget.onCrisisTopic!(topic),
                                        child: Text(topic),
                                      ),
                            ],
                            const SizedBox(height: 28),
                            Text('References', style: lumaDisplay(size: 21)),
                            const SizedBox(height: 8),
                            for (final reference in detail.citations)
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  alignment: Alignment.centerLeft,
                                ),
                                onPressed: () => _openSource(reference['url']),
                                child: Text(reference['label'] ?? 'Reference'),
                              ),
                            if (entry.reviewedAt != null)
                              Text(
                                'Reviewed ${entry.reviewedAt!.split('T').first}'
                                '${entry.reviewedBy == null ? '' : ' · ${entry.reviewedBy}'}',
                                style: lumaBody(
                                  size: 12,
                                  color: LumaColors.inkMuted,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
