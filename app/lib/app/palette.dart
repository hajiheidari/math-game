import 'package:flutter/material.dart';
import 'package:numcross_engine/numcross_engine.dart';

/// Adadi's warm colors (Amir, 2026-10-11: "warmer, more inviting, not busy").
/// The Material color scheme is built from [tangerine]; the rest are accents.
class Palette {
  static const tangerine = Color(0xFFFF6B3D);
  static const coral = Color(0xFFFF4F6D);
  static const sun = Color(0xFFFFB627);
  static const teal = Color(0xFF14B8A6);
  static const violet = Color(0xFF7C5CFF);
  static const ink = Color(0xFF2A1E3B);

  /// Light background: warm cream; dark: deep plum.
  static const cream = Color(0xFFFFF7EF);
  static const plum = Color(0xFF1B1426);

  static const star = Color(0xFFFFB627);
  static const flame = Color(0xFFFF6B3D);

  /// One color per difficulty, used on buttons and cards.
  static Color difficulty(Difficulty d) => switch (d) {
    Difficulty.easy => teal,
    Difficulty.medium => sun,
    Difficulty.hard => tangerine,
    Difficulty.expert => violet,
  };

  /// Inside a puzzle: calm navy and blue (Amir, 2026-10-11: red/orange in
  /// the game felt stressful). The menu keeps the warm colors.
  static const navy = Color(0xFF2F5D8A);

  static ThemeData calm(ThemeData base) {
    final dark = base.brightness == Brightness.dark;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: navy,
          brightness: base.brightness,
        ).copyWith(
          surface: dark ? const Color(0xFF131A24) : const Color(0xFFF4F7FB),
          surfaceContainerLowest: dark ? const Color(0xFF0E141C) : Colors.white,
          surfaceContainerLow: dark ? const Color(0xFF1B2430) : Colors.white,
        );
    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: base.appBarTheme.copyWith(backgroundColor: scheme.surface),
      dialogTheme: base.dialogTheme.copyWith(
        backgroundColor: scheme.surfaceContainerLow,
      ),
    );
  }

  /// The daily card / hero gradient.
  static const hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF8A3D), Color(0xFFFF4F6D)],
  );
}
