import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'aqi.g.dart';

/// {@template aqi_condition_model}
/// States of [Aqi]
/// {@endtemplate}
enum AqiCondition {
  good,
  fair,
  moderate,
  poor,
  veryPoor,
  extremelyPoor,
  unknown,
}

/// {@template aqi_model}
/// A single `aqi` item.
///
/// Contains a [aqi], [condition], [pm10], [pm25], [carbonMonoxide], [nitrogenDioxide], [sulphurDioxide] and [ozone]
///
/// [Aqi]s are immutable , in addition to
/// being serialized and deserialized using [toJson] and [fromJson]
/// respectively.
/// {@endtemplate}
@immutable
@JsonSerializable()
class Aqi extends Equatable {
  /// {@macro aqi_model}
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

  factory Aqi.fromJson(Map<String, dynamic> json) => _$AqiFromJson(json);

  Map<String, dynamic> toJson() => _$AqiToJson(this);

  /// The condition of the AQI
  final AqiCondition condition;
  
  /// The index of air quatity
  final int aqi;

  /// Concentration of PM10 particles.
  final double pm10;

  /// Concentration of PM2.5 particles.
  final double pm25;

  /// Concentration of carbon monoxide.
  final double carbonMonoxide;
  
  /// Concentration of nitrogen dioxide.
  final double nitrogenDioxide;

  /// Concentration of sulphur dioxide.
  final double sulphurDioxide;

  /// Concentration of ozone.
  final double ozone;
  
  @override
  List<Object?> get props => [aqi, pm10, pm25, carbonMonoxide, nitrogenDioxide, sulphurDioxide, ozone];

}
