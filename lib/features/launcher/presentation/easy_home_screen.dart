import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/launcher_app.dart';
import '../application/senior_settings_controller.dart';
import '../data/app_launcher.dart';
import 'widgets/app_tile.dart';
import '../../care/presentation/care_consent_prompt.dart';
import '../../family/application/senior_pairing_controller.dart';
import '../../family/presentation/primary_guardian_prompt.dart';
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
    // `04_SCREEN_SPEC` gives this slot as 가족 연결 또는 자녀 이름 버튼: before a
    // family is attached it is the way to attach one, and afterwards it is the
    // way to talk to them. A senior who is already connected has no use for a
    // 가족 연결 button, and every use for a way to answer their child.
    final connected =
        (ref.watch(seniorGuardiansProvider).value ?? const []).isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              const CareConsentPrompt(),
              const PrimaryGuardianPrompt(),
              const DefaultHomePrompt(),
              // Two per row, laid out from the saved list so the grid shrinks
              // with it instead of indexing past the end.
              //
              // The rows are sized from the space actually left rather than
              // left square. This screen does not scroll, and at 아주 크게 with
              // the 첫 화면 card showing there is not room for two square
              // tiles — a square grid quietly clips the bottom row instead of
              // complaining, so the labels simply vanish. Shorter tiles keep
              // every button whole; `AppTile` scales its own contents to fit.
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = 14.0;
                    final rows = (apps.length / 2).ceil();
                    final width = (constraints.maxWidth - spacing) / 2;
                    final height =
                        (constraints.maxHeight - spacing * (rows - 1)) / rows;
                    return GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: spacing,
                      crossAxisSpacing: spacing,
                      childAspectRatio: height > 0 ? width / height : 1,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for (final app in apps)
                          AppTile(
                            app: app,
                            onTap: () => _openApp(context, ref, app),
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _PillButton(
                      label: connected ? '가족 메시지' : '가족 연결',
                      icon: connected
                          ? Icons.chat_bubble_outline
                          : Icons.family_restroom,
                      onTap: () => context.push(
                        connected ? Routes.familyMessages : Routes.familyLink,
                      ),
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
