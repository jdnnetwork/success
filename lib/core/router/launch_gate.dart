/// Where the app should land when it starts.
enum LaunchDestination { splash, seniorHome, guardianDashboard }

/// Decides the landing screen from what the device has saved.
///
/// The senior case is the one that matters: this app is meant to become the
/// phone's launcher, so pressing Home must not land on a splash screen.
/// A saved screen mode therefore wins even if a guardian session also exists —
/// on a senior's phone the launcher always comes first.
///
/// Neither input can be supplied yet. Screen-mode persistence arrives in
/// Phase 2 and the guardian session in Phase 4; until then the caller passes
/// null/false and every launch falls through to the splash. The seam exists
/// now so navigation is not reworked twice.
LaunchDestination launchDestinationFor({
  required String? savedScreenMode,
  required bool guardianSignedIn,
}) {
  if (savedScreenMode != null) return LaunchDestination.seniorHome;
  if (guardianSignedIn) return LaunchDestination.guardianDashboard;
  return LaunchDestination.splash;
}
