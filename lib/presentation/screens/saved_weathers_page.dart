import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xiaomi_weather_clone/app/config/router/app_router.gr.dart';
import 'package:xiaomi_weather_clone/app/core/backgrounds.dart';
import 'package:xiaomi_weather_clone/app/di/service_locator.dart';
import 'package:xiaomi_weather_clone/app/extensions/context_extension.dart';
import 'package:xiaomi_weather_clone/bloc/weather/cubit/weather_cubit.dart';
import 'package:xiaomi_weather_clone/bloc/weather/models/weather.dart';
import 'package:xiaomi_weather_clone/bloc/weathers/weathers_cubit.dart';

import 'package:xiaomi_weather_clone/presentation/screens/search_page.dart';
import 'package:xiaomi_weather_clone/presentation/utils/utils.dart';
import 'package:xiaomi_weather_clone/presentation/widgets/custom_appbar_widget.dart';
import 'package:xiaomi_weather_clone/presentation/widgets/now_glow_scroll_widget.dart';
import 'package:xiaomi_weather_clone/presentation/widgets/selectable_list_widget.dart';

@RoutePage()
class SavedWeathersPage extends StatefulWidget {
  static const route = 'saved-weathers';
  const SavedWeathersPage({super.key});

  @override
  State<SavedWeathersPage> createState() => _SavedWeathersPageState();
}

class _SavedWeathersPageState extends State<SavedWeathersPage> {
  late FocusNode focusNode;
  late VoidCallback focusNodeListener;
  late bool selectionMode;
  late BehaviorSubject<List<DataLocationItem>> weathers;
  late StreamSubscription<List<Weather>> weathersSubscription;
  late List<Weather> weathersTemp;

  late final StreamSubscription<DateTime> _updateWeathers;
  late BehaviorSubject<DateTime> _weathersStream;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    selectionMode = false;
    focusNodeListener = () {
      if (focusNode.hasFocus) {
        focusNode.unfocus();
      }
    };
    focusNode.addListener(focusNodeListener);
    weathers = BehaviorSubject<List<DataLocationItem>>();
    weathersTemp = [];
    _weathersStream = BehaviorSubject<DateTime>.seeded(DateTime.now());
    _updateWeathers = updateWeather().listen((dateTime) async {
      final weathers = await sl<WeathersCubit>().getWeathersStream().first;
      if (weathers.isEmpty) return;

      final List<String> ids = [];

      for (final weather in weathers) {
        final nextUpdate = weather.lastUpdated
            .add(const Duration(hours: 1))
            .copyWith(minute: 0, second: 0);
        if (nextUpdate.isBefore(dateTime.copyWith(minute: 0, second: 0))) {
          ids.add(weather.id!);
        }
      }

      if (ids.isNotEmpty) {
        debugPrint('Updated weathers at: $dateTime');

        sl<WeathersCubit>().refreshWeathers(ids);
      }
    });

    weathersSubscription =
        sl<WeathersCubit>().getWeathersStream().listen((weathersList) {
      weathersTemp = weathersList;
      final transformedWeathers = weathersList
          .map((weather) => DataLocationItem(
                index: weathersList.indexOf(weather),
                decoration: Backgrounds.getBackground(weather.current.condition)
                    .copyWith(borderRadius: BorderRadius.circular(14)),
                dataLocation: DataLocation(
                  id: weather.id!,
                  name: weather.location.name,
                  currentTemp: weather.current.temperature,
                  aqi: weather.current.aqi.aqi,
                  minTemp: weather.daily.first.minTemperature,
                  maxTemp: weather.daily.first.maxTemperature,
                ),
              ))
          .toList();
      weathers.add(transformedWeathers);
    });
  }

  @override
  void dispose() {
    weathersSubscription.cancel();
    focusNode.removeListener(focusNodeListener);
    focusNode.dispose();
    _updateWeathers.cancel();
    _weathersStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _bottomNavigationBar(context, weathers),
      body: _body(context),
    );
  }

  NoGlowScroll _body(BuildContext context) {
    return NoGlowScroll(
      child: CustomScrollView(
        slivers: [
          _appBar(context),
          _searchLocation(context),
          _weathersList(),
        ],
      ),
    );
  }

  Widget _weathersList() {
    return StreamBuilder<List<DataLocationItem>>(
      stream: weathers,
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        return SelectableList(
          items: items,
          selectionMode: selectionMode,
          onTap: (index) async {
            if (!selectionMode) {
              final weathers =
                  await sl<WeathersCubit>().getWeathersStream().first;
              sl<WeatherCubit>().saveWeather(
                weathers
                    .firstWhere((e) => e.id == items[index].dataLocation.id),
              );
              context.router.popUntilRouteWithName(WeatherRoute.name);  
            } else {
              final temps = weathers.value;
              temps[index].isSelected = !temps[index].isSelected;
              weathers.add(temps);
            }
          },
          onSelectionMode: (index) {
            setState(() {
              selectionMode = true;
            });
          },
        );
      },
    );
  }

  SliverPersistentHeader _searchLocation(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverAppBarDelegate(
          minHeight: 100.0,
          maxHeight: 100.0,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: TextField(
                      focusNode: focusNode,
                      onTap: () {
                        context.router.pushNamed(SearchPage.route);
                      },
                      style: context.theme.textTheme.titleSmall,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        isDense: true,
                        hintText: context.localizations.introduceLocation,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          )),
    );
  }

  StreamBuilder<List<DataLocationItem>> _appBar(BuildContext context) {
    return StreamBuilder<List<DataLocationItem>>(
        stream: weathers,
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          final count = items.isEmpty
              ? 0
              : items
                  .map((e) => e.isSelected ? 1 : 0)
                  .reduce((value, element) => value + element);
          return !selectionMode
              ? MyCustomAppBar(
                  leading: GestureDetector(
                      child: const Icon(Icons.arrow_back),
                      onTap: () {
                        bool reorganize = false;
                        for (int i = 0; i < weathersTemp.length; i++) {
                          final item = items[i];
                          if (weathersTemp[i].id != item.dataLocation.id) {
                            reorganize = true;
                          }
                        }

                        if (reorganize) {
                          sl<WeathersCubit>().reorganizeWeathers(
                              items.map((e) => e.dataLocation.id).toList());
                        }

                        Navigator.pop(context);
                      }),
                  text: context.localizations.manageCities)
              : MyCustomAppBar(
                  leading: GestureDetector(
                    onTap: () => setState(() {
                      selectionMode = false;
                      final temps = items.map((e) {
                        e.isSelected = false;
                        return e;
                      }).toList();
                      weathers.add(temps);
                    }),
                    child: const Icon(Icons.close),
                  ),
                  trailing: GestureDetector(
                    onTap: () {
                      final List<DataLocationItem> temps;
                      if (items.any((e) => !e.isSelected)) {
                        temps = items.map((e) {
                          e.isSelected = true;
                          return e;
                        }).toList();
                      } else {
                        temps = items.map((e) {
                          e.isSelected = false;
                          return e;
                        }).toList();
                      }
                      weathers.add(temps);
                    },
                    child: const Icon(Icons.checklist_rounded),
                  ),
                  text: count == 0
                      ? context.localizations.selectElements
                      : context.localizations
                          .items_selected(count)
                          .replaceAll('#', count.toString()));
        });
  }

  Widget? _bottomNavigationBar(
      BuildContext context, Stream<List<DataLocationItem>> weathers) {
    return !selectionMode
        ? null
        : StreamBuilder(
            stream: weathers,
            builder: (context, snapshot) {
              return BlocBuilder<WeathersCubit, WeathersState>(
                  bloc: sl<WeathersCubit>(),
                  builder: (context, state) {
                    final items = snapshot.data ?? [];
                    final loading = state.status == WeathersStatus.loading;
                    return SizedBox(
                      height: 75,
                      child: GestureDetector(
                        onTap: loading
                            ? null
                            : () => sl<WeathersCubit>().deleteWeathers(items
                                .where((e) => e.isSelected)
                                .map((e) => e.dataLocation.id)
                                .toList()),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.delete_outline_rounded),
                            Text(context.localizations.delete)
                          ],
                        ),
                      ),
                    );
                  });
            });
  }
}
