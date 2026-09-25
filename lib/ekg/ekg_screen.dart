import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/luma_home_button.dart';
import 'ekg_content.dart';

class EkgScreen extends StatefulWidget {
  const EkgScreen({super.key, this.showClinicalDraft = false});
  final bool showClinicalDraft;
  @override
  State<EkgScreen> createState() => _EkgScreenState();
}

class _EkgScreenState extends State<EkgScreen> {
  String _query = '';
  String _category = 'All';

  @override
  Widget build(BuildContext context) {
    final categories = ['All', ...ekgEntries.map((e) => e.category).toSet()];
    final entries = ekgEntries.where((entry) =>
        (_category == 'All' || entry.category == _category) &&
        '${entry.title} ${entry.sections.values.join(' ')}'
            .toLowerCase().contains(_query.toLowerCase())).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('EKG Reference'),
        actions: const [LumaHomeButton()]),
      body: !widget.showClinicalDraft
        ? const Center(child: Padding(padding: EdgeInsets.all(24),
            child: Text('The EKG reference is being prepared for clinical review. '
                'It is not yet available as a clinical reference.')))
        : Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(children: [
            Container(
              width: double.infinity,
              color: const Color(0xFFFFF1D6),
              padding: const EdgeInsets.all(16),
              child: const Text('OWNER PREVIEW • CLINICAL DRAFT\n'
                  'Your specification + Base44 EKG organization. Not yet clinically '
                  'approved; do not use for patient care. Proceed/delay notes are '
                  'considerations, not individual clearance.'),
            ),
            Padding(padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Search EKG reference',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder()),
                onChanged: (value) => setState(() => _query = value))),
            SizedBox(height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: categories.map((category) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(label: Text(category),
                    selected: _category == category,
                    onSelected: (_) => setState(() => _category = category)),
                )).toList())),
            Expanded(child: entries.isEmpty
              ? const Center(child: Text('No matching EKG topics.'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return Card(child: ListTile(
                    title: Text(entry.title),
                    subtitle: Text(entry.category),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => _EkgDetail(entry: entry))),
                  ));
                })),
          ]),
        )),
    );
  }
}

class _EkgDetail extends StatelessWidget {
  const _EkgDetail({required this.entry});
  final EkgEntry entry;

  Future<void> _open(BuildContext context, String url) async {
    try {
      if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
        throw StateError('Unable to open reference');
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open reference: $url')));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(entry.title), actions: const [LumaHomeButton()]),
    body: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: ListView(padding: const EdgeInsets.all(24), children: [
        const Text('Clinical draft • not for patient care',
          style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF88420B))),
        const SizedBox(height: 20),
        for (final section in entry.sections.entries) ...[
          Text(section.key, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          SelectableText(section.value),
          const SizedBox(height: 24),
        ],
        Text('Reference reading', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text('References support the working draft; they do not represent '
          'completed clinical signoff. Source coverage must be finalized before release.'),
        for (final source in entry.sources)
          TextButton(
            onPressed: () => _open(context, source),
            child: Text(source, softWrap: true)),
      ]),
    )),
  );
}
