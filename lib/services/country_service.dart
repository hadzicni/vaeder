import 'dart:convert';

import 'package:http/http.dart' as http;

class CountryService {
  Future<String> getCountryName(String code) async {
    final response = await http
        .get(Uri.parse('https://restcountries.com/v3.1/alpha/${Uri.encodeComponent(code)}'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List && data.isNotEmpty) {
        return data[0]['name']['common'] as String;
      }
    }
    return code;
  }
}
