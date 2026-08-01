import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../guardian/application/guardian_home_apps_controller.dart';
import 'conversation_view.dart';

/// 메시지 — the guardian's end of the same conversation.
///
/// `04_SCREEN_SPEC` gives this tab 카톡 스타일 대화, 텍스트 전송, 이미지 전송,
/// 무료 잔여 횟수 표시 and 유료 전환 안내. Everything but images is here;
/// sending a picture needs an image picker and file storage, neither of which
/// can be built or verified from this environment, so it is absent rather than
/// present-and-broken.
class GuardianMessageTab extends ConsumerWidget {
  const GuardianMessageTab({super.key});

  static const emptyKey = Key('guardian-message-no-parent');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(selectedSeniorProfileProvider);

    if (profile == null) {
      return const Center(
        key: emptyKey,
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            '부모님을 먼저 연결해 주세요.\n연결되면 여기에서 이야기를 나눌 수 있어요.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF6B6459)),
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              profile.displayName,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        Expanded(child: ConversationView(title: profile.displayName)),
      ],
    );
  }
}
