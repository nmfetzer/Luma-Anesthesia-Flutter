// Clinical words are public because all published Quick References are free.
// Search indexes words, not generated answers or guessed medication names.
const corrected = new Set([
  'preop-other-readiness',
  'preop-documentation',
  'antihypertensive-bolus',
  'beta-blocker-bolus',
  'induction-medications-iv-induction-chart',
  'hemodynamic-support-preload-afterload-inotropy-hr',
  'drip-quick-reference-vasoactive-infusions',
  'svt-afib-cardioversion-svt-af-with-rvr',
  'svt-afib-cardioversion-cardioversion-energies-precautions',
  'anticoagulants-reversal-emergency-reversal-chart',
  'massive-transfusion-adult-hemorrhage-chart',
  'local-anesthetic-maxima-adult-single-dose-limits',
  'local-anesthetic-maxima-last-rescue',
  'ponv-prevention-rescue',
  'neuromuscular-blockade-intubation-contraindications',
  'preop-glucose-hyperglycemia-medication-readiness',
]);

export function finalizeRows(rows) {
  for (const row of rows) {
    const terms = row.body.replace(/\]\(https?:\/\/[^)]+\)/g, ']')
      .toLowerCase().match(/[a-z][a-z0-9-]{2,}/g) ?? [];
    row.keywords = [...new Set([...row.keywords, ...terms])];
    if (corrected.has(row.id)) row.version = '2026-09-27-audit1';
  }
}
