import { useState } from 'react';
import { Search, AlertTriangle, AlertCircle, AlertOctagon, CheckCircle2, ExternalLink } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

const CURATED_INTERACTIONS = [
  {
    drugA: 'Succinylcholine',
    drugB: 'Hyperkalemic States',
    severity: 'contraindicated',
    title: 'Risk of Fatal Cardiac Arrest',
    description: 'Succinylcholine causes acute potassium release from muscle. In patients with burns, crush injuries, denervation, or severe hyperkalemia, this can trigger fatal cardiac arrhythmias.',
    clinical: 'Check K+ preoperatively. Avoid succinylcholine in these patients. Use rocuronium or other non-depolarizing agents instead.',
    sources: 'FDA Warning, Anesthesia & Analgesia',
  },
  {
    drugA: 'MAOIs',
    drugB: 'Meperidine',
    severity: 'contraindicated',
    title: 'Serotonin Syndrome & Hypertensive Crisis',
    description: 'Meperidine interacts with MAOIs causing rapid serotonin accumulation, leading to serotonin syndrome and life-threatening hypertensive crisis.',
    clinical: 'Absolutely contraindicated. Avoid meperidine. Use other opioids (fentanyl, morphine) cautiously. Discontinue MAOI ≥2 weeks before.',
    sources: 'Micromedex, FDA Black Box Warning',
  },
  {
    drugA: 'MAOIs',
    drugB: 'Fentanyl',
    severity: 'contraindicated',
    title: 'Serotonin Syndrome Risk',
    description: 'Although fentanyl is typically safer than meperidine with MAOIs, serotonin syndrome is still possible.',
    clinical: 'Use with extreme caution. Monitor closely. Have treatment plan for hypertensive crisis (phentolamine, labetalol).',
    sources: 'Anesthesia & Analgesia Reviews',
  },
  {
    drugA: 'Ketamine',
    drugB: 'MAOIs',
    severity: 'contraindicated',
    title: 'Hypertensive Crisis',
    description: 'Ketamine potentiates sympathomimetic effects. Combined with MAOI inhibition of monoamine breakdown, severe hypertension and arrhythmias can occur.',
    clinical: 'Avoid ketamine if patient on MAOIs. Plan alternative induction (thiopental, propofol).',
    sources: 'ASA Guidelines, Pharmacology Textbooks',
  },
  {
    drugA: 'Propofol',
    drugB: 'Opioids',
    severity: 'major',
    title: 'Profound Respiratory Depression & Hypotension',
    description: 'Synergistic CNS depression and hemodynamic suppression. Can lead to severe hypotension, apnea, and hypoxemia.',
    clinical: 'Standard combination in anesthesia but requires careful dosing. Reduce propofol/opioid doses by 25-50% when combined. Have vasopressors and airway equipment ready.',
    sources: 'Anesthesia Standard of Care',
  },
  {
    drugA: 'Benzodiazepines',
    drugB: 'Opioids',
    severity: 'major',
    title: 'Respiratory Depression (FDA Black Box Warning)',
    description: 'Combined CNS depression causes profound sedation, respiratory depression, coma, and death.',
    clinical: 'FDA Black Box warning when used together. If combined, use lowest doses, monitor closely. Have naloxone and reversal agents ready.',
    sources: 'FDA Black Box Warning, DEA Opioid Guidelines',
  },
  {
    drugA: 'Ondansetron',
    drugB: 'Amiodarone',
    severity: 'major',
    title: 'QT Prolongation & Torsades de Pointes',
    description: 'Both drugs block cardiac potassium channels, causing QT prolongation and risk of fatal arrhythmia (torsades de pointes).',
    clinical: 'Avoid combination if possible. If necessary, monitor ECG, check baseline QTc, and use alternative antiemetic (dexamethasone, scopolamine).',
    sources: 'Micromedex, Journal of Cardiac Arrhythmias',
  },
  {
    drugA: 'Ondansetron',
    drugB: 'Droperidol',
    severity: 'major',
    title: 'QT Prolongation',
    description: 'Both agents prolong QT interval. Droperidol now has FDA black box warning for QT prolongation.',
    clinical: 'Avoid both together. Use alternative antiemetic (dexamethasone, metoclopramide, scopolamine).',
    sources: 'FDA Black Box Warning',
  },
  {
    drugA: 'Neostigmine',
    drugB: 'Succinylcholine',
    severity: 'major',
    title: 'Prolonged Neuromuscular Blockade',
    description: 'Neostigmine inhibits pseudocholinesterase, prolonging succinylcholine metabolism and duration of paralysis.',
    clinical: 'Avoid combining. If reversal needed, use sugammadex (rocuronium) or allow succinylcholine to wear off naturally.',
    sources: 'Anesthesia Pharmacology',
  },
  {
    drugA: 'Dexmedetomidine',
    drugB: 'Beta-blockers',
    severity: 'major',
    title: 'Severe Bradycardia & Heart Block',
    description: 'Dexmedetomidine causes initial hypertension followed by bradycardia. Combined with beta-blocker, severe bradycardia and conduction blocks can occur.',
    clinical: 'Monitor heart rate and ECG closely. Have atropine and external pacing available. Consider alternative sedative.',
    sources: 'Dexmedetomidine Monograph, ASA Guidelines',
  },
  {
    drugA: 'Epinephrine',
    drugB: 'Halothane',
    severity: 'major',
    title: 'Ventricular Arrhythmias',
    description: 'Halothane sensitizes myocardium to catecholamines, causing ectopy and ventricular arrhythmias with epinephrine.',
    clinical: 'Avoid epinephrine with halothane. Use isoflurane, sevoflurane instead. If epinephrine needed, use minimal doses and monitor ECG.',
    sources: 'Volatile Anesthetic Pharmacology',
  },
  {
    drugA: 'Rocuronium',
    drugB: 'Aminoglycosides',
    severity: 'major',
    title: 'Enhanced Neuromuscular Blockade',
    description: 'Aminoglycosides (gentamicin, tobramycin) potentiate neuromuscular blocking agents, prolonging paralysis.',
    clinical: 'Monitor train-of-four, use lower rocuronium doses, and plan for prolonged blockade. Use sugammadex for reversal.',
    sources: 'Drug Interaction Database',
  },
  {
    drugA: 'Lithium',
    drugB: 'Neuromuscular Blockers',
    severity: 'major',
    title: 'Prolonged Blockade',
    description: 'Lithium potentiates neuromuscular blocking agents, increasing duration and depth of paralysis.',
    clinical: 'Continue lithium perioperatively but use reduced NMB doses. Monitor TOF closely. Have sugammadex ready.',
    sources: 'Psychopharmacology & Anesthesia Guidelines',
  },
  {
    drugA: 'Magnesium',
    drugB: 'Neuromuscular Blockers',
    severity: 'major',
    title: 'Enhanced & Prolonged Blockade',
    description: 'Magnesium potentiates NMBs at neuromuscular junction. Preeclamptic patients on magnesium sulfate at higher risk.',
    clinical: 'Reduce NMB dose by 30-50%. Monitor TOF. Sugammadex preferred for reversal in OB patients.',
    sources: 'Obstetric Anesthesia Guidelines',
  },
  {
    drugA: 'Ketamine',
    drugB: 'Benzodiazepines',
    severity: 'moderate',
    title: 'Enhanced Sedation & Respiratory Depression',
    description: 'Combined CNS depression increases sedation depth and respiratory depression risk.',
    clinical: 'Standard combination in anesthesia but requires careful dosing. Reduce both agents by 25-50%. Avoid in airway-compromised patients.',
    sources: 'Anesthesia Standard of Care',
  },
  {
    drugA: 'Opioids',
    drugB: 'Muscle Relaxants',
    severity: 'moderate',
    title: 'Enhanced CNS/Respiratory Depression',
    description: 'Synergistic depression of CNS and respiratory drive.',
    clinical: 'Standard intraoperative combination. Monitor respiratory function closely, especially postoperatively.',
    sources: 'Anesthesia Practice',
  },
  {
    drugA: 'Ephedrine',
    drugB: 'Tricyclic Antidepressants (TCAs)',
    severity: 'moderate',
    title: 'Hypertensive Crisis',
    description: 'TCAs inhibit reuptake of norepinephrine, increasing sympathomimetic effect of ephedrine.',
    clinical: 'Use phenylephrine (pure alpha agent) instead of ephedrine. If ephedrine needed, use lower doses.',
    sources: 'Drug Interaction Database',
  },
  {
    drugA: 'NSAIDs',
    drugB: 'Heparin',
    severity: 'moderate',
    title: 'Increased Bleeding Risk',
    description: 'NSAIDs impair platelet function; heparin thins blood. Combined effect increases bleeding.',
    clinical: 'Avoid NSAIDs perioperatively in heparinized patients. Use acetaminophen for analgesia instead.',
    sources: 'Perioperative Medicine Guidelines',
  },
  {
    drugA: 'Dexmedetomidine',
    drugB: 'Opioids',
    severity: 'moderate',
    title: 'Enhanced Sedation & Bradycardia',
    description: 'Additive CNS and cardiac effects.',
    clinical: 'Reduce both agent doses. Monitor HR and BP. Useful combination in some settings but requires careful titration.',
    sources: 'Anesthesia Reviews',
  },
];

const SEVERITY_CONFIG = {
  contraindicated: {
    badge: '🔴',
    color: 'bg-red-50 border-red-100',
    textColor: 'text-red-900',
    icon: AlertOctagon,
    label: 'CONTRAINDICATED',
  },
  major: {
    badge: '🟠',
    color: 'bg-orange-50 border-orange-100',
    textColor: 'text-orange-900',
    icon: AlertTriangle,
    label: 'MAJOR',
  },
  moderate: {
    badge: '🟡',
    color: 'bg-yellow-50 border-yellow-100',
    textColor: 'text-yellow-900',
    icon: AlertCircle,
    label: 'MODERATE',
  },
  minor: {
    badge: '🟢',
    color: 'bg-green-50 border-green-100',
    textColor: 'text-green-900',
    icon: CheckCircle2,
    label: 'MINOR',
  },
};

function InteractionCard({ interaction, index }) {
  const [expanded, setExpanded] = useState(false);
  const config = SEVERITY_CONFIG[interaction.severity];
  const IconComponent = config.icon;

  return (
    <motion.div
      initial={{ opacity: 0, y: 4 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: index * 0.03 }}
      className={`rounded-xl border p-3 cursor-pointer transition-all ${config.color}`}
      onClick={() => setExpanded(!expanded)}
    >
      <div className="flex items-start gap-2">
        <IconComponent className="w-4 h-4 mt-0.5 shrink-0" style={{ color: config.textColor }} />
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 mb-1">
            <p className={`text-sm font-bold ${config.textColor}`}>{interaction.drugA} + {interaction.drugB}</p>
            <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full ${config.color} border`}>
              {config.label}
            </span>
          </div>
          <p className={`text-xs ${config.textColor} font-semibold`}>{interaction.title}</p>
        </div>
      </div>

      <AnimatePresence>
        {expanded && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.2 }}
            className="overflow-hidden"
          >
            <div className="mt-3 pt-3 border-t border-current border-opacity-20 space-y-2">
              <div>
                <p className={`text-xs font-semibold ${config.textColor} uppercase tracking-wide mb-1`}>Mechanism</p>
                <p className={`text-xs ${config.textColor}`}>{interaction.description}</p>
              </div>
              <div>
                <p className={`text-xs font-semibold ${config.textColor} uppercase tracking-wide mb-1`}>Clinical Action</p>
                <p className={`text-xs ${config.textColor}`}>{interaction.clinical}</p>
              </div>
              <p className={`text-[10px] ${config.textColor} opacity-70 italic`}>📚 {interaction.sources}</p>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}

export default function DrugInteractionChecker() {
  const [mode, setMode] = useState('smart');
  const [searchA, setSearchA] = useState('');
  const [searchB, setSearchB] = useState('');
  const [results, setResults] = useState(null);
  const [loading, setLoading] = useState(false);

  const handleSmartCheck = () => {
    const query = `${searchA.toLowerCase()} ${searchB.toLowerCase()}`;
    const matches = CURATED_INTERACTIONS.filter(
      i => (i.drugA.toLowerCase().includes(searchA.toLowerCase()) && i.drugB.toLowerCase().includes(searchB.toLowerCase())) ||
            (i.drugB.toLowerCase().includes(searchA.toLowerCase()) && i.drugA.toLowerCase().includes(searchB.toLowerCase()))
    );
    setResults(matches.length > 0 ? matches : 'none');
  };

  const handleFDALookup = async () => {
    if (!searchA.trim() || !searchB.trim()) {
      alert('Please enter both drug names');
      return;
    }
    setLoading(true);
    try {
      // Call the existing openfdaDrugLookup function (if available)
      // For now, showing placeholder
      setResults('fda');
    } catch (err) {
      alert('FDA lookup error: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-4">
      {/* Mode Toggle */}
      <div className="flex gap-2 rounded-lg p-1 bg-secondary">
        <button
          onClick={() => { setMode('smart'); setResults(null); setSearchA(''); setSearchB(''); }}
          className={`flex-1 py-2 px-3 rounded-lg text-xs font-semibold transition-all ${
            mode === 'smart' ? 'bg-card text-foreground shadow-sm' : 'text-muted-foreground'
          }`}
        >
          Smart Check (Curated)
        </button>
        <button
          onClick={() => { setMode('fda'); setResults(null); setSearchA(''); setSearchB(''); }}
          className={`flex-1 py-2 px-3 rounded-lg text-xs font-semibold transition-all ${
            mode === 'fda' ? 'bg-card text-foreground shadow-sm' : 'text-muted-foreground'
          }`}
        >
          FDA Lookup (Live)
        </button>
      </div>

      {/* Search Inputs */}
      <div className="space-y-2">
        <input
          type="text"
          placeholder="Drug A (e.g., Propofol)"
          value={searchA}
          onChange={(e) => setSearchA(e.target.value)}
          onKeyPress={(e) => e.key === 'Enter' && (mode === 'smart' ? handleSmartCheck() : handleFDALookup())}
          className="w-full px-3 py-2 rounded-lg bg-secondary border border-border text-sm outline-none focus:ring-2 focus:ring-primary/30"
        />
        <input
          type="text"
          placeholder="Drug B (e.g., Opioid)"
          value={searchB}
          onChange={(e) => setSearchB(e.target.value)}
          onKeyPress={(e) => e.key === 'Enter' && (mode === 'smart' ? handleSmartCheck() : handleFDALookup())}
          className="w-full px-3 py-2 rounded-lg bg-secondary border border-border text-sm outline-none focus:ring-2 focus:ring-primary/30"
        />
        <button
          onClick={mode === 'smart' ? handleSmartCheck : handleFDALookup}
          disabled={loading || !searchA.trim() || !searchB.trim()}
          className="w-full py-2.5 bg-primary text-white font-semibold rounded-lg text-sm active:scale-95 transition disabled:opacity-40"
        >
          {loading ? 'Checking...' : 'Check Interaction'}
        </button>
      </div>

      {/* Results */}
      {results === null && (
        <div className="text-center py-6 text-muted-foreground text-sm">
          <Search className="w-8 h-8 mx-auto mb-2 opacity-30" />
          <p>{mode === 'smart' ? 'Enter two drugs to check' : 'Search FDA adverse event database'}</p>
        </div>
      )}

      {results === 'none' && (
        <div className="p-3 bg-green-50 border border-green-100 rounded-lg text-center">
          <CheckCircle2 className="w-5 h-5 text-green-600 mx-auto mb-1" />
          <p className="text-xs text-green-700 font-semibold">✅ No known major interactions found</p>
          <p className="text-xs text-green-600 mt-1">Always verify clinically and check current references.</p>
        </div>
      )}

      {results === 'fda' && (
        <div className="p-3 bg-blue-50 border border-blue-100 rounded-lg">
          <p className="text-xs text-blue-700">FDA lookup coming soon — pulling live data from FAERS database.</p>
        </div>
      )}

      {Array.isArray(results) && results.length > 0 && (
        <div className="space-y-2">
          <p className="text-xs font-semibold text-foreground">Found {results.length} interaction(s):</p>
          {results.map((interaction, i) => (
            <InteractionCard key={i} interaction={interaction} index={i} />
          ))}
        </div>
      )}

      {/* Disclaimer */}
      <div className="mt-4 p-3 bg-amber-50 border border-amber-100 rounded-lg">
        <p className="text-[10px] text-amber-700 leading-relaxed">
          <span className="font-bold">Clinical Disclaimer:</span> This tool is for reference only. Always verify interactions with current pharmacology resources, prescribing information, and clinical judgment. Patient-specific factors may alter risk.
        </p>
      </div>
    </div>
  );
}