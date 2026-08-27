import 'package:shared_preferences/shared_preferences.dart';

import '../models/weather_models.dart';

class FavoritesService {
  static const String _key = 'favorite_weather_locations';
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  Future<List<WeatherLocation>> load() async {
    final values = await _preferences.getStringList(_key) ?? <String>[];
    final locations = <WeatherLocation>[];
    for (final value in values) {
      try {
        locations.add(WeatherLocation.decode(value));
      } on Object {
        // Ignore a malformed saved item while preserving all valid favorites.
      }
    }
    return locations;
  }

  Future<void> save(List<WeatherLocation> locations) {
    return _preferences.setStringList(
      _key,
      locations.map((location) => location.encode()).toList(),
    );
  }
}
