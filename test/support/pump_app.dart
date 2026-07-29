import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/app.dart';
import 'package:app/features/onboarding/presentation/splash_screen.dart';

/// Marks the root so a test can rasterise whatever is on screen.
const appRootKey = Key('app-root');

/// Pumps the real [App] (router + theme) inside a ProviderScope so tests can
/// drive the actual navigation flow. Pass [overrides] to inject fakes.
///
/// Does not settle: the splash loops its tap-prompt animation forever, so
/// `pumpAndSettle` would spin until it times out. Screens reached after the
/// splash can be settled normally.
///
/// Note: In Riverpod 3.x [Override] is not publicly exported; callers pass
/// values produced by `provider.overrideWith(...)` / `provider.overrideWithValue(...)`,
/// which implement the internal Override interface accepted by [ProviderScope].
Future<void> pumpApp(
  WidgetTester tester, {
  List<Object> overrides = const [],
  Map<String, Object> prefs = const {},
}) async {
  // Settings now go through shared_preferences, whose platform channel does
  // not exist under `flutter test` — without a mock store every save throws
  // and navigation stalls on the screen-mode choice. Pass [prefs] to start the
  // app as though a previous run had already saved something.
  //
  // The reset matters: SharedPreferences caches its instance for the life of
  // the isolate, so without it the second test in a file silently reads the
  // first test's store and passes for the wrong reason.
  SharedPreferences.resetStatic();
  SharedPreferences.setMockInitialValues(prefs);

  // The screens are laid out for a phone; the 800x600 default would push the
  // illustration off the top.
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    RepaintBoundary(
      key: appRootKey,
      child: ProviderScope(
        // ignore: invalid_use_of_internal_member
        overrides: overrides.cast(),
        child: const App(),
      ),
    ),
  );
  await tester.pump();
}

/// Advances past the splash's entering pause and the route transition that
/// follows it, leaving the splash disposed so later `pumpAndSettle` calls are
/// safe.
Future<void> settleAfterSplashTap(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(SplashScreen.enteringPause);
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

/// Taps the phone in the illustration and lands on the screen-mode choice.
Future<void> enterSeniorFlow(WidgetTester tester) async {
  await pumpApp(tester);
  await tester.tap(find.byKey(SplashScreen.tapTargetKey));
  await settleAfterSplashTap(tester);
}
