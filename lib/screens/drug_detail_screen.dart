// -----------------------------------------------------------------------------
// DrugDetailScreen — full clinical reference view for a single medication.
//
// Renders every field from the Base44 Medication entity when present.
// Fields are grouped into collapsible sections; empty fields are hidden so
// each drug's page only shows the content that's actually populated.
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../widgets/medication_deep_dive.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/medication.dart';
import '../theme/luma_theme.dart';
import '../widgets/luma_app_bar.dart';

class DrugDetailScreen extends StatelessWidget {
  const DrugDetailScreen({super.key, required this.medication});

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    final m = medication;
    return Scaffold(
      backgroundColor: LumaColors.cream,
      appBar: const LumaAppBar(title: 'Drug'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(medication: m),
              const SizedBox(height: 20),
              _WarningBanners(medication: m),
              _Section(
                title: 'Overview',
                children: [
                  _Text(label: 'INDICATIONS', value: m.indications),
                  _Text(label: 'MECHANISM OF ACTION', value: m.mechanism),
                  _Text(label: 'CLASSIFICATION', value: m.classification),
                ],
              ),
              _Section(
                title: 'Dosing',
                children: [
                  _Text(label: 'ADULT', value: m.adultDose),
                  _Text(label: 'PEDIATRIC', value: m.pedsDose),
                  if (m.doseMgPerKgMin != null || m.doseMgPerKgMax != null)
                    _Text(
                      label: 'CALCULATOR RANGE',
                      value:
                          '${m.doseMgPerKgMin ?? '?'}–${m.doseMgPerKgMax ?? '?'} ${m.doseUnit ?? 'mg'}/kg',
                    ),
                  _Text(label: 'ROUTES', value: m.routes),
                  _Text(label: 'DOSAGE FORMS', value: m.dosageForms),
                  _Text(label: 'COMMON CONCENTRATIONS', value: m.commonConcentrations),
                ],
              ),
              _Section(
                title: 'Concentration & Mixing',
                children: [
                  _Text(label: 'MIXING', value: m.concentrationMixing),
                  if (m.requiresDilution)
                    const _Chip(label: 'Requires dilution before administration'),
                  _Text(label: 'TARGET CONCENTRATION', value: m.targetConcentration),
                  _Text(label: 'STANDARD RECIPE', value: m.standardRecipe),
                  if (m.finalVolumeMl != null)
                    _Text(label: 'FINAL VOLUME', value: '${m.finalVolumeMl} mL'),
                  _Text(label: 'DILUENT', value: m.diluent),
                  _Text(label: 'ALTERNATIVE CONCENTRATIONS', value: m.alternativeConcentrations),
                  if (m.stabilityHoursRoomTemp != null)
                    _Text(
                      label: 'STABILITY (ROOM TEMP)',
                      value: '${m.stabilityHoursRoomTemp} hours',
                    ),
                  if (m.stabilityHoursRefrigerated != null)
                    _Text(
                      label: 'STABILITY (REFRIGERATED)',
                      value: '${m.stabilityHoursRefrigerated} hours',
                    ),
                  _Text(label: 'MIXING PEARLS', value: m.mixingPearls),
                  _Text(label: 'NOTES', value: m.notes),
                ],
              ),
              _Section(
                title: 'Pharmacokinetics',
                children: [
                  _Text(label: 'ONSET & DURATION', value: m.onsetDuration),
                  // ONSET (MIN) and DURATION (MIN) are calculator-only fields;
                  // never display raw minutes to the user — the ONSET & DURATION
                  // narrative above always tells the story better.
                  _Text(label: 'PHARMACOKINETICS', value: m.pharmacokinetics),
                ],
              ),
              _Section(
                title: 'Warnings & Safety',
                children: [
                  _Text(label: 'CONTRAINDICATIONS', value: m.contraindications),
                  _Text(label: 'WARNINGS & PRECAUTIONS', value: m.warningsPrecautions),
                  _Text(label: 'SIDE EFFECTS', value: m.sideEffects),
                  _Text(label: 'SERIOUS ADVERSE EFFECTS', value: m.seriousEffects),
                  _Text(label: 'DRUG INTERACTIONS', value: m.drugInteractions),
                  if (m.interactionsCritical.isNotEmpty)
                    _ChipList(
                      label: 'CRITICAL INTERACTIONS',
                      items: m.interactionsCritical,
                      color: LumaColors.highAlert,
                    ),
                  _Text(label: 'ANTIDOTE / REVERSAL', value: m.antidoteReversal),
                ],
              ),
              _Section(
                title: 'Administration',
                children: [
                  _Text(label: 'ADMINISTRATION DETAILS', value: m.administrationDetails),
                  _Text(label: 'SPECIAL POPULATIONS', value: m.specialPopulations),
                  _Text(label: 'PREGNANCY & LACTATION', value: m.pregnancyLactation),
                ],
              ),
              _Section(
                title: 'Monitoring',
                children: [
                  if (m.monitoringParameters.isNotEmpty)
                    _ChipList(
                      label: 'KEY LABS, VITALS & CHECKS',
                      items: m.monitoringParameters,
                      color: LumaColors.caution,
                    ),
                ],
              ),
              _Section(
                title: 'Clinical Pearls',
                children: [
                  _Text(label: 'PEARLS', value: m.clinicalPearls),
                  _Text(label: 'SPECIAL CONSIDERATIONS', value: m.specialConsiderations),
                ],
              ),
              _Section(
                title: 'Deep Dive',
                initiallyExpanded: false,
                children: [
                  MedicationDeepDive(medicationId: m.id),
                ],
              ),
              _Section(
                title: 'Sources',
                initiallyExpanded: false,
                children: [
                  for (final s in m.sources) _SourceRow(source: s),
                ],
              ),
              const SizedBox(height: 16),
              _ReviewFooter(medication: m),
              const SizedBox(height: 16),
              _Disclaimer(),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({required this.medication});
  final Medication medication;

  @override
  Widget build(BuildContext context) {
    final m = medication;
    final t = Theme.of(context).textTheme;
    final badges = <Widget>[];
    if (m.highAlert) {
      badges.add(_Badge(label: 'HIGH ALERT', color: LumaColors.highAlert));
    }
    if (m.isScheduled) {
      badges.add(_Badge(label: m.deaLabel, color: LumaColors.inkNavy));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(m.name, style: lumaDisplay(size: 32, weight: FontWeight.w700)),
        if (m.brandName != null) ...[
          const SizedBox(height: 2),
          Text(m.brandName!, style: t.bodyMedium?.copyWith(color: LumaColors.inkMuted)),
        ],
        if (m.classShort != null) ...[
          const SizedBox(height: 6),
          Text(m.classShort!, style: t.bodyLarge?.copyWith(color: LumaColors.inkNavy)),
        ],
        if (badges.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: badges),
        ],
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          letterSpacing: 1.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Warning banners (Boxed + LASA)
// ---------------------------------------------------------------------------

class _WarningBanners extends StatelessWidget {
  const _WarningBanners({required this.medication});
  final Medication medication;

  @override
  Widget build(BuildContext context) {
    final banners = <Widget>[];
    if (medication.blackBoxWarning != null) {
      banners.add(_WarningCard(
        label: 'FDA BOXED WARNING',
        text: medication.blackBoxWarning!,
        color: LumaColors.highAlert,
      ));
    }
    if (medication.lasaWarning != null) {
      banners.add(_WarningCard(
        label: 'LOOK-ALIKE / SOUND-ALIKE',
        text: medication.lasaWarning!,
        color: LumaColors.caution,
      ));
    }
    if (banners.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        for (final b in banners) Padding(padding: const EdgeInsets.only(bottom: 12), child: b),
      ],
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({required this.label, required this.text, required this.color});
  final String label;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: TextStyle(color: LumaColors.inkNavy, fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Collapsible section
// ---------------------------------------------------------------------------

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.children,
    this.initiallyExpanded = true,
  });
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    // Filter out empty children:
    //   - _Empty widgets (explicit empties)
    //   - _Text widgets whose value is null/blank (they'd render as _Empty)
    //   - _ChipList widgets with no items (they render nothing meaningful)
    final populated = children.where((c) {
      if (c is _Empty) return false;
      if (c is _Text) return c.hasContent;
      if (c is _ChipList) return c.items.isNotEmpty;
      return true;
    }).toList();
    if (populated.isEmpty) return const SizedBox.shrink();

    final t = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: LumaColors.creamElevated,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: LumaColors.divider),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedAlignment: Alignment.topLeft,
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(title, style: lumaDisplay(size: 18, weight: FontWeight.w600)),
          ),
          iconColor: LumaColors.inkNavy,
          collapsedIconColor: LumaColors.inkMuted,
            children: populated,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Field renderer — hides itself if value is empty
// ---------------------------------------------------------------------------

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _Text extends StatelessWidget {
  const _Text({this.label, this.value});
  final String? label;
  final String? value;

  bool get hasContent => value != null && value!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!hasContent) return const _Empty();
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (label != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label!,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: LumaColors.inkMuted,
                  fontSize: 11,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (label != null) const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              value!,
              textAlign: TextAlign.left,
              style: t.bodyMedium?.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: LumaColors.haloGold.withOpacity(0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: LumaColors.inkNavy,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ChipList extends StatelessWidget {
  const _ChipList({required this.label, required this.items, required this.color});
  final String label;
  final List<String> items;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _Empty();
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: LumaColors.inkMuted,
              fontSize: 11,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final item in items)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(color: LumaColors.inkNavy, fontSize: 12),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  const _SourceRow({required this.source});
  final MedicationSource source;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final s = source;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (s.number != null)
                Text(
                  '${s.number}.  ',
                  style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              Expanded(
                child: Text(
                  s.citation ?? '(no citation text)',
                  style: t.bodyMedium?.copyWith(height: 1.4),
                ),
              ),
            ],
          ),
          if (s.tier != null || s.type != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 20),
              child: Text(
                [
                  if (s.tier != null) s.tier!.toUpperCase(),
                  if (s.type != null) s.type!.replaceAll('_', ' ').toUpperCase(),
                ].join(' · '),
                style: TextStyle(color: LumaColors.inkMuted, fontSize: 11, letterSpacing: 0.5),
              ),
            ),
          if (s.url != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 20),
              child: InkWell(
                onTap: () async {
                  final uri = Uri.tryParse(s.url!);
                  if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                child: Text(
                  s.url!,
                  style: TextStyle(
                    color: LumaColors.haloGold,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReviewFooter extends StatelessWidget {
  const _ReviewFooter({required this.medication});
  final Medication medication;

  @override
  Widget build(BuildContext context) {
    final m = medication;
    if (m.lastReviewed == null && m.clinicalReviewer == null) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: LumaColors.divider.withOpacity(0.4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        [
          if (m.lastReviewed != null) 'Last reviewed ${m.lastReviewed}',
          if (m.clinicalReviewer != null) 'by ${m.clinicalReviewer}',
        ].join(' '),
        style: TextStyle(color: LumaColors.inkMuted, fontSize: 12),
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LumaColors.divider.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'For clinical reference only. Verify all doses and indications against '
        'institutional protocols and current prescribing information before '
        'administration.',
        style: TextStyle(color: LumaColors.inkMuted, fontSize: 12, height: 1.4),
      ),
    );
  }
}
