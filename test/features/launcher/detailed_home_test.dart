import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/launcher/presentation/widgets/app_tile.dart';
import '../../support/pump_app.dart';

Future<void> _gotoDetailedHome(WidgetTester tester) async {
  await enterSeniorFlow(tester);
  await tester.tap(find.text('자세한 화면'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('detailed home shows 6 tiles, 2 add-slots, and bottom tabs', (
    tester,
  ) async {
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
