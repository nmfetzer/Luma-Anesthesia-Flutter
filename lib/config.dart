// -----------------------------------------------------------------------------
// Luma Anesthesia — configuration
//
// Paste your Supabase project URL and anon (public) key here. Both are safe to
// commit — they identify the project, not you. Real secrets live server-side
// in Supabase and are protected by Row Level Security policies.
//
// Where to find these values:
//   Supabase dashboard → Settings → API → Project API keys → anon public
//
// Until these are filled in, the app runs against the bundled sample
// medications in assets/data/medications.json. Once set, it reads from
// Supabase automatically.
// -----------------------------------------------------------------------------

class LumaConfig {
  static const String supabaseUrl = 'https://xuckkusbbcxplpqclbxt.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_NXrT6ajzRKmpEfNKGh_G9g_Nd6RmEg7';

  /// True when both values above have been replaced with real credentials.
  static bool get supabaseConfigured =>
      supabaseUrl.startsWith('https://') && supabaseAnonKey.isNotEmpty;
}
