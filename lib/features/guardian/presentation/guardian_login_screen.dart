import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../application/guardian_session_controller.dart';

/// Widget keys the tests drive.
class GuardianLoginKeys {
  GuardianLoginKeys._();

  static const email = Key('guardian-login-email');
  static const password = Key('guardian-login-password');
  static const submit = Key('guardian-login-submit');
  static const toggleMode = Key('guardian-login-toggle-mode');
  static const message = Key('guardian-login-message');
}

/// 보호자 로그인. Email and password, which is what the project's auth settings
/// actually support today.
///
/// `GuardianStartScreen` argues for Kakao and Google, and that is still the
/// intended entry — but neither has an OAuth client configured on the Supabase
/// project, so a button there would fail on tap. This screen is the honest
/// route in the meantime rather than a replacement for that decision.
class GuardianLoginScreen extends ConsumerStatefulWidget {
  const GuardianLoginScreen({super.key});

  @override
  ConsumerState<GuardianLoginScreen> createState() =>
      _GuardianLoginScreenState();
}

class _GuardianLoginScreenState extends ConsumerState<GuardianLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _creatingAccount = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final controller = ref.read(guardianLoginControllerProvider.notifier);
    final ok = _creatingAccount
        ? await controller.signUp(
            email: _email.text,
            password: _password.text,
          )
        : await controller.signIn(
            email: _email.text,
            password: _password.text,
          );
    if (ok && mounted) context.go(Routes.guardianDashboard);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(guardianLoginControllerProvider);
    final busy = state is GuardianLoginBusy;

    return Theme(
      data: AppTheme.guardian,
      child: Scaffold(
        backgroundColor: AppColors.guardianBackground,
        appBar: AppBar(
          backgroundColor: AppColors.guardianBackground,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => context.go(Routes.guardianStart),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(26, 8, 26, 34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _creatingAccount ? '보호자 계정 만들기' : '보호자 로그인',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '부모님 폰을 대신 정리해 드리려면 보호자 계정이 필요해요.',
                  style: TextStyle(fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 26),
                TextField(
                  key: GuardianLoginKeys.email,
                  controller: _email,
                  enabled: !busy,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: '이메일',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  key: GuardianLoginKeys.password,
                  controller: _password,
                  enabled: !busy,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  decoration: const InputDecoration(
                    labelText: '비밀번호',
                    helperText: '6자 이상',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (_messageFor(state) case final message?) ...[
                  const SizedBox(height: 14),
                  _Message(
                    key: GuardianLoginKeys.message,
                    text: message,
                    isError: state is GuardianLoginFailed,
                  ),
                ],
                const SizedBox(height: 22),
                FilledButton(
                  key: GuardianLoginKeys.submit,
                  onPressed: busy ? null : _submit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_creatingAccount ? '가입하기' : '로그인'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  key: GuardianLoginKeys.toggleMode,
                  onPressed: busy
                      ? null
                      : () => setState(() {
                          _creatingAccount = !_creatingAccount;
                        }),
                  child: Text(
                    _creatingAccount ? '이미 계정이 있어요' : '계정이 없어요, 새로 만들래요',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String? _messageFor(GuardianLoginState state) => switch (state) {
    GuardianLoginFailed(:final message) => message,
    GuardianLoginAwaitingConfirmation(:final email) =>
      '$email 으로 인증 메일을 보냈어요. 메일의 링크를 누른 뒤 로그인해 주세요.',
    _ => null,
  };
}

class _Message extends StatelessWidget {
  const _Message({super.key, required this.text, required this.isError});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: TextStyle(color: color, height: 1.45)),
    );
  }
}
