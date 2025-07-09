import 'package:flutter/material.dart';

String getWeatherAnimation(String? mainCondition) {
  if (mainCondition == null) return 'assets/sunny.json';
  switch (mainCondition.toLowerCase()) {
    case 'clouds':
      return 'assets/cloud.json';
    case 'mist':
    case 'smoke':
    case 'haze':
    case 'dust':
    case 'fog':
      return 'assets/cloud.json';
    case 'rain':
    case 'drizzle':
    case 'shower rain':
      return 'assets/rain.json';
    case 'thunderstorm':
      return 'assets/thunder.json';
    case 'clear':
      return 'assets/sunny.json';
    default:
      return 'assets/sunny.json';
  }
}

List<Color> getWeatherGradient(String? mainCondition) {
  if (mainCondition == null) {
    return [const Color(0xFF4A90E2), const Color(0xFF7BB3F0)];
  }
  switch (mainCondition.toLowerCase()) {
    case 'clouds':
    case 'mist':
    case 'smoke':
    case 'haze':
    case 'dust':
    case 'fog':
      return [const Color(0xFF6B7280), const Color(0xFF9CA3AF)];
    case 'rain':
    case 'drizzle':
    case 'shower rain':
      return [const Color(0xFF374151), const Color(0xFF6B7280)];
    case 'thunderstorm':
      return [const Color(0xFF1F2937), const Color(0xFF374151)];
    case 'clear':
      return [const Color(0xFF4A90E2), const Color(0xFF7BB3F0)];
    default:
      return [const Color(0xFF4A90E2), const Color(0xFF7BB3F0)];
  }
}
