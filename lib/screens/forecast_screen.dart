import 'package:flutter/material.dart';

import '../models/weather_models.dart';
import '../widgets/weather_visuals.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({
    super.key,
    required this.location,
    required this.forecast,
    required this.loading,
    required this.error,
    required this.isFavorite,
    required this.onRefresh,
    required this.onUseLocation,
    required this.onToggleFavorite,
  });

  final WeatherLocation? location;
  final WeatherForecast? forecast;
  final bool loading;
  final String? error;
  final bool isFavorite;
  final VoidCallback onRefresh;
  final VoidCallback onUseLocation;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    if (forecast == null) {
      return SafeArea(
        child: _ForecastEmpty(
          loading: loading,
          error: error,
          onUseLocation: onUseLocation,
        ),
      );
    }

    final current = forecast!.current;
    final visual = weatherVisual(current.weatherCode, isDay: current.isDay);
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _CurrentHeader(
              location: location!,
              forecast: forecast!,
              visual: visual,
              isFavorite: isFavorite,
              loading: loading,
              onUseLocation: onUseLocation,
              onToggleFavorite: onToggleFavorite,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 110),
            sliver: SliverList.list(
              children: <Widget>[
                if (error != null) ...<Widget>[
                  _InlineError(message: error!, onRetry: onRefresh),
                  const SizedBox(height: 14),
                ],
                _HourlyCard(items: forecast!.hourly),
                const SizedBox(height: 16),
                _DailyCard(items: forecast!.daily),
                const SizedBox(height: 16),
                _SunCard(day: forecast!.daily.first),
                const SizedBox(height: 14),
                const Center(
                  child: Text(
                    'Weather data by Open-Meteo',
                    style: TextStyle(color: Color(0xFF8290A4), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentHeader extends StatelessWidget {
  const _CurrentHeader({
    required this.location,
    required this.forecast,
    required this.visual,
    required this.isFavorite,
    required this.loading,
    required this.onUseLocation,
    required this.onToggleFavorite,
  });

  final WeatherLocation location;
  final WeatherForecast forecast;
  final WeatherVisual visual;
  final bool isFavorite;
  final bool loading;
  final VoidCallback onUseLocation;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final current = forecast.current;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: visual.colors,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(38)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: onUseLocation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              location.isCurrentLocation
                                  ? Icons.my_location_rounded
                                  : Icons.location_on_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    location.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  if (location.subtitle.isNotEmpty)
                                    Text(
                                      location.subtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.82,
                                        ),
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: isFavorite
                        ? 'Remove from favorites'
                        : 'Add to favorites',
                    onPressed: onToggleFavorite,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      foregroundColor: Colors.white,
                    ),
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                    ),
                  ),
                ],
              ),
              if (loading)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    color: Colors.white,
                    backgroundColor: Colors.white24,
                  ),
                ),
              const SizedBox(height: 20),
              Icon(visual.icon, size: 82, color: Colors.white),
              const SizedBox(height: 6),
              Text(
                formatTemperature(current.temperature),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 78,
                  height: 1,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                visual.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Feels like ${formatTemperature(current.feelsLike)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.86),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  _Metric(
                    icon: Icons.water_drop_rounded,
                    value: '${current.humidity}%',
                    label: 'Humidity',
                  ),
                  _Metric(
                    icon: Icons.air_rounded,
                    value: '${current.windSpeed.round()} mph',
                    label: 'Wind',
                  ),
                  _Metric(
                    icon: Icons.umbrella_rounded,
                    value: '${current.precipitation.toStringAsFixed(2)} in',
                    label: 'Rain',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Icon(icon, color: Colors.white, size: 21),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _HourlyCard extends StatelessWidget {
  const _HourlyCard({required this.items});

  final List<HourlyWeather> items;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Next 24 hours',
      child: SizedBox(
        height: 132,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final item = items[index];
            final visual = weatherVisual(item.weatherCode);
            return Container(
              width: 74,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                color: index == 0
                    ? const Color(0xFFE9F2FF)
                    : const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: <Widget>[
                  Text(
                    index == 0 ? 'Now' : formatHour(item.time),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Icon(visual.icon, color: visual.colors.first, size: 27),
                  const Spacer(),
                  Text(
                    formatTemperature(item.temperature),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${item.precipitationChance}%',
                    style: const TextStyle(
                      color: Color(0xFF4D89E8),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DailyCard extends StatelessWidget {
  const _DailyCard({required this.items});

  final List<DailyWeather> items;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '7-day forecast',
      child: Column(
        children: List<Widget>.generate(items.length, (index) {
          final item = items[index];
          final visual = weatherVisual(item.weatherCode);
          return Column(
            children: <Widget>[
              if (index > 0) const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 13),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 56,
                      child: Text(
                        index == 0 ? 'Today' : weekdayName(item.date),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Icon(visual.icon, color: visual.colors.first, size: 25),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        visual.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.blueGrey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.water_drop_rounded,
                      size: 13,
                      color: Color(0xFF5794EE),
                    ),
                    const SizedBox(width: 3),
                    SizedBox(
                      width: 34,
                      child: Text(
                        '${item.precipitationChance}%',
                        style: const TextStyle(
                          color: Color(0xFF5794EE),
                          fontSize: 11,
                        ),
                      ),
                    ),
                    Text(
                      formatTemperature(item.high),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 28,
                      child: Text(
                        formatTemperature(item.low),
                        style: TextStyle(color: Colors.blueGrey.shade500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _SunCard extends StatelessWidget {
  const _SunCard({required this.day});

  final DailyWeather day;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Sunrise & sunset',
      child: Row(
        children: <Widget>[
          Expanded(
            child: _SunTime(
              icon: Icons.wb_twilight_rounded,
              label: 'Sunrise',
              value: formatHour(day.sunrise),
              color: const Color(0xFFFFA726),
            ),
          ),
          Container(width: 1, height: 48, color: const Color(0xFFE5EAF1)),
          Expanded(
            child: _SunTime(
              icon: Icons.nights_stay_rounded,
              label: 'Sunset',
              value: formatHour(day.sunset),
              color: const Color(0xFF6750A4),
            ),
          ),
        ],
      ),
    );
  }
}

class _SunTime extends StatelessWidget {
  const _SunTime({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        Text(
          label,
          style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 11),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 15),
            child,
          ],
        ),
      ),
    );
  }
}

class _ForecastEmpty extends StatelessWidget {
  const _ForecastEmpty({
    required this.loading,
    required this.error,
    required this.onUseLocation,
  });

  final bool loading;
  final String? error;
  final VoidCallback onUseLocation;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 108,
              height: 108,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[Color(0xFF4F8EF7), Color(0xFFFFB347)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sunny_snowing,
                size: 58,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              loading ? 'Finding your weather…' : 'Weather starts with a place',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              error ??
                  'Use your location, search for a city, or browse by country.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey.shade600, height: 1.4),
            ),
            const SizedBox(height: 24),
            if (loading)
              const CircularProgressIndicator()
            else
              FilledButton.icon(
                onPressed: onUseLocation,
                icon: const Icon(Icons.my_location_rounded),
                label: const Text('Use my location'),
              ),
          ],
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEF1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.cloud_off_rounded, color: Color(0xFFB83B5E)),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
