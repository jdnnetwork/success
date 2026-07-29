import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../data/app_launcher.dart';

/// Returns the app to its first screen when the Home key is pressed.
///
/// Once this app is the phone's home app, pressing Home does not restart it —
/// Android hands the running task a fresh HOME intent. Without listening for
/// that, the key does nothing whenever the senior is anywhere but the home
/// screen, which is exactly when they reach for it.
///
/// Wrapped around the router rather than placed on a screen: the point is to
/// leave whichever screen is on top, so it cannot live on any of them.
class HomeKeyListener extends StatefulWidget {
  const HomeKeyListener({
    super.key,
    required this.router,
    required this.child,
  });

  final GoRouter router;
  final Widget child;

  @override
  State<HomeKeyListener> createState() => _HomeKeyListenerState();
}

class _HomeKeyListenerState extends State<HomeKeyListener> {
  @override
  void initState() {
    super.initState();
    MethodChannelAppLauncher.channel.setMethodCallHandler(_onCall);
  }

  @override
  void dispose() {
    MethodChannelAppLauncher.channel.setMethodCallHandler(null);
    super.dispose();
  }

  Future<void> _onCall(MethodCall call) async {
    if (call.method != 'goHome') return;
    // The launch gate, not a home screen directly: on a phone the senior has
    // set up it resolves to their chosen home, and on one they have not it
    // still lands somewhere sensible.
    widget.router.go(Routes.firstScreen);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
