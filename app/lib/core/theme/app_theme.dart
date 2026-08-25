import 'package:flutter/material.dart';

/// Centralized theme so screens never hand-roll colors/typography.
///
/// Seeded from the app icon so the icon and the app read as one product:
/// the icon's deep teal-navy background becomes the primary seed, and its
/// glowing amber clock becomes the accent used for anything time-related.
class AppTheme {
  AppTheme._();

  /// Sampled from the icon's background.
  static const Color seed = Color(0xFF12384C);

  /// The icon's glowing clock. Reserved for time and urgency — dates,
  /// reminders, the thing the user is being told about — so the accent
  /// means something rather than just decorating.
  static const Color accent = Color(0xFFF08A3C);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    ).copyWith(tertiary: accent);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
    );
  }
}
