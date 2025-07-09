import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import 'country_service.dart';

class WeatherService {
  static const baseURL = 'https://api.openweathermap.org/data/2.5/weather';
  static const forecastURL =
      'https://api.openweathermap.org/data/2.5/forecast';
  final String apiKey;
  final CountryService _countryService = CountryService();

  WeatherService(this.apiKey);

  Future<Weather> getWeather(String cityName, {String units = 'metric'}) async {
    final response = await http.get(
      Uri.parse(
          '$baseURL?q=${Uri.encodeComponent(cityName)}&appid=$apiKey&units=$units'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final code = data['sys']['country'] as String;
      final countryName = await _countryService.getCountryName(code);
      return Weather.fromJson(data, countryName);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<List<ForecastDay>> getForecast(String cityName,
      {String units = 'metric'}) async {
    final response = await http.get(
      Uri.parse(
          '$forecastURL?q=${Uri.encodeComponent(cityName)}&appid=$apiKey&units=$units'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final List list = data['list'] as List;

      final Map<String, List<dynamic>> grouped = {};
      for (final item in list) {
        final dateTxt = item['dt_txt'] as String;
        final day = dateTxt.split(' ')[0];
        grouped.putIfAbsent(day, () => []).add(item);
      }

      final List<ForecastDay> days = [];
      for (final entry in grouped.entries.take(5)) {
        final items = entry.value;
        Map<String, dynamic> chosen = items.firstWhere(
          (i) => (i['dt_txt'] as String).contains('12:00:00'),
          orElse: () => items[0],
        );
        days.add(
          ForecastDay(
            date: DateTime.parse(entry.key),
            temperature: chosen['main']['temp'].toDouble(),
            mainCondition: chosen['weather'][0]['main'] as String,
          ),
        );
      }
      return days;
    } else {
      throw Exception('Failed to load forecast data');
    }
  }

  Future<String> getCurrentCity() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await GeolocatorPlatform.instance.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    String? city = placemarks.first.locality;
    return city ?? "";
  }
}
