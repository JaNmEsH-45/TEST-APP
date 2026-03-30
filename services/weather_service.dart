import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  final String apiKey = '643787a5fe554b30ade153721261003'; // Replace with your WeatherAPI key
  final String baseUrl = 'http://api.weatherapi.com/v1/current.json';

  Future<Weather> fetchWeather(String city) async {
    final url = '$baseUrl?key=$apiKey&q=$city&aqi=no';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Weather.fromJson(data);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<Weather> fetchWeatherByCoords(double lat, double lon) async {
    final url = '$baseUrl?key=$apiKey&q=$lat,$lon&aqi=no';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Weather.fromJson(data);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}