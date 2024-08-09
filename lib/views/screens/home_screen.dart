import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/weather_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<WeatherViewModel>(builder: (context, viewModel, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          color: Colors.blueAccent.withOpacity(0.3),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              viewModel.loading
                  ? const CircularProgressIndicator()
                  : CarouselSlider(
                      items: List.generate(viewModel.cityWeatherList.length,
                          (index) {
                        return Container(
                          width: 220,
                          margin: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: viewModel.getTemperatureColor(viewModel
                                  .cityWeatherList[index]
                                  .weather
                                  ?.temperature)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                viewModel.cityWeatherList[index].city.city,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              if (viewModel.cityWeatherList[index].weather !=
                                  null) ...[
                                Image.network(viewModel.getWeatherIconUrl(
                                  viewModel
                                      .cityWeatherList[index].weather!.icon,
                                )),
                                Text(
                                  '${viewModel.cityWeatherList[index].weather?.temperature ?? '_ _'} °C',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 32),
                                ),
                                Text(
                                  viewModel.cityWeatherList[index].weather!
                                      .description,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                              ]
                            ],
                          ),
                        );
                      }),
                      options: CarouselOptions(
                        height: 300,
                        initialPage: 1,
                        enableInfiniteScroll: false,
                        enlargeCenterPage: true,
                        enlargeFactor: 0.2,
                        aspectRatio: 16 / 9,
                        viewportFraction: 0.6,
                        onPageChanged: (index, reason) {},
                      ),
                    ),
              InkWell(
                onTap: () => viewModel.getCurrentLocationWeather(),
                child: Container(
                  height: 68,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(16)),
                  child: const Center(
                    child: Text(
                      'get current location weather',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              )
            ],
          )),
        );
      }),
    );
  }
}
