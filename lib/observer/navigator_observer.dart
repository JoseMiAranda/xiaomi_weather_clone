import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xiaomi_weather_clone/app/config/router/app_router.gr.dart';
import 'package:xiaomi_weather_clone/app/core/backgrounds.dart';
import 'package:xiaomi_weather_clone/app/di/service_locator.dart';
import 'package:xiaomi_weather_clone/bloc/weather/cubit/weather_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/weather/models/weather.dart';

class RouterObserver extends AutoRouterObserver {
  RouterObserver() {
    sl<WeatherCubit>().getCurrentWeatherStream().listen((w) {
      weather = w;
      _updateSystemUiOverlayStyle();
    });
  }

  Weather? weather;
  Route<dynamic>? currentRoute;

  final darkSystemUiOverlayStyle = const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  final lightSystemUiOverlayStyle = const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
  );

  void _updateSystemUiOverlayStyle() {
    final routeName = currentRoute?.settings.name;

    SystemChrome.setSystemUIOverlayStyle(routeName != WeatherRoute.name
        ? lightSystemUiOverlayStyle
        : darkSystemUiOverlayStyle.copyWith(
            systemNavigationBarColor: weather == null
                ? null
                : Backgrounds.getBackground(weather!.current.condition)
                    .gradient!
                    .colors
                    .last,
          ));
  }

  @override
  Future<void> didPush(Route route, Route? previousRoute) async {
    super.didPush(route, previousRoute);
    currentRoute = route;
    debugPrint('didPush ${route.settings.name}');
    _updateSystemUiOverlayStyle();
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    currentRoute = previousRoute;
    debugPrint('didPop ${route.settings.name}');
    _updateSystemUiOverlayStyle();
  }
}
