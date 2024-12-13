// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirm_cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfirmState _$ConfirmStateFromJson(Map<String, dynamic> json) => ConfirmState(
      status: $enumDecodeNullable(_$ConfirmStatusEnumMap, json['status']) ??
          ConfirmStatus.initial,
      temperatureUnits: $enumDecodeNullable(
              _$TemperatureUnitsEnumMap, json['temperatureUnits']) ??
          TemperatureUnits.celsius,
      weather: json['weather'] == null
          ? null
          : Weather.fromJson(json['weather'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ConfirmStateToJson(ConfirmState instance) =>
    <String, dynamic>{
      'status': _$ConfirmStatusEnumMap[instance.status]!,
      'weather': instance.weather,
      'temperatureUnits': _$TemperatureUnitsEnumMap[instance.temperatureUnits]!,
    };

const _$ConfirmStatusEnumMap = {
  ConfirmStatus.initial: 'initial',
  ConfirmStatus.loading: 'loading',
  ConfirmStatus.success: 'success',
  ConfirmStatus.failure: 'failure',
};

const _$TemperatureUnitsEnumMap = {
  TemperatureUnits.fahrenheit: 'fahrenheit',
  TemperatureUnits.celsius: 'celsius',
};
