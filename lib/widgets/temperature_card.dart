import 'package:flutter/material.dart';

class TemperatureCard extends StatelessWidget {
  final double temperature;
  final String unitSymbol;

  const TemperatureCard({
    super.key,
    required this.temperature,
    required this.unitSymbol,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20),
        ],
      ),
      child: Column(
        children: [
          Text(
            '${temperature.round()}°$unitSymbol',
            style: const TextStyle(
              fontSize: 76,
              fontWeight: FontWeight.w200,
              color: Colors.white,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
