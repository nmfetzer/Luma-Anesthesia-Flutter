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
