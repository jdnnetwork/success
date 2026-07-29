import 'package:flutter/material.dart';

import 'app_category.dart';

/// The warm palette a button can be recoloured to.
///
/// Only warm tones: `04_SCREEN_SPEC` puts the senior app on a 난색 팔레트, and
/// letting a button turn pale or cool would cost the contrast the whole screen
/// depends on.
enum ButtonColor {
  vermilion(Color(0xFFE24C2B)),
  orange(Color(0xFFF0902B)),
  yellow(Color(0xFFE8B22E)),
  rust(Color(0xFFC4451F)),
  rose(Color(0xFFD96A8A));

  const ButtonColor(this.color);

  final Color color;
}

/// A single launcher home button.
///
/// [id] is what survives editing: renaming or recolouring a button must not
/// make it a different button, and reordering must not rewrite anything else.
class LauncherApp {
  const LauncherApp({
    required this.id,
    required this.label,
    required this.category,
    this.color,
  });

  final String id;
  final String label;

  /// Drives the icon, and the colour when [color] is null.
  final AppCategory category;

  /// Set once the senior (or their guardian) picks a colour by hand.
  final ButtonColor? color;

  /// The colour actually drawn.
  Color get baseColor => color?.color ?? category.baseColor;

  LauncherApp copyWith({String? label, AppCategory? category}) => LauncherApp(
    id: id,
    label: label ?? this.label,
    category: category ?? this.category,
    color: color,
  );

  /// Separate from [copyWith] because clearing a colour is a real edit —
  /// `copyWith(color: null)` could not tell "leave it" from "reset it".
  LauncherApp withColor(ButtonColor? value) =>
      LauncherApp(id: id, label: label, category: category, color: value);

  Map<String, Object?> toJson() => {
    'id': id,
    'label': label,
    'category': category.name,
    'color': color?.name,
  };

  /// Returns null for a row that cannot be read, so one bad button does not
  /// take the whole home screen down with it.
  static LauncherApp? fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final label = json['label'];
    final category = _byName(AppCategory.values, json['category']);
    if (id is! String || label is! String || category == null) return null;
    return LauncherApp(
      id: id,
      label: label,
      category: category,
      color: _byName(ButtonColor.values, json['color']),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LauncherApp &&
      other.id == id &&
      other.label == label &&
      other.category == category &&
      other.color == color;

  @override
  int get hashCode => Object.hash(id, label, category, color);
}

T? _byName<T extends Enum>(List<T> values, Object? name) {
  if (name is! String) return null;
  for (final value in values) {
    if (value.name == name) return value;
  }
  return null;
}

/// Easy mode 2×2 grid (04_SCREEN_SPEC 정말 쉬운 화면).
const List<LauncherApp> defaultEasyApps = [
  LauncherApp(id: 'phone', label: '전화', category: AppCategory.phone),
  LauncherApp(id: 'message', label: '문자', category: AppCategory.message),
  LauncherApp(id: 'gallery', label: '앨범', category: AppCategory.gallery),
  LauncherApp(id: 'youtube', label: '영상 보기', category: AppCategory.youtube),
];

/// Detailed mode 6 buttons (04_SCREEN_SPEC 자세한 화면).
const List<LauncherApp> defaultDetailedApps = [
  LauncherApp(id: 'phone', label: '전화', category: AppCategory.phone),
  LauncherApp(id: 'message', label: '문자', category: AppCategory.message),
  LauncherApp(id: 'kakao', label: '카카오톡', category: AppCategory.kakao),
  LauncherApp(id: 'youtube', label: '영상 보기', category: AppCategory.youtube),
  LauncherApp(id: 'camera', label: '사진찍기', category: AppCategory.camera),
  LauncherApp(id: 'gallery', label: '사진 보기', category: AppCategory.gallery),
];
