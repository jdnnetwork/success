import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/app_category.dart';
import '../../../domain/launcher_app.dart';
import '../../launcher/application/senior_settings_controller.dart';
import 'add_senior_card.dart';

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
            _LauncherTab(),
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
  const _Card({required this.child});

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

/// 홈 — the parent's phone at a glance, plus the actions used most often.
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return _TabScaffold(
      title: '어머니 김순자',
      children: [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
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
                  const Text(
                    '방금 전까지 사용 중',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B6459)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Wrap(
                spacing: 18,
                runSpacing: 8,
                children: [
                  Text('배터리 72%', style: TextStyle(fontSize: 16)),
                  Text('벨소리 · 70%', style: TextStyle(fontSize: 16)),
                  Text('인터넷 연결됨', style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 12),
              // Naming the refresh rule prevents a stale reading from being
              // mistaken for a current one.
              const Text(
                '앱을 열 때 1회 갱신됩니다',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B6459)),
              ),
            ],
          ),
        ),
        const _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '빠른 조작',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 10),
              _QuickAction(label: '글씨 크게', detail: '현재 아주 크게'),
              _QuickAction(label: '소리 설정', detail: '벨소리 · 70%'),
              _QuickAction(label: '메시지 보내기', detail: '이번 달 32회 남음'),
              _QuickAction(label: '바로 전화', detail: '어머니에게 걸기'),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.label, required this.detail});

  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontSize: 16)),
      subtitle: Text(detail, style: const TextStyle(fontSize: 13)),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

/// 홈 화면 — the docs' 홈 관리 탭: the buttons on the parent's launcher.
class _LauncherTab extends ConsumerWidget {
  const _LauncherTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(seniorSettingsControllerProvider).value?.apps;
    final apps = (saved == null || saved.isEmpty) ? defaultEasyApps : saved;

    return _TabScaffold(
      title: '홈 화면 구성',
      children: [
        const _Card(
          child: Text(
            '바꾸면 어머니 폰에 바로 반영됩니다. 홈 화면 앱과 버튼 색을 원격으로 정리합니다.',
            style: TextStyle(fontSize: 15, height: 1.5),
          ),
        ),
        for (final app in apps)
          _Card(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: app.baseColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(app.category.icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    app.label,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(Icons.drag_handle, color: Color(0xFF9C8770)),
              ],
            ),
          ),
        const _Card(
          child: Text(
            '버튼 색상은 눈에 잘 띄는 난색 팔레트만 제공합니다.',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B6459)),
          ),
        ),
      ],
    );
  }
}

/// 돌봄 — the docs' 안심 탭. Paid features and what they cost.
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
