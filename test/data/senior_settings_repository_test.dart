import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/senior_settings.dart';
import 'package:app/data/senior_settings_repository.dart';

void main() {
  group('MockSeniorSettingsRepository', () {
    test('load returns empty settings before any save', () async {
      final repo = MockSeniorSettingsRepository();
      final settings = await repo.load();
      expect(settings.screenMode, isNull);
    });

    test('save then load round-trips the screen mode', () async {
      final repo = MockSeniorSettingsRepository();
      await repo.save(const SeniorSettings(screenMode: ScreenMode.easy));
      final settings = await repo.load();
      expect(settings.screenMode, ScreenMode.easy);
    });
  });
}
