/// Theme for Lead Tracker.
///
/// Uses a single seed color (deep teal) with [ColorScheme.fromSeed] and
/// Material 3. All colors, text styles and component themes live here so the
/// app has a consistent, professional look.
library;

import 'package:flutter/material.dart';

/// The app's seed color - a deep teal used consistently across status chips,
/// stat cards and buttons.
const Color kSeedColor = Color(0xFF0F6B6B);

/// Status colors used consistently in chips, cards and the chart.
const Color kStatusNewColor = Color(0xFF2196F3); // blue
const Color kStatusContactedColor = Color(0xFFFF9800); // orange
const Color kStatusConvertedColor = Color(0xFF4CAF50); // green

/// Returns the color associated with a lead status.
Color statusColor(String status) {
  switch (status) {
    case 'New':
      return kStatusNewColor;
    case 'Contacted':
      return kStatusContactedColor;
    case 'Converted':
      return kStatusConvertedColor;
    default:
      return kSeedColor;
  }
}

/// The [ThemeData] for the app (light mode).
ThemeData appTheme() {
  final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: kSeedColor,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      foregroundColor: colorScheme.onPrimaryContainer,
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kSeedColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: kSeedColor,
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      selectedItemColor: kSeedColor,
      unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
      type: BottomNavigationBarType.fixed,
      elevation: 2,
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outline.withValues(alpha: 0.2),
      space: 1,
      thickness: 1,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  );
}
