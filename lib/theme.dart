
import 'package:flutter/material.dart';

// Memora teal and mint color palette
const Color darkNavy = Color(0xFF0D2926);
const Color indigoPurple = Color(0xFF1C504D);
const Color pastelYellow = Color(0xFFF9DF77);
const Color white = Colors.white;

const Color mintBackground = Color(0xFFEAF8F7);
const Color mintCard = Color(0xFFD9F1EF);
const Color tealBorder = Color(0xFF397C77);
const Color mutedText = Color(0xFF718582);

ThemeData memoraTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: white,
    canvasColor: white,
    cardColor: mintBackground,

    colorScheme: const ColorScheme.light(
      primary: indigoPurple,
      onPrimary: white,
      secondary: pastelYellow,
      onSecondary: darkNavy,
      surface: white,
      onSurface: darkNavy,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      foregroundColor: darkNavy,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: darkNavy,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: indigoPurple,
      selectedItemColor: white,
      unselectedItemColor: Colors.white70,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),

    cardTheme: CardThemeData(
      color: mintBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: tealBorder,
          width: 1.5,
        ),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: indigoPurple,
        foregroundColor: white,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: indigoPurple,
        side: const BorderSide(color: tealBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: mintBackground,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: tealBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: tealBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: indigoPurple,
          width: 2,
        ),
      ),
      labelStyle: const TextStyle(color: indigoPurple),
      hintStyle: const TextStyle(color: mutedText),
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: darkNavy,
        fontSize: 18,
      ),
      bodyMedium: TextStyle(
        color: darkNavy,
        fontSize: 16,
      ),
      titleLarge: TextStyle(
        color: darkNavy,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: darkNavy,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
