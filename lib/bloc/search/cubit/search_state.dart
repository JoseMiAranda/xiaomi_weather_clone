part of 'search_cubit.dart';

enum SearchStatus { initial, loading, success, failure }

extension LocationStatusX on SearchStatus {
  bool get isInitial => this == SearchStatus.initial;
  bool get isLoading => this == SearchStatus.loading;
  bool get isSuccess => this == SearchStatus.success;
  bool get isFailure => this == SearchStatus.failure;
}

@JsonSerializable()
final class SearchState extends Equatable {
  SearchState({
    this.status = SearchStatus.initial,
    SearchResults? results,
  }) : results = results ?? SearchResults.empty();

  factory SearchState.fromJson(Map<String, dynamic> json) =>
      _$SearchStateFromJson(json);

  final SearchStatus status;
  final SearchResults results;

  SearchState copyWith({
    SearchStatus? status,
    SearchResults? results,
  }) {
    return SearchState(
      status: status ?? this.status,
      results: results ?? this.results,
    );
  }

  Map<String, dynamic> toJson() => _$SearchStateToJson(this);

  @override
  List<Object?> get props => [status, results];
}
