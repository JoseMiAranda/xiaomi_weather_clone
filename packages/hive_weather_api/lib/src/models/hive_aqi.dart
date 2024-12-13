import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'hive_aqi.g.dart';

@HiveType(typeId: 6)
enum HiveAqiCondition {
  @HiveField(0)
  good,

  @HiveField(1)
  fair,

  @HiveField(2)
  moderate,

  @HiveField(3)
  poor,

  @HiveField(4)
  veryPoor,

  @HiveField(5)
  extremelyPoor,

  @HiveField(6)
  unknown,
}

@HiveType(typeId: 7)
class HiveAqi extends Equatable {
  @HiveField(0)
  final int aqi;

  @HiveField(1)
  final HiveAqiCondition condition;

  @HiveField(2)
  final double pm10;

  @HiveField(3)
  final double pm25;

  @HiveField(4)
  final double carbonMonoxide;

  @HiveField(5)
  final double nitrogenDioxide;

  @HiveField(6)
  final double sulphurDioxide;

  @HiveField(7)
  final double ozone;

  const HiveAqi({
    required this.aqi,
    required this.condition,
    required this.pm10,
    required this.pm25,
    required this.carbonMonoxide,
    required this.nitrogenDioxide,
    required this.sulphurDioxide,
    required this.ozone,
  });

  @override
  List<Object?> get props => [
        aqi,
        condition,
        pm10,
        pm25,
        carbonMonoxide,
        nitrogenDioxide,
        sulphurDioxide,
        ozone
      ];
}
