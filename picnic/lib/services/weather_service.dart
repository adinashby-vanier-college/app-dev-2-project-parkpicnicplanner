import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherService {
  
  static const String _apiKey = '057a5186de1454fbb9f8d3d19680d4cf';
  static const String _base = 'https://api.openweathermap.org/data/2.5/weather';

  static Future<Weather?> getCurrentWeather(double lat, double lon) async {
    try {
      final uri = Uri.parse(_base).replace(queryParameters: {
        'lat': '$lat',
        'lon': '$lon',
        'appid': _apiKey,
        'units': 'metric',
      });

      final resp = await http.get(uri).timeout(const Duration(seconds: 12));
      if (resp.statusCode != 200) {
        // ignore: avoid_print
        print('OpenWeather HTTP ${resp.statusCode}: ${resp.body}');
        return null;
      }
      final data = json.decode(resp.body) as Map<String, dynamic>;
      return Weather.fromJson(data);
    } catch (e) {
      // ignore: avoid_print
      print('Weather fetch error: $e');
      return null;
    }
  }
}
