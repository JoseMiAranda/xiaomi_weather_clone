import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xiaomi_weather_clone/app/extensions/double_extension.dart';
import 'package:xiaomi_weather_clone/bloc/units/units_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/weather/models/weather.dart';
import 'package:xiaomi_weather_clone/bloc/units/models/weather_units.dart';
import 'package:weather_repository/weather_repository.dart'
    as weather_repository show WeatherRepository, Location, Weather;
import 'package:db_weather_repository/db_weather_repsitory.dart'
    as db_weather_repository show DbWeatherRepository;
part 'weathers_cubit.g.dart';
part 'weathers_state.dart';

class WeathersCubit extends Cubit<WeathersState> {
  WeathersCubit(
      this._weatherRepository, this._dbWeatherRepository, this._unitsCubit)
      : super(const WeathersState());

  final weather_repository.WeatherRepository _weatherRepository;
  final db_weather_repository.DbWeatherRepository _dbWeatherRepository;
  final UnitsCubit _unitsCubit;

  Stream<List<Weather>> getWeathersStream() {
    return Rx.combineLatest2<List<weather_repository.Weather>, WeatherUnits,
        List<Weather>>(
      _dbWeatherRepository.getWeathersStream(),
      _unitsCubit.stream.startWith(_unitsCubit.state),
      (weathers, units) {
        return weathers.map((weather) {
          final w = Weather.fromRepository(weather);
          final current = w.current.copyWith(
            aqi: w.current.aqi,
            condition: w.current.condition,
            feelsLikeTemperature: units.temperatureUnits.isCelsius
                ? w.current.feelsLikeTemperature
                : w.current.feelsLikeTemperature.toFahrenheit(),
            humidity: w.current.humidity,
            temperature: units.temperatureUnits.isCelsius
                ? w.current.temperature
                : w.current.temperature.toFahrenheit(),
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
        }).toList();
      },
    );
  }

  Future<void> deleteWeathers(List<String> ids) async {
    if (state.status.isLoading || ids.isEmpty) return;
    final weathers = await getWeathersStream().first;
    if (weathers.isEmpty) return;
    emit(state.copyWith(status: WeathersStatus.loading));
    await _dbWeatherRepository.deleteWeathers(ids);
    emit(state.copyWith(status: WeathersStatus.success));
  }

  Future<void> reorganizeWeathers(List<String> ids) async {
    if (state.status.isLoading || ids.isEmpty) return;
    emit(state.copyWith(status: WeathersStatus.loading));
    await _dbWeatherRepository.reorganizeWeathers(ids);
    emit(state.copyWith(status: WeathersStatus.success));
  }

  Future<void> refreshWeathers(final List<String> ids) async {
    if (state.status.isLoading) return;

    final weathers = await getWeathersStream().first;
    if (weathers.isEmpty) return;

    emit(state.copyWith(status: WeathersStatus.loading));

    final requiredWeathers = weathers.where((w) => ids.contains(w.id)).toList();

    try {
      for (final weather in requiredWeathers) {
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
            .saveWeather(Weather.toRepository(updatedWeather), current: false);
      }
      emit(
        state.copyWith(
          status: WeathersStatus.success,
        ),
      );
    } on Exception {
      emit(state.copyWith(status: WeathersStatus.failure));
    }
  }
}
