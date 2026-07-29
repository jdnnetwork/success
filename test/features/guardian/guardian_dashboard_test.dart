import 'package:flutter_test/flutter_test.dart';

import 'package:app/features/guardian/presentation/guardian_dashboard_screen.dart';
import 'package:app/features/onboarding/presentation/splash_screen.dart';

import '../../support/pump_app.dart';

/// Reaches the dashboard the way a guardian does: splash → guardian start →
/// a provider button. Auth lands in Phase 4; until then the button is the door.
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

  testWidgets('the dashboard opens on the parent status card', (tester) async {
    await _gotoDashboard(tester);

    expect(find.text('어머니 김순자'), findsOneWidget);
    expect(find.text('연결됨'), findsOneWidget);
    expect(find.textContaining('배터리'), findsWidgets);
  });

  testWidgets('phone status says when it was last read', (tester) async {
    await _gotoDashboard(tester);

    // The free tier refreshes once per app open. Saying so up front is the
    // difference between a stale reading and a wrong one.
    expect(find.textContaining('앱을 열 때'), findsOneWidget);
  });

  testWidgets('all four tabs are reachable without a backend', (tester) async {
    await _gotoDashboard(tester);

    await _openTab(tester, '홈 화면');
    expect(find.text('홈 화면 구성'), findsOneWidget);

    await _openTab(tester, '돌봄');
    expect(find.text('안심 케어'), findsWidgets);

    await _openTab(tester, '가족');
    expect(find.text('가족 연결 코드'), findsOneWidget);

    await _openTab(tester, '홈');
    expect(find.text('어머니 김순자'), findsOneWidget);
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

  testWidgets('the home-management tab lists the senior buttons', (
    tester,
  ) async {
    await _gotoDashboard(tester);
    await _openTab(tester, '홈 화면');

    expect(find.text('전화'), findsWidgets);
    expect(find.textContaining('원격'), findsWidgets);
  });
}
