import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData theme() {
    const primary = Color(0xFF003B95);
    const onPrimary = Colors.white;
    const background = Color(0xFFF5F7FB);
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      onPrimary: onPrimary,
      background: background,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
        },
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: onPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        surfaceTintColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF7F7F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: const Color(0xFFE6F0FF),
        backgroundColor: Colors.white,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: StadiumBorder(side: BorderSide(color: Colors.grey.shade300)),
        backgroundColor: const Color(0xFFF4F5F7),
        selectedColor: const Color(0xFFE6F0FF),
        labelStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.1),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(height: 1.4),
      ),
    );
  }
}
