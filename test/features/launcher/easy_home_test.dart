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
  testWidgets('easy home shows the 4 default tiles, SOS, 가족 연결, 더 보기', (
    tester,
  ) async {
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
