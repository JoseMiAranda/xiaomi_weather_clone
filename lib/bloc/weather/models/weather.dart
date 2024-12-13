import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:xiaomi_weather_clone/bloc/search/models/location.dart';
import 'package:xiaomi_weather_clone/bloc/weather/models/aqi.dart';
import 'package:weather_repository/weather_repository.dart'
    hide Weather, Location, Aqi;
import 'package:weather_repository/weather_repository.dart'
    as weather_repository;

part 'weather.g.dart';

@JsonSerializable()
class Weather extends Equatable {
  const Weather({
    this.id,
    required this.lastUpdated,
    required this.location,
    required this.current,
    required this.daily,
  });

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);

  factory Weather.fromRepository(weather_repository.Weather weather) {
    return Weather(
      id: weather.id,
      lastUpdated: weather.lastUpdated,
      location: Location.fromRepository(weather.location),
      current: Current.fromRepository(weather.current),
      daily: weather.daily.map(Daily.fromRepository).toList(),
    );
  }

  Weather copyWith({
    String? id,
    DateTime? lastUpdated,
    Location? location,
    Current? current,
    List<Daily>? daily,
  }) =>
      Weather(
        id: id ?? this.id,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        location: location ?? this.location,
        current: current ?? this.current,
        daily: daily ?? this.daily,
      );

  final String? id;
  final DateTime lastUpdated;
  final Location location;
  final Current current;
  final List<Daily> daily;

  Map<String, dynamic> toJson() => _$WeatherToJson(this);

  static weather_repository.Weather toRepository(Weather weather) =>
      weather_repository.Weather(
        id: weather.id,
        lastUpdated: weather.lastUpdated,
        location: weather.location.toRepository(),
        current: weather.current.toRepository(),
        daily: weather.daily.map((d) => d.toRepository()).toList(),
      );

  @override
  List<Object> get props => [location, current, daily];
}

@JsonSerializable()
class Current extends Equatable {
  const Current({
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.feelsLikeTemperature,
    required this.aqi,
  });

  factory Current.fromJson(Map<String, dynamic> json) =>
      _$CurrentFromJson(json);

  factory Current.fromRepository(weather_repository.Current current) {
    return Current(
      temperature: current.temperature,
      condition: current.condition,
      humidity: current.humidity,
      feelsLikeTemperature: current.feelsLikeTemperature,
      aqi: Aqi.fromRepository(current.aqi),
    );
  }

  Current copyWith({
    double? temperature,
    WeatherCondition? condition,
    int? humidity,
    double? feelsLikeTemperature,
    Aqi? aqi,
  }) =>
      Current(
        temperature: temperature ?? this.temperature,
        condition: condition ?? this.condition,
        humidity: humidity ?? this.humidity,
        feelsLikeTemperature: feelsLikeTemperature ?? this.feelsLikeTemperature,
        aqi: aqi ?? this.aqi,
      );

  final double temperature;
  final WeatherCondition condition;
  final int humidity;
  final double feelsLikeTemperature;
  final Aqi aqi;

  Map<String, dynamic> toJson() => _$CurrentToJson(this);

  weather_repository.Current toRepository() => weather_repository.Current(
        temperature: temperature,
        condition: condition,
        humidity: humidity,
        feelsLikeTemperature: feelsLikeTemperature,
        aqi: aqi.toRepository(),
      );

  @override
  List<Object> get props => [
        temperature,
        condition
      ];
}

@JsonSerializable()
class Hourly extends Equatable {
  const Hourly({
    required this.time,
    required this.condition,
    required this.temperature,
    required this.windSpeed,
    required this.windDirection,
  });

  factory Hourly.fromJson(Map<String, dynamic> json) =>
      _$HourlyFromJson(json);

  factory Hourly.fromRepository(weather_repository.Hourly hourly) {
    return Hourly(
      time: hourly.time,
      condition: hourly.condition,
      temperature: hourly.temperature,
      windSpeed: hourly.windSpeed,
      windDirection: hourly.windDirection,
    );
  }

  Hourly copyWith({
    DateTime? time,
    WeatherCondition? condition,
    double? temperature,
    double? windSpeed,
    int? windDirection,
  }) =>
      Hourly(
        time: time ?? this.time,
        condition: condition ?? this.condition,
        temperature: temperature ?? this.temperature,
        windSpeed: windSpeed ?? this.windSpeed,
        windDirection: windDirection ?? this.windDirection,
      );

  final DateTime time;
  final WeatherCondition condition;
  final double temperature;
  final double windSpeed;
  final int windDirection;

  Map<String, dynamic> toJson() => _$HourlyToJson(this);

  weather_repository.Hourly toRepository() => weather_repository.Hourly(
        time: time,
        condition: condition,
        temperature: temperature,
        windSpeed: windSpeed,
        windDirection: windDirection,
      );

  @override
  List<Object?> get props => [time, temperature, windSpeed, windDirection];
}

@JsonSerializable()
class Daily extends Equatable {
  const Daily({
    required this.time,
    required this.hourly,
    required this.maxTemperature,
    required this.minTemperature,
    required this.maxWindSpeed,
    required this.maxWindDirection,
    required this.precipitationProbability,
    required this.maxSeaPressure,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
  });

  factory Daily.fromJson(Map<String, dynamic> json) => _$DailyFromJson(json);

  factory Daily.fromRepository(weather_repository.Daily daily) {
    return Daily(
      time: daily.time,
      hourly: daily.hourly.map((hourly) => Hourly.fromRepository(hourly)).toList(),
      maxTemperature: daily.maxTemperature,
      minTemperature: daily.minTemperature,
      maxWindSpeed: daily.maxWindSpeed,
      maxWindDirection: daily.maxWindDirection,
      precipitationProbability: daily.precipitationProbability,
      uvIndex: daily.uvIndex,
      maxSeaPressure: daily.maxSeaPressure,
      sunrise: daily.sunrise,
      sunset: daily.sunset,
    );
  }

  Daily copyWith({
    DateTime? time,
    List<Hourly>? hourly,
    double? maxTemperature,
    double? minTemperature,
    double? maxWindSpeed,
    int? maxWindDirection,
    int? precipitationProbability,
    double? maxSeaPressure,
    int? uvIndex,
    DateTime? sunrise,
    DateTime? sunset,
  }) =>
      Daily(
        time: time ?? this.time,
        hourly: hourly ?? this.hourly,
        maxTemperature: maxTemperature ?? this.maxTemperature,
        minTemperature: minTemperature ?? this.minTemperature,
        maxWindSpeed: maxWindSpeed ?? this.maxWindSpeed,
        maxWindDirection: maxWindDirection ?? this.maxWindDirection,
        precipitationProbability: precipitationProbability ?? this.precipitationProbability,
        maxSeaPressure: maxSeaPressure ?? this.maxSeaPressure,
        uvIndex: uvIndex ?? this.uvIndex,
        sunrise: sunrise ?? this.sunrise,
        sunset: sunset ?? this.sunset,
      );

  final DateTime time;
  final List<Hourly> hourly;
  final double maxTemperature;
  final double minTemperature;
  final double maxWindSpeed;
  final int maxWindDirection;
  final int precipitationProbability;
  final double maxSeaPressure;
  final int uvIndex;
  final DateTime sunrise;
  final DateTime sunset;

  Map<String, dynamic> toJson() => _$DailyToJson(this);

  weather_repository.Daily toRepository() => weather_repository.Daily(
        time: time,
        hourly: hourly.map((h) => h.toRepository()).toList(),
        maxTemperature: maxTemperature,
        minTemperature: minTemperature,
        maxWindSpeed: maxWindSpeed,
        maxWindDirection: maxWindDirection,
        precipitationProbability: precipitationProbability,
        maxSeaPressure: maxSeaPressure,
        uvIndex: uvIndex,
        sunrise: sunrise,
        sunset: sunset,
      );

  @override
  List<Object?> get props => [
        time,
        sunrise,
        sunset,
      ];
}
