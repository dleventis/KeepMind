import 'package:flutter/material.dart';

/// Centralized theme so screens never hand-roll colors/typography.
/// Deliberately minimal for Phase A — expand once real screens exist
/// and accessibility/contrast passes are done (brief section 25).
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: const Color(0xFF3D5A80),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: const Color(0xFF3D5A80),
  );
}
