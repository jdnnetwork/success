import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/senior_settings.dart';

/// Persistence boundary for [SeniorSettings].
abstract interface class SeniorSettingsRepository {
  Future<SeniorSettings> load();
  Future<void> save(SeniorSettings settings);
}

/// In-memory implementation, kept for tests that do not care about disk.
class MockSeniorSettingsRepository implements SeniorSettingsRepository {
  SeniorSettings _state = const SeniorSettings();

  @override
  Future<SeniorSettings> load() async => _state;

  @override
  Future<void> save(SeniorSettings settings) async => _state = settings;
}

/// Stores the whole settings object as one JSON string.
///
/// One key rather than a key per field: the settings are always read and
/// written together, and a single write cannot leave the launcher holding a
/// screen mode whose buttons never arrived.
class SharedPreferencesSeniorSettingsRepository
    implements SeniorSettingsRepository {
  static const storageKey = 'senior_settings';

  @override
  Future<SeniorSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null) return const SeniorSettings();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, Object?>) return const SeniorSettings();
      return SeniorSettings.fromJson(decoded);
    } on FormatException {
      // This app is the senior's home screen; unreadable settings must degrade
      // to defaults rather than leave them with no launcher at all.
      return const SeniorSettings();
    }
  }

  @override
  Future<void> save(SeniorSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, jsonEncode(settings.toJson()));
  }
}

final seniorSettingsRepositoryProvider = Provider<SeniorSettingsRepository>(
  (ref) => SharedPreferencesSeniorSettingsRepository(),
);
