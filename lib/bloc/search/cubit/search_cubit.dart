import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:xiaomi_weather_clone/app/extensions/double_extension.dart';
import 'package:xiaomi_weather_clone/bloc/language/language_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/search/models/location.dart';
import 'package:xiaomi_weather_clone/bloc/search/models/search_results.dart';
import 'package:xiaomi_weather_clone/bloc/units/models/weather_units.dart';
import 'package:xiaomi_weather_clone/bloc/units/units_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/weather/models/weather.dart';
import 'package:weather_repository/weather_repository.dart'
    show WeatherRepository;

part 'search_cubit.g.dart';
part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._weatherRepository, this._languageCubit, this._unitsCubit)
      : super(SearchState()) {
    _locale = _languageCubit.state;
    _units = _unitsCubit.state;
    _languageSubscription = _languageCubit.stream.listen((locale) {
      _locale = locale;
    });
    _unitsSubscription = _unitsCubit.stream.listen(
      (units) {
        _units = units;
      },
    );
  }

  final LanguageCubit _languageCubit;
  final UnitsCubit _unitsCubit;
  final WeatherRepository _weatherRepository;
  late StreamSubscription<String> _languageSubscription;
  late String _locale;
  late StreamSubscription<WeatherUnits> _unitsSubscription;
  late WeatherUnits _units;

  void resetState() {
    emit(state.copyWith(status: SearchStatus.initial));
  }

  Future<void> fetchResults(String? city) async {
    if (city == null || city.isEmpty) return;

    if (city.length < 3) {
      emit(
        state.copyWith(
          status: SearchStatus.success,
          results: SearchResults.empty(),
        ),
      );
      return;
    }

    emit(state.copyWith(status: SearchStatus.loading));

    try {
      Weather? weather;
      final locationResults =
          await _weatherRepository.getLocations(city, lang: _locale);
      final locations = locationResults
          .map((location) => Location.fromRepository(location))
          .toList();

      if (locations.isNotEmpty) {
        final location = locations.first.toRepository();
        final weatherResult = await _weatherRepository.getWeather(location);
        weather = Weather.fromRepository(weatherResult);
        weather = weather.copyWith(
            current: weather.current.copyWith(
              feelsLikeTemperature: _units.temperatureUnits.isFahrenheit
                  ? weather.current.feelsLikeTemperature.toFahrenheit()
                  : weather.current.feelsLikeTemperature,
              temperature: _units.temperatureUnits.isFahrenheit
                  ? weather.current.temperature.toFahrenheit()
                  : weather.current.temperature,
            ),
            daily: weather.daily
                .map((d) => d.copyWith(
                    maxTemperature: _units.temperatureUnits.isFahrenheit
                        ? d.maxTemperature.toFahrenheit()
                        : d.maxTemperature,
                    minTemperature: _units.temperatureUnits.isFahrenheit
                        ? d.minTemperature.toFahrenheit()
                        : d.minTemperature,
                    maxWindSpeed: _units.windSpeedUnits.isMph
                        ? d.maxWindSpeed.toMph()
                        : d.maxWindSpeed,
                    hourly: d.hourly
                        .map((h) => h.copyWith(
                              temperature: _units.temperatureUnits.isFahrenheit
                                  ? h.temperature.toFahrenheit()
                                  : h.temperature,
                              windSpeed: _units.windSpeedUnits.isMph
                                  ? h.windSpeed.toMph()
                                  : h.windSpeed,
                            ))
                        .toList()))
                .toList());
      }

      emit(
        state.copyWith(
          status: SearchStatus.success,
          results: SearchResults(
              weather: weather,
              locations: locations.length == 1
                  ? []
                  : locations.sublist(1, locations.length)),
        ),
      );
    } on Exception {
      emit(state.copyWith(status: SearchStatus.failure));
    }
  }

  @override
  Future<void> close() {
    _languageSubscription.cancel();
    _unitsSubscription.cancel();
    return super.close();
  }
}
