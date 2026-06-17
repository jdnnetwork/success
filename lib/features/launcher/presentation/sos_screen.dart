import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../data/phone_dialer.dart';

/// SOS — choose 119 / 112 / 보호자. Selecting a number OPENS the dialer with
/// the number pre-filled; it never calls. The user must press call in the OS
/// dialer (04_SCREEN_SPEC / 06_PERMISSION_AND_POLICY).
class SosScreen extends ConsumerWidget {
  const SosScreen({super.key});

  Future<void> _dial(BuildContext context, WidgetRef ref, String number) async {
    await ref.read(phoneDialerProvider).openDialer(number);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('긴급 연락')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: _SosTile(
                  label: '119',
                  caption: '불 · 구급',
                  onTap: () => _dial(context, ref, '119'),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _SosTile(
                  label: '112',
                  caption: '경찰',
                  onTap: () => _dial(context, ref, '112'),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _SosTile(
                  label: '보호자',
                  caption: '가족을 연결하면 사용할 수 있어요',
                  onTap: null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SosTile extends StatelessWidget {
  const _SosTile({required this.label, required this.caption, this.onTap});

  final String label;
  final String caption;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: enabled ? AppColors.seniorSos : AppColors.seniorBorder,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                caption,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
