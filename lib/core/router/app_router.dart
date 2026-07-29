import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/family/presentation/family_link_placeholder.dart';
import '../../features/guardian/presentation/guardian_login_placeholder.dart';
import '../../features/guardian/presentation/guardian_dashboard_screen.dart';
import '../../features/guardian/presentation/guardian_start_screen.dart';
import '../../features/launcher/presentation/detailed_home_screen.dart';
import '../../features/launcher/presentation/easy_home_screen.dart';
import '../../features/launcher/presentation/app_settings_screen.dart';
import '../../features/launcher/presentation/font_size_screen.dart';
import '../../features/launcher/presentation/more_apps_placeholder.dart';
import '../../features/launcher/presentation/sos_screen.dart';
import '../../features/onboarding/presentation/screen_mode_choice_screen.dart';
import 'launch_gate.dart';
import 'routes.dart';

/// App-wide router. The first route is the launch gate: it decides whether the
/// splash should be shown at all. It now reads the saved screen mode, so a
/// senior who has chosen one lands on their home; the guardian-session check
/// arrives with Supabase in Phase 4. See [launchDestinationFor].
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.firstScreen,
    routes: [
      GoRoute(
        path: Routes.firstScreen,
        builder: (context, state) => const LaunchGate(),
      ),
      GoRoute(
        path: Routes.seniorOnboarding,
        builder: (context, state) => const ScreenModeChoiceScreen(),
      ),
      GoRoute(
        path: Routes.guardianStart,
        builder: (context, state) => const GuardianStartScreen(),
      ),
      GoRoute(
        path: Routes.guardianLogin,
        builder: (context, state) => const GuardianLoginPlaceholder(),
      ),
      GoRoute(
        path: Routes.guardianDashboard,
        builder: (context, state) => const GuardianDashboardScreen(),
      ),
      GoRoute(
        path: Routes.easyHome,
        builder: (context, state) => const EasyHomeScreen(),
      ),
      GoRoute(
        path: Routes.detailedHome,
        builder: (context, state) => const DetailedHomeScreen(),
      ),
      GoRoute(path: Routes.sos, builder: (context, state) => const SosScreen()),
      GoRoute(
        path: Routes.familyLink,
        builder: (context, state) => const FamilyLinkPlaceholder(),
      ),
      GoRoute(
        path: Routes.moreApps,
        builder: (context, state) => const MoreAppsPlaceholder(),
      ),
      GoRoute(
        path: Routes.appSettings,
        builder: (context, state) => const AppSettingsScreen(),
      ),
      GoRoute(
        path: Routes.fontSize,
        builder: (context, state) => const FontSizeScreen(),
      ),
    ],
  );
});
