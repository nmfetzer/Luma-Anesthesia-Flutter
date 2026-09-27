# Luma Anesthesia App Icon

Updated September 27, 2026 at the owner's request.

- Solid dark navy background: `#081A33`.
- Gold medical symbol with halo and gold “Luma” beneath it.
- No smoke, ribbons, stars, decorative background, or baked-in rounded corners.
- Opaque 1024 × 1024 master: `assets/branding/luma_icon.png`.
- Google Play listing PNG: `assets/branding/luma_google_play_icon_512.png`.
- iOS, Android, macOS, Windows, and web launcher assets regenerated.
- Android adaptive and web maskable variants use inset artwork to preserve the wordmark.
- In-app symbol-only account, welcome, CE, and paywall assets are unchanged.

Regenerate the platform sizes with `python tool/generate_launcher_icons.py`
(requires Pillow). This changes repository/build assets; it does not submit a
new binary to either store or change the icon of an already installed build.
Native signing/build and on-device launcher verification remain release tasks.
