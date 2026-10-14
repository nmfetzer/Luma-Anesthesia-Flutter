# Luma Academy: NCE Mastery

Owner direction recorded October 14, 2026. This brief defines the requested product and distinguishes approved direction from proposed commercial and mastery rules. The complete course, branded topic PDFs, saved-account progress and IAP are not yet implemented.

## Problem statement

The owner wants an organized NCE study product rather than a large undifferentiated question bank. Learners should see where every topic fits, study in manageable sections, practice retrieval and advance through a game path while their account retains progress.

The uploaded outline is the structural reference. Its major NCE domains are Basic Sciences (20%); Equipment, Instrumentation and Technology (20%); General Principles of Anesthesia (35%); and Anesthesia for Surgical Procedures and Special Populations (25%). The same document assigns equal 25% weights to SEE domains, which must not be substituted for NCE weights ([NBCRNA outline](https://www.nbcrna.com/docs/default-source/exams-documents/nce-resources-landing-page/nce_content_outline_2025to2026.pdf?sfvrsn=6abde65a_9)).

## Goals

- Map 100% of outline entries to a visible hub, topic or lesson, with no silently omitted subtopics.
- Release every teachable level with its own CE HALO-branded PDF, flashcards and multiple-choice practice/checkpoint content.
- Restore a learner's progress on a second authenticated device without granting another account their progress or purchase.
- Sell the complete NCE track through its own verified entitlement, independent of the clinical-reference subscription.
- Verify every released clinical claim, answer and rationale through the documented content-review process before sale.

## Non-goals

- No actual, recalled or proprietary NCE examination items. Questions are original educational items.
- No NBCRNA affiliation, endorsement, exam-equivalence or guaranteed-pass claims.
- No AANA-approved credit award from Academy study unless a separate course is expressly approved for that purpose.
- No AI-generated live assessment items at launch. Luma AI usage and billing remain separate.
- No public leaderboard, social competition, lost-life paywall, countdown pressure or paid level-skipping in the first version.

## User stories

- As a learner, I want to start at I.A.1 Cardiovascular and follow the outline so I know what I have covered.
- As a learner, I want small flashcard groups and explanations for correct and incorrect options so that I understand concepts rather than memorize answer positions.
- As a returning learner, I want a Continue button and a due-for-review queue so I can resume without finding my place again.
- As a purchaser, I want the NCE course to work without another paid clinical-reference subscription.
- As a learner replacing a phone, I want purchase restore and account progress recovery without paying twice.
- As the clinical owner, I want a coverage register and explicit asset/review states so that missing or unapproved materials cannot appear complete.

## Requirements

### Must have: exact structure and complete level bundles

Use the uploaded outline's domain, letter, number, lower-case and nested Roman-numeral identifiers as stable topic codes. The machine-readable map is `nce-outline-map.json`. Organizing hubs retain all children; every leaf is assigned a planned PDF, deck, practice set and checkpoint, initially null and not publishable.

The uploaded 12-page outline maps to 412 total hierarchy entries, including 336 leaf topics. These are coverage counts, not completed lessons. Broad entries such as Cardiovascular A&P can contain several small flashcard groups within one level; larger parent topics remain visible as organizing hubs rather than disappearing from navigation.

The first path is:

**I. Basic Sciences → A. Anatomy and physiology → 1. Cardiovascular → 2. Respiratory → 3. Central nervous system**, continuing through the remaining outline in order ([NBCRNA outline](https://www.nbcrna.com/docs/default-source/exams-documents/nce-resources-landing-page/nce_content_outline_2025to2026.pdf?sfvrsn=6abde65a_9)).

Each level contains:

- **Title and identity:** Official outline code, clear topic title, concise learning objectives and review date.
- **Learn:** Its own information PDF with CE HALO branding, a topic-specific title page, organized clinical explanations, tables, references and supplied graphics where appropriate.
- **Recall:** Flashcards grouped by concept, delivered in short sets. Missed/uncertain cards return for review.
- **Practice:** Original multiple-choice questions with referenced rationales explaining the correct answer and distractors.
- **Checkpoint:** A separate assessment pool, randomized without changing the content's meaning. A scoring threshold is not an NCE passing score.
- **Advance:** Earn a visible completed node and unlock the next level only after the agreed mastery rule is met. Previously completed nodes remain available.

Given any published level, when its learning assets are inspected, then every required asset exists, opens correctly and has a valid content version and clinical approval record. Null or placeholder assets fail publication.

### Must have: CE HALO PDF template

Proposed cover:

```text
CE HALO
Luma Academy | NCE Mastery
Part I: Basic Sciences
Anatomy & Physiology
Cardiovascular
Outline I.A.1 | Content version | Reviewed date
```

Interior: objectives; core concepts in small sections; clinical connections; concise summary; linked sources and review metadata. Source citations must identify actual references, not imply the outline itself is a medical textbook.

Graphics will be supplied by the owner. Keep graphic slots, captions, attribution/permission fields and accessibility descriptions in the source. Do not invent illustrations or claim graphic-dependent sections are complete before the assets are ready.

Keep the supplied NBCRNA PDF as a clearly attributed separate reference, not a CE HALO-authored guide. Provide the official document link in Academy; confirm redistribution permission before bundling a third-party PDF into the commercial product. Do not replace the NBCRNA cover with CE HALO branding.

### Must have: progress and mastery

Owner-approved direction: gated advancement and saved progress. Proposed initial rule, not yet owner-approved: all required flashcards reviewed, followed by at least 90% on a fresh checkpoint; missed concepts must be reviewed before retry. Use an adequate reviewed assessment pool, a defined minimum question count and alternate forms before enabling this rule. Do not let one repeatedly memorized item establish mastery.

Track PDF/lesson activity, card attempts/confidence, question attempts, first-attempt accuracy, checkpoint results, completed levels, current location, review due dates and content version. Opening a PDF is an activity event, not proof of understanding.

Store account progress with row-level access controls in Supabase and a local offline queue. Use unique attempt IDs, idempotent synchronization and explicit handling of content revisions. Never infer paid access from a local progress file. Keep sandbox progress and purchases separate from production.

Given an interrupted session, when the same learner returns, then the current level and completed attempts are restored. Given two users, when either queries progress, then they cannot read or alter the other's records. Given an updated lesson, retain historical achievements and mark new/changed concepts for review rather than erasing the learner's record.

Spaced-review status is distinct from path completion. A previously completed level can become due for review without silently deleting its earned completion or relocking the entire path. “Mastered” means the learner met Luma's study rule, not demonstrated clinical competence or guaranteed board readiness.

### Must have: separate purchase

Use one NCE course entitlement. Do not sell individual small levels. Clinical-reference, CE course and AI entitlements remain distinct. Check historical promises to existing customers before changing access to legacy Academy material.

Server-side verified store events must govern course access and handle duplicate events, restore, account reassignment, refunds and revocations. Course reading and purchase state must survive app restarts. Use actual localized store prices, not hard-coded checkout amounts.

Given an Academy-only purchaser, when they open NCE Mastery, then no second clinical subscription is required. Given no purchase, only the specifically designated free sample is accessible. Given a restore or refund, the entitlement reconciles without rewriting the learner's clinical or CE records.

### Should have

- A visual path with region headers, available/completed/locked nodes, a Continue action, milestones and modest celebratory feedback.
- Small daily review rounds, bookmarks, searchable purchased PDFs and accessible flashcard controls.
- A visible topic-coverage dashboard and mixed-domain practice weighted to the chosen exam mode.
- Full-text alternatives and large-text/screen-reader support for graphics and path controls.

### Could have later

- Optional cumulative domain challenges and exam-mode assessments after sufficient item coverage and validation.
- Additional item formats aligned to the real exam's format range. NCE includes more than single-answer multiple-choice, so MCQ-only practice must not be described as a complete exam simulation ([NBCRNA exam tutorial](https://www.nbcrna.com/students/nce-resources/nce-see-exam-tutorial)).

## Pricing recommendation

Recommended U.S. launch offer for the completed full track: **$199.99 introductory**, then **$249.99 regular**, as a single non-consumable purchase. Make the first complete Cardiovascular level a free sample. This is a positioning recommendation, not a demand forecast, approved store price or promise of profit.

For comparison, Ollivate currently lists Olli Scholar at $25/month or $199/year and has a free tier ([Ollivate pricing](https://ollivate.com/our-pricing)). APEX lists its course-only Student Review at $499 for one year, with different prices for longer access and SmartBank bundles ([APEX student course](https://www.apexanesthesia.com/student/)). These are pricing anchors, not evidence that the new Luma course has equivalent scope, validation or outcomes.

Apple describes a non-consumable as purchased once without expiry; fixed-duration access instead belongs to a subscription product type ([Apple IAP types](https://developer.apple.com/help/app-store-connect/reference/in-app-purchases-and-subscriptions/in-app-purchase-types)). Accordingly, do not sell a non-consumable and then apply an annual expiry. Define the included NCE course edition, corrections/updates and support obligations before purchase copy is finalized, without promising every future Luma product or unlimited AI.

No IAP has been created, priced, submitted or activated by this recommendation. Do not sell the three-question preview as the complete course.

## Success metrics

- Release gates: 100% outline coverage; 100% required assets and clinical approvals; all purchase/restore/refund and cross-account progress tests passing.
- Beta reliability: no unexplained progress loss in the scripted offline/reinstall/second-device test matrix; no cross-account data exposure.
- Post-launch product measures: free-sample completion, conversion to paid, first-week lesson completion, return-to-study rate, refund rate and progress-related support requests.
- Measure actual baseline during beta before setting commercial conversion or retention targets. Do not use quiz score growth as a proxy for proven NCE pass improvement.

## Open decisions and next build

- **Owner, blocks checkout:** Confirm one-time purchase versus time-limited subscription, final prices and included-update terms.
- **Owner, blocks mastery activation:** Confirm checkpoint threshold and whether the game path is strictly sequential across all domains or sequential within a chosen domain.
- **Clinical owner, blocks release:** Approve the reviewed content and assessment coverage. User supplies the graphics.
- **Implementation:** Build I.A.1 Cardiovascular end to end first: branded PDF, small flashcard decks, original practice/checkpoint questions, progress persistence and path transition to I.A.2. Then reuse the tested template without repeating design approvals for each topic.
- **Current status:** Outline mapped and product requirements recorded. The existing private three-question pharmacology preview remains a prototype, not the first completed Cardiovascular level. The full path UI, branded clinical PDFs, backend progress and paid course remain to be built.
