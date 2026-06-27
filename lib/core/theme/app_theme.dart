import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Defines the Material 3 Light and Dark themes matching the single source of truth design perfectly.
class AppTheme {
  // Emerald Green primary accent from the design
  static const Color emeraldGreen = Color(0xFF0B8544);
  
  // Common clean, geometric typography adhering to M3 scaling
  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.bold, letterSpacing: -0.25),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.bold, letterSpacing: 0.0),
    displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: 0.0),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: 0.0),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: 0.0),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: 0.0),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: 0.0),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
  );

  /// Pixel-perfect Light Theme matching the single source of truth
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: emeraldGreen,
      onPrimary: Colors.white,
      secondary: Color(0xFF333333),
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      surfaceContainerHighest: Color(0xFFE8E8EC), // Grey card background
      onSurfaceVariant: Color(0xFF555555),
      outline: Color(0xFFD5D5D8),
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F5F7), // Soft off-white background
    textTheme: _textTheme,
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32.0),
        side: const BorderSide(color: Color(0xFFEBEBEF), width: 1),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: const Color(0xFFF5F5F7),
      indicatorColor: emeraldGreen,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _textTheme.labelMedium!.copyWith(color: emeraldGreen, fontWeight: FontWeight.bold);
        }
        return _textTheme.labelMedium!.copyWith(color: const Color(0xFF757575));
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Colors.white, size: 24);
        }
        return const IconThemeData(color: Color(0xFF757575), size: 24);
      }),
    ),
  );

  /// Pixel-perfect Dark Theme matching the single source of truth
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: emeraldGreen,
      onPrimary: Colors.white,
      secondary: Color(0xFFCCCCCC),
      onSecondary: Colors.black,
      surface: Color(0xFF1C1C1E),
      onSurface: Colors.white,
      surfaceContainerHighest: Color(0xFF2C2C2E), // Grey card background in dark mode
      onSurfaceVariant: Color(0xFFAFAFAF),
      outline: Color(0xFF3A3A3C),
    ),
    scaffoldBackgroundColor: const Color(0xFF0D0D0D), // Deep dark background
    textTheme: _textTheme,
    cardTheme: CardThemeData(
      color: const Color(0xFF1C1C1E),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32.0),
        side: const BorderSide(color: Color(0xFF2C2C2E), width: 1),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: const Color(0xFF0D0D0D),
      indicatorColor: emeraldGreen,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _textTheme.labelMedium!.copyWith(color: emeraldGreen, fontWeight: FontWeight.bold);
        }
        return _textTheme.labelMedium!.copyWith(color: const Color(0xFF8A8A8A));
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Colors.white, size: 24);
        }
        return const IconThemeData(color: Color(0xFF8A8A8A), size: 24);
      }),
    ),
  );
}
