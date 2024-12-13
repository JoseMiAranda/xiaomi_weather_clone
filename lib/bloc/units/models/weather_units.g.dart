// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_units.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherUnits _$WeatherUnitsFromJson(Map<String, dynamic> json) => WeatherUnits(
      temperatureUnits:
          $enumDecode(_$TemperatureUnitsEnumMap, json['temperatureUnits']),
      windSpeedUnits:
          $enumDecode(_$WindSpeedUnitsEnumMap, json['windSpeedUnits']),
      pressureUnits: $enumDecode(_$PressureUnitsEnumMap, json['pressureUnits']),
    );

Map<String, dynamic> _$WeatherUnitsToJson(WeatherUnits instance) =>
    <String, dynamic>{
      'temperatureUnits': _$TemperatureUnitsEnumMap[instance.temperatureUnits]!,
      'windSpeedUnits': _$WindSpeedUnitsEnumMap[instance.windSpeedUnits]!,
      'pressureUnits': _$PressureUnitsEnumMap[instance.pressureUnits]!,
    };

const _$TemperatureUnitsEnumMap = {
  TemperatureUnits.fahrenheit: 'fahrenheit',
  TemperatureUnits.celsius: 'celsius',
};

const _$WindSpeedUnitsEnumMap = {
  WindSpeedUnits.kph: 'kph',
  WindSpeedUnits.mph: 'mph',
};

const _$PressureUnitsEnumMap = {
  PressureUnits.hpa: 'hpa',
  PressureUnits.mbar: 'mbar',
};
