import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/supabase/supabase_providers.dart';
import 'package:app/data/remote/home_apps_repository.dart';
import 'package:app/data/remote/senior_link_repository.dart';
import 'package:app/data/senior_link_store.dart';
import 'package:app/features/family/presentation/family_link_screen.dart';
import 'package:app/features/onboarding/presentation/splash_screen.dart';

import '../../support/pump_app.dart';

/// Walks the senior's route: splash → 정말 쉬운 화면 → 가족 연결.
Future<InMemorySeniorLinkRepository> _gotoFamilyLink(
  WidgetTester tester, {
  InMemorySeniorLinkRepository? links,
  InMemoryHomeAppsRepository? homeApps,
}) async {
  final repo = links ?? InMemorySeniorLinkRepository();
  await pumpApp(
    tester,
    overrides: [
      seniorLinkRepositoryProvider.overrideWithValue(repo),
      homeAppsRepositoryProvider.overrideWithValue(
        homeApps ?? InMemoryHomeAppsRepository(),
      ),
      seniorLinkStoreProvider.overrideWithValue(InMemorySeniorLinkStore()),
    ],
  );
  await tester.tap(find.byKey(SplashScreen.tapTargetKey));
  await settleAfterSplashTap(tester);
  await tester.tap(find.text('정말 쉬운 화면'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('가족 연결'));
  await tester.pumpAndSettle();
  return repo;
}

/// Creates a profile the way a guardian would.
Future<String> _codeFrom(InMemorySeniorLinkRepository links) async {
  await links.ensureGuardianAccount();
  return (await links.createSeniorProfile(displayName: '어머니')).customerCode;
}

Future<void> _enterCode(WidgetTester tester, String code) async {
  await tester.enterText(find.byKey(FamilyLinkKeys.code), code);
  await tester.tap(find.byKey(FamilyLinkKeys.submit));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the connect screen asks for the number, not an account', (
    tester,
  ) async {
    // The senior is never asked to create an account; their phone joins the
    // profile their child already made.
    await _gotoFamilyLink(tester);

    expect(find.byKey(FamilyLinkKeys.code), findsOneWidget);
    expect(find.text('연결하기'), findsOneWidget);
  });

  testWidgets('a wrong number says so and stays on the form', (tester) async {
    await _gotoFamilyLink(tester);

    await _enterCode(tester, 'WRONG123');

    expect(
      tester.widget<Text>(find.byKey(FamilyLinkKeys.message)).data,
      '연결 번호가 맞지 않아요. 다시 확인해 주세요.',
    );
    expect(find.byKey(FamilyLinkKeys.submit), findsOneWidget);
  });

  testWidgets('the right number connects the phone', (tester) async {
    final links = InMemorySeniorLinkRepository();
    final code = await _codeFrom(links);
    await _gotoFamilyLink(tester, links: links);

    await _enterCode(tester, code);

    expect(find.byKey(FamilyLinkKeys.connected), findsOneWidget);
    expect(find.text('가족과 연결되었어요'), findsOneWidget);
  });

  testWidgets('the code field refuses characters the code cannot contain', (
    tester,
  ) async {
    await _gotoFamilyLink(tester);

    await tester.enterText(find.byKey(FamilyLinkKeys.code), 'AB-12 !@#cd');
    await tester.pump();

    expect(
      tester.widget<TextField>(find.byKey(FamilyLinkKeys.code)).controller!.text,
      'AB12cd',
    );
  });
}
