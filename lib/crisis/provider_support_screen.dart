import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/luma_theme.dart';
import '../widgets/clinical_source_link.dart';
import '../widgets/luma_home_button.dart';
import 'crisis_reference_sections.dart';

/// Bundled public resources, independent of auth, subscriptions and Supabase.
/// This screen does not collect personal health information.
class ProviderSupportScreen extends StatefulWidget {
  const ProviderSupportScreen({super.key, this.loadContent});
  final Future<Map<String, dynamic>> Function()? loadContent;
  @override
  State<ProviderSupportScreen> createState() => _ProviderSupportScreenState();
}

class _ProviderSupportScreenState extends State<ProviderSupportScreen> {
  late final Future<Map<String, dynamic>> _data = _loadSafely();
  Future<Map<String, dynamic>> _loadSafely() async {
    try {
      if (widget.loadContent != null) return await widget.loadContent!();
      return jsonDecode(
        await rootBundle.loadString('assets/data/provider_support.json'),
      ) as Map<String, dynamic>;
    } catch (_) {
      // The scrollable may not mount FutureBuilder before loading fails.
      // Resolve safely so emergency contacts never depend on asset loading.
      return {'_loadError': true};
    }
  }

  String? _state;
  String _query = '';
  final _search = TextEditingController();
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  static const _contactUris = {
    'tel:988',
    'sms:988',
    'tel:911',
    'tel:18006545167',
    'tel:18884090141',
    'tel:18006624357',
  };
  Future<void> _contact(String target) async {
    if (!_contactUris.contains(target)) return;
    var opened = false;
    try {
      opened = await launchUrl(Uri.parse(target));
    } catch (_) {
      // Desktop browsers may not have a phone or SMS handler.
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'No phone or messaging app opened. Use the displayed number on your phone: ${target.split(':').last}'),
      ));
    }
  }

  Widget _link(String label, String url) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: ClinicalSourceLink(
          url: url,
          child: Text(label,
              style: const TextStyle(decoration: TextDecoration.underline)),
        ),
      );
  Widget _emergencyHelp() => Card(
        color: LumaColors.creamElevated,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Help right now', style: lumaDisplay(size: 24)),
            const SizedBox(height: 8),
            const Text(
                'U.S. crisis support is available 24/7. For immediate danger, overdose, or serious injury, call 911. Luma does not monitor this screen or dispatch help.'),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              FilledButton(
                  onPressed: () => _contact('tel:988'),
                  child: const Text('Call 988')),
              OutlinedButton(
                  onPressed: () => _contact('sms:988'),
                  child: const Text('Text 988')),
              OutlinedButton(
                  onPressed: () => _contact('tel:911'),
                  child: const Text('Call 911')),
            ]),
            _link('988 chat and crisis support', 'https://988lifeline.org/'),
          ]),
        ),
      );
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: const Text('Provider support'),
            actions: const [LumaHomeButton()]),
        body: SafeArea(
            child: Center(
                child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: ListView(padding: const EdgeInsets.all(20), children: [
            Text('Mental Health & Recovery Support',
                style: lumaDisplay(size: 28)),
            const SizedBox(height: 8),
            const Text(
                'For the whole anesthesia team: MD/DO physicians, CRNAs, CAAs, residents, fellows, students, technicians, and other anesthesia professionals.'),
            const SizedBox(height: 8),
            const Text('Always free. Free access, no account required.',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _emergencyHelp(),
            const SizedBox(height: 16),
            Text('Professional support contacts', style: lumaDisplay(size: 23)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              OutlinedButton(
                  onPressed: () => _contact('tel:18884090141'),
                  child: const Text('Physician Support · 888-409-0141')),
              OutlinedButton(
                  onPressed: () => _contact('tel:18006545167'),
                  child: const Text('AANA · 800-654-5167')),
              OutlinedButton(
                  onPressed: () => _contact('tel:18006624357'),
                  child: const Text('SAMHSA · 800-662-4357')),
            ]),
            const Text(
                'Physician Support Line: physicians and medical students, Mon–Fri 8 a.m.–11 p.m. Eastern, except federal holidays.\n\nAANA: substance-use concerns involving CRNAs and nurse anesthesia residents, 24/7.\n\nSAMHSA: treatment referral for anyone, not counseling, 24/7. Individual services have eligibility rules; this app section is open to everyone.'),
            _link('AANA help resources',
                'https://www.aana.com/membership/here-for-you/health-and-wellness/where-to-get-help/'),
            _link('Physician Support Line eligibility and hours',
                'https://www.physiciansupportline.com/'),
            _link('SAMHSA National Helpline',
                'https://www.samhsa.gov/find-help/national-helpline'),
            _link('ASA well-being resources',
                'https://www.asahq.org/advocating-for-you/well-being'),
            const SizedBox(height: 20),
            FutureBuilder<Map<String, dynamic>>(
              future: _data,
              builder: (context, snapshot) {
                if (snapshot.hasError || snapshot.data?['_loadError'] == true) {
                  return const Text(
                      'The full directory could not load. The immediate-help contacts above remain available.');
                }
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final data = snapshot.data!;
                final rows = (data['states'] as List).cast<Map>();
                final facilities = (data['facilities'] as List).cast<Map>();
                final states = rows
                    .map((r) => r['state'] as String)
                    .toSet()
                    .toList()
                  ..sort();
                final selectedFacilities = facilities
                    .where((f) =>
                        (_state == null || f['state'] == _state) &&
                        '${f['state']} ${f['name']} ${f['location']} ${f['level']} ${f['eligibility']} ${f['body']} ${f['student_confirmed'] == true ? f['student_eligibility'] : ''}'
                            .toLowerCase()
                            .contains(_query.trim().toLowerCase()))
                    .toList();
                final shownStates = states.where((state) =>
                    (_state == null || state == _state) &&
                    (_query.trim().isEmpty ||
                        selectedFacilities.any((f) => f['state'] == state)));
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Treatment programs by state',
                          style: lumaDisplay(size: 24)),
                      const SizedBox(height: 8),
                      const Text(
                          'Find addiction treatment for healthcare professionals, organized by treatment location. Virtual programs are labeled separately. Free to browse; external treatment may have fees.'),
                      const SizedBox(height: 8),
                      Text(
                          '${facilities.length} verified public program listings. All 50 states and D.C. are included for navigation; states without verified listings are clearly marked. This is not a complete census or an endorsement.'),
                      const SizedBox(height: 12),
                      TextField(
                        key: const ValueKey('support-search'),
                        controller: _search,
                        decoration: InputDecoration(
                          labelText:
                              'Search programs, professions, or locations',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Clear search',
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _search.clear();
                                    setState(() => _query = '');
                                  },
                                ),
                        ),
                        onChanged: (value) => setState(() => _query = value),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        key: const ValueKey('support-state'),
                        isExpanded: true,
                        value: _state,
                        decoration: const InputDecoration(
                            labelText: 'Choose your state',
                            border: OutlineInputBorder()),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('All states and D.C.')),
                          for (final state in states)
                            DropdownMenuItem(value: state, child: Text(state)),
                        ],
                        onChanged: (value) => setState(() => _state = value),
                      ),
                      if (_state != null) ...[
                        TextButton(
                            onPressed: () => setState(() => _state = null),
                            child: const Text('Clear state filter')),
                      ],
                      const SizedBox(height: 12),
                      if (shownStates.isEmpty)
                        const Text(
                            'No matching verified listings. Try another term, clear the state filter, or use the national treatment search below.'),
                      for (final state in shownStates)
                        if (_state != null)
                          _statePrograms(state, selectedFacilities)
                        else
                          Card(
                              child: ExpansionTile(
                            key: ValueKey('programs-$state-${_query.trim()}'),
                            initiallyExpanded: _query.trim().isNotEmpty,
                            title: Text(state,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            subtitle: Text(selectedFacilities
                                    .any((f) => f['state'] == state)
                                ? '${selectedFacilities.where((f) => f['state'] == state).length} program listing(s)'
                                : 'No verified program listed yet'),
                            children: [
                              _statePrograms(state, selectedFacilities)
                            ],
                          )),
                      _link('Search SAMHSA’s national treatment directory',
                          'https://findtreatment.gov/'),
                      const SizedBox(height: 24),
                      Text('State assistance and referral programs',
                          style: lumaDisplay(size: 24)),
                      const SizedBox(height: 8),
                      const Text(
                          'These are not rehab facilities. They may provide referrals, professional support, evaluation, or monitoring. Eligibility and reporting rules vary by profession and state.'),
                      if (_state == null)
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                                'Select a state above to see its assistance-program contact. Physicians, nurses, CAAs, students, and other professionals should confirm eligibility rather than assume every program accepts their role.')),
                      if (_state != null)
                        for (final row
                            in rows.where((r) => r['state'] == _state))
                          Card(
                              child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text('${row['name']}',
                                          style: lumaBody(
                                              size: 18,
                                              weight: FontWeight.w700)),
                                      if ('${row['phone']}'.isNotEmpty)
                                        SelectableText('${row['phone']}'),
                                      const SizedBox(height: 8),
                                      Text('${row['note']}'),
                                      _link(
                                          'Verified listing and contact source',
                                          '${row['source']}'),
                                    ],
                                  ))),
                      _link('FSPHP state-program directory',
                          'https://www.fsphp.org/state-programs'),
                      const SizedBox(height: 20),
                      Text('Support beyond the directory',
                          style: lumaDisplay(size: 24)),
                      const SizedBox(height: 12),
                      CrisisReferenceSections(
                          sections: (data['sections'] as List).cast<Map>()),
                      const SizedBox(height: 20),
                      Text(
                          'Public sources checked ${data['checked']}. Phone connections, availability, coverage, and eligibility have not been confirmed by calling.'),
                    ]);
              },
            ),
          ]),
        ))),
      );

  Widget _statePrograms(String state, List<Map> facilities) {
    final matches = facilities.where((f) => f['state'] == state).toList();
    if (matches.isEmpty) {
      return Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
              'No matching healthcare-professional treatment program is verified in this directory for $state. This does not mean no care exists. Use SAMHSA or the state referral program, or explore out-of-state treatment.'));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final f in matches)
        Card(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('${f['name']} · ${f['state']}',
                        style: lumaBody(size: 18, weight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text('${f['location']}'),
                    const SizedBox(height: 8),
                    for (final point in [
                      'Care: ${f['level']}',
                      'Who the program describes serving: ${f['eligibility']}',
                      '${f['body']}',
                      'Students and trainees: ${f['student_eligibility']}',
                    ])
                      Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text('• $point')),
                    if ('${f['phone']}'.isNotEmpty)
                      SelectableText('Contact: ${f['phone']}'),
                    for (final source in f['sources'] as List)
                      _link('${source['title']}', '${source['url']}'),
                  ],
                ))),
    ]);
  }
}
