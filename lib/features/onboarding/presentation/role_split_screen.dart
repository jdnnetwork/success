import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';

/// First screen. Splits into the senior flow (large CTA) and the
/// guardian flow (small text link). No onboarding questions here.
class RoleSplitScreen extends StatelessWidget {
  const RoleSplitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              Text('잘보이네', style: text.headlineLarge),
              const SizedBox(height: 12),
              Text(
                '어르신을 위한 쉬운 스마트폰',
                style: text.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(72),
                  ),
                  onPressed: () => context.go(Routes.seniorOnboarding),
                  child: const Text('시작하기'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go(Routes.guardianLogin),
                child: const Text('가족 및 어르신을 도와주시는 분은 여기를 눌러주세요'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
