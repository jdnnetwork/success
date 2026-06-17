import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/launcher_app.dart';
import 'widgets/app_tile.dart';
import 'widgets/sos_button.dart';

/// 정말 쉬운 화면 — 2x2 tiles, 가족 연결, SOS, 더 보기. No scrolling, depth 1.
class EasyHomeScreen extends StatelessWidget {
  const EasyHomeScreen({super.key});

  void _openApp(BuildContext context, LauncherApp app) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('${app.label} 열기는 다음 단계에서 연결됩니다')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              // 2×2 grid using fixed Column/Row so all 4 tiles always build.
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: AppTile(
                              app: defaultEasyApps[0],
                              onTap: () =>
                                  _openApp(context, defaultEasyApps[0]),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: AppTile(
                              app: defaultEasyApps[1],
                              onTap: () =>
                                  _openApp(context, defaultEasyApps[1]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: AppTile(
                              app: defaultEasyApps[2],
                              onTap: () =>
                                  _openApp(context, defaultEasyApps[2]),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: AppTile(
                              app: defaultEasyApps[3],
                              onTap: () =>
                                  _openApp(context, defaultEasyApps[3]),
                            ),
                          ),
                        ],
                      ),
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
  const _PillButton(
      {required this.label, required this.icon, required this.onTap});

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
              Text(label,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.seniorOnSurface)),
            ],
          ),
        ),
      ),
    );
  }
}
