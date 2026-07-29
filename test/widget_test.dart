import 'package:flutter_test/flutter_test.dart';

import 'support/pump_app.dart';

void main() {
  testWidgets('the app opens on the splash', (tester) async {
    await pumpApp(tester);

    expect(find.text('잘보이네'), findsOneWidget);
    expect(find.text('크게 보고 쉽게 쓰는'), findsOneWidget);
  });

  testWidgets('the splash leads to senior onboarding', (tester) async {
    await enterSeniorFlow(tester);

    expect(find.text('화면을 골라주세요'), findsOneWidget);
  });
}
