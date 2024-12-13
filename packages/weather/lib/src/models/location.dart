import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'location.g.dart';

/// {@template location_model}
/// A single `location` item.
///
/// Contains a [name], [country], [latitude] and [longitude]
///
/// [Locatio]s are immutable , in addition to
/// being serialized and deserialized using [toJson] and [fromJson]
/// respectively.
/// {@endtemplate}
@immutable
@JsonSerializable()
class Location extends Equatable {
  /// {@macro location_model}
  Location({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  })  : assert(name.isNotEmpty, 'name must not be empty'),
        assert(country.isNotEmpty, 'country must not be empty'),
        assert(latitude >= -90 && latitude <= 90,
            'latitude must be between -90 and 90'),
        assert(longitude >= -180 && longitude <= 180,
            'longitude must be between -180 and 180');

  factory Location.fromJson(Map<String, dynamic> json) {
    return _$LocationFromJson({
      ...json,
      'country': json['country'] ?? 'Not found',
    });
  }

  Map<String, dynamic> toJson() => _$LocationToJson(this);

  /// The name of the location
  ///
  /// Cannot be empty
  final String name;

  /// The country of the location
  ///
  /// Cannot be empty
  /// Defaults to `Not found` on fromJson
  final String country;

  /// The latitude of the location
  /// 
  /// Must be between -90 and 90
  final double latitude;

  /// The longitude of the location
  /// 
  /// Must be between -180 and 180
  final double longitude;

  @override
  List<Object?> get props => [name, country, latitude, longitude];
}
