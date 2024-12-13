// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_weather.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResponseWeather _$ResponseWeatherFromJson(Map<String, dynamic> json) =>
    ResponseWeather(
      current:
          ResponseCurrent.fromJson(json['current'] as Map<String, dynamic>),
      hourly: ResponseHourly.fromJson(json['hourly'] as Map<String, dynamic>),
      daily: ResponseDaily.fromJson(json['daily'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ResponseWeatherToJson(ResponseWeather instance) =>
    <String, dynamic>{
      'current': instance.current,
      'hourly': instance.hourly,
      'daily': instance.daily,
    };

ResponseCurrent _$ResponseCurrentFromJson(Map<String, dynamic> json) =>
    ResponseCurrent(
      temperature: (json['temperature_2m'] as num).toDouble(),
      relativeHumidity: (json['relative_humidity_2m'] as num).toInt(),
      feelsLikeTemperature: (json['apparent_temperature'] as num).toDouble(),
      precipitation: (json['precipitation'] as num).toInt(),
      weatherCode: (json['weather_code'] as num).toInt(),
      windSpeed: (json['wind_speed_10m'] as num).toDouble(),
    );

Map<String, dynamic> _$ResponseCurrentToJson(ResponseCurrent instance) =>
    <String, dynamic>{
      'temperature_2m': instance.temperature,
      'relative_humidity_2m': instance.relativeHumidity,
      'apparent_temperature': instance.feelsLikeTemperature,
      'precipitation': instance.precipitation,
      'weather_code': instance.weatherCode,
      'wind_speed_10m': instance.windSpeed,
    };

ResponseDaily _$ResponseDailyFromJson(Map<String, dynamic> json) =>
    ResponseDaily(
      time: (json['time'] as List<dynamic>)
          .map((e) => DateTime.parse(e as String))
          .toList(),
      weatherCode: (json['weather_code'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      temperatureMax: (json['temperature_2m_max'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      temperatureMin: (json['temperature_2m_min'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      windSpeed: (json['wind_speed_10m_max'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      windDirection: (json['wind_direction_10m_dominant'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      uvIndex: (json['uv_index_max'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      precipitationProbability:
          (json['precipitation_probability_max'] as List<dynamic>)
              .map((e) => (e as num).toInt())
              .toList(),
      sunrise: (json['sunrise'] as List<dynamic>)
          .map((e) => DateTime.parse(e as String))
          .toList(),
      sunset: (json['sunset'] as List<dynamic>)
          .map((e) => DateTime.parse(e as String))
          .toList(),
    );

Map<String, dynamic> _$ResponseDailyToJson(ResponseDaily instance) =>
    <String, dynamic>{
      'time': instance.time.map((e) => e.toIso8601String()).toList(),
      'weather_code': instance.weatherCode,
      'temperature_2m_max': instance.temperatureMax,
      'temperature_2m_min': instance.temperatureMin,
      'wind_speed_10m_max': instance.windSpeed,
      'wind_direction_10m_dominant': instance.windDirection,
      'uv_index_max': instance.uvIndex,
      'precipitation_probability_max': instance.precipitationProbability,
      'sunrise': instance.sunrise.map((e) => e.toIso8601String()).toList(),
      'sunset': instance.sunset.map((e) => e.toIso8601String()).toList(),
    };

ResponseHourly _$ResponseHourlyFromJson(Map<String, dynamic> json) =>
    ResponseHourly(
      time: (json['time'] as List<dynamic>)
          .map((e) => DateTime.parse(e as String))
          .toList(),
      weatherCode: (json['weather_code'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      temperature: (json['temperature_2m'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      windSpeed: (json['wind_speed_10m'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      windDirection: (json['wind_direction_10m'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      seaPressure: (json['pressure_msl'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$ResponseHourlyToJson(ResponseHourly instance) =>
    <String, dynamic>{
      'time': instance.time.map((e) => e.toIso8601String()).toList(),
      'weather_code': instance.weatherCode,
      'temperature_2m': instance.temperature,
      'wind_speed_10m': instance.windSpeed,
      'wind_direction_10m': instance.windDirection,
      'pressure_msl': instance.seaPressure,
    };
