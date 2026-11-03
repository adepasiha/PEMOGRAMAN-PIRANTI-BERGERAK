import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/app.dart';
import 'package:flutter_application_1/models/air_quality.dart';
import 'package:flutter_application_1/models/city.dart';
import 'package:flutter_application_1/services/air_quality_api.dart';
import 'package:flutter_application_1/services/air_quality_local_store.dart';

http.Response _airQualityResponse() {
  return http.Response(
    jsonEncode({
      'current': {
        'time': '2026-10-30T12:00',
        'us_aqi': 64,
        'pm2_5': 17.8,
        'pm10': 28.1,
        'nitrogen_dioxide': 8.6,
        'ozone': 32.4,
      },
      'hourly': {
        'us_aqi': [52, 55, 61, 64],
      },
    }),
    200,
  );
}

void main() {
  test(
    'local store persists the last city and its air quality snapshot',
    () async {
      SharedPreferences.setMockInitialValues({});
      final store = AirQualityLocalStore();
      final city = City.all[9];
      const air = AirQuality(
        time: null,
        usAqi: 64,
        pm25: 17.8,
        pm10: 28.1,
        nitrogenDioxide: 8.6,
        ozone: 32.4,
        hourlyAqi: [52, 55, 61, 64],
      );

      await store.saveLastCity(city);
      await store.saveAirQuality(city, air);

      expect((await store.loadLastCity())?.name, city.name);
      final cached = await store.loadAirQualityForCity(city);
      expect(cached?.airQuality.usAqi, 64);
      expect(cached?.airQuality.pm25, 17.8);
      expect(cached?.savedAt, isNotNull);
      expect(await store.loadAirQualityForCity(City.all.first), isNull);
    },
  );

  test('city list covers all major island groups', () {
    final islands = City.all.map((city) => city.island).toSet();

    expect(
      islands,
      containsAll([
        'Sumatra',
        'Jawa',
        'Bali & Nusa Tenggara',
        'Kalimantan',
        'Sulawesi',
        'Papua',
      ]),
    );
    expect(
      City.all.where((city) => city.island == 'Kalimantan').length,
      greaterThanOrEqualTo(4),
    );
  });

  test('API requests Open-Meteo air quality for the chosen city', () async {
    final client = MockClient((request) async {
      expect(request.url.host, 'air-quality-api.open-meteo.com');
      expect(request.url.path, '/v1/air-quality');
      expect(request.url.queryParameters['latitude'], '-6.2088');
      expect(
        request.url.queryParameters['current'],
        'pm2_5,pm10,nitrogen_dioxide,ozone,us_aqi',
      );
      return _airQualityResponse();
    });
    final api = AirQualityApi(client: client);

    final result = await api.fetch(City.all.first);

    expect(result.usAqi, 64);
    expect(result.pm25, 17.8);
    expect(result.category, 'Sedang');
    expect(result.hourlyAqi, [52, 55, 61, 64]);
    api.close();
  });

  test('API reports a readable error when the server fails', () async {
    final api = AirQualityApi(
      client: MockClient((_) async => http.Response('Unavailable', 503)),
    );

    await expectLater(
      api.fetch(City.all.first),
      throwsA(
        isA<AirQualityApiException>().having(
          (error) => error.message,
          'message',
          contains('503'),
        ),
      ),
    );
    api.close();
  });

  testWidgets('dashboard displays real API data for the selected city', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final api = AirQualityApi(
      client: MockClient((_) async => _airQualityResponse()),
    );

    await tester.pumpWidget(AirQualityApp(api: api));
    await tester.pumpAndSettle();

    expect(find.text('UdaraKita'), findsOneWidget);
    expect(find.text('Pantauan kualitas udara'), findsOneWidget);
    expect(find.textContaining('US AQI'), findsOneWidget);
    expect(find.text('64'), findsOneWidget);
    expect(find.text('17.8'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Peta lokasi'),
      250,
      scrollable: find
          .descendant(
            of: find.byType(RefreshIndicator),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Jakarta · 64 AQI'), findsOneWidget);
  });

  testWidgets('city selector reloads data from the API', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final requestedCities = <String>[];
    final api = AirQualityApi(
      client: MockClient((request) async {
        requestedCities.add(request.url.queryParameters['latitude']!);
        return _airQualityResponse();
      }),
    );

    await tester.pumpWidget(AirQualityApp(api: api));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('city_selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Denpasar · Bali'));
    await tester.pumpAndSettle();

    expect(requestedCities, contains('-8.65'));
    expect(find.text('Denpasar · Bali'), findsOneWidget);
    expect(
      await SharedPreferences.getInstance().then(
        (preferences) => preferences.getString('last_selected_city'),
      ),
      'Denpasar',
    );
    expect(
      (await AirQualityLocalStore().loadAirQualityForCity(City.all[9]))
          ?.airQuality
          .usAqi,
      64,
    );
  });

  testWidgets('cached air quality stays visible when API refresh fails', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = AirQualityLocalStore();
    final city = City.all[9];
    const air = AirQuality(
      time: null,
      usAqi: 64,
      pm25: 17.8,
      pm10: 28.1,
      nitrogenDioxide: 8.6,
      ozone: 32.4,
      hourlyAqi: [52, 55, 61, 64],
    );
    await store.saveLastCity(city);
    await store.saveAirQuality(city, air);
    final api = AirQualityApi(
      client: MockClient((_) async => http.Response('Unavailable', 503)),
    );

    await tester.pumpWidget(AirQualityApp(api: api));
    await tester.pumpAndSettle();

    expect(find.text('Denpasar · Bali'), findsOneWidget);
    expect(find.text('64'), findsOneWidget);
    expect(find.textContaining('Pembaruan data gagal'), findsOneWidget);
  });

  testWidgets('island filter and city cards open the selected city', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final requestedLatitudes = <String>[];
    final api = AirQualityApi(
      client: MockClient((request) async {
        requestedLatitudes.add(request.url.queryParameters['latitude']!);
        return _airQualityResponse();
      }),
    );

    await tester.pumpWidget(AirQualityApp(api: api));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Analisis'));
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const ValueKey('island_filter_list')),
      const Offset(-700, 0),
    );
    await tester.pumpAndSettle();
    final kalimantanFilter = find.byKey(
      const ValueKey('island_filter_Kalimantan'),
    );
    await tester.tap(kalimantanFilter);
    await tester.pumpAndSettle();
    expect(find.text('Pontianak'), findsOneWidget);
    expect(find.text('Samarinda'), findsOneWidget);

    final samarinda = find.text('Samarinda');
    final analysisScrollable = find.descendant(
      of: find.byKey(const ValueKey('analysis_list')),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
    );
    await tester.scrollUntilVisible(
      samarinda,
      300,
      scrollable: analysisScrollable,
    );
    await tester.tap(samarinda);
    await tester.pumpAndSettle();

    expect(find.text('Pantauan kualitas udara'), findsOneWidget);
    expect(find.text('Samarinda'), findsOneWidget);
    expect(requestedLatitudes, contains('-0.5022'));
  });
}
