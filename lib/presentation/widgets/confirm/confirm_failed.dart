import 'package:flutter/material.dart';
import 'package:xiaomi_weather_clone/app/extensions/context_extension.dart';

class ConfirmFailed extends StatelessWidget {
  const ConfirmFailed({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(context.localizations.somethingWentWrong),
    );
  }
}