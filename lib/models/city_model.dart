class City {
  final String cityName;
  final String lat;
  final String lng;

  City({required this.cityName, required this.lat, required this.lng});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      cityName: json['city'],
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}