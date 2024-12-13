import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:xiaomi_weather_clone/app/di/service_locator.dart';
import 'package:xiaomi_weather_clone/app/extensions/context_extension.dart';
import 'package:xiaomi_weather_clone/bloc/weather/cubit/weather_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/weather/models/weather.dart';
import 'package:xiaomi_weather_clone/presentation/utils/utils.dart';
import 'package:xiaomi_weather_clone/presentation/widgets/custom_appbar_widget.dart';
import 'package:xiaomi_weather_clone/presentation/widgets/url_widget.dart';

@RoutePage()
class AirQualityPage extends StatefulWidget {
  static const String route = 'air-quality';

  const AirQualityPage({super.key});

  @override
  State<AirQualityPage> createState() => _AirQualityPageState();
}

class _AirQualityPageState extends State<AirQualityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await sl<WeatherCubit>().refreshWeather();
        },
        displacement: 10,
        edgeOffset: MediaQuery.of(context).padding.top + 50,
        child: CustomScrollView(
          slivers: [
            MyCustomAppBar(
                leading: GestureDetector(
                  onTap: () => context.router.maybePop(),
                  child: const Icon(Icons.arrow_back),
                ),
                text: context.localizations.airQualityIndex),
            _body(context),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _body(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<Weather?>(
                stream: sl<WeatherCubit>().getCurrentWeatherStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final weather = snapshot.data as Weather;
                  final aqi = weather.current.aqi;

                  final polutionValues = {
                    'PM2.5': aqi.pm25,
                    'PM10': aqi.pm10,
                    'SO2': aqi.sulphurDioxide,
                    'NO2': aqi.nitrogenDioxide,
                    'O2': aqi.ozone,
                    'CO': aqi.carbonMonoxide,
                  };

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                          text: TextSpan(
                              text: '${aqi.aqi.toString()} ',
                              style: context.theme.textTheme.displayMedium!
                                  .copyWith(color: getAqiColor(aqi.condition)),
                              children: [
                            TextSpan(
                                text:
                                    getNameAqiCondition(context, aqi.condition),
                                style: context.theme.textTheme.titleLarge!
                                    .copyWith(
                                        color: getAqiColor(aqi.condition)))
                          ])),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: polutionValues.entries.map((entry) {
                          final value = entry.value;
                          return Expanded(
                            child: Column(
                              children: [
                                Text(
                                  value.toString(),
                                  style: context.theme.textTheme.titleLarge!
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  entry.key,
                                  style: context.theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  );
                }),
            const SizedBox(height: 30),
            const Divider(thickness: 1),
            Column(
              children: [
                const SizedBox(height: 20),
                UrlWidget(
                    url: 'https://open-meteo.com/',
                    child: Center(
                      child: Text(
                        'Open Meteo',
                        style: context.theme.textTheme.bodyMedium!.copyWith(color: Colors.grey.shade500),
                      ),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}