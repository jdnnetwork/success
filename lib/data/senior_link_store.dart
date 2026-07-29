import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// What this install knows about the profile it belongs to.
///
/// [installId] is minted once and kept forever: it is how the server tells a
/// reinstall on the same phone from a genuinely new phone, and regenerating it
/// on every launch would retire the device on every launch.
class SeniorLink {
  const SeniorLink({required this.installId, this.seniorProfileId});

  final String installId;

  /// Null until the parent's phone has been connected to a profile.
  final String? seniorProfileId;

  bool get isLinked => seniorProfileId != null;

  SeniorLink copyWith({String? seniorProfileId}) => SeniorLink(
    installId: installId,
    seniorProfileId: seniorProfileId ?? this.seniorProfileId,
  );

  Map<String, Object?> toJson() => {
    'installId': installId,
    'seniorProfileId': seniorProfileId,
  };

  @override
  bool operator ==(Object other) =>
      other is SeniorLink &&
      other.installId == installId &&
      other.seniorProfileId == seniorProfileId;

  @override
  int get hashCode => Object.hash(installId, seniorProfileId);
}

/// Local record of this phone's link, alongside the launcher's settings.
abstract interface class SeniorLinkStore {
  Future<SeniorLink> load();
  Future<void> save(SeniorLink link);
}

class SharedPreferencesSeniorLinkStore implements SeniorLinkStore {
  static const storageKey = 'senior_link';

  @override
  Future<SeniorLink> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, Object?> && decoded['installId'] is String) {
          return SeniorLink(
            installId: decoded['installId']! as String,
            seniorProfileId: decoded['seniorProfileId'] as String?,
          );
        }
      } on FormatException {
        // Fall through and mint a fresh install id. Losing the link is
        // recoverable — the guardian reads the code again — but refusing to
        // start is not: this app is the phone's home screen.
      }
    }
    final link = SeniorLink(installId: newInstallId());
    await save(link);
    return link;
  }

  @override
  Future<void> save(SeniorLink link) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, jsonEncode(link.toJson()));
  }

  /// 128 bits of randomness, hex-encoded. Not a UUID: nothing parses it, and
  /// the only property that matters is that two installs never collide.
  static String newInstallId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}

class InMemorySeniorLinkStore implements SeniorLinkStore {
  InMemorySeniorLinkStore([SeniorLink? initial])
    : _link = initial ?? const SeniorLink(installId: 'install-test');

  SeniorLink _link;

  @override
  Future<SeniorLink> load() async => _link;

  @override
  Future<void> save(SeniorLink link) async => _link = link;
}

final seniorLinkStoreProvider = Provider<SeniorLinkStore>(
  (ref) => SharedPreferencesSeniorLinkStore(),
);
