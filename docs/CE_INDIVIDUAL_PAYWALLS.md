# Individual CE paywalls

Each course and the three-course bundle has a separate branded purchase screen. The course purchase action selects its exact existing product; the CE library also has a bundle shortcut.

| Screen | Existing product ID |
| --- | --- |
| A Medication Review for the Experienced CRNA | `Medication_Review_for_the_Experienced_CRNA` |
| Uncommon but Catastrophic Anesthesia Events | `uncommon_anesthesia_events` |
| Legal Essentials for the CRNA | `legal_essentials_CRNA` |
| Three-course bundle | `3_course_bundle_pack` |

## Presentation and purchase protections

- Navy celestial background, cream panel, symbol-and-halo branding, persistent Home and Close controls.
- Course-specific benefits, 20 MAC Ed CE credits per course and 60 across the bundle.
- Existing complimentary-access terms: one individual-course month once per account; bundle allowance totals three months, including a prior individual-course month.
- No subscription required to purchase CE. No automatic subscription enrollment from the bonus.
- Prices come exclusively from the store SDK. Web preview does not simulate a purchasable product or invent a price.
- Existing server eligibility, identity, duplicate-purchase, verification and sandbox protections remain in force.
- Restore, refresh, retry, Terms of Use and Privacy Policy controls.
- No changes to Apple configuration, RevenueCat configuration, live database flags, product pricing or CE content.

## Product-loading fallback

Read the existing `crna_courses` offering first. Fetch only missing allowlisted one-time products directly through RevenueCat's store-product API. Preserve valid products if another lookup fails; unresolved products remain unpurchasable and show retry messaging instead of implying the course is unreleased.

## Verification and release

Automated coverage includes partial/failed offering lookup, exact product IDs, rejecting subscriptions and unknown products, account entry, localized prices, retry, phone/tablet layouts, large text, legal links, route overlays and existing CE access flows.

Build a new signed iOS archive and upload it to TestFlight to test native purchases. A source push or web-preview deployment does not update an installed TestFlight build. Native StoreKit purchase/restore remains a device-level verification step; no purchase was made during this implementation.
