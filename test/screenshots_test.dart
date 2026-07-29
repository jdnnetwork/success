import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_test/flutter_test.dart';

import 'package:app/features/guardian/presentation/guardian_start_screen.dart';
import 'package:app/features/onboarding/presentation/splash_screen.dart';

import 'support/pump_app.dart';

/// Renders each screen to `build/screenshots/` while checking it still draws.
///
/// This app's value is how it looks on a phone, and the remote environment has
/// no display, so these PNGs are how layout gets reviewed.
///
/// Two things the default test environment does not give us:
///
/// * Its stub font has no Korean glyphs, so every label rasterises as tofu.
///   `test/fonts/NotoSansKR.ttf` is registered under the family Flutter falls
///   back to, which is close to what an Android phone actually uses.
/// * `toImage` completes on a real engine callback that the fake clock never
///   delivers, so it has to run inside [WidgetTester.runAsync] — awaiting it
///   directly hangs the run instead of failing.
Future<void> _capture(WidgetTester tester, String name) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(appRootKey),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2.0);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final dir = Directory('build/screenshots')..createSync(recursive: true);
    File('${dir.path}/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

/// Asset images resolve asynchronously; without this the frame is captured
/// before the illustration has decoded and the screen looks empty.
Future<void> _loadImages(WidgetTester tester) async {
  final context = tester.element(find.byType(MaterialApp));
  await tester.runAsync(
    () => precacheImage(
      const AssetImage('assets/images/hand_phone.png'),
      context,
    ),
  );
  await tester.pump();
}

void main() {
  setUpAll(() async {
    Future<void> register(String family, String path) async {
      final bytes = File(path).readAsBytesSync();
      final loader = FontLoader(family)
        ..addFont(
          Future.value(ByteData.view(Uint8List.fromList(bytes).buffer)),
        );
      await loader.load();
    }

    for (final family in ['Roboto', 'Noto Sans KR']) {
      await register(family, 'test/fonts/NotoSansKR.ttf');
    }
    // Icons are tofu without this; the glyphs ship with the SDK rather than
    // the project, so the path is resolved from the running Flutter install.
    final icons = File(
      '${File(Platform.resolvedExecutable).parent.parent.parent.path}'
      '/artifacts/material_fonts/MaterialIcons-Regular.otf',
    );
    if (icons.existsSync()) {
      await register('MaterialIcons', icons.path);
    }
  });

  testWidgets('splash renders at rest', (tester) async {
    await pumpApp(tester);
    await _loadImages(tester);
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('눌러보세요'), findsOneWidget);
    await _capture(tester, '01-splash-idle');
  });

  testWidgets('splash renders while entering', (tester) async {
    await pumpApp(tester);
    await _loadImages(tester);
    await tester.tap(find.byKey(SplashScreen.tapTargetKey));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('준비하고 있어요\n잠시만 기다려 주세요'), findsOneWidget);
    await _capture(tester, '02-splash-entering');

    await settleAfterSplashTap(tester);
  });

  testWidgets('guardian start renders', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(SplashScreen.guardianCardKey));
    await tester.pumpAndSettle();

    expect(find.byKey(GuardianStartKeys.kakao), findsOneWidget);
    await _capture(tester, '03-guardian-start');
  });

  testWidgets('screen mode choice renders', (tester) async {
    await enterSeniorFlow(tester);

    expect(find.text('화면을 골라주세요'), findsOneWidget);
    await _capture(tester, '04-screen-mode-choice');
  });

  testWidgets('the guardian dashboard renders every tab', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(SplashScreen.guardianCardKey));
    await tester.pumpAndSettle();
    await tester.tap(find.text('카카오로 시작하기'));
    await tester.pumpAndSettle();

    expect(find.text('어머니 김순자'), findsOneWidget);
    await _capture(tester, '05-dashboard-home');

    for (final (tab, name) in [
      ('홈 화면', '06-dashboard-launcher'),
      ('돌봄', '07-dashboard-care'),
      ('가족', '08-dashboard-family'),
    ]) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
      await _capture(tester, name);
    }
  });
}
