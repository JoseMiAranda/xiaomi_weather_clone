import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:open_meteo_api/src/models/response_aqi.dart';
import 'package:weather/weather.dart';

/// Exception thrown when locationSearch fails.
class LocationRequestFailure implements Exception {}

/// Exception thrown when the provided location is not found.
class LocationNotFoundFailure implements Exception {}

/// Exception thrown when getWeather fails.
class WeatherRequestFailure implements Exception {}

/// Exception thrown when weather for provided location is not found.
class WeatherNotFoundFailure implements Exception {}

/// {@template open_meteo_api_client}
/// Dart API Client which wraps the [Open Meteo API](https://open-meteo.com).
/// {@endtemplate}
class OpenMeteoApiClient implements WeatherDatasource {
  /// {@macro open_meteo_api_client}
  OpenMeteoApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  static const _baseUrlWeather = 'api.open-meteo.com';
  static const _baseUrlGeocoding = 'geocoding-api.open-meteo.com';
  static const _baseUrlAqi = 'air-quality-api.open-meteo.com';

  final http.Client _httpClient;

  @override
  /// Finds a [Location] `/v1/search/?name=(query)`.
  Future<List<Location>> getLocations(String query, {String lang = 'en'}) async {
    final locationRequest = Uri.https(
      _baseUrlGeocoding,
      '/v1/search',
      {
        'name': query.trim(),
        'language': lang,
        'count': '5'
      },
    );

    final locationResponse = await _httpClient.get(locationRequest);

    if (locationResponse.statusCode != 200) {
      throw LocationRequestFailure();
    }

    final locationJson = jsonDecode(locationResponse.body) as Map;

    if (!locationJson.containsKey('results')) throw LocationNotFoundFailure();

    final results = locationJson['results'] as List;

    if (results.isEmpty) throw LocationNotFoundFailure();

    return results.map((location) => Location.fromJson(location)).toList();
  }

  @override
  /// Fetches [Weather] for a given [latitude] and [longitude].
  Future<Weather> getWeather(Location location) async {
    final weatherRequest = Uri.https(_baseUrlWeather, 'v1/forecast', {
      'latitude': '${location.latitude}',
      'longitude': '${location.longitude}',
      'current':
          'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m',
      'hourly': 'weather_code,temperature_2m,wind_speed_10m,wind_direction_10m,pressure_msl',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,wind_speed_10m_max,wind_direction_10m_dominant,uv_index_max,precipitation_probability_max,sunrise,sunset',
    });

    final aqiRequest = Uri.https(_baseUrlAqi, 'v1/air-quality', {
      'latitude': '${location.latitude}',
      'longitude': '${location.longitude}',
      'current':
          'european_aqi,pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide,ozone',
    });

    final weatherResponse = await _httpClient.get(weatherRequest);

    final aqiResponse = await _httpClient.get(aqiRequest);

    if (weatherResponse.statusCode != 200 || aqiResponse.statusCode != 200) {
      throw WeatherRequestFailure();
    }

    final weatherBodyJson =
        jsonDecode(weatherResponse.body) as Map<String, dynamic>;
    final aqiBodyJson = jsonDecode(aqiResponse.body) as Map<String, dynamic>;

    if (!weatherBodyJson.containsKey('current') &&
        !weatherBodyJson.containsKey('hourly') &&
        !weatherBodyJson.containsKey('daily') &&
        !aqiBodyJson.containsKey('current')) {
      throw WeatherNotFoundFailure();
    }

    final weatherModel = ResponseWeather.fromJson(weatherBodyJson);
    final aqiModel = ResponseAqi.fromJson(aqiBodyJson['current']);

    final weather = Weather(
      location: location,
      lastUpdated: DateTime.now(),
      current: Current(
        temperature: weatherModel.current.temperature,
        condition: weatherModel.current.weatherCode.toWeatherCondition,
        humidity: weatherModel.current.relativeHumidity,
        feelsLikeTemperature: weatherModel.current.feelsLikeTemperature,
        aqi: Aqi(
            aqi: aqiModel.europeanAqi,
            condition: aqiModel.europeanAqi.toAqiCondition,
            pm10: aqiModel.pm10,
            pm25: aqiModel.pm25,
            carbonMonoxide: aqiModel.carbonMonoxide,
            nitrogenDioxide: aqiModel.nitrogenDioxide,
            sulphurDioxide: aqiModel.sulphurDioxide,
            ozone: aqiModel.ozone),
      ),
      daily: List.generate(
        7, // 7 days of forecast
        (dayIndex) {
          final startHour = dayIndex * 24;

          return Daily(
            time: weatherModel.daily.time[dayIndex],
            maxTemperature: weatherModel.daily.temperatureMax[dayIndex],
            minTemperature: weatherModel.daily.temperatureMin[dayIndex],
            maxWindDirection: weatherModel.daily.windDirection[dayIndex],
            maxWindSpeed: weatherModel.daily.windSpeed[dayIndex],
            uvIndex: weatherModel.daily.uvIndex[dayIndex],
            precipitationProbability:
                weatherModel.daily.precipitationProbability[dayIndex],
            maxSeaPressure: List.generate(
                    24,
                    (hourIndex) =>
                        weatherModel.hourly.seaPressure[startHour + hourIndex])
                .reduce((value, element) => value > element ? value : element),
            sunrise: weatherModel.daily.sunrise[dayIndex],
            sunset: weatherModel.daily.sunset[dayIndex],
            hourly: List.generate(
              24,
              (hourIndex) {
                final actualIndex = startHour + hourIndex;

                return Hourly(
                  time: weatherModel.hourly.time[actualIndex],
                  condition:
                      weatherModel.hourly.weatherCode[actualIndex].toWeatherCondition,
                  temperature: weatherModel.hourly.temperature[actualIndex],
                  windSpeed: weatherModel.hourly.windSpeed[actualIndex],
                  windDirection: weatherModel.hourly.windDirection[actualIndex],
                );
              },
            ),
          );
        },
      ),
    );
    return weather;
  }
}

extension on int {
  AqiCondition get toAqiCondition {
    if(this >= 0 && this <= 20) return AqiCondition.good;
    if(this > 20 && this <= 40) return AqiCondition.fair;
    if(this > 40 && this <= 60) return AqiCondition.moderate;
    if(this > 60 && this <= 80) return AqiCondition.poor;
    if(this > 80 && this <= 100) return AqiCondition.veryPoor;
    if(this > 100) return AqiCondition.extremelyPoor;
    return AqiCondition.unknown;
  }

  WeatherCondition get toWeatherCondition {
    switch (this) {
      case 0:
        return WeatherCondition.clear;
      case 1:
      case 2:
      case 3:
      case 45:
      case 48:
        return WeatherCondition.cloudy;
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
      case 80:
      case 81:
      case 82:
      case 95:
      case 96:
      case 99:
        return WeatherCondition.rainy;
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return WeatherCondition.snowy;
      default:
        return WeatherCondition.unknown;
    }
  }
}
