import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/air_quality.dart';
import '../models/city.dart';

class AirQualityApiException implements Exception {
  const AirQualityApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AirQualityApi {
  AirQualityApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<AirQuality> fetch(City city) async {
    final uri = Uri.https('air-quality-api.open-meteo.com', '/v1/air-quality', {
      'latitude': '${city.latitude}',
      'longitude': '${city.longitude}',
      'current': 'pm2_5,pm10,nitrogen_dioxide,ozone,us_aqi',
      'hourly': 'us_aqi',
      'timezone': 'auto',
      'forecast_days': '1',
    });

    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw AirQualityApiException(
          'Server kualitas udara mengembalikan kode ${response.statusCode}.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Format data dari server tidak sesuai.');
      }
      return AirQuality.fromJson(decoded);
    } on TimeoutException {
      throw const AirQualityApiException(
        'Permintaan terlalu lama. Periksa koneksi internet lalu coba lagi.',
      );
    } on SocketException {
      throw const AirQualityApiException(
        'Tidak dapat terhubung ke internet. Periksa koneksi lalu coba lagi.',
      );
    } on http.ClientException {
      throw const AirQualityApiException(
        'Koneksi ke layanan kualitas udara gagal. Silakan coba lagi.',
      );
    } on FormatException {
      throw const AirQualityApiException(
        'Data dari layanan kualitas udara tidak dapat dibaca.',
      );
    }
  }

  void close() {
    _client.close();
  }
}
