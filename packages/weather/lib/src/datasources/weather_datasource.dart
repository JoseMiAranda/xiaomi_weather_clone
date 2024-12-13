import 'package:weather/weather.dart';

/// {@template todos_api}
/// The interface for an Datasource that fetchs locations and weathers.
/// {@endtemplate}
abstract class WeatherDatasource {
  /// Get a list of locations with the given city
  Future<List<Location>> getLocations(String city, {String lang});
  /// Get a weather with the given location
  Future<Weather> getWeather(Location location);
}