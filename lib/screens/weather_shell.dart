import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/weather_models.dart';
import '../services/favorites_service.dart';
import '../services/weather_service.dart';
import 'city_search_screen.dart';
import 'countries_screen.dart';
import 'favorites_screen.dart';
import 'forecast_screen.dart';

class WeatherShell extends StatefulWidget {
  const WeatherShell({
    super.key,
    this.autoLocate = true,
    this.enablePersistence = true,
    this.weatherService,
    this.favoritesService,
  });

  final bool autoLocate;
  final bool enablePersistence;
  final WeatherService? weatherService;
  final FavoritesService? favoritesService;

  @override
  State<WeatherShell> createState() => _WeatherShellState();
}

class _WeatherShellState extends State<WeatherShell> {
  late final WeatherService _weatherService;
  FavoritesService? _favoritesService;
  int _selectedIndex = 0;
  WeatherLocation? _location;
  WeatherForecast? _forecast;
  List<WeatherLocation> _favorites = <WeatherLocation>[];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _weatherService = widget.weatherService ?? WeatherService();
    if (widget.enablePersistence) {
      _favoritesService = widget.favoritesService ?? FavoritesService();
      _loadFavorites();
    }
    if (widget.autoLocate) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _useCurrentLocation(),
      );
    }
  }

  @override
  void dispose() {
    if (widget.weatherService == null) _weatherService.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await _favoritesService?.load() ?? <WeatherLocation>[];
      if (mounted) setState(() => _favorites = favorites);
    } on Object {
      // The rest of the app stays usable if local preferences are unavailable.
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _selectedIndex = 0;
      _loading = true;
      _error = null;
    });
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const LocationMessage(
          'Location services are off. Turn them on, then try again.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw const LocationMessage(
          'Location permission was not granted. You can still search any city.',
        );
      }
      if (permission == LocationPermission.deniedForever) {
        throw const LocationMessage(
          'Location permission is blocked. Enable it in your phone settings.',
        );
      }

      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 15),
          ),
        );
      } on TimeoutException {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown == null) {
          throw const LocationMessage(
            'No GPS position is available. On an emulator, open Extended '
            'controls > Location and set a map location, then try again.',
          );
        }
        position = lastKnown;
      }
      final location = WeatherLocation(
        name: 'My location',
        latitude: position.latitude,
        longitude: position.longitude,
        isCurrentLocation: true,
      );
      await _selectLocation(location);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _selectLocation(WeatherLocation location) async {
    setState(() {
      _selectedIndex = 0;
      _location = location;
      _loading = true;
      _error = null;
    });
    try {
      final forecast = await _weatherService.getForecast(location);
      if (!mounted || _location?.id != location.id) return;
      setState(() {
        _forecast = forecast;
        _loading = false;
      });
    } on Object catch (error) {
      if (!mounted || _location?.id != location.id) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _refresh() async {
    if (_location != null) await _selectLocation(_location!);
  }

  bool get _isFavorite =>
      _location != null && _favorites.any((item) => item.id == _location!.id);

  Future<void> _toggleFavorite() async {
    final location = _location;
    if (location == null) return;
    setState(() {
      if (_isFavorite) {
        _favorites.removeWhere((item) => item.id == location.id);
      } else {
        _favorites.add(location);
      }
    });
    await _favoritesService?.save(_favorites);
  }

  Future<void> _removeFavorite(WeatherLocation location) async {
    setState(() => _favorites.removeWhere((item) => item.id == location.id));
    await _favoritesService?.save(_favorites);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      ForecastScreen(
        location: _location,
        forecast: _forecast,
        loading: _loading,
        error: _error,
        isFavorite: _isFavorite,
        onRefresh: _refresh,
        onUseLocation: _useCurrentLocation,
        onToggleFavorite: _toggleFavorite,
      ),
      CitySearchScreen(
        weatherService: _weatherService,
        onSelected: _selectLocation,
        onUseCurrentLocation: _useCurrentLocation,
      ),
      CountriesScreen(
        weatherService: _weatherService,
        onLocationSelected: _selectLocation,
      ),
      FavoritesScreen(
        favorites: _favorites,
        onSelected: _selectLocation,
        onRemoved: _removeFavorite,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.cloud_outlined),
            selectedIcon: Icon(Icons.cloud_rounded),
            label: 'Weather',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.public_outlined),
            selectedIcon: Icon(Icons.public_rounded),
            label: 'Countries',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}

class LocationMessage implements Exception {
  const LocationMessage(this.message);

  final String message;

  @override
  String toString() => message;
}
