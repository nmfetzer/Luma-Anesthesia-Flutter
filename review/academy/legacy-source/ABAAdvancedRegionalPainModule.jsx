import React, { useState } from 'react';
import { ChevronDown, ChevronUp } from 'lucide-react';

export default function ABAAdvancedRegionalPainModule() {
  const [expandedSections, setExpandedSections] = useState({
    la: false,
    neuraxial: false,
    upper: false,
    lower: false,
    truncal: false,
    asra: false,
    acute: false,
    chronic: false,
    practice: false,
  });

  const toggle = (key) => setExpandedSections((prev) => ({ ...prev, [key]: !prev[key] }));

  return (
    <div className="space-y-3">

      {/* 1. Local Anesthetic Pharmacology */}
      <div className="rounded-2xl border border-sky-200 bg-card overflow-hidden">
        <button onClick={() => toggle('la')} className="w-full flex items-center gap-3 p-4 text-left hover:bg-sky-50 active:scale-[0.99] transition-all">
          <span className="text-xl">💊</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">1. Local Anesthetic Pharmacology &amp; LAST</p>
            <p className="text-xs text-muted-foreground mt-0.5">Mechanism, fiber order, max doses, LAST treatment</p>
          </div>
          {expandedSections.la ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.la && (
          <div className="border-t border-sky-100 p-4 bg-sky-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-sky-700 mb-1.5">Mechanism &amp; Classification</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Bind Na+ channels on cytoplasmic side; un-ionized form penetrates membrane, ionized form binds channel</li>
                <li>• Order of blockade: B fibers (sympathetic) → C &amp; A-δ (pain, temp) → A-γ (motor tone) → A-β (touch, pressure) → A-α (motor, proprioception)</li>
                <li>• Amides (lidocaine, bupivacaine, ropivacaine, mepivacaine): hepatic metabolism</li>
                <li>• Esters (procaine, chloroprocaine, tetracaine): plasma esterase; PABA metabolite → allergic reactions</li>
                <li>• Max doses: Lidocaine 4.5 mg/kg (7 with epi); bupivacaine 2 mg/kg (3 with epi); ropivacaine 3 mg/kg</li>
              </ul>
            </div>
            <div>
              <p className="font-bold text-sky-700 mb-1.5">LAST — Local Anesthetic Systemic Toxicity</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Early CNS: tinnitus, perioral numbness, metallic taste, lightheadedness</li>
                <li>• Progresses: muscle twitching, tonic-clonic seizures, unconsciousness</li>
                <li>• CV: HTN/tachycardia first → hypotension, bradycardia, conduction block, refractory arrest (bupivacaine)</li>
                <li>• Treatment: stop injection, airway, 100% O₂, seizure control (benzo), 20% lipid emulsion 1.5 mL/kg bolus → 0.25 mL/kg/min (up to 12 mL/kg total)</li>
                <li>• AVOID: vasopressin, β-blockers, Ca++ channel blockers, large epi doses; use epi ≤1 mcg/kg only</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* 2. Spinal and Epidural */}
      <div className="rounded-2xl border border-teal-200 bg-card overflow-hidden">
        <button onClick={() => toggle('neuraxial')} className="w-full flex items-center gap-3 p-4 text-left hover:bg-teal-50 active:scale-[0.99] transition-all">
          <span className="text-xl">🦴</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">2. Spinal &amp; Epidural Anesthesia</p>
            <p className="text-xs text-muted-foreground mt-0.5">Landmarks, baricity, complications, blood patch</p>
          </div>
          {expandedSections.neuraxial ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.neuraxial && (
          <div className="border-t border-teal-100 p-4 bg-teal-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-teal-700 mb-1.5">Technique</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Spinal needle below L1 (adult conus); typically L3-4 or L4-5 interspace</li>
                <li>• Tuffier's line (top of iliac crests) ≈ L4 spinous process</li>
                <li>• Spread depends on dose, baricity, height/position, injection site</li>
                <li>• Cold sensation (ice/alcohol) most sensitive level test (~2 dermatomes higher than pinprick)</li>
              </ul>
            </div>
            <div>
              <p className="font-bold text-teal-700 mb-1.5">Complications</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Hypotension/bradycardia: high sympathetic block → fluid, vasopressor, atropine</li>
                <li>• Total spinal: apnea, hypotension, unconsciousness → supportive</li>
                <li>• PDPH: postural frontal/occipital HA 12–72 h after; treat with rest, hydration, caffeine, sphenopalatine block, epidural blood patch (15–20 mL)</li>
                <li>• Spinal hematoma: emergency; neurosurgical decompression within 8 hours</li>
                <li>• TNS/cauda equina: historically with 5% lidocaine; avoid hyperbaric lidocaine</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* 3. Upper Extremity Blocks */}
      <div className="rounded-2xl border border-purple-200 bg-card overflow-hidden">
        <button onClick={() => toggle('upper')} className="w-full flex items-center gap-3 p-4 text-left hover:bg-purple-50 active:scale-[0.99] transition-all">
          <span className="text-xl">💪</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">3. Upper Extremity Blocks</p>
            <p className="text-xs text-muted-foreground mt-0.5">Interscalene, supraclavicular, infraclavicular, axillary</p>
          </div>
          {expandedSections.upper ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.upper && (
          <div className="border-t border-purple-100 p-4 bg-purple-50 space-y-3 text-sm">
            <ul className="space-y-2 text-muted-foreground text-xs">
              <li><span className="font-semibold text-purple-700">Interscalene (C5–C7):</span> Shoulder/proximal humerus. Phrenic paresis ~100% — avoid in contralateral pulmonary disease. Risks: Horner's, RLN, epidural/intrathecal spread, vertebral artery.</li>
              <li><span className="font-semibold text-purple-700">Supraclavicular:</span> 'Spinal of the arm' — entire brachial plexus. Risk of pneumothorax; US has reduced complications.</li>
              <li><span className="font-semibold text-purple-700">Infraclavicular:</span> Reliable; less phrenic involvement; useful for catheter techniques.</li>
              <li><span className="font-semibold text-purple-700">Axillary:</span> Safest for pulmonary patients. Misses musculocutaneous — block separately in coracobrachialis.</li>
            </ul>
          </div>
        )}
      </div>

      {/* 4. Lower Extremity Blocks */}
      <div className="rounded-2xl border border-red-200 bg-card overflow-hidden">
        <button onClick={() => toggle('lower')} className="w-full flex items-center gap-3 p-4 text-left hover:bg-red-50 active:scale-[0.99] transition-all">
          <span className="text-xl">🦵</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">4. Lower Extremity Blocks</p>
            <p className="text-xs text-muted-foreground mt-0.5">Femoral, adductor canal, sciatic, IPACK, ankle</p>
          </div>
          {expandedSections.lower ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.lower && (
          <div className="border-t border-red-100 p-4 bg-red-50 space-y-3 text-sm">
            <ul className="space-y-2 text-muted-foreground text-xs">
              <li><span className="font-semibold text-red-700">Femoral:</span> Anterior thigh, knee. Dense quadriceps block (fall risk). Often replaced by adductor canal for TKA.</li>
              <li><span className="font-semibold text-red-700">Adductor Canal:</span> Saphenous + nerve to vastus medialis; spares quadriceps — preferred for postoperative TKA.</li>
              <li><span className="font-semibold text-red-700">Sciatic (subgluteal, popliteal):</span> Posterior thigh, leg, foot. Popliteal block above bifurcation → tibial + common peroneal.</li>
              <li><span className="font-semibold text-red-700">IPACK:</span> Posterior knee analgesia for TKA without motor block.</li>
              <li><span className="font-semibold text-red-700">Ankle block:</span> 5 nerves (post tibial, sural, saphenous, deep peroneal, superficial peroneal). Avoid epi to terminal vessels.</li>
            </ul>
          </div>
        )}
      </div>

      {/* 5. Truncal Blocks */}
      <div className="rounded-2xl border border-orange-200 bg-card overflow-hidden">
        <button onClick={() => toggle('truncal')} className="w-full flex items-center gap-3 p-4 text-left hover:bg-orange-50 active:scale-[0.99] transition-all">
          <span className="text-xl">🫁</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">5. Truncal Blocks</p>
            <p className="text-xs text-muted-foreground mt-0.5">TAP, ESP, PECS, QL, rectus sheath</p>
          </div>
          {expandedSections.truncal ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.truncal && (
          <div className="border-t border-orange-100 p-4 bg-orange-50 space-y-3 text-sm">
            <ul className="space-y-2 text-muted-foreground text-xs">
              <li><span className="font-semibold text-orange-700">TAP (T10–L1):</span> Somatic coverage for lower abdominal incisions; does NOT cover visceral pain. Bilateral for midline.</li>
              <li><span className="font-semibold text-orange-700">Rectus sheath:</span> Periumbilical incisions; covers T9–T11 anterior cutaneous branches.</li>
              <li><span className="font-semibold text-orange-700">ESP (Erector Spinae Plane):</span> Single injection at paravertebral level; broad coverage (thoracic, abdominal, hip). Safer alternative to paravertebral.</li>
              <li><span className="font-semibold text-orange-700">Quadratus Lumborum:</span> Hip and abdominal surgery; thought to spread to paravertebral space.</li>
              <li><span className="font-semibold text-orange-700">PECS I/II:</span> Breast and chest wall surgery.</li>
            </ul>
          </div>
        )}
      </div>

      {/* 6. ASRA Anticoagulation Guidelines */}
      <div className="rounded-2xl border border-yellow-200 bg-card overflow-hidden">
        <button onClick={() => toggle('asra')} className="w-full flex items-center gap-3 p-4 text-left hover:bg-yellow-50 active:scale-[0.99] transition-all">
          <span className="text-xl">📋</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">6. ASRA Anticoagulation Guidelines (4th ed.)</p>
            <p className="text-xs text-muted-foreground mt-0.5">Hold times for all anticoagulant classes</p>
          </div>
          {expandedSections.asra ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.asra && (
          <div className="border-t border-yellow-100 p-4 bg-yellow-50 space-y-3 text-sm">
            <ul className="space-y-1 text-muted-foreground text-xs">
              <li>• <span className="font-semibold">Aspirin / NSAIDs:</span> No restriction</li>
              <li>• <span className="font-semibold">Clopidogrel:</span> 5–7 days; Prasugrel: 7–10 days; Ticagrelor: 5–7 days</li>
              <li>• <span className="font-semibold">UFH prophylactic BID:</span> No delay; TID: delay 4–6 h, check aPTT</li>
              <li>• <span className="font-semibold">UFH therapeutic IV:</span> Discontinue 4–6 h before; verify normal aPTT</li>
              <li>• <span className="font-semibold">LMWH prophylactic:</span> 12 h hold; restart ≥12 h after procedure</li>
              <li>• <span className="font-semibold">LMWH therapeutic:</span> 24 h hold; restart 24 h after catheter removal</li>
              <li>• <span className="font-semibold">Warfarin:</span> INR ≤1.4</li>
              <li>• <span className="font-semibold">DOACs:</span> Apixaban/rivaroxaban 72 h; dabigatran 72–120 h (renal-dependent)</li>
              <li>• <span className="font-semibold">Fondaparinux:</span> 36–42 h prophylactic; avoid neuraxial if therapeutic</li>
              <li>• <span className="font-semibold">Thrombolytics:</span> Avoid neuraxial 48 h pre- and post-administration</li>
            </ul>
          </div>
        )}
      </div>

      {/* 7. Acute Pain & Multimodal Analgesia */}
      <div className="rounded-2xl border border-green-200 bg-card overflow-hidden">
        <button onClick={() => toggle('acute')} className="w-full flex items-center gap-3 p-4 text-left hover:bg-green-50 active:scale-[0.99] transition-all">
          <span className="text-xl">⚕️</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">7. Acute Pain &amp; Multimodal Analgesia</p>
            <p className="text-xs text-muted-foreground mt-0.5">APAP, NSAIDs, ketamine, lidocaine infusion, gabapentinoids</p>
          </div>
          {expandedSections.acute ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.acute && (
          <div className="border-t border-green-100 p-4 bg-green-50 space-y-3 text-sm">
            <p className="text-xs text-muted-foreground">Combine acetaminophen, NSAIDs/COX-2, regional/neuraxial, titrated opioids, and adjuncts to reduce opioid consumption and chronic post-surgical pain risk.</p>
            <ul className="space-y-1 text-muted-foreground text-xs">
              <li>• Acetaminophen 1 g IV/PO q6h (max 4 g/24h; 3 g in elderly/hepatic)</li>
              <li>• Ketorolac 15–30 mg IV q6h (max 5 days; caution: renal, bleeding, elderly)</li>
              <li>• Gabapentinoids: reduce opioid use but sedation/respiratory depression risk — selective use</li>
              <li>• Ketamine 0.1–0.3 mg/kg bolus, infusion 0.1–0.3 mg/kg/h reduces opioid use &amp; chronic pain risk</li>
              <li>• Lidocaine infusion 1–2 mg/kg/h reduces opioid requirements in abdominal surgery</li>
            </ul>
          </div>
        )}
      </div>

      {/* 8. Chronic Pain */}
      <div className="rounded-2xl border border-pink-200 bg-card overflow-hidden">
        <button onClick={() => toggle('chronic')} className="w-full flex items-center gap-3 p-4 text-left hover:bg-pink-50 active:scale-[0.99] transition-all">
          <span className="text-xl">🔄</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">8. Chronic Pain</p>
            <p className="text-xs text-muted-foreground mt-0.5">Low back, neuropathic, CRPS, cancer, opioid prescribing</p>
          </div>
          {expandedSections.chronic ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.chronic && (
          <div className="border-t border-pink-100 p-4 bg-pink-50 space-y-3 text-sm">
            <ul className="space-y-2 text-muted-foreground text-xs">
              <li><span className="font-semibold text-pink-700">Low Back Pain:</span> Mostly non-specific. Conservative first; epidural steroids for radiculopathy (short-term). Facet injections/RFA for facet pain. SCS for failed back syndrome.</li>
              <li><span className="font-semibold text-pink-700">Neuropathic Pain:</span> First-line: gabapentinoids, TCAs, SNRIs (duloxetine). Topical lidocaine/capsaicin. Opioids second-line.</li>
              <li><span className="font-semibold text-pink-700">Cancer Pain:</span> WHO ladder. Celiac plexus block for pancreatic, hypogastric for pelvic cancer pain.</li>
              <li><span className="font-semibold text-pink-700">CRPS:</span> Early mobilization, sympathetic blocks, physical therapy, multimodal medications.</li>
              <li><span className="font-semibold text-pink-700">Opioid Prescribing (CDC 2022):</span> Lowest effective dose, immediate-release initially, PDMP monitoring, ORT/SOAPP-R tools, screen for OUD, naloxone co-prescribing for high-risk patients.</li>
            </ul>
          </div>
        )}
      </div>

      {/* Practice Questions */}
      <div className="rounded-2xl border border-blue-200 bg-card overflow-hidden">
        <button onClick={() => toggle('practice')} className="w-full flex items-center gap-3 p-4 text-left hover:bg-blue-50 active:scale-[0.99] transition-all">
          <span className="text-xl">📝</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">Practice Questions</p>
            <p className="text-xs text-muted-foreground mt-0.5">45 high-yield regional anesthesia &amp; pain medicine items</p>
          </div>
          {expandedSections.practice ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.practice && (
          <div className="border-t border-blue-100 p-4 bg-blue-50 space-y-3 text-xs">
            <div className="bg-card rounded-lg p-3 border border-blue-100">
              <p className="font-semibold text-blue-700 mb-1">Coverage Areas</p>
              <p className="text-muted-foreground">LAST treatment (lipid emulsion dosing, agents to avoid), max LA doses, ASRA hold times for all anticoagulant classes, epidural test dose, nerve fiber blockade order, interscalene phrenic paresis, adductor canal vs femoral block, truncal block anatomy, PDPH management, neuraxial complications, spinal spread modifiers, OLV in thoracic surgery, high spinal management, chronic opioid perioperative management, neuropathic pain first-line agents, CRPS diagnosis, cancer pain interventions, block adjuvants, ankle block nerve anatomy, failed block causes.</p>
            </div>
            <div className="bg-card rounded-lg p-3 border border-blue-100">
              <p className="font-semibold text-blue-700 mb-1">Key High-Yield Topics</p>
              <ul className="space-y-1 text-muted-foreground">
                <li>• LAST: 20% lipid emulsion 1.5 mL/kg bolus → 0.25 mL/kg/min; avoid vasopressin, β-blockers, Ca++ blockers</li>
                <li>• Interscalene: 100% phrenic paresis — avoid if contralateral pulmonary disease</li>
                <li>• Adductor canal block: preferred TKA analgesia (spares quadriceps motor)</li>
                <li>• Clopidogrel: 5–7 days; LMWH prophylactic: 12 h hold; therapeutic: 24 h hold</li>
                <li>• PDPH blood patch: 15–20 mL autologous blood; 70–90% success rate</li>
                <li>• Cold sensation 2 dermatomes higher than pinprick for spinal level testing</li>
                <li>• Intrathecal morphine 100–150 mcg for cesarean postop analgesia</li>
                <li>• ESP injection: deep to erector spinae at transverse process → spreads to paravertebral space</li>
                <li>• Deep peroneal nerve → first web space of foot</li>
                <li>• Chronic opioid patients: continue baseline opioids, add multimodal (never abrupt withdrawal)</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* Study Tips */}
      <div className="p-4 rounded-2xl bg-emerald-50 border border-emerald-200">
        <p className="text-xs font-bold text-emerald-700 mb-2">💡 Study Strategy</p>
        <ul className="space-y-1 text-xs text-muted-foreground">
          <li>• Memorize ASRA hold times for every anticoagulant class</li>
          <li>• Master LAST recognition and lipid emulsion protocol</li>
          <li>• Know which block for each surgery (adductor canal for TKA, PECS for breast, etc.)</li>
          <li>• Understand differential benefits of spinal vs epidural for each patient scenario</li>
          <li>• Practice all 45 questions before final ABA ADVANCED exam</li>
        </ul>
      </div>
    </div>
  );
}