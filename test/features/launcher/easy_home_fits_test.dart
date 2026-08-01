import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/data/senior_settings_repository.dart';
import 'package:app/domain/launcher_app.dart';
import 'package:app/domain/senior_settings.dart';
import 'package:app/features/launcher/data/app_launcher.dart';
import 'package:app/features/launcher/presentation/widgets/app_tile.dart';

import '../../support/pump_app.dart';

/// 정말 쉬운 화면 does not scroll, so everything on it has to fit.
///
/// Raising the text size is the point of this app: a home screen that only
/// holds together at the default size fails at exactly the setting it exists
/// for. And a clipped tile is worse than an overflow stripe — the grid is a
/// scrollable, so it swallows the excess silently and nothing throws.
Future<void> _pumpEasyHome(WidgetTester tester, FontSize size) async {
  await pumpApp(
    tester,
    overrides: [
      // Shows the 첫 화면으로 정하기 card, which is the tightest the screen ever
      // gets — and it is shown at whatever size the senior already chose.
      appLauncherProvider.overrideWithValue(FakeAppLauncher(defaultHome: false)),
    ],
    prefs: {
      SharedPreferencesSeniorSettingsRepository.storageKey: jsonEncode(
        SeniorSettings(
          screenMode: ScreenMode.easy,
          fontSize: size,
          apps: defaultEasyApps,
        ).toJson(),
      ),
    },
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final size in FontSize.values) {
    testWidgets('every tile is fully visible at ${size.name}', (tester) async {
      await _pumpEasyHome(tester, size);

      final grid = tester.getRect(find.byType(GridView));
      for (final tile in find.byType(AppTile).evaluate()) {
        final rect = tester.getRect(find.byWidget(tile.widget));
        expect(
          rect.bottom,
          lessThanOrEqualTo(grid.bottom + 0.5),
          reason: '${(tile.widget as AppTile).app.label} is cut off at '
              '${size.name}',
        );
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the labels are still readable at 아주 크게', (tester) async {
    // Fitting by shrinking the tiles to nothing would pass the check above.
    await _pumpEasyHome(tester, FontSize.extraLarge);

    for (final label in ['전화', '문자', '앨범', '영상 보기']) {
      expect(find.text(label), findsOneWidget);
      expect(tester.getSize(find.text(label)).height, greaterThan(0));
    }
  });
}
