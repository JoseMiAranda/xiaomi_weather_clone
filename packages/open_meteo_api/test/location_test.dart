import 'package:flutter_test/flutter_test.dart';
import 'package:open_meteo_api/open_meteo_api.dart';

void main() {
  group('Location', () {
    group('fromJson', () {
      test('returns correct Location object', () {
        expect(
          ResponseLocation.fromJson(
            <String, dynamic>{
              'id': 2514256,
              'name': 'Málaga',
              'country': 'Spain',
              'latitude': 36.72016,
              'longitude': -4.42034
            },
          ),
          isA<ResponseLocation>()
              .having((w) => w.id, 'id', 2514256)
              .having((w) => w.name, 'name', 'Málaga')
              .having((w) => w.country, 'country', 'Spain')
              .having((w) => w.latitude, 'latitude', 36.72016)
              .having((w) => w.longitude, 'longitude', -4.42034),
        );
      });
    });
  });
}
