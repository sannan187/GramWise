import 'package:flutter/material.dart';

/// Defines the complete design system tokens and constants for GramWise.
class AppConstants {
  // Static App Strings
  static const String appName = 'GramWise';
  static const String defaultCurrencyCode = 'INR';
  static const String defaultCurrencySymbol = '₹';
  static const String defaultCurrencyName = 'Indian Rupee';
  static const String defaultWeightUnit = 'kg';

  // Spacing Scale (dp)
  static const double spacingXXS = 4.0;
  static const double spacingXS = 8.0;
  static const double spacingSM = 12.0;
  static const double spacingMD = 16.0; // Default screen padding
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Corner Radius (dp)
  static const double radiusSM = 8.0;   // Chips, small buttons
  static const double radiusMD = 16.0;  // List tiles, text fields
  static const double radiusLG = 24.0;  // Main calculation cards, modal bottom sheets
  static const double radiusPill = 999.0; // Navigation bar active indicators, rounded action buttons

  // Animation Durations
  static const Duration durationQuick = Duration(milliseconds: 150); // Button presses, chip toggles, switch flips
  static const Duration durationNormal = Duration(milliseconds: 250); // Tab transitions, bottom sheet slides, card expansions
  static const Duration durationSlow = Duration(milliseconds: 400); // Page navigation, complex graph drawing

  // Motion Curves
  static const Curve curveStandard = Curves.easeInOutCubic; // Default smooth transitions
  static const Curve curveDecelerate = Curves.easeOutQuad;  // Entering elements, bottom sheets
  static const Curve curveAccelerate = Curves.easeInQuad;   // Exiting elements, dismissals
  static const Curve curveSpring = Curves.fastLinearToSlowEaseIn; // Premium Apple-like spring snaps
}
