import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:xiaomi_weather_clone/bloc/units/models/weather_units.dart';

class UnitsCubit extends HydratedCubit<WeatherUnits> {
  UnitsCubit() : super(const WeatherUnits.empty());

  void changeTemperatureUnits(TemperatureUnits temperatureUnits) {
    emit(state.copyWith(temperatureUnits: temperatureUnits));
  }

  void changeWindSpeedUnits(WindSpeedUnits windSpeedUnits) {
    emit(state.copyWith(windSpeedUnits: windSpeedUnits));
  }

  void changePressureUnits(PressureUnits pressureUnits) {
    emit(state.copyWith(pressureUnits: pressureUnits));
  }

  @override
  WeatherUnits? fromJson(Map<String, dynamic> json) =>
      !json.containsKey('units') ? null : WeatherUnits.fromJson(json['units']);
  @override
  Map<String, dynamic>? toJson(WeatherUnits state) => {'units': state.toJson()};
}
