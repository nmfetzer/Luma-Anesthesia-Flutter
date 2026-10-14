import { useState } from 'react';
import { ChevronDown, ChevronUp } from 'lucide-react';

const KEY_POINT = ({ children }) => (
  <div className="my-3 p-3 rounded-lg bg-amber-50 border-l-4 border-amber-400 text-sm text-amber-900">
    <span className="font-bold">KEY POINT — </span>{children}
  </div>
);

const Section = ({ title, children, defaultOpen = false }) => {
  const [open, setOpen] = useState(defaultOpen);
  return (
    <div className="rounded-xl border border-border/60 overflow-hidden mb-3">
      <button
        onClick={() => setOpen(o => !o)}
        className="w-full flex items-center justify-between px-4 py-3 bg-secondary text-left"
      >
        <span className="font-bold text-sm text-foreground">{title}</span>
        {open ? <ChevronUp className="w-4 h-4 text-muted-foreground shrink-0" /> : <ChevronDown className="w-4 h-4 text-muted-foreground shrink-0" />}
      </button>
      {open && <div className="px-4 py-3 text-sm text-foreground space-y-2 bg-background">{children}</div>}
    </div>
  );
};

const Table = ({ headers, rows }) => (
  <div className="overflow-x-auto my-2">
    <table className="w-full text-xs border-collapse">
      <thead>
        <tr className="bg-primary text-primary-foreground">
          {headers.map((h, i) => <th key={i} className="px-3 py-2 text-left font-semibold">{h}</th>)}
        </tr>
      </thead>
      <tbody>
        {rows.map((row, i) => (
          <tr key={i} className={i % 2 === 0 ? 'bg-background' : 'bg-secondary'}>
            {row.map((cell, j) => <td key={j} className="px-3 py-2 border-b border-border/30">{cell}</td>)}
          </tr>
        ))}
      </tbody>
    </table>
  </div>
);

const Bullet = ({ children }) => <p className="pl-3 border-l-2 border-slate-200 text-sm text-foreground">• {children}</p>;

export default function ABAAnatomyModule() {
  return (
    <div className="space-y-2 pb-4">
      {/* Intro */}
      <div className="p-4 rounded-xl bg-blue-50 border border-blue-100 mb-4">
        <p className="text-sm text-blue-900">This module reviews the surgical and applied anatomy most frequently tested on the ABA BASIC examination. Topics are organized by region, with emphasis on the relationships clinically relevant to airway management, regional anesthesia, vascular access, and patient positioning.</p>
        <KEY_POINT>Anatomy on the BASIC exam is rarely tested as pure recall — it is tested as the substrate for an anesthetic problem (a failed block, a lost airway, a positioning injury). Always translate anatomy to clinical consequence.</KEY_POINT>
      </div>

      {/* 1.1 Upper Airway */}
      <Section title="1.1 · Upper Airway Anatomy" defaultOpen>
        <p className="text-sm">The upper airway extends from the nares and lips to the cricoid cartilage. It is divided into the nasal cavity, oral cavity, pharynx (naso-, oro-, hypo-) and larynx.</p>

        <p className="font-semibold text-blue-800 mt-3">Nasal Cavity</p>
        <Bullet>Divided by the septum (anterior cartilaginous, posterior vomer and perpendicular plate of ethmoid). Lateral wall bears three turbinates (superior, middle, inferior).</Bullet>
        <Bullet>Nasal intubation must pass below the inferior turbinate — directed perpendicular to the face, not cephalad.</Bullet>
        <Bullet>Sensory: anterior septum/lateral wall — anterior ethmoidal nerve (V1); posterior — sphenopalatine nerve (V2). The sphenopalatine ganglion (behind the middle turbinate) is targeted for awake nasal intubation blocks.</Bullet>
        <Bullet>Vascular: Kiesselbach plexus (anterior septum) = most common epistaxis; sphenopalatine artery = severe posterior bleeds.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Oral Cavity & Oropharynx — Sensory Innervation</p>
        <Bullet>Anterior 2/3 of tongue — lingual nerve (V3) for sensation; chorda tympani (CN VII) for taste.</Bullet>
        <Bullet>Posterior 1/3 of tongue, vallecula, anterior epiglottis, tonsillar pillars, oropharynx — glossopharyngeal nerve (CN IX).</Bullet>
        <Bullet>Soft palate, uvula — lesser palatine (V2) and CN IX.</Bullet>
        <KEY_POINT>The gag reflex is mediated by CN IX (afferent) and CN X (efferent). Blocking CN IX bilaterally is required for awake oral fiberoptic intubation.</KEY_POINT>

        <p className="font-semibold text-blue-800 mt-3">Larynx</p>
        <Bullet>Extends from the epiglottis (C3) to the cricoid cartilage (C6). Nine cartilages: 3 unpaired (epiglottis, thyroid, cricoid) and 3 paired (arytenoid, corniculate, cuneiform).</Bullet>
        <Bullet>Vocal cords attach anteriorly at the thyroid cartilage, posteriorly to the vocal processes of the arytenoids.</Bullet>
        <Bullet>Cricoid cartilage = only complete ring; narrowest point in the pediatric (subglottic) airway. In adults, the glottis is the narrowest.</Bullet>
        <Bullet>Cricothyroid membrane: 1–1.5 cm tall, 2–3 cm wide; cricothyroid arteries cross its upper third — safest puncture site is the lower one-third in the midline.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Laryngeal Innervation (all CN X)</p>
        <Bullet>Superior laryngeal nerve (SLN): Internal branch — sensory above the cords; External branch — motor to cricothyroid (only cord tensor).</Bullet>
        <Bullet>Recurrent laryngeal nerve (RLN): sensory below the cords; motor to ALL other intrinsic laryngeal muscles.</Bullet>
        <KEY_POINT>Unilateral RLN injury → hoarseness. Bilateral RLN injury → stridor/airway obstruction. Bilateral SLN injury → hoarseness + aspiration (patent airway). Combined bilateral CN X injury → cords in cadaveric (intermediate) position.</KEY_POINT>

        <p className="font-semibold text-blue-800 mt-3">Tracheobronchial Tree</p>
        <Bullet>Trachea: 10–12 cm, 16–20 rings, cricoid (C6) to carina (T4–T5 / sternal angle).</Bullet>
        <Bullet>Right mainstem: shorter, wider, more vertical (≈25° from midline) → explains right-sided endobronchial intubation and aspiration.</Bullet>
        <Bullet>Left mainstem: ≈45°; RUL takeoff ≈2.5 cm from carina — frequently obstructed by malpositioned right-sided DLT.</Bullet>
      </Section>

      {/* 1.2 Spinal */}
      <Section title="1.2 · Spinal and Neuraxial Anatomy">
        <p className="text-sm">33 vertebrae: 7 cervical, 12 thoracic, 5 lumbar, 5 fused sacral, 4 fused coccygeal.</p>
        <KEY_POINT>In supine position: apex of thoracic kyphosis is T5–T6 (lowest point) and lumbar lordosis is L3 (highest point). This drives spread of hyperbaric spinal anesthetic.</KEY_POINT>

        <p className="font-semibold text-blue-800 mt-3">Surface Landmarks</p>
        <Table
          headers={['Landmark', 'Vertebral Level']}
          rows={[
            ['Vertebra prominens (C7)', 'C7 spinous process'],
            ['Root of scapular spine', 'T3'],
            ['Inferior angle of scapula', 'T7'],
            ['Inferior costal margin', 'L1'],
            ["Tuffier's line (iliac crests)", 'L4 or L4–L5 interspace'],
            ['Posterior superior iliac spines', 'S2 (dural sac termination in adults)'],
          ]}
        />

        <p className="font-semibold text-blue-800 mt-3">Spinal Cord & Meninges</p>
        <Bullet>Conus medullaris terminates at L1 in adults, L3 in neonates.</Bullet>
        <Bullet>Dural sac terminates at S2 in adults, S3 in infants.</Bullet>
        <Bullet>Three meninges (outer→inner): dura, arachnoid, pia. CSF in the subarachnoid space.</Bullet>
        <KEY_POINT>Spinal anesthesia must be performed below L1 in adults and below L3 in neonates. Tuffier's line (L4) is the safest landmark.</KEY_POINT>

        <p className="font-semibold text-blue-800 mt-3">Midline Needle Layers (superficial → deep)</p>
        <p className="text-sm">Skin → subcutaneous tissue → supraspinous ligament → interspinous ligament → ligamentum flavum (loss of resistance) → epidural space → dura → arachnoid → subarachnoid (CSF)</p>
        <Bullet>Paramedian approach bypasses supraspinous/interspinous ligaments, useful in calcified/elderly spines.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Epidural Space</p>
        <Bullet>Bounded superiorly by foramen magnum, inferiorly by sacrococcygeal ligament.</Bullet>
        <Bullet>Contents: fat, lymphatics, spinal nerve roots, Batson's venous plexus (valveless).</Bullet>
        <Bullet>Skin to epidural space: ≈4–6 cm at lumbar level; deeper in obese, shallower in thin.</Bullet>
      </Section>

      {/* 1.3 Peripheral Nerve */}
      <Section title="1.3 · Peripheral Nerve Anatomy for Regional Anesthesia">
        <p className="font-semibold text-blue-800">Brachial Plexus</p>
        <p className="text-sm">Roots (C5–T1) → Trunks → Divisions → Cords → Branches</p>
        <p className="text-xs italic text-muted-foreground mb-2">Mnemonic: <strong>R</strong>obert <strong>T</strong>aylor <strong>D</strong>rinks <strong>C</strong>old <strong>B</strong>eer</p>

        <Table
          headers={['Block', 'Level', 'Common Sparing']}
          rows={[
            ['Interscalene', 'Roots/trunks (C5–C7)', 'Ulnar (C8–T1) — inadequate for hand surgery'],
            ['Supraclavicular', 'Trunks/divisions', 'Most complete; risk of pneumothorax'],
            ['Infraclavicular', 'Cords', 'Reliable for elbow/forearm/hand'],
            ['Axillary', 'Branches', 'Musculocutaneous often spared — block separately in coracobrachialis'],
          ]}
        />
        <KEY_POINT>Interscalene block causes ipsilateral phrenic nerve palsy in 100% at standard volumes (~50% reduction in pulmonary function). Avoid in severe COPD or contralateral phrenic palsy.</KEY_POINT>

        <p className="font-semibold text-blue-800 mt-3">Lumbar & Sacral Plexus</p>
        <Bullet>Lumbar (L1–L4): iliohypogastric, ilioinguinal, genitofemoral, lateral femoral cutaneous, femoral, obturator.</Bullet>
        <Bullet>Sacral (L4–S4): sciatic (tibial + common peroneal), pudendal, posterior femoral cutaneous.</Bullet>

        <p className="font-semibold text-blue-800 mt-2">Lower-Extremity Blocks</p>
        <Bullet>Femoral: anterior thigh, medial leg (saphenous), knee — combine with sciatic for below-knee surgery.</Bullet>
        <Bullet>Adductor canal (saphenous): predominantly sensory — preserves quadriceps, ideal for knee analgesia.</Bullet>
        <Bullet>Sciatic (popliteal): posterior knee, leg (except medial), foot.</Bullet>
        <Bullet>Ankle block: 5 nerves — deep peroneal, superficial peroneal, posterior tibial, sural, saphenous.</Bullet>
      </Section>

      {/* 1.4 ANS */}
      <Section title="1.4 · Autonomic Nervous System">
        <p className="text-sm">Sympathetic (thoracolumbar, T1–L2) vs Parasympathetic (craniosacral: CN III, VII, IX, X, S2–S4).</p>

        <p className="font-semibold text-blue-800 mt-3">Sympathetic Levels — Clinically Important</p>
        <Table
          headers={['Target Organ', 'Spinal Level']}
          rows={[
            ['Head / eyes (pupils)', 'T1–T2 (stellate ganglion)'],
            ['Heart', 'T1–T4 (cardiac accelerators)'],
            ['Upper extremity', 'T2–T8'],
            ['Lungs / bronchi', 'T1–T4'],
            ['Liver, GI tract, adrenals', 'T5–T11 (splanchnic)'],
            ['Kidneys, ureters', 'T10–L1'],
            ['Uterus, bladder', 'T11–L2'],
            ['Lower extremity (vasomotor)', 'T10–L2'],
          ]}
        />

        <p className="font-semibold text-blue-800 mt-3">Parasympathetic Pelvic Outflow (S2–S4)</p>
        <Bullet>Supply descending colon, rectum, bladder, genitalia. Blocked by caudal and low spinal anesthesia → urinary retention, erectile dysfunction.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Stellate Ganglion</p>
        <Bullet>Fusion of inferior cervical + first thoracic sympathetic ganglia; anterior to C7 transverse process.</Bullet>
        <Bullet>Block at C6 (Chassaignac's tubercle) → ipsilateral Horner's syndrome (ptosis, miosis, anhidrosis, enophthalmos).</Bullet>
      </Section>

      {/* 1.5 Cardiac */}
      <Section title="1.5 · Cardiac Anatomy">
        <p className="font-semibold text-blue-800">Coronary Circulation</p>
        <Bullet>Left main → LAD (anterior wall, anterior 2/3 septum, apex) + Circumflex (lateral wall, often posterior wall).</Bullet>
        <Bullet>RCA → SA node (60%), AV node (80–90%), RV, inferior wall LV (right-dominant = 85% of population).</Bullet>
        <KEY_POINT>Inferior MI (RCA territory) frequently causes bradycardia/heart block (SA/AV node ischemia). RV involvement → profound preload-dependence; contraindicates nitrates and aggressive diuresis.</KEY_POINT>

        <p className="font-semibold text-blue-800 mt-3">Conduction System</p>
        <p className="text-sm">SA node (right atrium, near SVC) → internodal pathways → AV node → bundle of His → right & left bundle branches → Purkinje fibers</p>
        <Bullet>AV node delay ≈100 ms allows atrial contribution to ventricular filling.</Bullet>
        <Bullet>Sympathetic (β1) ↑ all phases; parasympathetic (vagus) ↓ SA/AV nodal activity (no ventricular effect).</Bullet>
      </Section>

      {/* 1.6 Positioning */}
      <Section title="1.6 · Position-Related Nerve Injuries">
        <Table
          headers={['Nerve', 'Position at Risk', 'Deficit']}
          rows={[
            ['Ulnar', 'Supination/elbow extension; arm boards', 'Claw hand, 4th/5th finger sensory loss — most common perioperative neuropathy'],
            ['Brachial plexus', 'Arm abducted >90°, head turned, shoulder braces in Trendelenburg', 'Stretch injury — upper trunk most often'],
            ['Radial', 'Lateral arm compression (BP cuff, screen edge)', 'Wrist drop'],
            ['Median', 'Antecubital compression / IV infiltrate', 'Loss of thumb opposition; benediction sign'],
            ['Common peroneal', 'Lithotomy — head of fibula vs stirrup', 'Foot drop, lateral leg sensory loss'],
            ['Sciatic', 'Sitting position with poor padding', 'Posterior leg weakness/sensory loss'],
            ['Femoral', 'Hip flexion/abduction (lithotomy); abdominal retractors', 'Quadriceps weakness, loss of patellar reflex'],
            ['Saphenous', 'Medial knee against stirrup post', 'Medial leg sensory loss'],
            ['Optic/retinal artery', 'Prone with eye compression', 'Postoperative vision loss (POVL)'],
          ]}
        />
        <KEY_POINT>Ulnar neuropathy is the most common perioperative peripheral nerve injury. Pad the elbow in supination (palms up). Male sex, thin habitus, and pre-existing neuropathy are non-modifiable risk factors.</KEY_POINT>
      </Section>

      {/* 1.7 Thoracic/Abdominal */}
      <Section title="1.7 · Thoracic and Abdominal Anatomy">
        <p className="font-semibold text-blue-800">Dermatomes (High Yield)</p>
        <Table
          headers={['Level', 'Landmark']}
          rows={[
            ['C4', 'Clavicle / top of shoulder'],
            ['T1', 'Inner forearm'],
            ['T4', 'Nipple line'],
            ['T6–T7', 'Xiphoid'],
            ['T10', 'Umbilicus'],
            ['L1', 'Inguinal ligament'],
            ['L4', 'Knee / medial malleolus'],
            ['S1', 'Lateral foot'],
            ['S2–S4', 'Perineum'],
          ]}
        />

        <p className="font-semibold text-blue-800 mt-3">Diaphragm</p>
        <Bullet>Motor: phrenic nerve (C3, C4, C5 — "keeps the diaphragm alive").</Bullet>
        <Bullet>Three openings: caval hiatus (T8 — IVC, right phrenic), esophageal hiatus (T10 — esophagus, vagi), aortic hiatus (T12 — aorta, thoracic duct, azygos).</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Pleural Anatomy & Pneumothorax Risk</p>
        <p className="text-sm">Pleural reflections descend to T12 posteriorly. Procedures with pneumothorax risk: interscalene, supraclavicular, intercostal, paravertebral, stellate ganglion blocks; subclavian and low IJ central line placement.</p>
      </Section>

      {/* 1.8 Clinical Correlates */}
      <Section title="1.8 · Clinical Correlates: Anatomy → Anesthesia">
        <KEY_POINT>RLN injury after thyroid surgery: unilateral = hoarseness, bilateral = airway emergency. Test cord function before and after extubation in high-risk cases.</KEY_POINT>
        <KEY_POINT>In the difficult airway algorithm, the cricothyroid membrane is the surgical airway entry point — palpate the notch between thyroid and cricoid cartilages.</KEY_POINT>
        <KEY_POINT>A "high spinal" = cephalad spread of local anesthetic. Loss of T1–T4 → bradycardia/hypotension. Loss of C3–C5 → respiratory arrest. Loss of cranial nerves → unconsciousness.</KEY_POINT>
        <KEY_POINT>Phrenic nerve palsy after interscalene block is universal at standard volumes. Avoid in limited respiratory reserve; consider lower-volume ultrasound-guided, supraclavicular, or suprascapular alternatives.</KEY_POINT>
        <KEY_POINT>Caudal anesthesia in pediatrics enters through the sacral hiatus. Dural sac terminates at S3 in infants (vs S2 in adults) — higher risk of dural puncture in neonates.</KEY_POINT>

        <p className="font-semibold text-blue-800 mt-4">Self-Assessment Checkpoints</p>
        <Bullet>Can you list the nerves blocked at each level of the brachial plexus and which surgeries each covers?</Bullet>
        <Bullet>Can you identify the layers traversed by an epidural needle in both midline and paramedian approaches?</Bullet>
        <Bullet>Can you predict the deficit from SLN vs RLN vs combined vagal lesion?</Bullet>
        <Bullet>Can you correlate sympathetic spinal levels with the autonomic effects of high spinal anesthesia?</Bullet>
        <Bullet>Can you name three patient positions and the specific nerves at risk in each?</Bullet>
      </Section>

      <p className="text-[10px] text-muted-foreground text-center pt-2">© CE Halo LLC · ABA BASIC Study Package · Module 1 · Edition 2026</p>
    </div>
  );
}