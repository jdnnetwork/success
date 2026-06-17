import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/app.dart';

/// Pumps the real [App] (router + theme) inside a ProviderScope so tests can
/// drive the actual navigation flow. Pass [overrides] to inject fakes.
///
/// Note: In Riverpod 3.x [Override] is not publicly exported; callers pass
/// values produced by `provider.overrideWith(...)` / `provider.overrideWithValue(...)`,
/// which implement the internal Override interface accepted by [ProviderScope].
Future<void> pumpApp(
  WidgetTester tester, {
  List<Object> overrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      // ignore: invalid_use_of_internal_member
      overrides: overrides.cast(),
      child: const App(),
    ),
  );
  await tester.pumpAndSettle();
}
