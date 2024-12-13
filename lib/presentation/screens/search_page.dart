import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xiaomi_weather_clone/app/di/service_locator.dart';
import 'package:xiaomi_weather_clone/app/extensions/context_extension.dart';
import 'package:xiaomi_weather_clone/bloc/search/cubit/search_cubit.dart';
import 'package:xiaomi_weather_clone/presentation/widgets/search/search_failed.dart';
import 'package:xiaomi_weather_clone/presentation/widgets/search/search_initial.dart';
import 'package:xiaomi_weather_clone/presentation/widgets/search/search_success.dart';
import 'package:xiaomi_weather_clone/presentation/widgets/search/search_loading.dart';

@RoutePage()
class SearchPage extends StatefulWidget {
  static const route = 'search';
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Timer? _debounce;
  late TextEditingController _controller;
  late String _query;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _query = '';
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  _fetchLocations(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      _query = query;
      sl<SearchCubit>().fetchResults(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Avoid resize when keyboard appears
      body: Padding(
        padding:
            const EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 20),
        child: SafeArea(
          child: Column(
            children: [
              _search(context),
              BlocBuilder(
                bloc: sl<SearchCubit>(),
                builder: (context, SearchState state) {
                  return switch (state.status) {
                    SearchStatus.initial => const SearchInitial(),
                    SearchStatus.loading => const SearchLoading(),
                    SearchStatus.success =>
                      SearchSuccess(query: _query, results: state.results),
                    _ => const SearchFailed(),
                  };
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row _search(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: TextField(
            autofocus: true,
            controller: _controller,
            onChanged: (value) => _fetchLocations(value),
            style: context.theme.textTheme.titleSmall,
            decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.search,
                  size: 14,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    width: 0,
                    style: BorderStyle.none,
                  ),
                )),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        TextButton(
            onPressed: () {
              sl<SearchCubit>().resetState();
              context.router.maybePop();
            },
            child: Text(context.localizations.cancel))
      ],
    );
  }
}
