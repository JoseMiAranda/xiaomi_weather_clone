// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_weather.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveWeatherAdapter extends TypeAdapter<HiveWeather> {
  @override
  final int typeId = 2;

  @override
  HiveWeather read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveWeather(
      id: fields[0] as String,
      lastUpdated: fields[1] as DateTime,
      location: fields[2] as HiveLocation,
      current: fields[3] as HiveCurrent,
      dailyForecast: (fields[4] as List).cast<HiveDailyForecast>(),
    );
  }

  @override
  void write(BinaryWriter writer, HiveWeather obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.lastUpdated)
      ..writeByte(2)
      ..write(obj.location)
      ..writeByte(3)
      ..write(obj.current)
      ..writeByte(4)
      ..write(obj.dailyForecast);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveWeatherAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveHourlyForecastAdapter extends TypeAdapter<HiveHourlyForecast> {
  @override
  final int typeId = 3;

  @override
  HiveHourlyForecast read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveHourlyForecast(
      time: fields[0] as DateTime,
      condition: fields[1] as HiveWeatherCondition,
      temperature: fields[2] as double,
      windSpeed: fields[3] as double,
      windDirection: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, HiveHourlyForecast obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.time)
      ..writeByte(1)
      ..write(obj.condition)
      ..writeByte(2)
      ..write(obj.temperature)
      ..writeByte(3)
      ..write(obj.windSpeed)
      ..writeByte(4)
      ..write(obj.windDirection);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveHourlyForecastAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveDailyForecastAdapter extends TypeAdapter<HiveDailyForecast> {
  @override
  final int typeId = 4;

  @override
  HiveDailyForecast read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveDailyForecast(
      time: fields[0] as DateTime,
      hourly: (fields[1] as List).cast<HiveHourlyForecast>(),
      maxTemperature: fields[2] as double,
      minTemperature: fields[3] as double,
      windSpeed: fields[4] as double,
      windDirection: fields[5] as int,
      precipitationProbability: fields[6] as int,
      maxSeaPressure: fields[8] as double,
      uvIndex: fields[7] as int,
      sunrise: fields[9] as DateTime,
      sunset: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HiveDailyForecast obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.time)
      ..writeByte(1)
      ..write(obj.hourly)
      ..writeByte(2)
      ..write(obj.maxTemperature)
      ..writeByte(3)
      ..write(obj.minTemperature)
      ..writeByte(4)
      ..write(obj.windSpeed)
      ..writeByte(5)
      ..write(obj.windDirection)
      ..writeByte(6)
      ..write(obj.precipitationProbability)
      ..writeByte(7)
      ..write(obj.uvIndex)
      ..writeByte(8)
      ..write(obj.maxSeaPressure)
      ..writeByte(9)
      ..write(obj.sunrise)
      ..writeByte(10)
      ..write(obj.sunset);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveDailyForecastAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveCurrentAdapter extends TypeAdapter<HiveCurrent> {
  @override
  final int typeId = 5;

  @override
  HiveCurrent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveCurrent(
      temperature: fields[0] as double,
      condition: fields[1] as HiveWeatherCondition,
      aqi: fields[2] as HiveAqi,
      humidity: fields[3] as int,
      feelsLikeTemperature: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, HiveCurrent obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.temperature)
      ..writeByte(1)
      ..write(obj.condition)
      ..writeByte(2)
      ..write(obj.aqi)
      ..writeByte(3)
      ..write(obj.humidity)
      ..writeByte(4)
      ..write(obj.feelsLikeTemperature);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveCurrentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveWeatherConditionAdapter extends TypeAdapter<HiveWeatherCondition> {
  @override
  final int typeId = 1;

  @override
  HiveWeatherCondition read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HiveWeatherCondition.clear;
      case 1:
        return HiveWeatherCondition.rainy;
      case 2:
        return HiveWeatherCondition.cloudy;
      case 3:
        return HiveWeatherCondition.snowy;
      case 4:
        return HiveWeatherCondition.unknown;
      default:
        return HiveWeatherCondition.clear;
    }
  }

  @override
  void write(BinaryWriter writer, HiveWeatherCondition obj) {
    switch (obj) {
      case HiveWeatherCondition.clear:
        writer.writeByte(0);
        break;
      case HiveWeatherCondition.rainy:
        writer.writeByte(1);
        break;
      case HiveWeatherCondition.cloudy:
        writer.writeByte(2);
        break;
      case HiveWeatherCondition.snowy:
        writer.writeByte(3);
        break;
      case HiveWeatherCondition.unknown:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveWeatherConditionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
