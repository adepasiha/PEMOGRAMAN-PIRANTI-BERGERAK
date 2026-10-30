import 'package:flutter/material.dart';

import '../app.dart';
import '../models/air_quality.dart';
import '../models/city.dart';
import '../services/air_quality_api.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({
    required this.api,
    required this.onSelectCity,
    super.key,
  });

  final AirQualityApi api;
  final ValueChanged<City> onSelectCity;

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  late Future<List<_CityResult>> _results;
  String _selectedIsland = 'Semua';

  List<String> get _islands => [
    'Semua',
    ...City.all.map((city) => city.island).toSet(),
  ];

  @override
  void initState() {
    super.initState();
    _results = _loadResults();
  }

  Future<List<_CityResult>> _loadResults() async {
    final results = <_CityResult>[];
    for (var start = 0; start < City.all.length; start += 4) {
      final batch = City.all.skip(start).take(4);
      results.addAll(
        await Future.wait(
          batch.map((city) async {
            try {
              return _CityResult(city, await widget.api.fetch(city));
            } on AirQualityApiException catch (error) {
              return _CityResult(city, null, error.message);
            }
          }),
        ),
      );
    }
    return results;
  }

  Future<void> _refresh() async {
    final nextResults = _loadResults();
    setState(() => _results = nextResults);
    await nextResults;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        key: const ValueKey('analysis_list'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 26),
        children: [
          const Text(
            'Analisis kota',
            style: TextStyle(
              color: inkColor,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pilih pulau dan ketuk kota untuk melihat pantauannya',
            style: TextStyle(color: mutedColor, fontSize: 12),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 40,
            child: ListView(
              key: const ValueKey('island_filter_list'),
              scrollDirection: Axis.horizontal,
              children: [
                for (final island in _islands)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      key: ValueKey('island_filter_$island'),
                      label: Text(island),
                      selected: _selectedIsland == island,
                      onSelected: (_) {
                        setState(() => _selectedIsland = island);
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<_CityResult>>(
            future: _results,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _AnalysisMessage(
                  message: 'Perbandingan belum dapat dimuat. Tarik layar untuk mencoba lagi.',
                );
              }
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 50),
                  child: Center(
                    child: CircularProgressIndicator(color: greenColor),
                  ),
                );
              }
              final results = [...snapshot.data!]
                ..sort((first, second) {
                  final firstAqi = first.air?.usAqi ?? -1;
                  final secondAqi = second.air?.usAqi ?? -1;
                  return secondAqi.compareTo(firstAqi);
                });
              final filteredResults = _selectedIsland == 'Semua'
                  ? results
                  : results
                        .where(
                          (result) => result.city.island == _selectedIsland,
                        )
                        .toList();
              return Column(
                children: [
                  for (final result in filteredResults)
                    _CityResultCard(
                      result: result,
                      rank: results.indexOf(result) + 1,
                      onTap: () => widget.onSelectCity(result.city),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          const Text(
            'Kategori US AQI',
            style: TextStyle(
              color: inkColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          const _AqiLegend(),
          const SizedBox(height: 15),
          const Text(
            'Indeks pada halaman ini memakai skala US AQI dari Open-Meteo. '
            'Skala tersebut tidak sama dengan ISPU resmi Indonesia.',
            style: TextStyle(color: mutedColor, fontSize: 10, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _CityResult {
  const _CityResult(this.city, this.air, [this.error]);

  final City city;
  final AirQuality? air;
  final String? error;
}

class _CityResultCard extends StatelessWidget {
  const _CityResultCard({
    required this.result,
    required this.rank,
    required this.onTap,
  });

  final _CityResult result;
  final int rank;
  final VoidCallback onTap;

  Color get _color {
    final aqi = result.air?.usAqi;
    if (aqi == null) return mutedColor;
    if (aqi <= 50) return const Color(0xFF18866B);
    if (aqi <= 100) return const Color(0xFFB88416);
    if (aqi <= 150) return const Color(0xFFD78040);
    return const Color(0xFFB84B55);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFEBEFED)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 27,
                  height: 27,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4F2),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: mutedColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.city.name,
                        style: const TextStyle(
                          color: inkColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        result.air?.category ??
                            result.error ??
                            'Tidak tersedia',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: mutedColor, fontSize: 9),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  result.air?.usAqi?.toString() ?? '—',
                  style: TextStyle(
                    color: _color,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: mutedColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AqiLegend extends StatelessWidget {
  const _AqiLegend();

  @override
  Widget build(BuildContext context) {
    const levels = [
      ('0–50', 'Baik', Color(0xFF18866B)),
      ('51–100', 'Sedang', Color(0xFFB88416)),
      ('101–150', 'Tidak sehat bagi kelompok sensitif', Color(0xFFD78040)),
      ('151–200', 'Tidak sehat', Color(0xFFB84B55)),
      ('201–300', 'Sangat tidak sehat', Color(0xFF9B4555)),
      ('>300', 'Berbahaya', Color(0xFF7C3A78)),
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFEBEFED)),
      ),
      child: Column(
        children: [
          for (var index = 0; index < levels.length; index++) ...[
            if (index > 0) const Divider(height: 15),
            Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: levels[index].$3,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    levels[index].$2,
                    style: const TextStyle(
                      color: inkColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  levels[index].$1,
                  style: const TextStyle(color: mutedColor, fontSize: 9),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AnalysisMessage extends StatelessWidget {
  const _AnalysisMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: mutedColor, fontSize: 12),
      ),
    );
  }
}
