import 'package:flutter/material.dart';

class NexusColors {
  static const Color background     = Color(0xFF060B14);
  static const Color surface        = Color(0xFF0F172A);
  static const Color surfaceVariant = Color(0xFF1E293B);
  static const Color border         = Color(0xFF334155);
  static const Color primary        = Color(0xFF6366F1);
  static const Color primaryVar     = Color(0xFF8B5CF6);
  static const Color accent         = Color(0xFF10B981);
  static const Color warning        = Color(0xFFF59E0B);
  static const Color error          = Color(0xFFEF4444);
  static const Color pink           = Color(0xFFEC4899);
  static const Color cyan           = Color(0xFF06B6D4);
  static const Color textPrimary    = Color(0xFFF1F5F9);
  static const Color textSecondary  = Color(0xFF94A3B8);
  static const Color textMuted      = Color(0xFF475569);
}

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: NexusColors.background,
    fontFamily: 'Roboto',
    colorScheme: const ColorScheme.dark(
      background: NexusColors.background,
      surface: NexusColors.surface,
      primary: NexusColors.primary,
      secondary: NexusColors.primaryVar,
      error: NexusColors.error,
      onBackground: NexusColors.textPrimary,
      onSurface: NexusColors.textPrimary,
      onPrimary: Colors.white,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: NexusColors.textPrimary, letterSpacing: -0.5),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: NexusColors.textPrimary, letterSpacing: -0.3),
      titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: NexusColors.textPrimary),
      titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: NexusColors.textPrimary),
      bodyLarge: TextStyle(fontSize: 14, color: NexusColors.textPrimary, height: 1.5),
      bodyMedium: TextStyle(fontSize: 13, color: NexusColors.textSecondary, height: 1.4),
      labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: NexusColors.textMuted, letterSpacing: 0.8),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: NexusColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: NexusColors.textSecondary),
    ),
    cardTheme: CardTheme(
      color: NexusColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: NexusColors.border),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: NexusColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: NexusColors.surfaceVariant,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: NexusColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: NexusColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: NexusColors.primary, width: 1.5)),
      hintStyle: const TextStyle(color: NexusColors.textMuted, fontSize: 13),
      contentPadding: const EdgeInsets.all(14),
    ),
    dividerTheme: const DividerThemeData(color: NexusColors.border, thickness: 1, space: 0),
    useMaterial3: true,
  );
}
