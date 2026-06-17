import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/domain/app_category.dart';

void main() {
  test('every category maps to a base+light gradient and an icon', () {
    for (final c in AppCategory.values) {
      expect(c.baseColor, isA<Color>());
      expect(c.lightColor, isA<Color>());
      expect(c.icon, isA<IconData>());
    }
  });

  test('phone maps to the green token, youtube to the red token', () {
    expect(AppCategory.phone.baseColor, AppColors.seniorButtonGreen);
    expect(AppCategory.phone.lightColor, AppColors.seniorButtonGreenLight);
    expect(AppCategory.youtube.baseColor, AppColors.seniorButtonRed);
  });
}
