import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // XXI / CGV Color Palette: Sleek Black and Rich Gold
  static const Color primaryGold = Color(0xFFFFC107);
  static const Color lightGold = Color(0xFFFFD54F);
  static const Color darkGold = Color(0xFFFF9800);
  
  static const Color bgBlack = Color(0xFF0F0F12);
  static const Color cardBg = Color(0xFF1E1E24);
  static const Color cardBgLight = Color(0xFF2B2B36);
  
  static const Color textWhite = Color(0xFFEEEEEE);
  static const Color textMuted = Color(0xFFA0A0AB);
  
  static const Color accentRed = Color(0xFFE53935);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentBlue = Color(0xFF2196F3);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgBlack,
      primaryColor: primaryGold,
      colorScheme: const ColorScheme.dark(
        primary: primaryGold,
        onPrimary: Colors.black,
        secondary: lightGold,
        onSecondary: Colors.black,
        surface: cardBg,
        onSurface: textWhite,
        error: accentRed,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(color: textWhite, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.poppins(color: textWhite, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.poppins(color: textWhite),
        bodyMedium: GoogleFonts.poppins(color: textMuted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgBlack,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          color: primaryGold,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
        iconTheme: const IconThemeData(color: primaryGold),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 4,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: primaryGold.withOpacity(0.15), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: Colors.black,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGold,
          side: const BorderSide(color: primaryGold, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBgLight,
        hintStyle: TextStyle(color: textMuted.withOpacity(0.6)),
        labelStyle: const TextStyle(color: primaryGold),
        prefixIconColor: primaryGold,
        suffixIconColor: primaryGold,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGold, width: 2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: primaryGold, width: 1),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardBgLight,
        contentTextStyle: GoogleFonts.poppins(color: textWhite),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: primaryGold, width: 0.8),
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(cardBgLight),
        headingTextStyle: GoogleFonts.poppins(
          color: primaryGold,
          fontWeight: FontWeight.bold,
        ),
        dataRowColor: WidgetStateProperty.all(cardBg),
        dataTextStyle: GoogleFonts.poppins(color: textWhite),
      ),
    );
  }
}
