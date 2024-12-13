part of 'weathers_cubit.dart';

enum WeathersStatus { initial, loading, success, failure }

extension WeathersStatusX on WeathersStatus {
  bool get isInitial => this == WeathersStatus.initial;
  bool get isLoading => this == WeathersStatus.loading;
  bool get isSuccess => this == WeathersStatus.success;
  bool get isFailure => this == WeathersStatus.failure;
}

@JsonSerializable()
final class WeathersState extends Equatable {
  const WeathersState({
    this.status = WeathersStatus.initial,
  });

  factory WeathersState.fromJson(Map<String, dynamic> json) =>
      _$WeathersStateFromJson(json);

  final WeathersStatus status;

  WeathersState copyWith({
    WeathersStatus? status,
  }) {
    return WeathersState(
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => _$WeathersStateToJson(this);

  @override
  List<Object?> get props => [status];
}
