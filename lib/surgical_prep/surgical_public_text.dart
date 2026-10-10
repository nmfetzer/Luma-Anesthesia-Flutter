/// Public-release wording for bundled surgical case text.
///
/// The bundled JSON keeps its reviewed source wording (preservation checks and
/// correction ledgers compare against it). These exact, owner-approved
/// replacements remove only internal "draft / before release" status language
/// at display time. Clinical uses of "release" (clamp or device release) are
/// never matched because every pattern is a full status phrase.
const _replacements = <(String, String)>[
  (
    'This remains a clinical-review draft. Evidence reconciliation, software '
        'testing and source integration do not establish independent clinician '
        'approval or authorize release.',
    '',
  ),
  ('This reference is available for review only; device/', 'Device/'),
  (
    'Independent cardiac-obstetric anesthesia clinical signoff has not been '
        'recorded. ',
    '',
  ),
  (
    'Independent LVAD/cardiac anesthesia clinical signoff has not been recorded. ',
    '',
  ),
  ('Independent ECMO/perfusion clinical signoff has not been recorded. ', ''),
  (
    'The source update does not constitute independent cardiac-obstetric '
        'signoff. ',
    '',
  ),
  (
    'the GLP-1 guidance difference and independent clinical review remain '
        'explicit. This is not specialist approval or a complete institutional '
        'ERAS order set.',
    'the GLP-1 guidance difference is stated explicitly. This is not a '
        'complete institutional ERAS order set.',
  ),
  (
    '; specialist clinical review is required before release.',
    '; involve specialist colleagues when indicated.',
  ),
  (
    ' and specialist clinical review remain essential before release.',
    ' and specialist input remain essential.',
  ),
  (
    ' and obtain specialist review before release.',
    ' and involve specialist colleagues when indicated.',
  ),
  (
    'This adult reference is a clinical review draft,',
    'This is an adult clinical reference,',
  ),
  (
    'This is an adult clinical-review draft,',
    'This is an adult clinical reference,',
  ),
  ('This adult clinical-review draft', 'This adult clinical reference'),
  ('Adult clinical-review draft', 'Adult clinical reference'),
  ('Adult clinical review draft', 'Adult clinical reference'),
];

String publicSurgicalText(String text) {
  var out = text;
  for (final (from, to) in _replacements) {
    out = out.replaceAll(from, to);
  }
  return out.replaceAll(RegExp(' {2,}'), ' ').trim();
}

/// Applies [publicSurgicalText] and drops bullets left empty.
List<String> publicSurgicalBullets(Iterable<String> bullets) => [
  for (final b in bullets)
    if (publicSurgicalText(b) case final t when t.isNotEmpty) t,
];

const _glp1Notice =
    'GLP-1 guidance differs: the 2026 gynecologic oncology ERAS update and the '
    'ASA-endorsed multisociety guidance give different hold/continue advice. '
    'Agree on the GLP-1 plan and anticoagulant/neuraxial timing with the team. '
    'No automatic medication orders.';

String _specialty(String team) =>
    'High-risk specialty case: plan with the $team. Follow device- or '
    'lesion-specific and institutional protocols. Not a patient-specific '
    'protocol.';

/// Owner-approved final customer notices (clinical review, 2026-10-10).
final Map<String, String> publicSurgicalNotices = {
  'gynecology-anesthesia-framework': _glp1Notice,
  'gynecologic-oncology-staging-laparotomy': _glp1Notice,
  'ovarian-cancer-debulking-cytoreductive-surgery': _glp1Notice,
  'radical-hysterectomy': _glp1Notice,
  'pelvic-exenteration': _glp1Notice,
  'placenta-accreta-spectrum-pas-cesarean-hysterectomy':
      'Delivery timing differs by source: ACOG/SMFM suggests 34+0–35+6 weeks '
      'for stable PAS, and the 2026 RCOG guideline is internally inconsistent. '
      'Confirm timing with the MFM/PAS team. Do not use this reference alone '
      'to schedule delivery.',
  'lvad-placement-left-ventricular-assist-device': _specialty(
    'LVAD/cardiac anesthesia team',
  ),
  'ecmo-cannulation-decannulation': _specialty('ECMO/perfusion team'),
  'high-risk-obstetric-anesthesia-cardiac-disease-in-pregnancy': _specialty(
    'Pregnancy Heart Team and obstetric anesthesia',
  ),
};

/// Final notice for a case; unknown or absent notices pass through.
String? publicSurgicalNotice(String id, String? notice) =>
    notice == null ? null : publicSurgicalNotices[id] ?? notice;

String publicSurgicalTitle(String title) => switch (title) {
  'Evidence scope & pending specialist review' => 'Evidence scope',
  'Evidence scope & clinical-review status' => 'Evidence scope',
  'Evidence scope & review boundary' => 'Evidence scope',
  _ => title,
};
