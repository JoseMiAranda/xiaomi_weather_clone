import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'hive_location.g.dart';

@HiveType(typeId: 0) 
class HiveLocation extends Equatable {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String country;

  @HiveField(2)
  final double latitude;

  @HiveField(3)
  final double longitude;

  const HiveLocation({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });
  
  @override
  List<Object?> get props => [name, country, latitude, longitude];
}