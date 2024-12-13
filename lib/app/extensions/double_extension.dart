extension TemperatureConversion on double {
  double toFahrenheit() => double.parse(((this * 9 / 5) + 32).toStringAsFixed(2));
  double toCelsius() => double.parse(((this - 32) * 5 / 9).toStringAsFixed(2));
}

extension WindSpeedConversion on double {
  double toKph() => double.parse((this / 0.621371).toStringAsFixed(2));
  double toMph() => double.parse((this * 0.621371).toStringAsFixed(2));
}
