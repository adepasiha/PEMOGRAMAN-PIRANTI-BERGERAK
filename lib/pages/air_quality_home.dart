import 'package:flutter/material.dart';

import '../app.dart';
import '../models/air_quality.dart';
import '../models/city.dart';
import '../services/air_quality_api.dart';
import '../widgets/air_quality_widgets.dart';
import 'analysis_page.dart';
import 'about_page.dart';

class AirQualityHome extends StatefulWidget {
  const AirQualityHome({this.api, super.key});

  final AirQualityApi? api;

  @override
  State<AirQualityHome> createState() => _AirQualityHomeState();
}

class _AirQualityHomeState extends State<AirQualityHome> {
  late final AirQualityApi _api = widget.api ?? AirQualityApi();
  City _city = City.all.first;
  AirQuality? _air;
  String? _error;
  bool _isLoading = true;
  int _selectedTab = 0;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _loadAirQuality();
  }

  @override
  void dispose() {
    if (widget.api == null) _api.close();
    super.dispose();
  }

  Future<void> _loadAirQuality({bool showLoading = true}) async {
    final requestId = ++_requestId;
    if (showLoading && mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final air = await _api.fetch(_city);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _air = air;
        _error = null;
        _isLoading = false;
      });
    } on AirQualityApiException catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _error = error.message;
        _isLoading = false;
      });
    }
  }

  void _selectCity(City city) {
    if (city == _city) return;
    setState(() {
      _city = city;
      _air = null;
    });
    _loadAirQuality();
  }

  void _openCityFromAnalysis(City city) {
    _selectCity(city);
    setState(() => _selectedTab = 0);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _selectedTab == 0
          ? _DashboardPage(
              city: _city,
              air: _air,
              isLoading: _isLoading,
              error: _error,
              onRetry: _loadAirQuality,
            )
          : const SizedBox.shrink(),
      _selectedTab == 1
          ? AnalysisPage(api: _api, onSelectCity: _openCityFromAnalysis)
          : const SizedBox.shrink(),
      _selectedTab == 2 ? const AboutPage() : const SizedBox.shrink(),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 14, 10),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2F1EC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.air_rounded,
                      color: greenColor,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 11),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'UdaraKita',
                          style: TextStyle(
                            color: inkColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'KUALITAS UDARA INDONESIA',
                          style: TextStyle(
                            color: mutedColor,
                            fontSize: 9,
                            letterSpacing: 1.15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CityPicker(city: _city, onChanged: _selectCity),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(index: _selectedTab, children: pages),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) {
          setState(() => _selectedTab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard_rounded),
            label: 'Ringkasan',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Analisis',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline_rounded),
            selectedIcon: Icon(Icons.info_rounded),
            label: 'Tentang',
          ),
        ],
      ),
    );
  }
}

class _DashboardPage extends StatelessWidget {
  const _DashboardPage({
    required this.city,
    required this.air,
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  final City city;
  final AirQuality? air;
  final bool isLoading;
  final String? error;
  final Future<void> Function({bool showLoading}) onRetry;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => onRetry(showLoading: false),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 26),
        children: [
          const Text(
            'Pantauan kualitas udara',
            style: TextStyle(
              color: inkColor,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${city.region} · Data terbaru dari layanan API',
            style: const TextStyle(color: mutedColor, fontSize: 12),
          ),
          const SizedBox(height: 17),
          if (isLoading && air == null)
            const _LoadingCard()
          else if (error != null && air == null)
            _ErrorCard(message: error!, onRetry: onRetry)
          else if (air != null) ...[
            AirQualityHero(city: city, air: air!),
            const SizedBox(height: 19),
            const SectionHeading(
              title: 'Konsentrasi polutan',
              subtitle: 'Nilai saat ini · mikrogram per meter kubik',
            ),
            const SizedBox(height: 11),
            Row(
              children: [
                Expanded(
                  child: PollutantCard(
                    name: 'PM2.5',
                    description: 'Partikel halus',
                    value: air!.pm25,
                    icon: Icons.blur_on_rounded,
                    tint: const Color(0xFFEAF2FF),
                    iconColor: const Color(0xFF5077B9),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PollutantCard(
                    name: 'PM10',
                    description: 'Partikel kasar',
                    value: air!.pm10,
                    icon: Icons.grain_rounded,
                    tint: const Color(0xFFFFF1E7),
                    iconColor: const Color(0xFFD78040),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: PollutantCard(
                    name: 'NO₂',
                    description: 'Nitrogen dioksida',
                    value: air!.nitrogenDioxide,
                    icon: Icons.local_fire_department_outlined,
                    tint: const Color(0xFFFFEBEB),
                    iconColor: const Color(0xFFD56A6A),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PollutantCard(
                    name: 'O₃',
                    description: 'Ozon permukaan',
                    value: air!.ozone,
                    icon: Icons.wb_sunny_outlined,
                    tint: const Color(0xFFFFF7D9),
                    iconColor: const Color(0xFFB48A21),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _TrendCard(values: air!.hourlyAqi),
            const SizedBox(height: 18),
            _HealthTip(aqi: air!.usAqi),
            const SizedBox(height: 13),
            const SimulationNote(),
          ] else
            const _LoadingCard(),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          CircularProgressIndicator(color: greenColor),
          SizedBox(height: 14),
          Text(
            'Mengambil data kualitas udara...',
            style: TextStyle(color: mutedColor, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function({bool showLoading}) onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0D6D1)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: Color(0xFFB84B55),
            size: 34,
          ),
          const SizedBox(height: 10),
          const Text(
            'Data belum dapat dimuat',
            style: TextStyle(
              color: inkColor,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: mutedColor,
              fontSize: 11,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () => onRetry(),
            icon: const Icon(Icons.refresh_rounded, size: 17),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.values});

  final List<double?> values;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBEFED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            title: 'Tren indeks hari ini',
            subtitle: 'US AQI per jam · nilai prakiraan API',
          ),
          const SizedBox(height: 16),
          AirQualityChart(values: values),
        ],
      ),
    );
  }
}

class _HealthTip extends StatelessWidget {
  const _HealthTip({required this.aqi});

  final int? aqi;

  @override
  Widget build(BuildContext context) {
    final value = aqi;
    final message = value == null
        ? 'Ikuti informasi dari instansi kesehatan dan lingkungan setempat.'
        : value > 100
        ? 'Batasi aktivitas berat di luar ruangan. Kelompok sensitif sebaiknya lebih berhati-hati.'
        : value > 50
        ? 'Kelompok sensitif dapat mempertimbangkan mengurangi aktivitas berat di luar ruangan.'
        : 'Kondisi relatif baik untuk aktivitas luar ruangan. Tetap perhatikan kondisi tubuh.';
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF4E8CC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.health_and_safety_outlined,
            color: Color(0xFFB88416),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saran kesehatan',
                  style: TextStyle(
                    color: inkColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF716244),
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
