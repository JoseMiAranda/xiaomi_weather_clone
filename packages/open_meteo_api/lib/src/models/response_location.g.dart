// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResponseLocation _$ResponseLocationFromJson(Map<String, dynamic> json) =>
    ResponseLocation(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      country: json['country'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$ResponseLocationToJson(ResponseLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'country': instance.country,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
