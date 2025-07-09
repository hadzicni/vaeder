import '../utils/country_names.dart';

class Weather {
  final String cityName;
  final String country;
  final double temperature;
  final String mainCondition;

  Weather({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.mainCondition,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final code = json['sys']['country'] as String;
    final countryName = countryNames[code] ?? code;
    return Weather(
      cityName: json['name'] as String,
      country: countryName,
      temperature: json['main']['temp'].toDouble(),
      mainCondition: json['weather'][0]['main'] as String,
    );
  }}
