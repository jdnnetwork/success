import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/senior_settings.dart';

/// Persistence boundary for [SeniorSettings].
///
/// Phase 0 ships an in-memory mock. Phase 2 adds a shared_preferences-backed
/// implementation behind this same interface — consumers do not change.
abstract interface class SeniorSettingsRepository {
  Future<SeniorSettings> load();
  Future<void> save(SeniorSettings settings);
}

/// In-memory implementation for Phase 0 (no persistence across restarts).
class MockSeniorSettingsRepository implements SeniorSettingsRepository {
  SeniorSettings _state = const SeniorSettings();

  @override
  Future<SeniorSettings> load() async => _state;

  @override
  Future<void> save(SeniorSettings settings) async => _state = settings;
}

/// Override this provider in Phase 2 with the shared_preferences-backed repo.
final seniorSettingsRepositoryProvider = Provider<SeniorSettingsRepository>(
  (ref) => MockSeniorSettingsRepository(),
);
