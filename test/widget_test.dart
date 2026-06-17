import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/app.dart';

void main() {
  testWidgets('first screen renders app name and CTA', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    expect(find.text('잘보이네'), findsOneWidget);
    expect(find.text('시작하기'), findsOneWidget);
    expect(find.text('가족 및 어르신을 도와주시는 분은 여기를 눌러주세요'), findsOneWidget);
  });

  testWidgets('tapping 시작하기 navigates to senior onboarding', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();

    expect(find.text('화면을 골라주세요'), findsOneWidget);
  });
}
