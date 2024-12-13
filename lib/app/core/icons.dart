// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:weather_repository/weather_repository.dart';


class FlagsIcon {
  static const assetName = 'assets/icons/Даниил/';

  static Widget getIcon(String countryCode) {
    return SvgPicture.asset(
      '$assetName$countryCode.svg',
      height: 25,
    );
  }
}

class WindDirectionIcon {
  static const assetName = 'assets/icons/samodeh97/';

  static Widget getIcon(int direction) {
    if ((direction >= 337.5 && direction < 360) ||
        (direction >= 0 && direction < 22.5)) {
      return WindDirectionIcon.right;
    } else if (direction >= 22.5 && direction < 67.5) {
      return WindDirectionIcon.topright;
    } else if (direction >= 67.5 && direction < 112.5) {
      return WindDirectionIcon.top;
    } else if (direction >= 112.5 && direction < 157.5) {
      return WindDirectionIcon.topLeft;
    } else if (direction >= 157.5 && direction < 202.5) {
      return WindDirectionIcon.left;
    } else if (direction >= 202.5 && direction < 247.5) {
      return WindDirectionIcon.bottomLeft;
    } else if (direction >= 247.5 && direction < 292.5) {
      return WindDirectionIcon.bottom;
    } else {
      return WindDirectionIcon.bottomRight;
    }
  }

  static Widget right = SvgPicture.asset(
    '${assetName}right.svg',
    height: 20,
    color: Colors.grey,
  );

  static Widget topright = SvgPicture.asset(
    '${assetName}top-right.svg',
    height: 20,
    color: Colors.grey,
  );

  static Widget top = SvgPicture.asset(
    '${assetName}top.svg',
    height: 20,
    color: Colors.grey,
  );

  static Widget topLeft = SvgPicture.asset(
    '${assetName}top-left.svg',
    height: 20,
    color: Colors.grey,
  );

  static Widget left = SvgPicture.asset(
    '${assetName}left.svg',
    height: 20,
    color: Colors.grey,
  );
  
  static Widget bottomLeft = SvgPicture.asset(
    '${assetName}bottom-left.svg',
    height: 20,
    color: Colors.grey,
  );

  static Widget bottom = SvgPicture.asset(
    '${assetName}bottom.svg',
    height: 20,
    color: Colors.grey,
  );

  static Widget bottomRight = SvgPicture.asset(
    '${assetName}bottom-right.svg',
    height: 20,
    color: Colors.grey,
  );

}

class WeatherIcon {
  static const assetName = 'assets/icons/carlos_yllobre/';

  static Widget getIcon(WeatherCondition condition, bool isNight) {
    return switch (condition) {
      WeatherCondition.clear => WeatherIcon.clear(isNight),
      WeatherCondition.cloudy => WeatherIcon.cloudy(isNight),
      WeatherCondition.rainy => WeatherIcon.rainny,
      WeatherCondition.snowy => WeatherIcon.snowy,
      _ => WeatherIcon.unkwon,
    };
  }

  static Widget clear(bool isNight) => SvgPicture.asset(
    '$assetName${!isNight ? '' : 'nt_' }clear.svg',
    height: 30,
  );
  static Widget cloudy(bool isNight) => SvgPicture.asset(
    '$assetName${!isNight ? '' : 'nt_' }cloudy.svg',
    height: 30,
  );
  static Widget rainny = SvgPicture.asset(
    '${assetName}rainny.svg',
    height: 30,
  );
  static Widget snowy = SvgPicture.asset(
    '${assetName}snowy.svg',
    height: 30,
  );

  static Widget unkwon = const Icon(
    Icons.question_mark_rounded,
    color: Colors.red,
    size: 30,
  );
}
