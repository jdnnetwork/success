/// Which launcher home the senior sees. Chosen during onboarding (Phase 1).
enum ScreenMode { easy, detailed }

/// Persistent senior-facing settings. In Phase 0 this only carries the
/// screen-mode choice; later phases extend it (font size, etc.).
class SeniorSettings {
  const SeniorSettings({this.screenMode});

  /// `null` means the senior has not chosen a mode yet.
  final ScreenMode? screenMode;

  SeniorSettings copyWith({ScreenMode? screenMode}) =>
      SeniorSettings(screenMode: screenMode ?? this.screenMode);

  @override
  bool operator ==(Object other) =>
      other is SeniorSettings && other.screenMode == screenMode;

  @override
  int get hashCode => screenMode.hashCode;
}
