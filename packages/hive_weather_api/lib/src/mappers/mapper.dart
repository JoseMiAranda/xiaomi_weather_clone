import 'package:hive_weather_api/hive_weather_api.dart';
import 'package:hive_weather_api/src/models/hive_aqi.dart';
import 'package:uuid/uuid.dart';
import 'package:weather/weather.dart';

class WeatherMapper {
  //* AqiCondition
  static AqiCondition toAqiCondition(
      HiveAqiCondition hiveAqiCondition) {
    return switch (hiveAqiCondition) {
      HiveAqiCondition.good => AqiCondition.good,
      HiveAqiCondition.fair => AqiCondition.fair,
      HiveAqiCondition.moderate => AqiCondition.moderate,
      HiveAqiCondition.poor => AqiCondition.poor,
      HiveAqiCondition.veryPoor => AqiCondition.veryPoor,
      HiveAqiCondition.extremelyPoor => AqiCondition.extremelyPoor,
      _ => AqiCondition.unknown
    };
  }

  static HiveAqiCondition toHiveAqiCondition(
      AqiCondition aqiCondition) {
    return switch (aqiCondition) {
      AqiCondition.good => HiveAqiCondition.good,
      AqiCondition.fair => HiveAqiCondition.fair,
      AqiCondition.moderate => HiveAqiCondition.moderate,
      AqiCondition.poor => HiveAqiCondition.poor,
      AqiCondition.veryPoor => HiveAqiCondition.veryPoor,
      AqiCondition.extremelyPoor => HiveAqiCondition.extremelyPoor,
      _ => HiveAqiCondition.unknown
    };
  }

  //* WeatherCondition
  static WeatherCondition toWeatherCondition(
      HiveWeatherCondition hiveWeatherCondition) {
    return switch (hiveWeatherCondition) {
      HiveWeatherCondition.clear => WeatherCondition.clear,
      HiveWeatherCondition.cloudy => WeatherCondition.cloudy,
      HiveWeatherCondition.rainy => WeatherCondition.rainy,
      HiveWeatherCondition.snowy => WeatherCondition.snowy,
      _ => WeatherCondition.unknown
    };
  }

  static HiveWeatherCondition toHiveWeatherCondition(
      WeatherCondition weatherCondition) {
    return switch (weatherCondition) {
      WeatherCondition.clear => HiveWeatherCondition.clear,
      WeatherCondition.cloudy => HiveWeatherCondition.cloudy,
      WeatherCondition.rainy => HiveWeatherCondition.rainy,
      WeatherCondition.snowy => HiveWeatherCondition.snowy,
      _ => HiveWeatherCondition.unknown
    };
  }

  //* Location
  static Location toLocation(HiveLocation hiveLocation) => Location(
      name: hiveLocation.name,
      country: hiveLocation.country,
      latitude: hiveLocation.latitude,
      longitude: hiveLocation.longitude);

  static HiveLocation toHiveLocation(Location location) => HiveLocation(
      name: location.name,
      country: location.country,
      latitude: location.latitude,
      longitude: location.longitude);

  //* Current
  static Current toCurrent(HiveCurrent hiveCurrent) => Current(
      temperature: hiveCurrent.temperature,
      condition: toWeatherCondition(hiveCurrent.condition),
      humidity: hiveCurrent.humidity,
      feelsLikeTemperature: hiveCurrent.feelsLikeTemperature,
      aqi: toAqi(hiveCurrent.aqi));

  static HiveCurrent toHiveCurrent(Current current) => HiveCurrent(
      temperature: current.temperature,
      condition: toHiveWeatherCondition(current.condition),
      humidity: current.humidity,
      feelsLikeTemperature: current.feelsLikeTemperature,
      aqi: toHiveAqi(current.aqi));

  //* Aqi
  static Aqi toAqi(HiveAqi hiveAqi) => Aqi(
      aqi: hiveAqi.aqi,
      condition: toAqiCondition(hiveAqi.condition),
      pm10: hiveAqi.pm10,
      pm25: hiveAqi.pm25,
      carbonMonoxide: hiveAqi.carbonMonoxide,
      nitrogenDioxide: hiveAqi.nitrogenDioxide,
      sulphurDioxide: hiveAqi.sulphurDioxide,
      ozone: hiveAqi.ozone);

  static HiveAqi toHiveAqi(Aqi aqi) => HiveAqi(
      aqi: aqi.aqi,
      condition: toHiveAqiCondition(aqi.condition),
      pm10: aqi.pm10,
      pm25: aqi.pm25,
      carbonMonoxide: aqi.carbonMonoxide,
      nitrogenDioxide: aqi.nitrogenDioxide,
      sulphurDioxide: aqi.sulphurDioxide,
      ozone: aqi.ozone);

  //* Hourly
  static Hourly toHourly(HiveHourlyForecast hiveHourly) => Hourly(
      time: hiveHourly.time,
      condition: toWeatherCondition(hiveHourly.condition),
      temperature: hiveHourly.temperature,
      windSpeed: hiveHourly.windSpeed,
      windDirection: hiveHourly.windDirection);

  static HiveHourlyForecast toHiveHourly(Hourly hourly) => HiveHourlyForecast(
      time: hourly.time,
      condition: toHiveWeatherCondition(hourly.condition),
      temperature: hourly.temperature,
      windSpeed: hourly.windSpeed,
      windDirection: hourly.windDirection);

  //* Daily
  static Daily toDaily(HiveDailyForecast hiveDaily) => Daily(
        time: hiveDaily.time,
        hourly: hiveDaily.hourly.map(toHourly).toList(),
        maxTemperature: hiveDaily.maxTemperature,
        minTemperature: hiveDaily.minTemperature,
        maxWindSpeed: hiveDaily.windSpeed,
        maxWindDirection: hiveDaily.windDirection,
        maxSeaPressure: hiveDaily.maxSeaPressure,
        precipitationProbability: hiveDaily.precipitationProbability,
        uvIndex: hiveDaily.uvIndex,
        sunrise: hiveDaily.sunrise,
        sunset: hiveDaily.sunset,
      );

  static HiveDailyForecast toHiveDaily(Daily daily) => HiveDailyForecast(
      time: daily.time,
      hourly: daily.hourly.map(toHiveHourly).toList(),
      maxTemperature: daily.maxTemperature,
      minTemperature: daily.minTemperature,
      windSpeed: daily.maxWindSpeed,
      windDirection: daily.maxWindDirection,
      maxSeaPressure: daily.maxSeaPressure,
      precipitationProbability: daily.precipitationProbability,
      uvIndex: daily.uvIndex,
      sunrise: daily.sunrise,
      sunset: daily.sunset);

  //* Weather
  static Weather toWeather(HiveWeather hiveWeather) => Weather(
      id: hiveWeather.id,
      lastUpdated: hiveWeather.lastUpdated,
      location: toLocation(hiveWeather.location),
      current: toCurrent(hiveWeather.current),
      daily: hiveWeather.dailyForecast.map(toDaily).toList());

  static HiveWeather toHiveWeather(Weather weather) => HiveWeather(
      id: weather.id ?? const Uuid().v1(),
      lastUpdated: weather.lastUpdated,
      location: toHiveLocation(weather.location),
      current: toHiveCurrent(weather.current),
      dailyForecast: weather.daily.map(toHiveDaily).toList());
}
