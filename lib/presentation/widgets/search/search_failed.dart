import 'package:flutter/material.dart';
import 'package:xiaomi_weather_clone/app/extensions/context_extension.dart';

class SearchFailed extends StatelessWidget {
  const SearchFailed({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Center(child: Text(context.localizations.searchFailed)));
  }
}
