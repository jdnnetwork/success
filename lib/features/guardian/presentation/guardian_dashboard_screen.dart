import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/senior_profile.dart';
import '../../../domain/senior_settings.dart';
import '../application/guardian_home_apps_controller.dart';
import '../application/guardian_session_controller.dart';
import '../../care/presentation/guardian_care_tab.dart';
import '../../messages/presentation/guardian_message_tab.dart';
import 'guardian_family_tab.dart';
import 'guardian_launcher_tab.dart';

/// 보호자 대시보드. Navigable without a backend — everything shown here is
/// either local settings or mock data until Phase 4 wires Supabase.
///
/// Where the uploaded design and the project docs disagreed, the docs won:
/// 약 알림 and 복약 기록 are listed under Out Of MVP, call-content analysis is
/// excluded outright, `06_PERMISSION_AND_POLICY` forbids describing location
/// as real-time tracking, and inviting other guardians is a free feature
/// rather than part of 안심 케어.
class GuardianDashboardScreen extends StatefulWidget {
  const GuardianDashboardScreen({super.key});

  @override
  State<GuardianDashboardScreen> createState() =>
      _GuardianDashboardScreenState();
}

class _GuardianDashboardScreenState extends State<GuardianDashboardScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    // The app runs on the senior theme by default; the guardian side is a
    // different persona on a different phone — 04_SCREEN_SPEC gives it a
    // white background and a blue accent rather than the warm launcher palette.
    return Theme(data: AppTheme.guardian, child: _build(context));
  }

  Widget _build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.guardianBackground,
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: const [
            _HomeTab(),
            GuardianLauncherTab(),
            GuardianMessageTab(),
            GuardianCareTab(),
            GuardianFamilyTab(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: '홈'),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            label: '홈 화면',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            label: '메시지',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            label: '돌봄',
          ),
          NavigationDestination(icon: Icon(Icons.people_outline), label: '가족'),
        ],
      ),
    );
  }
}

class _TabScaffold extends StatelessWidget {
  const _TabScaffold({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.guardianOnSurface,
          ),
        ),
        const SizedBox(height: 18),
        ...children,
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.guardianSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.guardianBorder),
      ),
      child: child,
    );
  }
}

/// 홈 — the parent's phone at a glance.
///
/// Only what the server actually knows. Battery, ringer volume and network
/// were mocked here through Phase 3; they arrive with the 5-minute background
/// sync in Phase 6, and a plausible-looking 배터리 72% on a dashboard whose
/// whole job is to reassure would be worse than an empty state that says so.
class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(linkedSeniorProfilesProvider);
    final profile = ref.watch(selectedSeniorProfileProvider);

    if (profiles.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (profile == null) {
      return _TabScaffold(
        title: '부모님 연결하기',
        children: const [
          _Card(
            key: GuardianHomeKeys.noParent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '아직 연결된 부모님이 없어요',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 8),
                Text(
                  '가족 탭에서 부모님을 추가하면 연결 번호가 나옵니다. '
                  '그 번호를 부모님 폰의 가족 연결 화면에 넣으면 연결돼요.',
                  style: TextStyle(fontSize: 15, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return _TabScaffold(
      title: profile.displayName,
      children: [
        if ((profiles.value?.length ?? 0) > 1)
          _Card(child: _ParentSwitcher(profiles: profiles.value!)),
        const _Card(child: _DeviceStatus()),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '부모님이 고른 설정',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              _Setting(
                label: '화면',
                value: switch (profile.screenMode) {
                  ScreenMode.easy => '정말 쉬운 화면',
                  ScreenMode.detailed => '자세한 화면',
                  null => '아직 고르지 않으셨어요',
                },
              ),
              _Setting(
                label: '글씨 크기',
                value: switch (profile.fontSize) {
                  FontSize.normal => '보통',
                  FontSize.large => '크게',
                  FontSize.extraLarge => '아주 크게',
                  null => '아직 고르지 않으셨어요',
                },
              ),
            ],
          ),
        ),
        const _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '배터리 · 소리 · 인터넷',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 8),
              Text(
                '부모님 폰 상태는 안심 케어에서 5분마다 확인해 알려 드릴 예정이에요. '
                '아직 준비 중입니다.',
                style: TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF6B6459)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Widget keys the tests drive.
class GuardianHomeKeys {
  GuardianHomeKeys._();

  static const noParent = Key('guardian-home-no-parent');
  static const connected = Key('guardian-home-connected');
  static const notConnected = Key('guardian-home-not-connected');
  static const switcher = Key('guardian-home-switcher');
}

/// Whether the parent's phone has ever connected, and which one it is now.
class _DeviceStatus extends ConsumerWidget {
  const _DeviceStatus();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(selectedSeniorDeviceProvider);

    return switch (device) {
      AsyncData(value: final it?) => Column(
        key: GuardianHomeKeys.connected,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.guardianPrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '연결됨',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                it.deviceLabel ?? it.platform ?? '부모님 폰',
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B6459)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '홈 화면 탭에서 버튼을 정리해 드릴 수 있어요.',
            style: TextStyle(fontSize: 15, height: 1.5),
          ),
        ],
      ),
      AsyncData() => const Column(
        key: GuardianHomeKeys.notConnected,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '부모님 폰이 아직 연결되지 않았어요',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 8),
          // The arrangement is kept and applied the moment the phone connects,
          // so there is no reason to make them wait before tidying it.
          Text(
            '가족 탭의 연결 번호를 부모님께 알려 주세요. '
            '미리 홈 화면을 정리해 두시면 연결되는 순간 그대로 적용됩니다.',
            style: TextStyle(fontSize: 15, height: 1.5),
          ),
        ],
      ),
      AsyncError() => const Text(
        '부모님 폰 상태를 읽지 못했어요.',
        style: TextStyle(fontSize: 15),
      ),
      _ => const Center(child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: CircularProgressIndicator(),
      )),
    };
  }
}

class _ParentSwitcher extends ConsumerWidget {
  const _ParentSwitcher({required this.profiles});

  final List<SeniorProfile> profiles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedSeniorProfileProvider);
    return Row(
      key: GuardianHomeKeys.switcher,
      children: [
        const Text('부모님', style: TextStyle(fontSize: 15)),
        const Spacer(),
        DropdownButton<String>(
          value: selected?.id,
          underline: const SizedBox.shrink(),
          items: [
            for (final profile in profiles)
              DropdownMenuItem(value: profile.id, child: Text(profile.displayName)),
          ],
          onChanged: (id) {
            if (id != null) {
              ref.read(selectedSeniorProfileIdProvider.notifier).select(id);
            }
          },
        ),
      ],
    );
  }
}

class _Setting extends StatelessWidget {
  const _Setting({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

