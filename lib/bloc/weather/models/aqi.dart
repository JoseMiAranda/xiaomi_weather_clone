import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_repository/weather_repository.dart' as weather_repository;
import 'package:weather_repository/weather_repository.dart';

part 'aqi.g.dart';

@JsonSerializable()
class Aqi extends Equatable {
  const Aqi({
    required this.aqi,
    required this.condition,
    required this.pm10,
    required this.pm25,
    required this.carbonMonoxide,
    required this.nitrogenDioxide,
    required this.sulphurDioxide,
    required this.ozone,
  });

  factory Aqi.fromJson(Map<String, dynamic> json) =>
      _$AqiFromJson(json);

  factory Aqi.fromRepository(weather_repository.Aqi aqi) =>
      Aqi(
        aqi: aqi.aqi,
        condition: aqi.condition,
        pm10: aqi.pm10,
        pm25: aqi.pm25,
        carbonMonoxide: aqi.carbonMonoxide,
        nitrogenDioxide: aqi.nitrogenDioxide,
        sulphurDioxide: aqi.sulphurDioxide,
        ozone: aqi.ozone,
      );

  final int aqi;
  final AqiCondition condition;
  final double pm10;
  final double pm25;
  final double carbonMonoxide;
  final double nitrogenDioxide;
  final double sulphurDioxide;
  final double ozone;

  Map<String, dynamic> toJson() => _$AqiToJson(this);

  weather_repository.Aqi toRepository() =>
      weather_repository.Aqi(
        aqi: aqi,
        condition: condition,
        pm10: pm10,
        pm25: pm25,
        carbonMonoxide: carbonMonoxide,
        nitrogenDioxide: nitrogenDioxide,
        sulphurDioxide: sulphurDioxide,
        ozone: ozone,
      );

  @override
  List<Object> get props => [aqi, pm10, pm25, carbonMonoxide, nitrogenDioxide, sulphurDioxide, ozone];
}
