// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:mocktail/mocktail.dart';
import 'package:open_meteo_api/open_meteo_api.dart' as open_meteo_api;
import 'package:test/test.dart';
import 'package:weather_repository/weather_repository.dart';

class MockOpenMeteoApiClient extends Mock
    implements open_meteo_api.OpenMeteoApiClient {}

class MockLocation extends Mock implements Location {}

class MockWeather extends Mock implements Weather {}

void main() {
  group('WeatherRepository', () {
    late open_meteo_api.OpenMeteoApiClient weatherApiClient;
    late WeatherRepository weatherRepository;

    setUp(() {
      weatherApiClient = MockOpenMeteoApiClient();
      weatherRepository = WeatherRepositoryImpl(
        weatherApiClient: weatherApiClient,
      );
    });

    group('constructor', () {
      test('instantiates internal weather api client when not injected', () {
        expect(WeatherRepositoryImpl(weatherApiClient: weatherApiClient),
            isNotNull);
      });
    });

    group('getLocation', () {
      const city = 'malaga';
      test('calls getLocations with correct city', () async {
        try {
          await weatherRepository.getLocations(city);
        } catch (_) {}
        verify(() => weatherApiClient.getLocations(city)).called(1);
      });

      test('throws when getLocations fails', () async {
        final exception = Exception('oops');
        when(() => weatherApiClient.getLocations(any())).thenThrow(exception);
        expect(
          () async => weatherRepository.getLocations(city),
          throwsA(exception),
        );
      });
    });

    group('getWeather', () {
      final location = Location(
          name: 'Malaga',
          country: 'Spain',
          latitude: 36.72016,
          longitude: -4.42034);
      test('calls getWeather with correct latitude/longitude', () async {
        try {
          await weatherRepository.getWeather(location);
        } catch (_) {}
        verify(
          () => weatherApiClient.getWeather(location),
        ).called(1);
      });

      test('throws when getWeather fails', () async {
        final exception = Exception('oops');
        when(
          () => weatherApiClient.getWeather(location),
        ).thenThrow(exception);
        expect(
          () async => weatherRepository.getWeather(location),
          throwsA(exception),
        );
      });

      test('returns correct weather on success (clear)', () async {
        final weather = MockWeather();
        when(() => weather.id).thenReturn(null);
        when(() => weather.lastUpdated).thenReturn(DateTime(2024));
        when(() => weather.location).thenReturn(Location(
            name: 'Malaga',
            country: 'Spain',
            latitude: 36.72016,
            longitude: -4.42034));
        when(() => weather.current).thenReturn(Current(
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
            condition: WeatherCondition.clear));
        when(() => weather.daily).thenReturn([
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
        when(() => weatherApiClient.getWeather(location)).thenAnswer(
          (_) async => weather,
        );
        when(
          () => weatherApiClient.getWeather(location),
        ).thenAnswer((_) async => weather);
        final actual = await weatherRepository.getWeather(location);
        expect(
          actual,
          isA<Weather>()
              .having((w) => w.id, 'id', null)
              .having((w) => w.lastUpdated, 'lastUpdated', DateTime(2024)),
        );

        expect(
            actual.location,
            isA<Location>()
                .having((l) => l.name, 'name', 'Malaga')
                .having((l) => l.country, 'country', 'Spain')
                .having((l) => l.latitude, 'latitude', 36.72016)
                .having((l) => l.longitude, 'longitude', -4.42034));

        expect(
            actual.current,
            isA<Current>()
                .having((c) => c.humidity, 'humidity', 67)
                .having(
                    (c) => c.feelsLikeTemperature, 'feelsLikeTemperature', 18.3)
                .having((c) => c.temperature, 'temperature', 19.1)
                .having(
                    (c) => c.condition, 'condition', WeatherCondition.clear));

        expect(
            actual.current.aqi,
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
            actual.daily[0],
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
            actual.daily[0].hourly[0],
            isA<Hourly>()
                .having((h) => h.time, 'time', DateTime(2024))
                .having((h) => h.condition, 'condition', WeatherCondition.clear)
                .having((h) => h.temperature, 'temperature', 19.6)
                .having((h) => h.windSpeed, 'windSpeed', 9.6)
                .having((h) => h.windDirection, 'windDirection', 100));
      });

      test('returns correct weather on success (cloudy)', () async {
        final weather = MockWeather();
        when(() => weather.id).thenReturn(null);
        when(() => weather.lastUpdated).thenReturn(DateTime(2024));
        when(() => weather.location).thenReturn(Location(
            name: 'Malaga',
            country: 'Spain',
            latitude: 36.72016,
            longitude: -4.42034));
        when(() => weather.current).thenReturn(Current(
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
            condition: WeatherCondition.cloudy));
        when(() => weather.daily).thenReturn([
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
                    condition: WeatherCondition.cloudy,
                    temperature: 19.6,
                    windSpeed: 9.6,
                    windDirection: 100)
              ])
        ]);
        when(() => weatherApiClient.getWeather(location)).thenAnswer(
          (_) async => weather,
        );
        when(
          () => weatherApiClient.getWeather(location),
        ).thenAnswer((_) async => weather);
        final actual = await weatherRepository.getWeather(location);
        expect(
          actual,
          isA<Weather>()
              .having((w) => w.id, 'id', null)
              .having((w) => w.lastUpdated, 'lastUpdated', DateTime(2024)),
        );

        expect(
            actual.location,
            isA<Location>()
                .having((l) => l.name, 'name', 'Malaga')
                .having((l) => l.country, 'country', 'Spain')
                .having((l) => l.latitude, 'latitude', 36.72016)
                .having((l) => l.longitude, 'longitude', -4.42034));

        expect(
            actual.current,
            isA<Current>()
                .having((c) => c.humidity, 'humidity', 67)
                .having(
                    (c) => c.feelsLikeTemperature, 'feelsLikeTemperature', 18.3)
                .having((c) => c.temperature, 'temperature', 19.1)
                .having(
                    (c) => c.condition, 'condition', WeatherCondition.cloudy));

        expect(
            actual.current.aqi,
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
            actual.daily[0],
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
            actual.daily[0].hourly[0],
            isA<Hourly>()
                .having((h) => h.time, 'time', DateTime(2024))
                .having(
                    (h) => h.condition, 'condition', WeatherCondition.cloudy)
                .having((h) => h.temperature, 'temperature', 19.6)
                .having((h) => h.windSpeed, 'windSpeed', 9.6)
                .having((h) => h.windDirection, 'windDirection', 100));
      });

      test('returns correct weather on success (rainy)', () async {
        final weather = MockWeather();
        when(() => weather.id).thenReturn(null);
        when(() => weather.lastUpdated).thenReturn(DateTime(2024));
        when(() => weather.location).thenReturn(Location(
            name: 'Malaga',
            country: 'Spain',
            latitude: 36.72016,
            longitude: -4.42034));
        when(() => weather.current).thenReturn(Current(
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
            condition: WeatherCondition.rainy));
        when(() => weather.daily).thenReturn([
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
                    condition: WeatherCondition.rainy,
                    temperature: 19.6,
                    windSpeed: 9.6,
                    windDirection: 100)
              ])
        ]);
        when(() => weatherApiClient.getWeather(location)).thenAnswer(
          (_) async => weather,
        );
        when(
          () => weatherApiClient.getWeather(location),
        ).thenAnswer((_) async => weather);
        final actual = await weatherRepository.getWeather(location);
        expect(
          actual,
          isA<Weather>()
              .having((w) => w.id, 'id', null)
              .having((w) => w.lastUpdated, 'lastUpdated', DateTime(2024)),
        );

        expect(
            actual.location,
            isA<Location>()
                .having((l) => l.name, 'name', 'Malaga')
                .having((l) => l.country, 'country', 'Spain')
                .having((l) => l.latitude, 'latitude', 36.72016)
                .having((l) => l.longitude, 'longitude', -4.42034));

        expect(
            actual.current,
            isA<Current>()
                .having((c) => c.humidity, 'humidity', 67)
                .having(
                    (c) => c.feelsLikeTemperature, 'feelsLikeTemperature', 18.3)
                .having((c) => c.temperature, 'temperature', 19.1)
                .having(
                    (c) => c.condition, 'condition', WeatherCondition.rainy));

        expect(
            actual.current.aqi,
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
            actual.daily[0],
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
            actual.daily[0].hourly[0],
            isA<Hourly>()
                .having((h) => h.time, 'time', DateTime(2024))
                .having((h) => h.condition, 'condition', WeatherCondition.rainy)
                .having((h) => h.temperature, 'temperature', 19.6)
                .having((h) => h.windSpeed, 'windSpeed', 9.6)
                .having((h) => h.windDirection, 'windDirection', 100));
      });

      test('returns correct weather on success (snowy)', () async {
        final weather = MockWeather();
        when(() => weather.id).thenReturn(null);
        when(() => weather.lastUpdated).thenReturn(DateTime(2024));
        when(() => weather.location).thenReturn(Location(
            name: 'Malaga',
            country: 'Spain',
            latitude: 36.72016,
            longitude: -4.42034));
        when(() => weather.current).thenReturn(Current(
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
            condition: WeatherCondition.snowy));
        when(() => weather.daily).thenReturn([
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
                    condition: WeatherCondition.snowy,
                    temperature: 19.6,
                    windSpeed: 9.6,
                    windDirection: 100)
              ])
        ]);
        when(() => weatherApiClient.getWeather(location)).thenAnswer(
          (_) async => weather,
        );
        when(
          () => weatherApiClient.getWeather(location),
        ).thenAnswer((_) async => weather);
        final actual = await weatherRepository.getWeather(location);
        expect(
          actual,
          isA<Weather>()
              .having((w) => w.id, 'id', null)
              .having((w) => w.lastUpdated, 'lastUpdated', DateTime(2024)),
        );

        expect(
            actual.location,
            isA<Location>()
                .having((l) => l.name, 'name', 'Malaga')
                .having((l) => l.country, 'country', 'Spain')
                .having((l) => l.latitude, 'latitude', 36.72016)
                .having((l) => l.longitude, 'longitude', -4.42034));

        expect(
            actual.current,
            isA<Current>()
                .having((c) => c.humidity, 'humidity', 67)
                .having(
                    (c) => c.feelsLikeTemperature, 'feelsLikeTemperature', 18.3)
                .having((c) => c.temperature, 'temperature', 19.1)
                .having(
                    (c) => c.condition, 'condition', WeatherCondition.snowy));

        expect(
            actual.current.aqi,
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
            actual.daily[0],
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
            actual.daily[0].hourly[0],
            isA<Hourly>()
                .having((h) => h.time, 'time', DateTime(2024))
                .having((h) => h.condition, 'condition', WeatherCondition.snowy)
                .having((h) => h.temperature, 'temperature', 19.6)
                .having((h) => h.windSpeed, 'windSpeed', 9.6)
                .having((h) => h.windDirection, 'windDirection', 100));
      });

      test('returns correct weather on success (unknown)', () async {
        final weather = MockWeather();
        when(() => weather.id).thenReturn(null);
        when(() => weather.lastUpdated).thenReturn(DateTime(2024));
        when(() => weather.location).thenReturn(Location(
            name: 'Malaga',
            country: 'Spain',
            latitude: 36.72016,
            longitude: -4.42034));
        when(() => weather.current).thenReturn(Current(
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
            condition: WeatherCondition.unknown));
        when(() => weather.daily).thenReturn([
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
                    condition: WeatherCondition.unknown,
                    temperature: 19.6,
                    windSpeed: 9.6,
                    windDirection: 100)
              ])
        ]);
        when(() => weatherApiClient.getWeather(location)).thenAnswer(
          (_) async => weather,
        );
        when(
          () => weatherApiClient.getWeather(location),
        ).thenAnswer((_) async => weather);
        final actual = await weatherRepository.getWeather(location);
        expect(
          actual,
          isA<Weather>()
              .having((w) => w.id, 'id', null)
              .having((w) => w.lastUpdated, 'lastUpdated', DateTime(2024)),
        );

        expect(
            actual.location,
            isA<Location>()
                .having((l) => l.name, 'name', 'Malaga')
                .having((l) => l.country, 'country', 'Spain')
                .having((l) => l.latitude, 'latitude', 36.72016)
                .having((l) => l.longitude, 'longitude', -4.42034));

        expect(
            actual.current,
            isA<Current>()
                .having((c) => c.humidity, 'humidity', 67)
                .having(
                    (c) => c.feelsLikeTemperature, 'feelsLikeTemperature', 18.3)
                .having((c) => c.temperature, 'temperature', 19.1)
                .having(
                    (c) => c.condition, 'condition', WeatherCondition.unknown));

        expect(
            actual.current.aqi,
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
            actual.daily[0],
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
            actual.daily[0].hourly[0],
            isA<Hourly>()
                .having((h) => h.time, 'time', DateTime(2024))
                .having(
                    (h) => h.condition, 'condition', WeatherCondition.unknown)
                .having((h) => h.temperature, 'temperature', 19.6)
                .having((h) => h.windSpeed, 'windSpeed', 9.6)
                .having((h) => h.windDirection, 'windDirection', 100));
      });
    });
  });
}
