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
