import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weather_units.g.dart';

enum TemperatureUnits { fahrenheit, celsius }

enum WindSpeedUnits { kph, mph }

enum PressureUnits { hpa, mbar }

extension TemperatureUnitsX on TemperatureUnits {
  bool get isFahrenheit => this == TemperatureUnits.fahrenheit;
  bool get isCelsius => this == TemperatureUnits.celsius;
  String get unit => switch(this) {
    TemperatureUnits.celsius => 'ºC',
    _ => 'ºF'
  };
}

extension WindSpeedUnitsX on WindSpeedUnits {
  bool get isKph => this == WindSpeedUnits.kph;
  bool get isMph => this == WindSpeedUnits.mph;
  String get unit => switch(this) {
    WindSpeedUnits.kph => 'km/h',
    _ => 'mph'
  };
}

extension PressureUnitsX on PressureUnits {
  bool get isKpa => this == PressureUnits.hpa;
  bool get isBar => this == PressureUnits.mbar;
  String get unit => switch(this) {
    PressureUnits.hpa => 'hPa',
    _ => 'mbar'
  };
}

@JsonSerializable()
class WeatherUnits extends Equatable {
  const WeatherUnits({
    required this.temperatureUnits,
    required this.windSpeedUnits,
    required this.pressureUnits,
  });

  factory WeatherUnits.fromJson(Map<String, dynamic> json) =>
      _$WeatherUnitsFromJson(json);

  const WeatherUnits.empty()
      : temperatureUnits = TemperatureUnits.celsius,
        windSpeedUnits = WindSpeedUnits.kph,
        pressureUnits = PressureUnits.hpa;

  WeatherUnits copyWith({
    TemperatureUnits? temperatureUnits,
    WindSpeedUnits? windSpeedUnits,
    PressureUnits? pressureUnits,
  }) =>
      WeatherUnits(
        temperatureUnits: temperatureUnits ?? this.temperatureUnits,
        windSpeedUnits: windSpeedUnits ?? this.windSpeedUnits,
        pressureUnits: pressureUnits ?? this.pressureUnits,
      );

  final TemperatureUnits temperatureUnits;
  final WindSpeedUnits windSpeedUnits;
  final PressureUnits pressureUnits;

  Map<String, dynamic> toJson() => _$WeatherUnitsToJson(this);

  @override
  List<Object?> get props => [temperatureUnits, windSpeedUnits, pressureUnits];
}
