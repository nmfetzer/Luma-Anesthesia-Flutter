import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ce/ce_pdf_viewer.dart';
import 'academy_package.dart';

/// Isolated owner review. No import in main.dart, no live course entitlement.
class AcademyPackageReviewScreen extends StatefulWidget {
  const AcademyPackageReviewScreen({
    super.key,
    required this.packages,
    required this.progress,
    required this.save,
  });
  final List<AcademyPackage> packages;
  final AcademyReviewProgress progress;
  final Future<void> Function() save;
  @override
  State<AcademyPackageReviewScreen> createState() =>
      _AcademyPackageReviewScreenState();
}

class _AcademyPackageReviewScreenState
    extends State<AcademyPackageReviewScreen> {
  static const navy = Color(0xFF081428);
  static const cream = Color(0xFFF7F3EC);
  Future<void> _open(AcademyPackage p) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _LevelScreen(
          package: p,
          progress: widget.progress,
          save: widget.save,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: cream,
    appBar: AppBar(title: const Text('Luma Academy'), backgroundColor: cream),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'CE HALO / PRIVATE OWNER REVIEW',
          style: TextStyle(fontWeight: FontWeight.bold, color: navy),
        ),
        const SizedBox(height: 16),
        const Text(
          'Your A&P learning path',
          style: TextStyle(fontFamily: 'Fraunces', fontSize: 30, color: navy),
        ),
        const SizedBox(height: 12),
        const Text(
          'Read. Recall. Apply. Check.\nNine individual levels in outline order. '
          'All are open for owner review, not unlocked through a purchase.',
        ),
        const SizedBox(height: 12),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Draft content awaiting clinical approval. Not approved-credit CE. '
              'Progress stays on this device in a review-only namespace. '
              'The proposed 90% checkpoint rule is not an NCE passing standard.',
            ),
          ),
        ),
        for (final (index, p) in widget.packages.indexed)
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: navy,
                foregroundColor: cream,
                child: Text('${index + 1}'),
              ),
              title: Text(
                p.title,
                style: const TextStyle(fontFamily: 'Fraunces'),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${p.id} • ${p.decks.length} decks\n'
                  '${widget.progress.seen(p, 'lessons').length}/${p.lessons.length} lessons reviewed • '
                  '${widget.progress.seen(p, 'cards').length}/${p.cards.length} cards recalled\n'
                  '${widget.progress.reviewGoalMet(p) ? "Review goal met; approval still pending" : "Continue review"}',
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _open(p),
            ),
          ),
      ],
    ),
  );
}

class AcademyPrivateBundleApp extends StatefulWidget {
  const AcademyPrivateBundleApp({super.key});
  @override
  State<AcademyPrivateBundleApp> createState() =>
      _AcademyPrivateBundleAppState();
}

class _AcademyPrivateBundleAppState extends State<AcademyPrivateBundleApp> {
  late final Future<Widget> _screen = _load();
  Future<Widget> _load() async {
    final raw = await rootBundle.loadString(
      'assets/academy_review/bundle.json',
    );
    final packages = (jsonDecode(raw) as List)
        .map((p) => AcademyPackage(Map<String, dynamic>.from(p as Map)))
        .toList();
    final prefs = await SharedPreferences.getInstance();
    final progress = AcademyReviewProgress.decode(
      prefs.getString('academy_owner_review_v1'),
    );
    return AcademyPackageReviewScreen(
      packages: packages,
      progress: progress,
      save: () async {
        final ok = await prefs.setString(
          'academy_owner_review_v1',
          progress.encode(),
        );
        if (!ok) throw StateError('Review progress was not saved');
      },
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF081428)),
    ),
    home: FutureBuilder<Widget>(
      future: _screen,
      builder: (_, snap) {
        if (snap.hasData) return snap.data!;
        if (snap.hasError) {
          return const Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Private Academy package unavailable. Prepare the owner-review bundle first. '
                  'No production content or purchase access has been changed.',
                ),
              ),
            ),
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    ),
  );
}

class _LevelScreen extends StatefulWidget {
  const _LevelScreen({
    required this.package,
    required this.progress,
    required this.save,
  });
  final AcademyPackage package;
  final AcademyReviewProgress progress;
  final Future<void> Function() save;
  @override
  State<_LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<_LevelScreen> {
  AcademyPackage get p => widget.package;
  Future<void> _persist() async {
    try {
      await widget.save();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Progress could not be saved. Keep this screen open and try again.',
            ),
          ),
        );
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _pdf(String asset, String title) async {
    try {
      final bytes = await rootBundle.load(asset);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            appBar: AppBar(title: Text(title)),
            body: CePdfViewer(
              bytes: bytes.buffer.asUint8List(
                bytes.offsetInBytes,
                bytes.lengthInBytes,
              ),
              title: title,
            ),
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This PDF could not be opened. Check the private review bundle.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _quiz(bool checkpoint, [String? deck]) async {
    final items = (checkpoint ? p.checkpoint : p.practice)
        .where((q) => deck == null || q['deckId'] == deck)
        .toList();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _QuizScreen(
          package: p,
          items: items,
          checkpoint: checkpoint,
          onScore: (score) async {
            widget.progress.score(
              p,
              checkpoint ? 'checkpoint' : 'practice:$deck',
              score,
              items.length,
            );
            await _persist();
          },
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pdfs = Map<String, dynamic>.from((p.data['reviewPdfs'] ?? {}) as Map);
    return Scaffold(
      appBar: AppBar(title: Text(p.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(p.data['scope'] as String),
          const SizedBox(height: 12),
          const Text('OWNER REVIEW • NO LIVE IAP • CLINICAL APPROVAL PENDING'),
          const SizedBox(height: 12),
          for (final entry in pdfs.entries)
            OutlinedButton.icon(
              onPressed: () => _pdf(entry.value as String, entry.key),
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: Text(entry.key),
            ),
          const SizedBox(height: 16),
          for (final deck in p.decks)
            Card(
              child: ExpansionTile(
                title: Text(deck['title'] as String),
                subtitle: Text(deck['objective'] as String),
                childrenPadding: const EdgeInsets.all(16),
                children: [
                  for (final lesson in p.lessons.where(
                    (l) => l['deckId'] == deck['id'],
                  )) ...[
                    Text(
                      lesson['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    for (final block
                        in (lesson['blocks'] as List)
                            .cast<Map<String, dynamic>>()) ...[
                      const SizedBox(height: 12),
                      Text(
                        block['heading'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(block['text'] as String),
                      _SourceLinks(
                        package: p,
                        ids: (block['sourceIds'] as List).cast<String>(),
                      ),
                    ],
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: widget.progress
                          .seen(p, 'lessons')
                          .contains(lesson['id']),
                      title: const Text('I reviewed this lesson'),
                      onChanged: (_) {
                        widget.progress.mark(
                          p,
                          'lessons',
                          lesson['id'] as String,
                        );
                        _persist();
                      },
                    ),
                  ],
                  FilledButton(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => _CardsScreen(
                            package: p,
                            cards: p.cards
                                .where((c) => c['deckId'] == deck['id'])
                                .toList(),
                            onRecalled: (id) async {
                              widget.progress.mark(p, 'cards', id);
                              await _persist();
                            },
                          ),
                        ),
                      );
                      if (mounted) setState(() {});
                    },
                    child: const Text('Recall this deck'),
                  ),
                  OutlinedButton(
                    onPressed: () => _quiz(false, deck['id'] as String),
                    child: const Text('Practice this deck'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Text(
            'Checkpoint: ${p.checkpoint.length} questions. Proposed target: ${p.proposedMinimum}/${p.checkpoint.length}. '
            'Answers stay hidden until submission. One form only; repeats are not fresh independent assessments.',
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => _quiz(true),
            child: const Text('Attempt mastery checkpoint'),
          ),
          Text(
            'Best review score: ${widget.progress.best(p, "checkpoint")?.toString() ?? "Not attempted"}'
            '/${p.checkpoint.length}. No paid-course unlock is granted.',
          ),
        ],
      ),
    );
  }
}

class _CardsScreen extends StatefulWidget {
  const _CardsScreen({
    required this.package,
    required this.cards,
    required this.onRecalled,
  });
  final AcademyPackage package;
  final List<Map<String, dynamic>> cards;
  final Future<void> Function(String) onRecalled;
  @override
  State<_CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<_CardsScreen> {
  int index = 0;
  bool revealed = false;
  bool busy = false;
  @override
  Widget build(BuildContext context) {
    final card = widget.cards[index];
    return Scaffold(
      appBar: AppBar(title: const Text('Recall deck')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Card ${index + 1} of ${widget.cards.length}'),
          const SizedBox(height: 24),
          Text(
            card['front'] as String,
            style: const TextStyle(fontFamily: 'Fraunces', fontSize: 26),
          ),
          const SizedBox(height: 24),
          if (!revealed)
            FilledButton(
              onPressed: () => setState(() => revealed = true),
              child: const Text('Reveal answer'),
            )
          else ...[
            Text(
              card['back'] as String,
              style: const TextStyle(fontSize: 17, height: 1.5),
            ),
            _SourceLinks(
              package: widget.package,
              ids: (card['sourceIds'] as List).cast<String>(),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: busy
                  ? null
                  : () async {
                      setState(() => busy = true);
                      await widget.onRecalled(card['id'] as String);
                      if (!mounted || !context.mounted) return;
                      if (index == widget.cards.length - 1) {
                        Navigator.pop(context);
                        return;
                      }
                      setState(() {
                        index++;
                        revealed = false;
                        busy = false;
                      });
                    },
              child: Text(
                index == widget.cards.length - 1
                    ? 'Mark recalled and finish'
                    : 'Mark recalled and continue',
              ),
            ),
          ],
          TextButton(
            onPressed: () {
              if (index == widget.cards.length - 1) {
                Navigator.pop(context);
                return;
              }
              setState(() {
                index++;
                revealed = false;
              });
            },
            child: const Text('Keep for review; skip without credit'),
          ),
        ],
      ),
    );
  }
}

class _QuizScreen extends StatefulWidget {
  const _QuizScreen({
    required this.package,
    required this.items,
    required this.checkpoint,
    required this.onScore,
  });
  final AcademyPackage package;
  final List<Map<String, dynamic>> items;
  final bool checkpoint;
  final Future<void> Function(int) onScore;
  @override
  State<_QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<_QuizScreen> {
  final answers = <String, String>{};
  int index = 0;
  bool submitted = false;
  bool busy = false;
  int get score => widget.items
      .where((q) => answers[q['id']] == q['correctOptionId'])
      .length;
  Widget explanation(Map<String, dynamic> q) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Correct answer: ${q["correctOptionId"]}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(q['rationale'] as String),
      for (final entry in (q['distractorRationales'] as Map).entries)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text('${entry.key}: ${entry.value}'),
        ),
      Text('Revisit: ${(q["lessonIds"] as List).join(", ")}'),
      _SourceLinks(
        package: widget.package,
        ids: (q['sourceIds'] as List).cast<String>(),
      ),
    ],
  );
  Future<void> next() async {
    if (index < widget.items.length - 1) {
      setState(() => index++);
      return;
    }
    if (answers.length != widget.items.length || busy) return;
    setState(() => busy = true);
    await widget.onScore(score);
    if (mounted) {
      setState(() {
        submitted = true;
        busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.items[index];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.checkpoint ? 'Mastery checkpoint' : 'Practice'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (submitted) ...[
            Text(
              '$score/${widget.items.length}',
              style: const TextStyle(fontFamily: 'Fraunces', fontSize: 36),
            ),
            const Text(
              'Review score only. Not an NCE result or a paid-course unlock.',
            ),
            for (final item in widget.items)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['prompt'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Your answer: ${answers[item["id"]]}'),
                      explanation(item),
                    ],
                  ),
                ),
              ),
          ] else ...[
            Text('Question ${index + 1} of ${widget.items.length}'),
            const SizedBox(height: 20),
            Text(
              q['prompt'] as String,
              style: const TextStyle(fontFamily: 'Fraunces', fontSize: 24),
            ),
            const SizedBox(height: 20),
            for (final option
                in (q['options'] as List).cast<Map<String, dynamic>>())
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OutlinedButton(
                  onPressed: answers.containsKey(q['id'])
                      ? null
                      : () => setState(
                          () => answers[q['id'] as String] =
                              option['id'] as String,
                        ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      '${option["id"]}. ${option["text"]}'
                      '${answers[q["id"]] == option["id"] ? " (selected)" : ""}',
                    ),
                  ),
                ),
              ),
            if (answers.containsKey(q['id']) && !widget.checkpoint)
              explanation(q),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: !answers.containsKey(q['id']) || busy ? null : next,
              child: Text(
                index == widget.items.length - 1
                    ? 'Submit answers'
                    : 'Next question',
              ),
            ),
            if (widget.checkpoint)
              const Text(
                'Answer explanations appear only after all questions are submitted.',
              ),
          ],
        ],
      ),
    );
  }
}

class _SourceLinks extends StatelessWidget {
  const _SourceLinks({required this.package, required this.ids});
  final AcademyPackage package;
  final List<String> ids;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final id in ids)
        TextButton(
          onPressed: () async {
            final source = (package.data['sources'] as Map)[id] as Map;
            final uri = Uri.tryParse(source['url'] as String);
            bool opened = false;
            try {
              if (uri != null && uri.scheme == 'https') {
                opened = await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
              }
            } catch (_) {
              /* Keep the lesson visible on platform failure. */
            }
            if (!opened && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Unable to open source. Try again online.'),
                ),
              );
            }
          },
          child: Text(
            ((package.data['sources'] as Map)[id] as Map)['title'] as String,
          ),
        ),
    ],
  );
}
