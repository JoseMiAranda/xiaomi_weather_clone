import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xiaomi_weather_clone/app/config/router/app_router.gr.dart';
import 'package:xiaomi_weather_clone/app/core/icons.dart';
import 'package:xiaomi_weather_clone/app/di/service_locator.dart';
import 'package:xiaomi_weather_clone/app/extensions/context_extension.dart';
import 'package:xiaomi_weather_clone/app/extensions/datetime_extension.dart';
import 'package:xiaomi_weather_clone/bloc/search/cubit/search_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/search/models/location.dart';
import 'package:xiaomi_weather_clone/bloc/search/models/search_results.dart';
import 'package:xiaomi_weather_clone/bloc/weather/models/weather.dart';
import 'package:xiaomi_weather_clone/bloc/weathers/weathers_cubit.dart';
import 'package:xiaomi_weather_clone/presentation/utils/utils.dart';
import 'package:xiaomi_weather_clone/presentation/widgets/now_glow_scroll_widget.dart';

class SearchSuccess extends StatefulWidget {
  const SearchSuccess({super.key, required this.query, required this.results});

  final String query;
  final SearchResults results;

  @override
  State<SearchSuccess> createState() => _SearchSuccessState();
}

class _SearchSuccessState extends State<SearchSuccess> {
  late final StreamSubscription<DateTime> _updateWeather;
  late final BehaviorSubject<DateTime> _weatherStream;

  @override
  void initState() {
    super.initState();
    _weatherStream = BehaviorSubject<DateTime>.seeded(DateTime.now());

    _updateWeather = updateWeather().listen((dateTime) async {
      if (widget.results.isEmpty) return;
      final nextUpdate = widget.results.weather!.lastUpdated
          .add(const Duration(hours: 1))
          .copyWith(minute: 0, second: 0);
      if (nextUpdate.isBefore(dateTime.copyWith(minute: 0, second: 0))) {
        debugPrint('Updated weather at: $dateTime');
        await sl<SearchCubit>().fetchResults(widget.query);
      }
    });
  }

  @override
  void dispose() {
    _updateWeather.cancel();
    _weatherStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.results.isEmpty
        ? Expanded(child: Center(child: Text(context.localizations.noResults)))
        : Expanded(
            child: StreamBuilder(
            stream: sl<WeathersCubit>().getWeathersStream(),
            builder: (context, snapshot) {
              final weathers = snapshot.data ?? <Weather>[];
              return NoGlowScroll(
                child: ListView(
                  children: [
                    firstResult(context, widget.results.weather!, weathers),
                    ...locations(context, widget.results.locations, weathers)
                  ],
                ),
              );
            },
          ));
  }
}

List<Widget> locations(
    BuildContext context, List<Location> locations, List<Weather> weathers) {
  return List.generate(
    locations.length,
    (index) {
      final location = locations[index];
      final bool added = weathers.any((e) => e.location == location);
      return GestureDetector(
        onTap: () => context.router.push(ConfirmLocationRoute(
          location: location,
        )),
        child: ListTile(
          title: Text(location.name),
          subtitle: Text(location.country),
          trailing: !added
              ? const Icon(Icons.arrow_forward_ios_rounded)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(context.localizations.added),
                    const SizedBox(
                      width: 3,
                    ),
                    GestureDetector(
                      // onTap: () => Navigator.of(context)
                      //     .pushNamed(WeatherScreen.route),
                      child: const Icon(Icons.arrow_forward_ios_rounded),
                    )
                  ],
                ),
        ),
      );
    },
  );
}

GestureDetector firstResult(
    BuildContext context, Weather weather, List<Weather> weathers) {
  int index = weathers.indexWhere((e) => e.location == weather.location);
  final location = weather.location;
  final added = index > -1;
  if (added) {
    weather = weather.copyWith(id: weathers[index].id!);
  }
  return GestureDetector(
    onTap: () => context.router.push(ConfirmLocationRoute(
      weather: weather
    )),
    child: Column(
      children: [
        ListTile(
          title: Text(location.name),
          subtitle: Text(location.country),
          trailing: !added
              ? const Icon(Icons.arrow_forward_ios_rounded)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(context.localizations.added),
                    const SizedBox(
                      width: 3,
                    ),
                    GestureDetector(
                      child: const Icon(Icons.arrow_forward_ios_rounded),
                    )
                  ],
                ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: weather.daily.length,
            itemBuilder: (context, index) {
              final daily = weather.daily[index];
              return SizedBox(
                width: 75,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(daily.time.nameOfDayWeek(context)),
                    const SizedBox(height: 3),
                    WeatherIcon.getIcon(
                        daily.hourly
                            .firstWhere(
                                (h) => h.temperature == daily.maxTemperature)
                            .condition,
                        false),
                    const SizedBox(height: 12),
                    Text(daily.maxTemperature.round().toString()),
                    const SizedBox(height: 12),
                    Text(daily.minTemperature.round().toString()),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
