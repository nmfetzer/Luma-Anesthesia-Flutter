# Luma AI Flutter wiring

Updated September 25, 2026. This change adds the Luma mascot home tile and a
disabled credit-pack preview. It does not implement or enable native checkout,
transaction verification, a credit ledger, or AI generation.

## Product catalog

- Apple product ID: `luma_ai_credits_150`.
- Apple ID supplied in App Store Connect: `6816028615`.
- Type: consumable, one-time purchase.
- Quantity: 150 credits, one completed bounded text response per credit.
- U.S. price shown in the owner's screenshot: $4.99.
- Included subscription/CE allowance: not yet defined; not 150 by implication.
- Android product: not yet supplied; do not reuse the Apple ID by assumption.

`lib/ai/luma_ai_catalog.dart` is metadata for the preview only, not an
authoritative source for server credit grants. Future checkout must use a
store-fetched localized price, server-verified transactions and a server-owned
catalog/ledger. Client changes must never award credits.

## Navigation and safety

The shared `LumaAiTile` uses the owner's exact `LUMA333.PNG` image, already bundled
as `assets/branding/luma_assistant.png`. Phone, tablet and desktop homes open
`/luma-ai`; the menu and home search already link to the same route.

The existing safety acknowledgement remains the first screen. Continuing opens
the pack preview, not a prompt field or consent to third-party data transmission.
Both credit purchases and chat are disabled, with no model or billing SDK calls.
The Home action returns to the tile dashboard.

## Before activation

Obtain separate authorization, implement and test native billing and server
verification, the credit ledger and refunds, source entitlements, provider
consent/privacy disclosures, clinical educational safety, and cost limits.
TestFlight/sandbox and physical iOS testing have not been performed by this change.
