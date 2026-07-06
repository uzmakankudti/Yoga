import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.bg,
      onSurface: AppColors.ink,
    ),
    scaffoldBackgroundColor: AppColors.bg,
    fontFamily: '.SF Pro Text',

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.ink,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w600,
        letterSpacing: 0.5, color: AppColors.ink,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        elevation: 0,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.line, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.line, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      labelStyle: const TextStyle(fontSize: 13, color: AppColors.muted, letterSpacing: 0.5),
      hintStyle: const TextStyle(fontSize: 13, color: AppColors.placeholder),
    ),

    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      margin: EdgeInsets.zero,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.muted,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: TextStyle(fontSize: 10, letterSpacing: 0.5),
      unselectedLabelStyle: TextStyle(fontSize: 10, letterSpacing: 0.5),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.line,
      space: 0,
      thickness: 1,
    ),

    textTheme: const TextTheme(
      displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w300, letterSpacing: 0,   color: AppColors.ink),
      displayMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w400, letterSpacing: 0.5, color: AppColors.ink),
      displaySmall:  TextStyle(fontSize: 22, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: AppColors.ink),
      headlineMedium:TextStyle(fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: AppColors.ink),
      headlineSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: AppColors.ink),
      titleLarge:    TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: AppColors.ink),
      titleMedium:   TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: AppColors.ink),
      bodyLarge:     TextStyle(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.3, color: AppColors.ink),
      bodyMedium:    TextStyle(fontSize: 13, fontWeight: FontWeight.w400, letterSpacing: 0.3, color: AppColors.ink),
      bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.5, color: AppColors.muted),
      labelLarge:    TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.0, color: AppColors.muted),
    ),
  );
}
