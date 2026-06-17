import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/guardian/presentation/guardian_login_placeholder.dart';
import '../../features/launcher/presentation/easy_home_screen.dart';
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
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('자세한 홈'))),
      ),
      GoRoute(
        path: Routes.sos,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('SOS'))),
      ),
      GoRoute(
        path: Routes.familyLink,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('가족 연결'))),
      ),
      GoRoute(
        path: Routes.moreApps,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('더 보기'))),
      ),
    ],
  );
});
