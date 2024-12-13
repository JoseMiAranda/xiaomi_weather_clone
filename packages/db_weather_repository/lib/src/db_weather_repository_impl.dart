import 'package:weather/weather.dart';

class DbWeatherRepositoryImpl implements DbWeatherRepository {

  DbWeatherRepositoryImpl({required DbWeatherDatasource datasource}) : _datasource = datasource;

  final DbWeatherDatasource _datasource;

  @override
  Stream<List<Weather>> getWeathersStream() {
    return _datasource.getWeathersStream();
  }

  @override
  Stream<Weather?> getCurrentWeatherStream() {
    return _datasource.getCurrentWeatherStream();
  }

  @override
  Future<void> deleteWeathers(List<String> ids) async {
    return _datasource.deleteWeathers(ids);
  }
  
  @override
  Future<void> saveWeather(Weather weather, {bool current = false}) async {
    return _datasource.saveWeather(weather, current: current);
  }
  
  @override
  Future<void> reorganizeWeathers(List<String> ids) {
    return _datasource.reorganizeWeathers(ids);
  }

}