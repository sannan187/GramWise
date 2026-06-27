import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/navigation_shell.dart';
import 'features/settings/controllers/settings_controller.dart';

/// Root GramWise application widget managing Material 3 theme modes dynamically.
class GramWiseApp extends ConsumerWidget {
  const GramWiseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the settings state so changes instantly rebuild the app
    final settingsState = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsNotifier.themeMode,
      home: const NavigationShell(),
    );
  }
}
