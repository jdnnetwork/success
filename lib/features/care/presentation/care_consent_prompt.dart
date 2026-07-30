import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/senior_profile.dart';
import '../../family/application/senior_link_controller.dart';

/// Whether the senior has been asked to agree to 안심 케어.
final careConsentPendingProvider = FutureProvider<SeniorProfile?>((ref) async {
  final link = await ref.watch(seniorLinkControllerProvider.future);
  final profileId = link.seniorProfileId;
  if (profileId == null) return null;
  try {
    final profile = await ref
        .read(seniorLinkRepositoryProvider)
        .fetchProfile(profileId);
    return profile.paidConsentStatus == PaidConsentStatus.pending
        ? profile
        : null;
  } on Object {
    // The launcher keeps working with no signal; unknown means nothing to ask.
    return null;
  }
});

/// Step 2 of the paid flow, on the senior's own phone.
///
/// `06_PERMISSION_AND_POLICY` orders it: 보호자 결제 → 피보호자 폰에 동의 화면 →
/// 피보호자가 허락 → 시스템 권한 요청 → 기능 활성화. This is the second step, and
/// nothing downstream of it runs until it is answered.
///
/// The wording matters as much as the mechanism. Location is described as a
/// periodic check, never as tracking, because what is described here is what
/// the senior is agreeing to. And refusing is offered as plainly as agreeing —
/// a consent screen with a hard-to-find 아니요 is not asking.
class CareConsentPrompt extends ConsumerStatefulWidget {
  const CareConsentPrompt({super.key});

  static const promptKey = Key('care-consent-prompt');
  static const approveKey = Key('care-consent-approve');
  static const declineKey = Key('care-consent-decline');

  @override
  ConsumerState<CareConsentPrompt> createState() => _CareConsentPromptState();
}

class _CareConsentPromptState extends ConsumerState<CareConsentPrompt> {
  bool _busy = false;

  Future<void> _answer(String profileId, bool approve) async {
    setState(() => _busy = true);
    try {
      await ref
          .read(subscriptionRepositoryProvider)
          .resolveCareConsent(profileId, approve);
      ref.invalidate(careConsentPendingProvider);
    } on Object {
      // The question stays on screen; they can answer again with signal.
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(careConsentPendingProvider).value;
    if (profile == null) return const SizedBox.shrink();

    return Padding(
      key: CareConsentPrompt.promptKey,
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: AppColors.seniorSurface,
        borderRadius: BorderRadius.circular(20),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '자녀분이 안심 케어를\n신청하셨어요',
                style: TextStyle(
                  fontSize: 20,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: AppColors.seniorOnSurface,
                ),
              ),
              const SizedBox(height: 8),
              // Each line is a thing that will actually happen. 위치 확인 is
              // 5분 주기 — never described as tracking.
              const Text(
                '허락하시면 이런 것을 자녀분이 볼 수 있어요.\n'
                '· 5분마다 어디 계신지\n'
                '· 연락처에 없는 번호와 통화하셨는지\n'
                '· 배터리와 소리, 인터넷 상태\n\n'
                '싫으시면 아니요를 누르세요. 지금 쓰시는 기능은\n'
                '그대로 쓸 수 있고, 자녀분 결제는 취소됩니다.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: AppColors.seniorOnSurface,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: CareConsentPrompt.declineKey,
                      onPressed: _busy ? null : () => _answer(profile.id, false),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                      child: const Text(
                        '아니요',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      key: CareConsentPrompt.approveKey,
                      onPressed: _busy ? null : () => _answer(profile.id, true),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                      child: const Text(
                        '허락합니다',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
