import 'package:flutter/material.dart';
import 'package:weather_repository/weather_repository.dart';

// clear,
// rainy,
// cloudy,
// snowy,
// unknown,

class Backgrounds {
   static BoxDecoration getBackground(WeatherCondition condition) {
    return switch (condition) {
      WeatherCondition.clear => clear(),
      WeatherCondition.cloudy => cloudy(),
      WeatherCondition.rainy => rainy(),
      WeatherCondition.snowy => snow(),
      WeatherCondition.unknown => unkonw(),
    };
  }
  
  static BoxDecoration clear() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF6DD5FA),
          Color(0xFF2980B9)
        ],
      ),
    );
  }

  static BoxDecoration cloudy() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFE4E5E6),
          Color(0xFF00416A)
        ],
      ),
    );
  }

  static BoxDecoration rainy() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF141E30),
          Color(0xFF243B55)
        ],
      ),
    );
  }

  static BoxDecoration snow() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF004E92),
          Color(0xFF000428)
        ],
      ),
    );
  }

  static BoxDecoration unkonw() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF928DAB),
          Color(0xFF1F1C2C)
        ],
      ),
    );
  } 

}
