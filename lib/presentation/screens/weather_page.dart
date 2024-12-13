import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:xiaomi_weather_clone/app/core/backgrounds.dart';
import 'package:xiaomi_weather_clone/app/di/service_locator.dart';
import 'package:xiaomi_weather_clone/bloc/weather/cubit/weather_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/weather/models/weather.dart';
import 'package:xiaomi_weather_clone/presentation/widgets/weather/weather_success.dart';
import 'package:xiaomi_weather_clone/presentation/widgets/weather_appbar_widget.dart';

@RoutePage()
class WeatherPage extends StatelessWidget {
  static const route = 'weather';

  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        body: StreamBuilder<Weather?>(
          stream: sl<WeatherCubit>().getCurrentWeatherStream(),
          builder: (context, snapshot) {
            final Weather? weather = snapshot.data;
            return Container(
                decoration: weather == null
                    ? const BoxDecoration(color: Colors.blue)
                    : Backgrounds.getBackground(weather.current.condition),
                child: RefreshIndicator(
                  displacement: 10,
                  edgeOffset: MediaQuery.of(context).padding.top + 70,
                  onRefresh: () async {
                    await sl<WeatherCubit>().refreshWeather();
                  },
                  child: CustomScrollView(
                    slivers: [
                      WeatherAppbar(weather),
                      if (weather != null) WeatherSuccess(weather: weather),
                    ],
                  ),
                ));
          },
        ));
  }
}
