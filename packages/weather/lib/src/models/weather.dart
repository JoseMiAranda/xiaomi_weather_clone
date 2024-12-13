import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather/weather.dart';

part 'weather.g.dart';

/// {@template weather_condition_model}
/// States of [Weather]
/// {@endtemplate}
enum WeatherCondition {
  clear,
  rainy,
  cloudy,
  snowy,
  unknown,
}

/// {@template weather_model}
/// A single `weather` item.
///
/// Contains a [id], [lastUpdated], [location], [current] and [daily]
///
/// [Weather]s are immutable , in addition to
/// being serialized and deserialized using [toJson] and [fromJson]
/// respectively.
/// {@endtemplate}
@immutable
@JsonSerializable()
class Weather extends Equatable {
  /// {@macro weather_model}
  const Weather({
    this.id,
    required this.lastUpdated,
    required this.location,
    required this.current,
    required this.daily,
  });

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherToJson(this);

  /// The id of the weather
  ///
  /// Can be null
  final String? id;

  /// The last updated time of the weather
  final DateTime lastUpdated;

  /// The location of the weather
  final Location location;

  /// The current weather
  final Current current;

  /// The daily weather that contains the hourly weather
  final List<Daily> daily;

  @override
  List<Object> get props => [
        current,
        daily,
      ];
}

/// {@template hourly_model}
/// A single `hourly` item.
///
/// Contains a [time], [condition], [temperature], [windSpeed] and [windDirection]
///
/// [Hourly]s are immutable , in addition to
/// being serialized and deserialized using [toJson] and [fromJson]
/// respectively.
/// {@endtemplate}
@immutable
@JsonSerializable()
class Hourly extends Equatable {
  /// {@macro hourly_model}
  const Hourly({
    required this.time,
    required this.condition,
    required this.temperature,
    required this.windSpeed,
    required this.windDirection,
  });

  factory Hourly.fromJson(Map<String, dynamic> json) => _$HourlyFromJson(json);

  Map<String, dynamic> toJson() => _$HourlyToJson(this);

  /// The time of the hourly weather
  final DateTime time;

  /// The condition of the hourly weather
  final WeatherCondition condition;

  /// The temperature of the hourly weather
  final double temperature;

  /// The wind speed of the hourly weather
  final double windSpeed;

  /// The wind direction of the hourly weather
  final int windDirection;

  @override
  List<Object?> get props =>
      [time, condition, temperature, windSpeed, windDirection];
}

/// {@template daily_model}
/// A single `daily` item.
///
/// Contains a [time], [hourly], [sunrise], [sunset], [maxTemperature], [minTemperature], [maxWindSpeed], [maxWindDirection], [maxSeaPressure], [uvIndex] and [precipitationProbability]
///
/// [Daily]s are immutable , in addition to
/// being serialized and deserialized using [toJson] and [fromJson]
/// respectively.
/// {@endtemplate}
@immutable
@JsonSerializable()
class Daily extends Equatable {
  /// {@macro daily_model}
  const Daily({
    required this.time,
    required this.hourly,
    required this.sunrise,
    required this.sunset,
    required this.maxTemperature,
    required this.minTemperature,
    required this.maxWindSpeed,
    required this.maxWindDirection,
    required this.maxSeaPressure,
    required this.uvIndex,
    required this.precipitationProbability,
  });

  factory Daily.fromJson(Map<String, dynamic> json) => _$DailyFromJson(json);

  Map<String, dynamic> toJson() => _$DailyToJson(this);

  /// The time of the daily weather
  final DateTime time;

  /// The hourly weather that contains the hourly weather
  final List<Hourly> hourly;

  /// The sunrise time of the daily weather
  final DateTime sunrise;

  /// The sunset time of the daily weather
  final DateTime sunset;

  /// The max temperature of the daily weather
  final double maxTemperature;

  /// The min temperature of the daily weather
  final double minTemperature;

  /// The max wind speed of the daily weather
  final double maxWindSpeed;

  /// The max wind direction of the daily weather
  final int maxWindDirection;

  /// The max sea pressure of the daily weather
  final double maxSeaPressure;

  /// The uv index of the daily weather
  final int uvIndex;

  /// The precipitation probability of the daily weather
  final int precipitationProbability;

  @override
  List<Object?> get props => [
        time,
        hourly,
        sunrise,
        sunset,
        maxTemperature,
        minTemperature,
        maxWindSpeed,
        maxWindDirection,
        maxSeaPressure,
        uvIndex,
        precipitationProbability
      ];
}

/// {@template current_model}
/// A single `current` item.
///
/// Contains a [temperature], [humidity], [feelsLikeTemperature], [condition] and [aqi]
///
/// [Current]s are immutable , in addition to
/// being serialized and deserialized using [toJson] and [fromJson]
/// respectively.
/// {@endtemplate}
@immutable
@JsonSerializable()
class Current extends Equatable {
  const Current({
    required this.temperature,
    required this.humidity,
    required this.feelsLikeTemperature,
    required this.condition,
    required this.aqi,
  });

  factory Current.fromJson(Map<String, dynamic> json) =>
      _$CurrentFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentToJson(this);

  /// The temperature of the current weather
  final double temperature;

  /// The humidity of the current weather
  final int humidity;

  /// The feels like temperature of the current weather
  final double feelsLikeTemperature;

  /// The condition of the current weather
  final WeatherCondition condition;

  /// The aqi of the current weather
  final Aqi aqi;

  @override
  List<Object> get props => [temperature, condition, aqi];
}
