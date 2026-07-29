import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/data/senior_settings_repository.dart';
import 'package:app/domain/senior_settings.dart';
import 'package:app/features/launcher/presentation/widgets/app_tile.dart';

import '../../support/pump_app.dart';

Map<String, Object> _saved(String fontSize) => {
  SharedPreferencesSeniorSettingsRepository.storageKey: jsonEncode({
    'screenMode': 'easy',
    'fontSize': fontSize,
    'apps': [
      {'id': 'phone', 'label': '전화', 'category': 'phone', 'color': null},
    ],
  }),
};

/// The scale the launcher is actually drawing at, read from inside a tile.
///
/// Measured rather than trusted: shared_preferences caches its instance for
/// the life of the isolate, so a test may not pump the app twice with
/// different stored settings — each size needs its own test.
double _appliedScale(WidgetTester tester) => MediaQuery.textScalerOf(
  tester.element(find.byType(AppTile).first),
).scale(10);

void main() {
  testWidgets('the default text size draws at the base scale', (tester) async {
    await pumpApp(tester, prefs: _saved('normal'));
    await tester.pumpAndSettle();

    expect(_appliedScale(tester), closeTo(10 * FontSize.normal.scale, 0.01));
  });

  testWidgets('the largest step reaches the launcher, not just the store', (
    tester,
  ) async {
    await pumpApp(tester, prefs: _saved('extraLarge'));
    await tester.pumpAndSettle();

    // Saving the choice is not the feature; the senior has to see it.
    expect(
      _appliedScale(tester),
      closeTo(10 * FontSize.extraLarge.scale, 0.01),
    );
  });

  testWidgets('the middle step sits between the other two', (tester) async {
    await pumpApp(tester, prefs: _saved('large'));
    await tester.pumpAndSettle();

    final scale = _appliedScale(tester);
    expect(scale, greaterThan(10 * FontSize.normal.scale));
    expect(scale, lessThan(10 * FontSize.extraLarge.scale));
  });
}
