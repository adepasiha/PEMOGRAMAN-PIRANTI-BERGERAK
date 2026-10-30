import 'package:flutter/material.dart';

import '../app.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 26),
      children: [
        const Text(
          'Tentang studi kasus',
          style: TextStyle(
            color: inkColor,
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Kualitas udara perkotaan Indonesia',
          style: TextStyle(color: mutedColor, fontSize: 12),
        ),
        const SizedBox(height: 18),
        const _InfoCard(
          icon: Icons.track_changes_rounded,
          title: 'Tujuan',
          body:
              'Mengenali kondisi kualitas udara, membandingkan beberapa kota, '
              'dan memahami informasi polutan melalui aplikasi berbasis API.',
        ),
        const SizedBox(height: 10),
        const _InfoCard(
          icon: Icons.science_outlined,
          title: 'Parameter',
          body:
              'PM2.5 dan PM10 adalah partikel di udara. NO₂ (nitrogen dioksida) '
              'dan O₃ (ozon) merupakan gas yang ikut dipantau. Konsentrasi '
              'ditampilkan dalam µg/m³.',
        ),
        const SizedBox(height: 10),
        const _InfoCard(
          icon: Icons.public_rounded,
          title: 'Sumber data',
          body:
              'Data diambil langsung dari Open-Meteo Air Quality API '
              '(air-quality-api.open-meteo.com). API menyediakan estimasi '
              'berdasarkan koordinat kota, bukan pembacaan sensor lokal.',
        ),
        const SizedBox(height: 10),
        const _InfoCard(
          icon: Icons.menu_book_rounded,
          title: 'Tentang indeks',
          body:
              'Aplikasi ini memakai US AQI yang disediakan API. Kategorinya: '
              'Baik (0–50), Sedang (51–100), tidak sehat bagi kelompok sensitif '
              '(101–150), Tidak sehat (151–200), Sangat tidak sehat (201–300), '
              'dan Berbahaya (di atas 300). US AQI bukan ISPU resmi Indonesia.',
        ),
        const SizedBox(height: 10),
        const _InfoCard(
          icon: Icons.warning_amber_rounded,
          title: 'Catatan',
          body:
              'Data dapat berubah dan memiliki keterbatasan resolusi. Aplikasi '
              'ini merupakan prototype pembelajaran, bukan alat diagnosis atau '
              'pengganti informasi resmi kesehatan dan lingkungan.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Sumber: Open-Meteo Air Quality API · Lisensi data CC BY 4.0',
          style: TextStyle(color: mutedColor, fontSize: 10),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFEBEFED)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F2ED),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 19, color: greenColor),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: inkColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: const TextStyle(
                    color: mutedColor,
                    fontSize: 11,
                    height: 1.5,
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
