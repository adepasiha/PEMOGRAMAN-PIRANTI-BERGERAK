import 'package:flutter/material.dart';

import '../app.dart';
import '../models/air_quality.dart';
import '../models/city.dart';

class CityPicker extends StatelessWidget {
  const CityPicker({required this.city, required this.onChanged, super.key});

  final City city;
  final ValueChanged<City> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<City>(
      key: const ValueKey('city_selector'),
      tooltip: 'Pilih kota',
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final item in City.all)
          PopupMenuItem(
            value: item,
            child: Text('${item.name} · ${item.region}'),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE7ECE9)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on_outlined, size: 16, color: greenColor),
            const SizedBox(width: 4),
            Text(
              city.name,
              style: const TextStyle(
                color: inkColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Icon(Icons.expand_more_rounded, size: 17, color: inkColor),
          ],
        ),
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: inkColor,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(subtitle, style: const TextStyle(color: mutedColor, fontSize: 11)),
      ],
    );
  }
}

class AirQualityHero extends StatelessWidget {
  const AirQualityHero({required this.city, required this.air, super.key});

  final City city;
  final AirQuality air;

  @override
  Widget build(BuildContext context) {
    final aqi = air.usAqi;
    final color = aqi == null
        ? const Color(0xFFD9E2DE)
        : aqi <= 50
        ? const Color(0xFF9BE5BA)
        : aqi <= 100
        ? const Color(0xFFFFD18B)
        : const Color(0xFFFFA18D);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF176D5C), Color(0xFF258D70)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'INDEKS KUALITAS UDARA · US AQI',
            style: TextStyle(
              color: Color(0xFFD0E9E0),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: .75,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  aqi?.toString() ?? '—',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 58,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -2,
                  ),
                ),
              ),
              Icon(Icons.air_rounded, color: color, size: 52),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            air.category,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${city.name} · ${city.region}',
            style: const TextStyle(color: Color(0xFFE2F2EB), fontSize: 11),
          ),
          if (air.time != null) ...[
            const SizedBox(height: 4),
            Text(
              'Waktu data: ${air.time!.toLocal().toString().substring(0, 16)}',
              style: const TextStyle(color: Color(0xFFD0E9E0), fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }
}

class PollutantCard extends StatelessWidget {
  const PollutantCard({
    required this.name,
    required this.description,
    required this.value,
    required this.icon,
    required this.tint,
    required this.iconColor,
    super.key,
  });

  final String name;
  final String description;
  final double? value;
  final IconData icon;
  final Color tint;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEBEFED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 17, color: iconColor),
              ),
              const Spacer(),
              Text(
                name,
                style: const TextStyle(
                  color: inkColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value == null ? '—' : value!.toStringAsFixed(1),
            style: const TextStyle(
              color: inkColor,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: const TextStyle(color: mutedColor, fontSize: 10),
          ),
          const SizedBox(height: 2),
          const Text('µg/m³', style: TextStyle(color: mutedColor, fontSize: 9)),
        ],
      ),
    );
  }
}

class AirQualityChart extends StatelessWidget {
  const AirQualityChart({required this.values, super.key});

  final List<double?> values;

  @override
  Widget build(BuildContext context) {
    final validValues = values.whereType<double>().toList();
    if (validValues.isEmpty) {
      return const Text(
        'Data tren per jam tidak tersedia.',
        style: TextStyle(color: mutedColor, fontSize: 11),
      );
    }
    final maxValue = validValues.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 110,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var index = 0; index < values.length; index++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: values[index] == null || maxValue == 0
                              ? .04
                              : (values[index]! / maxValue).clamp(.04, 1),
                          child: Container(
                            decoration: BoxDecoration(
                              color: index == values.length - 1
                                  ? greenColor
                                  : const Color(0xFFB9DCCE),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      index.toString().padLeft(2, '0'),
                      style: const TextStyle(color: mutedColor, fontSize: 8),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SimulationNote extends StatelessWidget {
  const SimulationNote({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Data diperoleh dari Open-Meteo Air Quality API. Indeks yang ditampilkan '
      'adalah US AQI, bukan ISPU resmi Indonesia. Data dapat berbeda dari '
      'stasiun pemantauan lokal.',
      style: TextStyle(color: mutedColor, fontSize: 10, height: 1.4),
    );
  }
}
