import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../utils/weather_utils.dart';

class WeatherAnimation extends StatelessWidget {
  final String? condition;
  final String? iconCode;

  const WeatherAnimation({super.key, required this.condition, required this.iconCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Lottie.asset(
        getWeatherAnimation(condition, iconCode: iconCode),
        width: 180,
        height: 180,
      ),
    );
  }
}
