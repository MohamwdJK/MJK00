import 'package:flutter/material.dart';

class LuxuryTheme {
  static const Color pitchBlack = Color(0xFF0D0D0D);
  static const Color charcoal = Color(0xFF1A1A1A);
  static const Color metallicGold = Color(0xFFD4AF37);
  static const Color brightGold = Color(0xFFFFD700);
  static const Color antiqueGold = Color(0xFF996515);
  static const Color textWhite = Color(0xFFF5F5F5);
  static const Color textMuted = Color(0xFF9E9E9E);
  static const Color emeraldSuccess = Color(0xFF2E7D32);
  static const Color crimsonAlert = Color(0xFFC62828);

  static const LinearGradient goldGradient = LinearGradient(
    colors: [
      Color(0xFFFFF2A1),
      brightGold,
      metallicGold,
      antiqueGold,
      metallicGold,
    ],
    stops: [0.0, 0.25, 0.5, 0.8, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkSurfaceGradient = LinearGradient(
    colors: [Color(0xFF222222), Color(0xFF141414)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: pitchBlack,
      primaryColor: metallicGold,
      colorScheme: const ColorScheme.dark(
        primary: metallicGold,
        secondary: brightGold,
        surface: charcoal,
        onPrimary: pitchBlack,
        onSecondary: pitchBlack,
        onSurface: textWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: pitchBlack,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: metallicGold),
        titleTextStyle: TextStyle(
          color: brightGold,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: charcoal,
        labelStyle: const TextStyle(color: metallicGold),
        hintStyle: const TextStyle(color: textMuted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: metallicGold.withOpacity(0.35), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: brightGold, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: metallicGold,
          foregroundColor: pitchBlack,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      cardTheme: CardThemeData(
        color: charcoal,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: metallicGold.withOpacity(0.3), width: 1),
        ),
      ),
    );
  }
}
