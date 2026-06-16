import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Root widget. Uses the senior theme by default (the first screen is the
/// senior-app entry). Guardian screens apply [AppTheme.guardian] locally
/// in later phases.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: '잘보이네',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.senior,
      routerConfig: router,
    );
  }
}
