import 'package:flutter/material.dart';
import 'package:xiaomi_weather_clone/app/core/sizes.dart';

class AppTheme {
  ThemeData getTheme() {
    final sizes = AppValues();

    return ThemeData(
      scaffoldBackgroundColor: Colors.white,
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: sizes.displayLarge,
        ),
        displayMedium: TextStyle(
          fontSize: sizes.displayMedium,
        ),
        displaySmall: TextStyle(
          fontSize: sizes.displaySmall,
        ),
        titleMedium: TextStyle(
          fontSize: sizes.titleMedium,
        ),
      ),
    );
  }
}
