import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/senior_profile.dart';
import '../../../domain/senior_settings.dart';
import '../application/guardian_home_apps_controller.dart';
import '../application/guardian_session_controller.dart';
import 'add_senior_card.dart';
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
            _CareTab(),
            _FamilyTab(),
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

class _CareTab extends StatelessWidget {
  const _CareTab();

  /// Wording follows `06_PERMISSION_AND_POLICY`: location is a periodic check
  /// rather than tracking, and the call alert is about numbers absent from the
  /// contact list, not about anything heard during the call.
  static const _features = <(String, String)>[
    ('위치 확인', '5분 주기로 어디 계신지 확인합니다'),
    ('모르는 번호 통화 알림', '연락처에 없는 번호와 통화하면 알려드립니다'),
    ('폰 미사용 알림', '12시간 동안 사용이 없으면 알림'),
    ('배터리 부족 알림', '20% 아래로 떨어지면 알림'),
    ('긴급 소리 보내기', '무음이어도 녹음한 목소리를 재생합니다'),
    ('가족 메시지 무제한', '무료 플랜의 월 50회 제한이 없어집니다'),
  ];

  @override
  Widget build(BuildContext context) {
    return _TabScaffold(
      title: '안심 케어',
      children: [
        const _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '월 5,900원',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 6),
              Text(
                '언제든 해지할 수 있습니다. 어머니가 동의하셔야 켜집니다.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        for (final (title, detail) in _features)
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lock_outline, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(detail, style: const TextStyle(fontSize: 14, height: 1.5)),
              ],
            ),
          ),
      ],
    );
  }
}

/// 가족 — the docs' 설정 탭: connection, invites, parent info.
class _FamilyTab extends StatelessWidget {
  const _FamilyTab();

  @override
  Widget build(BuildContext context) {
    return _TabScaffold(
      // Distinct from the tab label so the heading and the nav item are not
      // the same string.
      title: '가족 관리',
      children: [
        // Phase 4: creates the profile for real and hands back the number the
        // parent's phone actually accepts. The 가족 연결 코드 card below is the
        // Phase 5 shape — a 4-digit code the parent reads out — and is still
        // mocked, so the two are not the same number.
        const _Card(child: AddSeniorCard()),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '가족 연결 코드',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              // Scales down rather than clipping: four boxes at this padding
              // overflow a narrow phone by a hair.
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final digit in ['4', '7', '2', '9'])
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.guardianBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.guardianBorder),
                        ),
                        child: Text(
                          digit,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '어머니 폰에서 이 숫자를 입력하면 연결됩니다 (준비 중)',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B6459)),
              ),
            ],
          ),
        ),
        const _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '연결된 가족',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 10),
              Text('김지훈 · 대표 보호자', style: TextStyle(fontSize: 16)),
              SizedBox(height: 6),
              Text('김지원', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '가족 초대하기',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              // Free per the PRD; the uploaded design had put this behind
              // 안심 케어.
              const Text(
                '형제자매도 함께 돌볼 수 있어요. 무료입니다.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.guardianPrimary,
                ),
                onPressed: () {},
                child: const Text('초대 링크 보내기'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
