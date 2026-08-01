/// Centralized route paths. Keep all navigation targets here.
class Routes {
  Routes._();

  static const firstScreen = '/';
  static const seniorOnboarding = '/onboarding';
  static const guardianStart = '/guardian-start';
  static const guardianLogin = '/guardian-login';
  static const guardianDashboard = '/guardian';

  // Senior launcher (Phase 1)
  static const easyHome = '/home/easy';
  static const detailedHome = '/home/detailed';
  static const sos = '/sos';
  static const familyLink = '/family-link';
  static const moreApps = '/more';
  static const familyMessages = '/messages';

  // Senior-facing settings (Phase 2)
  static const appSettings = '/settings/apps';
  static const fontSize = '/settings/font-size';
}
