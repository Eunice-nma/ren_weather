import 'city_model.dart';
import 'weather_model.dart';

class CityWeather {
  final City city;
  Weather? weather;

  CityWeather({
    required this.city,
    this.weather,
  });
}
