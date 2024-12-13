import 'package:db_weather_repository/db_weather_repsitory.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_weather_api/hive_weather_api.dart';
import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:xiaomi_weather_clone/app/config/router/app_router.dart';
import 'package:xiaomi_weather_clone/bloc/confirm/confirm_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/language/language_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/observer/bloc_observer.dart';
import 'package:xiaomi_weather_clone/bloc/search/cubit/search_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/units/units_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/weather/cubit/weather_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/weathers/weathers_cubit.dart';
import 'package:weather_repository/weather_repository.dart';

final sl = GetIt.instance;

Future<void> setup() async {
  // Navigation
  sl.registerLazySingleton<AppRouter>(
    () => AppRouter(),
  );

  // Datasources
  final hiveWeatherApiClient = await HiveWeatherApiClient.instantiate();
  sl.registerLazySingleton<HiveWeatherApiClient>(() => hiveWeatherApiClient);

  sl.registerLazySingleton<OpenMeteoApiClient>(
    () => OpenMeteoApiClient(),
  );

  // Repositories
  final dbWeatherRepository =
      DbWeatherRepositoryImpl(datasource: hiveWeatherApiClient);
  sl.registerLazySingleton<DbWeatherRepository>(() => dbWeatherRepository);

  sl.registerLazySingleton<WeatherRepository>(
    () => WeatherRepositoryImpl(weatherApiClient: sl<OpenMeteoApiClient>()),
  );

  // Cubits
  sl.registerLazySingleton<LanguageCubit>(
    () => LanguageCubit(),
  );

  sl.registerLazySingleton<UnitsCubit>(
    () => UnitsCubit(),
  );

  sl.registerLazySingleton<MyBlocObserver>(
    () => MyBlocObserver(),
  );

  sl.registerSingleton<WeathersCubit>(WeathersCubit(
    sl<WeatherRepository>(),
    dbWeatherRepository,
    sl<UnitsCubit>(),
  ));

  sl.registerLazySingleton<SearchCubit>(
    () => SearchCubit(
        sl<WeatherRepository>(), sl<LanguageCubit>(), sl<UnitsCubit>()),
  );

  sl.registerLazySingleton<ConfirmCubit>(
    () => ConfirmCubit(sl<WeatherRepository>(), sl<UnitsCubit>()),
  );

  sl.registerLazySingleton<WeatherCubit>(
    () => WeatherCubit(
      sl<WeatherRepository>(),
      dbWeatherRepository,
      sl<UnitsCubit>(),
    ),
  );
}
