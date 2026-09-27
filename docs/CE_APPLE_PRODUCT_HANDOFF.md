# CE Apple Product Handoff

Recorded from the user's September 27, 2026 App Store Connect screenshots. These identifiers are case-sensitive and separate from the monthly/annual app subscriptions.

| CE purchase | Exact Apple Product ID | Apple ID | Screenshot status |
|---|---|---|---|
| Medication Review (20 AANA Approved MAC Ed Class A CEs) | `Medication_Review_for_the_Experienced_CRNA` | `6804191078` | Prepare for Submission |
| Uncommon but Catastrophic Anesthesia Events | `uncommon_anesthesia_events` | `6816681069` | Prepare for Submission |
| Legal Essentials for the CRNA | `legal_essentials_CRNA` | `6816681243` | Prepare for Submission |
| 3 Course AANA Approved Bundle Pack | `3_course_bundle_pack` | `6816681460` | Prepare for Submission |

The screenshots identify non-consumable purchases and show a notice about submitting the first non-consumable with a new app version. They do not establish approval, actual price, completed RevenueCat import, or a successful purchase.

## Integration boundary

- This subscription-integration change records the identifiers only; it does not edit concurrent CE course files or activate these purchases.
- Do not map these non-consumables as permanent app-Pro subscriptions. CE ownership and time-limited complimentary app access are different entitlements.
- Preserve the maximum-three-month policy: first individual course grants one month once per account; bundle-first grants three months; bundle after a course grants only two additional months. Additional individual courses, repeat bundles, refunds and restores do not reset the lifetime cap. See `20260927154627_ce_bonus_three_month_cap.sql`. A bundle upgrade follows remaining unrevoked CE time; paid subscription billing is unchanged.
- Existing paid subscriptions must not be silently canceled, paused, or extended by a CE purchase.
- Verify receipt ownership and refunds server-side before creating either CE ownership or a bonus grant.
- Google product IDs, CE RevenueCat entitlements/mappings, exact course ownership schema, and native acceptance still need confirmation by the CE integration session.
