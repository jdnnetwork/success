import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Always-visible red emergency bar (launcher.jsx SOS).
class SosButton extends StatelessWidget {
  const SosButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '긴급 구조 요청',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.seniorSos,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.seniorSos.withValues(alpha: 0.45),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            // Scales down rather than clipping: at 아주 크게 the label and
            // icon no longer fit the pill, and SOS is the one control that
            // must never be half off the screen.
            child: const Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_active,
                      color: Colors.white,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      '긴급 구조 요청',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
