import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/remote/senior_link_repository.dart';
import '../../launcher/application/senior_settings_controller.dart';
import '../application/senior_link_controller.dart';

/// Widget keys the tests drive.
class FamilyLinkKeys {
  FamilyLinkKeys._();

  static const code = Key('family-link-code');
  static const submit = Key('family-link-submit');
  static const message = Key('family-link-message');
  static const connected = Key('family-link-connected');
}

/// 가족 연결 on the parent's phone: they type the number their child read out,
/// and this phone joins that profile.
///
/// Phase 4 uses the profile's 8-character customer code. Phase 5 replaces the
/// typing with the 4-digit code and the install link, and adds recovery — this
/// screen is the seam those plug into, which is why it takes a code rather than
/// knowing where the code came from.
class FamilyLinkScreen extends ConsumerStatefulWidget {
  const FamilyLinkScreen({super.key});

  @override
  ConsumerState<FamilyLinkScreen> createState() => _FamilyLinkScreenState();
}

class _FamilyLinkScreenState extends ConsumerState<FamilyLinkScreen> {
  final _code = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(seniorLinkControllerProvider.notifier).connect(_code.text);
    } on SeniorLinkException catch (e) {
      // A mistyped number is the likely cause and the one thing they can fix,
      // so it is shown in their own words rather than as a generic failure.
      if (mounted) setState(() => _error = e.message);
    } on Object {
      if (mounted) setState(() => _error = '연결하지 못했어요. 인터넷 연결을 확인해 주세요.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final link = ref.watch(seniorLinkControllerProvider);
    final scale = ref.watch(seniorSettingsControllerProvider).value?.fontSize;

    return Scaffold(
      appBar: AppBar(title: const Text('가족 연결')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: MediaQuery.withClampedTextScaling(
            // Raising the text size is the point of this app, so the field and
            // the button grow with it rather than being pinned small.
            minScaleFactor: scale?.scale ?? 1.0,
            maxScaleFactor: scale?.scale ?? 1.0,
            child: link.value?.isLinked ?? false
                ? const _Connected()
                : _Form(
                    controller: _code,
                    busy: _busy,
                    error: _error,
                    onSubmit: _connect,
                  ),
          ),
        ),
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({
    required this.controller,
    required this.busy,
    required this.error,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool busy;
  final String? error;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '자녀분이 알려준 번호를\n그대로 넣어 주세요',
          style: TextStyle(fontSize: 24, height: 1.5, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 24),
        TextField(
          key: FamilyLinkKeys.code,
          controller: controller,
          enabled: !busy,
          textCapitalization: TextCapitalization.characters,
          // The code has no lookalike characters in it, so nothing here has to
          // guess between O and 0.
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
            LengthLimitingTextInputFormatter(8),
          ],
          style: const TextStyle(
            fontSize: 32,
            letterSpacing: 6,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        if (error case final message?) ...[
          const SizedBox(height: 16),
          Text(
            message,
            key: FamilyLinkKeys.message,
            style: TextStyle(
              fontSize: 18,
              height: 1.5,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 28),
        FilledButton(
          key: FamilyLinkKeys.submit,
          onPressed: busy ? null : onSubmit,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(64)),
          child: Text(
            busy ? '연결하는 중이에요' : '연결하기',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _Connected extends StatelessWidget {
  const _Connected();

  @override
  Widget build(BuildContext context) {
    return Column(
      key: FamilyLinkKeys.connected,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.check_circle,
          size: 72,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 20),
        const Text(
          '가족과 연결되었어요',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        const Text(
          '이제 자녀분이 이 폰의 화면을\n정리해 드릴 수 있어요',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, height: 1.6),
        ),
      ],
    );
  }
}
