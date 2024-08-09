import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/weather_model.dart';

class ApiService {
  final String _weatherUrl = 'https://api.openweathermap.org/data/2.5/weather';
  final String apiKey = '58e552f09d3307e36fa70ebc8c8bd1f2';

  Future<Weather> fetchWeather(String lat, String lon) async {
    try {
      final response = await http.get(Uri.parse(
          '$_weatherUrl?lat=$lat&lon=$lon&appid=$apiKey&units=metric'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return Weather.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load weather');
      }
    } catch (e) {
      print('Error fetching weather: $e');
      rethrow;
    }
  }
}
