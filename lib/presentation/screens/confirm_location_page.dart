import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xiaomi_weather_clone/app/di/service_locator.dart';
import 'package:xiaomi_weather_clone/bloc/confirm/confirm_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/search/models/location.dart';
import 'package:xiaomi_weather_clone/bloc/weather/models/weather.dart';
import 'package:xiaomi_weather_clone/presentation/widgets/confirm/confirm_initial.dart';
import 'package:xiaomi_weather_clone/presentation/widgets/confirm/confirm_success.dart';
import 'package:xiaomi_weather_clone/presentation/widgets/confirm/confirm_loading.dart';
import 'package:xiaomi_weather_clone/presentation/widgets/confirm/confirm_failed.dart';

@RoutePage()
class ConfirmLocationPage extends StatefulWidget {
  static const route = 'confirm-city';
  final Weather? weather;
  final Location? location; // From others results

  const ConfirmLocationPage({super.key, this.weather, this.location})
      : assert(
            (weather != null && location == null) ||
                (weather == null && location != null),
            'One non-nullable required value');

  @override
  State<ConfirmLocationPage> createState() => _ConfirmLocationPageState();
}

class _ConfirmLocationPageState extends State<ConfirmLocationPage> {
  @override
  void initState() {
    super.initState();

    if (widget.weather == null) {
      sl<ConfirmCubit>().fetchWeather(widget.location!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.weather != null
          ? ConfirmLoaded(
              weather: widget.weather!,
            )
          : BlocBuilder<ConfirmCubit, ConfirmState>(
              bloc: sl<ConfirmCubit>(),
              builder: (context, state) {
                return switch (state.status) {
                  ConfirmStatus.initial => const ConfirmInitial(),
                  ConfirmStatus.loading => const ConfirmLoading(),
                  ConfirmStatus.success => ConfirmLoaded(
                      weather: state.weather!,
                    ),
                  _ => const ConfirmFailed(),
                };
              },
            ),
    );
  }
}
