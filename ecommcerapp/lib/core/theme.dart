import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF6B4EE6); // Trendy Purple
  static const Color accentColor = Color(0xFF9E77ED);
  static const Color backgroundColor = Color(0xFFF9FAFB);
  static const Color darkBackgroundColor = Color(0xFF111827);
  static const Color cardColor = Colors.white;
  static const Color darkCardColor = Color(0xFF1F2937);
  static const Color textColor = Color(0xFF111827);
  static const Color darkTextColor = Colors.white;
  static const Color greyColor = Color(0xFF6B7280);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: accentColor,
      surface: cardColor,
    ),
    textTheme: GoogleFonts.outfitTextTheme(
      const TextTheme(
        headlineMedium: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textColor),
        bodyMedium: TextStyle(color: greyColor),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: textColor),
      centerTitle: true,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    cardColor: darkCardColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: accentColor,
      surface: darkCardColor,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.outfitTextTheme(
      const TextTheme(
        headlineMedium: TextStyle(color: darkTextColor, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: darkTextColor, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: darkTextColor),
        bodyMedium: TextStyle(color: Colors.white70),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: darkTextColor),
      centerTitle: true,
    ),
  );
}
