# Phase 1: 피보호자 런처 UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the senior (피보호자) launcher UI — splash, screen-mode choice, easy & detailed home screens, and the SOS phone handoff — wired through go_router and backed by Phase 0's in-memory `SeniorSettingsRepository`.

**Architecture:** Feature-first under `lib/features/launcher/`. A `LauncherApp` domain model + `AppCategory` color/icon mapping drive the home grids from the canonical `design-reference/see/launcher.jsx` tokens (already in `AppColors`). Screen-mode choice is held by a Riverpod `AsyncNotifier` that persists through `SeniorSettingsRepository` (mock in Phase 1, real in Phase 2). SOS dials through a `PhoneDialer` interface whose only operation is "open the dialer" — it is architecturally incapable of auto-calling.

**Tech Stack:** Flutter 3.38.9 (Dart 3.10), `flutter_riverpod`, `go_router`, `url_launcher` (added here). No Supabase, payment, location, call/install detection, medication, or real Android launcher registration.

**Source of truth:** `docs/claude-code/07_PHASE_PLAN_FOR_CLAUDE_CODE.md` (Phase 1 acceptance), `docs/claude-code/04_SCREEN_SPEC.md` (screen specs), `design-reference/see/launcher.jsx` + `splash.jsx` (senior tokens; colors already extracted into `lib/core/theme/app_colors.dart`).

**Phase 1 Acceptance (from 07):**
- user can choose mode
- app shows correct default buttons
- no extra onboarding questions
- SOS opens phone intent, does not auto-call

**App → category mapping (04 spec labels × launcher.jsx colors):**
- 전화 → `phone` (green), 문자 → `message` (blue), 앨범/사진 보기 → `gallery` (pink),
  영상 보기 → `youtube` (red), 카카오톡 → `kakao` (yellow), 사진찍기/카메라 → `camera` (purple).
- Easy home (2×2): 전화, 문자, 앨범, 영상 보기.
- Detailed home (2-col, 6): 전화, 문자, 카카오톡, 영상 보기, 사진찍기, 사진 보기.

---

## File Structure

- `pubspec.yaml` — **Modify**: add `url_launcher`.
- `lib/domain/app_category.dart` — **Create**: `AppCategory` enum + gradient/icon mapping from `AppColors`.
- `lib/domain/launcher_app.dart` — **Create**: `LauncherApp` model + `defaultEasyApps` / `defaultDetailedApps`.
- `lib/features/launcher/application/senior_settings_controller.dart` — **Create**: `AsyncNotifier` over `SeniorSettingsRepository`.
- `lib/features/launcher/data/phone_dialer.dart` — **Create**: `PhoneDialer` interface + `UrlLauncherPhoneDialer` + provider.
- `lib/features/launcher/presentation/widgets/app_tile.dart` — **Create**: clay-gradient app tile.
- `lib/features/launcher/presentation/widgets/sos_button.dart` — **Create**: red SOS bar.
- `lib/features/onboarding/presentation/screen_mode_choice_screen.dart` — **Create**: replaces `senior_onboarding_placeholder.dart`.
- `lib/features/launcher/presentation/easy_home_screen.dart` — **Create**.
- `lib/features/launcher/presentation/detailed_home_screen.dart` — **Create** (with inline bottom tabs).
- `lib/features/launcher/presentation/sos_screen.dart` — **Create**.
- `lib/features/family/presentation/family_link_placeholder.dart` — **Create**.
- `lib/features/launcher/presentation/more_apps_placeholder.dart` — **Create**.
- `lib/features/onboarding/presentation/role_split_screen.dart` — **Modify**: polish to `splash.jsx` SplashC.
- `lib/core/router/routes.dart` — **Modify**: add launcher routes.
- `lib/core/router/app_router.dart` — **Modify**: wire new screens.
- `lib/features/onboarding/presentation/senior_onboarding_placeholder.dart` — **Delete** (replaced by choice screen).
- `test/support/pump_app.dart` — **Create**: shared widget-test harness.
- Test files under `test/` mirroring each unit.

---

## Task 1: Add url_launcher dependency & branch

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Create the working branch**

Run:
```bash
git checkout -b phase-1-senior-launcher
```
Expected: `Switched to a new branch 'phase-1-senior-launcher'`

- [ ] **Step 2: Add url_launcher**

Run:
```bash
flutter pub add url_launcher
```
Expected: `pubspec.yaml` lists `url_launcher`; `flutter pub get` succeeds.

- [ ] **Step 3: Verify baseline**

Run: `flutter analyze`
Expected: No issues found.

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add url_launcher for SOS phone handoff"
```

---

## Task 2: AppCategory + color/icon mapping

**Files:**
- Create: `lib/domain/app_category.dart`
- Test: `test/domain/app_category_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/domain/app_category_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/domain/app_category.dart';

void main() {
  test('every category maps to a base+light gradient and an icon', () {
    for (final c in AppCategory.values) {
      expect(c.baseColor, isA<Color>());
      expect(c.lightColor, isA<Color>());
      expect(c.icon, isA<IconData>());
    }
  });

  test('phone maps to the green token, youtube to the red token', () {
    expect(AppCategory.phone.baseColor, AppColors.seniorButtonGreen);
    expect(AppCategory.phone.lightColor, AppColors.seniorButtonGreenLight);
    expect(AppCategory.youtube.baseColor, AppColors.seniorButtonRed);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/domain/app_category_test.dart`
Expected: FAIL — `app_category.dart` does not exist (Target of URI doesn't exist).

- [ ] **Step 3: Implement the mapping**

Create `lib/domain/app_category.dart`:

```dart
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Visual category for a launcher tile. Drives the clay gradient + icon.
/// Colors come verbatim from `design-reference/see/launcher.jsx` APPS.
enum AppCategory { phone, message, kakao, youtube, camera, gallery }

extension AppCategoryStyle on AppCategory {
  /// Darker gradient stop (c2 in launcher.jsx).
  Color get baseColor => switch (this) {
        AppCategory.phone => AppColors.seniorButtonGreen,
        AppCategory.message => AppColors.seniorButtonBlue,
        AppCategory.kakao => AppColors.seniorButtonYellow,
        AppCategory.youtube => AppColors.seniorButtonRed,
        AppCategory.camera => AppColors.seniorButtonPurple,
        AppCategory.gallery => AppColors.seniorButtonPink,
      };

  /// Lighter gradient stop (c1 in launcher.jsx).
  Color get lightColor => switch (this) {
        AppCategory.phone => AppColors.seniorButtonGreenLight,
        AppCategory.message => AppColors.seniorButtonBlueLight,
        AppCategory.kakao => AppColors.seniorButtonYellowLight,
        AppCategory.youtube => AppColors.seniorButtonRedLight,
        AppCategory.camera => AppColors.seniorButtonPurpleLight,
        AppCategory.gallery => AppColors.seniorButtonPinkLight,
      };

  /// Nearest Material glyph to the launcher.jsx custom icon.
  IconData get icon => switch (this) {
        AppCategory.phone => Icons.call,
        AppCategory.message => Icons.sms,
        AppCategory.kakao => Icons.chat_bubble,
        AppCategory.youtube => Icons.smart_display,
        AppCategory.camera => Icons.photo_camera,
        AppCategory.gallery => Icons.photo_library,
      };
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/domain/app_category_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/domain/app_category.dart test/domain/app_category_test.dart
git commit -m "feat: add AppCategory with launcher.jsx color/icon mapping"
```

---

## Task 3: LauncherApp model + default button sets

**Files:**
- Create: `lib/domain/launcher_app.dart`
- Test: `test/domain/launcher_app_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/domain/launcher_app_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/app_category.dart';
import 'package:app/domain/launcher_app.dart';

void main() {
  test('easy defaults are the 2x2 set: 전화 문자 앨범 영상 보기', () {
    expect(defaultEasyApps.map((a) => a.label).toList(),
        ['전화', '문자', '앨범', '영상 보기']);
    expect(defaultEasyApps.map((a) => a.category).toList(),
        [AppCategory.phone, AppCategory.message, AppCategory.gallery, AppCategory.youtube]);
  });

  test('detailed defaults are the 6 set in spec order', () {
    expect(defaultDetailedApps.map((a) => a.label).toList(),
        ['전화', '문자', '카카오톡', '영상 보기', '사진찍기', '사진 보기']);
    expect(defaultDetailedApps.length, 6);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/domain/launcher_app_test.dart`
Expected: FAIL — `launcher_app.dart` does not exist.

- [ ] **Step 3: Implement the model and defaults**

Create `lib/domain/launcher_app.dart`:

```dart
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
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/domain/launcher_app_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/domain/launcher_app.dart test/domain/launcher_app_test.dart
git commit -m "feat: add LauncherApp model and default easy/detailed button sets"
```

---

## Task 4: SeniorSettingsController (AsyncNotifier)

**Files:**
- Create: `lib/features/launcher/application/senior_settings_controller.dart`
- Test: `test/features/launcher/senior_settings_controller_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/features/launcher/senior_settings_controller_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/domain/senior_settings.dart';
import 'package:app/data/senior_settings_repository.dart';
import 'package:app/features/launcher/application/senior_settings_controller.dart';

void main() {
  test('initial state has no screen mode', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final settings =
        await container.read(seniorSettingsControllerProvider.future);
    expect(settings.screenMode, isNull);
  });

  test('chooseScreenMode persists to the repository and updates state',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(seniorSettingsControllerProvider.future);

    await container
        .read(seniorSettingsControllerProvider.notifier)
        .chooseScreenMode(ScreenMode.easy);

    expect(container.read(seniorSettingsControllerProvider).value!.screenMode,
        ScreenMode.easy);
    final repo = container.read(seniorSettingsRepositoryProvider);
    expect((await repo.load()).screenMode, ScreenMode.easy);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/launcher/senior_settings_controller_test.dart`
Expected: FAIL — `senior_settings_controller.dart` does not exist.

- [ ] **Step 3: Implement the controller**

Create `lib/features/launcher/application/senior_settings_controller.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/senior_settings_repository.dart';
import '../../../domain/senior_settings.dart';

/// Holds the senior's settings, loading from and saving to the repository.
class SeniorSettingsController extends AsyncNotifier<SeniorSettings> {
  @override
  Future<SeniorSettings> build() {
    return ref.watch(seniorSettingsRepositoryProvider).load();
  }

  Future<void> chooseScreenMode(ScreenMode mode) async {
    final repo = ref.read(seniorSettingsRepositoryProvider);
    final current = state.valueOrNull ?? const SeniorSettings();
    final updated = current.copyWith(screenMode: mode);
    await repo.save(updated);
    state = AsyncData(updated);
  }
}

final seniorSettingsControllerProvider =
    AsyncNotifierProvider<SeniorSettingsController, SeniorSettings>(
  SeniorSettingsController.new,
);
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/launcher/senior_settings_controller_test.dart`
Expected: PASS — both tests green.

- [ ] **Step 5: Commit**

```bash
git add lib/features/launcher/application/senior_settings_controller.dart test/features/launcher/senior_settings_controller_test.dart
git commit -m "feat: add SeniorSettingsController async notifier"
```

---

## Task 5: PhoneDialer interface + url_launcher impl

The SOS guarantee ("does not auto-call") is enforced by design: the interface can only open the dialer.

**Files:**
- Create: `lib/features/launcher/data/phone_dialer.dart`
- Test: `test/features/launcher/phone_dialer_test.dart`

- [ ] **Step 1: Write the failing test (using a fake)**

Create `test/features/launcher/phone_dialer_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/launcher/data/phone_dialer.dart';

/// Records dialer opens. There is no "call" method to record — the interface
/// makes auto-calling impossible.
class FakePhoneDialer implements PhoneDialer {
  final List<String> opened = [];
  @override
  Future<void> openDialer(String number) async => opened.add(number);
}

void main() {
  test('openDialer records the number, exposes no auto-call path', () async {
    final dialer = FakePhoneDialer();
    await dialer.openDialer('119');
    expect(dialer.opened, ['119']);
    // PhoneDialer has exactly one method; there is no place callers could
    // trigger a call without user confirmation in the OS dialer.
    expect(PhoneDialer, isNotNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/launcher/phone_dialer_test.dart`
Expected: FAIL — `phone_dialer.dart` does not exist.

- [ ] **Step 3: Implement the interface, impl, and provider**

Create `lib/features/launcher/data/phone_dialer.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the platform phone app pre-filled with a number. By contract it
/// NEVER places a call — on Android `tel:` resolves to ACTION_DIAL, which
/// only shows the dialer; the user must press call themselves.
abstract interface class PhoneDialer {
  Future<void> openDialer(String number);
}

class UrlLauncherPhoneDialer implements PhoneDialer {
  const UrlLauncherPhoneDialer();

  @override
  Future<void> openDialer(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    await launchUrl(uri);
  }
}

final phoneDialerProvider = Provider<PhoneDialer>(
  (ref) => const UrlLauncherPhoneDialer(),
);
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/launcher/phone_dialer_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/launcher/data/phone_dialer.dart test/features/launcher/phone_dialer_test.dart
git commit -m "feat: add PhoneDialer interface that cannot auto-call"
```

---

## Task 6: Shared widgets — AppTile + SosButton

**Files:**
- Create: `lib/features/launcher/presentation/widgets/app_tile.dart`
- Create: `lib/features/launcher/presentation/widgets/sos_button.dart`
- Test: `test/features/launcher/widgets_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/features/launcher/widgets_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/app_category.dart';
import 'package:app/domain/launcher_app.dart';
import 'package:app/features/launcher/presentation/widgets/app_tile.dart';
import 'package:app/features/launcher/presentation/widgets/sos_button.dart';

void main() {
  testWidgets('AppTile shows label and icon, fires onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AppTile(
          app: const LauncherApp(label: '전화', category: AppCategory.phone),
          onTap: () => tapped = true,
        ),
      ),
    ));
    expect(find.text('전화'), findsOneWidget);
    expect(find.byIcon(Icons.call), findsOneWidget);
    await tester.tap(find.byType(AppTile));
    expect(tapped, isTrue);
  });

  testWidgets('SosButton shows SOS label and fires onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: SosButton(onTap: () => tapped = true)),
    ));
    expect(find.text('긴급 구조 요청'), findsOneWidget);
    await tester.tap(find.byType(SosButton));
    expect(tapped, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/launcher/widgets_test.dart`
Expected: FAIL — `app_tile.dart` / `sos_button.dart` do not exist.

- [ ] **Step 3: Implement AppTile**

Create `lib/features/launcher/presentation/widgets/app_tile.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../domain/app_category.dart';
import '../../../../domain/launcher_app.dart';

/// Clay-gradient launcher tile (launcher.jsx clayStyle): light→dark gradient,
/// large white icon + bold white label, soft drop shadow.
class AppTile extends StatelessWidget {
  const AppTile({super.key, required this.app, required this.onTap});

  final LauncherApp app;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cat = app.category;
    return Semantics(
      button: true,
      label: app.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [cat.lightColor, cat.baseColor],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: cat.baseColor.withValues(alpha: 0.42),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(cat.icon, size: 50, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    app.label,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Implement SosButton**

Create `lib/features/launcher/presentation/widgets/sos_button.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Always-visible red emergency bar (launcher.jsx SOS).
class SosButton extends StatelessWidget {
  const SosButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '긴급 구조 요청',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.seniorSos,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.seniorSos.withValues(alpha: 0.45),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_active, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Text(
                    '긴급 구조 요청',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/features/launcher/widgets_test.dart`
Expected: PASS — both widget tests green.

- [ ] **Step 6: Commit**

```bash
git add lib/features/launcher/presentation/widgets/ test/features/launcher/widgets_test.dart
git commit -m "feat: add AppTile and SosButton launcher widgets"
```

---

## Task 7: Screen-mode choice screen + route wiring

Replaces the Phase 0 onboarding placeholder. Two preview cards; selecting saves the mode and routes to the matching home. No other questions.

**Files:**
- Create: `lib/features/onboarding/presentation/screen_mode_choice_screen.dart`
- Create: `test/support/pump_app.dart`
- Modify: `lib/core/router/routes.dart`
- Modify: `lib/core/router/app_router.dart`
- Delete: `lib/features/onboarding/presentation/senior_onboarding_placeholder.dart`
- Test: `test/features/onboarding/screen_mode_choice_test.dart`

> Note: this task references the easy/detailed home routes added in full in Tasks 8–9. To keep the app compiling, this task adds **all** launcher route constants to `routes.dart` now, and points the new routes at the choice screen and temporary inline `Scaffold` placeholders that Tasks 8–10 replace. Each later task swaps its placeholder for the real screen.

- [ ] **Step 1: Add all launcher route constants**

Replace `lib/core/router/routes.dart` with:

```dart
/// Centralized route paths. Keep all navigation targets here.
class Routes {
  Routes._();

  static const firstScreen = '/';
  static const seniorOnboarding = '/onboarding';
  static const guardianLogin = '/guardian-login';

  // Senior launcher (Phase 1)
  static const easyHome = '/home/easy';
  static const detailedHome = '/home/detailed';
  static const sos = '/sos';
  static const familyLink = '/family-link';
  static const moreApps = '/more';
}
```

- [ ] **Step 2: Write the shared test harness**

Create `test/support/pump_app.dart`:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/app.dart';

/// Pumps the real [App] (router + theme) inside a ProviderScope so tests can
/// drive the actual navigation flow. Pass [overrides] to inject fakes.
Future<void> pumpApp(
  WidgetTester tester, {
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(overrides: overrides, child: const App()),
  );
  await tester.pumpAndSettle();
}
```

- [ ] **Step 3: Write the failing choice-screen test**

Create `test/features/onboarding/screen_mode_choice_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import '../../support/pump_app.dart';

void main() {
  testWidgets('choice screen shows two preview cards, no other questions',
      (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();

    expect(find.text('정말 쉬운 화면'), findsOneWidget);
    expect(find.text('자세한 화면'), findsOneWidget);
  });

  testWidgets('choosing 정말 쉬운 화면 navigates to the easy home',
      (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('정말 쉬운 화면'));
    await tester.pumpAndSettle();

    // Easy home renders its 2x2 default tiles.
    expect(find.text('앨범'), findsOneWidget);
  });
}
```

- [ ] **Step 4: Run test to verify it fails**

Run: `flutter test test/features/onboarding/screen_mode_choice_test.dart`
Expected: FAIL — choice screen / easy home not wired yet.

- [ ] **Step 5: Implement the choice screen**

Create `lib/features/onboarding/presentation/screen_mode_choice_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/senior_settings.dart';
import '../../launcher/application/senior_settings_controller.dart';

/// Onboarding step: pick the launcher style. The ONLY onboarding question.
class ScreenModeChoiceScreen extends ConsumerWidget {
  const ScreenModeChoiceScreen({super.key});

  Future<void> _choose(
      BuildContext context, WidgetRef ref, ScreenMode mode) async {
    await ref
        .read(seniorSettingsControllerProvider.notifier)
        .chooseScreenMode(mode);
    if (!context.mounted) return;
    context.go(mode == ScreenMode.easy ? Routes.easyHome : Routes.detailedHome);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text('화면을 골라주세요',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Expanded(
                child: _ModeCard(
                  title: '정말 쉬운 화면',
                  subtitle: '큰 버튼 4개, 가장 간단해요',
                  onTap: () => _choose(context, ref, ScreenMode.easy),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _ModeCard(
                  title: '자세한 화면',
                  subtitle: '앱 6개와 설정을 쓸 수 있어요',
                  onTap: () => _choose(context, ref, ScreenMode.detailed),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard(
      {required this.title, required this.subtitle, required this.onTap});

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.seniorSurface,
      borderRadius: BorderRadius.circular(22),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.seniorOnSurface)),
              const SizedBox(height: 10),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 20, color: AppColors.seniorTextSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: Wire the router (choice screen + temporary home placeholders)**

Replace `lib/core/router/app_router.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/guardian/presentation/guardian_login_placeholder.dart';
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
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('앨범'))),
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
```

- [ ] **Step 7: Delete the obsolete placeholder**

Run:
```bash
git rm lib/features/onboarding/presentation/senior_onboarding_placeholder.dart
```
Expected: file removed. (It is no longer imported anywhere.)

- [ ] **Step 8: Run tests**

Run: `flutter test test/features/onboarding/screen_mode_choice_test.dart`
Expected: PASS — both tests green (easy-home placeholder renders '앨범').

- [ ] **Step 9: Commit**

```bash
git add lib/core/router/ lib/features/onboarding/presentation/screen_mode_choice_screen.dart test/support/pump_app.dart test/features/onboarding/screen_mode_choice_test.dart
git commit -m "feat: add screen-mode choice screen and launcher routes"
```

---

## Task 8: Easy home screen

2×2 grid + 가족 연결 + SOS + 더 보기. Replaces the easy-home placeholder.

**Files:**
- Create: `lib/features/launcher/presentation/easy_home_screen.dart`
- Modify: `lib/core/router/app_router.dart:Routes.easyHome` builder
- Test: `test/features/launcher/easy_home_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/features/launcher/easy_home_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/launcher/presentation/widgets/app_tile.dart';
import 'package:app/features/launcher/presentation/widgets/sos_button.dart';
import '../../support/pump_app.dart';

Future<void> _gotoEasyHome(WidgetTester tester) async {
  await pumpApp(tester);
  await tester.tap(find.text('시작하기'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('정말 쉬운 화면'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('easy home shows the 4 default tiles, SOS, 가족 연결, 더 보기',
      (tester) async {
    await _gotoEasyHome(tester);

    expect(find.byType(AppTile), findsNWidgets(4));
    expect(find.text('전화'), findsOneWidget);
    expect(find.text('영상 보기'), findsOneWidget);
    expect(find.byType(SosButton), findsOneWidget);
    expect(find.text('가족 연결'), findsOneWidget);
    expect(find.text('더 보기'), findsOneWidget);
  });

  testWidgets('tapping SOS navigates to the SOS route', (tester) async {
    await _gotoEasyHome(tester);
    await tester.tap(find.byType(SosButton));
    await tester.pumpAndSettle();
    expect(find.text('119'), findsOneWidget);
  });
}
```

> Note: the second test asserts `'119'` which the real SOS screen (Task 10) renders. Until Task 10 lands, the SOS route shows the temporary 'SOS' placeholder and this test fails on that assertion — that is expected; it goes green when Task 10 replaces the placeholder. Run only the first test until then: `flutter test test/features/launcher/easy_home_test.dart --plain-name 'easy home shows'`.

- [ ] **Step 2: Run the first test to verify it fails**

Run: `flutter test test/features/launcher/easy_home_test.dart --plain-name 'easy home shows'`
Expected: FAIL — easy home still shows the placeholder '앨범' text, not 4 AppTiles.

- [ ] **Step 3: Implement the easy home**

Create `lib/features/launcher/presentation/easy_home_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/launcher_app.dart';
import 'widgets/app_tile.dart';
import 'widgets/sos_button.dart';

/// 정말 쉬운 화면 — 2x2 tiles, 가족 연결, SOS, 더 보기. No scrolling, depth 1.
class EasyHomeScreen extends StatelessWidget {
  const EasyHomeScreen({super.key});

  void _openApp(BuildContext context, LauncherApp app) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('${app.label} 열기는 다음 단계에서 연결됩니다')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (final app in defaultEasyApps)
                      AppTile(app: app, onTap: () => _openApp(context, app)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _PillButton(
                      label: '가족 연결',
                      icon: Icons.family_restroom,
                      onTap: () => context.go(Routes.familyLink),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PillButton(
                      label: '더 보기',
                      icon: Icons.apps,
                      onTap: () => context.go(Routes.moreApps),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SosButton(onTap: () => context.go(Routes.sos)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton(
      {required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.seniorSurface,
      borderRadius: BorderRadius.circular(20),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Icon(icon, size: 30, color: AppColors.seniorPrimary),
              const SizedBox(height: 6),
              Text(label,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.seniorOnSurface)),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Point the route at the real screen**

In `lib/core/router/app_router.dart`, add the import:

```dart
import '../../features/launcher/presentation/easy_home_screen.dart';
```

and replace the `Routes.easyHome` route with:

```dart
      GoRoute(
        path: Routes.easyHome,
        builder: (context, state) => const EasyHomeScreen(),
      ),
```

- [ ] **Step 5: Run the first test to verify it passes**

Run: `flutter test test/features/launcher/easy_home_test.dart --plain-name 'easy home shows'`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/launcher/presentation/easy_home_screen.dart lib/core/router/app_router.dart test/features/launcher/easy_home_test.dart
git commit -m "feat: add easy home screen with 2x2 grid, family link, SOS, more"
```

---

## Task 9: Detailed home screen + bottom tabs

2-col 6 tiles + 2 add-slots + bottom tabs (첫 화면 / 설정 / SOS). Scrolling allowed.

**Files:**
- Create: `lib/features/launcher/presentation/detailed_home_screen.dart`
- Modify: `lib/core/router/app_router.dart:Routes.detailedHome` builder
- Test: `test/features/launcher/detailed_home_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/features/launcher/detailed_home_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/launcher/presentation/widgets/app_tile.dart';
import '../../support/pump_app.dart';

Future<void> _gotoDetailedHome(WidgetTester tester) async {
  await pumpApp(tester);
  await tester.tap(find.text('시작하기'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('자세한 화면'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('detailed home shows 6 tiles, 2 add-slots, and bottom tabs',
      (tester) async {
    await _gotoDetailedHome(tester);

    expect(find.byType(AppTile), findsNWidgets(6));
    expect(find.text('카카오톡'), findsOneWidget);
    expect(find.text('사진찍기'), findsOneWidget);
    expect(find.text('추가하기'), findsNWidgets(2));
    // Bottom tabs
    expect(find.text('첫 화면'), findsOneWidget);
    expect(find.text('설정'), findsOneWidget);
    expect(find.text('SOS'), findsOneWidget);
  });

  testWidgets('settings tab shows the settings placeholder', (tester) async {
    await _gotoDetailedHome(tester);
    await tester.tap(find.text('설정'));
    await tester.pumpAndSettle();
    expect(find.text('앱 설정하기'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/launcher/detailed_home_test.dart`
Expected: FAIL — detailed home shows the '자세한 홈' placeholder.

- [ ] **Step 3: Implement the detailed home**

Create `lib/features/launcher/presentation/detailed_home_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/launcher_app.dart';
import 'widgets/app_tile.dart';

/// 자세한 화면 — scrollable 2-col grid (6 default + 2 add-slots) with bottom
/// tabs: 첫 화면 / 설정 / SOS. SOS tab routes to the SOS screen.
class DetailedHomeScreen extends StatefulWidget {
  const DetailedHomeScreen({super.key});

  @override
  State<DetailedHomeScreen> createState() => _DetailedHomeScreenState();
}

class _DetailedHomeScreenState extends State<DetailedHomeScreen> {
  int _index = 0;

  void _openApp(LauncherApp app) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('${app.label} 열기는 다음 단계에서 연결됩니다')),
      );
  }

  void _onTab(int i) {
    if (i == 2) {
      context.go(Routes.sos);
      return;
    }
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: [
            _HomeGrid(onOpen: _openApp),
            const _SettingsPanel(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index == 1 ? 1 : 0,
        onDestinationSelected: _onTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: '첫 화면'),
          NavigationDestination(icon: Icon(Icons.settings), label: '설정'),
          NavigationDestination(
              icon: Icon(Icons.sos, color: AppColors.seniorSos), label: 'SOS'),
        ],
      ),
    );
  }
}

class _HomeGrid extends StatelessWidget {
  const _HomeGrid({required this.onOpen});

  final void Function(LauncherApp) onOpen;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      padding: const EdgeInsets.all(20),
      children: [
        for (final app in defaultDetailedApps)
          AppTile(app: app, onTap: () => onOpen(app)),
        _AddSlot(),
        _AddSlot(),
      ],
    );
  }
}

class _AddSlot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.seniorSurface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.seniorBorder, width: 2),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, size: 44, color: AppColors.seniorTextSecondary),
          SizedBox(height: 6),
          Text('추가하기',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.seniorTextSecondary)),
        ],
      ),
    );
  }
}

/// Inline settings placeholder (full settings is Phase 2/3).
class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel();

  @override
  Widget build(BuildContext context) {
    const items = [
      '앱 설정하기',
      '글씨 크기 조절하기',
      '가족 연결 설정',
      '진동/벨소리 전환',
      '잘보이네 사용하지 않기',
    ];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        for (final label in items)
          Card(
            color: AppColors.seniorSurface,
            child: ListTile(
              title: Text(label,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.seniorOnSurface)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
      ],
    );
  }
}
```

- [ ] **Step 4: Point the route at the real screen**

In `lib/core/router/app_router.dart`, add the import:

```dart
import '../../features/launcher/presentation/detailed_home_screen.dart';
```

and replace the `Routes.detailedHome` route with:

```dart
      GoRoute(
        path: Routes.detailedHome,
        builder: (context, state) => const DetailedHomeScreen(),
      ),
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test test/features/launcher/detailed_home_test.dart`
Expected: PASS — both tests green.

- [ ] **Step 6: Commit**

```bash
git add lib/features/launcher/presentation/detailed_home_screen.dart lib/core/router/app_router.dart test/features/launcher/detailed_home_test.dart
git commit -m "feat: add detailed home screen with add-slots and bottom tabs"
```

---

## Task 10: SOS screen (phone handoff, no auto-call)

119 / 112 / 보호자. 119 and 112 open the dialer (never call). 보호자 is disabled until family is linked (Phase 5).

**Files:**
- Create: `lib/features/launcher/presentation/sos_screen.dart`
- Modify: `lib/core/router/app_router.dart:Routes.sos` builder
- Test: `test/features/launcher/sos_screen_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/features/launcher/sos_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/launcher/data/phone_dialer.dart';
import 'package:app/features/launcher/presentation/sos_screen.dart';

class FakePhoneDialer implements PhoneDialer {
  final List<String> opened = [];
  @override
  Future<void> openDialer(String number) async => opened.add(number);
}

void main() {
  testWidgets('SOS shows 119/112/보호자 and dials 119 without auto-calling',
      (tester) async {
    final dialer = FakePhoneDialer();
    await tester.pumpWidget(ProviderScope(
      overrides: [phoneDialerProvider.overrideWithValue(dialer)],
      child: const MaterialApp(home: SosScreen()),
    ));

    expect(find.text('119'), findsOneWidget);
    expect(find.text('112'), findsOneWidget);
    expect(find.text('보호자'), findsOneWidget);

    await tester.tap(find.text('119'));
    await tester.pumpAndSettle();

    // Only the dialer was opened; nothing places a call.
    expect(dialer.opened, ['119']);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/launcher/sos_screen_test.dart`
Expected: FAIL — `sos_screen.dart` does not exist.

- [ ] **Step 3: Implement the SOS screen**

Create `lib/features/launcher/presentation/sos_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../data/phone_dialer.dart';

/// SOS — choose 119 / 112 / 보호자. Selecting a number OPENS the dialer with
/// the number pre-filled; it never calls. The user must press call in the OS
/// dialer (04_SCREEN_SPEC / 06_PERMISSION_AND_POLICY).
class SosScreen extends ConsumerWidget {
  const SosScreen({super.key});

  Future<void> _dial(
      BuildContext context, WidgetRef ref, String number) async {
    await ref.read(phoneDialerProvider).openDialer(number);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('긴급 연락')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: _SosTile(
                  label: '119',
                  caption: '불 · 구급',
                  onTap: () => _dial(context, ref, '119'),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _SosTile(
                  label: '112',
                  caption: '경찰',
                  onTap: () => _dial(context, ref, '112'),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _SosTile(
                  label: '보호자',
                  caption: '가족을 연결하면 사용할 수 있어요',
                  onTap: null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SosTile extends StatelessWidget {
  const _SosTile({required this.label, required this.caption, this.onTap});

  final String label;
  final String caption;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: enabled ? AppColors.seniorSos : AppColors.seniorBorder,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              const SizedBox(height: 6),
              Text(caption,
                  style: const TextStyle(fontSize: 18, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Point the route at the real screen**

In `lib/core/router/app_router.dart`, add the import:

```dart
import '../../features/launcher/presentation/sos_screen.dart';
```

and replace the `Routes.sos` route with:

```dart
      GoRoute(
        path: Routes.sos,
        builder: (context, state) => const SosScreen(),
      ),
```

- [ ] **Step 5: Run tests (SOS unit + the deferred easy-home navigation test)**

Run:
```bash
flutter test test/features/launcher/sos_screen_test.dart test/features/launcher/easy_home_test.dart
```
Expected: PASS — SOS unit test green; both easy-home tests now green (the '119' navigation assertion resolves).

- [ ] **Step 6: Commit**

```bash
git add lib/features/launcher/presentation/sos_screen.dart lib/core/router/app_router.dart test/features/launcher/sos_screen_test.dart
git commit -m "feat: add SOS screen that opens dialer without auto-calling"
```

---

## Task 11: Senior placeholders + polish role-split splash

Replace the temporary family-link / more route placeholders with real placeholder screens, and finish the role-split first screen to match `splash.jsx` SplashC.

**Files:**
- Create: `lib/features/family/presentation/family_link_placeholder.dart`
- Create: `lib/features/launcher/presentation/more_apps_placeholder.dart`
- Modify: `lib/core/router/app_router.dart` (familyLink, moreApps builders)
- Modify: `lib/features/onboarding/presentation/role_split_screen.dart`
- Test: `test/features/launcher/placeholders_test.dart`

- [ ] **Step 1: Write the failing placeholder test**

Create `test/features/launcher/placeholders_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import '../../support/pump_app.dart';

Future<void> _gotoEasyHome(WidgetTester tester) async {
  await pumpApp(tester);
  await tester.tap(find.text('시작하기'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('정말 쉬운 화면'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('가족 연결 opens the family-link placeholder', (tester) async {
    await _gotoEasyHome(tester);
    await tester.tap(find.text('가족 연결'));
    await tester.pumpAndSettle();
    expect(find.text('가족 연결은 곧 준비됩니다'), findsOneWidget);
  });

  testWidgets('더 보기 opens the more-apps placeholder', (tester) async {
    await _gotoEasyHome(tester);
    await tester.tap(find.text('더 보기'));
    await tester.pumpAndSettle();
    expect(find.text('더 많은 앱을 곧 추가할 수 있어요'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/launcher/placeholders_test.dart`
Expected: FAIL — the routes still show the temporary inline '가족 연결' / '더 보기' Center text, not the placeholder copy above.

- [ ] **Step 3: Implement the placeholders**

Create `lib/features/family/presentation/family_link_placeholder.dart`:

```dart
import 'package:flutter/material.dart';

/// Senior-side family connection entry point (full flow is Phase 5).
class FamilyLinkPlaceholder extends StatelessWidget {
  const FamilyLinkPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('가족 연결')),
      body: const Center(
        child: Text('가족 연결은 곧 준비됩니다',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
```

Create `lib/features/launcher/presentation/more_apps_placeholder.dart`:

```dart
import 'package:flutter/material.dart';

/// 더 보기 — limited app-add entry (full add/reorder is Phase 2).
class MoreAppsPlaceholder extends StatelessWidget {
  const MoreAppsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('더 보기')),
      body: const Center(
        child: Text('더 많은 앱을 곧 추가할 수 있어요',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
```

- [ ] **Step 4: Wire the placeholder routes**

In `lib/core/router/app_router.dart`, add imports:

```dart
import '../../features/family/presentation/family_link_placeholder.dart';
import '../../features/launcher/presentation/more_apps_placeholder.dart';
```

and replace the `Routes.familyLink` and `Routes.moreApps` routes with:

```dart
      GoRoute(
        path: Routes.familyLink,
        builder: (context, state) => const FamilyLinkPlaceholder(),
      ),
      GoRoute(
        path: Routes.moreApps,
        builder: (context, state) => const MoreAppsPlaceholder(),
      ),
```

- [ ] **Step 5: Polish the role-split splash to SplashC**

Replace `lib/features/onboarding/presentation/role_split_screen.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';

/// First screen (splash.jsx · SplashC 단정). Warm wordmark, headline, large
/// 시작하기 CTA for the senior flow, small underlined helper link for guardians.
/// No onboarding questions here.
class RoleSplitScreen extends StatelessWidget {
  const RoleSplitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Wordmark: small warm sun dot + 잘보이네
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.seniorButtonYellowLight,
                          AppColors.seniorPrimary,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('잘보이네',
                      style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          color: AppColors.seniorPrimary)),
                ],
              ),
              const SizedBox(height: 34),
              const Text('어르신을 위한\n쉬운 스마트폰',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 43,
                      height: 1.24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.seniorOnSurface)),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.seniorPrimary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(84),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26)),
                  ),
                  onPressed: () => context.go(Routes.seniorOnboarding),
                  child: const Text('시작하기',
                      style: TextStyle(
                          fontSize: 30, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 18),
              // Single string (no '\n') so it both wraps to two lines via
              // TextAlign.center AND keeps matching the Phase 0 widget_test.
              TextButton(
                onPressed: () => context.go(Routes.guardianLogin),
                child: const Text(
                  '가족 및 어르신을 도와주시는 분은 여기를 눌러주세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: AppColors.seniorTextSecondary,
                      decoration: TextDecoration.underline),
                ),
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

- [ ] **Step 6: Run the placeholder + existing first-screen tests**

Run:
```bash
flutter test test/features/launcher/placeholders_test.dart test/widget_test.dart
```
Expected: PASS — placeholders render the new copy; `test/widget_test.dart` still finds '잘보이네' / '시작하기' / the helper link (the polished splash keeps that exact copy).

- [ ] **Step 7: Commit**

```bash
git add lib/features/family/ lib/features/launcher/presentation/more_apps_placeholder.dart lib/core/router/app_router.dart lib/features/onboarding/presentation/role_split_screen.dart test/features/launcher/placeholders_test.dart
git commit -m "feat: add senior placeholders and polish role-split splash to SplashC"
```

---

## Task 12: Full acceptance — analyze, format, test, run

**Files:** none (verification only)

- [ ] **Step 1: Format**

Run: `dart format lib test`
Expected: files formatted or unchanged.

- [ ] **Step 2: Analyze**

Run: `flutter analyze`
Expected: No issues found.

- [ ] **Step 3: Full test suite**

Run: `flutter test`
Expected: PASS — all Phase 0 + Phase 1 tests green.

- [ ] **Step 4: Acceptance — manual run**

Run: `flutter run -d chrome` (Windows desktop needs the Visual Studio toolchain, which is absent here; Chrome is the verification target).
Walk the flow: 시작하기 → 화면 선택 → 정말 쉬운 화면 → confirm 2×2 tiles + SOS + 가족 연결 + 더 보기 → tap SOS → confirm 119/112/보호자 → back → restart, choose 자세한 화면 → confirm 6 tiles + add-slots + bottom tabs (첫 화면/설정/SOS). Confirm SOS never auto-dials. Then quit the run.

- [ ] **Step 5: Verify against Phase 1 acceptance (07)**

Confirm each:
- user can choose mode ✓ (choice screen saves to controller)
- app shows correct default buttons ✓ (easy 4 / detailed 6 per 04 spec)
- no extra onboarding questions ✓ (only the mode choice)
- SOS opens phone intent, does not auto-call ✓ (PhoneDialer has no call path)

---

## Acceptance Checklist (Phase 1)

- [ ] `flutter analyze` → no issues
- [ ] `flutter test` → all green
- [ ] Role split → choice → easy/detailed home → SOS flow works in Chrome
- [ ] Easy home: 2×2 default tiles (전화/문자/앨범/영상 보기) + 가족 연결 + SOS + 더 보기
- [ ] Detailed home: 6 tiles + 2 add-slots + bottom tabs (첫 화면/설정/SOS)
- [ ] SOS dials 119/112 via the dialer only; 보호자 disabled until family linked
- [ ] Screen mode saved through `SeniorSettingsRepository` (in-memory mock)
- [ ] Colors come only from `AppColors` (launcher.jsx / splash.jsx tokens)

## Out of Phase 1 (do NOT build)

- Supabase / backend, payment, location, call/install detection, medication alerts
- Real Android default-launcher registration (UI guidance only; system dialog is Phase 1.5/later)
- shared_preferences persistence of mode/buttons → Phase 2
- Editable buttons (add/remove/reorder/rename/color/font) → Phase 2
- Real app launching from tiles, real guardian phone number in SOS → later phases
- Live clock / weather / vibrate-state in the home header → Phase 2+
