import 'package:flutter_test/flutter_test.dart';

import 'package:app/domain/app_category.dart';
import 'package:app/features/launcher/data/app_launcher.dart';

void main() {
  test('전화 opens the dialer and never places the call', () {
    // `06_PERMISSION_AND_POLICY` requires the user press call themselves, and
    // that holds for the 전화 button exactly as it does for SOS.
    expect(
      launchRequestFor(AppCategory.phone),
      const LaunchRequest(intent: LaunchIntent.dial),
    );
  });

  test('system apps are asked for by category, not by package', () {
    // Naming a package would pick one phone's dialer or gallery and break
    // every other phone.
    for (final category in [
      AppCategory.phone,
      AppCategory.message,
      AppCategory.camera,
      AppCategory.gallery,
    ]) {
      expect(launchRequestFor(category).packageName, isNull, reason: '$category');
      expect(launchRequestFor(category).intent, isNotNull, reason: '$category');
    }
  });

  test('카카오톡 is named, because Android has no category for it', () {
    expect(launchRequestFor(AppCategory.kakao).packageName, 'com.kakao.talk');
  });

  test('카카오톡 has no web fallback', () {
    // The web version would drop a senior onto a login page, which is worse
    // than telling them it did not open.
    expect(launchRequestFor(AppCategory.kakao).fallbackUrl, isNull);
  });

  test('유튜브 falls back to the web, where the web version is usable', () {
    final request = launchRequestFor(AppCategory.youtube);
    expect(request.packageName, 'com.google.android.youtube');
    expect(request.fallbackUrl, 'https://m.youtube.com');
  });

  test('every category resolves to something openable', () {
    for (final category in AppCategory.values) {
      final request = launchRequestFor(category);
      expect(
        request.packageName ?? request.intent ?? request.fallbackUrl,
        isNotNull,
        reason: '$category has no way to open',
      );
    }
  });

  test('the arguments carry enum names the platform side matches on', () {
    expect(launchRequestFor(AppCategory.gallery).toArguments(), {
      'packageName': null,
      'intent': 'gallery',
      'fallbackUrl': null,
    });
  });
}
