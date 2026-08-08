import 'package:flutter/material.dart';

/// Jedinstvena paleta aplikacije.
/// Vrijednosti su preuzete iz postojecih ekrana, ovdje su samo imenovane
/// da se iste boje ne pisu na vise mjesta u razlicitim nijansama.
class AppColors {
  // Pozadine
  static const Color background = Color(0xFF0D1224);
  static const Color navBackground = Color(0xFF111827);
  static const Color navBorder = Color(0xFF1F2937);

  // Povrsine
  static const Color surface = Color(0xFF1A2238);
  static const Color surfaceAlt = Color(0xFF141C31);
  static const Color surfaceMuted = Color(0xFF151D33);
  static const Color surfaceDark = Color(0xFF10192E);
  static const Color iconBubble = Color(0xFF252E48);
  static const Color surfaceSelected = Color(0xFF2B2255);

  // Rubovi
  static const Color border = Color(0xFF2A3661);

  // Brend
  static const Color primary = Color(0xFF7C5CFF);
  static const Color primaryDark = Color(0xFF5511B8);
  static const Color primaryLight = Color(0xFFB99CFF);

  // Statusi
  static const Color success = Color(0xFF00D26A);
  static const Color warning = Colors.orangeAccent;
  static const Color danger = Colors.redAccent;

  // Tekst
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textMuted = Colors.white54;
  static const Color textFaint = Colors.white38;

  /// Boja postotka pogodaka, koristi se na vise ekrana.
  static Color forPercentage(int value) {
    if (value >= 65) return success;
    if (value >= 50) return warning;

    return danger;
  }
}
