class AirQuality {
  const AirQuality({
    required this.time,
    required this.usAqi,
    required this.pm25,
    required this.pm10,
    required this.nitrogenDioxide,
    required this.ozone,
    required this.hourlyAqi,
  });

  final DateTime? time;
  final int? usAqi;
  final double? pm25;
  final double? pm10;
  final double? nitrogenDioxide;
  final double? ozone;
  final List<double?> hourlyAqi;

  String get category {
    final value = usAqi;
    if (value == null) return 'Tidak tersedia';
    if (value <= 50) return 'Baik';
    if (value <= 100) return 'Sedang';
    if (value <= 150) return 'Tidak sehat bagi kelompok sensitif';
    if (value <= 200) return 'Tidak sehat';
    if (value <= 300) return 'Sangat tidak sehat';
    return 'Berbahaya';
  }

  factory AirQuality.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    if (current is! Map<String, dynamic>) {
      throw const FormatException('Data kualitas udara tidak ditemukan.');
    }

    final hourly = json['hourly'];
    final hourlyValues = hourly is Map<String, dynamic>
        ? hourly['us_aqi']
        : null;

    return AirQuality(
      time: current['time'] is String
          ? DateTime.tryParse(current['time'] as String)
          : null,
      usAqi: _toInt(current['us_aqi']),
      pm25: _toDouble(current['pm2_5']),
      pm10: _toDouble(current['pm10']),
      nitrogenDioxide: _toDouble(current['nitrogen_dioxide']),
      ozone: _toDouble(current['ozone']),
      hourlyAqi: hourlyValues is List
          ? hourlyValues.map(_toDouble).toList(growable: false)
          : const [],
    );
  }

  static int? _toInt(Object? value) => value is num ? value.round() : null;

  static double? _toDouble(Object? value) =>
      value is num ? value.toDouble() : null;
}
