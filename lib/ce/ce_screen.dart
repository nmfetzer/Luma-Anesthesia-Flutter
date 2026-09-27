import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/luma_theme.dart';
import 'ce_repository.dart';
import 'ce_certificate_screen.dart';
import 'ce_participation_dates.dart';
import 'ce_purchase_screen.dart';

const ceNavy = Color(0xFF102A3A);
const ceGold = Color(0xFFE1BD7F);

class CeCourseScreen extends StatefulWidget {
  const CeCourseScreen({
    super.key,
    this.repository,
    this.initialSection = 'catalog',
  });
  final CeRepository? repository;
  final String initialSection;
  @override
  State<CeCourseScreen> createState() => _CeCourseScreenState();
}

class _CeCourseScreenState extends State<CeCourseScreen> {
  late final CeRepository repo = widget.repository ?? SupabaseCeRepository();
  Map<String, dynamic>? catalog;
  Map<String, dynamic> status = {};
  late String view = widget.initialSection;
  String? error;
  bool busy = false;
  Map<String, dynamic>? attempt, result;
  Map<String, String> answers = {};
  Map<String, dynamic> hints = {};
  int questionIndex = 0;
  final fullName = TextEditingController();
  final credentials = TextEditingController();
  final aanaId = TextEditingController();
  final location = TextEditingController();
  final participationStart = TextEditingController();
  final participationEnd = TextEditingController();
  final learned = TextEditingController();
  final barriers = TextEditingController();
  final signature = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final evalKey = GlobalKey<FormState>();
  List<int?> ratings = List<int?>.filled(11, null);
  late String selectedModuleId = 'course_${repo.courseNumber}_module_1';
  bool attestation = false;
  final scroll = ScrollController();
  StreamSubscription<String?>? accountSubscription;

  List<Map<String, dynamic>> get availableModules =>
      ((catalog!['modules'] as List?) ?? [catalog!['module']])
          .map((m) => Map<String, dynamic>.from(m as Map))
          .toList();
  Map<String, dynamic> get module =>
      availableModules.firstWhere((m) => m['id'] == selectedModuleId);
  int get objectiveCount => (module['objectives'] as List).length;
  int get ratingCount =>
      objectiveCount + (module['evaluation_items'] as List).length;
  String get moduleTitle => module['title'] as String;
  Future<Map<String, dynamic>> call(
    String action, [
    Map<String, dynamic> payload = const {},
  ]) => repo.call(action, {...payload, 'module_id': selectedModuleId});

  Future<void> selectModule(String id) async {
    selectedModuleId = id;
    attempt = null;
    result = null;
    answers = {};
    hints = {};
    questionIndex = 0;
    ratings = List<int?>.filled(ratingCount, null);
    learned.clear();
    barriers.clear();
    signature.clear();
    attestation = false;
    await refresh();
    go('modules');
  }

  bool get preview => repo.isDemo || status['is_preview'] == true;

  Future<void> openCertificate() async {
    final edit = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CeCertificateScreen(repository: repo)),
    );
    if (!mounted) return;
    if (edit == true) {
      await run(refresh);
      if (mounted) go('details');
    }
  }

  @override
  void initState() {
    super.initState();
    run(() async {
      catalog = await call('catalog');
      await refresh();
      if (status['has_access'] != true) view = 'catalog';
    });
    var previousAccount = repo.accountId;
    accountSubscription = repo.accountChanges.listen((account) {
      if (account == previousAccount) return;
      previousAccount = account;
      if (!mounted) return;
      setState(() {
        status = {};
        attempt = null;
        result = null;
        answers = {};
        hints = {};
        ratings = List<int?>.filled(catalog == null ? 11 : ratingCount, null);
        attestation = false;
        for (final controller in [
          fullName,
          credentials,
          aanaId,
          location,
          participationStart,
          participationEnd,
          learned,
          barriers,
          signature,
        ]) {
          controller.clear();
        }
        view = 'catalog';
      });
      run(refresh);
    });
  }

  @override
  void dispose() {
    accountSubscription?.cancel();
    for (final c in [
      fullName,
      credentials,
      aanaId,
      location,
      participationStart,
      participationEnd,
      learned,
      barriers,
      signature,
    ]) {
      c.dispose();
    }
    scroll.dispose();
    super.dispose();
  }

  Future<void> refresh() async {
    final account = repo.accountId;
    final response = repo.signedIn ? await call('access') : <String, dynamic>{};
    if (!mounted || account != repo.accountId) return;
    status = response;
    final p = Map<String, dynamic>.from(status['profile'] as Map? ?? {});
    fullName.text = p['full_name'] as String? ?? '';
    credentials.text = p['credentials'] as String? ?? '';
    aanaId.text = p['aana_id'] as String? ?? '';
    location.text = p['location'] as String? ?? '';
    participationStart.text = p['participation_start_on'] as String? ?? '';
    participationEnd.text = p['participation_end_on'] as String? ?? '';
  }

  Future<void> run(Future<void> Function() action) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) {
        error = e.toString().replaceFirst('Exception: ', '');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void go(String next) {
    setState(() {
      view = next;
      error = null;
    });
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  Widget title(String text, {double size = 28}) => Text(
    text,
    style: lumaDisplay(size: size, color: ceNavy),
  );
  Widget copy(String text) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Text(text, style: lumaBody(size: 14, height: 1.55)),
  );
  Widget label(String text) => Text(
    text,
    style: lumaBody(
      size: 11,
      weight: FontWeight.w700,
      color: const Color(0xFF76603C),
    ),
  );
  Widget panel(List<Widget> children, {Color? color}) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: color ?? Colors.white,
      border: Border.all(color: LumaColors.divider),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
  Widget button(String text, VoidCallback? action, {bool secondary = false}) =>
      Padding(
        padding: const EdgeInsets.only(top: 16),
        child: SizedBox(
          width: double.infinity,
          child: secondary
              ? OutlinedButton(
                  onPressed: busy ? null : action,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(18),
                  ),
                  child: Text(text, textAlign: TextAlign.center),
                )
              : FilledButton(
                  onPressed: busy ? null : action,
                  style: FilledButton.styleFrom(
                    backgroundColor: ceNavy,
                    padding: const EdgeInsets.all(18),
                  ),
                  child: Text(text, textAlign: TextAlign.center),
                ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: view == 'catalog'
            ? null
            : IconButton(
                tooltip: 'Back to course',
                icon: const Icon(Icons.arrow_back),
                onPressed: busy ? null : () => go('catalog'),
              ),
        title: const Text('CE HALO'),
        actions: [
          IconButton(
            tooltip: 'Contact CE HALO',
            onPressed: () => launchUrl(Uri.parse('mailto:info@cehalo.com')),
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (repo.isDemo)
              Container(
                width: double.infinity,
                color: ceNavy,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: const Text(
                  'DESIGN PREVIEW  •  No payment or CE credit is recorded',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            if (busy) const LinearProgressIndicator(minHeight: 3),
            Expanded(
              child: catalog == null
                  ? Center(
                      child: error == null
                          ? const CircularProgressIndicator()
                          : Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(error!),
                                  button(
                                    'Try again',
                                    () => run(() async {
                                      catalog = await call('catalog');
                                      await refresh();
                                    }),
                                  ),
                                ],
                              ),
                            ),
                    )
                  : SingleChildScrollView(
                      controller: scroll,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: view == 'catalog' ? 1040 : 760,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (error != null)
                                panel([
                                  const Text(
                                    'Unable to continue',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  copy(error!),
                                ], color: const Color(0xFFFFEDE8)),
                              ...switch (view) {
                                'details' => details(),
                                'modules' => modules(),
                                'quiz' => quiz(),
                                'result' => results(),
                                'evaluation' => evaluation(),
                                'complete' => completion(),
                                _ => course(),
                              },
                              const SizedBox(height: 20),
                              const Center(
                                child: Text(
                                  'CE HALO LLC  •  info@cehalo.com',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: LumaColors.inkMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Map moduleStatus(String id) =>
      (status['module_statuses'] as Map?)?[id] as Map? ?? {};
  int get completedCount => availableModules
      .where((m) => moduleStatus(m['id'] as String)['completed'] == true)
      .length;
  Map<String, dynamic> get nextModule => availableModules.firstWhere(
    (m) => moduleStatus(m['id'] as String)['completed'] != true,
    orElse: () => availableModules.first,
  );

  void openModule(String id) {
    if (status['has_access'] != true) return;
    run(() async {
      await selectModule(id);
      if (mounted && fullName.text.isEmpty) go('details');
    });
  }

  void openPurchases() => run(() async {
    await Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => const CePurchaseScreen()));
    await refresh();
  });

  Widget moduleList() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      title('Course modules', size: 23),
      copy('Content → Quiz → Evaluation'),
      const SizedBox(height: 18),
      for (final m in availableModules)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: LumaColors.divider),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              key: ValueKey('ce-module-${m['id']}'),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: moduleStatus(m['id'])['completed'] == true
                    ? ceNavy
                    : LumaColors.cream,
                child: moduleStatus(m['id'])['completed'] == true
                    ? const Icon(Icons.check, color: Colors.white, size: 19)
                    : Text(
                        '${m['number']}'.padLeft(2, '0'),
                        style: const TextStyle(color: ceNavy, fontSize: 13),
                      ),
              ),
              title: Text(
                m['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  moduleStatus(m['id'])['completed'] == true
                      ? 'Content, quiz, and evaluation complete'
                      : moduleStatus(m['id'])['passed'] == true
                      ? 'Next: module evaluation'
                      : moduleStatus(m['id'])['read'] == true
                      ? 'Next: knowledge assessment'
                      : '${m['credits']} MAC Ed CE credits',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              trailing: Icon(
                status['has_access'] == true
                    ? Icons.chevron_right
                    : Icons.lock_outline,
                size: 20,
              ),
              onTap: busy || status['has_access'] != true
                  ? null
                  : () => openModule(m['id'] as String),
            ),
          ),
        ),
    ],
  );

  Widget courseProgress() => panel([
    label(preview ? 'CREATOR PREVIEW' : 'YOUR PROGRESS'),
    copy('$completedCount of ${repo.moduleCount} modules complete'),
    const SizedBox(height: 16),
    LinearProgressIndicator(
      value: completedCount / repo.moduleCount,
      color: ceNavy,
      backgroundColor: LumaColors.cream,
    ),
    if (status['has_access'] == true) ...[
      button(
        fullName.text.isEmpty
            ? 'Complete course registration'
            : completedCount == repo.moduleCount
            ? 'Review course modules'
            : 'Continue module ${nextModule['number']}',
        () => openModule(nextModule['id'] as String),
      ),
      if (preview)
        copy(
          'Creator access is unlocked. Preview activity does not award CE credits.',
        ),
      button('Course certificate', openCertificate, secondary: true),
      TextButton(
        onPressed: busy ? null : () => go('details'),
        child: const Text('Edit course registration'),
      ),
    ] else if (repo.isDemo)
      button(
        'Preview the post-purchase experience',
        () => run(() async {
          await call('demo_unlock');
          await refresh();
          go('details');
        }),
      )
    else ...[
      copy(
        'Course purchase is not yet available. Existing access is checked through your account.',
      ),
      button('View CE purchase options', openPurchases),
      if (!repo.signedIn)
        button(
          'Sign in to check course access',
          () => run(() async {
            await Navigator.of(context).pushNamed('/account');
            await refresh();
          }),
          secondary: true,
        ),
    ],
  ]);

  List<Widget> course() => [
    if (Navigator.of(context).canPop())
      TextButton.icon(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back, size: 16),
        label: const Text('All courses'),
      ),
    const SizedBox(height: 18),
    label('COURSE ${repo.courseNumber.toString().padLeft(2, '0')}'),
    const SizedBox(height: 14),
    title(repo.courseTitle, size: 32),
    copy(
      '20.00 MAC Ed CE credits · ${repo.moduleCount} modules · Course ID ${repo.courseId}',
    ),
    const SizedBox(height: 28),
    LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 820) {
          return Column(children: [courseProgress(), moduleList()]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: moduleList()),
            const SizedBox(width: 28),
            SizedBox(width: 310, child: courseProgress()),
          ],
        );
      },
    ),
    const SizedBox(height: 24),
    ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 8),
      title: const Text('Purchase & Luma access details'),
      childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 20),
      children: [
        if (!repo.isDemo)
          button('CE purchases & restore', openPurchases, secondary: true),
        copy(
          'CE courses are purchased separately. A Luma clinical subscription does not unlock this course.',
        ),
        copy(
          repo.courseNumber == 1
              ? 'Planned U.S. price: \$249.99. Includes one month of complimentary Luma Anesthesia clinical access, once per account. Final local pricing will come from Apple or Google at checkout.'
              : 'Course pricing and store checkout are pending launch configuration. No purchase is available in this preview.',
        ),
        if (repo.courseNumber == 1)
          copy(
            'Maximum three complimentary calendar months per account across stores. The bundle includes three months total, or two additional months if you already received the course month. The two months follow any remaining CE bonus access; otherwise they start on the original verified bundle purchase date. Additional course purchases and restores add no months. Refunds do not reset eligibility. Existing paid subscription billing is unchanged. No automatic subscription enrollment.',
          ),
      ],
    ),
    ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 8),
      title: const Text('AANA approval & course information'),
      childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 20),
      children: [
        copy(catalog!['approval_statement'] as String),
        if (repo.hasDesignatedCredits)
          copy(catalog!['pharmacology_statement'] as String),
        if (repo.hasDesignatedCredits)
          copy(catalog!['pain_statement'] as String),
        copy(
          'The 20.00-credit approval applies to the complete program, not an individual module. Use Course certificate to review requirements and retrieve your certificate when eligible. Creator previews do not award credit.',
        ),
      ],
    ),
  ];

  Widget stat(String value, String text) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(value, style: lumaDisplay(size: 26)),
      const SizedBox(height: 5),
      Text(text, style: const TextStyle(fontSize: 11, height: 1.4)),
    ],
  );
  String? requiredText(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;
  Widget field(
    String text,
    TextEditingController controller, {
    bool required = true,
    int lines = 1,
    String? hint,
    int maxLength = 150,
  }) => Padding(
    padding: const EdgeInsets.only(top: 18),
    child: TextFormField(
      controller: controller,
      maxLines: lines,
      maxLength: maxLength,
      textCapitalization: TextCapitalization.sentences,
      validator: required ? requiredText : null,
      decoration: InputDecoration(
        labelText: text,
        helperText: hint,
        helperMaxLines: 3,
        border: const OutlineInputBorder(),
        counterText: '',
      ),
    ),
  );

  List<Widget> details() => [
    label('BEFORE YOU BEGIN'),
    const SizedBox(height: 12),
    title('Your course registration'),
    copy(
      'Complete this form once after purchasing the course. Quizzes, evaluations and completion records stay linked to your signed-in account. These details are saved for your future certificate; enter your name exactly as it should appear.',
    ),
    const SizedBox(height: 20),
    panel([
      Form(
        key: formKey,
        child: Column(
          children: [
            field('Full name', fullName),
            field(
              'Credentials',
              credentials,
              hint: 'For example: DNP, CRNA',
              maxLength: 100,
            ),
            field('AANA ID (optional)', aanaId, required: false, maxLength: 60),
            field(
              'Location of completion',
              location,
              maxLength: 300,
              hint: 'City, state/province, country; venue optional. Saved with course registration. Use Edit course registration if it changes.',
            ),
            copy(
              'Location is saved for your own documentation. It does not establish tax deductibility, business-travel eligibility, or employer reimbursement.',
            ),
            field(
              'Participation start date',
              participationStart,
              required: false,
              maxLength: 10,
              hint: 'YYYY-MM-DD',
            ),
            field(
              'Participation end date',
              participationEnd,
              required: false,
              maxLength: 10,
              hint: 'YYYY-MM-DD',
            ),
            copy(
              'Enter your actual participation dates for the certificate. You may leave both blank when registering and add them through Edit course registration before requesting your certificate. The app records course completion separately.',
            ),
            button('Save details & view modules', () {
              if (!formKey.currentState!.validate()) return;
              final dateError = validateCeParticipationDates(
                participationStart.text.trim(),
                participationEnd.text.trim(),
                preview: preview,
              );
              if (dateError != null) {
                setState(() => error = dateError);
                if (scroll.hasClients) scroll.jumpTo(0);
                return;
              }
              run(() async {
                await call('profile', {
                  'full_name': fullName.text.trim(),
                  'credentials': credentials.text.trim(),
                  'aana_id': aanaId.text.trim(),
                  'location': location.text.trim(),
                  'participation_start_on': participationStart.text.trim(),
                  'participation_end_on': participationEnd.text.trim(),
                });
                await refresh();
                go('modules');
              });
            }),
          ],
        ),
      ),
    ]),
  ];

  List<Widget> modules() => [
    TextButton.icon(
      onPressed: busy ? null : () => go('catalog'),
      icon: const Icon(Icons.arrow_back, size: 16),
      label: const Text('All course modules'),
    ),
    const SizedBox(height: 16),
    panel([
      label(
        'MODULE ${module['number'] ?? 1}  •  ${module['credits']} MAC Ed CE CREDITS',
      ),
      const SizedBox(height: 12),
      title(moduleTitle),
      if (repo.hasDesignatedCredits)
        copy(
          '${module['pharmacology_credits']} Pharmacology & Therapeutics  •  ${module['pain_credits']} Pain Management',
        ),
      const SizedBox(height: 18),
      stageRow(
        '01',
        'Learner content',
        '${module['page_count'] ?? 17}-page module with references',
        status['read'] == true,
      ),
      stageRow(
        '02',
        'Knowledge assessment',
        '15 questions  •  80% to pass  •  3 attempts',
        status['passed'] == true,
      ),
      stageRow(
        '03',
        'Module evaluation',
        'Learning outcomes & feedback, linked to your account',
        status['completed'] == true,
      ),
      button(
        'Read learner content',
        () => run(() async {
          final document = await call('document');
          final bytes = base64Decode(document['base64'] as String);
          if (!mounted) return;
          final reviewed = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => CePdfScreen(bytes: bytes, title: moduleTitle),
            ),
          );
          if (reviewed == true) {
            await call('read');
            await refresh();
          }
        }),
      ),
      if (status['completed'] == true)
        button('View module completion', () => go('complete'), secondary: true)
      else if (status['passed'] == true)
        button('Complete evaluation', () => go('evaluation'))
      else if (status['read'] == true)
        button(
          'Start or resume assessment',
          () => run(() async {
            attempt = await call('quiz');
            answers = Map<String, String>.from(
              attempt!['answers'] as Map? ?? {},
            );
            hints = Map<String, dynamic>.from(attempt!['hints'] as Map? ?? {});
            questionIndex = 0;
            go('quiz');
          }),
        ),
      if ((status['attempts_used'] as num? ?? 0) >= 3 &&
          status['passed'] != true)
        copy(
          'If all three attempts are submitted without passing, contact info@cehalo.com for assistance.',
        ),
      Material(
        color: Colors.transparent,
        child: ExpansionTile(
          title: const Text('Learning objectives'),
          children: [
            for (final objective in module['objectives'] as List)
              copy(objective as String),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ]),
    if (availableModules.length < repo.moduleCount)
      panel([
        label(
          'REMAINING ${repo.moduleCount - availableModules.length} MODULES',
        ),
        const SizedBox(height: 10),
        title('More modules to come', size: 22),
        copy(
          'The remaining approved course content will appear here as each revised module is loaded. No unfinished module is represented as available.',
        ),
      ], color: LumaColors.creamElevated),
    button('All course modules', () => go('catalog'), secondary: true),
  ];

  Widget stageRow(String number, String heading, String detail, bool done) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: done ? ceNavy : LumaColors.cream,
              child: done
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      number,
                      style: const TextStyle(fontSize: 12, color: ceNavy),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    heading,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: const TextStyle(fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  List<Widget> quiz() {
    final questions = attempt!['questions'] as List;
    final q = Map<String, dynamic>.from(questions[questionIndex] as Map);
    final id = q['question_id'] as String;
    final eliminated = (hints[id] as List?) ?? [];
    return [
      label(
        '${module['short_title'] ?? moduleTitle}  /  ATTEMPT ${attempt!['number']} OF 3',
      ),
      const SizedBox(height: 12),
      title('Knowledge assessment'),
      copy(
        'Question ${questionIndex + 1} of 15  •  ${answers.length} answered',
      ),
      const SizedBox(height: 16),
      LinearProgressIndicator(
        value: (questionIndex + 1) / 15,
        color: ceNavy,
        backgroundColor: LumaColors.divider,
      ),
      const SizedBox(height: 22),
      panel([
        Text(
          q['stem'] as String,
          style: lumaBody(size: 18, weight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        button(
          eliminated.isEmpty
              ? 'Use hint: eliminate 2 wrong answers'
              : 'Hint used: two incorrect choices removed',
          eliminated.isEmpty
              ? () => run(() async {
                  final hint = await call('hint', {
                    'attempt_id': attempt!['attempt_id'],
                    'question_id': id,
                  });
                  hints[id] = hint['eliminated'];
                  answers = Map<String, String>.from(hint['answers'] as Map);
                })
              : null,
          secondary: true,
        ),
        const SizedBox(height: 16),
        for (final choice in [
          'a',
          'b',
          'c',
          'd',
        ].where((c) => !eliminated.contains(c)))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Semantics(
              selected: answers[id] == choice,
              button: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: busy
                    ? null
                    : () => run(() async {
                        final updated = {...answers, id: choice};
                        await call('save_answers', {
                          'attempt_id': attempt!['attempt_id'],
                          'answers': updated,
                        });
                        answers = updated;
                      }),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: answers[id] == choice
                        ? const Color(0xFFEAF0F2)
                        : Colors.white,
                    border: Border.all(
                      color: answers[id] == choice
                          ? ceNavy
                          : LumaColors.divider,
                      width: answers[id] == choice ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        choice.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          q['choice_$choice'] as String,
                          style: const TextStyle(height: 1.5),
                        ),
                      ),
                      if (answers[id] == choice)
                        const Icon(Icons.check_circle, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: button(
                'Previous',
                questionIndex == 0
                    ? null
                    : () => setState(() => questionIndex--),
                secondary: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: button(
                'Next',
                questionIndex == 14
                    ? null
                    : () => setState(() => questionIndex++),
              ),
            ),
          ],
        ),
        if (questionIndex == 14)
          button(
            'Submit all 15 answers',
            answers.length == 15
                ? () => run(() async {
                    result = await call('submit', {
                      'attempt_id': attempt!['attempt_id'],
                      'answers': answers,
                    });
                    await refresh();
                    go('result');
                  })
                : null,
          ),
        copy(
          'Selections are saved as you go. Answers are graded on the server; 12 correct answers are required to pass.',
        ),
      ]),
    ];
  }

  List<Widget> results() {
    final passed = result!['passed'] == true;
    return [
      label('ASSESSMENT RESULT'),
      const SizedBox(height: 12),
      title(passed ? 'Assessment passed.' : 'Review, then try again.'),
      const SizedBox(height: 22),
      panel([
        Text('${result!['score']} / 15', style: lumaDisplay(size: 48)),
        copy(
          passed ? 'Your next step is the module evaluation.' : 'The passing score is 12 of 15 (80%). Review the learner content before another attempt.',
        ),
        copy(
          'Attempt ${attempt!['number']} of 3. Correct answers are not displayed between attempts.',
        ),
        button(
          passed ? 'Continue to evaluation' : 'Return to module',
          () => go(passed ? 'evaluation' : 'modules'),
        ),
      ]),
    ];
  }

  List<Widget> evaluation() => [
    label('${module['short_title'] ?? moduleTitle}  /  FINAL STEP'),
    const SizedBox(height: 12),
    title('Reflect on your learning.'),
    copy(
      module['rating_scale_description'] as String? ?? 'Rate each item from 1 (strongly disagree / not achieved) to 5 (strongly agree / fully achieved). All ratings and written responses are required.',
    ),
    const SizedBox(height: 20),
    Form(
      key: evalKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          panel([
            title('Learning objectives', size: 22),
            for (int i = 0; i < objectiveCount; i++)
              rating(i, (module['objectives'] as List)[i] as String),
          ]),
          panel([
            title('Program evaluation', size: 22),
            for (
              int i = 0;
              i < (module['evaluation_items'] as List).length;
              i++
            )
              rating(
                i + objectiveCount,
                (module['evaluation_items'] as List)[i] as String,
              ),
            field(
              'One item learned that will improve your practice',
              learned,
              lines: 3,
              maxLength: 4000,
            ),
            field(
              'Barriers to implementing this change',
              barriers,
              lines: 3,
              maxLength: 4000,
              hint: 'If none, enter “None.”',
            ),
          ]),
          panel([
            title('Confirm your completion', size: 22),
            copy(
              'Saved to your account using your course registration. You do not need to enter your name, credentials, AANA ID or location again. Your completion date is recorded automatically.',
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: attestation,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: busy ? null : (v) => setState(() => attestation = v!),
              title: const Text(
                'I reviewed the content in full and completed the post-test. These responses reflect my own participation and assessment.',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
            ),
            button('Submit evaluation & complete module', () {
              if (!evalKey.currentState!.validate()) return;
              if (ratings.contains(null) || !attestation) {
                setState(
                  () => error =
                      'Select all $ratingCount ratings and check the acknowledgment.',
                );
                if (scroll.hasClients) scroll.jumpTo(0);
                return;
              }
              run(() async {
                await call('evaluate', {
                  'ratings': ratings,
                  'learned': learned.text.trim(),
                  'barriers': barriers.text.trim(),
                  'attestation': attestation,
                });
                await refresh();
                go('complete');
              });
            }),
          ]),
        ],
      ),
    ),
  ];

  Widget rating(int index, String text) => Padding(
    padding: const EdgeInsets.only(top: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: const TextStyle(fontSize: 13, height: 1.5)),
        const SizedBox(height: 10),
        Row(
          children: [
            for (int value = 1; value <= 5; value++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: value == 5 ? 0 : 6),
                  child: Semantics(
                    label: 'Rating ${index + 1}: $value of 5',
                    selected: ratings[index] == value,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 46),
                        padding: EdgeInsets.zero,
                        backgroundColor: ratings[index] == value
                            ? ceNavy
                            : null,
                        foregroundColor: ratings[index] == value
                            ? Colors.white
                            : ceNavy,
                      ),
                      onPressed: busy
                          ? null
                          : () => setState(() => ratings[index] = value),
                      child: Text('$value'),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
  );

  List<Widget> completion() {
    final record = Map<String, dynamic>.from(
      status['completion'] as Map? ?? {},
    );
    final learner = Map<String, dynamic>.from(record['learner'] as Map? ?? {});
    return [
      label(preview ? 'PREVIEW COMPLETE' : 'MODULE COMPLETE'),
      const SizedBox(height: 12),
      title('A meaningful step forward.'),
      const SizedBox(height: 20),
      panel([
        const Icon(Icons.check_circle_outline, size: 42, color: ceNavy),
        const SizedBox(height: 16),
        title(moduleTitle, size: 24),
        copy(
          preview
              ? 'You completed the preview flow. No CE credit has been earned or reported.'
              : 'Module requirements are complete: learner content, assessment and evaluation.',
        ),
        copy(
          '${learner['full_name'] ?? fullName.text}, ${learner['credentials'] ?? credentials.text}',
        ),
        if ((learner['aana_id'] as String? ?? '').isNotEmpty)
          copy('AANA ID: ${learner['aana_id']}'),
        copy('Completion location: ${record['location'] ?? location.text}'),
        if (record['completed_at'] != null)
          copy('Recorded: ${record['completed_at']}'),
        copy(
          repo.hasDesignatedCredits
              ? 'Module allocation: ${module['credits']} CE credits (${module['pharmacology_credits']} Pharmacology & Therapeutics; ${module['pain_credits']} Pain Management). This is not the full 20.00-credit program.'
              : 'Module allocation: ${module['credits']} CE credits. This is not the full 20.00-credit program.',
        ),
        copy(
          'Your full-program certificate requires all ${repo.moduleCount} modules. Creator previews do not earn credit; AANA submission is handled separately by the provider.',
        ),
        button('Course certificate', openCertificate, secondary: true),
        button('Return to modules', () => go('catalog')),
      ]),
    ];
  }
}

class CePdfScreen extends StatelessWidget {
  const CePdfScreen({super.key, required this.bytes, this.title = 'Ketamine'});
  final Uint8List bytes;
  final String title;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('$title • Learner content')),
    body: Column(
      children: [
        Expanded(
          child: PdfViewer.data(bytes, sourceName: '$title learner content'),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    'I have reviewed the complete module',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
