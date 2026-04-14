/// Supabase configuration constants
/// Configure via --dart-define or environment variables
class SupabaseConstants {
  SupabaseConstants._();

  /// Supabase project URL
  /// Pass via: --dart-define=SUPABASE_URL=https://your-project.supabase.co
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL',
  );

  /// Supabase anonymous key
  /// Pass via: --dart-define=SUPABASE_ANON_KEY=your-anon-key
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );

  /// Table names
  static const String tableaFarmacias = 'farmacias';

  /// RPC function names
  static const String rpcFarmaciasCercanas = 'farmacias_cercanas';
}
