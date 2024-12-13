import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xiaomi_weather_clone/app/config/router/app_router.gr.dart';
import 'package:xiaomi_weather_clone/app/core/icons.dart';
import 'package:xiaomi_weather_clone/app/di/service_locator.dart';
import 'package:xiaomi_weather_clone/app/extensions/context_extension.dart';
import 'package:xiaomi_weather_clone/app/extensions/datetime_extension.dart';
import 'package:xiaomi_weather_clone/bloc/confirm/confirm_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/search/cubit/search_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/units/models/weather_units.dart';
import 'package:xiaomi_weather_clone/bloc/units/units_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/weather/cubit/weather_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/weather/models/weather.dart';
import 'package:xiaomi_weather_clone/bloc/weathers/weathers_cubit.dart';
import 'package:xiaomi_weather_clone/presentation/utils/painter.dart';
import 'package:xiaomi_weather_clone/presentation/utils/utils.dart';
import 'package:xiaomi_weather_clone/presentation/widgets/custom_appbar_widget.dart';
import 'package:xiaomi_weather_clone/presentation/widgets/now_glow_scroll_widget.dart';
import 'package:xiaomi_weather_clone/presentation/utils/math.dart';

class ConfirmLoaded extends StatefulWidget {
  const ConfirmLoaded({super.key, required this.weather});

  final Weather weather;
  @override
  State<ConfirmLoaded> createState() => _ConfirmLoadedState();
}

class _ConfirmLoadedState extends State<ConfirmLoaded> {
  late final StreamSubscription<DateTime> _updateWeather;
  late final BehaviorSubject<DateTime> _weatherStream;

  @override
  void initState() {
    super.initState();
    _weatherStream = BehaviorSubject<DateTime>.seeded(DateTime.now());

    _updateWeather = updateWeather().listen((dateTime) async {
      final nextUpdate = widget.weather.lastUpdated
          .add(const Duration(hours: 1))
          .copyWith(minute: 0, second: 0);
      if (nextUpdate.isBefore(dateTime.copyWith(minute: 0, second: 0))) {
        debugPrint('Updated weather at: $dateTime');
        await sl<ConfirmCubit>().fetchWeather(widget.weather.location);
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
    return NoGlowScroll(
        child: CustomScrollView(
      slivers: [
        MyCustomAppBar(
          leading: GestureDetector(
              onTap: () => context.router.maybePop(),
              child: const Icon(Icons.arrow_back)),
          trailing: const SizedBox(),
          height: MediaQuery.of(context).padding.top + 50,
          text: widget.weather.location.name,
        ),
        _body(context, widget.weather),
      ],
    ));
  }
}

SliverToBoxAdapter _body(BuildContext context, Weather weather) {
  return SliverToBoxAdapter(
    child: SizedBox(
      height: MediaQuery.of(context).size.height -
          (MediaQuery.of(context).padding.top + 50),
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          _dailyForecast(weather),
          const SizedBox(
            height: 40,
          ),
          _button(context, weather)
        ],
      ),
    ),
  );
}

StreamBuilder<List<Weather>> _button(BuildContext context, Weather weather) {
  return StreamBuilder<List<Weather>>(
    stream: sl<WeathersCubit>().getWeathersStream(),
    builder: (context, snapshot) {
      final Weather? addedWeather = () {
        final weathers = snapshot.data;
        if (weathers == null) return null;
        for (var w in weathers) {
          if (w.location == weather.location) return w;
        }
        return null;
      }();
      return addedWeather == null
          ? addWeatherButton(context, weather)
          : goToWeatherButton(context, addedWeather);
    },
  );
}

Widget goToWeatherButton(BuildContext context, Weather weather) {
  return Column(
    children: [
      OutlinedButton(
        onPressed: () {
          sl<WeatherCubit>().saveWeather(weather);
          sl<SearchCubit>().resetState();
          context.router.popUntilRouteWithName(WeatherRoute.name);
        },
        style: OutlinedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(16),
          backgroundColor: Colors.grey.shade500,
          side: BorderSide.none,
        ),
        child: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.white,
        ),
      ),
      const SizedBox(
        height: 10,
      ),
      Text(context.localizations.seeInInitialPage)
    ],
  );
}

Widget addWeatherButton(BuildContext context, Weather weather) {
  return BlocBuilder(
    bloc: sl<WeatherCubit>(),
    builder: (BuildContext context, WeatherState state) {
      return Column(
        children: [
          OutlinedButton(
            onPressed: state.status == WeatherStatus.loading
                ? null
                : () => sl<WeatherCubit>().saveWeather(weather),
            style: OutlinedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.grey.shade500,
              side: BorderSide.none,
            ),
            child: state.status == WeatherStatus.loading
                ? const CircularProgressIndicator()
                : const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(context.localizations.addToInitialPage)
        ],
      );
    },
  );
}

SizedBox _dailyForecast(Weather weather) {
  final maxTempDay = weather.daily
      .reduce((value, element) =>
          value.maxTemperature > element.maxTemperature ? value : element)
      .maxTemperature
      .round()
      .toDouble();
  final minTempDay = weather.daily
      .reduce((value, element) =>
          value.minTemperature < element.minTemperature ? value : element)
      .minTemperature
      .round()
      .toDouble();

  return SizedBox(
    height: 400,
    child: Column(
      children: [
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: weather.daily.length,
            itemBuilder: (context, index) {
              final day = weather.daily[index];
              final maxTemperature = day.maxTemperature.round();
              final minTemperature = day.minTemperature.round();
              final maxTempHour = day.hourly
                  .firstWhere((h) => h.temperature == day.maxTemperature);
              final minTempHour = day.hourly
                  .firstWhere((h) => h.temperature == day.minTemperature);

              final prevDay = index > 0 ? weather.daily[index - 1] : null;
              final nextDay = index < weather.daily.length - 1
                  ? weather.daily[index + 1]
                  : null;

              return SizedBox(
                width: 82,
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Text(day.time.nameOfDayWeek(context)),
                    Text(
                        day.time.toFormat(DateTimeFormat.ddMM, separator: '/')),
                    const SizedBox(height: 20),
                    WeatherIcon.getIcon(maxTempHour.condition, false),
                    Expanded(child: LayoutBuilder(
                      builder: (context, constraints) {
                        final maxHeight = constraints.maxHeight - 30;

                        final maxTempHeight = interpolateBetweenPoints(
                          x1: maxTempDay,
                          y1: 0,
                          x0: minTempDay,
                          y0: maxHeight,
                          x: maxTemperature.toDouble(),
                        );

                        final minTempHeight = interpolateBetweenPoints(
                          x1: maxTempDay,
                          y1: 0,
                          x0: minTempDay,
                          y0: maxHeight,
                          x: minTemperature.toDouble(),
                        );

                        final prevMaxTempHeight = prevDay == null
                            ? -1.0
                            : interpolateBetweenPoints(
                                x1: maxTempDay,
                                y1: 0,
                                x0: minTempDay,
                                y0: maxHeight,
                                x: (maxTemperature +
                                        prevDay.maxTemperature.round()) /
                                    2,
                              );

                        final prevMinTempHeight = prevDay == null
                            ? -1.0
                            : interpolateBetweenPoints(
                                x1: maxTempDay,
                                y1: 0,
                                x0: minTempDay,
                                y0: maxHeight,
                                x: (minTemperature +
                                        prevDay.minTemperature.round()) /
                                    2,
                              );

                        final nextMaxTempHeight = nextDay == null
                            ? -1.0
                            : interpolateBetweenPoints(
                                x1: maxTempDay,
                                y1: 0,
                                x0: minTempDay,
                                y0: maxHeight,
                                x: (maxTemperature +
                                        nextDay.maxTemperature.round()) /
                                    2,
                              );

                        final nextMinTempHeight = nextDay == null
                            ? -1.0
                            : interpolateBetweenPoints(
                                x1: maxTempDay,
                                y1: 0,
                                x0: minTempDay,
                                y0: maxHeight,
                                x: (minTemperature +
                                        nextDay.minTemperature.round()) /
                                    2,
                              );

                        return Stack(
                          children: [
                            ..._points(maxTempHeight, minTempHeight, maxTemperature.round(), minTemperature.round()),
                            ..._lines(
                              maxTempHeight: maxTempHeight,
                              minTempHeight: minTempHeight,
                              prevMinTempHeight: prevMinTempHeight,
                              nextMinTempHeight: nextMinTempHeight,
                              prevMaxTempHeight: prevMaxTempHeight,
                              nextMaxTempHeight: nextMaxTempHeight,
                              maxWidth: constraints.maxWidth,
                              maxTemperature: maxTemperature,
                              minTemperature: minTemperature,
                              nextDay: nextDay,
                              prevDay: prevDay,
                            ),
                          ],
                        );
                      },
                    )),
                    WeatherIcon.getIcon(minTempHour.condition, true),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        WindDirectionIcon.getIcon(day.maxWindDirection),
                        BlocBuilder<UnitsCubit, WeatherUnits>(
                          bloc: sl<UnitsCubit>(),
                          builder: (context, state) {
                            return Text(
                              '${day.maxWindSpeed.toString()}${state.windSpeedUnits.unit}',
                              style: context.theme.textTheme.labelMedium,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
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

List<Positioned> _points(
    double maxTempHeight, double minTempHeight, int maxTemperature, int minTemperature) {
  return [
    Positioned(
      top: maxTempHeight,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            maxTemperature.toString(),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.grey,
                width: 1,
              ),
            ),
          )
        ],
      ),
    ),
    Positioned(
      top: minTempHeight,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.grey,
                width: 1,
              ),
            ),
          ),
          Text(
            minTemperature.toString(),
          ),
        ],
      ),
    ),
  ];
}

List<Positioned> _lines({
  required double maxTempHeight,
  required double minTempHeight,
  required double prevMinTempHeight,
  required double nextMinTempHeight,
  required double prevMaxTempHeight,
  required double nextMaxTempHeight,
  required double maxWidth,
  required int maxTemperature,
  required int minTemperature,
  required Daily? prevDay,
  required Daily? nextDay,
}) {
  return [
    if (prevDay != null)
      Positioned(
        top: minTempHeight +
            5 -
            (prevMinTempHeight > minTempHeight
                ? 0
                : (prevMinTempHeight - minTempHeight).abs()),
        left: 0,
        child: CustomPaint(
            size: Size(
                (maxWidth / 2) - 5, (prevMinTempHeight - minTempHeight).abs()),
            painter: DiagonalPainter(
                inverse: prevDay.minTemperature.round() < minTemperature)),
      ),
    if (nextDay != null)
      Positioned(
        top: minTempHeight +
            5 -
            (nextMinTempHeight > minTempHeight
                ? 0
                : (nextMinTempHeight - minTempHeight).abs()),
        right: 0,
        child: CustomPaint(
            size: Size(
                (maxWidth / 2) - 5, (nextMinTempHeight - minTempHeight).abs()),
            painter: DiagonalPainter(
                inverse: nextDay.minTemperature.round() > minTemperature)),
      ),
    if (prevDay != null)
      Positioned(
        top: maxTempHeight +
            25 -
            (prevMaxTempHeight > maxTempHeight
                ? 0
                : (prevMaxTempHeight - maxTempHeight).abs()),
        left: 0,
        child: CustomPaint(
            size: Size(
                (maxWidth / 2) - 5, (prevMaxTempHeight - maxTempHeight).abs()),
            painter: DiagonalPainter(
                inverse: prevDay.maxTemperature.round() < maxTemperature)),
      ),
    if (nextDay != null)
      Positioned(
        top: maxTempHeight +
            25 -
            (nextMaxTempHeight > maxTempHeight
                ? 0
                : (nextMaxTempHeight - maxTempHeight).abs()),
        right: 0,
        child: CustomPaint(
            size: Size(
                (maxWidth / 2) - 5, (nextMaxTempHeight - maxTempHeight).abs()),
            painter: DiagonalPainter(
                inverse: nextDay.maxTemperature.round() > maxTemperature)),
      ),
  ];
}
