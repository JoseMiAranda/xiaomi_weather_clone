import 'package:json_annotation/json_annotation.dart';

part 'response_aqi.g.dart';

@JsonSerializable()
class ResponseAqi {
  ResponseAqi({
    required this.europeanAqi,
    required this.pm10,
    required this.pm25,
    required this.carbonMonoxide,
    required this.nitrogenDioxide,
    required this.sulphurDioxide,
    required this.ozone,
  });

  factory ResponseAqi.fromJson(Map<String, dynamic> json) =>
      _$ResponseAqiFromJson(json);

  @JsonKey(name: 'european_aqi')
  int europeanAqi;
  double pm10;
  @JsonKey(name: 'pm2_5')
  double pm25;
  @JsonKey(name: 'carbon_monoxide')
  double carbonMonoxide;
  @JsonKey(name: 'nitrogen_dioxide')
  double nitrogenDioxide;
  @JsonKey(name: 'sulphur_dioxide')
  double sulphurDioxide;
  double ozone;
}
