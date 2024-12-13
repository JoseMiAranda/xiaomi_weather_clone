import 'package:weather/weather.dart';

/// {@template db_weather_datasource}
/// The interface for an Datasource that provides access to a list of weathers.
/// {@endtemplate}
abstract class DbWeatherDatasource {
  /// Provides a [Stream] of weather if is selected.
  Stream<Weather?> getCurrentWeatherStream();

  /// Provides a [Stream] of all weathers.
  Stream<List<Weather>> getWeathersStream();

  /// Saves a [Weather] to the database.
  Future<void> saveWeather(Weather weather, {bool current = false});

  /// Reorganizes the weathers for a given [ids]
  Future<void> reorganizeWeathers(List<String> ids);

  /// Deletes the weathers which id is contained in [ids]
  Future<void> deleteWeathers(List<String> ids);
}
