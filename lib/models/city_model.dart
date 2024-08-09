class City {
  final String city;
  final String lat;
  final String lng;

  City({required this.city, required this.lat, required this.lng});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      city: json['city'],
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}