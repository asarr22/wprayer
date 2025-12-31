import 'package:flutter/material.dart';
import 'package:wprayer/utils/constants/colors.dart';

class WTextTheme {
  WTextTheme._();

  // Helper method to create text style with fallback
  static TextStyle _textStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: 'Roboto', // System font fallback
    );
  }

  static TextTheme lightTextTheme = TextTheme(
    headlineLarge: _textStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      color: WColors.textDark,
    ),
    headlineMedium: _textStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      color: WColors.textDark,
    ),
    headlineSmall: _textStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: WColors.textDark,
    ),
    titleLarge: _textStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: WColors.textDark,
    ),
    titleMedium: _textStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      color: WColors.textDark,
    ),
    titleSmall: _textStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
      color: WColors.textDark,
    ),
    bodyLarge: _textStyle(
      fontSize: 14.5,
      fontWeight: FontWeight.w500,
      color: WColors.textDark,
    ),
    bodyMedium: _textStyle(
      fontSize: 14.5,
      fontWeight: FontWeight.normal,
      color: WColors.textDark,
    ),
    bodySmall: _textStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: WColors.textDark.withValues(alpha: 0.5),
    ),
    labelLarge: _textStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.bold,
      color: WColors.textDark,
    ),
    labelMedium: _textStyle(
      fontSize: 13.0,
      fontWeight: FontWeight.normal,
      color: WColors.textDark,
    ),
    labelSmall: _textStyle(
      fontSize: 11.5,
      fontWeight: FontWeight.normal,
      color: WColors.textDark,
    ),
  );

  static TextTheme darkTextTheme = TextTheme(
    headlineLarge: _textStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      color: WColors.textLight,
    ),
    headlineMedium: _textStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      color: WColors.textLight,
    ),
    headlineSmall: _textStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: WColors.textLight,
    ),
    titleLarge: _textStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: WColors.textLight,
    ),
    titleMedium: _textStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      color: WColors.textLight,
    ),
    titleSmall: _textStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
      color: WColors.textLight,
    ),
    bodyLarge: _textStyle(
      fontSize: 14.5,
      fontWeight: FontWeight.w500,
      color: WColors.textLight,
    ),
    bodyMedium: _textStyle(
      fontSize: 14.5,
      fontWeight: FontWeight.normal,
      color: WColors.textLight,
    ),
    bodySmall: _textStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: WColors.textLight.withValues(alpha: 0.7),
    ),
    labelLarge: _textStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: WColors.textLight,
    ),
    labelMedium: _textStyle(
      fontSize: 13.0,
      fontWeight: FontWeight.normal,
      color: WColors.textLight,
    ),
    labelSmall: _textStyle(
      fontSize: 11.5,
      fontWeight: FontWeight.normal,
      color: WColors.textLight,
    ),
  );
}
