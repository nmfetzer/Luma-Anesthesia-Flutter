// Educational review draft. No patient-input interpretation or dose calculator.
const acidBaseSource =
    'https://www.merckmanuals.com/professional/nephrology/acid-base-regulation-and-disorders/acid-base-disorders';
const compensationSource =
    'https://www.merckmanuals.com/professional/multimedia/table/primary-changes-and-compensations-in-simple-acid-base-disorders';
const gasComparisonSource =
    'https://pmc.ncbi.nlm.nih.gov/articles/PMC12387505/';
const sampleSource = 'https://pmc.ncbi.nlm.nih.gov/articles/PMC3900096/';
const airwaySource = 'https://pmc.ncbi.nlm.nih.gov/articles/PMC4703154/';
const capnographySource =
    'https://www.openanesthesia.org/wp-content/uploads/2024/10/08/ICU_one_pager_end_tidal_co2_v11.pdf';

class AbgSection {
  const AbgSection(
    this.title,
    this.bullets,
    this.sourceLabel,
    this.url, {
    this.caution = false,
  });
  final String title, sourceLabel, url;
  final List<String> bullets;
  final bool caution;
}

class AbgTopic {
  const AbgTopic(
    this.id,
    this.title,
    this.group,
    this.summary,
    this.aliases,
    this.sections,
  );
  final String id, title, group, summary, aliases;
  final List<AbgSection> sections;
}

const metabolicAcidosisCompensation = AbgSection(
  'Metabolic acidosis · Winter’s formula',
  [
    'Expected PaCO₂ = (1.5 × HCO₃⁻) + 8 ± 2 mmHg. Enter bicarbonate conceptually in mEq/L; mmol/L is numerically equivalent for bicarbonate.',
    'Measured PaCO₂ above this range suggests an additional respiratory acidosis; below it suggests an additional respiratory alkalosis.',
  ],
  'Merck Manual · Compensation table',
  compensationSource,
);
const metabolicAlkalosisCompensation = AbgSection(
  'Metabolic alkalosis · Expected respiratory response',
  [
    'PaCO₂ rises approximately 0.6–0.75 mmHg for each 1 mEq/L increase in HCO₃⁻ above baseline.',
    'Compensation alone generally should not raise PaCO₂ above 55 mmHg. These are approximate expectations, not ventilator targets.',
  ],
  'Merck Manual · Compensation table',
  compensationSource,
);
const respiratoryAcidosisCompensation = AbgSection(
  'Respiratory acidosis · Acute versus chronic',
  [
    'Acute: HCO₃⁻ rises approximately 1–2 mEq/L for each 10 mmHg rise in PaCO₂.',
    'Chronic: HCO₃⁻ rises approximately 3–4 mEq/L for each 10 mmHg rise in PaCO₂.',
    'Compare with baseline and time course. Acute-on-chronic disease may not fit either simple rule.',
  ],
  'Merck Manual · Compensation table',
  compensationSource,
);
const respiratoryAlkalosisCompensation = AbgSection(
  'Respiratory alkalosis · Acute versus chronic',
  [
    'Acute: HCO₃⁻ falls approximately 1–2 mEq/L for each 10 mmHg fall in PaCO₂.',
    'Chronic: HCO₃⁻ falls approximately 4–5 mEq/L for each 10 mmHg fall in PaCO₂.',
    'A bicarbonate value outside the expected response raises concern for an additional metabolic process.',
  ],
  'Merck Manual · Compensation table',
  compensationSource,
);
const compensationReference = <AbgSection>[
  metabolicAcidosisCompensation,
  metabolicAlkalosisCompensation,
  respiratoryAcidosisCompensation,
  respiratoryAlkalosisCompensation,
];

const abgTopics = <AbgTopic>[
  AbgTopic(
      'orientation',
      'Reading an ABG',
      'Foundations',
      'Separate the net pH from the processes producing it.',
      'arterial blood gas normal ranges ph paco2 hco3 bicarbonate acid base', [
    AbgSection(
      'Adult teaching intervals',
      [
        'pH: 7.35–7.45; PaCO₂: 35–45 mmHg; HCO₃⁻: 22–26 mmol/L.',
        'These are example adult intervals, not critical-value alerts or treatment thresholds. Use the reporting laboratory’s intervals and units.',
        'ABG assesses acid–base status, ventilation and arterial oxygenation. Review those questions separately rather than assigning a single “normal” label.',
      ],
      'Giani et al. · Blood gas review (2025)',
      gasComparisonSource,
    ),
    AbgSection(
      'Interpretation framework',
      [
        'Acidemia means pH below 7.35; alkalemia means pH above 7.45. Acidosis and alkalosis describe processes, which may coexist.',
        'A primary fall in bicarbonate favors metabolic acidosis; a primary rise favors metabolic alkalosis. A primary rise in PaCO₂ favors respiratory acidosis; a primary fall favors respiratory alkalosis.',
        'Compare the observed respiratory or metabolic response with expected compensation, then assess the anion gap and possible mixed processes.',
        'A pH inside the reference interval does not exclude an important mixed disorder. Compensation moves pH toward normal but does not overshoot.',
      ],
      'Merck Manual · Acid–base disorders',
      acidBaseSource,
    ),
  ]),
  AbgTopic(
      'sampling',
      'Sample quality & discordant results',
      'Foundations',
      'Check the specimen before explaining an unexpected number.',
      'air bubbles heparin delay contamination arterial line sample', [
    AbgSection(
      'Common preanalytical pitfalls',
      [
        'Air bubbles alter gas tensions toward ambient air; prolonged exposure may lower PaCO₂ and raise pH. Expel bubbles and handle the sample according to the laboratory protocol.',
        'Excess liquid heparin or arterial-line flush contamination can dilute the sample. Collection technique, appropriate mixing and specimen labeling matter.',
        'Delayed analysis permits cellular metabolism: oxygen and glucose may fall while lactate and acidity rise. Marked leukocytosis or thrombocytosis can accentuate oxygen consumption in the sample.',
        'Document arterial versus venous origin, collection time, oxygen delivery and ventilator settings. Follow local transport and analysis requirements rather than a universal storage rule.',
      ],
      'Baird · Preanalytical blood gas considerations',
      sampleSource,
    ),
    AbgSection(
      'When results do not fit',
      [
        'Compare the gas with the clinical condition, recent ventilation changes, pulse oximetry and related laboratory measurements.',
        'ABG bicarbonate is calculated from measured pH and PaCO₂; chemistry bicarbonate/total CO₂ is a separate measurement. A discordance merits assessment of sampling, timing and method.',
        'Recheck a questionable specimen when indicated; do not let repeat sampling delay urgent stabilization.',
      ],
      'Merck Manual · Acid–base assessment',
      acidBaseSource,
      caution: true,
    ),
  ]),
  AbgTopic(
      'vbg',
      'Arterial versus venous blood gas',
      'Foundations',
      'Useful overlap does not make every gas measurement interchangeable.',
      'vbg abg peripheral central mixed venous pvo2', [
    AbgSection(
      'What may be useful',
      [
        'Venous pH and bicarbonate can support acid–base assessment in selected settings; suitability depends on the clinical question and circulatory state.',
        'Peripheral, central and mixed venous samples represent different sampling locations. Do not treat them as a single interchangeable specimen type.',
      ],
      'Giani et al. · Blood gas review (2025)',
      gasComparisonSource,
    ),
    AbgSection(
      'Important limits',
      [
        'Venous PO₂ cannot substitute for arterial PaO₂ when assessing arterial oxygenation.',
        'Venous PCO₂ agreement with PaCO₂ is variable. Do not apply a fixed subtraction to convert every VBG into an ABG, especially in critical illness.',
        'Use an arterial sample when precise arterial ventilation or oxygenation assessment is required; interpret alongside the rest of the clinical picture.',
      ],
      'Giani et al. · Arterial/venous limitations',
      gasComparisonSource,
      caution: true,
    ),
  ]),
  AbgTopic(
      'metabolic-acidosis',
      'Metabolic acidosis',
      'Primary disorders',
      'Low bicarbonate requires compensation and anion-gap assessment.',
      'winter winters dka ketoacidosis lactic uremia', [
    AbgSection(
      'Pattern and mechanism',
      [
        'The primary process lowers HCO₃⁻. Acidemia is typical unless another process changes the net pH.',
        'Acid accumulation or bicarbonate loss may contribute. An increased anion gap supports accumulation of unmeasured anions, including lactate, ketoacids, retained acids in kidney failure or certain toxins.',
        'Determine the cause rather than treating a bicarbonate number in isolation. Use the clinical history, electrolytes and targeted laboratory evaluation.',
      ],
      'Merck Manual · Metabolic acid–base processes',
      acidBaseSource,
    ),
    metabolicAcidosisCompensation,
    AbgSection(
      'Anesthesia caution',
      [
        'A PaCO₂ within the usual reference interval may still be inappropriately high when bicarbonate is markedly reduced.',
        'Severe metabolic acidosis may depend on very high compensatory minute ventilation. Apnea or failure to maintain compensation around induction can rapidly worsen acidemia.',
        'Plan ventilation and hemodynamic support before induction; reassess the gas after a major change in ventilation or clinical condition.',
      ],
      'Mosier et al. · Physiologically difficult airway',
      airwaySource,
      caution: true,
    ),
  ]),
  AbgTopic(
      'metabolic-alkalosis',
      'Metabolic alkalosis',
      'Primary disorders',
      'Assess the primary bicarbonate rise and the limits of compensation.',
      'high bicarbonate hypoventilation alkalemia', [
    AbgSection(
      'Pattern and interpretation',
      [
        'The primary process raises HCO₃⁻. Alkalemia is typical, but a second disorder may bring pH into the reference interval.',
        'A compensatory PaCO₂ rise reflects hypoventilation, not necessarily a separate primary respiratory process.',
        'Compare the observed PaCO₂ with the expected response. A discrepancy warrants assessment for an additional respiratory disorder.',
      ],
      'Merck Manual · Acid–base disorders',
      acidBaseSource,
    ),
    metabolicAlkalosisCompensation,
    AbgSection(
      'Perioperative implications',
      [
        'Alkalemia may accompany reduced ionized calcium, potassium, magnesium or phosphate. Interpret these measurements in context rather than inferring their values from pH.',
        'Potential consequences include arrhythmias, neuromuscular irritability and reduced tissue perfusion from vasoconstriction.',
        'Compensatory hypoventilation can worsen oxygenation. Oxygenation still requires its own assessment.',
      ],
      'Merck Manual · Consequences of alkalemia',
      acidBaseSource,
      caution: true,
    ),
  ]),
  AbgTopic(
      'respiratory-acidosis',
      'Respiratory acidosis',
      'Primary disorders',
      'A primary CO₂ rise: distinguish acute, chronic and mixed patterns.',
      'hypercapnia hypoventilation retention paco2', [
    AbgSection(
      'Pattern and time course',
      [
        'A primary increase in PaCO₂ acidifies the blood. The associated bicarbonate response differs between acute buffering and chronic renal adaptation.',
        'A single elevated PaCO₂ does not establish chronicity. Compare prior gases, bicarbonate, clinical history and the timing of ventilation changes.',
        'An acute deterioration superimposed on chronic CO₂ retention may not match one simple compensation rule.',
      ],
      'Merck Manual · Respiratory acid–base processes',
      acidBaseSource,
    ),
    respiratoryAcidosisCompensation,
    AbgSection(
      'Avoid the compensation trap',
      [
        'An elevated bicarbonate may be compensation rather than a separate metabolic alkalosis. A lower-than-expected value may indicate a concurrent metabolic acidosis.',
        'Use the whole pattern, not an isolated pH or PaCO₂, to assess whether one process adequately explains the gas.',
      ],
      'Merck Manual · Expected compensation',
      compensationSource,
    ),
  ]),
  AbgTopic(
      'respiratory-alkalosis',
      'Respiratory alkalosis',
      'Primary disorders',
      'Low PaCO₂ may be a primary process or a needed compensatory response.',
      'hypocapnia hyperventilation low carbon dioxide', [
    AbgSection(
      'Pattern and distinction',
      [
        'A primary fall in PaCO₂ produces respiratory alkalosis. A fall in PaCO₂ accompanying metabolic acidosis may instead be appropriate respiratory compensation.',
        'Determine the primary process from pH, bicarbonate, expected compensation and clinical context; do not label all hyperventilation as primary respiratory alkalosis.',
        'Acute and chronic respiratory alkalosis produce different expected falls in bicarbonate.',
      ],
      'Merck Manual · Respiratory acid–base processes',
      acidBaseSource,
    ),
    respiratoryAlkalosisCompensation,
    AbgSection(
      'Clinical context',
      [
        'Alkalemia can reduce ionized calcium and contribute to paresthesias, tetany, altered mental status or seizures.',
        'A pH in the reference interval does not exclude respiratory alkalosis combined with metabolic acidosis.',
      ],
      'Merck Manual · Mixed disorders and alkalemia',
      acidBaseSource,
    ),
  ]),
  AbgTopic(
      'anion-gap',
      'Anion gap & albumin',
      'Mixed disorders',
      'Unmeasured anions must be interpreted against the right baseline.',
      'ag sodium chloride albumin hypoalbuminemia normal gap high gap', [
    AbgSection(
      'Calculation and context',
      [
        'Anion gap without potassium = Na⁺ − (Cl⁻ + HCO₃⁻), using matching electrolyte units, usually mEq/L.',
        'Use the laboratory’s reference interval and its convention regarding potassium. Do not impose one universal “normal” gap across all methods.',
        'Use a coherent, contemporaneous electrolyte panel. The chemistry bicarbonate/total CO₂ measurement and ABG-calculated bicarbonate are not identical methods.',
      ],
      'Merck Manual · Anion gap',
      acidBaseSource,
    ),
    AbgSection(
      'Albumin matters',
      [
        'Albumin contributes to the usual unmeasured anion pool. Hypoalbuminemia lowers the expected normal anion gap and may mask a clinically important increase.',
        'A commonly used adjustment reduces the expected normal gap by approximately 2.5 mEq/L for each 1 g/dL fall in albumin from the chosen normal baseline.',
        'Document the baseline and albumin units when making an adjustment; do not apply a g/dL coefficient directly to a g/L value.',
        'A gap estimate supports the interpretation; it does not identify the acid or replace evaluation for lactate, ketones, kidney dysfunction or toxins when indicated.',
      ],
      'Merck Manual · Albumin and anion gap',
      acidBaseSource,
    ),
  ]),
  AbgTopic(
      'mixed',
      'Mixed disorders & the delta gap',
      'Mixed disorders',
      'A normal-looking pH can conceal opposing abnormalities.',
      'delta ag gap corrected bicarbonate combined normal ph', [
    AbgSection(
      'Recognizing more than one process',
      [
        'Compare measured compensation with the expected range. A response that is too large or too small suggests an additional primary process.',
        'Compensation alone does not overshoot to the opposite pH disturbance. A near-normal pH with substantially abnormal PaCO₂ and bicarbonate warrants a mixed-disorder assessment.',
        'For metabolic acidosis, PaCO₂ above Winter’s expected range suggests additional respiratory acidosis; below the range suggests additional respiratory alkalosis.',
      ],
      'Merck Manual · Mixed acid–base disorders',
      acidBaseSource,
    ),
    AbgSection(
      'Delta-gap teaching method',
      [
        'For an elevated anion gap: delta AG = measured AG − the appropriate normal AG. Account for the laboratory convention and albumin when selecting that baseline.',
        'Add delta AG to the measured bicarbonate. A resulting bicarbonate above its expected normal value supports an additional metabolic alkalosis.',
        'This is a cross-check, not a standalone diagnosis. Baseline bicarbonate, timing, concurrent treatment and changing acid–base processes affect the interpretation.',
        'Do not apply fixed delta-ratio labels to every patient or allow them to override the full clinical picture.',
      ],
      'Merck Manual · Delta gap',
      acidBaseSource,
    ),
  ]),
  AbgTopic(
      'oxygenation',
      'Oxygenation is not ventilation',
      'Perioperative',
      'PaO₂, PaCO₂ and venous gas values answer different questions.',
      'pao2 spo2 fio2 saturation oxygen hypoxemia', [
    AbgSection(
      'Keep the questions separate',
      [
        'PaCO₂ supports assessment of ventilation; arterial PaO₂ supports assessment of oxygenation. A satisfactory oxygen value does not establish normal CO₂ clearance.',
        'Interpret PaO₂ with the oxygen delivery system and inspired oxygen concentration, not as an isolated number. Reference values also vary with altitude and patient context.',
        'Record the settings and timing of the sample after oxygen or ventilator changes. A gas is a snapshot of those conditions.',
      ],
      'MedlinePlus · Blood gases',
      'https://medlineplus.gov/ency/article/003855.htm',
    ),
    AbgSection(
      'Specimen limitation',
      [
        'Venous PO₂ is not a substitute for PaO₂. If the clinical question requires arterial oxygenation, use an appropriate arterial assessment.',
        'Interpret gas results alongside monitoring and clinical findings. No single gas value should be treated as a complete cardiopulmonary assessment.',
      ],
      'Giani et al. · Blood gas review (2025)',
      gasComparisonSource,
    ),
  ]),
  AbgTopic(
      'capnography',
      'EtCO₂ versus PaCO₂',
      'Perioperative',
      'Follow the waveform, but do not assume a fixed arterial gradient.',
      'etco2 end tidal capnography dead space pulmonary embolism cardiac output',
      [
        AbgSection(
          'What the measurements represent',
          [
            'EtCO₂ is the end-exhaled carbon dioxide measurement; PaCO₂ is the arterial carbon dioxide tension.',
            'EtCO₂ is usually below PaCO₂ because of physiologic dead space. The difference is not a constant correction factor for every patient.',
            'Increased dead space can widen the arterial-to-end-tidal gradient. Reduced cardiac output or pulmonary embolism can reduce CO₂ delivery to ventilated lung units.',
          ],
          'OpenAnesthesia · Capnography reference (PDF)',
          capnographySource,
        ),
        AbgSection(
          'Anesthesia application',
          [
            'Use capnography for continuous trend and waveform assessment while recognizing that changing perfusion or dead space may alter its relationship to PaCO₂.',
            'When precise arterial CO₂ assessment matters or the clinical picture changes, correlate the end-tidal trend with an arterial gas rather than assuming a fixed gradient.',
          ],
          'OpenAnesthesia · Capnography reference (PDF)',
          capnographySource,
        ),
      ]),
  AbgTopic(
      'induction',
      'Loss of compensation around induction',
      'Perioperative',
      'Severe metabolic acidosis creates a physiologically difficult airway.',
      'apnea intubation minute ventilation dka salicylate hemodynamic collapse',
      [
        AbgSection(
          'Why this matters',
          [
            'Severe metabolic acidosis may drive exceptionally high spontaneous minute ventilation. Even brief apnea can remove essential respiratory compensation.',
            'Mechanical ventilation after intubation may not reproduce the pre-induction ventilation. A rapid PaCO₂ rise can markedly worsen acidemia and cardiovascular instability.',
            'DKA, severe lactic acidosis and salicylate toxicity are examples in which compensatory hyperventilation may be prominent; the airway plan must address the underlying physiology.',
          ],
          'Mosier et al. · Physiologically difficult airway',
          airwaySource,
          caution: true,
        ),
        AbgSection(
          'Planning principles, not a ventilator prescription',
          [
            'Assess the pre-induction breathing pattern, gas, hemodynamics and expected compensation before a planned intervention when circumstances allow.',
            'Anticipate the effect of apnea and the feasibility of maintaining compensation; individualize the induction and ventilation strategy with the responsible clinician.',
            'Reassess ventilation, gas exchange and hemodynamics after airway control. Avoid treating a “normal” PaCO₂ as a universal goal in severe metabolic acidosis.',
            'This reference does not provide automatic ventilator settings, drug doses or a substitute for institutional emergency protocols.',
          ],
          'Mosier et al. · Peri-intubation physiology',
          airwaySource,
        ),
      ]),
  AbgTopic(
      'consequences',
      'Consequences of severe pH disturbance',
      'Perioperative',
      'Consider cardiovascular, electrolyte and neurologic effects.',
      'acidemia alkalemia ionized calcium potassium arrhythmia contractility', [
    AbgSection(
      'Acidemia',
      [
        'Potential effects include reduced myocardial contractility, cardiac output and blood pressure; impaired catecholamine responsiveness; and arrhythmias.',
        'Pulmonary vascular resistance may increase. Hyperkalemia, altered consciousness and respiratory muscle fatigue may coexist.',
        'Severity, duration and cause matter. These consequences are not a universal pH cutoff for a procedure or a blanket indication for bicarbonate.',
      ],
      'Merck Manual · Clinical consequences of acidemia',
      acidBaseSource,
      caution: true,
    ),
    AbgSection(
      'Alkalemia',
      [
        'Vasoconstriction can reduce coronary and cerebral blood flow. Arrhythmias and neuromuscular irritability may occur.',
        'Reduced ionized calcium and abnormalities in potassium, magnesium or phosphate can contribute to symptoms.',
        'Compensatory hypoventilation can worsen hypoxemia. Evaluate the cause and associated abnormalities rather than the pH alone.',
      ],
      'Merck Manual · Clinical consequences of alkalemia',
      acidBaseSource,
      caution: true,
    ),
  ]),
  AbgTopic(
      'examples',
      'Worked interpretation examples',
      'Teaching cases',
      'Three synthetic cases showing why compensation matters.',
      'winter practice calculation normal ph mixed disorder', [
    AbgSection(
      'Example A · Response within the expected range',
      [
        'Synthetic adult values: pH 7.25, PaCO₂ 26 mmHg, HCO₃⁻ 11 mEq/L.',
        'Winter’s estimate: (1.5 × 11) + 8 = 24.5 ± 2 mmHg, or 22.5–26.5 mmHg.',
        'The PaCO₂ of 26 is within that range: metabolic acidosis with a respiratory response consistent with expected compensation.',
        'The gas alone does not establish the cause or exclude a second metabolic process. Electrolytes, anion gap and clinical context are still needed.',
      ],
      'Method: Merck Manual · Compensation table',
      compensationSource,
    ),
    AbgSection(
      'Example B · Normal pH, mixed processes',
      [
        'Synthetic adult values: pH 7.40, PaCO₂ 20 mmHg, HCO₃⁻ 12 mEq/L.',
        'Winter’s estimate: (1.5 × 12) + 8 = 26 ± 2 mmHg, or 24–28 mmHg.',
        'The PaCO₂ of 20 is lower than expected: metabolic acidosis with an additional respiratory alkalosis, despite the pH being within the usual interval.',
      ],
      'Method: Merck Manual · Compensation table',
      compensationSource,
    ),
    AbgSection(
      'Example C · Additional respiratory acidosis',
      [
        'Synthetic adult values: pH 7.10, PaCO₂ 60 mmHg, HCO₃⁻ 18 mEq/L.',
        'Winter’s estimate: (1.5 × 18) + 8 = 35 ± 2 mmHg, or 33–37 mmHg.',
        'The PaCO₂ of 60 is well above expected: combined metabolic and respiratory acidosis, not appropriate compensation.',
        'These are rounded teaching examples, not a patient-input diagnostic engine or treatment recommendation.',
      ],
      'Method: Merck Manual · Compensation table',
      compensationSource,
    ),
  ]),
];

final abgGroups = <String>[
  'All',
  ...abgTopics.map((topic) => topic.group).toSet(),
];

List<AbgTopic> searchAbgTopics(String query, {String group = 'All'}) {
  String normalize(String text) => text
      .toLowerCase()
      .replaceAll(RegExp('[–−-]'), ' ')
      .replaceAll('₂', '2')
      .replaceAll('₃', '3')
      .replaceAll('⁻', '');
  final words = normalize(query)
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty);
  return abgTopics.where((topic) {
    if (group != 'All' && topic.group != group) return false;
    final haystack = normalize(
      [
        topic.title,
        topic.group,
        topic.summary,
        topic.aliases,
        for (final section in topic.sections) ...[
          section.title,
          ...section.bullets,
        ],
      ].join(' '),
    );
    return words.every(haystack.contains);
  }).toList();
}
