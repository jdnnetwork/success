import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'domain/senior_settings.dart';
import 'features/launcher/application/senior_settings_controller.dart';

/// Root widget. Uses the senior theme by default (the first screen is the
/// senior-app entry). Guardian screens apply [AppTheme.guardian] locally
/// in later phases.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final fontSize =
        ref.watch(seniorSettingsControllerProvider).value?.fontSize ??
        FontSize.normal;

    return MaterialApp.router(
      title: '잘보이네',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.senior,
      routerConfig: router,
      // Applied here rather than per screen so the chosen size reaches every
      // label, including dialogs and anything added later. Saving the choice
      // is not the feature — seeing it is.
      //
      // The senior's own choice replaces the system scale rather than
      // compounding with it: someone who already enlarged text OS-wide would
      // otherwise land on 그냥 크게 rendering enormous.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(fontSize.scale)),
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
