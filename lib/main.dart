import 'package:flutter/material.dart';

import 'pages/weather_page.dart';

void main() {
  runApp(const VaederApp());
}

class VaederApp extends StatelessWidget {
  const VaederApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.light(),
      themeMode: ThemeMode.light,
      home: const WeatherPage(),
    );
  }
}
