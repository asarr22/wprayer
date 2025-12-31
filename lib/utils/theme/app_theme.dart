import 'package:flutter/material.dart';
import 'package:wprayer/utils/constants/colors.dart';
import 'package:wprayer/utils/theme/text_theme.dart';

class WAppTheme {
  WAppTheme._();

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: WColors.primary,
    colorScheme: const ColorScheme.light(primary: WColors.primary),
    scaffoldBackgroundColor: WColors.backgroundLight,
    appBarTheme: const AppBarTheme(backgroundColor: WColors.backgroundLight),
    textTheme: WTextTheme.lightTextTheme,
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: WColors.primary,
    colorScheme: const ColorScheme.dark(primary: WColors.primary),
    scaffoldBackgroundColor: WColors.backgroundDark,
    appBarTheme: const AppBarTheme(backgroundColor: WColors.backgroundDark),
    textTheme: WTextTheme.darkTextTheme,
  );
}
