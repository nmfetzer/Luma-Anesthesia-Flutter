import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../widgets/clinical_source_link.dart';

/// Compact two-column clinical charts. The protected Markdown remains server
/// content; this widget only gives the dose column most of the available width.
class QuickReferenceChart extends StatelessWidget {
  const QuickReferenceChart({
    super.key,
    required this.body,
    this.nameColumnFlex = 1,
  });
  final String body;
  final double nameColumnFlex;

  @override
  Widget build(BuildContext context) {
    final lines = body
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.trim())
        .toList();
    final rows = lines
        .where((line) => !RegExp(r'^\|[\s:|-]+\|$').hasMatch(line))
        .map(
          (line) =>
              line.length >= 2 && line.startsWith('|') && line.endsWith('|')
              ? line.substring(1, line.length - 1).split('|')
              : <String>[],
        )
        .toList();
    if (rows.isEmpty ||
        lines.any((line) => !line.startsWith('|') || !line.endsWith('|')) ||
        rows.any((row) => row.length != 2)) {
      return MarkdownBody(
        data: body,
        selectable: true,
        onTapLink: (text, href, title) =>
            ClinicalSourceLink.open(context, href),
      );
    }
    return Table(
      columnWidths: {
        0: FlexColumnWidth(nameColumnFlex),
        1: const FlexColumnWidth(2),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      border: TableBorder.all(color: const Color(0xFFD8E2EC), width: 0.7),
      children: [
        for (var index = 0; index < rows.length; index++)
          TableRow(
            decoration: BoxDecoration(
              color: index == 0
                  ? const Color(0xFFEAF2FF)
                  : index.isEven
                  ? const Color(0xFFF7F9FC)
                  : Colors.white,
            ),
            children: [
              for (var column = 0; column < rows[index].length; column++)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 12,
                  ),
                  child: MarkdownBody(
                    data: rows[index][column].trim(),
                    selectable: true,
                    onTapLink: (text, href, title) =>
                        ClinicalSourceLink.open(context, href),
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        fontSize: index == 0 || column == 0 ? 13 : 14,
                        height: 1.5,
                        fontWeight: index == 0
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: const Color(0xFF172C40),
                      ),
                      a: const TextStyle(
                        color: Color(0xFF176AD6),
                        decoration: TextDecoration.underline,
                      ),
                      blockSpacing: 6,
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
