import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xiaomi_weather_clone/bloc/units/units_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/weather/models/weather.dart';
import 'package:xiaomi_weather_clone/bloc/units/models/weather_units.dart';
import 'package:xiaomi_weather_clone/app/extensions/double_extension.dart';
import 'package:weather_repository/weather_repository.dart'
    as weather_repository show WeatherRepository, Location, Weather;
import 'package:db_weather_repository/db_weather_repsitory.dart'
    as db_weather_repository show DbWeatherRepository;

part 'weather_cubit.g.dart';
part 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit(
      this._weatherRepository, this._dbWeatherRepository, this._unitsCubit)
      : super(const WeatherState());

  final weather_repository.WeatherRepository _weatherRepository;
  final db_weather_repository.DbWeatherRepository _dbWeatherRepository;
  final UnitsCubit _unitsCubit;

  Stream<Weather?> getCurrentWeatherStream() {
    return Rx.combineLatest2<weather_repository.Weather?, WeatherUnits,
        Weather?>(
      _dbWeatherRepository.getCurrentWeatherStream(),
      _unitsCubit.stream.startWith(_unitsCubit.state),
      (weather, units) {
        if (weather == null) return null;

        final w = Weather.fromRepository(weather);

        final current = w.current.copyWith(
          feelsLikeTemperature: units.temperatureUnits.isCelsius
              ? weather.current.feelsLikeTemperature
              : weather.current.feelsLikeTemperature.toFahrenheit(),
          temperature: units.temperatureUnits.isCelsius
              ? weather.current.temperature
              : weather.current.temperature.toFahrenheit(),
        );

        final daily = w.daily
            .map((d) => d.copyWith(
                  maxTemperature: units.temperatureUnits.isCelsius
                      ? d.maxTemperature
                      : d.maxTemperature.toFahrenheit(),
                  minTemperature: units.temperatureUnits.isCelsius
                      ? d.minTemperature
                      : d.minTemperature.toFahrenheit(),
                  maxWindSpeed: units.windSpeedUnits.isKph
                      ? d.maxWindSpeed
                      : d.maxWindSpeed.toMph(),
                  hourly: d.hourly
                      .map((h) => h.copyWith(
                            temperature: units.temperatureUnits.isCelsius
                                ? h.temperature
                                : h.temperature.toFahrenheit(),
                            windSpeed: units.windSpeedUnits.isKph
                                ? h.windSpeed
                                : h.windSpeed.toMph(),
                          ))
                      .toList(),
                ))
            .toList();

        return w.copyWith(
          current: current,
          daily: daily,
        );
      },
    );
  }

  Future<void> saveWeather(Weather weather) async {
    if (state.status.isLoading) return;

    emit(state.copyWith(status: WeatherStatus.loading));
    final units = _unitsCubit.state;

    final current = weather.current.copyWith(
      feelsLikeTemperature: units.temperatureUnits.isCelsius
          ? weather.current.feelsLikeTemperature
          : weather.current.feelsLikeTemperature.toCelsius(),
      temperature: units.temperatureUnits.isCelsius
          ? weather.current.temperature
          : weather.current.temperature.toCelsius(),
    );

    final daily = weather.daily
        .map((d) => d.copyWith(
            maxTemperature: units.temperatureUnits.isCelsius
                ? d.maxTemperature
                : d.maxTemperature.toCelsius(),
            minTemperature: units.temperatureUnits.isCelsius
                ? d.minTemperature
                : d.minTemperature.toCelsius(),
            maxWindSpeed: units.windSpeedUnits.isKph
                ? d.maxWindSpeed
                : d.maxWindSpeed.toKph(),
            hourly: d.hourly
                .map((h) => h.copyWith(
                      temperature: units.temperatureUnits.isCelsius
                          ? h.temperature
                          : h.temperature.toCelsius(),
                      windSpeed: units.windSpeedUnits.isKph
                          ? h.windSpeed
                          : h.windSpeed.toKph(),
                    ))
                .toList()))
        .toList();

    final formattedWeather = Weather.toRepository(weather.copyWith(
      current: current,
      daily: daily,
    ));

    await _dbWeatherRepository.saveWeather(formattedWeather, current: true);

    emit(
      state.copyWith(
        status: WeatherStatus.success,
      ),
    );
  }

  Future<void> refreshWeather() async {
    if (state.status.isLoading) return;
    final weather = await getCurrentWeatherStream().first;
    if (weather == null) return;
    emit(state.copyWith(status: WeatherStatus.loading));
    try {
      final searchedWeather =
          Weather.fromRepository(await _weatherRepository.getWeather(
        weather_repository.Location(
            name: weather.location.name,
            country: weather.location.country,
            latitude: weather.location.latitude,
            longitude: weather.location.longitude),
      ));

      final updatedWeather = searchedWeather.copyWith(
        id: weather.id,
        lastUpdated: DateTime.now(),
      );

      await _dbWeatherRepository
          .saveWeather(Weather.toRepository(updatedWeather), current: true);

      emit(
        state.copyWith(
          status: WeatherStatus.success,
        ),
      );
    } on Exception {
      emit(state.copyWith(status: WeatherStatus.failure));
    }
  }
}
