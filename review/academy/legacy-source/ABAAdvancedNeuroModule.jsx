import React, { useState } from 'react';
import { ChevronDown, ChevronUp } from 'lucide-react';

export default function ABAAdvancedNeuroModule() {
  const [expandedSections, setExpandedSections] = useState({
    cerebral: false,
    icp: false,
    pharmacology: false,
    craniotomy: false,
    tbi: false,
    aneurysm: false,
    awake: false,
    spine: false,
    posterior: false,
    practice: false,
  });

  const toggleSection = (key) => {
    setExpandedSections((prev) => ({ ...prev, [key]: !prev[key] }));
  };

  return (
    <div className="space-y-3">
      {/* 1. Cerebral Physiology and Blood Flow */}
      <div className="rounded-2xl border border-sky-200 bg-card overflow-hidden">
        <button
          onClick={() => toggleSection('cerebral')}
          className="w-full flex items-center gap-3 p-4 text-left hover:bg-sky-50 active:scale-[0.99] transition-all"
        >
          <span className="text-xl">🧠</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">1. Cerebral Physiology &amp; Blood Flow</p>
            <p className="text-xs text-muted-foreground mt-0.5">CBF, autoregulation, CMRO₂, CPP, CO₂ &amp; O₂ reactivity</p>
          </div>
          {expandedSections.cerebral ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.cerebral && (
          <div className="border-t border-sky-100 p-4 bg-sky-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-sky-700 mb-1.5">Core Physiology</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• CBF ~50 mL/100 g/min globally (gray matter 80, white matter 20)</li>
                <li>• CMRO₂ ~3.5 mL/100 g/min; ~60% used for synaptic activity</li>
                <li>• Cerebral perfusion pressure (CPP) = MAP − ICP (or CVP, whichever higher); target ≥60 mmHg in TBI</li>
              </ul>
            </div>
            <div>
              <p className="font-bold text-sky-700 mb-1.5">Autoregulation &amp; Reactivity</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Autoregulation maintains CBF constant over MAP ~50–150 mmHg</li>
                <li>• Shifted right in chronic HTN; lost in trauma, ischemia, vasospasm</li>
                <li>• CO₂ reactivity: CBF changes ~3% per mmHg PaCO₂ (20–80 mmHg range)</li>
                <li>• O₂ reactivity: CBF rises sharply with PaO₂ &lt;50 mmHg</li>
                <li>• Coupling: CBF normally follows CMRO₂; uncoupled by volatile anesthetics &gt;1 MAC</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* 2. Intracranial Pressure &amp; Monro-Kellie Doctrine */}
      <div className="rounded-2xl border border-teal-200 bg-card overflow-hidden">
        <button
          onClick={() => toggleSection('icp')}
          className="w-full flex items-center gap-3 p-4 text-left hover:bg-teal-50 active:scale-[0.99] transition-all"
        >
          <span className="text-xl">📊</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">2. Intracranial Pressure &amp; Monro-Kellie</p>
            <p className="text-xs text-muted-foreground mt-0.5">ICP management, osmotic therapy, CSF drainage</p>
          </div>
          {expandedSections.icp ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.icp && (
          <div className="border-t border-teal-100 p-4 bg-teal-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-teal-700 mb-1.5">Monro-Kellie Doctrine</p>
              <p className="text-xs text-muted-foreground">Fixed-volume skull contains brain, blood, CSF. Increase in any compartment compensated by CSF/venous displacement. Normal ICP ≤15 mmHg; treatment threshold &gt;20–22 mmHg.</p>
            </div>
            <div>
              <p className="font-bold text-teal-700 mb-1.5">ICP Management</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Head of bed 30°; neck neutral for jugular venous drainage</li>
                <li>• Adequate sedation, analgesia, neuromuscular blockade in refractory cases</li>
                <li>• Maintain PaCO₂ 35–40 mmHg; transient hyperventilation to 28–32 for impending herniation</li>
                <li>• Mannitol 0.25–1 g/kg IV (caution: rebound, hyperosmolality, AKI)</li>
                <li>• Hypertonic saline 3% (250–500 mL) or 23.4% (30 mL) — preferred in hypovolemic patients</li>
                <li>• CSF drainage via EVD when available</li>
                <li>• Decompressive craniectomy for refractory ICP</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* 3. Neuropharmacology */}
      <div className="rounded-2xl border border-purple-200 bg-card overflow-hidden">
        <button
          onClick={() => toggleSection('pharmacology')}
          className="w-full flex items-center gap-3 p-4 text-left hover:bg-purple-50 active:scale-[0.99] transition-all"
        >
          <span className="text-xl">💊</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">3. Neuropharmacology</p>
            <p className="text-xs text-muted-foreground mt-0.5">Effects on CMRO₂, CBF, ICP for neuro agents</p>
          </div>
          {expandedSections.pharmacology ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.pharmacology && (
          <div className="border-t border-purple-100 p-4 bg-purple-50 space-y-3 text-sm">
            <ul className="space-y-2 text-muted-foreground text-xs">
              <li><span className="font-semibold text-purple-700">Propofol:</span> ↓CMRO₂, ↓CBF, ↓ICP. Preserves autoregulation. Drug of choice for TIVA in neurosurgery.</li>
              <li><span className="font-semibold text-purple-700">Thiopental/Etomidate:</span> ↓CMRO₂ &amp; CBF; burst suppression. Useful for cerebral protection in temporary vascular occlusion.</li>
              <li><span className="font-semibold text-purple-700">Volatile Anesthetics:</span> &lt;1 MAC preserves coupling; &gt;1.5 MAC causes vasodilation with CBF/ICP rise.</li>
              <li><span className="font-semibold text-purple-700">Nitrous Oxide:</span> ↑CMRO₂, ↑CBF, ↑ICP; avoid in intracranial procedures, especially with intracranial gas.</li>
              <li><span className="font-semibold text-purple-700">Ketamine:</span> ↑CMRO₂ historically; recent data show limited ICP rise with controlled ventilation &amp; GABAergic agents. Useful in unstable trauma.</li>
              <li><span className="font-semibold text-purple-700">Opioids:</span> Minimal direct CBF/CMRO₂ effects; chest wall rigidity (remifentanil) can raise ICP indirectly.</li>
              <li><span className="font-semibold text-purple-700">Succinylcholine:</span> Transient ICP rise; rarely clinically significant; acceptable in RSI.</li>
            </ul>
          </div>
        )}
      </div>

      {/* 4. Anesthesia for Elective Craniotomy */}
      <div className="rounded-2xl border border-red-200 bg-card overflow-hidden">
        <button
          onClick={() => toggleSection('craniotomy')}
          className="w-full flex items-center gap-3 p-4 text-left hover:bg-red-50 active:scale-[0.99] transition-all"
        >
          <span className="text-xl">🏥</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">4. Anesthesia for Elective Craniotomy</p>
            <p className="text-xs text-muted-foreground mt-0.5">Goals, monitoring, brain relaxation, rapid emergence</p>
          </div>
          {expandedSections.craniotomy ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.craniotomy && (
          <div className="border-t border-red-100 p-4 bg-red-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-red-700 mb-1.5">Core Goals</p>
              <p className="text-xs text-muted-foreground">Maintain CPP, avoid hypoxia/hypercarbia, provide brain relaxation, ensure rapid emergence for neurologic exam.</p>
            </div>
            <div>
              <p className="font-bold text-red-700 mb-1.5">Technique</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Standard monitors + arterial line; CVC selectively</li>
                <li>• Avoid jugular compression with rigid head holder</li>
                <li>• Mannitol or hypertonic saline for brain relaxation</li>
                <li>• Maintain MAP at baseline; remifentanil &amp; propofol-based TIVA for smooth, rapid emergence</li>
                <li>• Extubate awake &amp; following commands for neuro exam</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* 5. Traumatic Brain Injury */}
      <div className="rounded-2xl border border-orange-200 bg-card overflow-hidden">
        <button
          onClick={() => toggleSection('tbi')}
          className="w-full flex items-center gap-3 p-4 text-left hover:bg-orange-50 active:scale-[0.99] transition-all"
        >
          <span className="text-xl">⚠️</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">5. Traumatic Brain Injury</p>
            <p className="text-xs text-muted-foreground mt-0.5">Avoid secondary injury, CPP targets, hyperosmolar therapy</p>
          </div>
          {expandedSections.tbi ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.tbi && (
          <div className="border-t border-orange-100 p-4 bg-orange-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-orange-700 mb-1.5">Avoid Secondary Injury</p>
              <p className="text-xs text-muted-foreground">Hypotension (SBP &lt;110), hypoxia (SpO₂ &lt;90), hypercapnia, hyperglycemia, fever, anemia, hyponatremia.</p>
            </div>
            <div>
              <p className="font-bold text-orange-700 mb-1.5">Management</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• CPP target 60–70 mmHg; do not exceed 70 routinely (ARDS risk)</li>
                <li>• Hyperosmolar therapy with hypertonic saline preferred in hypovolemic; mannitol if euvolemic</li>
                <li>• Seizure prophylaxis (levetiracetam) for 7 days</li>
                <li>• Maintain normothermia; induced hypothermia only in refractory cases</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* 6. Aneurysm Clipping/Coiling &amp; SAH */}
      <div className="rounded-2xl border border-pink-200 bg-card overflow-hidden">
        <button
          onClick={() => toggleSection('aneurysm')}
          className="w-full flex items-center gap-3 p-4 text-left hover:bg-pink-50 active:scale-[0.99] transition-all"
        >
          <span className="text-xl">🫀</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">6. Aneurysm Clipping/Coiling &amp; SAH</p>
            <p className="text-xs text-muted-foreground mt-0.5">Sudden worst headache, vasospasm management, temporary clipping</p>
          </div>
          {expandedSections.aneurysm ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.aneurysm && (
          <div className="border-t border-pink-100 p-4 bg-pink-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-pink-700 mb-1.5">SAH Presentation</p>
              <p className="text-xs text-muted-foreground">Sudden 'worst headache of life,' neurologic deficits, autonomic storm. Hunt-Hess &amp; WFNS grades correlate with outcome.</p>
            </div>
            <div>
              <p className="font-bold text-pink-700 mb-1.5">Management</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Prevent rebleed: tight BP until aneurysm secured (clip/coil)</li>
                <li>• Maintain CPP; manage cerebral vasospasm</li>
                <li>• Nimodipine 60 mg PO q4h × 21 days improves outcomes</li>
                <li>• Triple-H (hypertension, hypervolemia, hemodilution) historic; current: euvolemic hypertension favored</li>
              </ul>
            </div>
            <div>
              <p className="font-bold text-pink-700 mb-1.5">Temporary Clipping Management</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Burst suppression with propofol/thiopental provides metabolic suppression</li>
                <li>• Modest hypothermia (33–34°C) historically used; IHAST showed no benefit in good-grade SAH</li>
                <li>• Avoid sustained hyperventilation; maintain normocapnia</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* 7. Awake Craniotomy */}
      <div className="rounded-2xl border border-yellow-200 bg-card overflow-hidden">
        <button
          onClick={() => toggleSection('awake')}
          className="w-full flex items-center gap-3 p-4 text-left hover:bg-yellow-50 active:scale-[0.99] transition-all"
        >
          <span className="text-xl">👁️</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">7. Awake Craniotomy</p>
            <p className="text-xs text-muted-foreground mt-0.5">Asleep-awake-asleep, scalp block, seizure management</p>
          </div>
          {expandedSections.awake ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.awake && (
          <div className="border-t border-yellow-100 p-4 bg-yellow-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-yellow-700 mb-1.5">Indications</p>
              <p className="text-xs text-muted-foreground">Tumor near eloquent cortex, epilepsy surgery, deep brain stimulation.</p>
            </div>
            <div>
              <p className="font-bold text-yellow-700 mb-1.5">Techniques</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Asleep-awake-asleep (AAA), monitored anesthesia care, conscious sedation</li>
                <li>• Dexmedetomidine, propofol, remifentanil common; LMA or nasal airway for AAA</li>
                <li>• Scalp block essential: greater/lesser occipital, auriculotemporal, supraorbital, supratrochlear, zygomaticotemporal</li>
                <li>• Manage seizures with cold saline irrigation; have propofol &amp; midazolam ready</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* 8. Spine Surgery */}
      <div className="rounded-2xl border border-green-200 bg-card overflow-hidden">
        <button
          onClick={() => toggleSection('spine')}
          className="w-full flex items-center gap-3 p-4 text-left hover:bg-green-50 active:scale-[0.99] transition-all"
        >
          <span className="text-xl">🦴</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">8. Spine Surgery</p>
            <p className="text-xs text-muted-foreground mt-0.5">Prone positioning, POVL prevention, neuromonitoring</p>
          </div>
          {expandedSections.spine ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.spine && (
          <div className="border-t border-green-100 p-4 bg-green-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-green-700 mb-1.5">Positioning</p>
              <p className="text-xs text-muted-foreground">Prone position — avoid pressure on eyes, brachial plexus, abdomen (decreases venous return, increases epidural venous pressure &amp; bleeding).</p>
            </div>
            <div>
              <p className="font-bold text-green-700 mb-1.5">Postoperative Visual Loss (POVL)</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Ischemic optic neuropathy is most common cause</li>
                <li>• Risk factors: prolonged prone, blood loss, hypotension, head-down positioning, anemia</li>
                <li>• Maintain MAP, monitor blood loss, head level or slightly above heart, frequent eye checks</li>
              </ul>
            </div>
            <div>
              <p className="font-bold text-green-700 mb-1.5">Neuromonitoring &amp; TXA</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• SSEP, MEP, EMG: TIVA without NMB required for MEPs; volatile ≤0.5 MAC for SSEP</li>
                <li>• Tranexamic acid 10–20 mg/kg load reduces transfusion in major spine surgery</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* 9. Posterior Fossa Surgery &amp; VAE */}
      <div className="rounded-2xl border border-indigo-200 bg-card overflow-hidden">
        <button
          onClick={() => toggleSection('posterior')}
          className="w-full flex items-center gap-3 p-4 text-left hover:bg-indigo-50 active:scale-[0.99] transition-all"
        >
          <span className="text-xl">⚡</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">9. Posterior Fossa Surgery &amp; VAE</p>
            <p className="text-xs text-muted-foreground mt-0.5">Sitting position risk, VAE monitoring &amp; treatment</p>
          </div>
          {expandedSections.posterior ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.posterior && (
          <div className="border-t border-indigo-100 p-4 bg-indigo-50 space-y-3 text-sm">
            <div>
              <p className="font-bold text-indigo-700 mb-1.5">Sitting Position Considerations</p>
              <p className="text-xs text-muted-foreground">Sitting position improves surgical exposure but raises venous air embolism (VAE) risk up to 40%.</p>
            </div>
            <div>
              <p className="font-bold text-indigo-700 mb-1.5">VAE Monitoring</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Precordial Doppler (most sensitive); TEE (definitive)</li>
                <li>• End-tidal CO₂ (drops with VAE); end-tidal N₂ (rises)</li>
                <li>• Arterial line</li>
              </ul>
            </div>
            <div>
              <p className="font-bold text-indigo-700 mb-1.5">VAE Treatment</p>
              <ul className="space-y-1 text-muted-foreground text-xs">
                <li>• Flood field with saline; surgeon controls source</li>
                <li>• Jugular compression; 100% O₂; discontinue N₂O</li>
                <li>• Aspirate via CVC; vasopressors</li>
                <li>• Left lateral Trendelenburg; hemodynamic support</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* Practice Questions */}
      <div className="rounded-2xl border border-blue-200 bg-card overflow-hidden">
        <button
          onClick={() => toggleSection('practice')}
          className="w-full flex items-center gap-3 p-4 text-left hover:bg-blue-50 active:scale-[0.99] transition-all"
        >
          <span className="text-xl">📝</span>
          <div className="flex-1">
            <p className="font-semibold text-sm text-foreground">Practice Questions</p>
            <p className="text-xs text-muted-foreground mt-0.5">45 high-yield neuroanesthesia &amp; intracranial physiology items</p>
          </div>
          {expandedSections.practice ? <ChevronUp className="w-4 h-4 text-muted-foreground" /> : <ChevronDown className="w-4 h-4 text-muted-foreground" />}
        </button>
        {expandedSections.practice && (
          <div className="border-t border-blue-100 p-4 bg-blue-50 space-y-3 text-xs">
            <div className="bg-card rounded-lg p-3 border border-blue-100">
              <p className="font-semibold text-blue-700 mb-1">Coverage Areas</p>
              <p className="text-muted-foreground">Cerebral autoregulation ranges, CO₂ reactivity percentages, ICP management including osmotic therapy, pharmacology effects on CMRO₂/CBF/ICP, burst suppression during temporary clipping, TBI CPP targets, seizure prophylaxis, SAH vasospasm management, awake craniotomy techniques, scalp block anatomy, MEP &amp; SSEP monitoring, postoperative visual loss prevention, venous air embolism detection &amp; treatment, VAE monitoring modalities, hypothermia in neurosurgery, intrathecal baclofen management, transspenoidal surgery airway planning, acute spinal cord injury management.</p>
            </div>
            <div className="bg-card rounded-lg p-3 border border-blue-100">
              <p className="font-semibold text-blue-700 mb-1">Key High-Yield Topics</p>
              <ul className="space-y-1 text-muted-foreground">
                <li>• Cerebral autoregulation: MAP 50–150 mmHg in normotensive adults</li>
                <li>• CO₂ reactivity: 3% CBF change per mmHg PaCO₂</li>
                <li>• ICP normal ≤15 mmHg; treatment threshold &gt;20–22 mmHg</li>
                <li>• Propofol: ↓CMRO₂, ↓CBF, ↓ICP, preserves autoregulation — ideal for neuro TIVA</li>
                <li>• Volatile &gt;1.5 MAC: uncoupling &amp; cerebral vasodilation → ↑ICP</li>
                <li>• Mannitol contraindicated in severe hypovolemia or anuric AKI</li>
                <li>• CPP target in TBI: 60–70 mmHg (avoid &gt;70, ARDS risk)</li>
                <li>• Precordial Doppler: most sensitive non-invasive VAE monitor</li>
                <li>• Burst suppression during temporary aneurysm clipping: propofol/thiopental titrated to EEG</li>
                <li>• MEP monitoring: requires TIVA without NMB (after intubating dose)</li>
              </ul>
            </div>
          </div>
        )}
      </div>

      {/* Study Tips */}
      <div className="p-4 rounded-2xl bg-emerald-50 border border-emerald-200">
        <p className="text-xs font-bold text-emerald-700 mb-2">💡 Study Strategy</p>
        <ul className="space-y-1 text-xs text-muted-foreground">
          <li>• Master CBF physiology: autoregulation, reactivity, coupling</li>
          <li>• Know ICP management tiers: positioning → osmotic → CSF drainage → craniectomy</li>
          <li>• Understand why propofol is gold standard for neuro TIVA</li>
          <li>• Recognize VAE — precordial Doppler, ETCO₂ drop, ETCO₂ rise</li>
          <li>• Practice 45 questions before final exam</li>
        </ul>
      </div>
    </div>
  );
}