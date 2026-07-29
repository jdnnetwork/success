import 'package:flutter/material.dart';

import '../../../../domain/app_category.dart';
import '../../../../domain/launcher_app.dart';

/// Clay-gradient launcher tile (launcher.jsx clayStyle): light→dark gradient,
/// large white icon + bold white label, soft drop shadow.
class AppTile extends StatelessWidget {
  const AppTile({super.key, required this.app, required this.onTap});

  final LauncherApp app;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cat = app.category;
    return Semantics(
      button: true,
      label: app.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [cat.lightColor, cat.baseColor],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: cat.baseColor.withValues(alpha: 0.42),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              // The whole tile scales down to fit rather than overflowing.
              // Raising the text size is the point of this app, so a tile that
              // breaks at 아주 크게 breaks the feature it exists to serve.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat.icon, size: 50, color: Colors.white),
                    const SizedBox(height: 8),
                    Text(
                      app.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
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
