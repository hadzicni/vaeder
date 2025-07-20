
class Weather {
  final String cityName;
  final String country;
  final double temperature;
  final String mainCondition;
  final DateTime sunrise;
  final DateTime sunset;
  final int timezone;

  Weather({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.mainCondition,
    required this.sunrise,
    required this.sunset,
    required this.timezone,
  });

  bool get isDaytime {
    final nowUtc = DateTime.now().toUtc();
    final localNow = nowUtc.add(Duration(seconds: timezone));
    return localNow.isAfter(sunrise) && localNow.isBefore(sunset);
  }

  factory Weather.fromJson(Map<String, dynamic> json, String countryName) {
    final timezone = json['timezone'] as int;
    final sunriseUtc = DateTime.fromMillisecondsSinceEpoch(
      (json['sys']['sunrise'] as int) * 1000,
      isUtc: true,
    );
    final sunsetUtc = DateTime.fromMillisecondsSinceEpoch(
      (json['sys']['sunset'] as int) * 1000,
      isUtc: true,
    );
    return Weather(
      cityName: json['name'] as String,
      country: countryName,
      temperature: json['main']['temp'].toDouble(),
      mainCondition: json['weather'][0]['main'] as String,
      sunrise: sunriseUtc.add(Duration(seconds: timezone)),
      sunset: sunsetUtc.add(Duration(seconds: timezone)),
      timezone: timezone,
    );
  }
}
