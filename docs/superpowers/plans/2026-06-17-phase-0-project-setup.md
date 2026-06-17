# Phase 0: Project Setup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish the 잘보이네 Flutter app foundation — project structure, routing, two-tone theme, Riverpod state management, and the mock-repository pattern — with the role-split first screen rendering and no Supabase dependency.

**Architecture:** Feature-first folder layout under `lib/`. `go_router` drives navigation from route constants. Riverpod's `ProviderScope` wraps the app; repositories are exposed as providers behind abstract interfaces with in-memory mock implementations (real `shared_preferences` backing arrives in Phase 2). The first screen is the senior-app entry (role split) per `04_SCREEN_SPEC.md`; senior onboarding and guardian login are Phase-1 placeholder routes.

**Tech Stack:** Flutter 3.38.9 (Dart 3.10), `flutter_riverpod`, `go_router`, `shared_preferences` (declared now, used in Phase 2). No Supabase in Phase 0.

**Source of truth:** `docs/claude-code/` (esp. `04_SCREEN_SPEC.md`, `07_PHASE_PLAN_FOR_CLAUDE_CODE.md`). Decisions locked during brainstorming: state management = Riverpod; local storage = shared_preferences.

**Phase 0 Acceptance (from `07_PHASE_PLAN_FOR_CLAUDE_CODE.md`):**
- app runs
- first screen renders
- no Supabase required

---

## File Structure

Created/modified in this plan:

- `pubspec.yaml` — **Modify**: add `flutter_riverpod`, `go_router`, `shared_preferences`; remove `supabase_flutter`.
- `lib/main.dart` — **Modify**: replace Todos template; `ProviderScope` + `runApp(App())`, no Supabase.
- `lib/app.dart` — **Create**: `App` widget, `MaterialApp.router` wired to router + senior theme.
- `lib/core/theme/app_colors.dart` — **Create**: color tokens for senior (warm) and guardian (white/blue) palettes.
- `lib/core/theme/app_theme.dart` — **Create**: `AppTheme.senior` and `AppTheme.guardian` `ThemeData`.
- `lib/core/router/routes.dart` — **Create**: route path constants.
- `lib/core/router/app_router.dart` — **Create**: `GoRouter` configuration + `goRouterProvider`.
- `lib/features/onboarding/presentation/role_split_screen.dart` — **Create**: first screen (role split).
- `lib/features/onboarding/presentation/senior_onboarding_placeholder.dart` — **Create**: Phase-1 placeholder.
- `lib/features/guardian/presentation/guardian_login_placeholder.dart` — **Create**: Phase-1 placeholder.
- `lib/domain/senior_settings.dart` — **Create**: `ScreenMode` enum + `SeniorSettings` model.
- `lib/data/senior_settings_repository.dart` — **Create**: abstract `SeniorSettingsRepository` + `MockSeniorSettingsRepository` + `seniorSettingsRepositoryProvider`.
- `test/data/senior_settings_repository_test.dart` — **Create**: mock repository unit tests.
- `test/widget_test.dart` — **Modify**: replace counter smoke test with first-screen render + navigation test.

---

## Task 1: Dependency swap & branch setup

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Create a working branch**

The repo is on the default `main` branch. Branch before committing.

Run:
```bash
git checkout -b phase-0-project-setup
```
Expected: `Switched to a new branch 'phase-0-project-setup'`

- [ ] **Step 2: Remove Supabase, add Phase 0 dependencies**

Run:
```bash
flutter pub remove supabase_flutter
flutter pub add flutter_riverpod go_router shared_preferences
```
Expected: `pubspec.yaml` no longer lists `supabase_flutter`; lists `flutter_riverpod`, `go_router`, `shared_preferences`. `flutter pub get` resolves with no errors.

- [ ] **Step 3: Verify analyzer baseline**

Run: `flutter analyze`
Expected: errors only in `lib/main.dart` and `test/widget_test.dart` (they still reference the removed Supabase template / old `MyApp`). These are fixed in later tasks. No dependency-resolution errors.

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: swap supabase for riverpod/go_router/shared_preferences"
```

---

## Task 2: Theme base (senior + guardian palettes)

Per `04_SCREEN_SPEC.md`: senior app = large text, large buttons, warm palette; guardian app = white background, blue accent.

**Files:**
- Create: `lib/core/theme/app_colors.dart`
- Create: `lib/core/theme/app_theme.dart`

- [ ] **Step 1: Create color tokens**

Create `lib/core/theme/app_colors.dart`:

```dart
import 'package:flutter/material.dart';

/// Color tokens for the two app personas.
///
/// Values are extracted verbatim from the canonical design sources in
/// `design-reference/see/`:
///   - Senior (피보호자): `launcher.jsx` (PAGE_BG / INK / APPS tiles / SOS)
///     and `splash.jsx` (SplashC terracotta CTA).
///   - Guardian (보호자): `styles.css` `:root` high-contrast token set.
class AppColors {
  AppColors._();

  // ── Senior — warm cream / clay (launcher.jsx, splash.jsx) ──
  // PAGE_BG = linear-gradient(180deg, #FDF7EE 0%, #F6EBDA 100%)
  static const seniorBackground = Color(0xFFFDF7EE); // gradient top (cream)
  static const seniorBackgroundEnd = Color(0xFFF6EBDA); // gradient bottom (soft clay)
  static const seniorSurface = Color(0xFFFFFFFF); // card / list-row surface
  static const seniorPrimary = Color(0xFFE0481C); // terracotta CTA (SplashC btn / voice)
  static const seniorOnSurface = Color(0xFF3A2410); // INK — primary text
  static const seniorTextSecondary = Color(0xFF7A5A40); // INK_SOFT — secondary text
  static const seniorBorder = Color(0xFFC9A98C); // muted clay (chevron / divider)
  static const seniorSos = Color(0xFFD62116); // SOS gradient base (긴급 구조)

  // Senior launcher app-tile categories (c1 light → c2 base), from APPS in
  // launcher.jsx. Used by the home grid in Phase 1.
  static const seniorButtonGreen = Color(0xFF4E9457); // 전화
  static const seniorButtonGreenLight = Color(0xFF6FB36A);
  static const seniorButtonBlue = Color(0xFF4374B8); // 메시지
  static const seniorButtonBlueLight = Color(0xFF5E96D6);
  static const seniorButtonYellow = Color(0xFFF2A93B); // 카카오톡
  static const seniorButtonYellowLight = Color(0xFFFFCE5C);
  static const seniorButtonRed = Color(0xFFD8431C); // 유튜브
  static const seniorButtonRedLight = Color(0xFFF2683E);
  static const seniorButtonPurple = Color(0xFF7E55B0); // 카메라
  static const seniorButtonPurpleLight = Color(0xFFA074C8);
  static const seniorButtonPink = Color(0xFFC85E94); // 갤러리
  static const seniorButtonPinkLight = Color(0xFFE07AAC);

  // ── Guardian — high-contrast white / blue (styles.css :root) ──
  static const guardianPrimary = Color(0xFF0B5FD9); // --c-primary (deep blue)
  static const guardianBackground = Color(0xFFFFFFFF); // --c-bg
  static const guardianSurface = Color(0xFFF5F2EA); // --c-bg-soft (warm off-white)
  static const guardianOnSurface = Color(0xFF1A1A1A); // --c-ink
  static const guardianBorder = Color(0xFFE0DDD3); // --c-line
  static const guardianAccent = Color(0xFFE8B500); // --c-accent (golden)
  static const guardianDanger = Color(0xFFC8102E); // --c-danger
}
```

- [ ] **Step 2: Create themes**

Create `lib/core/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Two [ThemeData] personas. The senior theme is the app default
/// (the role-split first screen is the senior-app entry point).
class AppTheme {
  AppTheme._();

  static ThemeData get senior {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.seniorPrimary,
      brightness: Brightness.light,
    ).copyWith(
      surface: AppColors.seniorSurface,
      onSurface: AppColors.seniorOnSurface,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.seniorBackground,
      // Larger defaults for senior-facing UI.
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 22),
        labelLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  static ThemeData get guardian {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.guardianPrimary,
      brightness: Brightness.light,
    ).copyWith(
      surface: AppColors.guardianSurface,
      onSurface: AppColors.guardianOnSurface,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.guardianBackground,
    );
  }
}
```

- [ ] **Step 3: Verify it compiles**

Run: `flutter analyze lib/core/theme`
Expected: No issues found.

- [ ] **Step 4: Commit**

```bash
git add lib/core/theme/
git commit -m "feat: add senior and guardian theme bases"
```

---

## Task 3: Domain model + mock repository (establishes the pattern)

This task locks in the mock-repository + Riverpod-provider pattern that every later phase follows. We model the senior's screen-mode choice — the one piece of state the first screen flows into.

**Files:**
- Create: `lib/domain/senior_settings.dart`
- Create: `lib/data/senior_settings_repository.dart`
- Test: `test/data/senior_settings_repository_test.dart`

- [ ] **Step 1: Create the domain model**

Create `lib/domain/senior_settings.dart`:

```dart
/// Which launcher home the senior sees. Chosen during onboarding (Phase 1).
enum ScreenMode { easy, detailed }

/// Persistent senior-facing settings. In Phase 0 this only carries the
/// screen-mode choice; later phases extend it (font size, etc.).
class SeniorSettings {
  const SeniorSettings({this.screenMode});

  /// `null` means the senior has not chosen a mode yet.
  final ScreenMode? screenMode;

  SeniorSettings copyWith({ScreenMode? screenMode}) =>
      SeniorSettings(screenMode: screenMode ?? this.screenMode);

  @override
  bool operator ==(Object other) =>
      other is SeniorSettings && other.screenMode == screenMode;

  @override
  int get hashCode => screenMode.hashCode;
}
```

- [ ] **Step 2: Write the failing repository test**

Create `test/data/senior_settings_repository_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/senior_settings.dart';
import 'package:app/data/senior_settings_repository.dart';

void main() {
  group('MockSeniorSettingsRepository', () {
    test('load returns empty settings before any save', () async {
      final repo = MockSeniorSettingsRepository();
      final settings = await repo.load();
      expect(settings.screenMode, isNull);
    });

    test('save then load round-trips the screen mode', () async {
      final repo = MockSeniorSettingsRepository();
      await repo.save(const SeniorSettings(screenMode: ScreenMode.easy));
      final settings = await repo.load();
      expect(settings.screenMode, ScreenMode.easy);
    });
  });
}
```

- [ ] **Step 3: Run the test to verify it fails**

Run: `flutter test test/data/senior_settings_repository_test.dart`
Expected: FAIL — `senior_settings_repository.dart` does not exist (compile error / target of URI doesn't exist).

- [ ] **Step 4: Create the repository interface, mock, and provider**

Create `lib/data/senior_settings_repository.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/senior_settings.dart';

/// Persistence boundary for [SeniorSettings].
///
/// Phase 0 ships an in-memory mock. Phase 2 adds a shared_preferences-backed
/// implementation behind this same interface — consumers do not change.
abstract interface class SeniorSettingsRepository {
  Future<SeniorSettings> load();
  Future<void> save(SeniorSettings settings);
}

/// In-memory implementation for Phase 0 (no persistence across restarts).
class MockSeniorSettingsRepository implements SeniorSettingsRepository {
  SeniorSettings _state = const SeniorSettings();

  @override
  Future<SeniorSettings> load() async => _state;

  @override
  Future<void> save(SeniorSettings settings) async => _state = settings;
}

/// Override this provider in Phase 2 with the shared_preferences-backed repo.
final seniorSettingsRepositoryProvider = Provider<SeniorSettingsRepository>(
  (ref) => MockSeniorSettingsRepository(),
);
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `flutter test test/data/senior_settings_repository_test.dart`
Expected: PASS — both tests green.

- [ ] **Step 6: Commit**

```bash
git add lib/domain/senior_settings.dart lib/data/senior_settings_repository.dart test/data/senior_settings_repository_test.dart
git commit -m "feat: add SeniorSettings model and mock repository"
```

---

## Task 4: Router + route constants

**Files:**
- Create: `lib/core/router/routes.dart`
- Create: `lib/core/router/app_router.dart`
- Create: `lib/features/onboarding/presentation/senior_onboarding_placeholder.dart`
- Create: `lib/features/guardian/presentation/guardian_login_placeholder.dart`

> Note: `role_split_screen.dart` is referenced by the router and is created in Task 5. Build Task 4 and Task 5 together before running the app; the analyzer will flag the missing import until Task 5 Step 1 lands.

- [ ] **Step 1: Create route constants**

Create `lib/core/router/routes.dart`:

```dart
/// Centralized route paths. Keep all navigation targets here.
class Routes {
  Routes._();

  static const firstScreen = '/';
  static const seniorOnboarding = '/onboarding';
  static const guardianLogin = '/guardian-login';
}
```

- [ ] **Step 2: Create the Phase-1 placeholders**

Create `lib/features/onboarding/presentation/senior_onboarding_placeholder.dart`:

```dart
import 'package:flutter/material.dart';

/// Placeholder for the senior onboarding flow (built in Phase 1).
class SeniorOnboardingPlaceholder extends StatelessWidget {
  const SeniorOnboardingPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('피보호자 온보딩 (Phase 1)')),
    );
  }
}
```

Create `lib/features/guardian/presentation/guardian_login_placeholder.dart`:

```dart
import 'package:flutter/material.dart';

/// Placeholder for the guardian login flow (built in Phase 1/3).
class GuardianLoginPlaceholder extends StatelessWidget {
  const GuardianLoginPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('보호자 로그인 (Phase 1)')),
    );
  }
}
```

- [ ] **Step 3: Create the router provider**

Create `lib/core/router/app_router.dart`:

```dart
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
```

- [ ] **Step 4: Commit**

```bash
git add lib/core/router/ lib/features/onboarding/presentation/senior_onboarding_placeholder.dart lib/features/guardian/presentation/guardian_login_placeholder.dart
git commit -m "feat: add go_router config, route constants, and phase-1 placeholders"
```

---

## Task 5: First screen (role split) + app wiring

Per `04_SCREEN_SPEC.md` 피보호자 첫 실행:
- 앱 이름: 잘보이네
- 설명: 어르신을 위한 쉬운 스마트폰
- 큰 버튼: 시작하기 → senior onboarding
- 작은 안내: 가족 및 어르신을 도와주시는 분은 여기를 눌러주세요 → guardian login

**Files:**
- Create: `lib/features/onboarding/presentation/role_split_screen.dart`
- Create: `lib/app.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1: Create the role-split first screen**

Create `lib/features/onboarding/presentation/role_split_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';

/// First screen. Splits into the senior flow (large CTA) and the
/// guardian flow (small text link). No onboarding questions here.
class RoleSplitScreen extends StatelessWidget {
  const RoleSplitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              Text('잘보이네', style: text.headlineLarge),
              const SizedBox(height: 12),
              Text(
                '어르신을 위한 쉬운 스마트폰',
                style: text.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(72),
                  ),
                  onPressed: () => context.go(Routes.seniorOnboarding),
                  child: const Text('시작하기'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go(Routes.guardianLogin),
                child: const Text('가족 및 어르신을 도와주시는 분은 여기를 눌러주세요'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Create the App widget**

Create `lib/app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Root widget. Uses the senior theme by default (the first screen is the
/// senior-app entry). Guardian screens apply [AppTheme.guardian] locally
/// in later phases.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: '잘보이네',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.senior,
      routerConfig: router,
    );
  }
}
```

- [ ] **Step 3: Replace main.dart (remove Supabase)**

Replace the entire contents of `lib/main.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  runApp(const ProviderScope(child: App()));
}
```

- [ ] **Step 4: Analyze the whole project**

Run: `flutter analyze`
Expected: No issues found. (All Supabase references gone; router import of `role_split_screen.dart` now resolves.)

- [ ] **Step 5: Commit**

```bash
git add lib/main.dart lib/app.dart lib/features/onboarding/presentation/role_split_screen.dart
git commit -m "feat: render role-split first screen with riverpod + router wiring"
```

---

## Task 6: First-screen widget test + acceptance run

**Files:**
- Modify: `test/widget_test.dart`

- [ ] **Step 1: Replace the counter smoke test with a failing first-screen test**

Replace the entire contents of `test/widget_test.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/app.dart';

void main() {
  testWidgets('first screen renders app name and CTA', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    expect(find.text('잘보이네'), findsOneWidget);
    expect(find.text('시작하기'), findsOneWidget);
    expect(
      find.text('가족 및 어르신을 도와주시는 분은 여기를 눌러주세요'),
      findsOneWidget,
    );
  });

  testWidgets('tapping 시작하기 navigates to senior onboarding', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();

    expect(find.text('피보호자 온보딩 (Phase 1)'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run the widget test**

Run: `flutter test test/widget_test.dart`
Expected: PASS — both tests green. (If Step 1 were run before Task 5 landed it would fail; here it passes.)

- [ ] **Step 3: Run the full test suite**

Run: `flutter test`
Expected: PASS — `test/data/senior_settings_repository_test.dart` and `test/widget_test.dart` all green.

- [ ] **Step 4: Verify Acceptance — app runs & first screen renders**

Run: `flutter run -d windows` (or any available device from `flutter devices`)
Expected: App launches with no Supabase initialization; the role-split first screen shows "잘보이네", the "시작하기" button, and the guardian link. Tapping "시작하기" shows the onboarding placeholder. Close the app.

- [ ] **Step 5: Final formatting & analyze**

Run:
```bash
dart format lib test
flutter analyze
```
Expected: formatting applied (or "unchanged"); analyze reports no issues.

- [ ] **Step 6: Commit**

```bash
git add test/widget_test.dart lib test
git commit -m "test: cover first-screen render and navigation; remove counter smoke test"
```

---

## Acceptance Checklist (Phase 0)

- [ ] `flutter analyze` → no issues
- [ ] `flutter test` → all green
- [ ] App runs with **no Supabase** initialization (`grep` for `supabase` in `lib/` returns nothing)
- [ ] First screen (role split) renders and navigates to placeholders
- [ ] Riverpod `ProviderScope` in place; one mock repository wired behind a provider
- [ ] Two-tone theme (`AppTheme.senior`, `AppTheme.guardian`) defined; senior applied as default
- [ ] `go_router` config with `Routes` constants

## Out of Phase 0 (do NOT build here)

- Actual senior onboarding / screen-mode picker UI → Phase 1
- Easy/detailed home, SOS handoff → Phase 1
- shared_preferences-backed repository implementation → Phase 2
- Guardian dashboard → Phase 3
- Supabase schema, auth, real repositories → Phase 4
- Pairing/recovery, paid features → Phase 5/6
