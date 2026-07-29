import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/senior_settings_repository.dart';
import '../../../domain/app_category.dart';
import '../../../domain/launcher_app.dart';
import '../../../domain/senior_settings.dart';

/// Holds the senior's settings, loading from and saving to the repository.
///
/// Every edit writes through before the new state is published, so what the
/// screen shows is what survived to disk. On this app that matters more than
/// the extra await: it is the phone's home screen.
class SeniorSettingsController extends AsyncNotifier<SeniorSettings> {
  @override
  Future<SeniorSettings> build() {
    return ref.watch(seniorSettingsRepositoryProvider).load();
  }

  /// Picks the mode and, on a home that has no buttons yet, seeds that mode's
  /// defaults so there is something to edit.
  ///
  /// An existing arrangement is left alone — re-entering onboarding must not
  /// wipe a home the senior has already arranged.
  Future<void> chooseScreenMode(ScreenMode mode) async {
    final current = state.value ?? const SeniorSettings();
    await _write(
      current.copyWith(
        screenMode: mode,
        apps: current.apps.isEmpty ? _defaultsFor(mode) : current.apps,
      ),
    );
  }

  Future<void> setFontSize(FontSize size) async {
    final current = state.value ?? const SeniorSettings();
    await _write(current.copyWith(fontSize: size));
  }

  Future<void> renameApp(String id, String label) =>
      _mapApps((app) => app.id == id ? app.copyWith(label: label) : app);

  /// Pass null to drop back to the button's category colour.
  Future<void> setAppColor(String id, ButtonColor? color) =>
      _mapApps((app) => app.id == id ? app.withColor(color) : app);

  Future<void> removeApp(String id) async {
    final current = state.value ?? const SeniorSettings();
    await _write(
      current.copyWith(
        apps: current.apps.where((a) => a.id != id).toList(growable: false),
      ),
    );
  }

  /// Indices follow `ReorderableListView`: [newIndex] is read against the list
  /// as it still stands, before the dragged button is lifted out, so a move
  /// downward has to shed one place once it is.
  Future<void> reorderApps(int oldIndex, int newIndex) async {
    final current = state.value ?? const SeniorSettings();
    final apps = [...current.apps];
    if (oldIndex < 0 || oldIndex >= apps.length) return;
    final target = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final moved = apps.removeAt(oldIndex);
    apps.insert(target.clamp(0, apps.length), moved);
    await _write(current.copyWith(apps: apps));
  }

  Future<void> addApp({
    required String label,
    required AppCategory category,
  }) async {
    final current = state.value ?? const SeniorSettings();
    await _write(
      current.copyWith(
        apps: [
          ...current.apps,
          LauncherApp(
            id: _freshId(current.apps),
            label: label,
            category: category,
          ),
        ],
      ),
    );
  }

  Future<void> _mapApps(LauncherApp Function(LauncherApp) transform) async {
    final current = state.value ?? const SeniorSettings();
    await _write(
      current.copyWith(apps: current.apps.map(transform).toList(growable: false)),
    );
  }

  Future<void> _write(SeniorSettings settings) async {
    await ref.read(seniorSettingsRepositoryProvider).save(settings);
    state = AsyncData(settings);
  }

  /// Buttons are identified by id rather than label, so two buttons may share
  /// a name; the counter only has to avoid ids already in use.
  static String _freshId(List<LauncherApp> apps) {
    final taken = apps.map((a) => a.id).toSet();
    var n = apps.length + 1;
    while (taken.contains('app$n')) {
      n++;
    }
    return 'app$n';
  }

  static List<LauncherApp> _defaultsFor(ScreenMode mode) => switch (mode) {
    ScreenMode.easy => defaultEasyApps,
    ScreenMode.detailed => defaultDetailedApps,
  };
}

final seniorSettingsControllerProvider =
    AsyncNotifierProvider<SeniorSettingsController, SeniorSettings>(
      SeniorSettingsController.new,
    );
