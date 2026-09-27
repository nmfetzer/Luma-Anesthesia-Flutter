# CE HALO Course 1 certificate generator

The first generator version adds an account-linked certificate screen, a downloadable branded PDF preview, and a server-authoritative award-record foundation. Official issuance remains disabled while the provider approves the certificate and supplies the signature image.

## Available now

- **Certificate area:** Open Course 1, choose “Course certificate,” then choose “Preview certificate design” as the creator. No purchase or module completion is needed for the creator's design preview.
- **Autofill:** Full name, credentials, optional AANA ID, and learner-reported completion location come from the saved course registration. The preview does not write a completion or award.
- **Branding:** Portrait US Letter, CE HALO gold symbol, navy header, navy/gold border, and info@cehalo.com. The sample carries a prominent “PREVIEW ONLY / NOT VALID FOR CE CREDIT” label and awards zero credits.
- **Program:** A Medication Review for the Experienced CRNA; 20.00 MAC Ed CE credits, including 17.50 Pharmacology & Therapeutics and 2.50 Pain Management. Code 1047239; expiration 9/30/2029. Reporting class 196397 stays out of the learner certificate.
- **Download:** PDF download in the Chrome portal, with the printing package's share/save integration for native platforms. Browser behavior is tested; native device validation is still required.

## Official issuance foundation

The `ce_course1_certificate` RPC accepts only `status`, `preview`, or `issue`, never a caller-supplied learner ID, credit amount, or completion date. It uses the authenticated account and server-held learning records.

An official award requires a non-preview learner, a verified and unrevoked course purchase, a released course, approved certificate settings/signature, and all 11 modules with read acknowledgment, a passing quiz attempt, evaluation, and official completion record. Participation must fall within October 1, 2026 through September 30, 2029. Completion dates come from stored activity, not the PDF-generation date.

The award table has one row per account/course. The RPC locks the learner state before issuance and returns the same stored snapshot on repeat requests. Snapshot details do not change when registration is edited later. Existing awards can be retrieved after program expiration. No learner has direct table access; no public certificate URL or public personal-information lookup has been added.

## Approval and next implementation step

- **Provider identity:** The draft uses the previously supplied “Nicole M Fetzer, MS, CRNA,” “Owner, CE HALO LLC,” and “Buffalo, New York.” Confirm these before official release.
- **Signature:** The preview explicitly says “Provider signature pending approval.” Supply/approve the transparent signature PNG before enabling issuance. No signature has been fabricated.
- **Archival and reporting:** The database stores the immutable application-level award snapshot; the app renders the PDF from it. Exact PDF-byte archival, provider certificate-ledger export, automated email delivery, correction/revocation workflow, and AANA submission are not implemented in this first version. The existing provider module ledger remains separate and is not an AANA-formatted upload.
- **Release:** `enabled=false` and `approved_at=null` in certificate settings; Course 1 remains `released=false`. No store sales or official CE awards have been enabled. No official certificates were issued by testing.
- **Activation review:** Before turning issuance on, finish archival/reporting integration, confirm provider identity and signature, validate a complete paid-learner flow in staging during the approved period, and test native device save/share.

## Requirements reference

AANA's current provider responsibilities specify digitally populated certificate information, including learner name and AANA ID, provider name/city/state, program title/location/date, credits awarded, approval code/expiration/approved credits, provider signature, and the California BRN statement ([AANA Program Provider Responsibilities, August 2026](https://www.aana.com/wp-content/uploads/2023/04/Program-Provider-Responsibilities-August-2026.pdf)). The exact three approval/designation statements from the program approval letter are retained; the California statement uses AANA's CEP #10862, not a claim that CE HALO has that provider number.

## Verification

- Five certificate-specific Flutter tests cover preview registration, zero-credit behavior, blocked issuance, PDF generation, missing official data, long fields, and 375/1280-pixel requirements screens.
- The full Flutter suite passed 314 tests before the final PDF-layout refinements; the certificate-specific tests were rerun after those refinements.
- Live SQL safety tests run inside a rolled-back transaction: anonymous access denied, direct client table writes denied, provider preview allowed, no preview awards, non-provider preview denied, unpaid/incomplete issuance denied, immutable snapshot retrieval, and cross-account isolation.
- Desktop (1280px) and mobile (390px) browser checks passed registration-to-certificate navigation, creator preview, PDF download, and return to requirements, with no page errors. Long recipient/location fields were rendered and visually inspected.
- Production purchases, clinical content, module quizzes, evaluations, and reviewer access were not modified.
