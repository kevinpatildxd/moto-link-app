import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color bgColor = Color(0xFF000000);
  static const Color cardBg = Color(0xFF121212);
  static const Color primary = Color(0xFF39FF14); // Neon Green
  static const Color secondary = Color(0xFFFF5F1F); // Neon Orange
  static const Color alert = Color(0xFFFF0033);
  static const Color textMain = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFA0A0A0);
  static const Color borderColor = Color(0xFF333333);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgColor,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: cardBg,
        background: bgColor,
        error: alert,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: textMain,
        displayColor: textMain,
      ),
      useMaterial3: true,
    );
  }
}
