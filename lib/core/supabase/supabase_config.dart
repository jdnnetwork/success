/// Where the app finds its Supabase project.
///
/// Passed at build time rather than committed:
///
/// ```
/// flutter run \
///   --dart-define=SUPABASE_URL=https://<ref>.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=<publishable key>
/// ```
///
/// [isConfigured] is false when either is missing, and every Supabase-backed
/// provider falls back to its in-memory twin. That is deliberate: Phases 0–3
/// were built to run with no backend, `flutter test` has no keys, and a
/// launcher that refuses to draw the senior's home screen because a build flag
/// was forgotten would be worse than one that runs offline.
class SupabaseConfig {
  const SupabaseConfig({required this.url, required this.anonKey});

  static const fromEnvironment = SupabaseConfig(
    url: String.fromEnvironment('SUPABASE_URL'),
    anonKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  final String url;
  final String anonKey;

  bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      other is SupabaseConfig && other.url == url && other.anonKey == anonKey;

  @override
  int get hashCode => Object.hash(url, anonKey);
}
