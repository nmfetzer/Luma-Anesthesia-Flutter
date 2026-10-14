import { useEffect, useState, useRef } from 'react';
import { useScrollReset } from '@/components/ScrollToTop';
import { useSearchParams, useNavigate, useLocation } from 'react-router-dom';
import { GraduationCap, ChevronRight, CheckCircle2, BookOpen, ChevronLeft, ChevronDown, ChevronUp, Layers } from 'lucide-react';
import Breadcrumb from '@/components/Breadcrumb';
import FlashcardStudy from './FlashcardStudy';
import NCEReviewGuide from '@/components/academy/NCEReviewGuide';
import NBCRNAAPReviewModule from '@/components/academy/NBCRNAAPReviewModule';
import NCEPracticeTest from '@/components/academy/NCEPracticeTest';
import NCEPracticeTest2 from '@/components/academy/NCEPracticeTest2';
import EquipmentReviewGuide from '@/components/academy/EquipmentReviewGuide';
import EquipmentQuiz from '@/components/academy/EquipmentQuiz';
import ABAAnatomyModule from '@/components/academy/ABAAnatomyModule';
import ABAPhysiologyModule from '@/components/academy/ABAPhysiologyModule';
import ABAPharmacologyModule from '@/components/academy/ABAPharmacologyModule';
import ABAEquipmentModule from '@/components/academy/ABAEquipmentModule';
import ABAClinicalproceduresModule from '@/components/academy/ABAClinicalproceduresModule';
import ABASubspecialtyModule from '@/components/academy/ABASubspecialtyModule';
import ABASpecialProblemsModule from '@/components/academy/ABASpecialProblemsModule';
import ABAOrganDiseaseModule from '@/components/academy/ABAOrganDiseaseModule';
import ABAPracticeExam from '@/components/academy/ABAPracticeExam';
import ABAAdvancedAdultPedsModule from '@/components/academy/ABAAdvancedAdultPedsModule';
import ABAAdvancedObstetricModule from '@/components/academy/ABAAdvancedObstetricModule';
import ABAAdvancedCardiothoracicModule from '@/components/academy/ABAAdvancedCardiothoracicModule';
import ABAAdvancedNeuroModule from '@/components/academy/ABAAdvancedNeuroModule';
import ABAAdvancedRegionalPainModule from '@/components/academy/ABAAdvancedRegionalPainModule';
import ABAAdvancedCriticalCareModule from '@/components/academy/ABAAdvancedCriticalCareModule';
import ABAAdvancedEthicsModule from '@/components/academy/ABAAdvancedEthicsModule';
import FirstDayORModule from '@/components/academy/FirstDayORModule';
import { base44 } from '@/api/base44Client';
import { useEntitlement } from '@/hooks/useEntitlement';
import PaywallModal from '@/components/PaywallModal';
import { FreeBadge, LockBadge, LockThumbnail, AcademyLegend, FreePreviewBadge } from '@/components/academy/GatingBadges';
import CoursePreviewPaywall from '@/components/academy/CoursePreviewPaywall';
import OfflineBanner from '@/components/states/OfflineBanner';

// First module of each course library is free to preview without a subscription.
const FREE_PREVIEW_GUIDES = new Set(['nce', 'aba-anatomy', 'aba-advanced-adult-peds', 'first-day-or']);
const COURSE_INFO = {
  'nce': { name: 'NBCRNA NCE Study Library', modules: 5 },
  'aba-anatomy': { name: 'ABA BASIC Study Library', modules: 8 },
  'aba-advanced-adult-peds': { name: 'ABA ADVANCED Study Library', modules: 7 },
  'first-day-or': { name: 'Clinical Onboarding', modules: 1 },
};

const FLASHCARD_DECKS = [
{ id: 'pharm_induction', emoji: '💉', label: 'Induction & Inhaled Agents', color: 'bg-yellow-50 border-yellow-100', badgeColor: 'bg-yellow-100 text-yellow-700' },
{ id: 'pharm_opioids', emoji: '🩹', label: 'Opioids', color: 'bg-blue-50 border-blue-100', badgeColor: 'bg-blue-100 text-blue-700' },
{ id: 'pharm_la', emoji: '🧪', label: 'Local Anesthetics', color: 'bg-slate-50 border-slate-100', badgeColor: 'bg-slate-100 text-slate-700' },
{ id: 'pharm_nmb', emoji: '💉', label: 'Neuromuscular Blockers', color: 'bg-violet-50 border-violet-100', badgeColor: 'bg-violet-100 text-violet-700' },
{ id: 'pharm_cardio', emoji: '💊', label: 'Cardiovascular Drugs', color: 'bg-sky-50 border-sky-100', badgeColor: 'bg-sky-100 text-sky-700' },
{ id: 'physio_cardio', emoji: '❤️', label: 'Cardiovascular Physiology', color: 'bg-red-50 border-red-100', badgeColor: 'bg-red-100 text-red-700' },
{ id: 'physio_pulmonary', emoji: '🫁', label: 'Pulmonary Physiology', color: 'bg-cyan-50 border-cyan-100', badgeColor: 'bg-cyan-100 text-cyan-700' },
{ id: 'physio_neuro', emoji: '🧠', label: 'Neurology & Neuroanesthesia', color: 'bg-purple-50 border-purple-100', badgeColor: 'bg-purple-100 text-purple-700' },
{ id: 'physio_renal', emoji: '🫘', label: 'Renal, Endocrine & GI', color: 'bg-green-50 border-green-100', badgeColor: 'bg-green-100 text-green-700' },
{ id: 'airway_management', emoji: '😮‍💨', label: 'Airway Management', color: 'bg-amber-50 border-amber-100', badgeColor: 'bg-amber-100 text-amber-700' },
{ id: 'regional_neuraxial', emoji: '🩺', label: 'Regional & Neuraxial', color: 'bg-teal-50 border-teal-100', badgeColor: 'bg-teal-100 text-teal-700' },
{ id: 'ob_anesthesia', emoji: '🤰', label: 'Obstetric Anesthesia', color: 'bg-rose-50 border-rose-100', badgeColor: 'bg-rose-100 text-rose-700' },
{ id: 'peds_anesthesia', emoji: '👶', label: 'Pediatric Anesthesia', color: 'bg-pink-50 border-pink-100', badgeColor: 'bg-pink-100 text-pink-700' },
{ id: 'pacu_crisis', emoji: '🚨', label: 'PACU & Crisis Management', color: 'bg-orange-50 border-orange-100', badgeColor: 'bg-orange-100 text-orange-700' },
{ id: 'cardiac_thoracic', emoji: '🫀', label: 'Cardiac, Thoracic & Trauma', color: 'bg-red-50 border-red-100', badgeColor: 'bg-red-100 text-red-700' },
{ id: 'equipment_monitoring', emoji: '🔧', label: 'Equipment & Monitoring', color: 'bg-blue-50 border-blue-100', badgeColor: 'bg-blue-100 text-blue-700' }];


export default function LumaAcademy() {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const location = useLocation();
  const deckId = searchParams.get('deck') || null;
  const activeDeck = deckId ? FLASHCARD_DECKS.find((d) => d.id === deckId) : null;
  const [progressMap, setProgressMap] = useState({}); // set_id -> FlashcardProgress record
  const [flashcardsOpen, setFlashcardsOpen] = useState(false);
  const [nceOpen, setNceOpen] = useState(false);
  const [abaOpen, setAbaOpen] = useState(false);
  const [abaAdvancedOpen, setAbaAdvancedOpen] = useState(false);
  const { isEntitled, checking } = useEntitlement();
  const [paywallOpen, setPaywallOpen] = useState(false);

  useEffect(() => {
    async function loadProgress() {
      const me = await base44.auth.me().catch(() => null);
      if (!me) return;
      const records = await base44.entities.FlashcardProgress.filter({ user_id: me.id }).catch(() => []);
      const map = {};
      for (const r of records || []) map[r.set_id] = r;
      setProgressMap(map);
    }
    loadProgress();
  }, [deckId]); // re-fetch when returning from a deck

  const setActiveDeck = (deck) => {
    const params = new URLSearchParams(location.search);
    if (!deck) { params.delete('deck'); } else { params.set('deck', deck.id); }
    const search = params.toString();
    navigate(location.pathname + (search ? '?' + search : ''));
  };

  const rawGuide = searchParams.get('guide') || null;
  // Course modules are hard-gated except for the first module of each library,
  // which is a free preview. Non-subscribed users can open those preview guides.
  const guide = (isEntitled || FREE_PREVIEW_GUIDES.has(rawGuide)) ? rawGuide : null;
  // Reset scroll when navigating into/out of a deck or module view
  useScrollReset([deckId, guide]);
  const setGuide = (g) => {
    const params = new URLSearchParams(location.search);
    if (!g) { params.delete('guide'); } else { params.set('guide', g); }
    const search = params.toString();
    navigate(location.pathname + (search ? '?' + search : ''));
  };
  // Hard gate for course modules — non-subscribed users get the paywall,
  // unless the guide is a free-preview module.
  const openGuide = (g) => {
    if (!isEntitled && !FREE_PREVIEW_GUIDES.has(g)) {
      setPaywallOpen(true);
      return;
    }
    setGuide(g);
  };

  if (activeDeck) {
    return (
      <FlashcardStudy
        setId={activeDeck.id}
        title={`${activeDeck.emoji} ${activeDeck.label}`}
        onBack={() => setActiveDeck(null)} />);


  }

  if (guide === 'nce') {
    return (
      <div className="flex flex-col">
        <div className="px-4 md:px-6 pt-4 pb-3 bg-background border-b border-border/50 sticky top-0 z-10">
          <button onClick={() => setGuide(null)} className="flex items-center gap-1 text-primary text-sm font-medium mb-2 min-h-[44px]">
            <ChevronLeft className="w-4 h-4" /> Luma Academy
          </button>
          <h1 className="font-heading font-bold text-lg text-foreground leading-none">NBCRNA NCE Review</h1>
          <p className="text-xs text-muted-foreground mt-0.5">Comprehensive board exam guide</p>
        </div>
        <div className="px-4 md:px-6 pt-4 pb-20">
          <NCEReviewGuide />
          {!isEntitled && <CoursePreviewPaywall courseName={COURSE_INFO['nce'].name} moduleCount={COURSE_INFO['nce'].modules} onSubscribe={() => setPaywallOpen(true)} onContinue={() => setGuide(null)} />}
        </div>
      </div>);

  }

  if (guide === 'nce-ap-review') {
    return (
      <div className="flex flex-col">
        <div className="px-4 md:px-6 pt-4 pb-3 bg-background border-b border-border/50 sticky top-0 z-10">
          <button onClick={() => setGuide(null)} className="flex items-center gap-1 text-primary text-sm font-medium mb-2 min-h-[44px]">
            <ChevronLeft className="w-4 h-4" /> Luma Academy
          </button>
          <h1 className="font-heading font-bold text-lg text-foreground leading-none">NBCRNA A&P Review</h1>
          <p className="text-xs text-muted-foreground mt-0.5">6 Systems · Anatomy, Physiology & Anesthesia Implications · CE Halo LLC</p>
        </div>
        <div className="px-4 md:px-6 pt-4 pb-20">
          <NBCRNAAPReviewModule />
        </div>
      </div>
    );
  }

  if (guide === 'nce-practice') {
    return (
      <div className="flex flex-col">
        <div className="px-4 md:px-6 pt-4 pb-3 bg-background border-b border-border/50 sticky top-0 z-10">
          <button onClick={() => setGuide(null)} className="flex items-center gap-1 text-primary text-sm font-medium mb-2 min-h-[44px]">
            <ChevronLeft className="w-4 h-4" /> Luma Academy
          </button>
          <h1 className="font-heading font-bold text-lg text-foreground leading-none">NCE Practice Test</h1>
          <p className="text-xs text-muted-foreground mt-0.5">100 board-style questions with rationales</p>
        </div>
        <div className="px-4 md:px-6 pt-4 pb-20">
          <NCEPracticeTest />
        </div>
      </div>);

  }

  if (guide === 'equipment-quiz') {
    return (
      <div className="flex flex-col">
        <div className="px-4 md:px-6 pt-4 pb-3 bg-background border-b border-border/50 sticky top-0 z-10">
          <button onClick={() => setGuide(null)} className="flex items-center gap-1 text-primary text-sm font-medium mb-2 min-h-[44px]">
            <ChevronLeft className="w-4 h-4" /> Luma Academy
          </button>
          <h1 className="font-heading font-bold text-lg text-foreground leading-none">Equipment Rapid-Fire Quiz</h1>
          <p className="text-xs text-muted-foreground mt-0.5">50 questions · All 12 equipment sections · NBCRNA NCE Prep</p>
        </div>
        <div className="px-4 md:px-6 pt-4 pb-20">
          <EquipmentQuiz />
        </div>
      </div>);

  }

  if (guide === 'equipment-review') {
    return (
      <div className="flex flex-col">
        <div className="px-4 md:px-6 pt-4 pb-3 bg-background border-b border-border/50 sticky top-0 z-10">
          <button onClick={() => setGuide(null)} className="flex items-center gap-1 text-primary text-sm font-medium mb-2 min-h-[44px]">
            <ChevronLeft className="w-4 h-4" /> Luma Academy
          </button>
          <h1 className="font-heading font-bold text-lg text-foreground leading-none">Anesthesia Equipment Review</h1>
          <p className="text-xs text-muted-foreground mt-0.5">12 sections · NBCRNA NCE Board Review</p>
        </div>
        <div className="px-4 md:px-6 pt-4 pb-20">
          <EquipmentReviewGuide />
        </div>
      </div>);

  }

  if (guide === 'aba-anatomy') {
    return (
      <div className="flex flex-col">
        <div className="px-4 md:px-6 pt-4 pb-3 bg-background border-b border-border/50 sticky top-0 z-10">
          <button onClick={() => setGuide(null)} className="flex items-center gap-1 text-primary text-sm font-medium mb-2 min-h-[44px]">
            <ChevronLeft className="w-4 h-4" /> Luma Academy
          </button>
          <h1 className="font-heading font-bold text-lg text-foreground leading-none">Module 1: Basic Sciences: Anatomy</h1>
          <p className="text-xs text-muted-foreground mt-0.5">ABA BASIC Examination Preparation · CE Halo LLC · 2026</p>
        </div>
        <div className="px-4 md:px-6 pt-4 pb-20">
          <ABAAnatomyModule />
          {!isEntitled && <CoursePreviewPaywall courseName={COURSE_INFO['aba-anatomy'].name} moduleCount={COURSE_INFO['aba-anatomy'].modules} onSubscribe={() => setPaywallOpen(true)} onContinue={() => setGuide(null)} />}
        </div>
      </div>
    );
  }

  if (guide === 'aba-advanced-adult-peds') {
    return (
      <div className="flex flex-col">
        <div className="px-4 md:px-6 pt-4 pb-3 bg-background border-b border-border/50 sticky top-0 z-10">
          <button onClick={() => setGuide(null)} className="flex items-center gap-1 text-primary text-sm font-medium mb-2 min-h-[44px]">
            <ChevronLeft className="w-4 h-4" /> Luma Academy
          </button>
          <h1 className="font-heading font-bold text-lg text-foreground leading-none">Module 1: Adult & Pediatric Anesthesia</h1>
          <p className="text-xs text-muted-foreground mt-0.5">ABA ADVANCED Board Review · Document 1 of 7</p>
        </div>
        <div className="px-4 md:px-6 pt-4 pb-20">
          <ABAAdvancedAdultPedsModule />
          {!isEntitled && <CoursePreviewPaywall courseName={COURSE_INFO['aba-advanced-adult-peds'].name} moduleCount={COURSE_INFO['aba-advanced-adult-peds'].modules} onSubscribe={() => setPaywallOpen(true)} onContinue={() => setGuide(null)} />}
        </div>
      </div>
    );
  }

  if (guide === 'aba-advanced-obstetric') {
    return (
      <div className="flex flex-col">
        <div className="px-4 md:px-6 pt-4 pb-3 bg-background border-b border-border/50 sticky top-0 z-10">
          <button onClick={() => setGuide(null)} className="flex items-center gap-1 text-primary text-sm font-medium mb-2 min-h-[44px]">
            <ChevronLeft className="w-4 h-4" /> Luma Academy
          </button>
          <h1 className="font-heading font-bold text-lg text-foreground leading-none">Module 2: Obstetric Anesthesia</h1>
          <p className="text-xs text-muted-foreground mt-0.5">ABA ADVANCED Board Review · Document 2 of 7 · 45-question quiz</p>
        </div>
        <div className="px-4 md:px-6 pt-4 pb-20">
          <ABAAdvancedObstetricModule />
        </div>
      </div>
    );
  }

  if (guide === 'aba-advanced-cardiothoracic') {
    return (
      <div className="flex flex-col">
        <div className="px-4 md:px-6 pt-4 pb-3 bg-background border-b border-border/50 sticky top-0 z-10">
          <button onClick={() => setGuide(null)} className="flex items-center gap-1 text-primary text-sm font-medium mb-2 min-h-[44px]">
            <ChevronLeft className="w-4 h-4" /> Luma Academy
          </button>
          <h1 className="font-heading font-bold text-lg text-foreground leading-none">Module 3: Cardiothoracic &amp; Vascular Anesthesia</h1>
          <p className="text-xs text-muted-foreground mt-0.5">ABA ADVANCED Board Review · Document 3 of 7 · 45-question quiz</p>
        </div>
        <div className="px-4 md:px-6 pt-4 pb-20">
          <ABAAdvancedCardiothoracicModule />
        </div>
      </div>
    );
  }

  if (guide === 'aba-advanced-ethics') {
    return (
      <div className="flex flex-col">
        <div className="px-4 md:px-6 pt-4 pb-3 bg-background border-b border-border/50 sticky top-0 z-10">
          <button onClick={() => setGuide(null)} className="flex items-center gap-1 text-primary text-sm font-medium mb-2 min-h-[44px]">
            <ChevronLeft className="w-4 h-4" /> Luma Academy
          </button>
          <h1 className="font-heading font-bold text-lg text-foreground leading-none">Module 7: Ethics, Professionalism &amp; Patient Safety</h1>
          <p className="text-xs text-muted-foreground mt-0.5">ABA ADVANCED Board Review · Document 7 of 7 · 35-question quiz</p>
        </div>
        <div className="px-4 md:px-6 pt-4 pb-20">
          <ABAAdvancedEthicsModule />
        </div>
      </div>
    );
  }

  if (guide === 'aba-advanced-critical-care') {
    return (
      <div className="flex flex-col">
        <div className="px-4 md:px-6 pt-4 pb-3 bg-background border-b border-border/50 sticky top-0 z-10">
          <button onClick={() => setGuide(null)} className="flex items-center gap-1 text-primary text-sm font-medium mb-2 min-h-[44px]">
            <ChevronLeft className="w-4 h-4" /> Luma Academy
          </button>
          <h1 className="font-heading font-bold text-lg text-foreground leading-none">Module 6: Critical Care &amp; Perioperative Medicine</h1>
          <p className="text-xs text-muted-foreground mt-0.5">ABA ADVANCED Board Review · Document 6 of 7 · 45-question quiz</p>
        </div>
        <div className="px-4 md:px-6 pt-4 pb-20">
          <ABAAdvancedCriticalCareModule />
        </div>
      </div>
    );
  }

  if (guide === 'aba-advanced-regional-pain') {
    return (
      <div className="flex flex-col">
        <div className="px-4 md:px-6 pt-4 pb-3 bg-background border-b border-border/50 sticky top-0 z-10">
          <button onClick={() => setGuide(null)} className="flex items-center gap-1 text-primary text-sm font-medium mb-2 min-h-[44px]">
            <ChevronLeft className="w-4 h-4" /> Luma Academy
          </button>
          <h1 className="font-heading font-bold text-lg text-foreground leading-none">Module 5: Regional Anesthesia &amp; Pain Management</h1>
          <p className="text-xs text-muted-foreground mt-0.5">ABA ADVANCED Board Review · Document 5 of 7 · 45-question quiz</p>
        </div>
        <div className="px-4 md:px-6 pt-4 pb-20">
          <ABAAdvancedRegionalPainModule />
        </div>
      </div>
    );
  }

  if (guide === 'aba-advanced-neuro') {
    return (
      <div className="flex flex-col">
        <div className="px-4 md:px-6 pt-4 pb-3 bg-background border-b border-border/50 sticky top-0 z-10">
          <button onClick={() => setGuide(null)} className="flex items-center gap-1 text-primary text-sm font-medium mb-2 min-h-[44px]">
            <ChevronLeft className="w-4 h-4" /> Luma Academy
          </button>
          <h1 className="font-heading font-bold text-lg text-foreground leading-none">Module 4: Neuroanesthesia</h1>
          <p className="text-xs text-muted-foreground mt-0.5">ABA ADVANCED Board Review · Document 4 of 7 · 45-question quiz</p>
        </div>
        <div className="px-4 md:px-6 pt-4 pb-20">
          <ABAAdvancedNeuroModule />
        </div>
      </div>
    );
  }

  if (guide === 'aba-practice-exam') {
    return (
      <div className="flex flex-col">
        <div className="px-4 md:px-6 pt-4 pb-3 bg-background border-b border-border/50 sticky top-0 z-10">
          <button onClick={() => setGuide(null)} className="flex items-center gap-1 text-primary text-sm font-medium mb-2 min-h-[44px]">
            <ChevronLeft className="w-4 h-4" /> Luma Academy
          </button>
          <h1 className="font-heading font-bold text-lg text-foreground leading-none">ABA BASIC Practice Examination</h1>
          <p className="text-xs text-muted-foreground mt-0.5">301 Questions · 9 Sections · CE Halo LLC · 2026</p>
        </div>
        <div className="px-4 md:px-6 pt-4 pb-20">
          <ABAPracticeExam onBack={() => setGuide(null)} />
        </div>
      </div>
    );
  }

  if (guide === 'aba-organ-disease') {
    return (
      <div className="flex flex-col">
        <div className="px-4 md:px-6 pt-4 pb-3 bg-background border-b border-border/50 sticky top-0 z-10">
          <button onClick={() => setGuide(null)} className="flex items-center gap-1 text-primary text-sm font-medium mb-2 min-h-[44px]">
            <ChevronLeft className="w-4 h-4" /> Luma Academy
          </button>
          <h1 className="font-heading font-bold text-lg text-foreground leading-none">Module 8: Clinical Sciences: Organ Based & Coexisting Diseases</h1>
          <p className="text-xs text-muted-foreground mt-0.5">ABA BASIC Examination Preparation · CE Halo LLC · 2026</p>
        </div>
        <div className="px-4 md:px-6 pt-4 pb-20">
          <ABAOrganDiseaseModule />
        </div>
      </div>
    );
  }

  if (guide === 'aba-special-problems') {
    return (
      <div className="flex flex-col">
        <div className="px-4 md:px-6 pt-4 pb-3 bg-background border-b border-border/50 sticky top-0 z-10">
          <button onClick={() => setGuide(null)} className="flex items-center gap-1 text-primary text-sm font-medium mb-2 min-h-[44px]">
            <ChevronLeft className="w-4 h-4" /> Luma Academy
          </button>
          <h1 className="font-heading font-bold text-lg text-foreground leading-none">Module 7: Special Problems & Patient Issues</h1>
          <p className="text-xs text-muted-foreground mt-0.5">ABA BASIC Examination Preparation · CE Halo LLC · 2026</p>
        </div>
        <div className="px-4 md:px-6 pt-4 pb-20">
          <ABASpecialProblemsModule />
        </div>
      </div>
    );
  }

  if (guide === 'aba-subspecialty') {
    return (
      <div className="flex flex-col">
        <div className="px-4 md:px-6 pt-4 pb-3 bg-background border-b border-border/50 sticky top-0 z-10">
          <button onClick={() => setGuide(null)} className="flex items-center gap-1 text-primary text-sm font-medium mb-2 min-h-[44px]">
            <ChevronLeft className="w-4 h-4" /> Luma Academy
          </button>
          <h1 className="font-heading font-bold text-lg text-foreground leading-none">Module 6: Subspecialty Anesthesia</h1>
          <p className="text-xs text-muted-foreground mt-0.5">ABA BASIC Examination Preparation · CE Halo LLC · 2026</p>
        </div>
        <div className="px-4 md:px-6 pt-4 pb-20">
          <ABASubspecialtyModule />
        </div>
      </div>
    );
  }

  if (guide === 'aba-clinical-procedures') {
    return (
      <div className="flex flex-col">
        <div className="px-4 md:px-6 pt-4 pb-3 bg-background border-b border-border/50 sticky top-0 z-10">
          <button onClick={() => setGuide(null)} className="flex items-center gap-1 text-primary text-sm font-medium mb-2 min-h-[44px]">
            <ChevronLeft className="w-4 h-4" /> Luma Academy
          </button>
          <h1 className="font-heading font-bold text-lg text-foreground leading-none">Module 5: Clinical Sciences: Procedures, Methods & Techniques</h1>
          <p className="text-xs text-muted-foreground mt-0.5">ABA BASIC Examination Preparation · CE Halo LLC · 2026</p>
        </div>
        <div className="px-4 md:px-6 pt-4 pb-20">
          <ABAClinicalproceduresModule />
        </div>
      </div>
    );
  }

  if (guide === 'aba-equipment') {
    return (
      <div className="flex flex-col">
        <div className="px-4 md:px-6 pt-4 pb-3 bg-background border-b border-border/50 sticky top-0 z-10">
          <button onClick={() => setGuide(null)} className="flex items-center gap-1 text-primary text-sm font-medium mb-2 min-h-[44px]">
            <ChevronLeft className="w-4 h-4" /> Luma Academy
          </button>
          <h1 className="font-heading font-bold text-lg text-foreground leading-none">Module 4: Anesthesia Equipment & Monitoring</h1>
          <p className="text-xs text-muted-foreground mt-0.5">ABA BASIC Examination Preparation · CE Halo LLC · 2026</p>
        </div>
        <div className="px-4 md:px-6 pt-4 pb-20">
          <ABAEquipmentModule />
        </div>
      </div>
    );
  }

  if (guide === 'aba-pharmacology') {
    return (
      <div className="flex flex-col">
        <div className="px-4 md:px-6 pt-4 pb-3 bg-background border-b border-border/50 sticky top-0 z-10">
          <button onClick={() => setGuide(null)} className="flex items-center gap-1 text-primary text-sm font-medium mb-2 min-h-[44px]">
            <ChevronLeft className="w-4 h-4" /> Luma Academy
          </button>
          <h1 className="font-heading font-bold text-lg text-foreground leading-none">Module 3: Basic Sciences: Pharmacology</h1>
          <p className="text-xs text-muted-foreground mt-0.5">ABA BASIC Examination Preparation · CE Halo LLC · 2026</p>
        </div>
        <div className="px-4 md:px-6 pt-4 pb-20">
          <ABAPharmacologyModule />
        </div>
      </div>
    );
  }

  if (guide === 'aba-physiology') {
    return (
      <div className="flex flex-col">
        <div className="px-4 md:px-6 pt-4 pb-3 bg-background border-b border-border/50 sticky top-0 z-10">
          <button onClick={() => setGuide(null)} className="flex items-center gap-1 text-primary text-sm font-medium mb-2 min-h-[44px]">
            <ChevronLeft className="w-4 h-4" /> Luma Academy
          </button>
          <h1 className="font-heading font-bold text-lg text-foreground leading-none">Module 2: Basic Sciences: Physiology</h1>
          <p className="text-xs text-muted-foreground mt-0.5">ABA BASIC Examination Preparation · CE Halo LLC · 2026</p>
        </div>
        <div className="px-4 md:px-6 pt-4 pb-20">
          <ABAPhysiologyModule />
        </div>
      </div>
    );
  }

  if (guide === 'first-day-or') {
    return (
      <div className="flex flex-col">
        <div className="px-4 md:px-6 pt-4 pb-3 bg-background border-b border-border/50 sticky top-0 z-10">
          <button onClick={() => setGuide(null)} className="flex items-center gap-1 text-primary text-sm font-medium mb-2 min-h-[44px]">
            <ChevronLeft className="w-4 h-4" /> Luma Academy
          </button>
          <h1 className="font-heading font-bold text-lg text-foreground leading-none">The First Days in the OR</h1>
          <p className="text-xs text-muted-foreground mt-0.5">Clinical Onboarding Module · CE Halo LLC</p>
        </div>
        <div className="px-4 md:px-6 pt-4 pb-20">
          <FirstDayORModule />
          {!isEntitled && <CoursePreviewPaywall courseName={COURSE_INFO['first-day-or'].name} moduleCount={COURSE_INFO['first-day-or'].modules} onSubscribe={() => setPaywallOpen(true)} onContinue={() => setGuide(null)} />}
        </div>
      </div>
    );
  }

  if (guide === 'nce-practice-2') {
    return (
      <div className="flex flex-col">
        <div className="px-4 md:px-6 pt-4 pb-3 bg-background border-b border-border/50 sticky top-0 z-10">
          <button onClick={() => setGuide(null)} className="flex items-center gap-1 text-primary text-sm font-medium mb-2 min-h-[44px]">
            <ChevronLeft className="w-4 h-4" /> Luma Academy
          </button>
          <h1 className="font-heading font-bold text-lg text-foreground leading-none">NCE Practice Test #2</h1>
          <p className="text-xs text-muted-foreground mt-0.5">100 board-style questions with rationales</p>
        </div>
        <div className="px-4 md:px-6 pt-4 pb-20">
          <NCEPracticeTest2 />
        </div>
      </div>);

  }

  return (
    <div className="flex flex-col pb-20">
      <PaywallModal open={paywallOpen} onClose={() => setPaywallOpen(false)} />
      <OfflineBanner />
      {/* Header */}
      <div className="px-4 md:px-6 pt-4 pb-4 sticky top-0 z-10 bg-background border-b border-border/40 shadow-sm">
        <Breadcrumb pages={[{ label: 'Luma Academy' }]} />
        <div className="flex items-center gap-3 mt-2">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-purple-100 to-purple-50 border border-purple-200 flex items-center justify-center shadow-sm">
            <GraduationCap className="w-5 h-5 text-purple-600" strokeWidth={1.5} />
          </div>
          <div>
            <h1 className="font-heading font-bold text-lg text-foreground leading-tight">Luma Academy</h1>
            <p className="text-xs text-muted-foreground font-medium">Clinical education modules</p>
          </div>
        </div>
      </div>

      <div className="px-4 md:px-6 pt-6 space-y-4">
        {!checking && !isEntitled && <AcademyLegend />}

        <div className="mb-1">
          <p className="text-xs font-bold text-muted-foreground uppercase tracking-widest">Flashcard Decks</p>
          <p className="text-xs text-muted-foreground/80 mt-0.5">First 5 cards free in every deck</p>
        </div>

        {/* Collapsed flashcard box */}
        <div className="rounded-2xl border border-purple-200 bg-gradient-to-br from-purple-50 to-purple-100 overflow-hidden shadow-sm hover:shadow-md transition-shadow">
          <button
            onClick={() => setFlashcardsOpen((o) => !o)}
            className="w-full flex items-center gap-3 p-4 text-left active:scale-[0.98] transition-all hover:bg-purple-100/30">
            
            <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-purple-600 to-purple-700 flex items-center justify-center shrink-0 shadow-md">
              <Layers className="w-5 h-5 text-white" strokeWidth={1.5} />
            </div>
            <div className="flex-1 min-w-0">
              <p className="font-bold text-sm text-foreground leading-[1.4]">Anesthesia (NBCRNA & ABA)Flashcard Library</p>
              <p className="text-xs text-muted-foreground mt-0.5">{FLASHCARD_DECKS.length} decks · Pharmacology, Physiology, Airway & more</p>
            </div>
            {flashcardsOpen ? <ChevronUp className="w-4 h-4 text-muted-foreground shrink-0" /> : <ChevronDown className="w-4 h-4 text-muted-foreground shrink-0" />}
          </button>

          {flashcardsOpen &&
          <div className="border-t border-purple-200 bg-background/50 divide-y divide-border/40">
              {FLASHCARD_DECKS.map((deck) => {
              const prog = progressMap[deck.id];
              const seen = prog?.cards_completed || 0;
              const total = prog?.total_cards || 0;
              const completed = prog?.completed || false;
              const started = seen > 0;

              return (
                <button
                  key={deck.id}
                  onClick={() => setActiveDeck(deck)}
                  className="relative w-full flex items-center gap-3 px-4 py-3.5 text-left hover:bg-primary/5 active:scale-[0.98] transition-all">
                  <FreeBadge show={!isEntitled} />
                  
                    <span className="text-xl shrink-0">{deck.emoji}</span>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-1.5">
                        <p className="font-semibold text-sm text-foreground leading-[1.4]">{deck.label}</p>
                        {completed && <CheckCircle2 className="w-3.5 h-3.5 text-green-500 shrink-0" />}
                      </div>
                      {started && total > 0 ?
                    <div className="flex items-center gap-2 mt-1">
                          <div className="flex-1 h-1 bg-black/10 rounded-full overflow-hidden">
                            <div
                          className={`h-1 rounded-full transition-all ${completed ? 'bg-green-500' : 'bg-primary'}`}
                          style={{ width: `${seen / total * 100}%` }} />
                        
                          </div>
                          <span className={`text-xs font-semibold shrink-0 ${completed ? 'text-green-600' : 'text-muted-foreground'}`}>
                            {seen}/{total}
                          </span>
                        </div> :

                    <span className={`inline-block mt-0.5 text-xs font-semibold px-1.5 py-0.5 rounded-full ${deck.badgeColor}`}>
                          Flashcards
                        </span>
                    }
                    </div>
                    <ChevronRight className="w-4 h-4 text-muted-foreground shrink-0" />
                  </button>);

            })}
            </div>
          }
        </div>

        <div className="mb-1">
          <p className="text-xs font-bold text-muted-foreground uppercase tracking-widest">Course Library</p>
          <p className="text-xs text-muted-foreground/80 mt-0.5">Premium content — subscribe to unlock</p>
        </div>

        {/* NBCRNA NCE Review and Practice Questions */}
        <div className="mt-6">
          <p className="text-xs font-bold text-muted-foreground uppercase tracking-widest mb-2">NBCRNA NCE Review and Practice Questions</p>

          <div className="rounded-2xl border border-teal-200 bg-gradient-to-br from-teal-50 to-teal-100 overflow-hidden shadow-sm hover:shadow-md transition-shadow">
            <button
              onClick={() => setNceOpen((o) => !o)}
              className="w-full flex items-center gap-3 p-4 text-left active:scale-[0.98] transition-all hover:bg-teal-100/30">
              
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-teal-700 to-teal-800 flex items-center justify-center shrink-0 shadow-md">
                <BookOpen className="w-5 h-5 text-white" strokeWidth={1.5} />
              </div>
              <div className="flex-1 min-w-0">
                <p className="font-bold text-sm text-foreground leading-[1.4]">NBCRNA NCE Study Library</p>
                <p className="text-xs text-muted-foreground mt-0.5">5 modules · Review guides, practice tests & equipment</p>
              </div>
              {nceOpen ? <ChevronUp className="w-4 h-4 text-muted-foreground shrink-0" /> : <ChevronDown className="w-4 h-4 text-muted-foreground shrink-0" />}
            </button>

            {nceOpen &&
            <div className="border-t border-teal-200 bg-background/50 divide-y divide-border/40">
                <button onClick={() => openGuide('nce')} className="w-full flex items-center gap-3 px-4 py-3.5 text-left hover:bg-primary/5 active:scale-[0.98] transition-all">
                  <LockThumbnail emoji="📖" locked={false} />
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <p className="font-semibold text-sm text-foreground leading-[1.4]">NBCRNA NCE Comprehensive Review</p>
                      {!isEntitled && <span className="text-[10px] font-bold px-1.5 py-0.5 rounded-full bg-emerald-500 text-white whitespace-nowrap shrink-0">FREE PREVIEW</span>}
                    </div>
                    <p className="text-xs text-muted-foreground mt-0.5">All 4 domains · High-yield tables · Clinical pearls · 2024-2026</p>
                  </div>
                  <ChevronRight className="w-4 h-4 text-muted-foreground shrink-0" />
                </button>
                <button onClick={() => openGuide('nce-ap-review')} className="w-full flex items-center gap-3 px-4 py-3.5 text-left hover:bg-primary/5 active:scale-[0.98] transition-all">
                  <LockThumbnail emoji="🧬" locked={!isEntitled} />
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-sm text-foreground leading-[1.4]">NBCRNA A&P Review</p>
                    <p className="text-xs text-muted-foreground mt-0.5">6 Systems · CV, Respiratory, Renal, Neuro, Endocrine, Hepatic · CE Halo LLC</p>
                  </div>
                  <ChevronRight className="w-4 h-4 text-muted-foreground shrink-0" />
                </button>
                <button onClick={() => openGuide('equipment-review')} className="w-full flex items-center gap-3 px-4 py-3.5 text-left hover:bg-primary/5 active:scale-[0.98] transition-all">
                  <LockThumbnail emoji="⚙️" locked={!isEntitled} />
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-sm text-foreground leading-[1.4]">Anesthesia Equipment Review Module</p>
                    <p className="text-xs text-muted-foreground mt-0.5">Gas supply, airway, circuits, monitors · 12 Sections · 2025</p>
                  </div>
                  <ChevronRight className="w-4 h-4 text-muted-foreground shrink-0" />
                </button>
                <button onClick={() => openGuide('nce-practice')} className="w-full flex items-center gap-3 px-4 py-3.5 text-left hover:bg-primary/5 active:scale-[0.98] transition-all">
                  <LockThumbnail emoji="📝" locked={!isEntitled} />
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-sm text-foreground leading-[1.4]">NCE Practice Test — 100 Questions</p>
                    <p className="text-xs text-muted-foreground mt-0.5">Board-style questions · Detailed rationales · Domain scoring · 2026</p>
                  </div>
                  <ChevronRight className="w-4 h-4 text-muted-foreground shrink-0" />
                </button>
                <button onClick={() => openGuide('nce-practice-2')} className="w-full flex items-center gap-3 px-4 py-3.5 text-left hover:bg-primary/5 active:scale-[0.98] transition-all">
                  <LockThumbnail emoji="📝" locked={!isEntitled} />
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-sm text-foreground leading-[1.4]">NCE Practice Test #2 — 100 Questions</p>
                    <p className="text-xs text-muted-foreground mt-0.5">Board-style questions · Detailed rationales · Domain scoring · 2025</p>
                  </div>
                  <ChevronRight className="w-4 h-4 text-muted-foreground shrink-0" />
                </button>
                <button onClick={() => openGuide('equipment-quiz')} className="w-full flex items-center gap-3 px-4 py-3.5 text-left hover:bg-primary/5 active:scale-[0.98] transition-all">
                  <LockThumbnail emoji="⚡" locked={!isEntitled} />
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-sm text-foreground leading-[1.4]">Equipment Rapid-Fire Quiz — 50 Questions</p>
                    <p className="text-xs text-muted-foreground mt-0.5">All 12 sections · Recall + situational reasoning · Target ≥80%</p>
                  </div>
                  <ChevronRight className="w-4 h-4 text-muted-foreground shrink-0" />
                </button>
              </div>
            }
          </div>
        </div>

        {/* ABA BASIC */}
        <div className="mt-6">
          <p className="text-xs font-bold text-muted-foreground uppercase tracking-widest mb-2">ABA BASIC</p>

          <div className="rounded-2xl border border-blue-200 bg-gradient-to-br from-blue-50 to-blue-100 overflow-hidden shadow-sm hover:shadow-md transition-shadow">
            <button
              onClick={() => setAbaOpen(o => !o)}
              className="w-full flex items-center gap-3 p-4 text-left active:scale-[0.98] transition-all hover:bg-blue-100/30"
            >
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-blue-700 to-blue-800 flex items-center justify-center shrink-0 shadow-md">
                <BookOpen className="w-5 h-5 text-white" strokeWidth={1.5} />
              </div>
              <div className="flex-1 min-w-0">
                <p className="font-bold text-sm text-foreground leading-[1.4]">ABA BASIC Study Library</p>
                <p className="text-xs text-muted-foreground mt-0.5">8 modules + Practice Exam · CE Halo LLC · 2026</p>
              </div>
              {abaOpen ? <ChevronUp className="w-4 h-4 text-muted-foreground shrink-0" /> : <ChevronDown className="w-4 h-4 text-muted-foreground shrink-0" />}
            </button>

            {abaOpen && (
              <div className="border-t border-blue-200 bg-background/50 divide-y divide-border/40">
                <button onClick={() => openGuide('aba-anatomy')} className="w-full flex items-center gap-3 px-4 py-3.5 text-left hover:bg-primary/5 active:scale-[0.98] transition-all">
                  <LockThumbnail emoji="🫀" locked={false} />
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <p className="font-semibold text-sm text-foreground leading-[1.4]">Module 1: Basic Sciences: Anatomy</p>
                      {!isEntitled && <span className="text-[10px] font-bold px-1.5 py-0.5 rounded-full bg-emerald-500 text-white whitespace-nowrap shrink-0">FREE PREVIEW</span>}
                    </div>
                    <p className="text-xs text-muted-foreground mt-0.5">Airway, neuraxial, regional, autonomic, cardiac, positioning · 8 sections</p>
                  </div>
                  <ChevronRight className="w-4 h-4 text-muted-foreground shrink-0" />
                </button>
                <button onClick={() => openGuide('aba-physiology')} className="w-full flex items-center gap-3 px-4 py-3.5 text-left hover:bg-primary/5 active:scale-[0.98] transition-all">
                  <LockThumbnail emoji="🫁" locked={!isEntitled} />
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-sm text-foreground leading-[1.4]">Module 2: Basic Sciences: Physiology</p>
                    <p className="text-xs text-muted-foreground mt-0.5">CV, pulmonary, renal, hepatic, neuro, endocrine · 6 sections</p>
                  </div>
                  <ChevronRight className="w-4 h-4 text-muted-foreground shrink-0" />
                </button>
                <button onClick={() => openGuide('aba-pharmacology')} className="w-full flex items-center gap-3 px-4 py-3.5 text-left hover:bg-primary/5 active:scale-[0.98] transition-all">
                  <LockThumbnail emoji="💊" locked={!isEntitled} />
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-sm text-foreground leading-[1.4]">Module 3: Basic Sciences: Pharmacology</p>
                    <p className="text-xs text-muted-foreground mt-0.5">PK/PD, inhaled agents, IV induction, opioids, NMBs, local anesthetics · 7 sections</p>
                  </div>
                  <ChevronRight className="w-4 h-4 text-muted-foreground shrink-0" />
                </button>
                <button onClick={() => openGuide('aba-equipment')} className="w-full flex items-center gap-3 px-4 py-3.5 text-left hover:bg-primary/5 active:scale-[0.98] transition-all">
                  <LockThumbnail emoji="🔧" locked={!isEntitled} />
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-sm text-foreground leading-[1.4]">Module 4: Anesthesia Equipment & Monitoring</p>
                    <p className="text-xs text-muted-foreground mt-0.5">Machine, vaporizers, circuits, ventilation, monitoring, hazards · 6 sections</p>
                  </div>
                  <ChevronRight className="w-4 h-4 text-muted-foreground shrink-0" />
                </button>
                <button onClick={() => openGuide('aba-clinical-procedures')} className="w-full flex items-center gap-3 px-4 py-3.5 text-left hover:bg-primary/5 active:scale-[0.98] transition-all">
                  <LockThumbnail emoji="🩺" locked={!isEntitled} />
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-sm text-foreground leading-[1.4]">Module 5: Clinical Sciences: Procedures, Methods & Techniques</p>
                    <p className="text-xs text-muted-foreground mt-0.5">Preop assessment, airway, vascular access, regional, fluids, PACU · 6 sections</p>
                  </div>
                  <ChevronRight className="w-4 h-4 text-muted-foreground shrink-0" />
                </button>
                <button onClick={() => openGuide('aba-subspecialty')} className="w-full flex items-center gap-3 px-4 py-3.5 text-left hover:bg-primary/5 active:scale-[0.98] transition-all">
                  <LockThumbnail emoji="🫀" locked={!isEntitled} />
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-sm text-foreground leading-[1.4]">Module 6: Subspecialty Anesthesia</p>
                    <p className="text-xs text-muted-foreground mt-0.5">OB, pediatric, cardiac, neuroanesthesia, regional subspecialty · 5 sections</p>
                  </div>
                  <ChevronRight className="w-4 h-4 text-muted-foreground shrink-0" />
                </button>
                <button onClick={() => openGuide('aba-special-problems')} className="w-full flex items-center gap-3 px-4 py-3.5 text-left hover:bg-primary/5 active:scale-[0.98] transition-all">
                  <LockThumbnail emoji="🚨" locked={!isEntitled} />
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-sm text-foreground leading-[1.4]">Module 7: Special Problems & Patient Issues</p>
                    <p className="text-xs text-muted-foreground mt-0.5">MH, anaphylaxis, awareness, electrolytes, geriatrics, obesity, trauma, pain · 8 sections</p>
                  </div>
                  <ChevronRight className="w-4 h-4 text-muted-foreground shrink-0" />
                </button>
                <button onClick={() => openGuide('aba-organ-disease')} className="w-full flex items-center gap-3 px-4 py-3.5 text-left hover:bg-primary/5 active:scale-[0.98] transition-all">
                  <LockThumbnail emoji="🫀" locked={!isEntitled} />
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-sm text-foreground leading-[1.4]">Module 8: Clinical Sciences: Organ Based & Coexisting Diseases</p>
                    <p className="text-xs text-muted-foreground mt-0.5">Pulmonary, CV, neuro, endocrine, renal, hematologic, sepsis, surgical · 8 sections</p>
                  </div>
                  <ChevronRight className="w-4 h-4 text-muted-foreground shrink-0" />
                </button>
                <button onClick={() => openGuide('aba-practice-exam')} className="w-full flex items-center gap-3 px-4 py-3.5 text-left hover:bg-primary/5 active:scale-[0.98] transition-all">
                  <LockThumbnail emoji="📝" locked={!isEntitled} />
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-sm text-foreground leading-[1.4]">ABA BASIC Practice Examination — 301 Questions</p>
                    <p className="text-xs text-muted-foreground mt-0.5">All 9 sections · Board-style MCQs · Detailed rationales · By section or full exam · 2026</p>
                  </div>
                  <ChevronRight className="w-4 h-4 text-muted-foreground shrink-0" />
                </button>
              </div>
            )}
          </div>
        </div>

        {/* ABA ADVANCED */}
        <div className="mt-6">
          <p className="text-xs font-bold text-muted-foreground uppercase tracking-widest mb-2">ABA ADVANCED</p>

          <div className="rounded-2xl border border-emerald-200 bg-gradient-to-br from-emerald-50 to-emerald-100 overflow-hidden shadow-sm hover:shadow-md transition-shadow">
            <button
              onClick={() => setAbaAdvancedOpen(o => !o)}
              className="w-full flex items-center gap-3 p-4 text-left active:scale-[0.98] transition-all hover:bg-emerald-100/30"
            >
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-emerald-700 to-emerald-800 flex items-center justify-center shrink-0 shadow-md">
                <BookOpen className="w-5 h-5 text-white" strokeWidth={1.5} />
              </div>
              <div className="flex-1 min-w-0">
                <p className="font-bold text-sm text-foreground leading-[1.4]">ABA ADVANCED Study Library</p>
                <p className="text-xs text-muted-foreground mt-0.5">7 modules · Complete Board Review Series</p>
              </div>
              {abaAdvancedOpen ? <ChevronUp className="w-4 h-4 text-muted-foreground shrink-0" /> : <ChevronDown className="w-4 h-4 text-muted-foreground shrink-0" />}
            </button>

            {abaAdvancedOpen && (
              <div className="border-t border-emerald-200 bg-background/50 divide-y divide-border/40">
                <button onClick={() => openGuide('aba-advanced-adult-peds')} className="w-full flex items-center gap-3 px-4 py-3.5 text-left hover:bg-primary/5 active:scale-[0.98] transition-all">
                  <LockThumbnail emoji="🎓" locked={false} />
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <p className="font-semibold text-sm text-foreground leading-[1.4]">Module 1: Adult &amp; Pediatric Anesthesia</p>
                      {!isEntitled && <span className="text-[10px] font-bold px-1.5 py-0.5 rounded-full bg-emerald-500 text-white whitespace-nowrap shrink-0">FREE PREVIEW</span>}
                    </div>
                    <p className="text-xs text-muted-foreground mt-0.5">Preop evaluation, airway, pharmacology, NMB, monitoring, peds physiology · 50-question quiz</p>
                  </div>
                  <ChevronRight className="w-4 h-4 text-muted-foreground shrink-0" />
                </button>
                <button onClick={() => openGuide('aba-advanced-obstetric')} className="w-full flex items-center gap-3 px-4 py-3.5 text-left hover:bg-primary/5 active:scale-[0.98] transition-all">
                  <LockThumbnail emoji="🤰" locked={!isEntitled} />
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-sm text-foreground leading-[1.4]">Module 2: Obstetric Anesthesia</p>
                    <p className="text-xs text-muted-foreground mt-0.5">Maternal physiology, labor analgesia, cesarean, hemorrhage, preeclampsia · 45-question quiz</p>
                  </div>
                  <ChevronRight className="w-4 h-4 text-muted-foreground shrink-0" />
                </button>
                <button onClick={() => openGuide('aba-advanced-cardiothoracic')} className="w-full flex items-center gap-3 px-4 py-3.5 text-left hover:bg-primary/5 active:scale-[0.98] transition-all">
                  <LockThumbnail emoji="🫀" locked={!isEntitled} />
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-sm text-foreground leading-[1.4]">Module 3: Cardiothoracic &amp; Vascular Anesthesia</p>
                    <p className="text-xs text-muted-foreground mt-0.5">CPB, valvular disease, CABG, thoracic anesthesia, vascular surgery, mechanical circulatory support · 45-question quiz</p>
                  </div>
                  <ChevronRight className="w-4 h-4 text-muted-foreground shrink-0" />
                </button>
                <button onClick={() => openGuide('aba-advanced-neuro')} className="w-full flex items-center gap-3 px-4 py-3.5 text-left hover:bg-primary/5 active:scale-[0.98] transition-all">
                  <LockThumbnail emoji="🧠" locked={!isEntitled} />
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-sm text-foreground leading-[1.4]">Module 4: Neuroanesthesia</p>
                    <p className="text-xs text-muted-foreground mt-0.5">Cerebral physiology, ICP management, craniotomy, spine surgery, aneurysm, posterior fossa, VAE · 45-question quiz</p>
                  </div>
                  <ChevronRight className="w-4 h-4 text-muted-foreground shrink-0" />
                </button>
                <button onClick={() => openGuide('aba-advanced-regional-pain')} className="w-full flex items-center gap-3 px-4 py-3.5 text-left hover:bg-primary/5 active:scale-[0.98] transition-all">
                  <LockThumbnail emoji="💉" locked={!isEntitled} />
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-sm text-foreground leading-[1.4]">Module 5: Regional Anesthesia &amp; Pain Management</p>
                    <p className="text-xs text-muted-foreground mt-0.5">LAST, neuraxial, UE/LE blocks, truncal blocks, ASRA guidelines, acute &amp; chronic pain · 45-question quiz</p>
                  </div>
                  <ChevronRight className="w-4 h-4 text-muted-foreground shrink-0" />
                </button>
                <button onClick={() => openGuide('aba-advanced-critical-care')} className="w-full flex items-center gap-3 px-4 py-3.5 text-left hover:bg-primary/5 active:scale-[0.98] transition-all">
                  <LockThumbnail emoji="🏥" locked={!isEntitled} />
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-sm text-foreground leading-[1.4]">Module 6: Critical Care &amp; Perioperative Medicine</p>
                    <p className="text-xs text-muted-foreground mt-0.5">Shock, sepsis, ARDS, mechanical ventilation, AKI, transfusion, endocrine emergencies, brain death · 45-question quiz</p>
                  </div>
                  <ChevronRight className="w-4 h-4 text-muted-foreground shrink-0" />
                </button>
                <button onClick={() => openGuide('aba-advanced-ethics')} className="w-full flex items-center gap-3 px-4 py-3.5 text-left hover:bg-primary/5 active:scale-[0.98] transition-all">
                  <LockThumbnail emoji="⚖️" locked={!isEntitled} />
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-sm text-foreground leading-[1.4]">Module 7: Ethics, Professionalism &amp; Patient Safety</p>
                    <p className="text-xs text-muted-foreground mt-0.5">Informed consent, DNR, error disclosure, medication safety, wrong-site surgery, physician SUD · 35-question quiz</p>
                  </div>
                  <ChevronRight className="w-4 h-4 text-muted-foreground shrink-0" />
                </button>
              </div>
            )}
          </div>
        </div>

        {/* Clinical Onboarding */}
        <div className="mt-6">
          <p className="text-xs font-bold text-muted-foreground uppercase tracking-widest mb-2">Clinical Onboarding</p>
          <button
            onClick={() => openGuide('first-day-or')}
            className="w-full rounded-2xl border border-amber-200 bg-gradient-to-br from-amber-50 to-amber-100 overflow-hidden shadow-sm hover:shadow-md transition-shadow flex items-center gap-3 p-4 text-left active:scale-[0.98]"
          >
            <div className="relative w-10 h-10 rounded-xl bg-gradient-to-br from-amber-700 to-amber-900 flex items-center justify-center shrink-0 shadow-md">
              <span className="text-xl">🏥</span>
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2">
                <p className="font-bold text-sm text-foreground leading-[1.4]">The First Days in the OR</p>
                {!isEntitled && <span className="text-[10px] font-bold px-1.5 py-0.5 rounded-full bg-emerald-500 text-white whitespace-nowrap shrink-0">FREE PREVIEW</span>}
              </div>
              <p className="text-xs text-muted-foreground mt-0.5">SOAP-ME · Machine check · Emergency drugs · Day-one survival guide · CE Halo LLC</p>
            </div>
            <ChevronRight className="w-4 h-4 text-muted-foreground shrink-0" />
          </button>
        </div>
      </div>
    </div>);

}