import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:hive_weather_api/src/models/hive_aqi.dart';
import 'package:hive_weather_api/src/models/hive_location.dart';

part 'hive_weather.g.dart';

@HiveType(typeId: 1)
enum HiveWeatherCondition {
  @HiveField(0)
  clear,

  @HiveField(1)
  rainy,

  @HiveField(2)
  cloudy,

  @HiveField(3)
  snowy,

  @HiveField(4)
  unknown,
}

@HiveType(typeId: 2)
class HiveWeather extends Equatable {
  const HiveWeather({
    required this.id,
    required this.lastUpdated,
    required this.location,
    required this.current,
    required this.dailyForecast,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime lastUpdated;

  @HiveField(2)
  final HiveLocation location;

  @HiveField(3)
  final HiveCurrent current;

  @HiveField(4)
  final List<HiveDailyForecast> dailyForecast;

  @override
  List<Object?> get props =>
      [id, lastUpdated, location, current, dailyForecast];
}

@HiveType(typeId: 3)
class HiveHourlyForecast extends Equatable {
  const HiveHourlyForecast({
    required this.time,
    required this.condition,
    required this.temperature,
    required this.windSpeed,
    required this.windDirection,
  });

  @HiveField(0)
  final DateTime time;

  @HiveField(1)
  final HiveWeatherCondition condition;

  @HiveField(2)
  final double temperature;

  @HiveField(3)
  final double windSpeed;

  @HiveField(4)
  final int windDirection;

  @override
  List<Object?> get props => [time, temperature, windSpeed, windDirection];
}

@HiveType(typeId: 4)
class HiveDailyForecast extends Equatable {
  const HiveDailyForecast({
    required this.time,
    required this.hourly,
    required this.maxTemperature,
    required this.minTemperature,
    required this.windSpeed,
    required this.windDirection,
    required this.precipitationProbability,
    required this.maxSeaPressure,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
  });

  @HiveField(0)
  final DateTime time;

  @HiveField(1)
  final List<HiveHourlyForecast> hourly;

  @HiveField(2)
  final double maxTemperature;

  @HiveField(3)
  final double minTemperature;

  @HiveField(4) 
  final double windSpeed;

  @HiveField(5)
  final int windDirection;

  @HiveField(6)
  final int precipitationProbability;  

  @HiveField(7)
  final int uvIndex;

  @HiveField(8)
  final double maxSeaPressure;

  @HiveField(9)
  final DateTime sunrise;

  @HiveField(10)
  final DateTime sunset;

  @override
  List<Object?> get props =>
      [time, hourly, maxTemperature, minTemperature, sunrise, sunset];
}

@HiveType(typeId: 5)
class HiveCurrent extends Equatable {
  const HiveCurrent({
    required this.temperature,
    required this.condition,
    required this.aqi,
    required this.humidity,
    required this.feelsLikeTemperature,
  });

  @HiveField(0)
  final double temperature;

  @HiveField(1)
  final HiveWeatherCondition condition;

  @HiveField(2)
  final HiveAqi aqi;

  @HiveField(3)
  final int humidity;

  @HiveField(4) 
  final double feelsLikeTemperature;

  @override
  List<Object?> get props => [
        temperature,
        condition,
        aqi
      ];
}
