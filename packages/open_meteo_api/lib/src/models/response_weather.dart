import 'package:json_annotation/json_annotation.dart';

part 'response_weather.g.dart';

@JsonSerializable()
class ResponseWeather {
  ResponseWeather({
    required this.current,
    required this.hourly,
    required this.daily,
  });

  ResponseCurrent current;
  ResponseHourly hourly;
  ResponseDaily daily;

  factory ResponseWeather.fromJson(Map<String, dynamic> json) =>
      _$ResponseWeatherFromJson(json);
}

@JsonSerializable()
class ResponseCurrent {
  ResponseCurrent({
    required this.temperature,
    required this.relativeHumidity,
    required this.feelsLikeTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
  });

  factory ResponseCurrent.fromJson(Map<String, dynamic> json) => _$ResponseCurrentFromJson(json);

  @JsonKey(name: "temperature_2m")
  double temperature;
  @JsonKey(name: "relative_humidity_2m")
  int relativeHumidity;
  @JsonKey(name: "apparent_temperature")
  double feelsLikeTemperature;
  int precipitation;
  @JsonKey(name: "weather_code")
  int weatherCode;
  @JsonKey(name: "wind_speed_10m")
  double windSpeed;
}

@JsonSerializable()
class ResponseDaily {
  ResponseDaily({
    required this.time,
    required this.weatherCode,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.windSpeed,
    required this.windDirection,
    required this.uvIndex,
    required this.precipitationProbability,
    required this.sunrise,
    required this.sunset,
  });

  factory ResponseDaily.fromJson(Map<String, dynamic> json) => _$ResponseDailyFromJson(json);

  List<DateTime> time;
  @JsonKey(name: "weather_code")
  List<int> weatherCode;
  @JsonKey(name: "temperature_2m_max")
  List<double> temperatureMax;
  @JsonKey(name: "temperature_2m_min")
  List<double> temperatureMin;
  @JsonKey(name: "wind_speed_10m_max")
  List<double> windSpeed;
  @JsonKey(name: "wind_direction_10m_dominant")
  List<int> windDirection;
  @JsonKey(name: "uv_index_max")
  List<int> uvIndex;
  @JsonKey(name: "precipitation_probability_max")
  List<int> precipitationProbability;
  List<DateTime> sunrise;
  List<DateTime> sunset;
}

@JsonSerializable()
class ResponseHourly {
  ResponseHourly({
    required this.time,
    required this.weatherCode,
    required this.temperature,
    required this.windSpeed,
    required this.windDirection,
    required this.seaPressure,
  });

  factory ResponseHourly.fromJson(Map<String, dynamic> json) => _$ResponseHourlyFromJson(json);

  List<DateTime> time;
  @JsonKey(name: "weather_code")
  List<int> weatherCode;
  @JsonKey(name: "temperature_2m")
  List<double> temperature;
  @JsonKey(name: "wind_speed_10m")
  List<double> windSpeed;
  @JsonKey(name: "wind_direction_10m")
  List<int> windDirection;
  @JsonKey(name: "pressure_msl")
  List<double> seaPressure;
}
