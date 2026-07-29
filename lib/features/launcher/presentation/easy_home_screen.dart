import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/launcher_app.dart';
import '../application/senior_settings_controller.dart';
import '../data/app_launcher.dart';
import 'widgets/app_tile.dart';
import 'widgets/default_home_prompt.dart';
import 'widgets/sos_button.dart';

/// 정말 쉬운 화면 — 2x2 tiles, 가족 연결, SOS, 더 보기. No scrolling, depth 1.
///
/// The tiles come from the saved settings rather than the constant defaults,
/// so a rename or a removal made in 설정 actually reaches the home screen.
class EasyHomeScreen extends ConsumerWidget {
  const EasyHomeScreen({super.key});

  /// Says so when nothing opened, rather than leaving the senior tapping a
  /// tile that does nothing. Almost always the app is simply not installed.
  Future<void> _openApp(
    BuildContext context,
    WidgetRef ref,
    LauncherApp app,
  ) async {
    final opened = await ref
        .read(appLauncherProvider)
        .open(launchRequestFor(app.category));
    if (opened || !context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('${app.label}을(를) 열 수 없어요. 자녀분께 말씀해 주세요.')),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(seniorSettingsControllerProvider).value?.apps;
    final apps = (saved == null || saved.isEmpty) ? defaultEasyApps : saved;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              const DefaultHomePrompt(),
              // Two per row, laid out from the saved list so the grid shrinks
              // with it instead of indexing past the end.
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (final app in apps)
                      AppTile(
                        app: app,
                        onTap: () => _openApp(context, ref, app),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _PillButton(
                      label: '가족 연결',
                      icon: Icons.family_restroom,
                      onTap: () => context.go(Routes.familyLink),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PillButton(
                      label: '더 보기',
                      icon: Icons.apps,
                      onTap: () => context.go(Routes.moreApps),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SosButton(onTap: () => context.go(Routes.sos)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.seniorSurface,
      borderRadius: BorderRadius.circular(20),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Icon(icon, size: 30, color: AppColors.seniorPrimary),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.seniorOnSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
