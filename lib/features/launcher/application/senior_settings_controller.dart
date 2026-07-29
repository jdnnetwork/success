import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/senior_settings_repository.dart';
import '../../../domain/app_category.dart';
import '../../../domain/launcher_app.dart';
import '../../../domain/senior_settings.dart';
import 'senior_settings_sync.dart';

/// Holds the senior's settings, loading from and saving to the repository.
///
/// Every edit writes through before the new state is published, so what the
/// screen shows is what survived to disk. On this app that matters more than
/// the extra await: it is the phone's home screen.
///
/// Since Phase 4 each write is also pushed to Supabase, but never in the path
/// the senior waits on: disk is the source of truth, the server is a copy, and
/// an edit must land at full speed on a phone with no signal.
class SeniorSettingsController extends AsyncNotifier<SeniorSettings> {
  Future<void>? _sync;

  /// The push started by the most recent write, for tests and for callers that
  /// need the server to have caught up. Never completes with an error.
  Future<void> get pendingSync => _sync ?? Future<void>.value();

  @override
  Future<SeniorSettings> build() {
    return ref.watch(seniorSettingsRepositoryProvider).load();
  }

  /// Adopts whatever the server holds for this phone's profile.
  ///
  /// Called after the phone is linked, so a guardian who arranged the home
  /// screen before the parent connected sees their arrangement take effect.
  Future<bool> pullFromServer() async {
    final current = state.value ?? const SeniorSettings();
    final merged = await ref.read(seniorSettingsSyncProvider).pull(current);
    if (merged == null) return false;
    await ref.read(seniorSettingsRepositoryProvider).save(merged);
    state = AsyncData(merged);
    return true;
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
    // Deliberately not awaited: the senior has already seen the change, and
    // holding the edit open for a round trip would make every rename feel like
    // a network operation. `push` swallows its own failures.
    _sync = ref.read(seniorSettingsSyncProvider).push(settings);
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
