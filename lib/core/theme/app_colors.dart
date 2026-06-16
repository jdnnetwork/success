import 'package:flutter/material.dart';

/// Color tokens for the two app personas.
///
/// Senior (피보호자) values are extracted directly from the clay/cream design
/// references in `design-reference/` (잘보이네 스플래시 / 홈화면 standalone HTML).
/// Guardian (보호자) palette is white with a blue accent.
class AppColors {
  AppColors._();

  // ── Senior — clay / cream (from design-reference) ──
  // Body background is a radial gradient #F6EEE2 → #EFE3D2.
  static const seniorBackground = Color(0xFFF6EEE2); // gradient top (cream)
  static const seniorBackgroundEnd = Color(0xFFEFE3D2); // gradient bottom (clay)
  static const seniorSurface = Color(0xFFFFFDF9); // card surface (near-white cream)
  static const seniorPrimary = Color(0xFFC2531E); // terracotta brand accent
  static const seniorOnSurface = Color(0xFF3A2410); // primary text (dark clay brown)
  static const seniorTextSecondary = Color(0xFF7A5A40); // secondary text (muted brown)
  static const seniorBorder = Color(0xFFC9A98C); // clay tan border / divider

  // Senior launcher button category colors (light → dark gradient pairs),
  // used by the home grid in Phase 1.
  static const seniorButtonGreen = Color(0xFF4E9457);
  static const seniorButtonGreenLight = Color(0xFF6FB36A);
  static const seniorButtonBlue = Color(0xFF4374B8);
  static const seniorButtonBlueLight = Color(0xFF5E96D6);
  static const seniorButtonPurple = Color(0xFF7E55B0);
  static const seniorButtonPurpleLight = Color(0xFFA074C8);
  static const seniorButtonPink = Color(0xFFC85E94);
  static const seniorButtonPinkLight = Color(0xFFE07AAC);

  // ── Guardian — clean white with blue accent ──
  static const guardianPrimary = Color(0xFF2563EB); // blue
  static const guardianBackground = Color(0xFFFFFFFF);
  static const guardianSurface = Color(0xFFF7F8FA);
  static const guardianOnSurface = Color(0xFF1A1A1A);
}
