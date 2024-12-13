import 'dart:async';

import 'package:open_meteo_api/open_meteo_api.dart'
    hide ResponseLocation, ResponseWeather, ResponseCurrent, ResponseHourly, ResponseDaily;

import 'package:weather/weather.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  WeatherRepositoryImpl({required OpenMeteoApiClient? weatherApiClient})
      : _weatherApiClient = weatherApiClient ?? OpenMeteoApiClient();

  final OpenMeteoApiClient _weatherApiClient;

  @override
  Future<List<Location>> getLocations(String city, {String lang = 'en'}) async {
    final locations = await _weatherApiClient.getLocations(city, lang: lang);
    return locations
        .map((location) => Location(
              name: location.name,
              country: location.country,
              latitude: location.latitude,
              longitude: location.longitude,
            ))
        .toList();
  }

  @override
  Future<Weather> getWeather(Location location) async {
    return await _weatherApiClient.getWeather(location);
  }
}

