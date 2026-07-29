import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/remote/senior_link_repository.dart';
import '../../../domain/senior_profile.dart';
import '../application/guardian_session_controller.dart';

/// Widget keys the tests drive.
class AddSeniorKeys {
  AddSeniorKeys._();

  static const name = Key('add-senior-name');
  static const submit = Key('add-senior-submit');
  static const message = Key('add-senior-message');
  static const code = Key('add-senior-code');
}

/// 부모님 추가하기 — creates the profile and shows the number to read out.
///
/// The name asked for here is what the senior's phone and the SOS button will
/// call them, not the contact's own name: `07_PHASE_PLAN` is explicit that a
/// senior recognises `아들` faster than `김철수`, so the guardian types it.
class AddSeniorCard extends ConsumerStatefulWidget {
  const AddSeniorCard({super.key});

  @override
  ConsumerState<AddSeniorCard> createState() => _AddSeniorCardState();
}

class _AddSeniorCardState extends ConsumerState<AddSeniorCard> {
  final _name = TextEditingController();
  SeniorProfile? _created;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = '부모님을 부를 이름을 넣어 주세요.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final links = ref.read(seniorLinkRepositoryProvider);
      await links.ensureGuardianAccount();
      final profile = await links.createSeniorProfile(displayName: name);
      if (!mounted) return;
      setState(() => _created = profile);
      ref.invalidate(linkedSeniorProfilesProvider);
    } on SeniorLinkException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on Object {
      if (mounted) setState(() => _error = '부모님을 추가하지 못했어요. 잠시 후 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final created = _created;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '부모님 추가하기',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          '어르신이 알아보실 호칭으로 적어 주세요.',
          style: TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF6B6459)),
        ),
        const SizedBox(height: 12),
        if (created == null) ...[
          TextField(
            key: AddSeniorKeys.name,
            controller: _name,
            enabled: !_busy,
            decoration: const InputDecoration(
              labelText: '부모님 이름',
              hintText: '어머니',
              border: OutlineInputBorder(),
            ),
          ),
          if (_error case final message?) ...[
            const SizedBox(height: 10),
            Text(
              message,
              key: AddSeniorKeys.message,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton(
            key: AddSeniorKeys.submit,
            onPressed: _busy ? null : _create,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.guardianPrimary,
            ),
            child: Text(_busy ? '만드는 중이에요' : '부모님 추가하기'),
          ),
        ] else
          _CreatedCode(profile: created),
      ],
    );
  }
}

class _CreatedCode extends StatelessWidget {
  const _CreatedCode({required this.profile});

  final SeniorProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${profile.displayName} 연결 번호',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        // Scales down rather than clipping: eight wide-tracked characters
        // overflow a narrow phone otherwise.
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: SelectableText(
            profile.customerCode,
            key: AddSeniorKeys.code,
            style: const TextStyle(
              fontSize: 30,
              letterSpacing: 5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          '부모님 폰의 가족 연결 화면에서 이 번호를 넣으면 연결됩니다.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => Clipboard.setData(
            ClipboardData(text: profile.customerCode),
          ),
          icon: const Icon(Icons.copy, size: 18),
          label: const Text('번호 복사하기'),
        ),
      ],
    );
  }
}
