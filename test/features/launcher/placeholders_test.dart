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
