// -----------------------------------------------------------------------------
// DrugDetailScreen — full-page view for one medication.
//
// Layout matches Luma's editorial style:
//   • Back arrow + "Drug" toolbar label
//   • Optional black-box warning banner at the very top (critical safety info)
//   • Fraunces H1 drug name, brand names beneath, class as tertiary line
//   • Row of subtle flag chips (High Alert / DEA schedule)
//   • Info sections: Dose, Onset & Duration
//     Each section: Fraunces heading, thin divider, mono numbers, body prose
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../models/medication.dart';
import '../theme/luma_theme.dart';

class DrugDetailScreen extends StatelessWidget {
  final Medication med;
  const DrugDetailScreen({super.key, required this.med});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LumaColors.cream,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Drug', style: lumaBody(size: 14, weight: FontWeight.w500)),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          if (med.blackBoxWarning != null) _BlackBoxBanner(text: med.blackBoxWarning!),
          _Header(med: med),
          if (med.adultDose != null || med.pedsDose != null)
            _Section(
              title: 'Dose',
              children: [
                if (med.adultDose != null)
                  _LabeledBlock(label: 'Adult', body: med.adultDose!),
                if (med.pedsDose != null)
                  _LabeledBlock(label: 'Pediatric', body: med.pedsDose!),
              ],
            ),
          if (med.onsetDuration != null)
            _Section(
              title: 'Onset & Duration',
              children: [
                _LabeledBlock(label: '', body: med.onsetDuration!),
              ],
            ),
          _Section(
            title: 'Classification',
            children: [
              _LabeledBlock(label: 'Category', body: med.category),
              if (med.classShort != null)
                _LabeledBlock(label: 'Drug class', body: med.classShort!),
              if (med.isScheduled)
                _LabeledBlock(label: 'DEA schedule', body: med.deaLabel),
            ],
          ),
          const _Disclaimer(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _BlackBoxBanner extends StatelessWidget {
  final String text;
  const _BlackBoxBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LumaColors.highAlert.withValues(alpha: 0.08),
        border: Border.all(color: LumaColors.highAlert, width: 1.2),
        borderRadius: BorderRadius.circular(LumaRadius.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded,
              size: 18, color: LumaColors.highAlert),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Black Box Warning',
                    style: lumaBody(
                      size: 11,
                      weight: FontWeight.w700,
                      color: LumaColors.highAlert,
                    ).copyWith(letterSpacing: 0.08)),
                const SizedBox(height: 4),
                Text(text,
                    style: lumaBody(size: 13, color: LumaColors.inkPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Medication med;
  const _Header({required this.med});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(med.name, style: lumaDisplay(size: 28, weight: FontWeight.w600)),
          if (med.brandName != null) ...[
            const SizedBox(height: 4),
            Text(med.brandName!,
                style: lumaBody(size: 14, color: LumaColors.inkMuted)),
          ],
          if (med.classShort != null) ...[
            const SizedBox(height: 8),
            Text(med.classShort!,
                style: lumaBody(size: 14, color: LumaColors.inkSecondary)),
          ],
          if (med.highAlert || med.isScheduled) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (med.highAlert)
                  _FlagChip('HIGH ALERT', LumaColors.highAlert),
                if (med.highAlert && med.isScheduled) const SizedBox(width: 6),
                if (med.isScheduled)
                  _FlagChip('DEA ${med.deaLabel}', LumaColors.caution),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FlagChip extends StatelessWidget {
  final String label;
  final Color color;
  const _FlagChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: lumaMono(
            size: 10.5,
            weight: FontWeight.w600,
            color: color,
          ).copyWith(letterSpacing: 0.06)),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: lumaDisplay(size: 15, weight: FontWeight.w600)),
          const SizedBox(height: 10),
          Container(height: 0.5, color: LumaColors.divider),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _LabeledBlock extends StatelessWidget {
  final String label;
  final String body;
  const _LabeledBlock({required this.label, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Text(label.toUpperCase(),
                style: lumaBody(
                  size: 10.5,
                  weight: FontWeight.w600,
                  color: LumaColors.inkMuted,
                ).copyWith(letterSpacing: 0.08)),
          if (label.isNotEmpty) const SizedBox(height: 4),
          Text(body,
              style: lumaBody(size: 14, height: 1.55).copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              )),
        ],
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: LumaColors.haloGoldLight.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(LumaRadius.sm),
        ),
        child: Text(
          'For clinical reference only. Verify all doses and indications against institutional protocols and current prescribing information before administration.',
          style: lumaBody(size: 12, color: LumaColors.inkSecondary, height: 1.5),
        ),
      ),
    );
  }
}
