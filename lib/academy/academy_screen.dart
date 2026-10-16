import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ce/ce_pdf_viewer.dart';
import 'academy_repository.dart';

const _navy = Color(0xFF081428);
const _cream = Color(0xFFF7F3EC);
const _gold = Color(0xFFD4AE5C);
List<Map<String, dynamic>> _list(dynamic value) => (value as List? ?? [])
    .map((e) => Map<String, dynamic>.from(e as Map))
    .toList();
String _id(Map p) => (p['levelId'] ?? p['id']) as String;
List<Map<String, dynamic>> _sources(dynamic value) => value is Map
    ? value.entries
          .map(
            (e) => <String, dynamic>{
              ...Map<String, dynamic>.from(e.value as Map),
              'id': e.key,
            },
          )
          .toList()
    : _list(value);
String _version(Map p) => (p['version'] ?? p['contentVersion']) as String;

/// A separate nested Navigator is destroyed on account changes, clearing every
/// open card, answer, PDF and cached lesson from the previous account.
class AcademyScreen extends StatefulWidget {
  const AcademyScreen({super.key});
  @override
  State<AcademyScreen> createState() => _AcademyScreenState();
}

class _AcademyScreenState extends State<AcademyScreen> {
  final _client = Supabase.instance.client;
  StreamSubscription<AuthState>? _auth;
  String? _user;
  @override
  void initState() {
    super.initState();
    _user = _client.auth.currentUser?.id;
    _auth = _client.auth.onAuthStateChange.listen((state) {
      if (mounted && _user != state.session?.user.id) {
        setState(() => _user = state.session?.user.id);
      }
    });
  }

  @override
  void dispose() {
    _auth?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null || _client.auth.currentUser?.isAnonymous == true) {
      return _Frame(
        title: 'Luma Academy',
        children: [
          const _Heading('Your study path. One account.'),
          const Text(
            'Sign in with your Luma account to use Academy on the website and in supported app builds. Your study progress belongs to your account.',
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.of(
              context,
              rootNavigator: true,
            ).pushNamed('/account'),
            child: const Text('Sign in to Luma'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Academy is a separate study package, not AANA-approved CE credit. Existing CE courses and purchases are unchanged.',
          ),
        ],
      );
    }
    return Navigator(
      key: ValueKey(_user),
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) =>
            AcademyLearningHome(repository: AcademyRepository(_client)),
      ),
    );
  }
}

class AcademyLearningHome extends StatefulWidget {
  const AcademyLearningHome({super.key, required this.repository});
  final AcademyRepository repository;
  @override
  State<AcademyLearningHome> createState() => _AcademyLearningHomeState();
}

class _AcademyLearningHomeState extends State<AcademyLearningHome>
    with WidgetsBindingObserver {
  Map<String, dynamic>? catalog;
  AcademyProgress progress = AcademyProgress({});
  String? error;
  bool loading = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        loading = true;
        error = null;
      });
    }
    try {
      final c = await widget.repository.catalog();
      final p = c['hasAccess'] == true
          ? await widget.repository.progress()
          : <String, dynamic>{};
      if (mounted) {
        setState(() {
          catalog = c;
          progress = AcademyProgress(p);
          loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          error =
              'Academy could not load. Check your connection and try again.';
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final access = catalog?['hasAccess'] == true;
    return _Frame(
      title: 'Luma Academy',
      actions: [
        if (Navigator.of(context, rootNavigator: true).canPop())
          IconButton(
            tooltip: 'Close Academy',
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            icon: const Icon(Icons.close),
          ),
        IconButton(
          tooltip: 'Refresh account progress',
          onPressed: loading ? null : _load,
          icon: const Icon(Icons.refresh),
        ),
      ],
      children: [
        const Text('CE HALO  /  NCE STUDY'),
        const SizedBox(height: 12),
        const _Heading('Your A&P learning path'),
        const Text(
          'Read. Recall. Apply. Check. Small decks, focused practice, and nine individual sections in outline order.',
        ),
        const SizedBox(height: 20),
        if (loading)
          const LinearProgressIndicator()
        else if (error != null)
          _ErrorBox(error!, _load)
        else ...[
          _Notice(
            access
                ? 'Account progress is connected. Successfully saved work is available in other connected Academy clients. This study course does not award CE credit.'
                : 'Academy access is not active for this account. Sales are not open yet. Signing in or purchasing a CE course does not unlock Academy.',
          ),
          if (catalog?['accessKind'] == 'owner_review')
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Owner review access. All nine sections are open; the final mastery-unlock policy is not yet enabled.',
              ),
            ),
          for (final p in _list(catalog?['levels']))
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.all(20),
                leading: Text(
                  '${p['position']}'.padLeft(2, '0'),
                  style: const TextStyle(
                    fontSize: 24,
                    color: _navy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                title: Text(
                  p['title'] as String,
                  style: const TextStyle(fontFamily: 'Fraunces', fontSize: 22),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${p['deckCount']} small decks · ${p['cardCount']} flashcards\n'
                    '${progress.seen(_id(p), _version(p), 'lessons').length}/${p['lessonCount']} lessons reviewed · '
                    '${progress.seen(_id(p), _version(p), 'cards').length}/${p['cardCount']} cards recalled',
                  ),
                ),
                trailing: Icon(
                  access ? Icons.chevron_right : Icons.lock_outline,
                ),
                onTap: !access
                    ? null
                    : () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => _Level(
                              repository: widget.repository,
                              summary: p,
                            ),
                          ),
                        );
                        if (mounted) await _load();
                      },
              ),
            ),
        ],
      ],
    );
  }
}

class _Level extends StatefulWidget {
  const _Level({required this.repository, required this.summary});
  final AcademyRepository repository;
  final Map<String, dynamic> summary;
  @override
  State<_Level> createState() => _LevelState();
}

class _LevelState extends State<_Level> {
  Map<String, dynamic>? p;
  AcademyProgress progress = AcademyProgress({});
  String? error, saving;
  bool loading = true;
  String get id => _id(widget.summary);
  String get version => _version(widget.summary);
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final content = await widget.repository.level(id, version);
      final state = await widget.repository.progress();
      if (mounted) {
        setState(() {
          p = content;
          progress = AcademyProgress(state);
          loading = false;
          error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
          error = 'This section is unavailable. Check your connection and Academy access, then retry.';
        });
      }
    }
  }

  Future<void> _mark(String kind, String item) async {
    setState(() => saving = item);
    try {
      await widget.repository.mark(id, version, kind, item);
      final state = await widget.repository.progress();
      if (mounted) setState(() => progress = AcademyProgress(state));
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'Your progress was not saved. Please retry before leaving this page.',
        );
      }
    } finally {
      if (mounted) setState(() => saving = null);
    }
  }

  Future<void> _pdf(String kind) async {
    setState(() => saving = kind);
    try {
      final bytes = await widget.repository.document(id, version, kind);
      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: Text('${widget.summary['title']}: $kind')),
              body: CePdfViewer(bytes: bytes, title: kind),
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => error = 'The PDF could not load. Please retry.');
      }
    } finally {
      if (mounted) setState(() => saving = null);
    }
  }

  Future<void> _round(String kind, [String scope = 'all']) async {
    final items = kind == 'checkpoint'
        ? _list((p!['masteryCheckpoint'] as Map)['items'])
        : _list(p!['practiceQuestions'])
              .where((q) => scope == 'all' || q['deckId'] == scope)
              .toList();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _Quiz(
          repository: widget.repository,
          package: p!,
          kind: kind,
          scope: scope,
          questions: items,
        ),
      ),
    );
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final best = progress.bestCheckpoint(id, version);
    return _Frame(
      title: widget.summary['title'] as String,
      children: [
        if (loading) const LinearProgressIndicator(),
        if (error != null)
          _ErrorBox(error!, () {
            setState(() => error = null);
            _load();
          }),
        if (p != null) ...[
          Text('$id  /  ANATOMY & PHYSIOLOGY'),
          const SizedBox(height: 12),
          _Heading(widget.summary['title'] as String),
          const Text(
            'Learn one small deck at a time. Use the interactive flashcards and questions below; PDFs are optional.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: saving == null ? () => _pdf('Study guide') : null,
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Study guide PDF'),
              ),
              FilledButton(
                onPressed: () => _round('practice'),
                child: const Text('Practice this section'),
              ),
              OutlinedButton(
                onPressed: () => _round('checkpoint'),
                child: const Text('Section checkpoint'),
              ),
            ],
          ),
          if (saving != null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: LinearProgressIndicator(),
            ),
          const SizedBox(height: 16),
          Text(
            best == null
                ? 'No checkpoint score saved yet. Checkpoints provide feedback; mastery unlocking is not active.'
                : 'Best checkpoint: ${best['correct']}/${best['total']}. Saved to your account. Mastery unlocking is not active.',
          ),
          const SizedBox(height: 16),
          for (final (index, deck) in _list(p!['decks']).indexed)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ExpansionTile(
                key: PageStorageKey('$id:${deck['id']}'),
                title: Text('${index + 1}. ${deck['title']}'),
                subtitle: Text(
                  '${_list(p!['flashcards']).where((c) => c['deckId'] == deck['id']).length} cards · focused practice',
                ),
                childrenPadding: const EdgeInsets.all(20),
                children: [
                  for (final lesson in _list(
                    p!['lessons'],
                  ).where((l) => l['deckId'] == deck['id'])) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        lesson['title'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    for (final block in _list(lesson['blocks'])) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          block['heading'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(block['text'] as String),
                      ),
                      _Sources(package: p!, ids: block['sourceIds']),
                    ],
                    if (lesson['takeaway'] != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(lesson['takeaway'] as String),
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed:
                            saving != null ||
                                progress
                                    .seen(id, version, 'lessons')
                                    .contains(lesson['id'])
                            ? null
                            : () => _mark('lessons', lesson['id'] as String),
                        icon: Icon(
                          progress
                                  .seen(id, version, 'lessons')
                                  .contains(lesson['id'])
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                        ),
                        label: Text(
                          progress
                                  .seen(id, version, 'lessons')
                                  .contains(lesson['id'])
                              ? 'Reviewed · saved'
                              : 'Mark lesson reviewed',
                        ),
                      ),
                    ),
                    const Divider(height: 28),
                  ],
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton(
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => _Cards(
                                repository: widget.repository,
                                package: p!,
                                deck: deck,
                              ),
                            ),
                          );
                          if (mounted) await _load();
                        },
                        child: const Text('Recall this deck'),
                      ),
                      OutlinedButton(
                        onPressed: () =>
                            _round('practice', deck['id'] as String),
                        child: const Text('Practice this deck'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if ((p!['documents'] as List? ?? []).length > 1)
            ExpansionTile(
              title: const Text('Optional PDF companions'),
              subtitle: const Text(
                'Interactive study does not require these PDFs.',
              ),
              children: [
                for (final kind in (p!['documents'] as List).where(
                  (k) => k != 'Study guide',
                ))
                  ListTile(
                    title: Text(kind as String),
                    trailing: const Icon(Icons.picture_as_pdf_outlined),
                    onTap: saving == null ? () => _pdf(kind) : null,
                  ),
              ],
            ),
        ],
      ],
    );
  }
}

class _Cards extends StatefulWidget {
  const _Cards({
    required this.repository,
    required this.package,
    required this.deck,
  });
  final AcademyRepository repository;
  final Map<String, dynamic> package, deck;
  @override
  State<_Cards> createState() => _CardsState();
}

class _CardsState extends State<_Cards> {
  late final cards = _list(widget.package['flashcards'])
      .where((c) => c['deckId'] == widget.deck['id'])
      .toList();
  int index = 0, recalled = 0;
  bool revealed = false, busy = false;
  String? error;
  void _next() {
    setState(() {
      index++;
      revealed = false;
      error = null;
    });
  }

  Future<void> _recall() async {
    setState(() => busy = true);
    try {
      await widget.repository.mark(
        _id(widget.package),
        _version(widget.package),
        'cards',
        cards[index]['id'] as String,
      );
      if (mounted) {
        recalled++;
        _next();
      }
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Not saved. Check your connection, then retry.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => _Frame(
    title: widget.deck['title'] as String,
    children: [
      if (index >= cards.length) ...[
        const _Heading('Deck complete'),
        Text(
          '$recalled of ${cards.length} cards marked recalled in this round. Saved recalls are attached to your account.',
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Back to section'),
        ),
        TextButton(
          onPressed: () => setState(() {
            index = 0;
            recalled = 0;
            revealed = false;
          }),
          child: const Text('Study this deck again'),
        ),
      ] else ...[
        Text('CARD ${index + 1} OF ${cards.length}'),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: index / cards.length,
          color: _gold,
          backgroundColor: Colors.black12,
        ),
        const SizedBox(height: 24),
        _Heading(cards[index]['front'] as String),
        const Text('Try to answer before revealing the explanation.'),
        const SizedBox(height: 24),
        if (!revealed)
          FilledButton(
            onPressed: () => setState(() => revealed = true),
            child: const Text('Reveal answer'),
          )
        else ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(cards[index]['back'] as String),
            ),
          ),
          _Sources(package: widget.package, ids: cards[index]['sourceIds']),
          const SizedBox(height: 20),
          if (error != null) _ErrorBox(error!, busy ? null : _recall),
          FilledButton(
            onPressed: busy ? null : _recall,
            child: Text(
              busy ? 'Saving…' : 'I recalled this · save and continue',
            ),
          ),
          TextButton(
            onPressed: busy ? null : _next,
            child: const Text('Keep for review · continue'),
          ),
        ],
      ],
    ],
  );
}

String _attemptId() {
  final r = Random.secure();
  final b = List<int>.generate(16, (_) => r.nextInt(256));
  b[6] = (b[6] & 15) | 64;
  b[8] = (b[8] & 63) | 128;
  final h = b.map((v) => v.toRadixString(16).padLeft(2, '0')).join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
}

class _Quiz extends StatefulWidget {
  const _Quiz({
    required this.repository,
    required this.package,
    required this.kind,
    required this.scope,
    required this.questions,
  });
  final AcademyRepository repository;
  final Map<String, dynamic> package;
  final String kind, scope;
  final List<Map<String, dynamic>> questions;
  @override
  State<_Quiz> createState() => _QuizState();
}

class _QuizState extends State<_Quiz> {
  final answers = <String, String>{};
  final attempt = _attemptId();
  int index = 0;
  bool busy = false, submitted = false;
  String? error;
  Map<String, dynamic>? result;
  Future<void> _submit() async {
    setState(() {
      busy = true;
      submitted = true;
      error = null;
    });
    try {
      final value = await widget.repository.submit(
        _id(widget.package),
        _version(widget.package),
        widget.kind,
        widget.scope,
        attempt,
        answers,
      );
      if (mounted) setState(() => result = value);
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'Results are not saved yet. Retry submission; the same attempt will not count twice.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questions[index];
    final selected = answers[q['id']];
    final checkpoint = widget.kind == 'checkpoint';
    return _Frame(
      title: checkpoint ? 'Section checkpoint' : 'Practice round',
      children: [
        if (result != null) ...[
          _Heading('${result!['correct']} / ${result!['total']} correct'),
          const Text(
            'Scored on the server and saved to your account. Review each explanation below. This result does not award CE credit or activate a mastery unlock.',
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back to section'),
          ),
          for (final item in _list(result!['feedback']))
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['prompt'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text('Your answer: ${item['selectedOptionId']}'),
                    _Explanation(question: item, package: widget.package),
                  ],
                ),
              ),
            ),
        ] else ...[
          Text('QUESTION ${index + 1} OF ${widget.questions.length}'),
          const SizedBox(height: 16),
          _Heading(q['prompt'] as String),
          for (final o in _list(q['options']))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(18),
                  backgroundColor: selected == o['id'] ? _navy : null,
                  foregroundColor: selected == o['id'] ? _cream : _navy,
                ),
                onPressed:
                    busy || submitted || (!checkpoint && selected != null)
                    ? null
                    : () => setState(
                        () => answers[q['id'] as String] = o['id'] as String,
                      ),
                child: Text('${o['id']}. ${o['text']}'),
              ),
            ),
          if (!checkpoint && selected != null)
            _Explanation(question: q, package: widget.package),
          if (checkpoint)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Answers and explanations appear after you submit the whole checkpoint.',
              ),
            ),
          if (error != null) _ErrorBox(error!, busy ? null : _submit),
          const SizedBox(height: 20),
          if (busy) const LinearProgressIndicator(),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (index > 0)
                TextButton(
                  onPressed: busy || submitted
                      ? null
                      : () => setState(() => index--),
                  child: const Text('Previous'),
                ),
              FilledButton(
                onPressed: selected == null || busy || submitted
                    ? null
                    : () {
                        if (index + 1 < widget.questions.length) {
                          setState(() => index++);
                        } else {
                          _submit();
                        }
                      },
                child: Text(
                  index + 1 == widget.questions.length
                      ? 'Submit and save'
                      : 'Next question',
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Explanation extends StatelessWidget {
  const _Explanation({required this.question, required this.package});
  final Map<String, dynamic> question, package;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Correct answer: ${question['correctOptionId']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(question['rationale'] as String? ?? ''),
        for (final e
            in (question['distractorRationales'] as Map? ?? {}).entries)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('${e.key}: ${e.value}'),
          ),
        _Sources(package: package, ids: question['sourceIds']),
      ],
    ),
  );
}

class _Sources extends StatelessWidget {
  const _Sources({required this.package, required this.ids});
  final Map<String, dynamic> package;
  final dynamic ids;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    children: [
      for (final s in _sources(
        package['sources'],
      ).where((s) => (ids as List? ?? []).contains(s['id'])))
        TextButton(
          onPressed: () async {
            final uri = Uri.tryParse(s['url'] as String? ?? '');
            if (uri == null || !['https', 'http'].contains(uri.scheme)) return;
            try {
              if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                return;
              }
            } catch (_) {}
            if (context.mounted) {
              showDialog<void>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Reference address'),
                  content: Text(uri.toString()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            }
          },
          child: Text(s['title'] as String? ?? s['id'] as String),
        ),
    ],
  );
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Text(
      text,
      style: const TextStyle(
        fontFamily: 'Fraunces',
        fontSize: 26,
        color: _navy,
      ),
    ),
  );
}

class _Notice extends StatelessWidget {
  const _Notice(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(20), child: Text(text)),
  );
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox(this.text, this.retry);
  final String text;
  final VoidCallback? retry;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(text, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      TextButton(onPressed: retry, child: const Text('Retry')),
    ],
  );
}

class _Frame extends StatelessWidget {
  const _Frame({required this.title, required this.children, this.actions});
  final String title;
  final List<Widget> children;
  final List<Widget>? actions;
  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(
      cardTheme: const CardThemeData(color: Color(0xFFFBF9F5)),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(44, 48),
          backgroundColor: _navy,
          foregroundColor: _cream,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(44, 48),
          foregroundColor: _navy,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(44, 48),
          foregroundColor: _navy,
        ),
      ),
    ),
    child: Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: _cream,
        actions: actions,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: children,
          ),
        ),
      ),
    ),
  );
}
