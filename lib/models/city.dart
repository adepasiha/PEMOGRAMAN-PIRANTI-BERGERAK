class City {
  const City({
    required this.name,
    required this.region,
    required this.island,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String region;
  final String island;
  final double latitude;
  final double longitude;

  static const all = [
    City(
      name: 'Jakarta',
      region: 'DKI Jakarta',
      island: 'Jawa',
      latitude: -6.2088,
      longitude: 106.8456,
    ),
    City(
      name: 'Banda Aceh',
      region: 'Aceh',
      island: 'Sumatra',
      latitude: 5.5483,
      longitude: 95.3238,
    ),
    City(
      name: 'Bandung',
      region: 'Jawa Barat',
      island: 'Jawa',
      latitude: -6.9175,
      longitude: 107.6191,
    ),
    City(
      name: 'Medan',
      region: 'Sumatera Utara',
      island: 'Sumatra',
      latitude: 3.5952,
      longitude: 98.6722,
    ),
    City(
      name: 'Palembang',
      region: 'Sumatera Selatan',
      island: 'Sumatra',
      latitude: -2.9761,
      longitude: 104.7754,
    ),
    City(
      name: 'Pekanbaru',
      region: 'Riau',
      island: 'Sumatra',
      latitude: 0.5071,
      longitude: 101.4478,
    ),
    City(
      name: 'Padang',
      region: 'Sumatera Barat',
      island: 'Sumatra',
      latitude: -0.9471,
      longitude: 100.4172,
    ),
    City(
      name: 'Bandar Lampung',
      region: 'Lampung',
      island: 'Sumatra',
      latitude: -5.3971,
      longitude: 105.2668,
    ),
    City(
      name: 'Semarang',
      region: 'Jawa Tengah',
      island: 'Jawa',
      latitude: -6.9667,
      longitude: 110.4167,
    ),
    City(
      name: 'Denpasar',
      region: 'Bali',
      island: 'Bali & Nusa Tenggara',
      latitude: -8.65,
      longitude: 115.2167,
    ),
    City(
      name: 'Yogyakarta',
      region: 'DI Yogyakarta',
      island: 'Jawa',
      latitude: -7.7956,
      longitude: 110.3695,
    ),
    City(
      name: 'Surabaya',
      region: 'Jawa Timur',
      island: 'Jawa',
      latitude: -7.2575,
      longitude: 112.7521,
    ),
    City(
      name: 'Mataram',
      region: 'Nusa Tenggara Barat',
      island: 'Bali & Nusa Tenggara',
      latitude: -8.5833,
      longitude: 116.1167,
    ),
    City(
      name: 'Kupang',
      region: 'Nusa Tenggara Timur',
      island: 'Bali & Nusa Tenggara',
      latitude: -10.1772,
      longitude: 123.607,
    ),
    City(
      name: 'Pontianak',
      region: 'Kalimantan Barat',
      island: 'Kalimantan',
      latitude: -0.0263,
      longitude: 109.3425,
    ),
    City(
      name: 'Palangka Raya',
      region: 'Kalimantan Tengah',
      island: 'Kalimantan',
      latitude: -2.2096,
      longitude: 113.9213,
    ),
    City(
      name: 'Banjarmasin',
      region: 'Kalimantan Selatan',
      island: 'Kalimantan',
      latitude: -3.3186,
      longitude: 114.5944,
    ),
    City(
      name: 'Samarinda',
      region: 'Kalimantan Timur',
      island: 'Kalimantan',
      latitude: -0.5022,
      longitude: 117.1536,
    ),
    City(
      name: 'Makassar',
      region: 'Sulawesi Selatan',
      island: 'Sulawesi',
      latitude: -5.1477,
      longitude: 119.4327,
    ),
    City(
      name: 'Manado',
      region: 'Sulawesi Utara',
      island: 'Sulawesi',
      latitude: 1.4748,
      longitude: 124.8421,
    ),
    City(
      name: 'Palu',
      region: 'Sulawesi Tengah',
      island: 'Sulawesi',
      latitude: -0.9003,
      longitude: 119.8779,
    ),
    City(
      name: 'Jayapura',
      region: 'Papua',
      island: 'Papua',
      latitude: -2.5337,
      longitude: 140.7181,
    ),
    City(
      name: 'Sorong',
      region: 'Papua Barat Daya',
      island: 'Papua',
      latitude: -0.8762,
      longitude: 131.2558,
    ),
  ];
}
