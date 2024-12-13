// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weathers_cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeathersState _$WeathersStateFromJson(Map<String, dynamic> json) =>
    WeathersState(
      status: $enumDecodeNullable(_$WeathersStatusEnumMap, json['status']) ??
          WeathersStatus.initial,
    );

Map<String, dynamic> _$WeathersStateToJson(WeathersState instance) =>
    <String, dynamic>{
      'status': _$WeathersStatusEnumMap[instance.status]!,
    };

const _$WeathersStatusEnumMap = {
  WeathersStatus.initial: 'initial',
  WeathersStatus.loading: 'loading',
  WeathersStatus.success: 'success',
  WeathersStatus.failure: 'failure',
};
