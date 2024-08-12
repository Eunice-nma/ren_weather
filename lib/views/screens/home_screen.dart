import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ren_weather_sample_app/views/screens/country_list_screen.dart';

import '../../models/city_model.dart';
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
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () {
                      editCountrySelection(viewModel);
                    },
                    child: const Text(
                      'Edit City',
                      style: TextStyle(
                        color: Colors.purple,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                if (viewModel.cityWeatherList.isNotEmpty &&
                    viewModel.cityWeatherList[0].weather != null)
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.purple[800],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${viewModel.cityWeatherList[0].weather?.temperature ?? '- -'} °C',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 40),
                            ),
                            const Spacer(),
                            Image.network(viewModel.getWeatherIconUrl(
                              viewModel.cityWeatherList[0].weather!.icon,
                            )),
                          ],
                        ),
                        Text(
                          '${viewModel.cityWeatherList[0].weather?.description} in ${viewModel.cityWeatherList[0].city.cityName}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                CarouselSlider(
                  items: [
                    ...List.generate(viewModel.cityWeatherList.length, (index) {
                      return Container(
                        width: 220,
                        margin: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: viewModel.getTemperatureColor(viewModel
                              .cityWeatherList[index].weather?.temperature),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              viewModel.cityWeatherList[index].city.cityName,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 20),
                            ),
                            Text(
                              '${viewModel.cityWeatherList[index].weather?.temperature ?? '- -'} °C',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 32),
                            ),
                            if (viewModel.cityWeatherList[index].weather !=
                                null) ...[
                              Image.network(viewModel.getWeatherIconUrl(
                                viewModel.cityWeatherList[index].weather!.icon,
                              )),
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
                    GestureDetector(
                      onTap: () {
                        editCountrySelection(viewModel);
                      },
                      child: Container(
                        width: 90,
                        margin: const EdgeInsets.all(5.0),
                        padding: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.purple[800]),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 38,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                        color: Colors.purple[800],
                        borderRadius: BorderRadius.circular(16)),
                    child: Center(
                      child: viewModel.loading
                          ? const Center(
                              child: CircularProgressIndicator(
                              color: Colors.white,
                            ))
                          : const Text(
                              'Get current location weather',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void editCountrySelection(WeatherViewModel model) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => CountryListScreen(
          cityList: model.cities,
          activeCityList: model.cityWeatherList
              .map((cityWeather) => cityWeather.city)
              .toList(),
        ),
      ),
    )
        .then((updatedActiveCities) {
      if (updatedActiveCities != null && updatedActiveCities is List<City>) {
        model.updateActiveCities(updatedActiveCities);
      }
    });
  }
}
