import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xiaomi_weather_clone/app/core/backgrounds.dart';
import 'package:xiaomi_weather_clone/app/di/service_locator.dart';
import 'package:xiaomi_weather_clone/app/extensions/context_extension.dart';
import 'package:xiaomi_weather_clone/bloc/units/models/weather_units.dart';
import 'package:xiaomi_weather_clone/bloc/units/units_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/weather/cubit/weather_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/weather/models/weather.dart';
import 'package:xiaomi_weather_clone/presentation/screens/air_quality_page.dart';
import 'package:xiaomi_weather_clone/presentation/screens/saved_weathers_page.dart';
import 'package:xiaomi_weather_clone/presentation/screens/settings_page.dart';
import 'package:xiaomi_weather_clone/presentation/utils/math.dart';
import 'package:xiaomi_weather_clone/presentation/utils/utils.dart';
import 'package:xiaomi_weather_clone/presentation/widgets/custom_appbar_widget.dart';
import 'package:xiaomi_weather_clone/presentation/widgets/fade_widget.dart';

class WeatherAppbar extends StatefulWidget {
  final Weather? weather;
  const WeatherAppbar(
    this.weather, {
    super.key,
  });

  @override
  State<WeatherAppbar> createState() => _WeatherAppbarState();
}

class _WeatherAppbarState extends State<WeatherAppbar> {
  bool _transparentAppbar = true;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverAppBarDelegate(
        minHeight: MediaQuery.of(context).padding.top + 70,
        maxHeight: 350,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: () {
                    final heightFator = (MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top -
                            50) /
                        MediaQuery.of(context).size.height;
                    return heightFator < 0 ? null : heightFator;
                  }(),
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height,
                    decoration: _transparentAppbar
                        ? null
                        : widget.weather == null
                            ? const BoxDecoration(color: Colors.blue)
                            : Backgrounds.getBackground(
                                widget.weather!.current.condition),
                    child: const SizedBox(),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).padding.top + 70,
              child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 20,
                    left: 20,
                    right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                        onTap: () =>
                            context.router.pushNamed(SavedWeathersPage.route),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                        )),
                    if (widget.weather != null)
                      Column(
                        children: [
                          Text(
                            widget.weather!.location.name,
                            style: context.theme.textTheme.titleLarge!
                                .copyWith(color: Colors.white),
                          ),
                          BlocBuilder<WeatherCubit, WeatherState>(
                            bloc: sl<WeatherCubit>(),
                            builder: (context, state) {
                              return switch (state.status) {
                                WeatherStatus.loading => Text(
                                    context.localizations.loading,
                                    style:
                                        const TextStyle(color: Colors.white)),
                                WeatherStatus.failure => Text(
                                    context.localizations.updateFailed,
                                    style:
                                        const TextStyle(color: Colors.white)),
                                WeatherStatus.success =>
                                  const SizedBox.shrink(),
                                _ => const SizedBox.shrink(),
                              };
                            },
                          )
                        ],
                      ),
                    InkWell(
                        onTap: () => context.router.pushNamed(
                              SettingsPage.route,
                            ),
                        child: const Icon(
                          Icons.more_vert_rounded,
                          color: Colors.white,
                        )),
                  ],
                ),
              ),
            ),
            if (widget.weather != null)
              LayoutBuilder(
                builder: (context, constraints) {
                  double scrollRatio = constraints.maxHeight / 350;
                  scrollRatio = scrollRatio.clamp(0.0, 1.0);

                  final double transparencyRate = interpolateBetweenPoints(
                    y0: 0,
                    y1: 1,
                    x: scrollRatio,
                    x0: 0.65,
                    x1: 1,
                  ).clamp(0.0, 1.0);

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (transparencyRate <= 0.0 && _transparentAppbar) {
                      setState(() {
                        _transparentAppbar = false;
                      });
                    } else if (transparencyRate > 0.0 && !_transparentAppbar) {
                      setState(() {
                        _transparentAppbar = true;
                      });
                    }
                  });

                  return BlocBuilder<UnitsCubit, WeatherUnits>(
                    bloc: sl<UnitsCubit>(),
                    builder: (context, state) => FadeWidget(
                        transparencyRate: transparencyRate,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Spacer(),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            '${widget.weather!.current.temperature.round()}',
                                        style: context
                                            .theme.textTheme.displayLarge!
                                            .copyWith(color: Colors.white),
                                      ),
                                      WidgetSpan(
                                        child: Transform.translate(
                                          offset: const Offset(-0,
                                              -40), // Ajusta el offset vertical según sea necesario
                                          child: Text(
                                            state.temperatureUnits.unit,
                                            style: context
                                                .theme.textTheme.titleLarge!
                                                .copyWith(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  getNameCondition(context,
                                      widget.weather!.current.condition),
                                  style: context.theme.textTheme.headlineSmall!
                                      .copyWith(color: Colors.white),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => context.router
                                      .pushNamed(AirQualityPage.route),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white10,
                                        borderRadius:
                                            BorderRadius.circular(16.0)),
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.energy_savings_leaf_outlined,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                            '${context.localizations.aqi} ${widget.weather!.current.aqi.aqi}',
                                            style: context
                                                .theme.textTheme.bodySmall!
                                                .copyWith(color: Colors.white))
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        )),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
