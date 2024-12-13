import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive_weather_api/hive_weather_api.dart';
import 'package:weather/weather.dart';

class FakeWeatherAdapter extends Fake implements TypeAdapter<Object?> {
  @override
  int get typeId => 0;

  @override
  Object? read(BinaryReader reader) => null;

  @override
  void write(BinaryWriter writer, Object? obj) {}
}

class MockHive extends Mock implements HiveInterface {}

class MockBox<T> extends Mock implements Box<T> {}

void main() {
  const channel = MethodChannel(
    'plugins.flutter.io/path_provider',
  );

  late MockHive mockHive;
  late MockBox mockBox;
  late HiveWeatherApiClient hiveWeatherApiClient;

  setUpAll(() {
    registerFallbackValue(FakeWeatherAdapter());
  });

  setUp(() async {
    //Create test path
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return '/mock/path';
      }
      return null;
    });

    mockHive = MockHive();
    mockBox = MockBox();

    // Register default values of myBox
    when(() => mockHive.isBoxOpen(any())).thenReturn(false);
    when(() => mockHive.openBox(HiveWeatherApiClient.kMyBoxKey))
        .thenAnswer((_) async => mockBox);
    when(() => mockBox.get(HiveWeatherApiClient.kWeathersKey,
        defaultValue: any(named: 'defaultValue'))).thenReturn(<HiveWeather>[]);
    when(() => mockBox.get(HiveWeatherApiClient.kCurrentWeatherKey,
        defaultValue: any(named: 'defaultValue'))).thenReturn('');

    // Register the adapters
    when(() => mockHive.isAdapterRegistered(any())).thenReturn(false);
    when(() => mockHive.registerAdapter(any(), override: true))
        .thenReturn(null);

    hiveWeatherApiClient =
        await HiveWeatherApiClient.instantiate(hive: mockHive);
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('constructor', () {
    test('call async constructor', () async {
      expect(() async => HiveWeatherApiClient.instantiate(hive: mockHive),
          returnsNormally);
    });
  });

  group('get initial streams', () {
    test('get initial weathers', () async {
      final Stream<List<Weather>> weathersStream =
          hiveWeatherApiClient.getWeathersStream();
      final List<Weather> weathers = await weathersStream.first;
      expect(weathers.length, 0);
    });

    test('get initial current weather', () async {
      final Stream<Weather?> weatherStream =
          hiveWeatherApiClient.getCurrentWeatherStream();
      final Weather? weather = await weatherStream.first;
      expect(
        weather,
        null,
      );
    });
  });

  group('saveWeather', () {
    test('saves weather', () async {
      final weatherToSave = Weather(
          id: '1234',
          lastUpdated: DateTime(2024),
          location: Location(
              name: 'Malaga',
              country: 'Spain',
              latitude: 36.72016,
              longitude: -4.42034),
          current: const Current(
              aqi: Aqi(
                  aqi: 35,
                  condition: AqiCondition.fair,
                  pm10: 12.6,
                  pm25: 39.5,
                  carbonMonoxide: 123.0,
                  nitrogenDioxide: 7.5,
                  sulphurDioxide: 1.0,
                  ozone: 56.0),
              humidity: 0,
              feelsLikeTemperature: 15.1,
              temperature: 15.1,
              condition: WeatherCondition.clear),
          daily: [
            Daily(
                time: DateTime(2024),
                maxTemperature: 20.1,
                minTemperature: 10.1,
                maxWindSpeed: 9.0,
                maxSeaPressure: 1025.0,
                maxWindDirection: 270,
                precipitationProbability: 0,
                uvIndex: 2,
                sunrise: DateTime(2024),
                sunset: DateTime(2024),
                hourly: [
                  Hourly(
                      time: DateTime(2024),
                      condition: WeatherCondition.clear,
                      temperature: 15.1,
                      windSpeed: 120,
                      windDirection: 96)
                ])
          ]);

      when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

      await hiveWeatherApiClient.saveWeather(weatherToSave, current: true);

      verify(() => mockBox.put(
            HiveWeatherApiClient.kCurrentWeatherKey,
            '1234',
          )).called(1);

      verify(() => mockBox.put(
            HiveWeatherApiClient.kWeathersKey,
            any(
                that: predicate<List<dynamic>>((list) =>
                    list.isNotEmpty &&
                    list.first is HiveWeather &&
                    list.first.id == '1234')),
          )).called(1);
    });

    test('get weathers', () async {
      final Stream<List<Weather>> weathersStream =
          hiveWeatherApiClient.getWeathersStream();
      final List<Weather> weathers = await weathersStream.first;

      expect(weathers.length, 1);

      final Weather weather = weathers[0];

      expect(
        weather,
        isA<Weather>()
            .having((w) => w.id, 'id', '1234')
            .having((w) => w.lastUpdated, 'lastUpdated', DateTime(2024)),
      );

      expect(
          weather.location,
          isA<Location>()
              .having((l) => l.name, 'name', 'Malaga')
              .having((l) => l.country, 'country', 'Spain')
              .having((l) => l.latitude, 'latitude', 36.72016)
              .having((l) => l.longitude, 'longitude', -4.42034));

      expect(
          weather.current,
          isA<Current>()
              .having((c) => c.humidity, 'humidity', 0)
              .having(
                  (c) => c.feelsLikeTemperature, 'feelsLikeTemperature', 15.1)
              .having((c) => c.temperature, 'temperature', 15.1)
              .having((c) => c.condition, 'condition', WeatherCondition.clear));

      expect(
          weather.current.aqi,
          isA<Aqi>()
              .having((a) => a.aqi, 'aqi', 35)
              .having((a) => a.condition, 'condition', AqiCondition.fair)
              .having((a) => a.pm10, 'pm10', 12.6)
              .having((a) => a.pm25, 'pm25', 39.5)
              .having((a) => a.carbonMonoxide, 'carbonMonoxide', 123.0)
              .having((a) => a.nitrogenDioxide, 'nitrogenDioxide', 7.5)
              .having((a) => a.sulphurDioxide, 'sulphurDioxide', 1.0)
              .having((a) => a.ozone, 'ozone', 56.0));

      expect(
          weather.daily[0],
          isA<Daily>()
              .having((d) => d.time, 'time', DateTime(2024))
              .having((d) => d.maxTemperature, 'temperatureMax', 20.1)
              .having((d) => d.minTemperature, 'temperatureMin', 10.1)
              .having((d) => d.maxWindSpeed, 'maxWindSpeed', 9.0)
              .having((d) => d.maxSeaPressure, 'maxSeaPressure', 1025.0)
              .having((d) => d.maxWindDirection, 'maxWindDirection', 270)
              .having((d) => d.precipitationProbability,
                  'precipitationProbability', 0)
              .having((d) => d.uvIndex, 'uvIndex', 2)
              .having((d) => d.sunrise, 'sunrise', DateTime(2024))
              .having((d) => d.sunrise, 'sunset', DateTime(2024)));

      expect(
          weather.daily[0].hourly[0],
          isA<Hourly>()
              .having((h) => h.time, 'time', DateTime(2024))
              .having((h) => h.condition, 'condition', WeatherCondition.clear)
              .having((h) => h.temperature, 'temperature', 15.1)
              .having((h) => h.windSpeed, 'windSpeed', 120)
              .having((h) => h.windDirection, 'windDirection', 96));
    });

    test('get current weather', () async {
      final Stream<Weather?> weatherStream =
          hiveWeatherApiClient.getCurrentWeatherStream();
      final Weather? weather = await weatherStream.first;

      expect(weather, isNotNull);

      expect(
        weather,
        isA<Weather>()
            .having((w) => w.id, 'id', '1234')
            .having((w) => w.lastUpdated, 'lastUpdated', DateTime(2024)),
      );

      expect(
          weather!.location,
          isA<Location>()
              .having((l) => l.name, 'name', 'Malaga')
              .having((l) => l.country, 'country', 'Spain')
              .having((l) => l.latitude, 'latitude', 36.72016)
              .having((l) => l.longitude, 'longitude', -4.42034));

      expect(
          weather.current,
          isA<Current>()
              .having((c) => c.humidity, 'humidity', 0)
              .having(
                  (c) => c.feelsLikeTemperature, 'feelsLikeTemperature', 15.1)
              .having((c) => c.temperature, 'temperature', 15.1)
              .having((c) => c.condition, 'condition', WeatherCondition.clear));

      expect(
          weather.current.aqi,
          isA<Aqi>()
              .having((a) => a.aqi, 'aqi', 35)
              .having((a) => a.condition, 'condition', AqiCondition.fair)
              .having((a) => a.pm10, 'pm10', 12.6)
              .having((a) => a.pm25, 'pm25', 39.5)
              .having((a) => a.carbonMonoxide, 'carbonMonoxide', 123.0)
              .having((a) => a.nitrogenDioxide, 'nitrogenDioxide', 7.5)
              .having((a) => a.sulphurDioxide, 'sulphurDioxide', 1.0)
              .having((a) => a.ozone, 'ozone', 56.0));

      expect(
          weather.daily[0],
          isA<Daily>()
              .having((d) => d.time, 'time', DateTime(2024))
              .having((d) => d.maxTemperature, 'temperatureMax', 20.1)
              .having((d) => d.minTemperature, 'temperatureMin', 10.1)
              .having((d) => d.maxWindSpeed, 'maxWindSpeed', 9.0)
              .having((d) => d.maxSeaPressure, 'maxSeaPressure', 1025.0)
              .having((d) => d.maxWindDirection, 'maxWindDirection', 270)
              .having((d) => d.precipitationProbability,
                  'precipitationProbability', 0)
              .having((d) => d.uvIndex, 'uvIndex', 2)
              .having((d) => d.sunrise, 'sunrise', DateTime(2024))
              .having((d) => d.sunrise, 'sunset', DateTime(2024)));

      expect(
          weather.daily[0].hourly[0],
          isA<Hourly>()
              .having((h) => h.time, 'time', DateTime(2024))
              .having((h) => h.condition, 'condition', WeatherCondition.clear)
              .having((h) => h.temperature, 'temperature', 15.1)
              .having((h) => h.windSpeed, 'windSpeed', 120)
              .having((h) => h.windDirection, 'windDirection', 96));
    });
  });

  group('updateWeather', () {
    test('saves weather', () async {
      final weatherToUpdate = Weather(
          id: '1234',
          lastUpdated: DateTime(2024),
          location: Location(
              name: 'Malaga',
              country: 'Spain',
              latitude: 36.72016,
              longitude: -4.42034),
          current: const Current(
              aqi: Aqi(
                  aqi: 44,
                  condition: AqiCondition.moderate,
                  pm10: 44.2,
                  pm25: 17.2,
                  carbonMonoxide: 132.0,
                  nitrogenDioxide: 17.9,
                  sulphurDioxide: 3.4,
                  ozone: 39.0),
              humidity: 67,
              feelsLikeTemperature: 18.3,
              temperature: 19.1,
              condition: WeatherCondition.cloudy),
          daily: [
            Daily(
                time: DateTime(2024),
                maxTemperature: 22.3,
                minTemperature: 12.5,
                maxWindSpeed: 14.8,
                maxSeaPressure: 1024.0,
                maxWindDirection: 300,
                precipitationProbability: 10,
                uvIndex: 3,
                sunrise: DateTime(2024),
                sunset: DateTime(2024),
                hourly: [
                  Hourly(
                      time: DateTime(2024),
                      condition: WeatherCondition.clear,
                      temperature: 19.6,
                      windSpeed: 9.6,
                      windDirection: 100)
                ])
          ]);

      when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

      await hiveWeatherApiClient.saveWeather(weatherToUpdate);

      verify(() => mockBox.put(
            HiveWeatherApiClient.kWeathersKey,
            any(
                that: predicate<List<dynamic>>((list) =>
                    list.isNotEmpty &&
                    list.first is HiveWeather &&
                    list.first.id == '1234')),
          )).called(1);
    });

    test('get weathers', () async {
      final Stream<List<Weather>> weathersStream =
          hiveWeatherApiClient.getWeathersStream();
      final List<Weather> weathers = await weathersStream.first;

      expect(weathers.length, 1);

      final Weather weather = weathers[0];

      expect(
        weather,
        isA<Weather>()
            .having((w) => w.id, 'id', '1234')
            .having((w) => w.lastUpdated, 'lastUpdated', DateTime(2024)),
      );

      expect(
          weather.location,
          isA<Location>()
              .having((l) => l.name, 'name', 'Malaga')
              .having((l) => l.country, 'country', 'Spain')
              .having((l) => l.latitude, 'latitude', 36.72016)
              .having((l) => l.longitude, 'longitude', -4.42034));

      expect(
          weather.current,
          isA<Current>()
              .having((c) => c.humidity, 'humidity', 67)
              .having(
                  (c) => c.feelsLikeTemperature, 'feelsLikeTemperature', 18.3)
              .having((c) => c.temperature, 'temperature', 19.1)
              .having(
                  (c) => c.condition, 'condition', WeatherCondition.cloudy));

      expect(
          weather.current.aqi,
          isA<Aqi>()
              .having((a) => a.aqi, 'aqi', 44)
              .having((a) => a.condition, 'condition', AqiCondition.moderate)
              .having((a) => a.pm10, 'pm10', 44.2)
              .having((a) => a.pm25, 'pm25', 17.2)
              .having((a) => a.carbonMonoxide, 'carbonMonoxide', 132.0)
              .having((a) => a.nitrogenDioxide, 'nitrogenDioxide', 17.9)
              .having((a) => a.sulphurDioxide, 'sulphurDioxide', 3.4)
              .having((a) => a.ozone, 'ozone', 39.0));

      expect(
          weather.daily[0],
          isA<Daily>()
              .having((d) => d.time, 'time', DateTime(2024))
              .having((d) => d.maxTemperature, 'temperatureMax', 22.3)
              .having((d) => d.minTemperature, 'temperatureMin', 12.5)
              .having((d) => d.maxWindSpeed, 'maxWindSpeed', 14.8)
              .having((d) => d.maxSeaPressure, 'maxSeaPressure', 1024.0)
              .having((d) => d.maxWindDirection, 'maxWindDirection', 300)
              .having((d) => d.precipitationProbability,
                  'precipitationProbability', 10)
              .having((d) => d.uvIndex, 'uvIndex', 3)
              .having((d) => d.sunrise, 'sunrise', DateTime(2024))
              .having((d) => d.sunset, 'sunset', DateTime(2024)));

      expect(
          weather.daily[0].hourly[0],
          isA<Hourly>()
              .having((h) => h.time, 'time', DateTime(2024))
              .having((h) => h.condition, 'condition', WeatherCondition.clear)
              .having((h) => h.temperature, 'temperature', 19.6)
              .having((h) => h.windSpeed, 'windSpeed', 9.6)
              .having((h) => h.windDirection, 'windDirection', 100));
    });

    test('get current weather', () async {
      final Stream<Weather?> weatherStream =
          hiveWeatherApiClient.getCurrentWeatherStream();
      final Weather? weather = await weatherStream.first;

      expect(weather, isNotNull);

      expect(
        weather!,
        isA<Weather>()
            .having((w) => w.id, 'id', '1234')
            .having((w) => w.lastUpdated, 'lastUpdated', DateTime(2024)),
      );

      expect(
          weather.location,
          isA<Location>()
              .having((l) => l.name, 'name', 'Malaga')
              .having((l) => l.country, 'country', 'Spain')
              .having((l) => l.latitude, 'latitude', 36.72016)
              .having((l) => l.longitude, 'longitude', -4.42034));

      expect(
          weather.current,
          isA<Current>()
              .having((c) => c.humidity, 'humidity', 67)
              .having(
                  (c) => c.feelsLikeTemperature, 'feelsLikeTemperature', 18.3)
              .having((c) => c.temperature, 'temperature', 19.1)
              .having(
                  (c) => c.condition, 'condition', WeatherCondition.cloudy));

      expect(
          weather.current.aqi,
          isA<Aqi>()
              .having((a) => a.aqi, 'aqi', 44)
              .having((a) => a.condition, 'condition', AqiCondition.moderate)
              .having((a) => a.pm10, 'pm10', 44.2)
              .having((a) => a.pm25, 'pm25', 17.2)
              .having((a) => a.carbonMonoxide, 'carbonMonoxide', 132.0)
              .having((a) => a.nitrogenDioxide, 'nitrogenDioxide', 17.9)
              .having((a) => a.sulphurDioxide, 'sulphurDioxide', 3.4)
              .having((a) => a.ozone, 'ozone', 39.0));

      expect(
          weather.daily[0],
          isA<Daily>()
              .having((d) => d.time, 'time', DateTime(2024))
              .having((d) => d.maxTemperature, 'temperatureMax', 22.3)
              .having((d) => d.minTemperature, 'temperatureMin', 12.5)
              .having((d) => d.maxWindSpeed, 'maxWindSpeed', 14.8)
              .having((d) => d.maxSeaPressure, 'maxSeaPressure', 1024.0)
              .having((d) => d.maxWindDirection, 'maxWindDirection', 300)
              .having((d) => d.precipitationProbability,
                  'precipitationProbability', 10)
              .having((d) => d.uvIndex, 'uvIndex', 3)
              .having((d) => d.sunrise, 'sunrise', DateTime(2024))
              .having((d) => d.sunset, 'sunset', DateTime(2024)));

      expect(
          weather.daily[0].hourly[0],
          isA<Hourly>()
              .having((h) => h.time, 'time', DateTime(2024))
              .having((h) => h.condition, 'condition', WeatherCondition.clear)
              .having((h) => h.temperature, 'temperature', 19.6)
              .having((h) => h.windSpeed, 'windSpeed', 9.6)
              .having((h) => h.windDirection, 'windDirection', 100));
    });
  });

  group('deleteWeather', () {
    test('deletes weather', () async {
      final weatherToDelete = ['1234'];

      when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

      await hiveWeatherApiClient.deleteWeathers(weatherToDelete);

      verify(() => mockBox.put(HiveWeatherApiClient.kWeathersKey, []))
          .called(1);
    });

    test('get weathers', () {
      expect(
        hiveWeatherApiClient.getWeathersStream(),
        emits([]),
      );
    });

    test('get current weather', () {
      expect(
        hiveWeatherApiClient.getCurrentWeatherStream(),
        emits(null),
      );
    });
  });
}
