import 'package:flutter/material.dart';

import '../theme/luma_theme.dart';

class DiagnosticsNotice extends StatelessWidget {
  const DiagnosticsNotice({super.key, required this.reviewPreview});
  final bool reviewPreview;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: LumaColors.haloGoldLight,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      reviewPreview
          ? 'REVIEW PREVIEW\nAdult perioperative reference. Pending release approval; not released for patient care.'
          : 'Adult perioperative reference. Use the patient’s laboratory report, clinical context and institutional protocols. '
                'Example ranges and formulas are not stand-alone treatment or procedural-clearance thresholds.',
      style: const TextStyle(color: LumaColors.inkNavy, height: 1.5),
    ),
  );
}
