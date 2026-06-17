import 'app_category.dart';

/// A single launcher home button. Phase 1 uses fixed defaults; Phase 2 makes
/// these editable and persisted.
class LauncherApp {
  const LauncherApp({required this.label, required this.category});

  final String label;
  final AppCategory category;
}

/// Easy mode 2×2 grid (04_SCREEN_SPEC 정말 쉬운 화면).
const List<LauncherApp> defaultEasyApps = [
  LauncherApp(label: '전화', category: AppCategory.phone),
  LauncherApp(label: '문자', category: AppCategory.message),
  LauncherApp(label: '앨범', category: AppCategory.gallery),
  LauncherApp(label: '영상 보기', category: AppCategory.youtube),
];

/// Detailed mode 6 buttons (04_SCREEN_SPEC 자세한 화면).
const List<LauncherApp> defaultDetailedApps = [
  LauncherApp(label: '전화', category: AppCategory.phone),
  LauncherApp(label: '문자', category: AppCategory.message),
  LauncherApp(label: '카카오톡', category: AppCategory.kakao),
  LauncherApp(label: '영상 보기', category: AppCategory.youtube),
  LauncherApp(label: '사진찍기', category: AppCategory.camera),
  LauncherApp(label: '사진 보기', category: AppCategory.gallery),
];
