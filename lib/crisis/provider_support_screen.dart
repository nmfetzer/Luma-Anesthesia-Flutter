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
            _link('AANA: immediate-help guidance',
                'https://www.aana.com/membership/here-for-you/health-and-wellness/where-to-get-help/'),
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
                'Care for the person behind the provider. Free access, no account required.'),
            const SizedBox(height: 16),
            _emergencyHelp(),
            const SizedBox(height: 16),
            Text('Professional support contacts', style: lumaDisplay(size: 23)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              OutlinedButton(
                  onPressed: () => _contact('tel:18006545167'),
                  child: const Text('AANA · 800-654-5167')),
              OutlinedButton(
                  onPressed: () => _contact('tel:18884090141'),
                  child: const Text('Physician Support · 888-409-0141')),
              OutlinedButton(
                  onPressed: () => _contact('tel:18006624357'),
                  child: const Text('SAMHSA · 800-662-4357')),
            ]),
            const Text(
                'AANA: drug/alcohol concerns, 24/7. Physician Support Line: physicians and medical students, Mon–Fri 8 a.m.–11 p.m. Eastern, except federal holidays. SAMHSA: treatment referral, not counseling, 24/7.'),
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
                    .where((f) => _state == null || f['state'] == _state)
                    .toList();
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Find help by state', style: lumaDisplay(size: 24)),
                      const SizedBox(height: 8),
                      const Text(
                          'Assistance programs are not rehab facilities. Confirm your profession is eligible. This directory includes all 50 states and D.C.; gaps are clearly labeled.'),
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
                              value: null, child: Text('Choose a state')),
                          for (final state in states)
                            DropdownMenuItem(value: state, child: Text(state)),
                        ],
                        onChanged: (value) => setState(() => _state = value),
                      ),
                      if (_state != null) ...[
                        TextButton(
                            onPressed: () => setState(() => _state = null),
                            child: const Text('Clear state filter')),
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
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                                'CRNA or nurse anesthesia resident? AANA: 800-654-5167, 24/7 for substance-use support and resource navigation. State PHP eligibility varies by profession.')),
                      ],
                      const SizedBox(height: 20),
                      Text('Selected professional treatment programs',
                          style: lumaDisplay(size: 24)),
                      const SizedBox(height: 8),
                      const Text(
                          'Non-ranked examples, not an endorsement or an all-state rehab directory. Confirm admissions, insurance, services, and any monitoring-program requirements directly.'),
                      if (selectedFacilities.isEmpty)
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                                'No healthcare-professional treatment facility has been verified for this state in this selection. Use the referral contacts above or clear the filter to see the selected out-of-state programs.')),
                      for (final facility in selectedFacilities)
                        Card(
                            child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                        '${facility['name']} · ${facility['state']}',
                                        style: lumaBody(
                                            size: 18, weight: FontWeight.w700)),
                                    SelectableText('${facility['phone']}'),
                                    const SizedBox(height: 8),
                                    for (final point in '${facility['body']}'
                                        .split(RegExp(r'(?<=[.!?])\s+')))
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 6),
                                        child: Text('• $point'),
                                      ),
                                    for (final source
                                        in facility['sources'] as List)
                                      _link('${source['title']}',
                                          '${source['url']}'),
                                  ],
                                ))),
                      const SizedBox(height: 20),
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
}
