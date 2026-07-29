import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/remote/senior_link_repository.dart';
import '../../../domain/pair_link.dart';
import '../../launcher/application/senior_settings_controller.dart';
import '../application/senior_pairing_controller.dart';

/// Widget keys the tests drive.
class FamilyLinkKeys {
  FamilyLinkKeys._();

  static const showCode = Key('family-link-show-code');
  static const shownCode = Key('family-link-shown-code');
  static const code = Key('family-link-code');
  static const submit = Key('family-link-submit');
  static const message = Key('family-link-message');
  static const connected = Key('family-link-connected');
}

/// 가족 연결 on the parent's phone.
///
/// Offers both directions at once, because which one applies is not something
/// the senior should have to work out:
///
/// * 이 폰 번호 보여주기 — the 4-digit code their child types (경로 B).
/// * 번호 넣기 — a number their child read out, for a replacement phone or an
///   install link that did not survive.
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

  Future<void> _enterCode() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(seniorPairingControllerProvider.notifier)
          .enterCode(_code.text);
      ref.invalidate(seniorGuardiansProvider);
    } on SeniorLinkException catch (e) {
      // A mistyped number is the likely cause and the one thing they can fix.
      if (mounted) setState(() => _error = e.message);
    } on Object {
      if (mounted) setState(() => _error = '연결하지 못했어요. 인터넷 연결을 확인해 주세요.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = ref.watch(seniorSettingsControllerProvider).value?.fontSize;
    // Connected means a guardian is attached, not merely that this phone has a
    // profile — showing a code creates one, and nobody has claimed it yet.
    final connected =
        (ref.watch(seniorGuardiansProvider).value ?? const []).isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('가족 연결')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: MediaQuery.withClampedTextScaling(
            // Raising the text size is the point of this app, so the code and
            // the field grow with it rather than being pinned small.
            minScaleFactor: scale?.scale ?? 1.0,
            maxScaleFactor: scale?.scale ?? 1.0,
            child: connected
                ? const _Connected()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _ShowCode(),
                      const SizedBox(height: 36),
                      const Divider(height: 1),
                      const SizedBox(height: 28),
                      _EnterCode(
                        controller: _code,
                        busy: _busy,
                        error: _error,
                        onSubmit: _enterCode,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// 경로 B. The number is generated here and typed by the guardian.
class _ShowCode extends ConsumerStatefulWidget {
  const _ShowCode();

  @override
  ConsumerState<_ShowCode> createState() => _ShowCodeState();
}

class _ShowCodeState extends ConsumerState<_ShowCode> {
  Timer? _poll;

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  /// While a code is on screen, ask every few seconds whether anyone has
  /// claimed it. A senior should see the screen change by itself rather than
  /// be asked to check — they have no way to know when their child finished
  /// typing.
  void _watchForGuardian() {
    _poll?.cancel();
    _poll = Timer.periodic(
      const Duration(seconds: 5),
      (_) => ref.invalidate(seniorGuardiansProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pairing = ref.watch(seniorPairingControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '자녀분에게 이 번호를\n불러 주세요',
          style: TextStyle(fontSize: 24, height: 1.5, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 20),
        switch (pairing) {
          AsyncData(value: final link?) => _Code(link: link),
          AsyncError() => const Text(
            '번호를 받지 못했어요. 인터넷 연결을 확인해 주세요.',
            style: TextStyle(fontSize: 18, height: 1.5),
          ),
          AsyncLoading() => const Center(child: CircularProgressIndicator()),
          _ => FilledButton(
            key: FamilyLinkKeys.showCode,
            onPressed: () async {
              await ref
                  .read(seniorPairingControllerProvider.notifier)
                  .showCode();
              _watchForGuardian();
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(64),
            ),
            child: const Text(
              '번호 보여주기',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ),
        },
      ],
    );
  }
}

class _Code extends StatelessWidget {
  const _Code({required this.link});

  final PairLink link;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Scales down rather than clipping: four wide-tracked digits overflow a
        // narrow phone at 아주 크게 otherwise.
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            link.code,
            key: FamilyLinkKeys.shownCode,
            style: const TextStyle(
              fontSize: 64,
              letterSpacing: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Saying it expires is the difference between a number that stopped
        // working and a phone that seems broken.
        const Text(
          '이 번호는 10분 동안만 쓸 수 있어요',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17, height: 1.5),
        ),
      ],
    );
  }
}

/// Recovery, and the 경로 A fallback. One field for both — the senior was told
/// "type this number", not which kind of number it is.
class _EnterCode extends StatelessWidget {
  const _EnterCode({
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
          '자녀분이 번호를 알려 주셨나요?',
          style: TextStyle(fontSize: 22, height: 1.5, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        TextField(
          key: FamilyLinkKeys.code,
          controller: controller,
          enabled: !busy,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          style: const TextStyle(
            fontSize: 32,
            letterSpacing: 8,
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
        const SizedBox(height: 20),
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
