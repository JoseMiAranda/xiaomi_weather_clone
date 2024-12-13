// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i8;
import 'package:flutter/material.dart' as _i9;
import 'package:xiaomi_weather_clone/bloc/search/models/location.dart' as _i11;
import 'package:xiaomi_weather_clone/bloc/weather/models/weather.dart' as _i10;
import 'package:xiaomi_weather_clone/presentation/screens/air_quality_page.dart'
    as _i1;
import 'package:xiaomi_weather_clone/presentation/screens/confirm_location_page.dart'
    as _i2;
import 'package:xiaomi_weather_clone/presentation/screens/home_page.dart' as _i3;
import 'package:xiaomi_weather_clone/presentation/screens/saved_weathers_page.dart'
    as _i4;
import 'package:xiaomi_weather_clone/presentation/screens/search_page.dart'
    as _i5;
import 'package:xiaomi_weather_clone/presentation/screens/settings_page.dart'
    as _i6;
import 'package:xiaomi_weather_clone/presentation/screens/weather_page.dart'
    as _i7;

/// generated route for
/// [_i1.AirQualityPage]
class AirQualityRoute extends _i8.PageRouteInfo<void> {
  const AirQualityRoute({List<_i8.PageRouteInfo>? children})
      : super(
          AirQualityRoute.name,
          initialChildren: children,
        );

  static const String name = 'AirQualityRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i1.AirQualityPage();
    },
  );
}

/// generated route for
/// [_i2.ConfirmLocationPage]
class ConfirmLocationRoute extends _i8.PageRouteInfo<ConfirmLocationRouteArgs> {
  ConfirmLocationRoute({
    _i9.Key? key,
    _i10.Weather? weather,
    _i11.Location? location,
    List<_i8.PageRouteInfo>? children,
  }) : super(
          ConfirmLocationRoute.name,
          args: ConfirmLocationRouteArgs(
            key: key,
            weather: weather,
            location: location,
          ),
          initialChildren: children,
        );

  static const String name = 'ConfirmLocationRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ConfirmLocationRouteArgs>(
          orElse: () => const ConfirmLocationRouteArgs());
      return _i2.ConfirmLocationPage(
        key: args.key,
        weather: args.weather,
        location: args.location,
      );
    },
  );
}

class ConfirmLocationRouteArgs {
  const ConfirmLocationRouteArgs({
    this.key,
    this.weather,
    this.location,
  });

  final _i9.Key? key;

  final _i10.Weather? weather;

  final _i11.Location? location;

  @override
  String toString() {
    return 'ConfirmLocationRouteArgs{key: $key, weather: $weather, location: $location}';
  }
}

/// generated route for
/// [_i3.HomePage]
class HomeRoute extends _i8.PageRouteInfo<void> {
  const HomeRoute({List<_i8.PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i3.HomePage();
    },
  );
}

/// generated route for
/// [_i4.SavedWeathersPage]
class SavedWeathersRoute extends _i8.PageRouteInfo<void> {
  const SavedWeathersRoute({List<_i8.PageRouteInfo>? children})
      : super(
          SavedWeathersRoute.name,
          initialChildren: children,
        );

  static const String name = 'SavedWeathersRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i4.SavedWeathersPage();
    },
  );
}

/// generated route for
/// [_i5.SearchPage]
class SearchRoute extends _i8.PageRouteInfo<void> {
  const SearchRoute({List<_i8.PageRouteInfo>? children})
      : super(
          SearchRoute.name,
          initialChildren: children,
        );

  static const String name = 'SearchRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i5.SearchPage();
    },
  );
}

/// generated route for
/// [_i6.SettingsPage]
class SettingsRoute extends _i8.PageRouteInfo<void> {
  const SettingsRoute({List<_i8.PageRouteInfo>? children})
      : super(
          SettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SettingsRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i6.SettingsPage();
    },
  );
}

/// generated route for
/// [_i7.WeatherPage]
class WeatherRoute extends _i8.PageRouteInfo<void> {
  const WeatherRoute({List<_i8.PageRouteInfo>? children})
      : super(
          WeatherRoute.name,
          initialChildren: children,
        );

  static const String name = 'WeatherRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i7.WeatherPage();
    },
  );
}
