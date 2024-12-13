import 'package:weather/weather.dart';

abstract class DbWeatherRepository {
  Stream<Weather?> getCurrentWeatherStream();
  Stream<List<Weather>> getWeathersStream();
  Future<void> saveWeather(Weather weather, {bool current = false});
  Future<void> reorganizeWeathers(List<String> ids);
  Future<void> deleteWeathers(List<String> ids);
}