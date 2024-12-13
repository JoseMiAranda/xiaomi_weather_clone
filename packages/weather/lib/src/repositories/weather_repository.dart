import 'package:weather/weather.dart';

/// {@template weather_repository}
/// A repository that handles `weather` and `locations` related requests.
/// {@endtemplate}
abstract class WeatherRepository {

  /// Get a list of locations with the given city, throws [Exception] if the city is not found
  Future<List<Location>> getLocations(String city, {String lang});

  /// Get a weather with the given location, throws [Exception] if the location is not valid
  Future<Weather> getWeather(Location location);
}