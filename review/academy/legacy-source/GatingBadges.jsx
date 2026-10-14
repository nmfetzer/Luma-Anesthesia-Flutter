import { Lock } from 'lucide-react';

// Emerald "FREE PREVIEW" pill — signals a free-preview course module.
// Place inside a `relative` container; sits in the top-right corner.
export function FreePreviewBadge({ show }) {
  if (!show) return null;
  return (
    <span className="absolute top-1.5 right-1.5 z-10 text-[10px] font-bold px-1.5 py-0.5 rounded-full bg-emerald-500 text-white border border-emerald-600 whitespace-nowrap">
      FREE PREVIEW
    </span>
  );
}

// Mint-green "5 Free" pill — signals a soft-gated flashcard deck (first 5 free).
// Place inside a `relative` container; sits in the top-right corner.
export function FreeBadge({ show }) {
  if (!show) return null;
  return (
    <span className="absolute top-1.5 right-1.5 z-10 text-[10px] font-bold px-1.5 py-0.5 rounded-full bg-emerald-100 text-emerald-800 border border-emerald-200">
      5 Free
    </span>
  );
}

// Small dark circle with a white lock — sits top-right inside a `relative` container.
// Uses non-negative positioning so it can never be clipped by ancestor overflow.
export function LockBadge({ show }) {
  if (!show) return null;
  return (
    <div className="absolute top-0 right-0 z-10 w-5 h-5 rounded-full bg-zinc-900 flex items-center justify-center shadow-sm ring-2 ring-background">
      <Lock className="w-3 h-3 text-white" strokeWidth={2.5} />
    </div>
  );
}

// Wraps an emoji "thumbnail" with a dark overlay + lock badge when locked.
// Fixed-size box so the overlay and badge position reliably for every row.
export function LockThumbnail({ emoji, locked }) {
  return (
    <div className="relative w-9 h-9 shrink-0 flex items-center justify-center rounded-lg">
      <span className="text-xl">{emoji}</span>
      {locked && <div className="absolute inset-0 bg-black/30 rounded-lg" />}
      <LockBadge show={locked} />
    </div>
  );
}

// Legend banner explaining the gating badges to non-subscribed users.
export function AcademyLegend() {
  return (
    <div className="rounded-2xl border border-purple-200 bg-purple-50/60 px-4 py-3 flex flex-wrap items-center gap-x-5 gap-y-2">
      <div className="flex items-center gap-2">
        <span className="w-3.5 h-3.5 rounded-full bg-emerald-400 border border-emerald-500 shrink-0" />
        <span className="text-xs font-medium text-foreground/80">Free preview available</span>
      </div>
      <div className="flex items-center gap-2">
        <span className="w-3.5 h-3.5 rounded-full bg-zinc-900 flex items-center justify-center shrink-0">
          <Lock className="w-2 h-2 text-white" strokeWidth={3} />
        </span>
        <span className="text-xs font-medium text-foreground/80">Subscribe to unlock</span>
      </div>
    </div>
  );
}