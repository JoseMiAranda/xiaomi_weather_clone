import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:xiaomi_weather_clone/app/extensions/double_extension.dart';
import 'package:xiaomi_weather_clone/bloc/search/models/location.dart';
import 'package:xiaomi_weather_clone/bloc/units/units_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/weather/models/weather.dart';
import 'package:xiaomi_weather_clone/bloc/units/models/weather_units.dart';
import 'package:weather_repository/weather_repository.dart'
    as weather_repository show WeatherRepository, Location;

part 'confirm_cubit.g.dart';
part 'confirm_state.dart';

class ConfirmCubit extends Cubit<ConfirmState> {
  ConfirmCubit(this._weatherRepository, this._unitsCubit)
      : super(const ConfirmState()) {
    _units = _unitsCubit.state;
    _unitsSubscription = _unitsCubit.stream.listen(
      (units) {
        _units = units;
      },
    );
  }

  final weather_repository.WeatherRepository _weatherRepository;
  final UnitsCubit _unitsCubit;
  late StreamSubscription<WeatherUnits> _unitsSubscription;
  late WeatherUnits _units;

  Future<void> fetchWeather(Location location) async {
    emit(state.copyWith(status: ConfirmStatus.loading));

    try {
      final searchedWeather =
          Weather.fromRepository(await _weatherRepository.getWeather(
        weather_repository.Location(
            name: location.name,
            country: location.country,
            latitude: location.latitude,
            longitude: location.longitude),
      ));

      final tempUnit = _units.temperatureUnits;
      final windUnit = _units.windSpeedUnits;

      final current = searchedWeather.current.copyWith(
        aqi: searchedWeather.current.aqi,
        condition: searchedWeather.current.condition,
        feelsLikeTemperature: tempUnit.isFahrenheit
            ? searchedWeather.current.feelsLikeTemperature.toFahrenheit()
            : searchedWeather.current.feelsLikeTemperature,
        humidity: searchedWeather.current.humidity,
        temperature: tempUnit.isFahrenheit
            ? searchedWeather.current.temperature.toFahrenheit()
            : searchedWeather.current.temperature,
      );

      final daily = searchedWeather.daily
          .map((d) => d.copyWith(
                sunrise: d.sunrise,
                sunset: d.sunset,
                time: d.time,
                maxSeaPressure: d.maxSeaPressure,
                maxWindDirection: d.maxWindDirection,
                maxWindSpeed:
                    windUnit.isMph ? d.maxWindSpeed.toMph() : d.maxWindSpeed,
                precipitationProbability: d.precipitationProbability,
                uvIndex: d.uvIndex,
                hourly: d.hourly
                    .map((h) => h.copyWith(
                          time: h.time,
                          temperature: tempUnit.isFahrenheit
                              ? h.temperature.toFahrenheit()
                              : h.temperature,
                          windSpeed: windUnit.isMph
                              ? h.windSpeed.toMph()
                              : h.windSpeed,
                          windDirection: h.windDirection,
                        ))
                    .toList(),
                maxTemperature: tempUnit.isFahrenheit
                    ? d.maxTemperature.toFahrenheit()
                    : d.maxTemperature,
                minTemperature: tempUnit.isFahrenheit
                    ? d.minTemperature.toFahrenheit()
                    : d.minTemperature,
              ))
          .toList();

      emit(
        state.copyWith(
          status: ConfirmStatus.success,
          weather: searchedWeather.copyWith(
            lastUpdated: DateTime.now(),
            current: current,
            daily: daily,
          ),
        ),
      );
    } on Exception {
      emit(state.copyWith(status: ConfirmStatus.failure));
    }
  }

  @override
  Future<void> close() {
    _unitsSubscription.cancel();
    return super.close();
  }
}
