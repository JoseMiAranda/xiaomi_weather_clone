// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Weather _$WeatherFromJson(Map<String, dynamic> json) => Weather(
      id: json['id'] as String?,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      current: Current.fromJson(json['current'] as Map<String, dynamic>),
      daily: (json['daily'] as List<dynamic>)
          .map((e) => Daily.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WeatherToJson(Weather instance) => <String, dynamic>{
      'id': instance.id,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'location': instance.location,
      'current': instance.current,
      'daily': instance.daily,
    };

Current _$CurrentFromJson(Map<String, dynamic> json) => Current(
      temperature: (json['temperature'] as num).toDouble(),
      condition: $enumDecode(_$WeatherConditionEnumMap, json['condition']),
      humidity: (json['humidity'] as num).toInt(),
      feelsLikeTemperature: (json['feelsLikeTemperature'] as num).toDouble(),
      aqi: Aqi.fromJson(json['aqi'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CurrentToJson(Current instance) => <String, dynamic>{
      'temperature': instance.temperature,
      'condition': _$WeatherConditionEnumMap[instance.condition]!,
      'humidity': instance.humidity,
      'feelsLikeTemperature': instance.feelsLikeTemperature,
      'aqi': instance.aqi,
    };

const _$WeatherConditionEnumMap = {
  WeatherCondition.clear: 'clear',
  WeatherCondition.rainy: 'rainy',
  WeatherCondition.cloudy: 'cloudy',
  WeatherCondition.snowy: 'snowy',
  WeatherCondition.unknown: 'unknown',
};

Hourly _$HourlyFromJson(Map<String, dynamic> json) => Hourly(
      time: DateTime.parse(json['time'] as String),
      condition: $enumDecode(_$WeatherConditionEnumMap, json['condition']),
      temperature: (json['temperature'] as num).toDouble(),
      windSpeed: (json['windSpeed'] as num).toDouble(),
      windDirection: (json['windDirection'] as num).toInt(),
    );

Map<String, dynamic> _$HourlyToJson(Hourly instance) => <String, dynamic>{
      'time': instance.time.toIso8601String(),
      'condition': _$WeatherConditionEnumMap[instance.condition]!,
      'temperature': instance.temperature,
      'windSpeed': instance.windSpeed,
      'windDirection': instance.windDirection,
    };

Daily _$DailyFromJson(Map<String, dynamic> json) => Daily(
      time: DateTime.parse(json['time'] as String),
      hourly: (json['hourly'] as List<dynamic>)
          .map((e) => Hourly.fromJson(e as Map<String, dynamic>))
          .toList(),
      maxTemperature: (json['maxTemperature'] as num).toDouble(),
      minTemperature: (json['minTemperature'] as num).toDouble(),
      maxWindSpeed: (json['maxWindSpeed'] as num).toDouble(),
      maxWindDirection: (json['maxWindDirection'] as num).toInt(),
      precipitationProbability:
          (json['precipitationProbability'] as num).toInt(),
      maxSeaPressure: (json['maxSeaPressure'] as num).toDouble(),
      uvIndex: (json['uvIndex'] as num).toInt(),
      sunrise: DateTime.parse(json['sunrise'] as String),
      sunset: DateTime.parse(json['sunset'] as String),
    );

Map<String, dynamic> _$DailyToJson(Daily instance) => <String, dynamic>{
      'time': instance.time.toIso8601String(),
      'hourly': instance.hourly,
      'maxTemperature': instance.maxTemperature,
      'minTemperature': instance.minTemperature,
      'maxWindSpeed': instance.maxWindSpeed,
      'maxWindDirection': instance.maxWindDirection,
      'precipitationProbability': instance.precipitationProbability,
      'maxSeaPressure': instance.maxSeaPressure,
      'uvIndex': instance.uvIndex,
      'sunrise': instance.sunrise.toIso8601String(),
      'sunset': instance.sunset.toIso8601String(),
    };
