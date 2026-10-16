# Academy connected-client QA inventory

The QA entry point uses the production Flutter Academy widgets and repository contract against an isolated local PostgreSQL database with the same migration and approved private packages. It bypasses login for one synthetic local account only. It is not evidence of real browser OAuth, native TestFlight login, a store purchase, or a production learner session.

## Checks

- Desktop and 375px: learning path, all nine titles, clear counts and account-progress copy.
- Level: deck expansion, full lessons, source links, mark reviewed only after successful server save.
- Flashcards: reveal, save recall, skip, completion, repeat and back navigation.
- Practice: select answers, explanation, previous/next, server submission, saved score.
- Checkpoint: no keys in pre-submit response; all questions required; explanation after submission.
- Persistence: reload and a second browser context read previously saved marks.
- PDFs: authorized study-guide fetch and viewer, optional companion controls.
- Failure: failed mark shows retry without advancing; duplicate submission has one attempt.
- Security SQL: anonymous denial, unentitled denial, cross-account isolation, revoked access, invalid item/version/answers, direct content denial, protected answer PDFs.
- Portal: actual signed-out Academy route, account navigation, CE course navigation, purchase-first entry retained.
- Static output: no paid content, PDFs, keys, local QA bridge or synthetic access embedded.

The mastery threshold and commercial access product remain disabled. Production publishing requires deployment access and explicit release approval; no existing CE ownership is modified.
