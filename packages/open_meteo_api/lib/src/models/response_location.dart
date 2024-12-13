import 'package:json_annotation/json_annotation.dart';

part 'response_location.g.dart';

@JsonSerializable()
class ResponseLocation {
  const ResponseLocation({
    required this.id,
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory ResponseLocation.fromJson(Map<String, dynamic> json) =>
      _$ResponseLocationFromJson(json);

  final int id;
  final String name; 
  final String country;
  final double latitude;
  final double longitude;
}