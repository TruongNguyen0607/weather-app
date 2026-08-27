import 'dart:async';

import 'package:flutter/material.dart';

import '../models/weather_models.dart';
import '../services/weather_service.dart';

class CitySearchScreen extends StatefulWidget {
  const CitySearchScreen({
    super.key,
    required this.weatherService,
    required this.onSelected,
    this.onUseCurrentLocation,
    this.countryCode,
    this.countryName,
    this.embedded = true,
  });

  final WeatherService weatherService;
  final ValueChanged<WeatherLocation> onSelected;
  final VoidCallback? onUseCurrentLocation;
  final String? countryCode;
  final String? countryName;
  final bool embedded;

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  List<WeatherLocation> _results = const <WeatherLocation>[];
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 2) {
      setState(() {
        _results = const <WeatherLocation>[];
        _error = null;
        _loading = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(value));
  }

  Future<void> _search(String query) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await widget.weatherService.searchCities(
        query,
        countryCode: widget.countryCode,
      );
      if (!mounted || query != _controller.text) return;
      setState(() {
        _results = results;
        _loading = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  void _select(WeatherLocation location) {
    FocusManager.instance.primaryFocus?.unfocus();
    widget.onSelected(location);
    if (!widget.embedded) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.countryName == null
                      ? 'Find a city'
                      : 'Cities in ${widget.countryName}',
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.countryName == null
                      ? 'Search cities and towns anywhere in the world.'
                      : 'Type any city or town to search within this country.',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: Colors.blueGrey.shade600),
                ),
                const SizedBox(height: 18),
                SearchBar(
                  controller: _controller,
                  autoFocus: !widget.embedded,
                  hintText: widget.countryName == null
                      ? 'City or postal code'
                      : 'City in ${widget.countryName}',
                  leading: const Icon(Icons.search_rounded),
                  trailing: <Widget>[
                    if (_controller.text.isNotEmpty)
                      IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _controller.clear();
                          _onChanged('');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() {});
                    _onChanged(value);
                  },
                  onSubmitted: _search,
                ),
                if (widget.onUseCurrentLocation != null) ...<Widget>[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        widget.onUseCurrentLocation!();
                      },
                      icon: const Icon(Icons.my_location_rounded),
                      label: const Text('Use my current location'),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          Expanded(child: _buildResults()),
        ],
      ),
    );

    if (widget.embedded) return content;
    return Scaffold(
      appBar: AppBar(title: Text(widget.countryName ?? 'Search')),
      body: content,
    );
  }

  Widget _buildResults() {
    if (_error != null) {
      return _Message(
        icon: Icons.cloud_off_rounded,
        title: 'Could not search',
        message: _error!,
      );
    }
    if (_controller.text.trim().length < 2) {
      return const _Message(
        icon: Icons.travel_explore_rounded,
        title: 'The whole world is here',
        message: 'Enter at least two letters to begin.',
      );
    }
    if (!_loading && _results.isEmpty) {
      return const _Message(
        icon: Icons.location_off_rounded,
        title: 'No cities found',
        message: 'Check the spelling or try a nearby city.',
      );
    }
    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
      itemCount: _results.length,
      separatorBuilder: (_, _) => const Divider(height: 1, indent: 62),
      itemBuilder: (context, index) {
        final location = _results[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 5,
          ),
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFE8F1FF),
            child: Text(
              location.countryCode ?? '•',
              style: const TextStyle(
                color: Color(0xFF2D6CDF),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          title: Text(
            location.name,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(location.subtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => _select(location),
        );
      },
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 50, color: const Color(0xFF6096E8)),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey.shade600, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
