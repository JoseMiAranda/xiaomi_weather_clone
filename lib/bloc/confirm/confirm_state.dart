part of 'confirm_cubit.dart';

enum ConfirmStatus { initial, loading, success, failure }

extension ConfirmStatusX on ConfirmStatus {
  bool get isInitial => this == ConfirmStatus.initial;
  bool get isLoading => this == ConfirmStatus.loading;
  bool get isSuccess => this == ConfirmStatus.success;
  bool get isFailure => this == ConfirmStatus.failure;
}

@JsonSerializable()
final class ConfirmState extends Equatable {
  const ConfirmState({
    this.status = ConfirmStatus.initial,
    this.temperatureUnits = TemperatureUnits.celsius,
    this.weather,
  });

  factory ConfirmState.fromJson(Map<String, dynamic> json) =>
      _$ConfirmStateFromJson(json);

  final ConfirmStatus status;
  final Weather? weather;
  final TemperatureUnits temperatureUnits;

  ConfirmState copyWith({
    ConfirmStatus? status,
    TemperatureUnits? temperatureUnits,
    Weather? weather,
  }) {
    return ConfirmState(
      status: status ?? this.status,
      temperatureUnits: temperatureUnits ?? this.temperatureUnits,
      weather: weather ?? this.weather,
    );
  }

  Map<String, dynamic> toJson() => _$ConfirmStateToJson(this);

  @override
  List<Object?> get props => [status, temperatureUnits, weather];
}
