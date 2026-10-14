// Pixel-matched to the real LumaAcademy main view at 373px:
// header → Flashcard Decks group (purple card) → Course Library group →
// 4 labeled section cards (teal, blue, emerald, amber).
// Text-bar heights: titles h-5 (text-sm leading-snug), subtitles h-4 (text-xs),
// labels h-3.5 (text-xs). Multi-line wrapping matches the real text breaks.

function CardBlock({ border, grad, icon, titleLines, subLines }) {
  return (
    <div className={`rounded-2xl border ${border} bg-gradient-to-br ${grad} overflow-hidden shadow-sm`}>
      <div className="flex items-center gap-3 p-4">
        <div className={`w-10 h-10 rounded-xl bg-gradient-to-br ${icon} shrink-0 shadow-md`} />
        <div className="flex-1 min-w-0">
          <div className="space-y-0.5">
            {titleLines.map((w, i) => (
              <div key={i} className={`h-5 ${w} rounded-md bg-muted/70 animate-pulse`} />
            ))}
          </div>
          <div className="mt-0.5 space-y-0.5">
            {subLines.map((w, i) => (
              <div key={i} className={`h-4 ${w} rounded-full bg-muted/50 animate-pulse`} />
            ))}
          </div>
        </div>
        <div className="w-4 h-4 rounded-full bg-muted/50 animate-pulse shrink-0" />
      </div>
    </div>
  );
}

const PURPLE_CARD = {
  border: 'border-purple-200',
  grad: 'from-purple-50 to-purple-100',
  icon: 'from-purple-600 to-purple-700',
  titleLines: ['w-44', 'w-32'], // "Anesthesia (NBCRNA & ABA)" / "Flashcard Library"
  subLines: ['w-52', 'w-20'],  // "16 decks · Pharmacology, Physiology," / "Airway & more"
};

const SECTIONS = [
  {
    label: 'w-72', // "NBCRNA NCE Review and Practice Questions"
    border: 'border-teal-200', grad: 'from-teal-50 to-teal-100', icon: 'from-teal-700 to-teal-800',
    titleLines: ['w-44'], subLines: ['w-52', 'w-32'],
  },
  {
    label: 'w-20', // "ABA BASIC"
    border: 'border-blue-200', grad: 'from-blue-50 to-blue-100', icon: 'from-blue-700 to-blue-800',
    titleLines: ['w-44'], subLines: ['w-52', 'w-24'],
  },
  {
    label: 'w-24', // "ABA ADVANCED"
    border: 'border-emerald-200', grad: 'from-emerald-50 to-emerald-100', icon: 'from-emerald-700 to-emerald-800',
    titleLines: ['w-48'], subLines: ['w-52', 'w-16'],
  },
  {
    label: 'w-36', // "Clinical Onboarding"
    border: 'border-amber-200', grad: 'from-amber-50 to-amber-100', icon: 'from-amber-700 to-amber-900',
    titleLines: ['w-44'], subLines: ['w-56', 'w-56', 'w-20'],
  },
];

export default function AcademySkeleton() {
  return (
    <div className="flex flex-col pb-20">
      {/* Header */}
      <div className="px-4 md:px-6 pt-4 pb-4 sticky top-0 z-10 bg-background border-b border-border/40 shadow-sm">
        {/* Breadcrumb: Home › Luma Academy */}
        <div className="flex items-center gap-1.5 mb-4 text-xs px-1">
          <div className="h-3.5 w-8 rounded-full bg-muted animate-pulse" />
          <div className="w-3.5 h-3.5 rounded-full bg-muted animate-pulse" />
          <div className="h-3.5 w-20 rounded-full bg-muted animate-pulse" />
        </div>
        <div className="flex items-center gap-3 mt-2">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-purple-100 to-purple-50 border border-purple-200 shrink-0 shadow-sm" />
          <div className="space-y-0.5">
            <div className="h-5 w-28 rounded-md bg-muted animate-pulse" />
            <div className="h-4 w-40 rounded-full bg-muted animate-pulse" />
          </div>
        </div>
      </div>

      {/* Body */}
      <div className="px-4 md:px-6 pt-6 space-y-4">
        {/* Flashcard Decks group */}
        <div className="mb-1">
          <div className="h-3.5 w-28 rounded-full bg-muted animate-pulse" />
          <div className="h-3.5 w-52 rounded-full bg-muted animate-pulse mt-0.5" />
        </div>
        <CardBlock {...PURPLE_CARD} />

        {/* Course Library group */}
        <div className="mb-1">
          <div className="h-3.5 w-28 rounded-full bg-muted animate-pulse" />
          <div className="h-3.5 w-56 rounded-full bg-muted animate-pulse mt-0.5" />
        </div>

        {/* Labeled section cards */}
        {SECTIONS.map((s, i) => (
          <div key={i} className="mt-6">
            <div className={`h-3.5 ${s.label} rounded-full bg-muted animate-pulse mb-2`} />
            <CardBlock {...s} />
          </div>
        ))}
      </div>
    </div>
  );
}