import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ren_weather_sample_app/viewmodels/weather_viewmodel.dart';
import 'package:ren_weather_sample_app/views/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WeatherViewModel(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
  }
}
