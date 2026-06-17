import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';

/// First screen (splash.jsx · SplashC 단정). Warm wordmark, headline, large
/// 시작하기 CTA for the senior flow, small underlined helper link for guardians.
/// No onboarding questions here.
class RoleSplitScreen extends StatelessWidget {
  const RoleSplitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Wordmark: small warm sun dot + 잘보이네
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.seniorButtonYellowLight,
                          AppColors.seniorPrimary,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    '잘보이네',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: AppColors.seniorPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 34),
              const Text(
                '어르신을 위한\n쉬운 스마트폰',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 43,
                  height: 1.24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.seniorOnSurface,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.seniorPrimary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(84),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  onPressed: () => context.go(Routes.seniorOnboarding),
                  child: const Text(
                    '시작하기',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // Single string (no '\n') so it both wraps to two lines via
              // TextAlign.center AND keeps matching the Phase 0 widget_test.
              TextButton(
                onPressed: () => context.go(Routes.guardianLogin),
                child: const Text(
                  '가족 및 어르신을 도와주시는 분은 여기를 눌러주세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: AppColors.seniorTextSecondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
