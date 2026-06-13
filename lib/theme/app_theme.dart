import 'package:flutter/material.dart';

/// الهوية البصرية للتطبيق — لون أخضر هادئ وخلفية فاتحة مريحة.
class AppTheme {
  static const Color primaryGreen = Color(0xFF2E7D5B);
  static const Color lightGreen = Color(0xFFE6F2EC);
  static const Color background = Color(0xFFF6F8F6);
  static const Color cardColor = Colors.white;
  static const Color textDark = Color(0xFF1F2D27);
  static const Color textMuted = Color(0xFF6B7B73);
  static const Color accentGold = Color(0xFFB8860B);

  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
      ),
      scaffoldBackgroundColor: background,
      fontFamily: 'Cairo', // خط عربي إن توفّر، وإلا الخط الافتراضي
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
