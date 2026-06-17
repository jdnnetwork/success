import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Visual category for a launcher tile. Drives the clay gradient + icon.
/// Colors come verbatim from `design-reference/see/launcher.jsx` APPS.
enum AppCategory { phone, message, kakao, youtube, camera, gallery }

extension AppCategoryStyle on AppCategory {
  /// Darker gradient stop (c2 in launcher.jsx).
  Color get baseColor => switch (this) {
        AppCategory.phone => AppColors.seniorButtonGreen,
        AppCategory.message => AppColors.seniorButtonBlue,
        AppCategory.kakao => AppColors.seniorButtonYellow,
        AppCategory.youtube => AppColors.seniorButtonRed,
        AppCategory.camera => AppColors.seniorButtonPurple,
        AppCategory.gallery => AppColors.seniorButtonPink,
      };

  /// Lighter gradient stop (c1 in launcher.jsx).
  Color get lightColor => switch (this) {
        AppCategory.phone => AppColors.seniorButtonGreenLight,
        AppCategory.message => AppColors.seniorButtonBlueLight,
        AppCategory.kakao => AppColors.seniorButtonYellowLight,
        AppCategory.youtube => AppColors.seniorButtonRedLight,
        AppCategory.camera => AppColors.seniorButtonPurpleLight,
        AppCategory.gallery => AppColors.seniorButtonPinkLight,
      };

  /// Nearest Material glyph to the launcher.jsx custom icon.
  IconData get icon => switch (this) {
        AppCategory.phone => Icons.call,
        AppCategory.message => Icons.sms,
        AppCategory.kakao => Icons.chat_bubble,
        AppCategory.youtube => Icons.smart_display,
        AppCategory.camera => Icons.photo_camera,
        AppCategory.gallery => Icons.photo_library,
      };
}
