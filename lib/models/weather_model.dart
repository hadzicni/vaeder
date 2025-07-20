
class Weather {
  final String cityName;
  final String country;
  final double temperature;
  final String mainCondition;
  final String iconCode;

  Weather({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.mainCondition,
    required this.iconCode,
  });

  factory Weather.fromJson(Map<String, dynamic> json, String countryName) {
    return Weather(
      cityName: json['name'] as String,
      country: countryName,
      temperature: json['main']['temp'].toDouble(),
      mainCondition: json['weather'][0]['main'] as String,
      iconCode: json['weather'][0]['icon'] as String,
    );
  }
}
