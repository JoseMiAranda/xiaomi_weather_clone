import 'package:flutter/material.dart';
import 'package:xiaomi_weather_clone/app/extensions/context_extension.dart';
import 'package:weather_repository/weather_repository.dart' hide Weather;

String getNameAqiCondition(BuildContext context, AqiCondition condition) {
  return switch (condition) {
    AqiCondition.good => context.localizations.good,
    AqiCondition.fair => context.localizations.fair,
    AqiCondition.moderate => context.localizations.moderate,
    AqiCondition.poor => context.localizations.poor,
    AqiCondition.veryPoor => context.localizations.veryPoor,
    AqiCondition.extremelyPoor => context.localizations.extremelyPoor,
    _ => context.localizations.unknown,
  };
}

IconData getAqiIcon(AqiCondition condition) {
  return switch (condition) {
    AqiCondition.poor => Icons.masks,
    AqiCondition.veryPoor => Icons.masks,
    AqiCondition.extremelyPoor => Icons.masks,
    _ => Icons.energy_savings_leaf_outlined,
  };
}

Color getAqiColor(AqiCondition condition) {
  return switch (condition) {
    AqiCondition.fair => const Color(0xFF50CCAB),
    AqiCondition.moderate => const Color(0xFF50CCAB),
    AqiCondition.poor => const Color(0xFF50CCAB),
    AqiCondition.veryPoor => const Color(0xFF50CCAB),
    AqiCondition.extremelyPoor => const Color(0xFF50CCAB),
    _ => const Color(0xFF4FF0E5),
  };
}

String getNameCondition(BuildContext context, WeatherCondition condition) {
  return switch (condition) {
    WeatherCondition.clear => context.localizations.cleared,
    WeatherCondition.cloudy => context.localizations.cloudy,
    WeatherCondition.rainy => context.localizations.rainy,
    WeatherCondition.snowy => context.localizations.snowy,
    _ => context.localizations.unknown,
  };
}

Stream<DateTime> updateSun() {
  return Stream<DateTime>.periodic(
    const Duration(minutes: 1),
    (_) => DateTime.now(),
  );
}

Stream<DateTime> updateWeather() async* {
  await Future.delayed(const Duration(seconds: 1));
  yield DateTime.now();

  yield* Stream<DateTime>.periodic(
    const Duration(minutes: 5),
    (_) => DateTime.now(),
  );
}
