// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aqi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Aqi _$AqiFromJson(Map<String, dynamic> json) => Aqi(
      aqi: (json['aqi'] as num).toInt(),
      condition: $enumDecode(_$AqiConditionEnumMap, json['condition']),
      pm10: (json['pm10'] as num).toDouble(),
      pm25: (json['pm25'] as num).toDouble(),
      carbonMonoxide: (json['carbonMonoxide'] as num).toDouble(),
      nitrogenDioxide: (json['nitrogenDioxide'] as num).toDouble(),
      sulphurDioxide: (json['sulphurDioxide'] as num).toDouble(),
      ozone: (json['ozone'] as num).toDouble(),
    );

Map<String, dynamic> _$AqiToJson(Aqi instance) => <String, dynamic>{
      'aqi': instance.aqi,
      'condition': _$AqiConditionEnumMap[instance.condition]!,
      'pm10': instance.pm10,
      'pm25': instance.pm25,
      'carbonMonoxide': instance.carbonMonoxide,
      'nitrogenDioxide': instance.nitrogenDioxide,
      'sulphurDioxide': instance.sulphurDioxide,
      'ozone': instance.ozone,
    };

const _$AqiConditionEnumMap = {
  AqiCondition.good: 'good',
  AqiCondition.fair: 'fair',
  AqiCondition.moderate: 'moderate',
  AqiCondition.poor: 'poor',
  AqiCondition.veryPoor: 'veryPoor',
  AqiCondition.extremelyPoor: 'extremelyPoor',
  AqiCondition.unknown: 'unknown',
};
