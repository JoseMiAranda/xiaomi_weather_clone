// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_aqi.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveAqiAdapter extends TypeAdapter<HiveAqi> {
  @override
  final int typeId = 7;

  @override
  HiveAqi read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveAqi(
      aqi: fields[0] as int,
      condition: fields[1] as HiveAqiCondition,
      pm10: fields[2] as double,
      pm25: fields[3] as double,
      carbonMonoxide: fields[4] as double,
      nitrogenDioxide: fields[5] as double,
      sulphurDioxide: fields[6] as double,
      ozone: fields[7] as double,
    );
  }

  @override
  void write(BinaryWriter writer, HiveAqi obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.aqi)
      ..writeByte(1)
      ..write(obj.condition)
      ..writeByte(2)
      ..write(obj.pm10)
      ..writeByte(3)
      ..write(obj.pm25)
      ..writeByte(4)
      ..write(obj.carbonMonoxide)
      ..writeByte(5)
      ..write(obj.nitrogenDioxide)
      ..writeByte(6)
      ..write(obj.sulphurDioxide)
      ..writeByte(7)
      ..write(obj.ozone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveAqiAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveAqiConditionAdapter extends TypeAdapter<HiveAqiCondition> {
  @override
  final int typeId = 6;

  @override
  HiveAqiCondition read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HiveAqiCondition.good;
      case 1:
        return HiveAqiCondition.fair;
      case 2:
        return HiveAqiCondition.moderate;
      case 3:
        return HiveAqiCondition.poor;
      case 4:
        return HiveAqiCondition.veryPoor;
      case 5:
        return HiveAqiCondition.extremelyPoor;
      case 6:
        return HiveAqiCondition.unknown;
      default:
        return HiveAqiCondition.good;
    }
  }

  @override
  void write(BinaryWriter writer, HiveAqiCondition obj) {
    switch (obj) {
      case HiveAqiCondition.good:
        writer.writeByte(0);
        break;
      case HiveAqiCondition.fair:
        writer.writeByte(1);
        break;
      case HiveAqiCondition.moderate:
        writer.writeByte(2);
        break;
      case HiveAqiCondition.poor:
        writer.writeByte(3);
        break;
      case HiveAqiCondition.veryPoor:
        writer.writeByte(4);
        break;
      case HiveAqiCondition.extremelyPoor:
        writer.writeByte(5);
        break;
      case HiveAqiCondition.unknown:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveAqiConditionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
