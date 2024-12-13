import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_weather_api/src/mappers/mapper.dart';
import 'package:hive_weather_api/src/models/hive_aqi.dart';
import 'package:hive_weather_api/src/models/hive_location.dart';
import 'package:hive_weather_api/src/models/hive_weather.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weather/weather.dart';

/// {@template hive_weather_api_client}
/// A Flutter implementation of the [DbWeatherDatasource] that uses local storage.
/// {@endtemplate}
class HiveWeatherApiClient implements DbWeatherDatasource {
  static HiveWeatherApiClient? _instance;
  final HiveInterface _hive;

  HiveWeatherApiClient._internal(this._hive);

  static Future<HiveWeatherApiClient> instantiate({HiveInterface? hive}) async {
    if (_instance != null) {
      return _instance!;
    }

    final hiveInstance = hive ?? Hive;
    final instance = HiveWeatherApiClient._internal(hiveInstance);

    await instance._init();
    _instance = instance;

    return _instance!;
  }

  late final BehaviorSubject<List<HiveWeather>> _weatherStreamController =
      BehaviorSubject<List<HiveWeather>>.seeded(const []);

  late final BehaviorSubject<String> _currentStreamController =
      BehaviorSubject<String>.seeded('');

  /// The key used for storing the weathers locally.
  ///
  /// This is only exposed for testing and shouldn't be used by consumers of
  /// this library.
  @visibleForTesting
  static const kMyBoxKey = 'myBox';

  /// The key used for storing the weathers locally.
  ///
  /// This is only exposed for testing and shouldn't be used by consumers of
  /// this library.
  @visibleForTesting
  static const kWeathersKey = 'weathers';

  /// The key used to store the current weather ID locally.
  ///
  /// This is only exposed for testing and shouldn't be used by consumers of
  /// this library.
  @visibleForTesting
  static const kCurrentWeatherKey = 'currentWeather';

  Future<void> _init() async {
    if (!_hive.isBoxOpen(kMyBoxKey)) {
      if (kIsWeb) {
        _hive.initFlutter();
      } else {
        final appDocumentDir = await getApplicationDocumentsDirectory();
        _hive.init(appDocumentDir.path);
      }
    }

    _registerAdapters();

    final box = await _hive.openBox(kMyBoxKey);

    final weathers = box.get(
      kWeathersKey,
      defaultValue: <HiveWeather>[],
    ).cast<HiveWeather>();

    final current = box.get(kCurrentWeatherKey, defaultValue: '') as String;

    _weatherStreamController.add(weathers);
    _currentStreamController.add(current);
  }

  void _registerAdapters() {
    //* Register adapter wihout usign map (produces errors)

    if (!_hive.isAdapterRegistered(HiveWeatherAdapter().typeId)) {
      _hive.registerAdapter(HiveWeatherAdapter());
    }

    if (!_hive.isAdapterRegistered(HiveHourlyForecastAdapter().typeId)) {
      _hive.registerAdapter(HiveHourlyForecastAdapter());
    }

    if (!_hive.isAdapterRegistered(HiveDailyForecastAdapter().typeId)) {
      _hive.registerAdapter(HiveDailyForecastAdapter());
    }

    if (!_hive.isAdapterRegistered(HiveCurrentAdapter().typeId)) {
      _hive.registerAdapter(HiveCurrentAdapter());
    }

    if (!_hive.isAdapterRegistered(HiveAqiAdapter().typeId)) {
      _hive.registerAdapter(HiveAqiAdapter());
    }

    if (!_hive.isAdapterRegistered(HiveAqiConditionAdapter().typeId)) {
      _hive.registerAdapter(HiveAqiConditionAdapter());
    }

    if (!_hive.isAdapterRegistered(HiveWeatherConditionAdapter().typeId)) {
      _hive.registerAdapter(HiveWeatherConditionAdapter());
    }

    if (!_hive.isAdapterRegistered(HiveLocationAdapter().typeId)) {
      _hive.registerAdapter(HiveLocationAdapter());
    }
  }

  @override
  Stream<Weather?> getCurrentWeatherStream() =>
      _currentStreamController.asBroadcastStream().map((id) {
        if (id.isEmpty) return null;
        final index = _weatherStreamController.value
            .indexWhere((weather) => id == weather.id);
        if (index < 0) return null;
        return WeatherMapper.toWeather(_weatherStreamController.value[index]);
      });

  @override
  Stream<List<Weather>> getWeathersStream() =>
      _weatherStreamController.asBroadcastStream().map(
            (weathers) => weathers.map(WeatherMapper.toWeather).toList(),
          );

  Future<void> _setCurrentWeather(String id) async {
    var box = await _hive.openBox(kMyBoxKey);
    await box.put(kCurrentWeatherKey, id);
  }

  Future<void> _setWeathers(List<HiveWeather> weathers) async {
    var box = await _hive.openBox(kMyBoxKey);
    await box.put(kWeathersKey, weathers);
  }

  @override
  Future<void> saveWeather(Weather weather, {bool current = false}) async {
    final HiveWeather hiveWeather = WeatherMapper.toHiveWeather(weather);
    final String currentIdWeather = await _currentStreamController.first;

    final weathers = [..._weatherStreamController.value];
    final weatherIndex = weathers.indexWhere((w) => w.id == weather.id);
    if (weatherIndex >= 0) {
      if (currentIdWeather == weathers[weatherIndex].id) {
        _currentStreamController.add(currentIdWeather);
      }
      weathers[weatherIndex] = hiveWeather;
    } else {
      weathers.add(hiveWeather);
    }

    _weatherStreamController.add(weathers);
    await _setWeathers(weathers);

    if (!current) return;

    _currentStreamController.add(hiveWeather.id);
    await _setCurrentWeather(hiveWeather.id);
  }

  @override
  Future<void> reorganizeWeathers(List<String> ids) async {
    final weathers = [..._weatherStreamController.value];
    final tempWeathers = <HiveWeather>[];

    for (String id in ids) {
      final weatherIndex = weathers.indexWhere((w) => w.id == id);
      if (weatherIndex >= 0) {
        tempWeathers.add(weathers[weatherIndex]);
      }
    }

    _weatherStreamController.add(tempWeathers);
  }

  @override
  Future<void> deleteWeathers(List<String> ids) async {
    final currentId = _currentStreamController.value;
    final weathers = [..._weatherStreamController.value];

    if (ids.contains(currentId)) {
      final tempWeathers = weathers.sublist(
          0, weathers.indexWhere((weather) => currentId == weather.id));
      tempWeathers.removeWhere((w) => ids.contains(w.id));
      _currentStreamController
          .add(tempWeathers.isEmpty ? '' : tempWeathers.last.id);
    }

    weathers.removeWhere((w) => ids.contains(w.id));
    _weatherStreamController.add(weathers);
    return await _setWeathers(weathers);
  }
}
