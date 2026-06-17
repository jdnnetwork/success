import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/senior_settings.dart';
import '../../launcher/application/senior_settings_controller.dart';

/// Onboarding step: pick the launcher style. The ONLY onboarding question.
class ScreenModeChoiceScreen extends ConsumerWidget {
  const ScreenModeChoiceScreen({super.key});

  Future<void> _choose(
    BuildContext context,
    WidgetRef ref,
    ScreenMode mode,
  ) async {
    await ref
        .read(seniorSettingsControllerProvider.notifier)
        .chooseScreenMode(mode);
    if (!context.mounted) return;
    // Phase 1 routes from the tapped card. Phase 2 (shared_preferences) should
    // add a router redirect that reads the saved screenMode so a returning
    // senior lands directly on their home instead of the splash.
    context.go(mode == ScreenMode.easy ? Routes.easyHome : Routes.detailedHome);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text(
                '화면을 골라주세요',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _ModeCard(
                  title: '정말 쉬운 화면',
                  subtitle: '큰 버튼 4개, 가장 간단해요',
                  onTap: () => _choose(context, ref, ScreenMode.easy),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _ModeCard(
                  title: '자세한 화면',
                  subtitle: '앱 6개와 설정을 쓸 수 있어요',
                  onTap: () => _choose(context, ref, ScreenMode.detailed),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.seniorSurface,
      borderRadius: BorderRadius.circular(22),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.seniorOnSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 20,
                  color: AppColors.seniorTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
