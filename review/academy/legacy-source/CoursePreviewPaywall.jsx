import { CheckCircle2, Lock } from 'lucide-react';

// Tailored paywall shown at the bottom of a free-preview course module when the
// user is not subscribed. Surfaces after the user reads through the preview so
// they can upgrade without leaving the module.
export default function CoursePreviewPaywall({ courseName, moduleCount, onSubscribe, onContinue }) {
  return (
    <div className="mt-8 rounded-2xl border-2 border-primary/30 bg-gradient-to-br from-primary/5 to-primary/10 p-5 text-center">
      <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-primary/10 text-primary text-xs font-bold mb-3">
        <Lock className="w-3 h-3" /> Free Preview
      </div>
      <h3 className="font-heading font-bold text-lg text-foreground mb-2 leading-tight">
        You've finished the preview of {courseName}
      </h3>
      <p className="text-sm text-muted-foreground mb-4 max-w-sm mx-auto leading-relaxed">
        Unlock all {moduleCount} modules and pass your boards with confidence.
      </p>
      <ul className="text-left space-y-2 mb-5 max-w-sm mx-auto">
        {[
          'Full access to every module in this course',
          'Practice tests with detailed rationales',
          '900+ flashcards across 17 decks',
          'Regular content updates',
          'Cancel anytime',
        ].map((item) => (
          <li key={item} className="flex items-center gap-2.5 text-sm text-foreground">
            <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0" strokeWidth={2.5} />
            <span>{item}</span>
          </li>
        ))}
      </ul>
      <button
        onClick={onSubscribe}
        className="w-full py-3.5 rounded-xl bg-primary text-primary-foreground text-sm font-bold shadow-md active:scale-95 transition mb-3 min-h-[48px]"
      >
        Start 14-Day Free Trial
      </button>
      <button
        onClick={onContinue}
        className="w-full py-2 text-sm font-medium text-muted-foreground hover:text-foreground transition-colors min-h-[44px]"
      >
        Continue browsing
      </button>
    </div>
  );
}