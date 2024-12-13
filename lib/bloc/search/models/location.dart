import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_repository/weather_repository.dart' as weather_repository;

part 'location.g.dart';

@JsonSerializable()
class Location extends Equatable {
  const Location({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  factory Location.fromRepository(weather_repository.Location location) =>
      Location(
        name: location.name,
        country: location.country,
        latitude: location.latitude,
        longitude: location.longitude,
      );

  static const empty = Location(
        name: '--',
        country: '--',
        latitude: 0,
        longitude: 0,
      );

  final String name;
  final String country;
  final double latitude;
  final double longitude;

  Map<String, dynamic> toJson() => _$LocationToJson(this);

  weather_repository.Location toRepository() =>
      weather_repository.Location(
        name: name,
        country: country,
        latitude: latitude,
        longitude: longitude,
      );

  @override
  List<Object> get props => [latitude, longitude];
}
