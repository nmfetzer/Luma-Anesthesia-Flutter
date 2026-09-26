import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../theme/luma_theme.dart';
import '../widgets/clinical_source_link.dart';

/// Stack table cells under their column headings on phones. Clinical wording,
/// units, qualifiers and inline citations are retained verbatim.
String stackReferenceTables(String markdown) {
  final lines = markdown.split('\n');
  final out = <String>[];
  List<String> cells(String line) => line
      .trim()
      .replaceFirst(RegExp(r'^\|'), '')
      .replaceFirst(RegExp(r'\|$'), '')
      .split(RegExp(r'(?<!\\)\|'))
      .map((s) => s.trim())
      .toList();
  for (var i = 0; i < lines.length; i++) {
    if (lines[i].trim().startsWith('|') &&
        i + 1 < lines.length &&
        RegExp(r'^\s*\|[\s:|\-]+\|\s*$').hasMatch(lines[i + 1])) {
      final headers = cells(lines[i]);
      i += 2;
      while (i < lines.length && lines[i].trim().startsWith('|')) {
        final row = cells(lines[i]);
        out.add('\n---\n');
        for (var j = 0; j < row.length; j++) {
          out.add(
              '**${j < headers.length ? headers[j] : 'Detail'}:** ${row[j]}\n');
        }
        i++;
      }
      i--;
    } else {
      out.add(lines[i]);
    }
  }
  return out.join('\n');
}

class CrisisReferenceSections extends StatefulWidget {
  const CrisisReferenceSections({super.key, required this.sections});
  final List<Map> sections;

  @override
  State<CrisisReferenceSections> createState() =>
      _CrisisReferenceSectionsState();
}

class _CrisisReferenceSectionsState extends State<CrisisReferenceSections> {
  String _query = '';
  bool _expandAll = false;
  int _generation = 0;

  @override
  Widget build(BuildContext context) {
    final words = _query.toLowerCase().trim().split(RegExp(r'\s+'));
    final visible = widget.sections.where((s) {
      final text = '${s['title']} ${s['body_markdown']}'.toLowerCase();
      return words.every(text.contains);
    }).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('Explore this reference', style: lumaDisplay(size: 24)),
      const SizedBox(height: 8),
      const Text(
          'Open a section to read the full clinical discussion. Source citations open directly from the text.'),
      const SizedBox(height: 16),
      TextField(
        decoration: const InputDecoration(
          labelText: 'Find within this reference',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) => setState(() {
          _query = value;
          _generation++;
        }),
      ),
      if (_query.trim().isEmpty)
        Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => setState(() {
                _expandAll = !_expandAll;
                _generation++;
              }),
              child: Text(
                  _expandAll ? 'Collapse all sections' : 'Expand all sections'),
            )),
      if (visible.isEmpty)
        const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No matching sections. Try another clinical term.')),
      for (final section in visible)
        Card(
          color: LumaColors.creamElevated,
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            key: ValueKey('${section['id']}-$_generation'),
            initiallyExpanded: _expandAll || _query.trim().isNotEmpty,
            title: Text('${section['title']}',
                style: lumaBody(size: 18, weight: FontWeight.w700)),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(builder: (context, constraints) {
                final body = '${section['body_markdown'] ?? ''}';
                return MarkdownBody(
                  data: constraints.maxWidth < 650
                      ? stackReferenceTables(body)
                      : body,
                  selectable: true,
                  imageBuilder: (_, __, alt) => Text(alt ?? 'Illustration'),
                  onTapLink: (_, href, __) =>
                      ClinicalSourceLink.open(context, href),
                  styleSheet:
                      MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                    p: lumaBody(size: 16),
                    a: lumaBody(size: 16, color: LumaColors.inkNavy).copyWith(
                      decoration: TextDecoration.underline,
                      decorationColor: LumaColors.inkNavy,
                    ),
                    h3: lumaBody(size: 20, weight: FontWeight.w700),
                    tableColumnWidth: const FlexColumnWidth(),
                    tableCellsPadding: const EdgeInsets.all(10),
                  ),
                );
              })
            ],
          ),
        ),
    ]);
  }
}
