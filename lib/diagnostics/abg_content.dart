// Clinician-facing adult perioperative reference; pending clinical review.
const acidBaseSource =
    'https://www.merckmanuals.com/professional/nephrology/acid-base-regulation-and-disorders/acid-base-disorders';
const compensationSource =
    'https://www.merckmanuals.com/professional/multimedia/table/primary-changes-and-compensations-in-simple-acid-base-disorders';
const acidosisReview = 'https://pmc.ncbi.nlm.nih.gov/articles/PMC10874758/';
const alkalosisReview = 'https://pmc.ncbi.nlm.nih.gov/articles/PMC10028421/';
const dkaConsensus = 'https://pmc.ncbi.nlm.nih.gov/articles/PMC11272983/';
const alkalosisSource =
    'https://www.merckmanuals.com/professional/nephrology/acid-base-regulation-and-disorders/metabolic-alkalosis';
const respiratorySource =
    'https://www.openanesthesia.org/keywords/respiratory-acidosis-and-alkalosis/';
const gasComparisonSource =
    'https://pmc.ncbi.nlm.nih.gov/articles/PMC12387505/';
const sampleSource = 'https://pmc.ncbi.nlm.nih.gov/articles/PMC3900096/';
const airwaySource = 'https://pmc.ncbi.nlm.nih.gov/articles/PMC4703154/';
const capnographySource =
    'https://www.openanesthesia.org/wp-content/uploads/2024/10/08/ICU_one_pager_end_tidal_co2_v11.pdf';
const tourniquetSource =
    'https://www.openanesthesia.org/keywords/perioperative-tourniquet-use/';

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

class AbgDifferential {
  const AbgDifferential(
    this.process,
    this.clues,
    this.focus,
    this.sourceLabel,
    this.url,
  );
  final String process, clues, focus, sourceLabel, url;
}

class AbgTopic {
  const AbgTopic(
    this.id,
    this.title,
    this.group,
    this.summary,
    this.aliases,
    this.sections, {
    this.differential = const [],
  });
  final String id, title, group, summary, aliases;
  final List<AbgSection> sections;
  final List<AbgDifferential> differential;
}

const compensationReference = <AbgSection>[
  AbgSection(
    'Metabolic acidosis',
    [
      'Expected PaCO₂ = (1.5 × HCO₃⁻) + 8 ± 2 mmHg. HCO₃⁻ in mEq/L (numerically equivalent to mmol/L).',
      'Above expected: additional respiratory acidosis. Below expected: additional respiratory alkalosis.',
    ],
    'Merck Manual · Compensation table',
    compensationSource,
  ),
  AbgSection(
    'Metabolic alkalosis',
    [
      'PaCO₂ rises approximately 0.6–0.75 mmHg per 1 mEq/L rise in HCO₃⁻ above baseline.',
      'Compensation alone generally does not raise PaCO₂ above 55 mmHg.',
    ],
    'Merck Manual · Compensation table',
    compensationSource,
  ),
  AbgSection(
    'Respiratory acidosis',
    [
      'Acute: HCO₃⁻ rises 1–2 mEq/L per 10 mmHg PaCO₂ increase.',
      'Chronic: HCO₃⁻ rises 3–4 mEq/L per 10 mmHg PaCO₂ increase.',
    ],
    'Merck Manual · Compensation table',
    compensationSource,
  ),
  AbgSection(
    'Respiratory alkalosis',
    [
      'Acute: HCO₃⁻ falls 1–2 mEq/L per 10 mmHg PaCO₂ decrease.',
      'Chronic: HCO₃⁻ falls 4–5 mEq/L per 10 mmHg PaCO₂ decrease.',
    ],
    'Merck Manual · Compensation table',
    compensationSource,
  ),
];

const gapReference = AbgSection(
  'Anion gap and delta gap',
  [
    'AG = Na⁺ − (Cl⁻ + HCO₃⁻), using matching units and the laboratory’s convention. Use its reference interval, not a universal normal gap.',
    'Hypoalbuminemia lowers the expected normal AG by about 2.5 mEq/L per 1 g/dL fall in albumin from the chosen normal baseline; document the baseline and units.',
    'Delta AG = measured AG − appropriate normal AG. Adding delta AG to measured HCO₃⁻ yields a useful cross-check: a value above the expected normal bicarbonate supports a concurrent metabolic alkalosis.',
    'Compensation and gap estimates are diagnostic aids, not treatment targets. Acute-on-chronic states, evolving therapy and baseline abnormalities limit rigid interpretation.',
  ],
  'Merck Manual · Anion gap and mixed disorders',
  acidBaseSource,
);

const abgTopics = <AbgTopic>[
  AbgTopic(
    'unexplained-acidosis',
    'Unexplained intraoperative metabolic acidosis',
    'Metabolic',
    'Separate perfusion failure, unmeasured anions and chloride effects.',
    'high anion gap ag sodium chloride albumin base deficit hco3 winter renal toxins',
    [
      AbgSection(
        'Identify what is driving the change',
        [
          'Pair the current gas with contemporaneous sodium, chloride, chemistry bicarbonate/total CO₂, albumin, lactate, glucose and renal function. Obtain blood ketones when the context warrants.',
          'Review the trend against preoperative values, fluid composition and volume, urine output, blood loss, hemodynamics, medications and timing of surgical events.',
          'Assess the albumin-adjusted gap and the sodium–chloride relationship. A “normal” gap in a hypoalbuminemic patient can conceal unmeasured anions; gap and chloride-associated acidosis can coexist.',
          'Base deficit is nonspecific. It does not distinguish hypoperfusion, chloride loading, renal acids or mixed processes.',
        ],
        'BJA Education · Metabolic acidosis (2024)',
        acidosisReview,
      ),
      AbgSection(
        'Anesthesia implications',
        [
          'Compare PaCO₂ with the expected response, not just the usual laboratory range. A mechanically ventilated patient cannot independently increase ventilation to compensate for a new metabolic acid load.',
          'Acidemia can reduce myocardial contractility and catecholamine responsiveness, increase pulmonary vascular tone and compound arrhythmia risk.',
          'Address the cause and the adequacy of ventilation together. Improving the displayed pH is not evidence that perfusion or the underlying disease has improved.',
        ],
        'BJA Education · Perioperative metabolic acidosis',
        acidosisReview,
        caution: true,
      ),
      AbgSection(
        'Management pitfalls',
        [
          'Do not equate every base deficit with a need for more crystalloid. Further chloride-rich fluid can worsen chloride-associated acidosis.',
          'Do not attribute progressive acidemia solely to recent saline without considering ongoing ischemia, lactate, ketones and renal dysfunction.',
          'Persistent or worsening acidosis despite correction of apparent causes warrants reassessment and escalation of organ support, not repeated empiric bicarbonate solely to normalize a number.',
        ],
        'BJA Education · Cause-directed management',
        acidosisReview,
      ),
    ],
    differential: [
      AbgDifferential(
        'Lactate-associated',
        'Shock, hemorrhage, regional ischemia; adrenergic stimulation or impaired clearance may coexist.',
        'Measure lactate and assess perfusion, oxygen delivery, source control and liver function.',
        'BJA Education · Acidosis differential',
        acidosisReview,
      ),
      AbgDifferential(
        'Ketoacids',
        'Diabetes, SGLT2 exposure, fasting, insulin interruption; glucose may not be markedly elevated.',
        'Measure β-hydroxybutyrate and glucose; assess diabetes history and metabolic context.',
        '2024 hyperglycemic-crises consensus',
        dkaConsensus,
      ),
      AbgDifferential(
        'Renal / exogenous anions',
        'AKI, advanced renal disease, relevant drug or toxic exposure; lactate does not explain the gap.',
        'Review renal trajectory and exposures; obtain targeted testing and specialist input.',
        'BJA Education · Acidosis differential',
        acidosisReview,
      ),
      AbgDifferential(
        'Chloride-associated',
        'Chloride-rich fluids, GI bicarbonate losses, renal tubular dysfunction or acetazolamide.',
        'Review fluid balance and electrolytes; assess for a simultaneous high-gap component.',
        'BJA Education · Acidosis differential',
        acidosisReview,
      ),
    ],
  ),
  AbgTopic(
      'lactate',
      'Rising lactate: perfusion, production or clearance?',
      'Metabolic',
      'Interpret the trajectory without reflex fluid loading.',
      'lactic shock hemorrhage epinephrine beta agonist liver ischemia tourniquet reperfusion',
      [
        AbgSection(
          'Clinical discrimination',
          [
            'Hypovolemia, low cardiac output, sepsis and regional ischemia are important causes. A satisfactory systemic blood pressure does not by itself resolve concern about a regional ischemic source.',
            'Endogenous or exogenous β₂ stimulation, including epinephrine, can increase lactate through accelerated aerobic metabolism. Impaired hepatic metabolism may contribute independently.',
            'Evaluate lactate alongside its trajectory, hemodynamic course, bleeding, organ function and the operative context. Adrenergic generation is a consideration, not permission to dismiss hypoperfusion.',
          ],
          'BJA Education · Lactate mechanisms and management',
          acidosisReview,
        ),
        AbgSection(
          'Cause-directed response',
          [
            'For suspected hypoperfusion, address oxygen delivery and the mechanism: circulating volume, cardiac function, hemorrhage or local ischemia. Regional ischemia may require surgical intervention.',
            'Reassess exogenous β-agonist exposure when clinically feasible, while preserving needed hemodynamic support.',
            'A bicarbonate bolus does not correct the source of lactate generation. Treat the cause and follow the metabolic and clinical response.',
          ],
          'BJA Education · Lactic acidosis',
          acidosisReview,
        ),
        AbgSection(
          'Tourniquet release: a timing clue, not a dismissal',
          [
            'Deflation can release CO₂-rich blood, lactate and potassium, with transient hypercarbia, acidosis and reduced arterial pressure.',
            'Anticipate the transition, correlate changes with release, and reassess ventilation and hemodynamics. Do not assume persistent or disproportionate abnormalities are benign washout.',
            'Patients with limited cardiovascular reserve or elevated intracranial pressure require particular attention to the physiologic consequences.',
          ],
          'OpenAnesthesia · Perioperative tourniquet use',
          tourniquetSource,
        ),
      ]),
  AbgTopic(
      'euglycemic-dka',
      'Perioperative ketoacidosis & SGLT2 exposure',
      'Metabolic',
      'Near-normal glucose does not exclude a consequential ketoacidosis.',
      'euglycemic dka euDKA beta hydroxybutyrate ketones fasting insulin potassium',
      [
        AbgSection(
          'When the glucose is misleading',
          [
            'Consider euglycemic DKA in a patient with diabetes or SGLT2 exposure, reduced intake and otherwise unexplained metabolic acidosis. Measure blood β-hydroxybutyrate rather than relying on glucose or urine ketones alone.',
            'The adult consensus diagnosis requires diabetes/history of diabetes or glucose ≥200 mg/dL, significant ketosis (β-hydroxybutyrate ≥3.0 mmol/L or urine ketones ≥2+), and metabolic acidosis (pH <7.3 and/or bicarbonate <18 mmol/L).',
            'Euglycemic DKA has glucose <200 mg/dL with the ketosis and acidosis criteria. Starvation and alcoholic ketoacidosis remain alternative causes of ketonemia; interpret the full context.',
          ],
          'ADA/EASD and partner societies · 2024 consensus',
          dkaConsensus,
        ),
        AbgSection(
          'Management considerations',
          [
            'Use the institutional DKA pathway for fluids, insulin, dextrose, potassium and serial metabolic assessment. Stop SGLT2 therapy on admission when DKA is present.',
            'Euglycemic DKA requires dextrose early alongside insulin so ketogenesis can be suppressed without causing hypoglycemia; a low glucose is not a reason to omit insulin treatment of DKA.',
            'If potassium is <3.5 mmol/L, replace potassium and delay insulin until potassium is >3.5 mmol/L under the treatment protocol. Renal or cardiac compromise changes fluid and electrolyte tolerance.',
            'Routine bicarbonate is not recommended for DKA. The consensus reserves consideration for severe acidemia, pH <7.0; this is not a general intraoperative bicarbonate trigger.',
          ],
          '2024 consensus · DKA treatment and potassium',
          dkaConsensus,
          caution: true,
        ),
        AbgSection(
          'Do not confuse treatment effects with persistent DKA',
          [
            'Resolution is based on plasma ketones <0.6 mmol/L plus venous pH ≥7.3 or bicarbonate ≥18 mmol/L; ideally glucose is also <200 mg/dL.',
            'Hyperchloremic acidosis may persist after ketoacidosis improves. Do not use the anion gap or urine ketones alone to declare persistent DKA or resolution.',
            'Urine acetoacetate can rise during recovery as β-hydroxybutyrate is converted; direct blood ketone measurement better supports monitoring.',
          ],
          '2024 consensus · Resolution and treatment complications',
          dkaConsensus,
        ),
      ]),
  AbgTopic(
      'chloride',
      'Hyperchloremic acidosis after resuscitation',
      'Metabolic',
      'Distinguish a treatment-related shift from unresolved acid generation.',
      'normal gap nagma saline balanced crystalloid ileostomy diarrhea acetazolamide renal tubular',
      [
        AbgSection(
          'Differential and identifying context',
          [
            'A normal-gap acidosis may reflect chloride-rich resuscitation, GI bicarbonate loss, renal tubular dysfunction or acetazolamide exposure.',
            'The relevant physiochemical change is chloride relative to sodium, not chloride viewed alone. Hypoalbuminemia and other concurrent processes can further obscure the pattern.',
            'Compare current electrolytes with pre-resuscitation values and cumulative fluids. Check lactate and ketones when indicated rather than assuming all residual acidosis is chloride-related.',
          ],
          'BJA Education · Chloride-associated acidosis',
          acidosisReview,
        ),
        AbgSection(
          'Fluid and organ-support implications',
          [
            'Reassess the need for further fluid and its composition. Reduce unnecessary chloride loading and use an appropriate replacement strategy for the actual losses and volume state.',
            'Balanced crystalloids may reduce treatment-related hyperchloremia, but selection still depends on the clinical setting; this is not a universal fluid prescription.',
            'True bicarbonate-losing states may warrant replacement. Persistent severe acidosis with renal dysfunction requires an individualized organ-support assessment.',
            'Do not chase base deficit with repeated 0.9% saline when the fluid itself is contributing to the disturbance.',
          ],
          'BJA Education · Fluid-related acid–base management',
          acidosisReview,
          caution: true,
        ),
        AbgSection(
          'DKA recovery',
          [
            'Loss of keto-anions and chloride-containing fluids can create a normal-gap acidosis during DKA treatment.',
            'Use direct ketone and acid–base resolution criteria rather than extending insulin solely because a treatment-related gap pattern or bicarbonate abnormality persists.',
          ],
          '2024 consensus · Hyperchloremic recovery phase',
          dkaConsensus,
        ),
      ]),
  AbgTopic(
    'alkalosis',
    'Metabolic alkalosis: chloride, potassium & volume state',
    'Metabolic',
    'Choose the response by mechanism, not bicarbonate alone.',
    'urine chloride ng suction vomiting diuretics contraction acetazolamide mineralocorticoid',
    [
      AbgSection(
        'Mechanism-directed assessment',
        [
          'Review vomiting or NG suction, loop/thiazide exposure, potassium and magnesium, intravascular volume, blood pressure, chronic hypercapnia and recent alkali or precursor administration.',
          'When the cause is unclear and renal function permits interpretation, urine chloride <20 mEq/L supports chloride responsiveness; >20 mEq/L suggests chloride unresponsiveness.',
          'Interpret urine electrolytes with the diuretic and replacement history. Diuretic-associated alkalosis and potassium depletion can produce overlapping patterns; urine electrolyte values are not diagnostic in stage 4–5 CKD.',
        ],
        'Merck Manual · Metabolic alkalosis',
        alkalosisSource,
      ),
      AbgSection(
        'Management considerations',
        [
          'For a chloride-depleted, volume-contracted patient who can tolerate fluid, chloride-containing replacement and potassium correction address the sustaining mechanisms.',
          'Do not automatically give saline to a volume-overloaded patient. Address diuretics, potassium/magnesium deficits and mineralocorticoid causes according to the volume and renal assessment.',
          'Acetazolamide may help selected volume-overloaded or diuretic-associated cases, but can worsen potassium and phosphate losses. It is not a substitute for correcting the cause.',
          'Severe or refractory alkalemia with renal dysfunction or volume overload warrants critical-care/nephrology assessment; extracorporeal correction may be considered. Concentrated acid therapy is not a routine bedside response.',
        ],
        'Merck Manual · Mechanism-specific treatment',
        alkalosisSource,
        caution: true,
      ),
      AbgSection(
        'Anesthesia implications',
        [
          'Consider reduced ionized calcium, potassium-related arrhythmia risk, vasoconstriction and neuromuscular effects. Measure relevant electrolytes rather than inferring them from pH.',
          'A compensatory PaCO₂ rise may worsen oxygenation; pulmonary disease can also limit compensation. Assess respiratory status separately.',
          'Hypoalbuminemic alkalinization can coexist with lactate or other acid loads. A near-normal pH does not settle the underlying risk.',
        ],
        'BJA Education · Metabolic alkalosis and mixed disorders',
        alkalosisReview,
      ),
    ],
    differential: [
      AbgDifferential(
        'Gastric loss / chloride depletion',
        'Vomiting, NG losses, contraction and often potassium depletion.',
        'Replace deficits according to volume tolerance; assess ongoing losses.',
        'Merck Manual · Alkalosis',
        alkalosisSource,
      ),
      AbgDifferential(
        'Diuretic / mineralocorticoid effects',
        'Diuretic exposure or hypertension with renal potassium wasting; volume state varies.',
        'Review drug timing, potassium/magnesium and endocrine context before choosing fluid.',
        'Merck Manual · Alkalosis',
        alkalosisSource,
      ),
      AbgDifferential(
        'Posthypercapnic / alkali-related',
        'PaCO₂ reduced rapidly after chronic retention, or bicarbonate/precursor load.',
        'Compare prior gases and therapy; avoid correcting one number in isolation.',
        'BJA Education · Mixed disorders',
        alkalosisReview,
      ),
    ],
  ),
  AbgTopic(
    'hypercapnia',
    'Acute hypercapnia during anesthesia or recovery',
    'Ventilation',
    'Separate inadequate ventilation, dead space and chronic retention.',
    'respiratory acidosis etco2 paco2 copd obesity neuromuscular opioid reversal',
    [
      AbgSection(
        'Clinical assessment',
        [
          'Review actual delivered ventilation, airway mechanics, anesthetic/sedative exposure and residual neuromuscular impairment. Pre-existing COPD, obesity hypoventilation or neuromuscular weakness changes the baseline.',
          'Compare current PaCO₂ and bicarbonate with prior values. An elevated bicarbonate may represent chronic adaptation, but does not exclude an acute deterioration.',
          'A low or apparently satisfactory EtCO₂ does not exclude arterial hypercapnia when dead space or perfusion changes widen the gradient.',
        ],
        'OpenAnesthesia · Perioperative respiratory disorders',
        respiratorySource,
      ),
      AbgSection(
        'Ventilation and hemodynamic trade-offs',
        [
          'Treat the cause and provide ventilatory support when needed. Review avoidable apparatus dead space and the delivered respiratory rate and tidal volume.',
          'Increase effective alveolar ventilation when appropriate without abandoning lung-protective constraints. A compensation equation is not a ventilator prescription.',
          'Hypercapnia can increase cerebral blood flow/intracranial pressure and pulmonary vascular tone. Consider cerebral and right-heart tolerance when accepting permissive hypercapnia.',
          'During recovery, assess ongoing opioid/sedative effect, weakness and adequacy of ventilation; oxygenation and CO₂ clearance remain separate assessments.',
        ],
        'OpenAnesthesia · Respiratory acidosis management',
        respiratorySource,
        caution: true,
      ),
      AbgSection(
        'EtCO₂–PaCO₂ discordance',
        [
          'Reduced cardiac output or pulmonary vascular obstruction can reduce exhaled CO₂ delivery while increasing dead-space effects.',
          'Correlate the capnogram and hemodynamic change with an arterial gas when arterial CO₂ matters. Do not use a fixed subtraction or addition to estimate PaCO₂.',
        ],
        'OpenAnesthesia · Capnography (PDF)',
        capnographySource,
      ),
    ],
    differential: [
      AbgDifferential(
        'Reduced effective ventilation',
        'Anesthetic depression, residual weakness, impaired mechanics or insufficient delivered ventilation.',
        'Assess the airway and ventilatory support; address the reversible cause.',
        'OpenAnesthesia · Respiratory disorders',
        respiratorySource,
      ),
      AbgDifferential(
        'Dead-space / perfusion change',
        'EtCO₂ falls or separates from PaCO₂; low output or pulmonary vascular obstruction is possible.',
        'Assess hemodynamics and dead space; confirm arterial CO₂ rather than relying on the end-tidal value.',
        'OpenAnesthesia · Capnography',
        capnographySource,
      ),
      AbgDifferential(
        'Acute-on-chronic retention',
        'Prior hypercapnia/high bicarbonate with a new respiratory insult.',
        'Use the prior gas and current physiology, not an automatic normal-PaCO₂ target.',
        'BJA Education · Posthypercapnic disturbances',
        alkalosisReview,
      ),
    ],
  ),
  AbgTopic(
      'hypocapnia',
      'Unexpected hypocapnia or alkalemia',
      'Ventilation',
      'Do not suppress a necessary compensatory respiratory response.',
      'respiratory alkalosis hyperventilation sepsis pain hypoxemia salicylate',
      [
        AbgSection(
          'Distinguish the reason for low PaCO₂',
          [
            'Consider excessive delivered ventilation, pain/inadequate analgesia, hypoxemic drive, pulmonary disease and systemic illness. Pregnancy and liver disease may alter the baseline.',
            'Before reducing ventilation, compare PaCO₂ with expected compensation for any coexisting metabolic acidosis.',
            'If PaCO₂ is below the expected range for metabolic acidosis, consider an additional respiratory alkalosis rather than labeling the entire pattern “compensated.”',
          ],
          'OpenAnesthesia · Respiratory alkalosis',
          respiratorySource,
        ),
        AbgSection(
          'Management and pitfalls',
          [
            'Address the driver: ventilator delivery, pain, hypoxemia or the underlying disease. Reducing respiratory drive without understanding its purpose can worsen a metabolic disturbance.',
            'Alkalemia can reduce ionized calcium and contribute to vasoconstriction, arrhythmia and neuromuscular symptoms. Reassess electrolytes when clinically indicated.',
            'A mixed respiratory alkalosis and metabolic acidosis warrants an etiologic assessment; the net pH may conceal both processes.',
          ],
          'Merck Manual · Mixed acid–base disorders',
          acidBaseSource,
          caution: true,
        ),
      ]),
  AbgTopic(
      'induction',
      'Severe metabolic acidosis at induction',
      'Ventilation',
      'Anticipate the consequences of losing spontaneous compensation.',
      'apnea intubation high minute ventilation dka salicylate collapse', [
    AbgSection(
      'Physiologic risk',
      [
        'Patients with severe metabolic acidosis may sustain unusually high spontaneous minute ventilation. A short apneic interval can rapidly increase PaCO₂ and worsen acidemia.',
        'The required compensatory ventilation may be difficult to reproduce after intubation. Hemodynamic deterioration can reflect both induction effects and the abrupt loss of compensation.',
        'DKA, severe lactic acidosis and salicylate toxicity are important contexts. The same airway technique may have very different physiologic consequences across these patients.',
      ],
      'Mosier et al. · Physiologically difficult airway',
      airwaySource,
      caution: true,
    ),
    AbgSection(
      'Peri-induction considerations',
      [
        'When circumstances permit, establish the current gas, spontaneous ventilatory demand and circulatory state before intervention; plan how compensation and perfusion will be maintained.',
        'Minimize avoidable loss of ventilation within an individualized airway strategy. The urgency of airway protection and oxygenation still governs the decision.',
        'After airway control, reassess effective ventilation, PaCO₂/pH and hemodynamics promptly. Do not use PaCO₂ 40 mmHg as a universal target in severe metabolic acidosis.',
        'This is physiology-based planning, not a blanket recommendation for a particular induction drug, airway technique or oversized tidal volume.',
      ],
      'Mosier et al. · Peri-intubation considerations',
      airwaySource,
    ),
  ]),
  AbgTopic(
      'mixed',
      'Mixed disorders hidden by a near-normal pH',
      'Mixed states',
      'Use baseline, albumin and compensation to expose competing processes.',
      'delta gap albumin hypoalbuminemia high gap normal ph strong ion base excess',
      [
        AbgSection(
          'High-yield combinations',
          [
            'Lactate or ketoacids plus vomiting/NG losses or diuretic-associated alkalosis can partially offset in the net pH.',
            'Hypoalbuminemia lowers the expected anion gap and has an alkalinizing effect; concurrent chloride loading or unmeasured anions can be obscured.',
            'Sepsis or other respiratory stimulation can accompany metabolic acidosis. Additional respiratory alkalosis is determined by departure from expected compensation, not simply by low PaCO₂.',
            'Chronic CO₂ retention plus a new metabolic acidosis can produce a misleading bicarbonate value. Compare with the patient’s prior gas, not only a population reference interval.',
          ],
          'BJA Education · Mixed acid–base disturbance',
          alkalosisReview,
        ),
        AbgSection(
          'Interpretation that changes the assessment',
          [
            'Use contemporaneous electrolytes and albumin to interpret the gap, then assess respiratory compensation. The delta-gap cross-check may reveal a concurrent metabolic alkalosis.',
            'Avoid treating base excess as a mechanism-specific measurement. Chloride, albumin and unmeasured anions can move it in opposing directions.',
            'The traditional gap approach and a strong-ion framework are complementary. Neither removes the need to measure relevant lactate/ketones and reconcile the operative history.',
          ],
          'BJA Education · Integrated interpretation',
          acidosisReview,
        ),
        AbgSection(
          'Management pitfall',
          [
            'Correcting one process may unmask the other. Reassess after changes in ventilation, perfusion, chloride delivery or gastric losses instead of assuming that an initially normal pH confers stability.',
            'Do not use a single delta ratio or compensation rule to override evolving physiology, baseline disease or a discordant specimen.',
          ],
          'BJA Education · Mixed disorders and treatment effects',
          alkalosisReview,
          caution: true,
        ),
      ]),
  AbgTopic(
      'posthypercapnic',
      'Posthypercapnic & alkali-related alkalosis',
      'Mixed states',
      'Recognize why pH may rise after ventilation or treatment improves.',
      'chronic copd bicarbonate acetate citrate renal replacement transfusion',
      [
        AbgSection(
          'Posthypercapnic pattern',
          [
            'When PaCO₂ falls rapidly after chronic retention, the renal adaptation does not immediately reverse. Significant metabolic alkalosis may become evident after mechanical ventilation is started.',
            'Compare the previous PaCO₂/HCO₃⁻ with the current gas and assess chloride, potassium, volume state and concurrent diuretics.',
            'Avoid a reflex normal-PaCO₂ target without considering the resulting pH and clinical context. This does not mean tolerating an acutely unsafe ventilation or oxygenation state.',
          ],
          'BJA Education · Posthypercapnic alkalosis',
          alkalosisReview,
        ),
        AbgSection(
          'Exogenous alkali and precursors',
          [
            'Review bicarbonate administration and metabolizable anions such as citrate or acetate. Their effect depends on metabolism and accompanying strong ions.',
            'With citrate-based renal replacement, successful citrate metabolism can contribute to alkalosis; impaired metabolism can instead cause citrate accumulation and acidosis.',
            'Do not assume all citrate exposure has the same acid–base effect. Follow the relevant organ-support protocol and clinical/laboratory context.',
          ],
          'BJA Education · Exogenous anions and citrate metabolism',
          alkalosisReview,
        ),
        AbgSection(
          'Treatment limits',
          [
            'Correct contributing chloride/potassium deficits and reassess diuretic or alkali exposure according to volume status.',
            'Acetazolamide can improve selected alkalosis patterns, but biochemical improvement should not be represented as a proven reduction in ventilation duration.',
          ],
          'BJA Education · Alkalosis therapy and trial limitations',
          alkalosisReview,
        ),
      ]),
  AbgTopic(
      'bicarbonate',
      'Bicarbonate: indication, limitations & current evidence',
      'Treatment decisions',
      'Separate cause-specific use from routine pH normalization.',
      'sodium bicarbonate bicaricu soda bic aki dialysis renal replacement buffering',
      [
        AbgSection(
          'Define the reason before giving buffer',
          [
            'Prioritize correction of the cause. Bicarbonate-losing states and selected toxicologic indications differ from empiric buffering of lactic acidosis; use the appropriate disease-specific protocol.',
            'Consider the ability to eliminate the CO₂ generated by buffering. Inadequate ventilation can negate the intended benefit and worsen the respiratory component.',
            'Assess sodium and volume tolerance, potassium and ionized calcium. Hypernatremia, hypokalemia and hypocalcemia are relevant risks.',
            'A rise in pH does not establish improved perfusion, kidney recovery or survival. Refractory acidemia may require broader organ support.',
          ],
          'BJA Education · Bicarbonate physiology and limitations',
          acidosisReview,
          caution: true,
        ),
        AbgSection(
          'CO₂ generation is clinically relevant',
          [
            'Bicarbonate increases CO₂ generation through the carbonic-acid equilibrium. If CO₂ cannot be excreted, the acid–base response may be unfavorable.',
            'Reassess ventilation and the whole gas rather than responding to a low bicarbonate concentration in isolation.',
          ],
          'BJA Education · Buffering and ventilation',
          alkalosisReview,
        ),
        AbgSection(
          'BICARICU-2 · 2025',
          [
            'In critically ill adults with pH ≤7.20 and moderate-to-severe AKI, bicarbonate did not reduce 90-day mortality: 62.1% versus 61.7%.',
            'Kidney replacement therapy was used less often (35% versus 50%), a secondary outcome. This must not be described as a demonstrated survival benefit.',
            'The selected ICU population and open-label design limit extrapolation to every intraoperative acidosis or to respiratory acidosis.',
          ],
          'JAMA · BICARICU-2 primary trial',
          'https://pubmed.ncbi.nlm.nih.gov/41159812/',
        ),
        AbgSection(
          'SODa-BIC · 2026',
          [
            'In vasopressor-treated ICU adults with metabolic acidosis (pH <7.30, base excess ≤−4 mmol/L and prespecified PaCO₂ limits), bicarbonate did not reduce major adverse kidney events by 30 days versus placebo.',
            'The primary outcome occurred in 40.2% versus 39.4% (P=0.78). Biochemical correction should not be equated with demonstrated patient-centered benefit.',
            'These findings address the studied ICU strategy, not every rescue situation or a separate disease-specific indication.',
          ],
          'NEJM · SODa-BIC primary trial (2026)',
          'https://pubmed.ncbi.nlm.nih.gov/42283370/',
        ),
      ]),
  AbgTopic(
      'discordance',
      'Discordant gas, chemistry or capnography',
      'Measurement pitfalls',
      'Resolve method and sampling problems before treating an artifact.',
      'vbg abg total co2 hco3 contamination line flush heparin air bubble sample delay pao2 fio2',
      [
        AbgSection(
          'ABG versus chemistry',
          [
            'Gas bicarbonate is calculated from pH and PaCO₂; chemistry total CO₂/bicarbonate is measured separately. Compare collection times, specimen origin and clinical changes before interpreting the difference.',
            'Use a coherent electrolyte panel for the anion gap. A gas and electrolyte sample taken before and after a major intervention may not describe one physiologic state.',
            'An internally inconsistent or clinically implausible result warrants laboratory discussion and a properly collected repeat, without delaying treatment of genuine instability.',
          ],
          'Merck Manual · Acid–base evaluation',
          acidBaseSource,
        ),
        AbgSection(
          'Collection artifacts',
          [
            'Arterial-line flush contamination and excess liquid heparin can dilute the specimen. Air exposure shifts oxygen toward ambient levels and can lower CO₂ with a pH rise.',
            'Delayed processing permits cellular metabolism, with oxygen consumption and acid generation. Marked leukocytosis/thrombocytosis can accentuate spurious oxygen reduction.',
            'Document arterial/venous origin, collection time, FiO₂ and ventilator settings; follow local specimen handling and transport requirements.',
          ],
          'Baird · Preanalytical blood gas considerations',
          sampleSource,
        ),
        AbgSection(
          'VBG and oxygenation limits',
          [
            'Venous pH and bicarbonate are useful in selected contexts, but venous PCO₂ cannot be converted to PaCO₂ with a universal correction.',
            'Venous PO₂ cannot replace PaO₂. When the decision requires precise arterial ventilation or oxygenation, use an appropriate arterial assessment.',
            'Supplemental oxygen and a satisfactory saturation do not establish adequate CO₂ clearance; interpret oxygenation and ventilation separately.',
          ],
          'Giani et al. · Blood gas review (2025)',
          gasComparisonSource,
        ),
        AbgSection(
          'End-tidal mismatch',
          [
            'A changing PaCO₂–EtCO₂ gradient may reflect altered dead space or perfusion, not merely a need to turn up ventilation.',
            'Assess the waveform, hemodynamics and arterial gas together. Avoid a fixed assumed gradient during changing physiology.',
          ],
          'OpenAnesthesia · Capnography reference (PDF)',
          capnographySource,
        ),
      ]),
];

final abgGroups = <String>['All', ...abgTopics.map((t) => t.group).toSet()];

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
        for (final row in topic.differential) ...[
          row.process,
          row.clues,
          row.focus,
        ],
      ].join(' '),
    );
    return words.every(haystack.contains);
  }).toList();
}
