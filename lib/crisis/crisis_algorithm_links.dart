import 'package:flutter/material.dart';
import '../theme/luma_theme.dart';
import '../widgets/clinical_source_link.dart';

class CrisisAlgorithm {
  const CrisisAlgorithm(this.title, this.url);
  final String title, url;
}

/// External publisher-hosted charts, not copied or modified AHA artwork.
/// Source destinations verified 2026-09-26. No patient data is sent.
const crisisAlgorithms = <String, List<CrisisAlgorithm>>{
  'cardiac_meds': [
    CrisisAlgorithm('Adult cardiac arrest',
        'https://cpr.heart.org/-/media/CPR-Files/CPR-Guidelines-Files/2025-Algorithms/Algorithm-ACLS-CA-250527.pdf'),
    CrisisAlgorithm('Adult bradycardia with a pulse',
        'https://cpr.heart.org/-/media/CPR-Files/CPR-Guidelines-Files/2025-Algorithms/Algorithm-ACLS-Bradycardia-250514.pdf?sc_lang=en'),
    CrisisAlgorithm('Adult tachyarrhythmia with a pulse',
        'https://cpr.heart.org/-/media/CPR-Files/CPR-Guidelines-Files/2025-Algorithms/Algorithm-ACLS-Tachycardia-250514.pdf?sc_lang=en'),
    CrisisAlgorithm('Electrical cardioversion',
        'https://cpr.heart.org/-/media/CPR-Files/CPR-Guidelines-Files/2025-Algorithms/Algorithm-ACLS-Electrical-Cardioversion-250514.pdf?sc_lang=en'),
  ],
  'pals': [
    CrisisAlgorithm('Pediatric cardiac arrest',
        'https://www.heart.org/-/media/CPR-Files/CPR-Guidelines-Files/2025-Algorithms/Algorithm-PALS-CA-250123.pdf'),
    CrisisAlgorithm('Pediatric bradycardia with a pulse',
        'https://cpr.heart.org/-/media/CPR-Files/CPR-Guidelines-Files/2025-Algorithms/Algorithm-PALS-Bradycardia-250121.pdf?sc_lang=en'),
    CrisisAlgorithm('Pediatric tachyarrhythmia with a pulse',
        'https://cpr.heart.org/-/media/CPR-Files/CPR-Guidelines-Files/2025-Algorithms/Algorithm-PALS-Tachyarrhythmia-250117.pdf?sc_lang=en'),
  ],
};

const bradycardiaCorrectionUrl =
    'https://cpr.heart.org/-/media/CPR-Files/Course-Updates/2026-Updates/2025_GL_ChngNtc_2626.pdf?sc_lang=en';

class CrisisAlgorithmLinks extends StatelessWidget {
  const CrisisAlgorithmLinks({super.key, required this.slug});
  final String slug;

  @override
  Widget build(BuildContext context) {
    final algorithms = crisisAlgorithms[slug] ?? const <CrisisAlgorithm>[];
    if (algorithms.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LumaColors.creamElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LumaColors.haloGoldLight),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Semantics(
          header: true,
          child: Text('Quick-access algorithms', style: lumaDisplay(size: 24)),
        ),
        const SizedBox(height: 8),
        Text(
          slug == 'pals' ? 'PEDIATRIC • AHA / AAP 2025' : 'ADULT • AHA 2025',
          style: lumaBody(size: 12, weight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text(
            'Open an official chart full-size in your browser or PDF viewer. Internet connection required.'),
        const SizedBox(height: 16),
        LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth >= 560
              ? (constraints.maxWidth - 12) / 2
              : constraints.maxWidth;
          return Wrap(spacing: 12, runSpacing: 12, children: [
            for (final algorithm in algorithms)
              SizedBox(
                width: width,
                child: OutlinedButton(
                  onPressed: () =>
                      ClinicalSourceLink.open(context, algorithm.url),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: LumaColors.inkNavy,
                    minimumSize: const Size(0, 64),
                    padding: const EdgeInsets.all(12),
                    alignment: Alignment.centerLeft,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.account_tree_outlined, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(algorithm.title,
                            style:
                                lumaBody(size: 15, weight: FontWeight.w700))),
                    const SizedBox(width: 8),
                    const Icon(Icons.open_in_new, size: 16),
                  ]),
                ),
              ),
          ]);
        }),
        if (slug == 'cardiac_meds') ...[
          const SizedBox(height: 12),
          const Text(
              'Bradycardia chart correction (Feb 6, 2026): add “Establish vascular access” to Assessment and support.'),
          Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                  onPressed: () => ClinicalSourceLink.open(
                      context, bradycardiaCorrectionUrl),
                  child: const Text('Read AHA correction notice'))),
        ],
        const SizedBox(height: 8),
        Text(
            'Charts remain on the publisher’s website. Luma is not endorsed by AHA or AAP.',
            style: lumaBody(size: 12, color: LumaColors.inkMuted)),
      ]),
    );
  }
}
