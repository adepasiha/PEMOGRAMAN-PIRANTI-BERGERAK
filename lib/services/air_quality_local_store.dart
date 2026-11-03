import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/air_quality.dart';
import '../models/city.dart';

class AirQualityLocalStoreException implements Exception {
  const AirQualityLocalStoreException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CachedAirQuality {
  const CachedAirQuality({
    required this.city,
    required this.airQuality,
    required this.savedAt,
  });

  final City city;
  final AirQuality airQuality;
  final DateTime savedAt;
}

class AirQualityLocalStore {
  static const _lastCityKey = 'last_selected_city';
  static const _snapshotKey = 'last_air_quality_snapshot';

  Future<SharedPreferences> _preferences() async {
    try {
      return await SharedPreferences.getInstance();
    } on PlatformException catch (error) {
      throw AirQualityLocalStoreException(
        'Penyimpanan lokal tidak dapat dibuka: ${error.message ?? error.code}',
      );
    }
  }

  Future<City?> loadLastCity() async {
    final preferences = await _preferences();
    final name = preferences.getString(_lastCityKey);
    if (name == null) return null;

    for (final city in City.all) {
      if (city.name == name) return city;
    }
    final removed = await preferences.remove(_lastCityKey);
    if (!removed) {
      throw const AirQualityLocalStoreException(
        'Pilihan kota tersimpan tidak dikenal dan tidak dapat dihapus.',
      );
    }
    throw const AirQualityLocalStoreException(
      'Pilihan kota tersimpan tidak dikenal dan telah dihapus.',
    );
  }

  Future<void> saveLastCity(City city) async {
    final preferences = await _preferences();
    try {
      final saved = await preferences.setString(_lastCityKey, city.name);
      if (!saved) {
        throw const AirQualityLocalStoreException(
          'Pilihan kota tidak berhasil disimpan di perangkat.',
        );
      }
    } on PlatformException catch (error) {
      throw AirQualityLocalStoreException(
        'Pilihan kota tidak berhasil disimpan: ${error.message ?? error.code}',
      );
    }
  }

  Future<CachedAirQuality?> loadAirQualityForCity(City city) async {
    final preferences = await _preferences();
    final encoded = preferences.getString(_snapshotKey);
    if (encoded == null) return null;

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Format snapshot tidak sesuai.');
      }
      final cityName = decoded['city'];
      final savedAtValue = decoded['saved_at'];
      final airQualityValue = decoded['air_quality'];
      if (cityName is! String ||
          savedAtValue is! String ||
          airQualityValue is! Map<String, dynamic>) {
        throw const FormatException('Data snapshot tidak lengkap.');
      }
      if (cityName != city.name) return null;

      final savedCity = City.all.where((item) => item.name == cityName);
      final savedAt = DateTime.tryParse(savedAtValue);
      if (savedCity.isEmpty || savedAt == null) {
        throw const FormatException('Identitas snapshot tidak valid.');
      }

      return CachedAirQuality(
        city: savedCity.first,
        airQuality: AirQuality.fromJson(airQualityValue),
        savedAt: savedAt,
      );
    } on FormatException catch (error) {
      final bool removed;
      try {
        removed = await preferences.remove(_snapshotKey);
      } on PlatformException catch (removeError) {
        throw AirQualityLocalStoreException(
          'Snapshot lokal rusak dan tidak dapat dihapus: '
          '${removeError.message ?? removeError.code}',
        );
      }
      if (!removed) {
        throw const AirQualityLocalStoreException(
          'Snapshot lokal rusak dan tidak dapat dihapus.',
        );
      }
      throw AirQualityLocalStoreException(
        'Snapshot lokal rusak dan telah dihapus: ${error.message}',
      );
    }
  }

  Future<void> saveAirQuality(City city, AirQuality airQuality) async {
    final preferences = await _preferences();
    final encoded = jsonEncode({
      'city': city.name,
      'saved_at': DateTime.now().toIso8601String(),
      'air_quality': airQuality.toJson(),
    });
    try {
      final saved = await preferences.setString(_snapshotKey, encoded);
      if (!saved) {
        throw const AirQualityLocalStoreException(
          'Data kualitas udara tidak berhasil disimpan di perangkat.',
        );
      }
    } on PlatformException catch (error) {
      throw AirQualityLocalStoreException(
        'Data kualitas udara tidak berhasil disimpan: '
        '${error.message ?? error.code}',
      );
    }
  }
}
