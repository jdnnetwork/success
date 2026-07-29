import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/guardian/application/guardian_session_controller.dart';
import '../../features/guardian/presentation/guardian_dashboard_screen.dart';
import '../../features/launcher/application/senior_settings_controller.dart';
import '../../features/launcher/presentation/detailed_home_screen.dart';
import '../../features/launcher/presentation/easy_home_screen.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../theme/app_colors.dart';
import '../../domain/senior_settings.dart';

/// Where the app should land when it starts.
enum LaunchDestination { splash, seniorHome, guardianDashboard }

/// Decides the landing screen from what the device has saved.
///
/// The senior case is the one that matters: this app is meant to become the
/// phone's launcher, so pressing Home must not land on a splash screen.
/// A saved screen mode therefore wins even if a guardian session also exists —
/// on a senior's phone the launcher always comes first.
LaunchDestination launchDestinationFor({
  required ScreenMode? savedScreenMode,
  required bool guardianSignedIn,
}) {
  if (savedScreenMode != null) return LaunchDestination.seniorHome;
  if (guardianSignedIn) return LaunchDestination.guardianDashboard;
  return LaunchDestination.splash;
}

/// The widget behind `/`. Reads the saved settings, then shows the screen the
/// device has earned rather than always starting from the splash.
class LaunchGate extends ConsumerWidget {
  const LaunchGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(seniorSettingsControllerProvider);

    return settings.when(
      // Reading one preferences key is fast, and the senior's phone opens
      // straight into this. A spinner would flash; the paper colour does not.
      loading: () => const ColoredBox(color: AppColors.splashBgMid),
      error: (_, _) => const SplashScreen(),
      data: (value) => switch (launchDestinationFor(
        savedScreenMode: value.screenMode,
        // Restored by Supabase from disk, so a guardian who signed in last
        // week does not land on the splash.
        guardianSignedIn: ref.watch(guardianSignedInProvider),
      )) {
        LaunchDestination.splash => const SplashScreen(),
        LaunchDestination.seniorHome => switch (value.screenMode!) {
          ScreenMode.easy => const EasyHomeScreen(),
          ScreenMode.detailed => const DetailedHomeScreen(),
        },
        LaunchDestination.guardianDashboard => const GuardianDashboardScreen(),
      },
    );
  }
}
