import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/domain/senior_settings.dart';
import 'package:app/data/senior_settings_repository.dart';
import 'package:app/features/launcher/application/senior_settings_controller.dart';

void main() {
  test('initial state has no screen mode', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final settings = await container.read(
      seniorSettingsControllerProvider.future,
    );
    expect(settings.screenMode, isNull);
  });

  test(
    'chooseScreenMode persists to the repository and updates state',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(seniorSettingsControllerProvider.future);

      await container
          .read(seniorSettingsControllerProvider.notifier)
          .chooseScreenMode(ScreenMode.easy);

      expect(
        container.read(seniorSettingsControllerProvider).value!.screenMode,
        ScreenMode.easy,
      );
      final repo = container.read(seniorSettingsRepositoryProvider);
      expect((await repo.load()).screenMode, ScreenMode.easy);
    },
  );
}
