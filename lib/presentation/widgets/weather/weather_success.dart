import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xiaomi_weather_clone/app/core/backgrounds.dart';
import 'package:xiaomi_weather_clone/app/core/icons.dart';
import 'package:xiaomi_weather_clone/app/di/service_locator.dart';
import 'package:xiaomi_weather_clone/app/extensions/context_extension.dart';
import 'package:xiaomi_weather_clone/app/extensions/datetime_extension.dart';
import 'package:xiaomi_weather_clone/bloc/units/models/weather_units.dart';
import 'package:xiaomi_weather_clone/bloc/units/units_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/weather/cubit/weather_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/weather/models/aqi.dart';
import 'package:xiaomi_weather_clone/bloc/weather/models/weather.dart';
import 'package:xiaomi_weather_clone/presentation/screens/air_quality_page.dart';
import 'package:xiaomi_weather_clone/presentation/utils/painter.dart';
import 'package:xiaomi_weather_clone/presentation/utils/utils.dart';
import 'package:xiaomi_weather_clone/presentation/widgets/url_widget.dart';

class WeatherSuccess extends StatefulWidget {
  final Weather weather;

  const WeatherSuccess({super.key, required this.weather});

  @override
  State<WeatherSuccess> createState() => _WeatherSuccessState();
}

class _WeatherSuccessState extends State<WeatherSuccess> {
  late final StreamSubscription<DateTime> _updateWeather;
  late final StreamSubscription<DateTime> _updateSun;
  late final BehaviorSubject<DateTime> _sunStream;
  late final BehaviorSubject<DateTime> _weatherStream;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor:
          Backgrounds.getBackground(widget.weather.current.condition)
              .gradient!
              .colors
              .last,
    ));

    _sunStream = BehaviorSubject<DateTime>.seeded(DateTime.now());
    _weatherStream = BehaviorSubject<DateTime>.seeded(DateTime.now());

    _updateSun = updateSun().listen((dateTime) {
      debugPrint('Updated sun at: $dateTime');
      _sunStream.add(dateTime);
    });
    _updateWeather = updateWeather().listen((dateTime) async {
      final weather = await sl<WeatherCubit>().getCurrentWeatherStream().first;
      if (weather == null) return;
      final nextUpdate = weather.lastUpdated
          .add(const Duration(hours: 1))
          .copyWith(minute: 0, second: 0);
      if (nextUpdate.isBefore(dateTime.copyWith(minute: 0, second: 0))) {
        debugPrint('Updated weather at: $dateTime');
        await sl<WeatherCubit>().refreshWeather();
      }
    });
  }

  @override
  void dispose() {
    _updateSun.cancel();
    _sunStream.close();

    _updateWeather.cancel();
    _weatherStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        //? Page View?
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            _dailyWeather(widget.weather.daily),
            const SizedBox(height: 40),
            _hourlyWeather(widget.weather.daily),
            const SizedBox(height: 40),
            _moreDetails(widget.weather),
            const SizedBox(height: 20),
            SizedBox(
                height: 84,
                child:
                    Center(child: _AnimatedButton(widget.weather.current.aqi))),
            const SizedBox(height: 20),
            calledApi(context),
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }

  Container _moreDetails(Weather weather) {
    final daily = weather.daily.first;
    return Container(
      padding: const EdgeInsets.all(20).copyWith(top: 30),
      height: 320,
      decoration: BoxDecoration(
          color: Colors.white10, borderRadius: BorderRadius.circular(12.0)),
      child: BlocBuilder<UnitsCubit, WeatherUnits>(
        builder: (context, state) => Column(
          children: [
            Expanded(child: LayoutBuilder(builder: (context, constraints) {
              return StreamBuilder<DateTime>(
                stream: _sunStream.stream,
                builder: (context, snapshot) {
                  return CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: SunArcPainter(
                        sunrise: daily.sunrise,
                        sunset: daily.sunset,
                      ));
                },
              );
            })),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 7.5, right: 7.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${context.localizations.sunrise} ${daily.sunrise.toFormat(DateTimeFormat.hhmm, separator: ':')}',
                      style: context.theme.textTheme.bodySmall!
                          .copyWith(color: Colors.white)),
                  Text(
                      '${context.localizations.sunset} ${daily.sunset.toFormat(DateTimeFormat.hhmm, separator: ':')}',
                      style: context.theme.textTheme.bodySmall!
                          .copyWith(color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _moreDetailsField(context, context.localizations.feelsLike,
                    '${weather.current.feelsLikeTemperature.round()}${state.temperatureUnits.unit}'),
                _moreDetailsField(context, context.localizations.humidity,
                    '${weather.current.humidity}%')
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _moreDetailsField(
                    context,
                    context.localizations.precipitationProbability,
                    '${daily.precipitationProbability}%'),
                _moreDetailsField(context, context.localizations.pressure,
                    '${daily.maxSeaPressure.round()}${state.pressureUnits.unit}')
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _moreDetailsField(context, context.localizations.windSpeed,
                    '${daily.maxWindSpeed} ${state.windSpeedUnits.unit}'),
                _moreDetailsField(
                    context, context.localizations.uvIndex, '${daily.uvIndex}')
              ],
            ),
          ],
        ),
      ),
    );
  }

  Expanded _moreDetailsField(
      BuildContext context, String title, String subtitle) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.theme.textTheme.bodySmall!
                .copyWith(color: Colors.white70),
          ),
          Text(subtitle,
              style: context.theme.textTheme.titleLarge!
                  .copyWith(color: Colors.white)),
        ],
      ),
    );
  }

  SizedBox _hourlyWeather(List<Daily> daily) {
    List<Widget> getChildren(WindSpeedUnits windSpeedUnits) {
      final now = DateTime.now();
      final indexToday = daily.expand((e) => e.hourly).toList().indexWhere(
          (e) => e.time
              .copyWith(
                  hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0)
              .isAtSameMomentAs(now.copyWith(
                  hour: 0,
                  minute: 0,
                  second: 0,
                  millisecond: 0,
                  microsecond: 0)));

      if (indexToday < 0) return [];

      final List<Widget> children = [];

      List<Daily> daysTemp = [...daily];

      daysTemp = daysTemp.sublist((indexToday) ~/ 24);

      for (int i = 0; i < daysTemp.length; i++) {
        final d = daysTemp[i];
        final hourly = i != 0
            ? d.hourly
            : d.hourly.sublist(daysTemp.first.hourly.indexWhere((h) => h.time
                .copyWith(minute: 0, second: 0, millisecond: 0, microsecond: 0)
                .isAtSameMomentAs(now.copyWith(
                    minute: 0, second: 0, millisecond: 0, microsecond: 0))));

        for (int j = 0; j < hourly.length; j++) {
          final h = hourly[j];
          final isNight =
              h.time.isAfter(d.sunset) || h.time.isBefore(d.sunrise);
          children.add(SizedBox(
            width: 90,
            child: Column(
              children: [
                () {
                  String text = '';
                  if (i == 0 && j == 0) {
                    text = context.localizations.today;
                  } else if (h.time.isAtSameMomentAs(d.sunrise
                      .copyWith(minute: 0, millisecond: 0, microsecond: 0))) {
                    text = context.localizations.sunrise;
                  } else if (h.time.isAtSameMomentAs(d.sunset
                      .copyWith(minute: 0, millisecond: 0, microsecond: 0))) {
                    text = context.localizations.sunset;
                  } else {
                    text = h.time.hour == 0
                        ? '${h.time.day}/${h.time.month}'
                        : '${h.time.hour}:${h.time.minute.toString().padLeft(2, '0')}';
                  }
                  return Text(
                    text,
                    style: context.theme.textTheme.bodySmall!
                        .copyWith(color: Colors.white70),
                  );
                }(),
                Text(
                  '${h.temperature.round().toString()}º',
                  style: const TextStyle(color: Colors.white),
                ),
                Expanded(
                  child: WeatherIcon.getIcon(
                    h.condition,
                    isNight,
                  ),
                ),
                FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      WindDirectionIcon.getIcon(h.windDirection),
                      Text(
                        '${h.windSpeed.toString()}${windSpeedUnits.unit}',
                        style: context.theme.textTheme.bodySmall!
                            .copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ));
        }
      }
      return children;
    }

    return SizedBox(
      height: 90,
      child: Column(
        children: [
          Expanded(
            child: BlocBuilder<UnitsCubit, WeatherUnits>(
              bloc: sl<UnitsCubit>(),
              builder: (context, state) => ListView(
                  scrollDirection: Axis.horizontal,
                  children: getChildren(state.windSpeedUnits)),
            ),
          ),
        ],
      ),
    );
  }

  Column _dailyWeather(List<Daily> daily) {
    return Column(
      children: [
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.end,
        //   children: [
        //     GestureDetector(
        //       child: const Row(
        //         children: [
        //           Text(
        //             'Más detalles',
        //             style: TextStyle(color: Colors.white),
        //           ),
        //           Icon(
        //             Icons.arrow_forward_ios_rounded,
        //             size: 16.0,
        //             color: Colors.white,
        //           )
        //         ],
        //       ),
        //     )
        //   ],
        // ),
        const SizedBox(height: 10),
        ...List.generate(daily.length > 3 ? 3 : daily.length, (index) {
          final isNigth = DateTime.now().isAfter(daily.first.sunset) ||
              DateTime.now().isBefore(daily.first.sunrise);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(children: [
              WeatherIcon.getIcon(
                  (isNigth
                          ? daily[index].hourly.firstWhere((h) =>
                              h.temperature == daily[index].minTemperature)
                          : daily[index].hourly.firstWhere((h) =>
                              h.temperature == daily[index].maxTemperature))
                      .condition,
                  isNigth),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(
                      daily[index].time.nameOfDayWeek(context, today: true),
                      style: context.theme.textTheme.bodyLarge!
                          .copyWith(color: Colors.white))),
              const SizedBox(width: 10),
              Text(
                  '${daily[index].maxTemperature.round()}º / ${daily[index].minTemperature.round()}º',
                  style: context.theme.textTheme.bodyLarge!
                      .copyWith(color: Colors.white))
            ]),
          );
        }),
        const SizedBox(height: 10),
        // ElevatedButton(
        //     style: ButtonStyle(
        //       splashFactory: NoSplash.splashFactory,
        //       shape: WidgetStatePropertyAll(RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(25.0),
        //       )),
        //       backgroundColor: const WidgetStatePropertyAll(Colors.white10),
        //       shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        //       foregroundColor: const WidgetStatePropertyAll(Colors.white),
        //     ),
        //     onPressed: () {
        //       HapticFeedback.mediumImpact();
        //     },
        //     child: const SizedBox(
        //         width: double.infinity,
        //         child: Padding(
        //           padding: EdgeInsets.symmetric(vertical: 12),
        //           child: Text(
        //             'Previsión para 5 días',
        //             style: TextStyle(fontSize: 16),
        //             textAlign: TextAlign.center,
        //           ),
        //         ))),
      ],
    );
  }

  Center calledApi(BuildContext context) {
    return Center(
      child: UrlWidget(
        url: 'https://open-meteo.com/',
        child: Text(
          context.localizations.dataProvided('Open Metep'),
          style: context.theme.textTheme.labelSmall!
              .copyWith(color: Colors.white70),
        ),
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final Aqi aqi;
  const _AnimatedButton(this.aqi);

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedSize(
        curve: Curves.bounceInOut,
        duration: const Duration(milliseconds: 200),
        child: Container(
          height: _isPressed ? 80 : 84,
          padding:
              !_isPressed ? null : const EdgeInsets.symmetric(horizontal: 4),
          child: ElevatedButton(
            onPressed: () => context.router.pushNamed(AirQualityPage.route),
            style: ButtonStyle(
              splashFactory: NoSplash.splashFactory,
              padding: const WidgetStatePropertyAll(EdgeInsets.all(0)),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              backgroundColor: const WidgetStatePropertyAll(Colors.white10),
              shadowColor: const WidgetStatePropertyAll(Colors.transparent),
              foregroundColor: const WidgetStatePropertyAll(Colors.white),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.localizations.airQualityIndex,
                    style: context.theme.textTheme.bodySmall!
                        .copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(getAqiIcon(widget.aqi.condition),
                          color: Colors.white),
                      const SizedBox(width: 8),
                      Text(widget.aqi.aqi.toString(),
                          style: context.theme.textTheme.titleLarge!
                              .copyWith(color: Colors.white)),
                      const SizedBox(width: 8),
                      const Spacer(),
                      Text(
                        context.localizations.completedAqiForecast,
                        style: context.theme.textTheme.bodySmall!
                            .copyWith(color: Colors.white70),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: _isPressed ? 14 : 16, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
