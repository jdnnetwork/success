import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/supabase/supabase_config.dart';
import 'core/theme/font_license.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerFontLicense();

  // A build with no --dart-define keys still runs: every repository falls back
  // to its in-memory twin. Phases 0–3 were built without a backend and are
  // expected to keep working without one.
  const config = SupabaseConfig.fromEnvironment;
  if (config.isConfigured) {
    // `publishableKey` accepts both the new `sb_publishable_…` key and the
    // legacy anon JWT, so either value of SUPABASE_ANON_KEY works.
    await Supabase.initialize(url: config.url, publishableKey: config.anonKey);
  }

  runApp(const ProviderScope(child: App()));
}
