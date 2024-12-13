import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:xiaomi_weather_clone/bloc/search/models/location.dart';
import 'package:xiaomi_weather_clone/bloc/weather/models/weather.dart';

part 'search_results.g.dart';

@JsonSerializable()
class SearchResults extends Equatable {
  const SearchResults({
    this.weather,
    required this.locations,
  });

  SearchResults.empty()
      : weather = null,
        locations = <Location>[];

  factory SearchResults.fromJson(Map<String, dynamic> json) =>
      _$SearchResultsFromJson(json);

  final Weather? weather;
  final List<Location> locations;

  Map<String, dynamic> toJson() => _$SearchResultsToJson(this);

  bool get isEmpty => locations.isEmpty;
  
  @override
  List<Object?> get props => [weather, locations];
}
