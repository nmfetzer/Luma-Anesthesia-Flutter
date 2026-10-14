import 'academy_question.dart';

/// First corrected tranche, checked against labels on 2026-10-14.
/// Do not add the legacy bank to this list without item-level review.
const academyReviewQuestions = [
  AcademyQuestion(
    id: 'etomidate-adrenal-effects',
    legacyId: 'ABAPracticeExamData:51',
    topic: 'Induction agents',
    prompt: 'Which statement about etomidate is accurate?',
    options: [
      'It preserves adrenal cortisol synthesis after an induction dose.',
      'It can cause myoclonus and transient adrenal steroid suppression.',
      'It is intended for prolonged infusion to maintain anesthesia.',
      'Pain on injection is not associated with etomidate.',
    ],
    answer: 1,
    rationale:
        'Etomidate can cause pain on injection and myoclonus. '
        'Induction doses can suppress cortisol and aldosterone production, '
        'probably by inhibiting adrenal 11-beta-hydroxylation. The label reports '
        'suppression lasting approximately 6–8 hours and warns against prolonged '
        'infusion. The old question incorrectly described preserved adrenal function.',
    sourceTitle: 'DailyMed: Etomidate, Clinical Pharmacology and Warnings',
    sourceUrl: 'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=dc43b289-4f32-1c1e-e053-2995a90a3a23',
  ),
  AcademyQuestion(
    id: 'desflurane-blood-gas',
    legacyId: 'ABAPracticeExamData:54',
    topic: 'Inhaled agents',
    prompt:
        'Which blood/gas partition coefficient at 37°C is listed '
        'for desflurane in the SUPRANE prescribing information?',
    options: ['0.424', '1.4', '2.4', '12'],
    answer: 0,
    rationale:
        'The SUPRANE label lists a blood/gas partition coefficient of '
        '0.424 at 37°C. This pharmacokinetic property does not make desflurane '
        'an appropriate inhalation-induction agent for every patient: airway '
        'irritation is common, and pediatric inhalation induction is contraindicated. '
        'The legacy item mixed agent categories and had a contradictory answer key; '
        'this replacement tests the specific labeled property.',
    sourceTitle: 'DailyMed: SUPRANE, Description and Induction',
    sourceUrl: 'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3fe3d468-d283-4dd0-a1a7-29291a9b2d0b',
  ),
  AcademyQuestion(
    id: 'plain-lidocaine-label-limit',
    legacyId: 'ABAPracticeExamData:67',
    topic: 'Local anesthetics',
    prompt:
        'For a normal healthy adult, which general maximum is '
        'listed for lidocaine hydrochloride injection WITHOUT epinephrine?',
    options: [
      '7 mg/kg, generally no more than 500 mg',
      '4.5 mg/kg, generally no more than 300 mg',
      '10 mg/kg, with no total-dose limit',
      'The same maximum for every patient and every technique',
    ],
    answer: 1,
    rationale:
        'The label gives a general maximum of 4.5 mg/kg, with a '
        'maximum total dose generally not exceeding 300 mg, for normal healthy '
        'adults without epinephrine. These are ceilings, not target doses or a '
        'guarantee against toxicity. Technique-specific limits and patient factors '
        'may require lower dosing. The old answer incorrectly combined plain '
        'lidocaine with the epinephrine-containing formulation.',
    sourceTitle:
        'DailyMed: Lidocaine Hydrochloride, Maximum Recommended Dosage',
    sourceUrl: 'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3b2dd84e-cee8-4e58-d494-395a65a353a0',
  ),
];
