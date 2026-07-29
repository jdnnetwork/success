import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:app/data/senior_settings_repository.dart';
import 'package:app/features/launcher/presentation/widgets/app_tile.dart';

import '../../support/pump_app.dart';

Map<String, Object> _saved({
  required String mode,
  required List<Map<String, Object?>> apps,
  String fontSize = 'normal',
}) => {
  SharedPreferencesSeniorSettingsRepository.storageKey: jsonEncode({
    'screenMode': mode,
    'fontSize': fontSize,
    'apps': apps,
  }),
};

Map<String, Object?> _app(String id, String label, String category) => {
  'id': id,
  'label': label,
  'category': category,
  'color': null,
};

void main() {
  testWidgets('the easy home draws the buttons that were saved', (
    tester,
  ) async {
    await pumpApp(
      tester,
      prefs: _saved(
        mode: 'easy',
        apps: [
          _app('phone', '전화걸기', 'phone'),
          _app('message', '문자', 'message'),
          _app('gallery', '앨범', 'gallery'),
          _app('youtube', '영상 보기', 'youtube'),
        ],
      ),
    );
    await tester.pumpAndSettle();

    // The rename has to reach the home, otherwise editing is cosmetic.
    expect(find.text('전화걸기'), findsOneWidget);
    expect(find.text('전화'), findsNothing);
    expect(find.byType(AppTile), findsNWidgets(4));
  });

  testWidgets('a removed button leaves the easy home with fewer tiles', (
    tester,
  ) async {
    await pumpApp(
      tester,
      prefs: _saved(
        mode: 'easy',
        apps: [_app('phone', '전화', 'phone'), _app('gallery', '앨범', 'gallery')],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppTile), findsNWidgets(2));
    expect(find.text('문자'), findsNothing);
  });

  testWidgets('the detailed home draws the buttons that were saved', (
    tester,
  ) async {
    await pumpApp(
      tester,
      prefs: _saved(
        mode: 'detailed',
        apps: [
          _app('phone', '전화', 'phone'),
          _app('kakao', '카톡', 'kakao'),
          _app('camera', '사진찍기', 'camera'),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('카톡'), findsOneWidget);
    expect(find.byType(AppTile), findsNWidgets(3));
  });
}
