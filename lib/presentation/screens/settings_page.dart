import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xiaomi_weather_clone/app/core/icons.dart';
import 'package:xiaomi_weather_clone/app/di/service_locator.dart';
import 'package:xiaomi_weather_clone/app/extensions/context_extension.dart';
import 'package:xiaomi_weather_clone/bloc/language/language_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/units/models/weather_units.dart';
import 'package:xiaomi_weather_clone/bloc/units/units_cubit.dart';
import 'package:xiaomi_weather_clone/presentation/widgets/custom_appbar_widget.dart';
import 'package:xiaomi_weather_clone/presentation/widgets/now_glow_scroll_widget.dart';
import 'package:xiaomi_weather_clone/presentation/widgets/selection_button_widget.dart';
import 'package:xiaomi_weather_clone/presentation/widgets/url_widget.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  static const route = 'settings';

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NoGlowScroll(
            child: CustomScrollView(
      slivers: [_appBar(context), _body(context)],
    )));
  }

  Widget _appBar(BuildContext context) {
    return MyCustomAppBar(
        leading: GestureDetector(
          onTap: () => context.router.maybePop(),
          child: const Icon(Icons.arrow_back),
        ),
        text: context.localizations.settings);
  }

  SliverToBoxAdapter _body(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.localizations.language,
                style: context.theme.textTheme.bodyMedium!
                    .copyWith(color: Colors.grey)),
            const SizedBox(height: 10),
            _languages(),
            const SizedBox(height: 15),
            const Divider(thickness: 1),
            const SizedBox(height: 15),
            Text(context.localizations.units,
                style: context.theme.textTheme.bodyMedium!
                    .copyWith(color: Colors.grey)),
            const SizedBox(height: 8),
            _units(),
            const SizedBox(height: 15),
            const Divider(thickness: 1),
            const SizedBox(height: 15),
            _urlGithub(context)
          ],
        ),
      ),
    );
  }

  Column _units() {
    return Column(
      children: [
        _temperatureUnits(),
        _windSpeedUnits(),
        _pressureUnits(),
      ],
    );
  }

  UrlWidget _urlGithub(BuildContext context) {
    return UrlWidget(
        url: 'https://github.com/JoseMiAranda',
        child: Center(
          child: Text(
            context.localizations.madedBy('JoseMiAranda'),
            style: const TextStyle(color: Colors.grey),
          ),
        ));
  }

  BlocBuilder<UnitsCubit, WeatherUnits> _pressureUnits() {
    return BlocBuilder<UnitsCubit, WeatherUnits>(
      bloc: sl<UnitsCubit>(),
      buildWhen: (previous, current) =>
          previous.pressureUnits != current.pressureUnits,
      builder: (context, units) {
        return SelectionButton(
            title: context.localizations.pressureUnit,
            initialValue: units.pressureUnits.name,
            list: <SelectionItem>[
              SelectionItem(
                  title: context.localizations.hPaDescription,
                  value: PressureUnits.hpa.name),
              SelectionItem(
                  title: context.localizations.mbarDescription,
                  value: PressureUnits.mbar.name),
            ],
            onSelected: (value) {
              if (value == units.windSpeedUnits.name) return;
              sl<UnitsCubit>().changePressureUnits(
                  PressureUnits.values.firstWhere((e) => e.name == value));
            });
      },
    );
  }

  BlocBuilder<UnitsCubit, WeatherUnits> _windSpeedUnits() {
    return BlocBuilder<UnitsCubit, WeatherUnits>(
      bloc: sl<UnitsCubit>(),
      buildWhen: (previous, current) =>
          previous.windSpeedUnits != current.windSpeedUnits,
      builder: (context, units) {
        return SelectionButton(
            title: context.localizations.windSpeedUnit,
            initialValue: units.windSpeedUnits.name,
            list: <SelectionItem>[
              SelectionItem(
                  title: context.localizations.kmhDescription,
                  value: WindSpeedUnits.kph.name),
              SelectionItem(
                  title: context.localizations.mphDescription,
                  value: WindSpeedUnits.mph.name),
            ],
            onSelected: (value) {
              if (value == units.windSpeedUnits.name) return;
              sl<UnitsCubit>().changeWindSpeedUnits(
                  WindSpeedUnits.values.firstWhere((e) => e.name == value));
            });
      },
    );
  }

  BlocBuilder<UnitsCubit, WeatherUnits> _temperatureUnits() {
    return BlocBuilder<UnitsCubit, WeatherUnits>(
      bloc: sl<UnitsCubit>(),
      buildWhen: (previous, current) =>
          previous.temperatureUnits != current.temperatureUnits,
      builder: (context, units) {
        return SelectionButton(
            title: context.localizations.temperatureUnit,
            initialValue: units.temperatureUnits.name,
            list: <SelectionItem>[
              SelectionItem(
                  title: TemperatureUnits.celsius.unit,
                  value: TemperatureUnits.celsius.name),
              SelectionItem(
                  title: TemperatureUnits.fahrenheit.unit,
                  value: TemperatureUnits.fahrenheit.name),
            ],
            onSelected: (value) {
              if (value == units.windSpeedUnits.name) return;
              sl<UnitsCubit>().changeTemperatureUnits(
                  TemperatureUnits.values.firstWhere((e) => e.name == value));
            });
      },
    );
  }

  BlocBuilder<LanguageCubit, String> _languages() {
    return BlocBuilder<LanguageCubit, String>(
      bloc: sl<LanguageCubit>(),
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                onPressed: () => sl<LanguageCubit>().changeLanguage('en'),
                child: SizedBox(
                    width: 125,
                    height: 45,
                    child: Row(children: [
                      FlagsIcon.getIcon('en'),
                      const SizedBox(width: 5),
                      Text(context.localizations.english),
                      const SizedBox(width: 5),
                      if (state == 'en')
                        const Icon(Icons.check, color: Colors.green)
                    ]))),
            OutlinedButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                onPressed: () => sl<LanguageCubit>().changeLanguage('es'),
                child: SizedBox(
                    width: 125,
                    height: 45,
                    child: Row(children: [
                      FlagsIcon.getIcon('es'),
                      const SizedBox(width: 5),
                      Text(context.localizations.spanish),
                      const SizedBox(width: 5),
                      if (state == 'es')
                        const Icon(Icons.check, color: Colors.green)
                    ]))),
          ],
        );
      },
    );
  }
}
