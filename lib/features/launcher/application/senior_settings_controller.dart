import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/senior_settings_repository.dart';
import '../../../domain/senior_settings.dart';

/// Holds the senior's settings, loading from and saving to the repository.
class SeniorSettingsController extends AsyncNotifier<SeniorSettings> {
  @override
  Future<SeniorSettings> build() {
    return ref.watch(seniorSettingsRepositoryProvider).load();
  }

  Future<void> chooseScreenMode(ScreenMode mode) async {
    final repo = ref.read(seniorSettingsRepositoryProvider);
    final current = state.value ?? const SeniorSettings();
    final updated = current.copyWith(screenMode: mode);
    await repo.save(updated);
    state = AsyncData(updated);
  }
}

final seniorSettingsControllerProvider =
    AsyncNotifierProvider<SeniorSettingsController, SeniorSettings>(
  SeniorSettingsController.new,
);
