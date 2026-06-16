import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/guardian/presentation/guardian_login_placeholder.dart';
import '../../features/onboarding/presentation/role_split_screen.dart';
import '../../features/onboarding/presentation/senior_onboarding_placeholder.dart';
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
        builder: (context, state) => const SeniorOnboardingPlaceholder(),
      ),
      GoRoute(
        path: Routes.guardianLogin,
        builder: (context, state) => const GuardianLoginPlaceholder(),
      ),
    ],
  );
});
