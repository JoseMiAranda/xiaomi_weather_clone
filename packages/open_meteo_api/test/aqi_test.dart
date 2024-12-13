import 'package:flutter_test/flutter_test.dart';
import 'package:open_meteo_api/src/models/response_aqi.dart';

void main() {
  group('Aqi', () {
    group('fromJson', () {
      test('returns correct Aqi object', () {
        expect(
            ResponseAqi.fromJson(
              <String, dynamic>{
                'time': '2024-12-03T12:00',
                'interval': 3600,
                'european_aqi': 26,
                'pm10': 9.9,
                'pm2_5': 8.7,
                'carbon_monoxide': 216,
                'nitrogen_dioxide': 19.8,
                'sulphur_dioxide': 1.5,
                'ozone': 36
              },
            ),
            isA<ResponseAqi>()
                .having((a) => a.europeanAqi, 'european_aqi', 26)
                .having((a) => a.pm10, 'pm10', 9.9)
                .having((a) => a.pm25, 'pm2_5', 8.7)
                .having((a) => a.carbonMonoxide, 'carbon_monoxide', 216)
                .having((a) => a.nitrogenDioxide, 'nitrogen_dioxide', 19.8)
                .having((a) => a.sulphurDioxide, 'sulphur_dioxide', 1.5)
                .having((a) => a.ozone, 'ozone', 36));
      });
    });
  });
}
