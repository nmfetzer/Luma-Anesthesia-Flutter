# Luma Anesthesia — Flutter

Clinical reference for anesthesia providers. One Flutter codebase → iOS, Android, and web (luma-anesthesia.app).

## What's in here

```
lib/
  main.dart                          # App entry, Supabase init
  config.dart                        # Supabase URL + publishable key
  theme/luma_theme.dart              # Fraunces / Inter / JetBrains Mono, brand colors
  models/medication.dart             # Medication entity (matches Base44 schema)
  data/medication_repository.dart    # Reads Supabase, falls back to bundled JSON
  screens/
    drugs_categories_screen.dart     # Category list (full-width rows)
    category_detail_screen.dart      # Alphabetized drugs + A-Z rail
  widgets/luma_app_bar.dart          # Shared top bar
assets/data/medications.json         # 47 anesthesia meds bundled as fallback
supabase/schema.sql                  # Database schema (paste into SQL Editor)
tools/import_to_supabase.mjs         # Base44 export → Supabase upsert
```

## First run

Prereqs: Flutter SDK installed, an iOS simulator or Android emulator (or just use `-d chrome` for web).

```bash
flutter pub get
flutter run                          # picks a running device automatically
flutter run -d chrome                # web build for luma-anesthesia.app
```

The app boots with 47 sample meds from `assets/data/medications.json` if Supabase can't be reached, so you can develop offline.

## Wiring up Supabase

1. In the Supabase dashboard for project `xuckkusbbcxplpqclbxt`, open the SQL Editor, paste the contents of `supabase/schema.sql`, and click Run.
2. Grab the **service_role** key from Settings → API. Do NOT commit it.
3. Import medications:

   ```bash
   npm install @supabase/supabase-js
   export SUPABASE_URL="https://xuckkusbbcxplpqclbxt.supabase.co"
   export SUPABASE_SERVICE_KEY="paste_service_role_here"
   node tools/import_to_supabase.mjs assets/data/medications.json
   ```

   Replace `assets/data/medications.json` with your full Base44 export (e.g. `medications-763.json`) to load the real dataset.

## Brand system

- **Fraunces** for display (drug names, screen titles) — never body/buttons.
- **Inter** for body/UI.
- **JetBrains Mono** for numbers only.
- Colors: Cream `#F7F4EF`, Ink Navy `#1F2937`, Halo Gold `#D4A574`, High Alert `#B84A3E`, Caution `#C99A2E`.
- Hairline dividers: `#E5DFD5` at 0.5 px.

Change any of these in `lib/theme/luma_theme.dart` and the whole app follows.
