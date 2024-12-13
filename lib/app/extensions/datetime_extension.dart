import 'package:flutter/material.dart';
import 'package:xiaomi_weather_clone/app/extensions/context_extension.dart';

enum DateTimeFormat { yyyyMMdd, ddMM, hhmm }

extension DateTimeExtension on DateTime {
  String toFormat(DateTimeFormat format, {separator = '-'}) {
    return switch (format) {
      DateTimeFormat.yyyyMMdd =>
        '${year.toString().padLeft(4, '0')}$separator${month.toString().padLeft(2, '0')}$separator${day.toString().padLeft(2, '0')}',
      DateTimeFormat.ddMM =>
        '${day.toString().padLeft(2, '0')}$separator${month.toString().padLeft(2, '0')}',
      DateTimeFormat.hhmm =>
        '${hour.toString().padLeft(2, '0')}$separator${minute.toString().padLeft(2, '0')}',
      _ => () {
          final toString = this.toString();
          late String oldSeparator;
          for (int i = 0; i < toString.length; i++) {
            if (int.tryParse(toString[i]) == null) {
              oldSeparator = toString[i];
              break;
            }
          }
          return toString.replaceAll(oldSeparator, separator);
        }(),
    };
  }

  String nameOfDayWeek(BuildContext context, {bool today = false}) {
    return switch (weekday) {
      DateTime.monday => _getNameOfDayWeek(
          context, context.localizations.monday.substring(0, 3)),
      DateTime.tuesday => _getNameOfDayWeek(
          context, context.localizations.tuesday.substring(0, 3)),
      DateTime.wednesday => _getNameOfDayWeek(
          context, context.localizations.wednesday.substring(0, 3)),
      DateTime.thursday => _getNameOfDayWeek(
          context, context.localizations.thursday.substring(0, 3)),
      DateTime.friday => _getNameOfDayWeek(
          context, context.localizations.friday.substring(0, 3)),
      DateTime.saturday => _getNameOfDayWeek(
          context, context.localizations.saturday.substring(0, 3)),
      _ => _getNameOfDayWeek(
          context, context.localizations.sunday.substring(0, 3)),
    };
  }

  String _getNameOfDayWeek(BuildContext context, String defaultName) {
    if (isToday()) return context.localizations.today;
    if (isTomorrow()) return context.localizations.tomorrow;
    return defaultName;
  }

  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool isTomorrow() {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }
}
