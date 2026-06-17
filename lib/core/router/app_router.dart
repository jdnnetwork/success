import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/family/presentation/family_link_placeholder.dart';
import '../../features/guardian/presentation/guardian_login_placeholder.dart';
import '../../features/launcher/presentation/detailed_home_screen.dart';
import '../../features/launcher/presentation/easy_home_screen.dart';
import '../../features/launcher/presentation/more_apps_placeholder.dart';
import '../../features/launcher/presentation/sos_screen.dart';
import '../../features/onboarding/presentation/role_split_screen.dart';
import '../../features/onboarding/presentation/screen_mode_choice_screen.dart';
import 'routes.dart';

/// App-wide router. First screen is the senior-app entry (role split).
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.firstScreen,
    routes: [
      GoRoute(
        path: Routes.firstScreen,
        builder: (context, state) => const RoleSplitScreen(),
      ),
      GoRoute(
        path: Routes.seniorOnboarding,
        builder: (context, state) => const ScreenModeChoiceScreen(),
      ),
      GoRoute(
        path: Routes.guardianLogin,
        builder: (context, state) => const GuardianLoginPlaceholder(),
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
    ],
  );
});
