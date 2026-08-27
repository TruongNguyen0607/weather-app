import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

import '../models/weather_models.dart';
import '../services/weather_service.dart';
import 'city_search_screen.dart';

class CountriesScreen extends StatefulWidget {
  const CountriesScreen({
    super.key,
    required this.weatherService,
    required this.onLocationSelected,
  });

  final WeatherService weatherService;
  final ValueChanged<WeatherLocation> onLocationSelected;

  @override
  State<CountriesScreen> createState() => _CountriesScreenState();
}

class _CountriesScreenState extends State<CountriesScreen> {
  final TextEditingController _controller = TextEditingController();
  late final List<Country> _countries;
  late List<Country> _filtered;

  @override
  void initState() {
    super.initState();
    _countries = CountryService().getAll()
      ..sort((a, b) => a.name.compareTo(b.name));
    _filtered = _countries;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _filter(String query) {
    final normalized = query.trim().toLowerCase();
    setState(() {
      _filtered = normalized.isEmpty
          ? _countries
          : _countries.where((country) {
              return country.name.toLowerCase().contains(normalized) ||
                  country.countryCode.toLowerCase().contains(normalized);
            }).toList();
    });
  }

  void _openCountry(Country country) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => CitySearchScreen(
          weatherService: widget.weatherService,
          countryCode: country.countryCode,
          countryName: country.name,
          embedded: false,
          onSelected: widget.onLocationSelected,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Explore countries',
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose a country, then search any city inside it.',
                  style: TextStyle(color: Colors.blueGrey.shade600),
                ),
                const SizedBox(height: 18),
                SearchBar(
                  controller: _controller,
                  hintText: 'Search countries',
                  leading: const Icon(Icons.public_rounded),
                  onChanged: _filter,
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.35,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final country = _filtered[index];
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _openCountry(country),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: <Widget>[
                          Text(
                            country.flagEmoji,
                            style: const TextStyle(fontSize: 27),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              country.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
