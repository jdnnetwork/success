import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/launcher_app.dart';
import 'widgets/app_tile.dart';

/// 자세한 화면 — scrollable 2-col grid (6 default + 2 add-slots) with bottom
/// tabs: 첫 화면 / 설정 / SOS. SOS tab routes to the SOS screen.
class DetailedHomeScreen extends StatefulWidget {
  const DetailedHomeScreen({super.key});

  @override
  State<DetailedHomeScreen> createState() => _DetailedHomeScreenState();
}

class _DetailedHomeScreenState extends State<DetailedHomeScreen> {
  int _index = 0;

  void _openApp(LauncherApp app) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('${app.label} 열기는 다음 단계에서 연결됩니다')));
  }

  void _onTab(int i) {
    if (i == 2) {
      context.go(Routes.sos);
      return;
    }
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: [
            _HomeGrid(onOpen: _openApp),
            const _SettingsPanel(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index == 1 ? 1 : 0,
        onDestinationSelected: _onTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: '첫 화면'),
          NavigationDestination(icon: Icon(Icons.settings), label: '설정'),
          NavigationDestination(
            icon: Icon(Icons.sos, color: AppColors.seniorSos),
            label: 'SOS',
          ),
        ],
      ),
    );
  }
}

class _HomeGrid extends StatelessWidget {
  const _HomeGrid({required this.onOpen});

  final void Function(LauncherApp) onOpen;

  @override
  Widget build(BuildContext context) {
    // SingleChildScrollView + shrinkWrap grid: scrollable for real use AND
    // builds all 8 cells eagerly (so widget tests find every tile/slot).
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (final app in defaultDetailedApps)
            AppTile(app: app, onTap: () => onOpen(app)),
          _AddSlot(),
          _AddSlot(),
        ],
      ),
    );
  }
}

class _AddSlot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.seniorSurface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.seniorBorder, width: 2),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, size: 44, color: AppColors.seniorTextSecondary),
          SizedBox(height: 6),
          Text(
            '추가하기',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.seniorTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline settings placeholder (full settings is Phase 2/3).
class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel();

  @override
  Widget build(BuildContext context) {
    const items = [
      '앱 설정하기',
      '글씨 크기 조절하기',
      '가족 연결 설정',
      '진동/벨소리 전환',
      '잘보이네 사용하지 않기',
    ];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        for (final label in items)
          Card(
            color: AppColors.seniorSurface,
            child: ListTile(
              title: Text(
                label,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.seniorOnSurface,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
      ],
    );
  }
}
