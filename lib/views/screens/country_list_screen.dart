import 'package:flutter/material.dart';

import '../../models/city_model.dart';

class CountryListScreen extends StatefulWidget {
  const CountryListScreen(
      {required this.activeCityList, required this.cityList, super.key});
  final List<City> cityList;
  final List<City> activeCityList;

  @override
  State<CountryListScreen> createState() => _CountryListScreenState();
}

class _CountryListScreenState extends State<CountryListScreen> {
  late List<City> selectedCity;

  @override
  void initState() {
    super.initState();
    // Initialize the selectedCountries with the activeCountryList
    selectedCity = List.from(widget.activeCityList);
  }

  void _onCountrySelected(bool? selected, City city) {
    setState(() {
      if (selected == true) {
        selectedCity.add(city);
      } else {
        selectedCity.remove(city);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Countries'),
      ),
      body: ListView.builder(
        itemCount: widget.cityList.length,
        itemBuilder: (context, index) {
          final city = widget.cityList[index];
          final isSelected = selectedCity.contains(city);

          return ListTile(
            title: Text(city.cityName),
            trailing: Checkbox(
              value: isSelected,
              onChanged: (bool? selected) {
                _onCountrySelected(selected, city);
              },
            ),
            onTap: () {
              _onCountrySelected(!isSelected, city);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
         Navigator.of(context).pop(selectedCity);
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
