// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_aqi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResponseAqi _$ResponseAqiFromJson(Map<String, dynamic> json) => ResponseAqi(
      europeanAqi: (json['european_aqi'] as num).toInt(),
      pm10: (json['pm10'] as num).toDouble(),
      pm25: (json['pm2_5'] as num).toDouble(),
      carbonMonoxide: (json['carbon_monoxide'] as num).toDouble(),
      nitrogenDioxide: (json['nitrogen_dioxide'] as num).toDouble(),
      sulphurDioxide: (json['sulphur_dioxide'] as num).toDouble(),
      ozone: (json['ozone'] as num).toDouble(),
    );

Map<String, dynamic> _$ResponseAqiToJson(ResponseAqi instance) =>
    <String, dynamic>{
      'european_aqi': instance.europeanAqi,
      'pm10': instance.pm10,
      'pm2_5': instance.pm25,
      'carbon_monoxide': instance.carbonMonoxide,
      'nitrogen_dioxide': instance.nitrogenDioxide,
      'sulphur_dioxide': instance.sulphurDioxide,
      'ozone': instance.ozone,
    };
