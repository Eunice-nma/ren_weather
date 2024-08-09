// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/api_service.dart';
import '../models/city_weather_model.dart';
import '../models/weather_model.dart';
import '../models/city_model.dart';

class WeatherViewModel with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<City> _cities = [];
  List<CityWeather> _cityWeatherList = [];
  List<CityWeather> get cityWeatherList => _cityWeatherList;

  List<City> get cities => _cities;

  final _defaultDisplayCitiesString = ['lagos', 'abuja', 'ibadan'];
  bool loading = false;

  SharedPreferences? _sharedPreferences;

  WeatherViewModel() {
    init();
  }

  void init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    await _loadCities();
    _getDisplayCities();
    notifyListeners();
  }

  Future<void> _loadCities() async {
    final String response = await rootBundle.loadString('assets/cities.json');
    final List<dynamic> data = json.decode(response) as List<dynamic>;
    _cities = data.take(15).map((cityJson) => City.fromJson(cityJson)).toList();
  }

  void _getDisplayCities() async {
    final List<String> savedCityNames =
        _sharedPreferences?.getStringList('activeCityList') ??
            _defaultDisplayCitiesString;

    _cityWeatherList = _cities
        .where((city) => savedCityNames.contains(city.cityName.toLowerCase()))
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

    final Color coldColor = Colors.purple[900]!;
    final Color hotColor = Colors.purple[100]!;

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
    // try {
    //   PermissionStatus status = await Permission.camera.request();
      // if (status.isGranted) {
        final City currentyCity = await getCurrentLocation();
        final getcurrentCityWeather =
            await getWeather(currentyCity.lat, currentyCity.lng);
        CityWeather currentCityWeather = CityWeather(city: currentyCity);

        if (getcurrentCityWeather != null) {
          currentCityWeather.weather = getcurrentCityWeather;
        }
        cityWeatherList.insert(0, currentCityWeather);
    //   }
    // } catch (e) {
    //   print("An error occurred while getting the current location: $e");
    // }
  }

  Future<City> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    String cityName = placemarks.first.locality ?? "Unknown City";
    City currentLocation = City(
        cityName: cityName,
        lat: position.latitude.toString(),
        lng: position.longitude.toString());

    return currentLocation;
  }

  void updateActiveCities(List<City> updatedCities) async {
    _cityWeatherList =
        updatedCities.map((city) => CityWeather(city: city)).toList();

    final prefs = await SharedPreferences.getInstance();
    List<String> cityNames =
        updatedCities.map((city) => city.cityName.toLowerCase()).toList();
    await prefs.setStringList('activeCityList', cityNames);
    _loadDefaultWeatherData(); // Fetch the weather data for the updated list
  }
}
