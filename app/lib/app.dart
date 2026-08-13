import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'presentation/home/home_screen.dart';

/// Root widget. Kept intentionally tiny: routing and theming only.
/// Phase A ships a single screen; navigation grows in later phases.
class KeepMindApp extends StatelessWidget {
  const KeepMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KeepMind',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
