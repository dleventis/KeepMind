import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'presentation/home/home_screen.dart';

/// Root widget. Kept intentionally tiny: routing and theming only.
/// Phase A ships a single screen; navigation grows in later phases.
class MindkeepApp extends StatelessWidget {
  const MindkeepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mindkeep',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
