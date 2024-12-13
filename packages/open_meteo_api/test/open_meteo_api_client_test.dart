// ignore_for_file: prefer_const_constructors
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:test/test.dart';
import 'package:weather/weather.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

class FakeUri extends Fake implements Uri {}

void main() {
  group('OpenMeteoApiClient', () {
    late http.Client httpClient;
    late OpenMeteoApiClient apiClient;

    setUpAll(() {
      registerFallbackValue(FakeUri());
    });

    setUp(() {
      httpClient = MockHttpClient();
      apiClient = OpenMeteoApiClient(httpClient: httpClient);
    });

    group('constructor', () {
      test('does not require an httpClient', () {
        expect(OpenMeteoApiClient(), isNotNull);
      });
    });

    group('getLocations', () {
      const query = 'mock-query';
      test('makes correct http request (English)', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        try {
          await apiClient.getLocations(query);
        } catch (_) {}
        verify(
          () => httpClient.get(
            Uri.https(
              'geocoding-api.open-meteo.com',
              '/v1/search',
              {'name': query, 'language': 'en', 'count': '5'},
            ),
          ),
        ).called(1);
      });

      test('makes correct http request (Spanish)', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        try {
          await apiClient.getLocations(query, lang: 'es');
        } catch (_) {}
        verify(
          () => httpClient.get(
            Uri.https(
              'geocoding-api.open-meteo.com',
              '/v1/search',
              {'name': query, 'language': 'es', 'count': '5'},
            ),
          ),
        ).called(1);
      });

      test('throws LocationRequestFailure on non-200 response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(400);
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        expect(
          () async => apiClient.getLocations(query),
          throwsA(isA<LocationRequestFailure>()),
        );
      });

      test('throws LocationNotFoundFailure on error response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        await expectLater(
          apiClient.getLocations(query),
          throwsA(isA<LocationNotFoundFailure>()),
        );
      });

      test('throws LocationNotFoundFailure on empty response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{"results": []}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        await expectLater(
          apiClient.getLocations(query),
          throwsA(isA<LocationNotFoundFailure>()),
        );
      });

      test('returns Location on valid response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn(
          '''
{
  "results": [
    {
      "id": 2514256,
      "name": "Málaga",
      "latitude": 36.72016,
      "longitude": -4.42034,
      "country": "Spain"
    }
  ]
}''',
        );
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        final actual = await apiClient.getLocations(query);
        expect(
          actual.first,
          isA<Location>()
              .having((l) => l.name, 'name', 'Málaga')
              .having((l) => l.country, 'country', 'Spain')
              .having((l) => l.latitude, 'latitude', 36.72016)
              .having((l) => l.longitude, 'longitude', -4.42034),
        );
      });
    });

    group('getWeather', () {
      const name = 'Malaga';
      const country = 'Spain';
      const latitude = 41.85003;
      const longitude = -87.6500;

      test('makes correct http request', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        try {
          await apiClient.getWeather(Location(
              name: name,
              country: country,
              latitude: latitude,
              longitude: longitude));
        } catch (_) {}
        verify(
          () => httpClient.get(
            Uri.https('api.open-meteo.com', 'v1/forecast', {
              'latitude': '$latitude',
              'longitude': '$longitude',
              'current':
                  'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m',
              'hourly':
                  'weather_code,temperature_2m,wind_speed_10m,wind_direction_10m,pressure_msl',
              'daily':
                  'weather_code,temperature_2m_max,temperature_2m_min,wind_speed_10m_max,wind_direction_10m_dominant,uv_index_max,precipitation_probability_max,sunrise,sunset',
            }),
          ),
        ).called(1);

        verify(
          () => httpClient.get(
            Uri.https('air-quality-api.open-meteo.com', 'v1/air-quality', {
              'latitude': '$latitude',
              'longitude': '$longitude',
              'current':
                  'european_aqi,pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide,ozone',
            }),
          ),
        ).called(1);
      });

      test('throws WeatherRequestFailure on non-200 response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(400);
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        expect(
          () async => apiClient.getWeather(Location(
              name: name,
              country: country,
              latitude: latitude,
              longitude: longitude)),
          throwsA(isA<WeatherRequestFailure>()),
        );
      });

      test('throws WeatherNotFoundFailure on empty response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        expect(
          () async => apiClient.getWeather(Location(
              name: name,
              country: country,
              latitude: latitude,
              longitude: longitude)),
          throwsA(isA<WeatherNotFoundFailure>()),
        );
      });

      test('returns weather on valid response', () async {
        final aqiResponse = MockResponse();
        final weatherResponse = MockResponse();

        when(() => aqiResponse.statusCode).thenReturn(200);
        when(() => aqiResponse.body).thenReturn('''
{
  "latitude": 52.5,
  "longitude": 13.400002,
  "generationtime_ms": 0.138998031616211,
  "utc_offset_seconds": 0,
  "timezone": "GMT",
  "timezone_abbreviation": "GMT",
  "elevation": 38,
  "current_units": {
    "time": "iso8601",
    "interval": "seconds",
    "european_aqi": "EAQI",
    "pm10": "μg/m³",
    "pm2_5": "μg/m³",
    "carbon_monoxide": "μg/m³",
    "nitrogen_dioxide": "μg/m³",
    "sulphur_dioxide": "μg/m³",
    "ozone": "μg/m³"
  },
  "current": {
    "time": "2024-12-03T12:00",
    "interval": 3600,
    "european_aqi": 26,
    "pm10": 9.9,
    "pm2_5": 8.7,
    "carbon_monoxide": 216,
    "nitrogen_dioxide": 19.8,
    "sulphur_dioxide": 1.5,
    "ozone": 36
  }
}
''');

        when(() => weatherResponse.statusCode).thenReturn(200);
        when(() => weatherResponse.body).thenReturn(
          '''
{
  "latitude": 36.6875,
  "longitude": -4.5,
  "generationtime_ms": 0.185966491699219,
  "utc_offset_seconds": 0,
  "timezone": "GMT",
  "timezone_abbreviation": "GMT",
  "elevation": 19,
  "current_units": {
    "time": "iso8601",
    "interval": "seconds",
    "temperature_2m": "°C",
    "relative_humidity_2m": "%",
    "apparent_temperature": "°C",
    "precipitation": "mm",
    "weather_code": "wmo code",
    "wind_speed_10m": "km/h"
  },
  "current": {
    "time": "2024-12-03T15:30",
    "interval": 900,
    "temperature_2m": 21.2,
    "relative_humidity_2m": 51,
    "apparent_temperature": 19.7,
    "precipitation": 0,
    "weather_code": 2,
    "wind_speed_10m": 12.3
  },
  "hourly_units": {
    "time": "iso8601",
    "weather_code": "wmo code",
    "temperature_2m": "°C",
    "wind_speed_10m": "km/h",
    "wind_direction_10m": "°",
    "pressure_msl": "hPa"
  },
  "hourly": {
    "time": [
      "2024-12-03T00:00",
      "2024-12-03T01:00",
      "2024-12-03T02:00",
      "2024-12-03T03:00",
      "2024-12-03T04:00",
      "2024-12-03T05:00",
      "2024-12-03T06:00",
      "2024-12-03T07:00",
      "2024-12-03T08:00",
      "2024-12-03T09:00",
      "2024-12-03T10:00",
      "2024-12-03T11:00",
      "2024-12-03T12:00",
      "2024-12-03T13:00",
      "2024-12-03T14:00",
      "2024-12-03T15:00",
      "2024-12-03T16:00",
      "2024-12-03T17:00",
      "2024-12-03T18:00",
      "2024-12-03T19:00",
      "2024-12-03T20:00",
      "2024-12-03T21:00",
      "2024-12-03T22:00",
      "2024-12-03T23:00",
      "2024-12-04T00:00",
      "2024-12-04T01:00",
      "2024-12-04T02:00",
      "2024-12-04T03:00",
      "2024-12-04T04:00",
      "2024-12-04T05:00",
      "2024-12-04T06:00",
      "2024-12-04T07:00",
      "2024-12-04T08:00",
      "2024-12-04T09:00",
      "2024-12-04T10:00",
      "2024-12-04T11:00",
      "2024-12-04T12:00",
      "2024-12-04T13:00",
      "2024-12-04T14:00",
      "2024-12-04T15:00",
      "2024-12-04T16:00",
      "2024-12-04T17:00",
      "2024-12-04T18:00",
      "2024-12-04T19:00",
      "2024-12-04T20:00",
      "2024-12-04T21:00",
      "2024-12-04T22:00",
      "2024-12-04T23:00",
      "2024-12-05T00:00",
      "2024-12-05T01:00",
      "2024-12-05T02:00",
      "2024-12-05T03:00",
      "2024-12-05T04:00",
      "2024-12-05T05:00",
      "2024-12-05T06:00",
      "2024-12-05T07:00",
      "2024-12-05T08:00",
      "2024-12-05T09:00",
      "2024-12-05T10:00",
      "2024-12-05T11:00",
      "2024-12-05T12:00",
      "2024-12-05T13:00",
      "2024-12-05T14:00",
      "2024-12-05T15:00",
      "2024-12-05T16:00",
      "2024-12-05T17:00",
      "2024-12-05T18:00",
      "2024-12-05T19:00",
      "2024-12-05T20:00",
      "2024-12-05T21:00",
      "2024-12-05T22:00",
      "2024-12-05T23:00",
      "2024-12-06T00:00",
      "2024-12-06T01:00",
      "2024-12-06T02:00",
      "2024-12-06T03:00",
      "2024-12-06T04:00",
      "2024-12-06T05:00",
      "2024-12-06T06:00",
      "2024-12-06T07:00",
      "2024-12-06T08:00",
      "2024-12-06T09:00",
      "2024-12-06T10:00",
      "2024-12-06T11:00",
      "2024-12-06T12:00",
      "2024-12-06T13:00",
      "2024-12-06T14:00",
      "2024-12-06T15:00",
      "2024-12-06T16:00",
      "2024-12-06T17:00",
      "2024-12-06T18:00",
      "2024-12-06T19:00",
      "2024-12-06T20:00",
      "2024-12-06T21:00",
      "2024-12-06T22:00",
      "2024-12-06T23:00",
      "2024-12-07T00:00",
      "2024-12-07T01:00",
      "2024-12-07T02:00",
      "2024-12-07T03:00",
      "2024-12-07T04:00",
      "2024-12-07T05:00",
      "2024-12-07T06:00",
      "2024-12-07T07:00",
      "2024-12-07T08:00",
      "2024-12-07T09:00",
      "2024-12-07T10:00",
      "2024-12-07T11:00",
      "2024-12-07T12:00",
      "2024-12-07T13:00",
      "2024-12-07T14:00",
      "2024-12-07T15:00",
      "2024-12-07T16:00",
      "2024-12-07T17:00",
      "2024-12-07T18:00",
      "2024-12-07T19:00",
      "2024-12-07T20:00",
      "2024-12-07T21:00",
      "2024-12-07T22:00",
      "2024-12-07T23:00",
      "2024-12-08T00:00",
      "2024-12-08T01:00",
      "2024-12-08T02:00",
      "2024-12-08T03:00",
      "2024-12-08T04:00",
      "2024-12-08T05:00",
      "2024-12-08T06:00",
      "2024-12-08T07:00",
      "2024-12-08T08:00",
      "2024-12-08T09:00",
      "2024-12-08T10:00",
      "2024-12-08T11:00",
      "2024-12-08T12:00",
      "2024-12-08T13:00",
      "2024-12-08T14:00",
      "2024-12-08T15:00",
      "2024-12-08T16:00",
      "2024-12-08T17:00",
      "2024-12-08T18:00",
      "2024-12-08T19:00",
      "2024-12-08T20:00",
      "2024-12-08T21:00",
      "2024-12-08T22:00",
      "2024-12-08T23:00",
      "2024-12-09T00:00",
      "2024-12-09T01:00",
      "2024-12-09T02:00",
      "2024-12-09T03:00",
      "2024-12-09T04:00",
      "2024-12-09T05:00",
      "2024-12-09T06:00",
      "2024-12-09T07:00",
      "2024-12-09T08:00",
      "2024-12-09T09:00",
      "2024-12-09T10:00",
      "2024-12-09T11:00",
      "2024-12-09T12:00",
      "2024-12-09T13:00",
      "2024-12-09T14:00",
      "2024-12-09T15:00",
      "2024-12-09T16:00",
      "2024-12-09T17:00",
      "2024-12-09T18:00",
      "2024-12-09T19:00",
      "2024-12-09T20:00",
      "2024-12-09T21:00",
      "2024-12-09T22:00",
      "2024-12-09T23:00"
    ],
    "weather_code": [2, 2, 2, 2, 2, 2, 2, 1, 1, 0, 0, 0, 0, 0, 2, 2, 3, 3, 3, 3, 3, 3, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 2, 0, 1, 2, 3, 1, 1, 0, 0, 0, 0, 3, 3, 3, 1, 2, 0, 0, 0, 1, 1, 0, 0, 0, 0, 3, 1, 2, 0, 1, 0, 1, 0, 0, 0, 1, 2, 1, 3, 3, 2, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    "temperature_2m": [14.2, 13.8, 13.6, 13, 12.8, 12.6, 12.3, 12.3, 13.1, 16.2, 18.9, 20.6, 21, 21.5, 21.6, 21.6, 20.9, 19.4, 18.2, 17.7, 17.2, 16.8, 16.5, 16.1, 15.7, 15.6, 15.5, 15.2, 15.2, 15.1, 15, 15, 14.8, 15.9, 16.9, 17.5, 18.2, 18.9, 19.1, 18.9, 18.4, 17.3, 16.8, 16.7, 16.5, 16.3, 15.7, 15.3, 14.7, 14.3, 13.9, 13.5, 13.1, 13.5, 13.4, 12.9, 12.4, 14.3, 16.5, 17.9, 19.2, 20.1, 20.5, 20.4, 19.7, 18.3, 16.4, 14.7, 14.1, 14.2, 13.8, 13.1, 12.6, 12.5, 12.4, 11.7, 11.2, 10.9, 10.6, 10.5, 10.6, 12.7, 15.8, 17.4, 18.9, 20.1, 20.9, 21, 20.1, 18.4, 16.7, 15.3, 13.8, 12.7, 12.1, 11.9, 11.8, 11.8, 11.9, 12.2, 12.4, 12.6, 13.3, 14.6, 16.4, 18.1, 19.8, 21.3, 22.4, 22.9, 22.8, 22.4, 21.4, 20.1, 19.1, 18.7, 18.6, 18.4, 18.2, 18, 17.6, 17.1, 16.4, 15.8, 15.3, 14.9, 14.6, 16.9, 16.8, 17.1, 18.1, 19.5, 20.2, 19.8, 18.8, 17.8, 17.1, 16.5, 16, 15.6, 15.4, 15.2, 15.1, 15, 14.8, 14.4, 13.9, 13.3, 12.5, 11.7, 11.1, 10.7, 10.6, 10.9, 12.1, 13.7, 14.9, 15.1, 14.7, 14.2, 13.4, 12.3, 11.4, 10.8, 10.2, 9.7, 9.3, 8.9],
    "wind_speed_10m": [6, 6.6, 7, 5.9, 6, 6.8, 7.5, 8.1, 9.5, 10.7, 10.5, 15.4, 15.7, 14, 12.5, 10.2, 14.5, 15.1, 15.9, 13.5, 12.5, 12.4, 11.5, 9.3, 11.2, 13.4, 14.8, 14.1, 14.7, 15.6, 16, 14, 9.2, 11.8, 18.4, 24.4, 24.5, 22.7, 21.9, 20.9, 20.9, 20, 18.1, 18.4, 13.8, 11.6, 12.1, 12.3, 10.1, 9.3, 10.2, 10.2, 9.4, 9.6, 9, 8.8, 8.4, 9.3, 8.4, 6, 4.7, 4.2, 5.4, 6.2, 6.1, 5.4, 4.8, 7.6, 8.7, 9.2, 9.2, 8.7, 9.7, 10.3, 9.4, 8.6, 8.7, 8.2, 8.2, 8.9, 8.4, 7.9, 6.9, 6.1, 3.6, 2.8, 2.4, 2.6, 3.3, 4.8, 5.9, 6.5, 7.1, 7.6, 7.9, 8.1, 8.4, 8.8, 9.4, 9.8, 10.1, 10.2, 11, 12.9, 14.8, 17, 18.8, 20.2, 21.4, 22.7, 24, 24.7, 24.3, 22.9, 21.9, 21.3, 20.3, 19.5, 18.2, 17.1, 15.9, 14.8, 13.9, 13.2, 13.1, 13.1, 13.3, 12.4, 10.7, 8.4, 5.7, 2.6, 1.8, 7, 13.3, 16.8, 14.8, 9.6, 6, 5.2, 5.5, 5.4, 4.8, 4.1, 2.7, 1.4, 5.7, 9.2, 11, 11.7, 12, 12.2, 12, 12.5, 14.8, 19.7, 24.2, 26.3, 27.2, 26.8, 24.5, 21.2, 18.4, 16.7, 15.8, 15.3, 15.5, 16.3],
    "wind_direction_10m": [295, 279, 282, 281, 295, 288, 287, 283, 281, 284, 292, 307, 307, 305, 303, 302, 316, 310, 303, 304, 303, 300, 290, 286, 291, 290, 288, 289, 295, 299, 293, 288, 291, 290, 298, 304, 311, 319, 316, 306, 311, 308, 305, 305, 298, 292, 297, 302, 297, 298, 288, 293, 293, 290, 293, 289, 290, 286, 290, 287, 279, 250, 266, 260, 225, 222, 283, 301, 294, 291, 291, 300, 301, 299, 293, 292, 294, 285, 293, 291, 295, 286, 298, 310, 307, 310, 297, 286, 283, 283, 284, 289, 294, 295, 294, 291, 290, 289, 288, 287, 287, 288, 289, 288, 288, 287, 287, 286, 287, 290, 296, 299, 299, 298, 297, 298, 300, 300, 297, 292, 288, 288, 291, 292, 291, 291, 289, 324, 327, 329, 325, 304, 191, 145, 139, 137, 139, 146, 155, 155, 148, 143, 138, 128, 113, 360, 325, 321, 319, 317, 316, 313, 311, 316, 334, 351, 357, 356, 352, 349, 346, 339, 334, 335, 339, 341, 338, 335],
    "pressure_msl": [1022.8, 1022.8, 1022.7, 1022.5, 1022.4, 1022.2, 1022.4, 1022.7, 1022.9, 1023.9, 1023.6, 1023.9, 1022.8, 1022.4, 1021.7, 1021.3, 1021.3, 1021.5, 1022, 1022.5, 1023.1, 1023.2, 1022.9, 1022.2, 1022.7, 1022.6, 1022.5, 1022.1, 1022.3, 1022.4, 1022.8, 1023.2, 1024.5, 1025.3, 1025.8, 1025.7, 1025.4, 1025.3, 1025.3, 1025.6, 1025.7, 1026.2, 1026.7, 1027.4, 1028, 1028.5, 1028.7, 1028.7, 1028.6, 1028.8, 1029.4, 1029.7, 1029.5, 1029.7, 1029.9, 1030.2, 1030.4, 1031, 1031.7, 1031.5, 1030.8, 1030.2, 1029.6, 1029.3, 1029.2, 1029.4, 1030, 1030.5, 1030.4, 1030.6, 1030.5, 1030.5, 1030.6, 1030.4, 1030.7, 1030.5, 1030.3, 1030.2, 1030.7, 1031.4, 1032.1, 1032.4, 1032.6, 1032.5, 1031.4, 1030.6, 1029.6, 1028.9, 1028.8, 1029.1, 1029.4, 1029.6, 1029.9, 1030, 1029.8, 1029.5, 1029.2, 1029, 1028.7, 1028.5, 1028.2, 1027.9, 1027.8, 1028, 1028.4, 1028.5, 1028.2, 1027.6, 1027, 1026.4, 1025.7, 1025.3, 1025.3, 1025.5, 1025.7, 1025.9, 1026.2, 1026.4, 1026.5, 1026.5, 1026.5, 1026.5, 1026.4, 1026.5, 1026.7, 1027.1, 1027.3, 1024.1, 1024.8, 1025.4, 1025.8, 1026.1, 1026.2, 1026.1, 1025.8, 1025.6, 1025.6, 1025.6, 1025.6, 1025.6, 1025.6, 1025.5, 1025.3, 1024.9, 1024.6, 1024.2, 1023.9, 1023.6, 1023.4, 1023.3, 1023.3, 1023.6, 1024, 1024.2, 1023.9, 1023.3, 1022.7, 1022.2, 1021.8, 1021.6, 1021.8, 1022.2, 1022.6, 1023, 1023.4, 1023.8, 1024.2, 1024.5]
  },
  "daily_units": {
    "time": "iso8601",
    "weather_code": "wmo code",
    "temperature_2m_max": "°C",
    "temperature_2m_min": "°C",
    "wind_speed_10m_max": "km/h",
    "wind_direction_10m_dominant": "°",
    "uv_index_max": "",
    "precipitation_probability_max": "%",
    "sunrise": "iso8601",
    "sunset": "iso8601"
  },
  "daily": {
    "time": [
      "2024-12-03",
      "2024-12-04",
      "2024-12-05",
      "2024-12-06",
      "2024-12-07",
      "2024-12-08",
      "2024-12-09"
    ],
    "weather_code": [3, 3, 3, 3, 3, 3, 3],
    "temperature_2m_max": [21.6, 19.1, 20.5, 21, 22.9, 20.2, 15.1],
    "temperature_2m_min": [12.3, 14.8, 12.4, 10.5, 11.8, 14.6, 8.9],
    "wind_speed_10m_max": [15.9, 24.5, 10.2, 10.3, 24.7, 16.8, 27.2],
    "wind_direction_10m_dominant": [298, 301, 286, 294, 293, 262, 339],
    "uv_index_max": [3.15, 3.15, 3.2, 2.95, 3.1, 2.4, 2.8],
    "precipitation_probability_max": [0, 0, 0, 0, 0, 0, 0],
    "sunrise": [
      "2024-12-03T07:14",
      "2024-12-04T07:14",
      "2024-12-05T07:15",
      "2024-12-06T07:16",
      "2024-12-07T07:17",
      "2024-12-08T07:18",
      "2024-12-09T07:19"
    ],
    "sunset": [
      "2024-12-03T17:01",
      "2024-12-04T17:01",
      "2024-12-05T17:01",
      "2024-12-06T17:01",
      "2024-12-07T17:01",
      "2024-12-08T17:01",
      "2024-12-09T17:02"
    ]
  }
}
        ''',
        );

        when(() => httpClient.get(
              Uri.https('api.open-meteo.com', 'v1/forecast', {
                'latitude': '$latitude',
                'longitude': '$longitude',
                'current':
                    'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m',
                'hourly':
                    'weather_code,temperature_2m,wind_speed_10m,wind_direction_10m,pressure_msl',
                'daily':
                    'weather_code,temperature_2m_max,temperature_2m_min,wind_speed_10m_max,wind_direction_10m_dominant,uv_index_max,precipitation_probability_max,sunrise,sunset',
              }),
            )).thenAnswer((_) async => weatherResponse);

        when(() => httpClient.get(
                Uri.https('air-quality-api.open-meteo.com', 'v1/air-quality', {
              'latitude': '$latitude',
              'longitude': '$longitude',
              'current':
                  'european_aqi,pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide,ozone',
            }))).thenAnswer((_) async => aqiResponse);

        final weather = await apiClient.getWeather(Location(
            name: name,
            country: country,
            latitude: latitude,
            longitude: longitude));
        expect(
            weather.current,
            isA<Current>()
                .having((c) => c.temperature, 'temperature', 21.2)
                .having((c) => c.humidity, 'relative_humidity', 51)
                .having((c) => c.feelsLikeTemperature, 'feels_like_temperature',
                    19.7)
                .having(
                    (c) => c.condition, 'condition', WeatherCondition.cloudy)
                .having(
                    (c) => c.aqi,
                    'aqi',
                    isA<Aqi>()
                        .having((a) => a.aqi, 'aqi', 26)
                        .having(
                            (a) => a.condition, 'condition', AqiCondition.fair)
                        .having((a) => a.pm10, 'pm10', 9.9)
                        .having((a) => a.pm25, 'pm25', 8.7)
                        .having(
                            (a) => a.carbonMonoxide, 'carbonMonoxide', 216.0)
                        .having(
                            (a) => a.nitrogenDioxide, 'nitrogenDioxide', 19.8)
                        .having((a) => a.sulphurDioxide, 'sulphurDioxide', 1.5)
                        .having((a) => a.ozone, 'ozone', 36.0)));

        expect(
            weather.daily[0],
            isA<Daily>()
                .having((d) => d.time, 'time', DateTime.parse('2024-12-03'))
                .having((d) => d.sunrise, 'sunrise',
                    DateTime.parse('2024-12-03T07:14'))
                .having((d) => d.sunset, 'sunset',
                    DateTime.parse('2024-12-03T17:01'))
                .having((d) => d.maxTemperature, 'max_temperature', 21.6)
                .having((d) => d.minTemperature, 'min_temperature', 12.3)
                .having((d) => d.maxWindSpeed, 'wind_speed', 15.9)
                .having((d) => d.maxWindDirection, 'wind_direction', 298)
                .having((d) => d.maxSeaPressure, 'max_sea_pressure', 1023.9)
                .having((d) => d.uvIndex, 'uv_index', 3)
                .having((d) => d.precipitationProbability,
                    'precipitation_probability', 0)
                .having((d) => d.hourly, 'hourly', [
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-03T00:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 14.2)
                  .having((h) => h.windSpeed, 'wind_speed', 6)
                  .having((h) => h.windDirection, 'wind_direction', 295),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-03T01:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 13.8)
                  .having((h) => h.windSpeed, 'wind_speed', 6.6)
                  .having((h) => h.windDirection, 'wind_direction', 279),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-03T02:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 13.6)
                  .having((h) => h.windSpeed, 'wind_speed', 7.0)
                  .having((h) => h.windDirection, 'wind_direction', 282),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-03T03:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 13.0)
                  .having((h) => h.windSpeed, 'wind_speed', 5.9)
                  .having((h) => h.windDirection, 'wind_direction', 281),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-03T04:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 12.8)
                  .having((h) => h.windSpeed, 'wind_speed', 6.0)
                  .having((h) => h.windDirection, 'wind_direction', 295),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-03T05:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 12.6)
                  .having((h) => h.windSpeed, 'wind_speed', 6.8)
                  .having((h) => h.windDirection, 'wind_direction', 288),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-03T06:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 12.3)
                  .having((h) => h.windSpeed, 'wind_speed', 7.5)
                  .having((h) => h.windDirection, 'wind_direction', 287),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-03T07:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 12.3)
                  .having((h) => h.windSpeed, 'wind_speed', 8.1)
                  .having((h) => h.windDirection, 'wind_direction', 283),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-03T08:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 13.1)
                  .having((h) => h.windSpeed, 'wind_speed', 9.5)
                  .having((h) => h.windDirection, 'wind_direction', 281),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-03T09:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 16.2)
                  .having((h) => h.windSpeed, 'wind_speed', 10.7)
                  .having((h) => h.windDirection, 'wind_direction', 284),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-03T10:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 18.9)
                  .having((h) => h.windSpeed, 'wind_speed', 10.5)
                  .having((h) => h.windDirection, 'wind_direction', 292),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-03T11:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 20.6)
                  .having((h) => h.windSpeed, 'wind_speed', 15.4)
                  .having((h) => h.windDirection, 'wind_direction', 307),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-03T12:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 21.0)
                  .having((h) => h.windSpeed, 'wind_speed', 15.7)
                  .having((h) => h.windDirection, 'wind_direction', 307),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-03T13:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 21.5)
                  .having((h) => h.windSpeed, 'wind_speed', 14.0)
                  .having((h) => h.windDirection, 'wind_direction', 305),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-03T14:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 21.6)
                  .having((h) => h.windSpeed, 'wind_speed', 12.5)
                  .having((h) => h.windDirection, 'wind_direction', 303),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-03T15:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 21.6)
                  .having((h) => h.windSpeed, 'wind_speed', 10.2)
                  .having((h) => h.windDirection, 'wind_direction', 302),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-03T16:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 20.9)
                  .having((h) => h.windSpeed, 'wind_speed', 14.5)
                  .having((h) => h.windDirection, 'wind_direction', 316),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-03T17:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 19.4)
                  .having((h) => h.windSpeed, 'wind_speed', 15.1)
                  .having((h) => h.windDirection, 'wind_direction', 310),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-03T18:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 18.2)
                  .having((h) => h.windSpeed, 'wind_speed', 15.9)
                  .having((h) => h.windDirection, 'wind_direction', 303),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-03T19:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 17.7)
                  .having((h) => h.windSpeed, 'wind_speed', 13.5)
                  .having((h) => h.windDirection, 'wind_direction', 304),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-03T20:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 17.2)
                  .having((h) => h.windSpeed, 'wind_speed', 12.5)
                  .having((h) => h.windDirection, 'wind_direction', 303),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-03T21:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 16.8)
                  .having((h) => h.windSpeed, 'wind_speed', 12.4)
                  .having((h) => h.windDirection, 'wind_direction', 300),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-03T22:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 16.5)
                  .having((h) => h.windSpeed, 'wind_speed', 11.5)
                  .having((h) => h.windDirection, 'wind_direction', 290),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-03T23:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 16.1)
                  .having((h) => h.windSpeed, 'wind_speed', 9.3)
                  .having((h) => h.windDirection, 'wind_direction', 286),
            ]));

        expect(
            weather.daily[1],
            isA<Daily>()
                .having((d) => d.time, 'time', DateTime.parse('2024-12-04'))
                .having((d) => d.sunrise, 'sunrise',
                    DateTime.parse('2024-12-04T07:14'))
                .having((d) => d.sunset, 'sunset',
                    DateTime.parse('2024-12-04T17:01'))
                .having((d) => d.maxTemperature, 'max_temperature', 19.1)
                .having((d) => d.minTemperature, 'min_temperature', 14.8)
                .having((d) => d.maxWindSpeed, 'wind_speed', 24.5)
                .having((d) => d.maxWindDirection, 'wind_direction', 301)
                .having((d) => d.maxSeaPressure, 'max_sea_pressure', 1028.7)
                .having((d) => d.uvIndex, 'uv_index', 3)
                .having((d) => d.precipitationProbability,
                    'precipitation_probability', 0)
                .having((d) => d.hourly, 'hourly', [
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-04T00:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 15.7)
                  .having((h) => h.windSpeed, 'wind_speed', 11.2)
                  .having((h) => h.windDirection, 'wind_direction', 291),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-04T01:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 15.6)
                  .having((h) => h.windSpeed, 'wind_speed', 13.4)
                  .having((h) => h.windDirection, 'wind_direction', 290),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-04T02:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 15.5)
                  .having((h) => h.windSpeed, 'wind_speed', 14.8)
                  .having((h) => h.windDirection, 'wind_direction', 288),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-04T03:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 15.2)
                  .having((h) => h.windSpeed, 'wind_speed', 14.1)
                  .having((h) => h.windDirection, 'wind_direction', 289),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-04T04:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 15.2)
                  .having((h) => h.windSpeed, 'wind_speed', 14.7)
                  .having((h) => h.windDirection, 'wind_direction', 295),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-04T05:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 15.1)
                  .having((h) => h.windSpeed, 'wind_speed', 15.6)
                  .having((h) => h.windDirection, 'wind_direction', 299),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-04T06:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 15.0)
                  .having((h) => h.windSpeed, 'wind_speed', 16.0)
                  .having((h) => h.windDirection, 'wind_direction', 293),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-04T07:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 15.0)
                  .having((h) => h.windSpeed, 'wind_speed', 14.0)
                  .having((h) => h.windDirection, 'wind_direction', 288),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-04T08:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 14.8)
                  .having((h) => h.windSpeed, 'wind_speed', 9.2)
                  .having((h) => h.windDirection, 'wind_direction', 291),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-04T09:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 15.9)
                  .having((h) => h.windSpeed, 'wind_speed', 11.8)
                  .having((h) => h.windDirection, 'wind_direction', 290),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-04T10:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 16.9)
                  .having((h) => h.windSpeed, 'wind_speed', 18.4)
                  .having((h) => h.windDirection, 'wind_direction', 298),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-04T11:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 17.5)
                  .having((h) => h.windSpeed, 'wind_speed', 24.4)
                  .having((h) => h.windDirection, 'wind_direction', 304),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-04T12:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 18.2)
                  .having((h) => h.windSpeed, 'wind_speed', 24.5)
                  .having((h) => h.windDirection, 'wind_direction', 311),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-04T13:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 18.9)
                  .having((h) => h.windSpeed, 'wind_speed', 22.7)
                  .having((h) => h.windDirection, 'wind_direction', 319),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-04T14:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 19.1)
                  .having((h) => h.windSpeed, 'wind_speed', 21.9)
                  .having((h) => h.windDirection, 'wind_direction', 316),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-04T15:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 18.9)
                  .having((h) => h.windSpeed, 'wind_speed', 20.9)
                  .having((h) => h.windDirection, 'wind_direction', 306),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-04T16:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 18.4)
                  .having((h) => h.windSpeed, 'wind_speed', 20.9)
                  .having((h) => h.windDirection, 'wind_direction', 311),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-04T17:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 17.3)
                  .having((h) => h.windSpeed, 'wind_speed', 20.0)
                  .having((h) => h.windDirection, 'wind_direction', 308),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-04T18:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 16.8)
                  .having((h) => h.windSpeed, 'wind_speed', 18.1)
                  .having((h) => h.windDirection, 'wind_direction', 305),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-04T19:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 16.7)
                  .having((h) => h.windSpeed, 'wind_speed', 18.4)
                  .having((h) => h.windDirection, 'wind_direction', 305),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-04T20:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 16.5)
                  .having((h) => h.windSpeed, 'wind_speed', 13.8)
                  .having((h) => h.windDirection, 'wind_direction', 298),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-04T21:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 16.3)
                  .having((h) => h.windSpeed, 'wind_speed', 11.6)
                  .having((h) => h.windDirection, 'wind_direction', 292),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-04T22:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 15.7)
                  .having((h) => h.windSpeed, 'wind_speed', 12.1)
                  .having((h) => h.windDirection, 'wind_direction', 297),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-04T23:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 15.3)
                  .having((h) => h.windSpeed, 'wind_speed', 12.3)
                  .having((h) => h.windDirection, 'wind_direction', 302),
            ]));

        expect(
            weather.daily[2],
            isA<Daily>()
                .having((d) => d.time, 'time', DateTime.parse('2024-12-05'))
                .having((d) => d.sunrise, 'sunrise',
                    DateTime.parse('2024-12-05T07:15'))
                .having((d) => d.sunset, 'sunset',
                    DateTime.parse('2024-12-05T17:01'))
                .having((d) => d.maxTemperature, 'max_temperature', 20.5)
                .having((d) => d.minTemperature, 'min_temperature', 12.4)
                .having((d) => d.maxWindSpeed, 'wind_speed', 10.2)
                .having((d) => d.maxWindDirection, 'wind_direction', 286)
                .having((d) => d.maxSeaPressure, 'max_sea_pressure', 1031.7)
                .having((d) => d.uvIndex, 'uv_index', 3)
                .having((d) => d.precipitationProbability,
                    'precipitation_probability', 0)
                .having((d) => d.hourly, 'hourly', [
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-05T00:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 14.7)
                  .having((h) => h.windSpeed, 'wind_speed', 10.1)
                  .having((h) => h.windDirection, 'wind_direction', 297),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-05T01:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 14.3)
                  .having((h) => h.windSpeed, 'wind_speed', 9.3)
                  .having((h) => h.windDirection, 'wind_direction', 298),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-05T02:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 13.9)
                  .having((h) => h.windSpeed, 'wind_speed', 10.2)
                  .having((h) => h.windDirection, 'wind_direction', 288),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-05T03:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 13.5)
                  .having((h) => h.windSpeed, 'wind_speed', 10.2)
                  .having((h) => h.windDirection, 'wind_direction', 293),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-05T04:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 13.1)
                  .having((h) => h.windSpeed, 'wind_speed', 9.4)
                  .having((h) => h.windDirection, 'wind_direction', 293),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-05T05:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 13.5)
                  .having((h) => h.windSpeed, 'wind_speed', 9.6)
                  .having((h) => h.windDirection, 'wind_direction', 290),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-05T06:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 13.4)
                  .having((h) => h.windSpeed, 'wind_speed', 9.0)
                  .having((h) => h.windDirection, 'wind_direction', 293),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-05T07:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 12.9)
                  .having((h) => h.windSpeed, 'wind_speed', 8.8)
                  .having((h) => h.windDirection, 'wind_direction', 289),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-05T08:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 12.4)
                  .having((h) => h.windSpeed, 'wind_speed', 8.4)
                  .having((h) => h.windDirection, 'wind_direction', 290),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-05T09:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 14.3)
                  .having((h) => h.windSpeed, 'wind_speed', 9.3)
                  .having((h) => h.windDirection, 'wind_direction', 286),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-05T10:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 16.5)
                  .having((h) => h.windSpeed, 'wind_speed', 8.4)
                  .having((h) => h.windDirection, 'wind_direction', 290),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-05T11:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 17.9)
                  .having((h) => h.windSpeed, 'wind_speed', 6.0)
                  .having((h) => h.windDirection, 'wind_direction', 287),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-05T12:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 19.2)
                  .having((h) => h.windSpeed, 'wind_speed', 4.7)
                  .having((h) => h.windDirection, 'wind_direction', 279),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-05T13:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 20.1)
                  .having((h) => h.windSpeed, 'wind_speed', 4.2)
                  .having((h) => h.windDirection, 'wind_direction', 250),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-05T14:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 20.5)
                  .having((h) => h.windSpeed, 'wind_speed', 5.4)
                  .having((h) => h.windDirection, 'wind_direction', 266),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-05T15:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 20.4)
                  .having((h) => h.windSpeed, 'wind_speed', 6.2)
                  .having((h) => h.windDirection, 'wind_direction', 260),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-05T16:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 19.7)
                  .having((h) => h.windSpeed, 'wind_speed', 6.1)
                  .having((h) => h.windDirection, 'wind_direction', 225),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-05T17:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 18.3)
                  .having((h) => h.windSpeed, 'wind_speed', 5.4)
                  .having((h) => h.windDirection, 'wind_direction', 222),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-05T18:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 16.4)
                  .having((h) => h.windSpeed, 'wind_speed', 4.8)
                  .having((h) => h.windDirection, 'wind_direction', 283),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-05T19:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 14.7)
                  .having((h) => h.windSpeed, 'wind_speed', 7.6)
                  .having((h) => h.windDirection, 'wind_direction', 301),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-05T20:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 14.1)
                  .having((h) => h.windSpeed, 'wind_speed', 8.7)
                  .having((h) => h.windDirection, 'wind_direction', 294),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-05T21:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 14.2)
                  .having((h) => h.windSpeed, 'wind_speed', 9.2)
                  .having((h) => h.windDirection, 'wind_direction', 291),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-05T22:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 13.8)
                  .having((h) => h.windSpeed, 'wind_speed', 9.2)
                  .having((h) => h.windDirection, 'wind_direction', 291),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-05T23:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 13.1)
                  .having((h) => h.windSpeed, 'wind_speed', 8.7)
                  .having((h) => h.windDirection, 'wind_direction', 300),
            ]));

        expect(
            weather.daily[3],
            isA<Daily>()
                .having((d) => d.time, 'time', DateTime.parse('2024-12-06'))
                .having((d) => d.sunrise, 'sunrise',
                    DateTime.parse('2024-12-06T07:16'))
                .having((d) => d.sunset, 'sunset',
                    DateTime.parse('2024-12-06T17:01'))
                .having((d) => d.maxTemperature, 'max_temperature', 21.0)
                .having((d) => d.minTemperature, 'min_temperature', 10.5)
                .having((d) => d.maxWindSpeed, 'wind_speed', 10.3)
                .having((d) => d.maxWindDirection, 'wind_direction', 294)
                .having((d) => d.maxSeaPressure, 'max_sea_pressure', 1032.6)
                .having((d) => d.uvIndex, 'uv_index', 2)
                .having((d) => d.precipitationProbability,
                    'precipitation_probability', 0)
                .having((d) => d.hourly, 'hourly', [
              // Horas anteriores ya agregadas...

              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-06T00:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 12.6)
                  .having((h) => h.windSpeed, 'wind_speed', 9.7)
                  .having((h) => h.windDirection, 'wind_direction', 301),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-06T01:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 12.5)
                  .having((h) => h.windSpeed, 'wind_speed', 10.3)
                  .having((h) => h.windDirection, 'wind_direction', 299),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-06T02:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 12.4)
                  .having((h) => h.windSpeed, 'wind_speed', 9.4)
                  .having((h) => h.windDirection, 'wind_direction', 293),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-06T03:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 11.7)
                  .having((h) => h.windSpeed, 'wind_speed', 8.6)
                  .having((h) => h.windDirection, 'wind_direction', 292),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-06T04:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 11.2)
                  .having((h) => h.windSpeed, 'wind_speed', 8.7)
                  .having((h) => h.windDirection, 'wind_direction', 294),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-06T05:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 10.9)
                  .having((h) => h.windSpeed, 'wind_speed', 8.2)
                  .having((h) => h.windDirection, 'wind_direction', 285),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-06T06:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 10.6)
                  .having((h) => h.windSpeed, 'wind_speed', 8.2)
                  .having((h) => h.windDirection, 'wind_direction', 293),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-06T07:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 10.5)
                  .having((h) => h.windSpeed, 'wind_speed', 8.9)
                  .having((h) => h.windDirection, 'wind_direction', 291),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-06T08:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 10.6)
                  .having((h) => h.windSpeed, 'wind_speed', 8.4)
                  .having((h) => h.windDirection, 'wind_direction', 295),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-06T09:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 12.7)
                  .having((h) => h.windSpeed, 'wind_speed', 7.9)
                  .having((h) => h.windDirection, 'wind_direction', 286),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-06T10:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 15.8)
                  .having((h) => h.windSpeed, 'wind_speed', 6.9)
                  .having((h) => h.windDirection, 'wind_direction', 298),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-06T11:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 17.4)
                  .having((h) => h.windSpeed, 'wind_speed', 6.1)
                  .having((h) => h.windDirection, 'wind_direction', 310),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-06T12:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 18.9)
                  .having((h) => h.windSpeed, 'wind_speed', 3.6)
                  .having((h) => h.windDirection, 'wind_direction', 307),

              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-06T13:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 20.1)
                  .having((h) => h.windSpeed, 'wind_speed', 2.8)
                  .having((h) => h.windDirection, 'wind_direction', 310),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-06T14:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 20.9)
                  .having((h) => h.windSpeed, 'wind_speed', 2.4)
                  .having((h) => h.windDirection, 'wind_direction', 297),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-06T15:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 21.0)
                  .having((h) => h.windSpeed, 'wind_speed', 2.6)
                  .having((h) => h.windDirection, 'wind_direction', 286),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-06T16:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 20.1)
                  .having((h) => h.windSpeed, 'wind_speed', 3.3)
                  .having((h) => h.windDirection, 'wind_direction', 283),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-06T17:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 18.4)
                  .having((h) => h.windSpeed, 'wind_speed', 4.8)
                  .having((h) => h.windDirection, 'wind_direction', 283),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-06T18:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 16.7)
                  .having((h) => h.windSpeed, 'wind_speed', 5.9)
                  .having((h) => h.windDirection, 'wind_direction', 284),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-06T19:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 15.3)
                  .having((h) => h.windSpeed, 'wind_speed', 6.5)
                  .having((h) => h.windDirection, 'wind_direction', 289),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-06T20:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 13.8)
                  .having((h) => h.windSpeed, 'wind_speed', 7.1)
                  .having((h) => h.windDirection, 'wind_direction', 294),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-06T21:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 12.7)
                  .having((h) => h.windSpeed, 'wind_speed', 7.6)
                  .having((h) => h.windDirection, 'wind_direction', 295),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-06T22:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 12.1)
                  .having((h) => h.windSpeed, 'wind_speed', 7.9)
                  .having((h) => h.windDirection, 'wind_direction', 294),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-06T23:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 11.9)
                  .having((h) => h.windSpeed, 'wind_speed', 8.1)
                  .having((h) => h.windDirection, 'wind_direction', 291),
            ]));

        expect(
            weather.daily[4],
            isA<Daily>()
                .having((d) => d.time, 'time', DateTime.parse('2024-12-07'))
                .having((d) => d.sunrise, 'sunrise',
                    DateTime.parse('2024-12-07T07:17'))
                .having((d) => d.sunset, 'sunset',
                    DateTime.parse('2024-12-07T17:01'))
                .having((d) => d.maxTemperature, 'max_temperature', 22.9)
                .having((d) => d.minTemperature, 'min_temperature', 11.8)
                .having((d) => d.maxWindSpeed, 'wind_speed', 24.7)
                .having((d) => d.maxWindDirection, 'wind_direction', 293)
                .having((d) => d.maxSeaPressure, 'max_sea_pressure', 1029.2)
                .having((d) => d.uvIndex, 'uv_index', 3)
                .having((d) => d.precipitationProbability,
                    'precipitation_probability', 0)
                .having((d) => d.hourly, 'hourly', [
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-07T00:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 11.8)
                  .having((h) => h.windSpeed, 'wind_speed', 8.4)
                  .having((h) => h.windDirection, 'wind_direction', 290),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-07T01:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 11.8)
                  .having((h) => h.windSpeed, 'wind_speed', 8.8)
                  .having((h) => h.windDirection, 'wind_direction', 289),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-07T02:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 11.9)
                  .having((h) => h.windSpeed, 'wind_speed', 9.4)
                  .having((h) => h.windDirection, 'wind_direction', 288),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-07T03:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 12.2)
                  .having((h) => h.windSpeed, 'wind_speed', 9.8)
                  .having((h) => h.windDirection, 'wind_direction', 287),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-07T04:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 12.4)
                  .having((h) => h.windSpeed, 'wind_speed', 10.1)
                  .having((h) => h.windDirection, 'wind_direction', 287),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-07T05:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 12.6)
                  .having((h) => h.windSpeed, 'wind_speed', 10.2)
                  .having((h) => h.windDirection, 'wind_direction', 288),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-07T06:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 13.3)
                  .having((h) => h.windSpeed, 'wind_speed', 11.0)
                  .having((h) => h.windDirection, 'wind_direction', 289),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-07T07:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 14.6)
                  .having((h) => h.windSpeed, 'wind_speed', 12.9)
                  .having((h) => h.windDirection, 'wind_direction', 288),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-07T08:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 16.4)
                  .having((h) => h.windSpeed, 'wind_speed', 14.8)
                  .having((h) => h.windDirection, 'wind_direction', 288),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-07T09:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 18.1)
                  .having((h) => h.windSpeed, 'wind_speed', 17.0)
                  .having((h) => h.windDirection, 'wind_direction', 287),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-07T10:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 19.8)
                  .having((h) => h.windSpeed, 'wind_speed', 18.8)
                  .having((h) => h.windDirection, 'wind_direction', 287),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-07T11:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 21.3)
                  .having((h) => h.windSpeed, 'wind_speed', 20.2)
                  .having((h) => h.windDirection, 'wind_direction', 286),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-07T12:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 22.4)
                  .having((h) => h.windSpeed, 'wind_speed', 21.4)
                  .having((h) => h.windDirection, 'wind_direction', 287),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-07T13:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 22.9)
                  .having((h) => h.windSpeed, 'wind_speed', 22.7)
                  .having((h) => h.windDirection, 'wind_direction', 290),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-07T14:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 22.8)
                  .having((h) => h.windSpeed, 'wind_speed', 24.0)
                  .having((h) => h.windDirection, 'wind_direction', 296),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-07T15:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 22.4)
                  .having((h) => h.windSpeed, 'wind_speed', 24.7)
                  .having((h) => h.windDirection, 'wind_direction', 299),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-07T16:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 21.4)
                  .having((h) => h.windSpeed, 'wind_speed', 24.3)
                  .having((h) => h.windDirection, 'wind_direction', 299),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-07T17:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 20.1)
                  .having((h) => h.windSpeed, 'wind_speed', 22.9)
                  .having((h) => h.windDirection, 'wind_direction', 298),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-07T18:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 19.1)
                  .having((h) => h.windSpeed, 'wind_speed', 21.9)
                  .having((h) => h.windDirection, 'wind_direction', 297),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-07T19:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 18.7)
                  .having((h) => h.windSpeed, 'wind_speed', 21.3)
                  .having((h) => h.windDirection, 'wind_direction', 298),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-07T20:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 18.6)
                  .having((h) => h.windSpeed, 'wind_speed', 20.3)
                  .having((h) => h.windDirection, 'wind_direction', 300),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-07T21:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 18.4)
                  .having((h) => h.windSpeed, 'wind_speed', 19.5)
                  .having((h) => h.windDirection, 'wind_direction', 300),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-07T22:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 18.2)
                  .having((h) => h.windSpeed, 'wind_speed', 18.2)
                  .having((h) => h.windDirection, 'wind_direction', 297),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-07T23:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 18.0)
                  .having((h) => h.windSpeed, 'wind_speed', 17.1)
                  .having((h) => h.windDirection, 'wind_direction', 292),
            ]));

        expect(
            weather.daily[5],
            isA<Daily>()
                .having((d) => d.time, 'time', DateTime.parse('2024-12-08'))
                .having((d) => d.sunrise, 'sunrise',
                    DateTime.parse('2024-12-08T07:18'))
                .having((d) => d.sunset, 'sunset',
                    DateTime.parse('2024-12-08T17:01'))
                .having((d) => d.maxTemperature, 'max_temperature', 20.2)
                .having((d) => d.minTemperature, 'min_temperature', 14.6)
                .having((d) => d.maxWindSpeed, 'wind_speed', 16.8)
                .having((d) => d.maxWindDirection, 'wind_direction', 262)
                .having((d) => d.maxSeaPressure, 'max_sea_pressure', 1027.3)
                .having((d) => d.uvIndex, 'uv_index', 2)
                .having((d) => d.precipitationProbability,
                    'precipitation_probability', 0)
                .having((d) => d.hourly, 'hourly', [
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-08T00:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 17.6)
                  .having((h) => h.windSpeed, 'wind_speed', 15.9)
                  .having((h) => h.windDirection, 'wind_direction', 288),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-08T01:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 17.1)
                  .having((h) => h.windSpeed, 'wind_speed', 14.8)
                  .having((h) => h.windDirection, 'wind_direction', 288),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-08T02:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 16.4)
                  .having((h) => h.windSpeed, 'wind_speed', 13.9)
                  .having((h) => h.windDirection, 'wind_direction', 291),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-08T03:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 15.8)
                  .having((h) => h.windSpeed, 'wind_speed', 13.2)
                  .having((h) => h.windDirection, 'wind_direction', 292),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-08T04:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 15.3)
                  .having((h) => h.windSpeed, 'wind_speed', 13.1)
                  .having((h) => h.windDirection, 'wind_direction', 291),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-08T05:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 14.9)
                  .having((h) => h.windSpeed, 'wind_speed', 13.1)
                  .having((h) => h.windDirection, 'wind_direction', 291),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-08T06:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 14.6)
                  .having((h) => h.windSpeed, 'wind_speed', 13.3)
                  .having((h) => h.windDirection, 'wind_direction', 289),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-08T07:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 16.9)
                  .having((h) => h.windSpeed, 'wind_speed', 12.4)
                  .having((h) => h.windDirection, 'wind_direction', 324),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-08T08:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 16.8)
                  .having((h) => h.windSpeed, 'wind_speed', 10.7)
                  .having((h) => h.windDirection, 'wind_direction', 327),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-08T09:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 17.1)
                  .having((h) => h.windSpeed, 'wind_speed', 8.4)
                  .having((h) => h.windDirection, 'wind_direction', 329),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-08T10:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 18.1)
                  .having((h) => h.windSpeed, 'wind_speed', 5.7)
                  .having((h) => h.windDirection, 'wind_direction', 325),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-08T11:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 19.5)
                  .having((h) => h.windSpeed, 'wind_speed', 2.6)
                  .having((h) => h.windDirection, 'wind_direction', 304),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-08T12:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 20.2)
                  .having((h) => h.windSpeed, 'wind_speed', 1.8)
                  .having((h) => h.windDirection, 'wind_direction', 191),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-08T13:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 19.8)
                  .having((h) => h.windSpeed, 'wind_speed', 7.0)
                  .having((h) => h.windDirection, 'wind_direction', 145),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-08T14:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 18.8)
                  .having((h) => h.windSpeed, 'wind_speed', 13.3)
                  .having((h) => h.windDirection, 'wind_direction', 139),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-08T15:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 17.8)
                  .having((h) => h.windSpeed, 'wind_speed', 16.8)
                  .having((h) => h.windDirection, 'wind_direction', 137),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-08T16:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 17.1)
                  .having((h) => h.windSpeed, 'wind_speed', 14.8)
                  .having((h) => h.windDirection, 'wind_direction', 139),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-08T17:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 16.5)
                  .having((h) => h.windSpeed, 'wind_speed', 9.6)
                  .having((h) => h.windDirection, 'wind_direction', 146),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-08T18:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 16.0)
                  .having((h) => h.windSpeed, 'wind_speed', 6.0)
                  .having((h) => h.windDirection, 'wind_direction', 155),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-08T19:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 15.6)
                  .having((h) => h.windSpeed, 'wind_speed', 5.2)
                  .having((h) => h.windDirection, 'wind_direction', 155),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-08T20:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 15.4)
                  .having((h) => h.windSpeed, 'wind_speed', 5.5)
                  .having((h) => h.windDirection, 'wind_direction', 148),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-08T21:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 15.2)
                  .having((h) => h.windSpeed, 'wind_speed', 5.4)
                  .having((h) => h.windDirection, 'wind_direction', 143),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-08T22:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 15.1)
                  .having((h) => h.windSpeed, 'wind_speed', 4.8)
                  .having((h) => h.windDirection, 'wind_direction', 138),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-08T23:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 15.0)
                  .having((h) => h.windSpeed, 'wind_speed', 4.1)
                  .having((h) => h.windDirection, 'wind_direction', 128),
            ]));

        expect(
            weather.daily[6],
            isA<Daily>()
                .having((d) => d.time, 'time', DateTime.parse('2024-12-09'))
                .having((d) => d.sunrise, 'sunrise',
                    DateTime.parse('2024-12-09T07:19'))
                .having((d) => d.sunset, 'sunset',
                    DateTime.parse('2024-12-09T17:02'))
                .having((d) => d.maxTemperature, 'max_temperature', 15.1)
                .having((d) => d.minTemperature, 'min_temperature', 8.9)
                .having((d) => d.maxWindSpeed, 'wind_speed', 27.2)
                .having((d) => d.maxWindDirection, 'wind_direction', 339)
                .having((d) => d.maxSeaPressure, 'max_sea_pressure', 1024.6)
                .having((d) => d.uvIndex, 'uv_index', 2)
                .having((d) => d.precipitationProbability,
                    'precipitation_probability', 0)
                .having((d) => d.hourly, 'hourly', [
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-09T00:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 14.8)
                  .having((h) => h.windSpeed, 'wind_speed', 2.7)
                  .having((h) => h.windDirection, 'wind_direction', 113),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-09T01:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 14.4)
                  .having((h) => h.windSpeed, 'wind_speed', 1.4)
                  .having((h) => h.windDirection, 'wind_direction', 360),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-09T02:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 13.9)
                  .having((h) => h.windSpeed, 'wind_speed', 5.7)
                  .having((h) => h.windDirection, 'wind_direction', 325),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-09T03:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.cloudy)
                  .having((h) => h.temperature, 'temperature', 13.3)
                  .having((h) => h.windSpeed, 'wind_speed', 9.2)
                  .having((h) => h.windDirection, 'wind_direction', 321),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-09T04:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 12.5)
                  .having((h) => h.windSpeed, 'wind_speed', 11.0)
                  .having((h) => h.windDirection, 'wind_direction', 319),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-09T05:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 11.7)
                  .having((h) => h.windSpeed, 'wind_speed', 11.7)
                  .having((h) => h.windDirection, 'wind_direction', 317),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-09T06:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 11.1)
                  .having((h) => h.windSpeed, 'wind_speed', 12.0)
                  .having((h) => h.windDirection, 'wind_direction', 316),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-09T07:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 10.7)
                  .having((h) => h.windSpeed, 'wind_speed', 12.2)
                  .having((h) => h.windDirection, 'wind_direction', 313),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-09T08:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 10.6)
                  .having((h) => h.windSpeed, 'wind_speed', 12.0)
                  .having((h) => h.windDirection, 'wind_direction', 311),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-09T09:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 10.9)
                  .having((h) => h.windSpeed, 'wind_speed', 12.5)
                  .having((h) => h.windDirection, 'wind_direction', 316),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-09T10:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 12.1)
                  .having((h) => h.windSpeed, 'wind_speed', 14.8)
                  .having((h) => h.windDirection, 'wind_direction', 334),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-09T11:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 13.7)
                  .having((h) => h.windSpeed, 'wind_speed', 19.7)
                  .having((h) => h.windDirection, 'wind_direction', 351),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-09T12:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 14.9)
                  .having((h) => h.windSpeed, 'wind_speed', 24.2)
                  .having((h) => h.windDirection, 'wind_direction', 357),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-09T13:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 15.1)
                  .having((h) => h.windSpeed, 'wind_speed', 26.3)
                  .having((h) => h.windDirection, 'wind_direction', 356),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-09T14:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 14.7)
                  .having((h) => h.windSpeed, 'wind_speed', 27.2)
                  .having((h) => h.windDirection, 'wind_direction', 352),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-09T15:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 14.2)
                  .having((h) => h.windSpeed, 'wind_speed', 26.8)
                  .having((h) => h.windDirection, 'wind_direction', 349),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-09T16:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 13.4)
                  .having((h) => h.windSpeed, 'wind_speed', 24.5)
                  .having((h) => h.windDirection, 'wind_direction', 346),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-09T17:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 12.3)
                  .having((h) => h.windSpeed, 'wind_speed', 21.2)
                  .having((h) => h.windDirection, 'wind_direction', 339),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-09T18:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 11.4)
                  .having((h) => h.windSpeed, 'wind_speed', 18.4)
                  .having((h) => h.windDirection, 'wind_direction', 334),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-09T19:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 10.8)
                  .having((h) => h.windSpeed, 'wind_speed', 16.7)
                  .having((h) => h.windDirection, 'wind_direction', 335),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-09T20:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 10.2)
                  .having((h) => h.windSpeed, 'wind_speed', 15.8)
                  .having((h) => h.windDirection, 'wind_direction', 339),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-09T21:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 9.7)
                  .having((h) => h.windSpeed, 'wind_speed', 15.3)
                  .having((h) => h.windDirection, 'wind_direction', 341),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-09T22:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 9.3)
                  .having((h) => h.windSpeed, 'wind_speed', 15.5)
                  .having((h) => h.windDirection, 'wind_direction', 338),
              isA<Hourly>()
                  .having(
                      (h) => h.time, 'time', DateTime.parse('2024-12-09T23:00'))
                  .having(
                      (h) => h.condition, 'condition', WeatherCondition.clear)
                  .having((h) => h.temperature, 'temperature', 8.9)
                  .having((h) => h.windSpeed, 'wind_speed', 16.3)
                  .having((h) => h.windDirection, 'wind_direction', 335),
            ]));
      });
    });
  });
}
