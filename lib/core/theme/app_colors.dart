import 'package:flutter/material.dart';

/// Color tokens for the two app personas.
///
/// Values are extracted verbatim from the canonical design sources in
/// `design-reference/see/`:
///   - Senior (피보호자): `launcher.jsx` (PAGE_BG / INK / APPS tiles / SOS)
///     and `splash.jsx` (SplashC terracotta CTA).
///   - Guardian (보호자): `styles.css` `:root` high-contrast token set.
class AppColors {
  AppColors._();

  // ── Senior — warm cream / clay (launcher.jsx, splash.jsx) ──
  // PAGE_BG = linear-gradient(180deg, #FDF7EE 0%, #F6EBDA 100%)
  static const seniorBackground = Color(0xFFFDF7EE); // gradient top (cream)
  static const seniorBackgroundEnd = Color(
    0xFFF6EBDA,
  ); // gradient bottom (soft clay)
  static const seniorSurface = Color(0xFFFFFFFF); // card / list-row surface
  static const seniorPrimary = Color(
    0xFFE0481C,
  ); // terracotta CTA (SplashC btn / voice)
  static const seniorOnSurface = Color(0xFF3A2410); // INK — primary text
  static const seniorTextSecondary = Color(
    0xFF7A5A40,
  ); // INK_SOFT — secondary text
  static const seniorBorder = Color(
    0xFFC9A98C,
  ); // muted clay (chevron / divider)
  static const seniorSos = Color(0xFFD62116); // SOS gradient base (긴급 구조)

  // Senior launcher app-tile categories (c1 light → c2 base), from APPS in
  // launcher.jsx. Used by the home grid in Phase 1.
  static const seniorButtonGreen = Color(0xFF4E9457); // 전화
  static const seniorButtonGreenLight = Color(0xFF6FB36A);
  static const seniorButtonBlue = Color(0xFF4374B8); // 메시지
  static const seniorButtonBlueLight = Color(0xFF5E96D6);
  static const seniorButtonYellow = Color(0xFFF2A93B); // 카카오톡
  static const seniorButtonYellowLight = Color(0xFFFFCE5C);
  static const seniorButtonRed = Color(0xFFD8431C); // 유튜브
  static const seniorButtonRedLight = Color(0xFFF2683E);
  static const seniorButtonPurple = Color(0xFF7E55B0); // 카메라
  static const seniorButtonPurpleLight = Color(0xFFA074C8);
  static const seniorButtonPink = Color(0xFFC85E94); // 갤러리
  static const seniorButtonPinkLight = Color(0xFFE07AAC);

  // ── Splash / guardian entry (2026-07-29 design) ──
  // Warm paper gradient behind the hand illustration.
  static const splashBgTop = Color(0xFFFFFDF8);
  static const splashBgMid = Color(0xFFFDF6EA);
  static const splashBgBottom = Color(0xFFF6E8D5);
  static const splashInk = Color(0xFF35291F); // wordmark
  static const splashTagline = Color(0xFF7A6450);
  static const splashAccent = Color(0xFFD93516); // tap circle, wordmark dot
  static const splashPromptInk = Color(0xFF7A3D24); // 스마트폰이 쉬워져요
  static const splashCardFill = Color(0xA6FFFDF8); // guardian card, 65% alpha
  static const splashCardBorder = Color(0x3D4A382A);
  static const splashCardLabel = Color(0xFF8A7460);
  static const splashCardTitle = Color(0xFF3A2E24);

  // Guardian start screen — same paper, cooler ink.
  static const guardianStartBgTop = Color(0xFFFFFDF8);
  static const guardianStartBgMid = Color(0xFFFBF7F0);
  static const guardianStartBgBottom = Color(0xFFF4EDE2);
  static const guardianStartInk = Color(0xFF211B14);
  static const guardianStartMuted = Color(0xFF8C8578);
  static const guardianStartSub = Color(0xFF7C7568);
  static const guardianStartFaint = Color(0xFFA79F92);
  static const guardianStartAccent = Color(0xFFC4451F);
  static const guardianStartLine = Color(0xFFE3DCCE);
  static const guardianStartCardBorder = Color(0xFFEDE7DC);
  static const guardianStartBadgeFill = Color(0xFFFBF0E9);
  static const guardianStartBadgeBorder = Color(0xFFF0DACC);
  static const kakaoYellow = Color(0xFFFEE500);
  static const kakaoInk = Color(0xFF191600);

  // ── Guardian — high-contrast white / blue (styles.css :root) ──
  static const guardianPrimary = Color(0xFF0B5FD9); // --c-primary (deep blue)
  static const guardianBackground = Color(0xFFFFFFFF); // --c-bg
  static const guardianSurface = Color(
    0xFFF5F2EA,
  ); // --c-bg-soft (warm off-white)
  static const guardianOnSurface = Color(0xFF1A1A1A); // --c-ink
  static const guardianBorder = Color(0xFFE0DDD3); // --c-line
  static const guardianAccent = Color(0xFFE8B500); // --c-accent (golden)
  static const guardianDanger = Color(0xFFC8102E); // --c-danger
}
