import 'package:flutter_test/flutter_test.dart';

import 'package:app/features/guardian/presentation/guardian_dashboard_screen.dart';
import 'package:app/features/guardian/presentation/guardian_launcher_tab.dart';
import 'package:app/features/onboarding/presentation/splash_screen.dart';

import '../../support/pump_app.dart';

/// Reaches the dashboard the way a guardian does on a build with no Supabase
/// project: splash → guardian start → a provider button, which is what keeps
/// Phase 3's "navigable without a backend" true.
///
/// With no project the repositories resolve to their in-memory twins, so no
/// parent is linked — that empty state is what these cases see. The cases that
/// need a linked parent live in guardian_launcher_tab_test.dart.
Future<void> _gotoDashboard(WidgetTester tester) async {
  await pumpApp(tester);
  await tester.tap(find.byKey(SplashScreen.guardianCardKey));
  await tester.pumpAndSettle();
  await tester.tap(find.text('카카오로 시작하기'));
  await tester.pumpAndSettle();
}

Future<void> _openTab(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('signing in lands on the dashboard, not a placeholder', (
    tester,
  ) async {
    await _gotoDashboard(tester);

    expect(find.byType(GuardianDashboardScreen), findsOneWidget);
  });

  testWidgets('a guardian with no parent yet is told how to get one', (
    tester,
  ) async {
    await _gotoDashboard(tester);

    expect(find.byKey(GuardianHomeKeys.noParent), findsOneWidget);
    expect(find.text('아직 연결된 부모님이 없어요'), findsOneWidget);
  });

  testWidgets('no phone reading is shown that the server does not have', (
    tester,
  ) async {
    await _gotoDashboard(tester);

    // Battery, ringer and network were mocked through Phase 3 and arrive with
    // the Phase 6 background sync. On a dashboard whose whole job is to
    // reassure, a plausible-looking 배터리 72% is worse than saying nothing.
    expect(find.textContaining('배터리 72'), findsNothing);
    expect(find.textContaining('벨소리 · 70'), findsNothing);
    expect(find.text('연결됨'), findsNothing);
  });

  testWidgets('all four tabs are reachable without a backend', (tester) async {
    await _gotoDashboard(tester);

    await _openTab(tester, '홈 화면');
    expect(find.byKey(GuardianLauncherKeys.empty), findsOneWidget);

    await _openTab(tester, '돌봄');
    expect(find.text('안심 케어'), findsWidgets);

    await _openTab(tester, '가족');
    expect(find.text('가족 연결 코드'), findsOneWidget);

    await _openTab(tester, '홈');
    expect(find.byKey(GuardianHomeKeys.noParent), findsOneWidget);
  });

  testWidgets('the care tab drops what the PRD puts outside the MVP', (
    tester,
  ) async {
    await _gotoDashboard(tester);
    await _openTab(tester, '돌봄');

    // 약 알림 / 복약 기록 are listed under Out Of MVP, and call-content
    // analysis is explicitly excluded, so neither may be advertised here.
    expect(find.textContaining('약 알림'), findsNothing);
    expect(find.textContaining('복용'), findsNothing);
    expect(find.textContaining('보이스피싱'), findsNothing);
  });

  testWidgets('the care tab does not promise real-time tracking', (
    tester,
  ) async {
    await _gotoDashboard(tester);
    await _openTab(tester, '돌봄');

    // 06_PERMISSION_AND_POLICY: 실시간 추적이라고 표현하지 않는다.
    expect(find.textContaining('실시간'), findsNothing);
    expect(find.textContaining('위치'), findsWidgets);
  });

  testWidgets('inviting other guardians is shown as free', (tester) async {
    await _gotoDashboard(tester);
    await _openTab(tester, '가족');

    // The PRD lists 가족 보호자 초대 among the free features; the design had
    // moved it behind 안심 케어.
    expect(find.text('가족 초대하기'), findsOneWidget);
    expect(find.textContaining('무료'), findsWidgets);
  });

  testWidgets('the pairing code is shown with what to do with it', (
    tester,
  ) async {
    await _gotoDashboard(tester);
    await _openTab(tester, '가족');

    expect(find.text('가족 연결 코드'), findsOneWidget);
    expect(find.textContaining('어머니 폰에서'), findsOneWidget);
  });

  testWidgets('the home tab does not offer editing a parent who is not there', (
    tester,
  ) async {
    // Through Phase 3 this tab drew the guardian's own local buttons and
    // claimed they reached the parent's phone. With nobody linked there is
    // nothing to edit, and saying so beats showing someone else's home screen.
    await _gotoDashboard(tester);
    await _openTab(tester, '홈 화면');

    expect(find.byKey(GuardianLauncherKeys.empty), findsOneWidget);
    expect(find.byKey(GuardianLauncherKeys.add), findsNothing);
  });
}
