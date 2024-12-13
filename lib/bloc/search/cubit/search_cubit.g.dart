// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchState _$SearchStateFromJson(Map<String, dynamic> json) => SearchState(
      status: $enumDecodeNullable(_$SearchStatusEnumMap, json['status']) ??
          SearchStatus.initial,
      results: json['results'] == null
          ? null
          : SearchResults.fromJson(json['results'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SearchStateToJson(SearchState instance) =>
    <String, dynamic>{
      'status': _$SearchStatusEnumMap[instance.status]!,
      'results': instance.results,
    };

const _$SearchStatusEnumMap = {
  SearchStatus.initial: 'initial',
  SearchStatus.loading: 'loading',
  SearchStatus.success: 'success',
  SearchStatus.failure: 'failure',
};
