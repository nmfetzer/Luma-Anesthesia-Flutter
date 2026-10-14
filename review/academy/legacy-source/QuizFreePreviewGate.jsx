import { Lock, CheckCircle2 } from 'lucide-react';

export default function QuizFreePreviewGate({ answeredCount, totalQuestions, onSubscribe, onBack }) {
  return (
    <div className="flex flex-col gap-4 pb-4">
      <div className="bg-gradient-to-br from-primary/10 to-primary/5 border border-primary/20 rounded-2xl p-6 text-center">
        <div className="w-14 h-14 rounded-2xl bg-primary/10 flex items-center justify-center mx-auto mb-3">
          <Lock className="w-7 h-7 text-primary" />
        </div>
        <h2 className="font-heading font-bold text-lg text-foreground mb-1.5">Free preview complete</h2>
        <p className="text-sm text-muted-foreground mb-5 leading-relaxed">
          You've answered {answeredCount} free sample questions. Subscribe to unlock all {totalQuestions} questions with detailed rationales.
        </p>
        <button
          onClick={onSubscribe}
          className="w-full py-3.5 rounded-xl bg-primary text-primary-foreground text-sm font-bold shadow-md active:scale-95 transition mb-3 min-h-[48px]"
        >
          Start 14-Day Free Trial
        </button>
        <button
          onClick={onBack}
          className="text-sm font-medium text-muted-foreground hover:text-foreground transition-colors min-h-[44px]"
        >
          Back to start
        </button>
      </div>

      <div className="bg-card border border-border rounded-2xl p-4">
        <p className="text-xs font-bold text-muted-foreground uppercase tracking-wide mb-3">What you get with Premium</p>
        <ul className="space-y-2.5">
          {[
            'Full practice tests with all questions',
            'Detailed rationales for every answer',
            'Performance breakdown by domain',
            'Unlimited retakes',
            '900+ flashcards & study guides',
          ].map((item, i) => (
            <li key={i} className="flex items-start gap-2 text-sm text-foreground">
              <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0 mt-0.5" />
              {item}
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}