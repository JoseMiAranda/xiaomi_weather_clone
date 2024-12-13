import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:xiaomi_weather_clone/app/config/router/app_router.dart';
import 'package:xiaomi_weather_clone/app/config/theme/app_theme.dart';
import 'package:xiaomi_weather_clone/app/di/service_locator.dart';
import 'package:xiaomi_weather_clone/bloc/confirm/confirm_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/language/language_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/observer/bloc_observer.dart';
import 'package:xiaomi_weather_clone/bloc/search/cubit/search_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/units/units_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/weather/cubit/weather_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/weathers/weathers_cubit.dart';
import 'package:xiaomi_weather_clone/l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xiaomi_weather_clone/observer/navigator_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );
  await setup();
  Bloc.observer = sl<MyBlocObserver>();
  
  if(kIsWeb) {
    setPathUrlStrategy();
  }

  if (!kIsWeb) {
    SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = sl<AppRouter>();
    return MultiBlocProvider(
      providers: [
        BlocProvider<SearchCubit>(
          create: (context) => sl<SearchCubit>(),
        ),
        BlocProvider<ConfirmCubit>(
          create: (context) => sl<ConfirmCubit>(),
        ),
        BlocProvider<WeatherCubit>(
          create: (context) => sl<WeatherCubit>(),
        ),
        BlocProvider<WeathersCubit>(
          create: (context) => sl<WeathersCubit>(),
        ),
        BlocProvider<LanguageCubit>(
          create: (context) => sl<LanguageCubit>(),
        ),
        BlocProvider<UnitsCubit>(
          create: (context) => sl<UnitsCubit>(),
        ),
      ],
      child: BlocBuilder<LanguageCubit, String>(
        bloc: sl<LanguageCubit>(),
        builder: (context, state) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: AppTheme().getTheme(),
            locale: Locale(state),
            supportedLocales: L10n.all,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate
            ],
            routerConfig: router.config(
              navigatorObservers: () => [
                RouterObserver(),
              ],
            ),
          );
        },
      ),
    );
  }
}
