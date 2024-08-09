// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/services/api_service.dart';
import '../models/city_weather_model.dart';
import '../models/weather_model.dart';
import '../models/city_model.dart';

class WeatherViewModel with ChangeNotifier {
  final ApiService _apiService = ApiService();
  Weather? _weather;
  List<City> _cities = [];
  List<City> _displayCities = [];
  List<CityWeather> _cityWeatherList = [];
  List<CityWeather> get cityWeatherList => _cityWeatherList;
  // List<Weather> _weatherDataList = [];

  Weather? get weather => _weather;
  List<City> get cities => _cities;
  List<City> get displayCities => _displayCities;
  // List<Weather> get weatherDataList => _weatherDataList;
  final _defaultDisplayCitiesString = ['lagos', 'abuja', 'ibadan'];
  bool loading = false;

  WeatherViewModel() {
    _loadCities();
  }

  Future<void> _loadCities() async {
    // Load the JSON file from assets
    final String response = await rootBundle.loadString('assets/cities.json');
    final List<dynamic> data = json.decode(response) as List<dynamic>;

    // Convert only the first 15 maps to City objects
    _cities = data.take(15).map((cityJson) => City.fromJson(cityJson)).toList();
    _getDisplayCities();
    notifyListeners();
  }

  void _getDisplayCities() {
    // todo: use shaed prefrence to get [defaultDisplayCitiesString]
    _cityWeatherList = _cities
        .where((city) =>
            _defaultDisplayCitiesString.contains(city.city.toLowerCase()))
        .map((city) => CityWeather(city: city))
        .toList();
    _loadDefaultWeatherData();
  }

  Future<void> _loadDefaultWeatherData() async {
    for (CityWeather cityWeather in _cityWeatherList) {
      final Weather? weatherData =
          await getWeather(cityWeather.city.lat, cityWeather.city.lng);
      if (weatherData != null) {
        cityWeather.weather = weatherData;
      }
    }
    notifyListeners();
  }

  Future<Weather?> getWeather(String lat, String lon) async {
    setLoader(true);
    try {
      final weather = await _apiService.fetchWeather(lat, lon);
      return weather;
    } catch (e) {
      print(e);
      return null;
    } finally {
      setLoader(false);
    }
  }

  Color getTemperatureColor(double? temperature) {
    const double minTemp = 10.0;
    const double maxTemp = 50.0;
    const double defaultTemp = 25.0;
    final temp = temperature ?? defaultTemp;

    double normalizedTemp = (temp - minTemp) / (maxTemp - minTemp);
    normalizedTemp = normalizedTemp.clamp(0.0, 1.0);

    final Color coldColor = Colors.blue[900]!;
    final Color hotColor = Colors.blueAccent[100]!;

    return Color.lerp(coldColor, hotColor, normalizedTemp)!;
  }

  void setLoader(bool value) {
    loading = value;
    notifyListeners();
  }

  String getWeatherIconUrl(String code) {
    return 'http://openweathermap.org/img/wn/$code@2x.png';
  }

  void getCurrentLocationWeather() async {
    // setLoader(true);
    try {
      PermissionStatus status = await Permission.camera.request();
      if (status.isGranted) {
        final City currentyCity = await getCurrentLocation();
        final getcurrentCityWeather =
            await getWeather(currentyCity.lat, currentyCity.lng);
        CityWeather currentCityWeather = CityWeather(city: currentyCity);

        if (getcurrentCityWeather != null) {
          currentCityWeather.weather = getcurrentCityWeather;
        }
        cityWeatherList.insert(1, currentCityWeather);
      }
    } catch (e) {
      print("An error occurred while getting the current location: $e");
    }
    // setLoader(false);
  }

  Future<City> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    String cityName = placemarks.first.locality ?? "Unknown City";
    City currentLocation = City(
        city: cityName,
        lat: position.latitude.toString(),
        lng: position.longitude.toString());

    return currentLocation;
  }
}
