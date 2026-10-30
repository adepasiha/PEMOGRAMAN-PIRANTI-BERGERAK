import 'package:flutter/material.dart';

import 'pages/air_quality_home.dart';
import 'services/air_quality_api.dart';

const inkColor = Color(0xFF18312F);
const mutedColor = Color(0xFF71817D);
const canvasColor = Color(0xFFF4F7F5);
const greenColor = Color(0xFF18866B);

class AirQualityApp extends StatelessWidget {
  const AirQualityApp({super.key, this.api});

  final AirQualityApi? api;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UdaraKita Indonesia',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: canvasColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: greenColor,
          surface: Colors.white,
        ),
      ),
      home: AirQualityHome(api: api),
    );
  }
}
