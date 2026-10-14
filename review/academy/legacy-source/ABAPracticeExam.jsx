import { useState, useMemo } from 'react';
import { useScrollReset } from '@/components/ScrollToTop';
import { ChevronLeft, ChevronRight, RotateCcw, Trophy, BookOpen, ChevronDown, ChevronUp, CheckCircle2, XCircle, List } from 'lucide-react';
import { QUESTIONS, SECTIONS } from './ABAPracticeExamData';
import { useEntitlement } from '@/hooks/useEntitlement';
import PaywallModal from '@/components/PaywallModal';
import QuizFreePreviewGate from './QuizFreePreviewGate';

const FREE_PREVIEW_LIMIT = 5;

const SECTION_COLORS = {
  1: { bg: 'bg-blue-50', border: 'border-blue-200', badge: 'bg-blue-100 text-blue-700', dark: 'bg-blue-700' },
  2: { bg: 'bg-indigo-50', border: 'border-indigo-200', badge: 'bg-indigo-100 text-indigo-700', dark: 'bg-indigo-700' },
  3: { bg: 'bg-violet-50', border: 'border-violet-200', badge: 'bg-violet-100 text-violet-700', dark: 'bg-violet-700' },
  4: { bg: 'bg-cyan-50', border: 'border-cyan-200', badge: 'bg-cyan-100 text-cyan-700', dark: 'bg-cyan-700' },
  5: { bg: 'bg-teal-50', border: 'border-teal-200', badge: 'bg-teal-100 text-teal-700', dark: 'bg-teal-700' },
  6: { bg: 'bg-pink-50', border: 'border-pink-200', badge: 'bg-pink-100 text-pink-700', dark: 'bg-pink-700' },
  7: { bg: 'bg-red-50', border: 'border-red-200', badge: 'bg-red-100 text-red-700', dark: 'bg-red-700' },
  8: { bg: 'bg-orange-50', border: 'border-orange-200', badge: 'bg-orange-100 text-orange-700', dark: 'bg-orange-700' },
  9: { bg: 'bg-green-50', border: 'border-green-200', badge: 'bg-green-100 text-green-700', dark: 'bg-green-700' },
};

function ScoreBar({ score, total }) {
  const pct = total > 0 ? Math.round((score / total) * 100) : 0;
  const color = pct >= 85 ? 'bg-emerald-500' : pct >= 75 ? 'bg-teal-500' : pct >= 65 ? 'bg-amber-500' : 'bg-red-500';
  const label = pct >= 85 ? 'Exceptional!' : pct >= 75 ? 'Well-prepared' : pct >= 65 ? 'Needs review' : 'Intensive review needed';
  return (
    <div>
      <div className="flex items-center justify-between mb-1">
        <span className="text-sm font-semibold text-foreground">{score}/{total} correct ({pct}%)</span>
        <span className="text-xs text-muted-foreground">{label}</span>
      </div>
      <div className="w-full h-2.5 bg-secondary rounded-full overflow-hidden">
        <div className={`h-full rounded-full transition-all duration-700 ${color}`} style={{ width: `${pct}%` }} />
      </div>
    </div>
  );
}

// Mode: 'select' | 'test' | 'results' | 'review'
export default function ABAPracticeExam({ onBack }) {
  const { isEntitled } = useEntitlement();
  const [paywallOpen, setPaywallOpen] = useState(false);
  const [showGate, setShowGate] = useState(false);
  const [mode, setMode] = useState('select');
  const [selectedSection, setSelectedSection] = useState(null); // null = all 301
  const [currentIdx, setCurrentIdx] = useState(0);
  const [selected, setSelected] = useState(null);
  const [showAnswer, setShowAnswer] = useState(false);
  const [answers, setAnswers] = useState({}); // questionId -> { chosen, correct }
  const [reviewIdx, setReviewIdx] = useState(0);
  const [showRationale, setShowRationale] = useState(false);
  const [reviewFilter, setReviewFilter] = useState('all'); // 'all' | 'wrong'

  // Scroll to top whenever the question or mode changes so the question is visible
  useScrollReset([currentIdx, reviewIdx, mode]);

  const fullQuestionCount = useMemo(() => {
    return selectedSection === null ? QUESTIONS.length : QUESTIONS.filter(q => q.section === selectedSection).length;
  }, [selectedSection]);

  const activeQuestions = useMemo(() => {
    let qs = selectedSection === null ? QUESTIONS : QUESTIONS.filter(q => q.section === selectedSection);
    return isEntitled ? qs : qs.slice(0, FREE_PREVIEW_LIMIT);
  }, [selectedSection, isEntitled]);

  const currentQ = activeQuestions[currentIdx];
  const colors = currentQ ? SECTION_COLORS[currentQ.section] : SECTION_COLORS[1];
  const totalAnswered = Object.keys(answers).length;
  const totalCorrect = Object.values(answers).filter(a => a.correct).length;

  function startExam(sectionId) {
    setSelectedSection(sectionId);
    setCurrentIdx(0);
    setSelected(null);
    setShowAnswer(false);
    setAnswers({});
    setMode('test');
  }

  function handleSelect(idx) {
    if (showAnswer) return;
    setSelected(idx);
    setShowAnswer(true);
    setAnswers(prev => ({ ...prev, [currentQ.id]: { chosen: idx, correct: idx === currentQ.answer } }));
  }

  function handleNext() {
    setSelected(null);
    setShowAnswer(false);
    if (currentIdx < activeQuestions.length - 1) {
      setCurrentIdx(currentIdx + 1);
    } else if (isEntitled) {
      setMode('results');
    } else {
      setShowGate(true);
    }
  }

  function handleReset() {
    setCurrentIdx(0);
    setSelected(null);
    setShowAnswer(false);
    setAnswers({});
    setMode('select');
    setSelectedSection(null);
    setShowGate(false);
  }

  function getOptionStyle(idx) {
    if (!showAnswer) {
      return selected === idx ? 'bg-primary/10 border-primary ring-1 ring-primary' : 'bg-card border-border hover:bg-secondary/50';
    }
    if (idx === currentQ.answer) return 'bg-emerald-50 border-emerald-300 ring-1 ring-emerald-400';
    if (idx === selected && idx !== currentQ.answer) return 'bg-red-50 border-red-300 ring-1 ring-red-400';
    return 'bg-card border-border opacity-50';
  }

  // SECTION SELECT
  if (mode === 'select') {
    return (
      <div className="flex flex-col gap-3 pb-4">
        <div className="p-4 rounded-xl bg-blue-50 border border-blue-100 mb-2">
          <p className="text-xs font-bold text-blue-800 mb-1">ABA BASIC Practice Examination — CE Halo LLC · 2026</p>
          <p className="text-xs text-blue-700">301 board-style questions across 9 sections. Select a section or take the full exam.</p>
        </div>

        <button
          onClick={() => startExam(null)}
          className="w-full flex items-center gap-3 p-4 rounded-2xl bg-slate-800 text-white text-left active:scale-[0.99] transition-all">
          <div className="w-10 h-10 rounded-xl bg-card/20 flex items-center justify-center shrink-0">
            <Trophy className="w-5 h-5 text-white" />
          </div>
          <div className="flex-1 min-w-0">
            <p className="font-bold text-sm leading-[1.35]">Full Practice Examination</p>
            <p className="text-xs opacity-70 mt-0.5">All 301 questions · All 9 sections · ~5 hours</p>
          </div>
          <ChevronRight className="w-4 h-4 opacity-60 shrink-0" />
        </button>

        <p className="text-[11px] font-bold text-muted-foreground uppercase tracking-widest mt-2">Or choose a section</p>

        {SECTIONS.map(sec => {
          const c = SECTION_COLORS[sec.id];
          const count = sec.range[1] - sec.range[0] + 1;
          return (
            <button
              key={sec.id}
              onClick={() => startExam(sec.id)}
              className={`w-full flex items-center gap-3 p-3 rounded-xl border ${c.bg} ${c.border} text-left active:scale-[0.99] transition-all`}>
              <div className={`w-8 h-8 rounded-lg ${c.dark} flex items-center justify-center shrink-0`}>
                <span className="text-white text-xs font-bold">{sec.id}</span>
              </div>
              <div className="flex-1 min-w-0">
                <p className="font-semibold text-xs text-foreground leading-[1.35]">{sec.label.replace(`Section ${sec.id}: `, '')}</p>
                <p className="text-[10px] text-muted-foreground mt-0.5">Q{sec.range[0]}–{sec.range[1]} · {count} questions</p>
              </div>
              <ChevronRight className="w-3.5 h-3.5 text-muted-foreground shrink-0" />
            </button>
          );
        })}
        <p className="text-[10px] text-muted-foreground text-center pt-2">© CE Halo LLC · For educational use only. Not for clinical decision-making.</p>
      </div>
    );
  }

  // RESULTS
  if (mode === 'results') {
    const pct = Math.round((totalCorrect / activeQuestions.length) * 100);
    const sectionStats = {};
    activeQuestions.forEach(q => {
      if (!sectionStats[q.section]) sectionStats[q.section] = { correct: 0, total: 0, label: SECTIONS.find(s => s.id === q.section)?.label.split(': ')[1] || '' };
      sectionStats[q.section].total++;
      if (answers[q.id]?.correct) sectionStats[q.section].correct++;
    });

    return (
      <div className="flex flex-col gap-4 pb-4">
        <div className="bg-slate-800 text-white rounded-2xl p-5 text-center">
          <Trophy className="w-10 h-10 mx-auto mb-2 opacity-90" />
          <h2 className="font-bold text-xl">Exam Complete!</h2>
          <p className="text-4xl font-bold mt-1">{pct}%</p>
          <p className="text-sm opacity-80 mt-1">{totalCorrect} / {activeQuestions.length} correct</p>
        </div>

        <div className="bg-card rounded-2xl border border-border p-4 space-y-3">
          <h3 className="font-bold text-sm text-foreground">Results by Section</h3>
          {Object.entries(sectionStats).map(([secId, stat]) => {
            const dpct = Math.round((stat.correct / stat.total) * 100);
            const c = SECTION_COLORS[parseInt(secId)];
            return (
              <div key={secId} className={`rounded-xl p-3 border ${c.bg} ${c.border}`}>
                <div className="flex items-center justify-between mb-1">
                  <span className="text-xs font-semibold text-foreground truncate mr-2">{stat.label}</span>
                  <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full shrink-0 ${c.badge}`}>{stat.correct}/{stat.total} ({dpct}%)</span>
                </div>
                <div className="w-full h-1.5 bg-card/50 rounded-full overflow-hidden">
                  <div className={`h-full rounded-full ${dpct >= 75 ? 'bg-emerald-500' : dpct >= 65 ? 'bg-amber-500' : 'bg-red-500'}`} style={{ width: `${dpct}%` }} />
                </div>
              </div>
            );
          })}
        </div>

        <div className="bg-amber-50 border border-amber-200 rounded-xl p-3">
          <p className="text-xs text-amber-800 font-medium">Performance guide: &lt;65% = intensive review · 65-74% = targeted review · 75%+ = well-prepared · 85%+ = exceptional</p>
        </div>

        <div className="flex gap-2">
          <button
            onClick={() => { setMode('review'); setReviewIdx(0); setShowRationale(false); setReviewFilter('all'); }}
            className="flex-1 py-3 bg-teal-50 border border-teal-200 rounded-xl text-sm font-semibold text-teal-700 active:scale-95 transition-all flex items-center justify-center gap-1">
            <BookOpen className="w-4 h-4" /> Review Answers
          </button>
          <button
            onClick={handleReset}
            className="flex-1 py-3 bg-slate-800 text-white rounded-xl text-sm font-semibold active:scale-95 transition-all flex items-center justify-center gap-1">
            <RotateCcw className="w-4 h-4" /> New Exam
          </button>
        </div>
        <p className="text-[10px] text-muted-foreground text-center">© CE Halo LLC · For educational use only.</p>
      </div>
    );
  }

  // REVIEW
  if (mode === 'review') {
    const reviewPool = reviewFilter === 'wrong'
      ? activeQuestions.filter(q => answers[q.id] && !answers[q.id].correct)
      : activeQuestions;
    const rq = reviewPool[reviewIdx];

    if (!rq) {
      return (
        <div className="flex flex-col gap-3 items-center py-8">
          <p className="text-sm text-muted-foreground">No questions match this filter.</p>
          <button onClick={() => setReviewFilter('all')} className="px-4 py-2 bg-primary text-white rounded-xl text-sm font-semibold">Show all</button>
        </div>
      );
    }

    const rc = SECTION_COLORS[rq.section];
    const userAnswer = answers[rq.id];

    return (
      <div className="flex flex-col gap-3 pb-4">
        <div className="flex items-center justify-between">
          <button onClick={() => setMode('results')} className="flex items-center gap-1 text-primary text-sm font-medium">
            <ChevronLeft className="w-4 h-4" /> Results
          </button>
          <div className="flex gap-1">
            <button
              onClick={() => { setReviewFilter('all'); setReviewIdx(0); }}
              className={`px-2.5 py-1 rounded-lg text-xs font-semibold ${reviewFilter === 'all' ? 'bg-slate-800 text-white' : 'bg-secondary text-muted-foreground'}`}>
              All ({activeQuestions.length})
            </button>
            <button
              onClick={() => { setReviewFilter('wrong'); setReviewIdx(0); }}
              className={`px-2.5 py-1 rounded-lg text-xs font-semibold ${reviewFilter === 'wrong' ? 'bg-red-500 text-white' : 'bg-secondary text-muted-foreground'}`}>
              Wrong ({activeQuestions.filter(q => answers[q.id] && !answers[q.id].correct).length})
            </button>
          </div>
        </div>

        <div className="flex items-center justify-between text-xs text-muted-foreground">
          <span>Q{rq.id}</span>
          <span>{reviewIdx + 1} of {reviewPool.length}</span>
        </div>

        <div className={`rounded-xl p-3 border ${rc.bg} ${rc.border}`}>
          <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full ${rc.badge}`}>{SECTIONS.find(s => s.id === rq.section)?.label.split(': ')[1]}</span>
          <p className="text-sm font-semibold text-foreground mt-2 leading-relaxed">{rq.q}</p>
        </div>

        <div className="flex flex-col gap-2">
          {rq.options.map((opt, idx) => {
            let style = 'bg-card border-border';
            let icon = null;
            if (idx === rq.answer) { style = 'bg-emerald-50 border-emerald-300'; icon = <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0" />; }
            else if (userAnswer?.chosen === idx && idx !== rq.answer) { style = 'bg-red-50 border-red-300'; icon = <XCircle className="w-4 h-4 text-red-500 shrink-0" />; }
            return (
              <div key={idx} className={`flex items-start gap-2 p-3 rounded-xl border ${style}`}>
                <span className="text-xs font-bold text-muted-foreground shrink-0 mt-0.5">{String.fromCharCode(65 + idx)}.</span>
                <p className="text-xs text-foreground flex-1">{opt}</p>
                {icon}
              </div>
            );
          })}
        </div>

        {!userAnswer && (
          <div className="p-3 bg-secondary border border-border rounded-xl text-center">
            <p className="text-xs text-muted-foreground">Not answered during this session.</p>
          </div>
        )}

        <button
          onClick={() => setShowRationale(r => !r)}
          className="flex items-center justify-between w-full p-3 bg-teal-50 border border-teal-200 rounded-xl text-sm font-semibold text-teal-700 active:scale-95 transition-all">
          <span>📖 Rationale</span>
          {showRationale ? <ChevronUp className="w-4 h-4" /> : <ChevronDown className="w-4 h-4" />}
        </button>
        {showRationale && (
          <div className="p-3 bg-teal-50/50 border border-teal-200 rounded-xl">
            <p className="text-xs text-foreground leading-relaxed">{rq.rationale}</p>
          </div>
        )}

        <div className="flex gap-2">
          <button
            onClick={() => { setReviewIdx(r => Math.max(0, r - 1)); setShowRationale(false); }}
            disabled={reviewIdx === 0}
            className="px-4 py-3 bg-secondary border border-border rounded-xl text-sm font-semibold text-muted-foreground disabled:opacity-40 active:scale-95 transition-all">
            <ChevronLeft className="w-4 h-4" />
          </button>
          <button
            onClick={() => { setReviewIdx(r => Math.min(reviewPool.length - 1, r + 1)); setShowRationale(false); }}
            disabled={reviewIdx === reviewPool.length - 1}
            className="flex-1 py-3 bg-primary text-white rounded-xl text-sm font-semibold disabled:opacity-40 active:scale-95 transition-all flex items-center justify-center gap-1">
            Next <ChevronRight className="w-4 h-4" />
          </button>
        </div>
      </div>
    );
  }

  // FREE PREVIEW GATE
  if (showGate) {
    return (
      <>
        <QuizFreePreviewGate
          answeredCount={FREE_PREVIEW_LIMIT}
          totalQuestions={fullQuestionCount}
          onSubscribe={() => setPaywallOpen(true)}
          onBack={handleReset}
        />
        <PaywallModal open={paywallOpen} onClose={() => setPaywallOpen(false)} />
      </>
    );
  }

  // TEST MODE
  const sectionLabel = SECTIONS.find(s => s.id === currentQ.section)?.label.split(': ')[1] || '';
  const progress = Math.round(((currentIdx + 1) / activeQuestions.length) * 100);

  return (
    <div className="flex flex-col gap-3 pb-4">
      {/* Header */}
      <div className={`px-4 py-3 rounded-2xl ${colors.bg} ${colors.border} border`}>
        <div className="flex items-center justify-between mb-2">
          <div className="flex items-center gap-2">
            <BookOpen className="w-4 h-4 text-muted-foreground" />
            <span className="text-xs font-bold text-muted-foreground uppercase tracking-wide">CE HALO LLC</span>
          </div>
          <button onClick={handleReset} className="flex items-center gap-1 px-2.5 py-1.5 bg-card/60 rounded-lg text-xs font-semibold text-muted-foreground active:scale-95 transition-all">
            <RotateCcw className="w-3.5 h-3.5" /> Reset
          </button>
        </div>
        <div className="flex items-center justify-between mb-1.5">
          <span className="text-xs font-semibold text-muted-foreground">Q{currentIdx + 1} of {activeQuestions.length}</span>
          <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full ${colors.badge}`}>{sectionLabel}</span>
        </div>
        <div className="w-full h-1.5 bg-black/10 rounded-full overflow-hidden">
          <div className="h-full bg-current rounded-full transition-all duration-300" style={{ width: `${progress}%` }} />
        </div>
      </div>

      {/* Score */}
      <div className="bg-card rounded-2xl border border-border p-3">
        <ScoreBar score={totalCorrect} total={totalAnswered} />
      </div>

      {/* Question */}
      <div className={`rounded-xl p-3 border ${colors.bg} ${colors.border}`}>
        <p className="text-sm font-semibold text-foreground leading-relaxed">{currentQ.q}</p>
      </div>

      {/* Options */}
      <div className="flex flex-col gap-2">
        {currentQ.options.map((opt, idx) => (
          <button
            key={idx}
            onClick={() => handleSelect(idx)}
            className={`flex items-start gap-2 p-3 rounded-xl border text-left transition-all active:scale-[0.98] ${getOptionStyle(idx)}`}>
            <span className="text-xs font-bold text-muted-foreground shrink-0 mt-0.5 min-w-[16px]">{String.fromCharCode(65 + idx)}.</span>
            <p className="text-xs text-foreground leading-relaxed">{opt}</p>
            {showAnswer && idx === currentQ.answer && <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0 ml-auto" />}
            {showAnswer && idx === selected && idx !== currentQ.answer && <XCircle className="w-4 h-4 text-red-500 shrink-0 ml-auto" />}
          </button>
        ))}
      </div>

      {/* Rationale */}
      {showAnswer && (
        <div className="p-3 bg-teal-50 border border-teal-200 rounded-xl">
          <p className="text-xs font-semibold text-teal-700 mb-1">
            {selected === currentQ.answer ? '✅ Correct!' : '❌ Incorrect'} — Rationale
          </p>
          <p className="text-xs text-foreground leading-relaxed">{currentQ.rationale}</p>
        </div>
      )}

      {/* Navigation */}
      <div className="flex gap-2">
        <button
          onClick={() => {
            const prevQ = activeQuestions[Math.max(0, currentIdx - 1)];
            const prevAnswer = answers[prevQ?.id];
            setCurrentIdx(i => Math.max(0, i - 1));
            setSelected(prevAnswer?.chosen ?? null);
            setShowAnswer(prevAnswer !== undefined);
          }}
          disabled={currentIdx === 0}
          className="px-4 py-3 bg-secondary border border-border rounded-xl text-sm font-semibold text-muted-foreground disabled:opacity-40 active:scale-95 transition-all">
          <ChevronLeft className="w-4 h-4" />
        </button>
        <button
          onClick={handleNext}
          disabled={!showAnswer}
          className="flex-1 py-3 bg-primary text-white rounded-xl text-sm font-semibold disabled:opacity-40 active:scale-95 transition-all flex items-center justify-center gap-1">
          {currentIdx === activeQuestions.length - 1 ? (isEntitled ? 'View Results' : 'Unlock Full Exam') : 'Next Question'} <ChevronRight className="w-4 h-4" />
        </button>
      </div>

      <p className="text-[10px] text-muted-foreground text-center">© CE Halo LLC · For educational use only. Not for clinical decision-making.</p>
    </div>
  );
}