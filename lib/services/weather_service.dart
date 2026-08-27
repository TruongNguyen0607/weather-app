import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather_models.dart';

class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<WeatherLocation>> searchCities(
    String query, {
    String? countryCode,
  }) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return const <WeatherLocation>[];

    final uri = Uri.https(
      'geocoding-api.open-meteo.com',
      '/v1/search',
      <String, String>{
        'name': trimmed,
        'count': '20',
        'language': 'en',
        'format': 'json',
        'countryCode': ?countryCode,
      },
    );
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw WeatherException('City search is unavailable right now.');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final results = json['results'] as List<dynamic>? ?? const <dynamic>[];
    return results.map((dynamic item) {
      final map = item as Map<String, dynamic>;
      return WeatherLocation(
        name: map['name'] as String,
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        country: map['country'] as String?,
        countryCode: map['country_code'] as String?,
        region: map['admin1'] as String?,
        timezone: map['timezone'] as String?,
      );
    }).toList();
  }

  Future<WeatherForecast> getForecast(WeatherLocation location) async {
    final uri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      <String, String>{
        'latitude': location.latitude.toString(),
        'longitude': location.longitude.toString(),
        'current': [
          'temperature_2m',
          'relative_humidity_2m',
          'apparent_temperature',
          'is_day',
          'precipitation',
          'weather_code',
          'wind_speed_10m',
        ].join(','),
        'hourly': [
          'temperature_2m',
          'precipitation_probability',
          'weather_code',
        ].join(','),
        'daily': [
          'weather_code',
          'temperature_2m_max',
          'temperature_2m_min',
          'precipitation_probability_max',
          'sunrise',
          'sunset',
        ].join(','),
        'temperature_unit': 'fahrenheit',
        'wind_speed_unit': 'mph',
        'precipitation_unit': 'inch',
        'timezone': 'auto',
        'forecast_days': '7',
      },
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw WeatherException('The forecast is unavailable right now.');
    }

    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final current = json['current'] as Map<String, dynamic>;
      final hourly = json['hourly'] as Map<String, dynamic>;
      final daily = json['daily'] as Map<String, dynamic>;

      final hourlyTimes = _strings(hourly['time']);
      final hourlyTemperatures = _numbers(hourly['temperature_2m']);
      final hourlyPrecipitation = _numbers(hourly['precipitation_probability']);
      final hourlyCodes = _numbers(hourly['weather_code']);

      final now = DateTime.now();
      final allHourly = List<HourlyWeather>.generate(hourlyTimes.length, (
        index,
      ) {
        return HourlyWeather(
          time: DateTime.parse(hourlyTimes[index]),
          temperature: hourlyTemperatures[index].toDouble(),
          precipitationChance: hourlyPrecipitation[index].round(),
          weatherCode: hourlyCodes[index].round(),
        );
      });
      final upcomingHourly = allHourly
          .where(
            (item) => item.time.isAfter(now.subtract(const Duration(hours: 1))),
          )
          .take(24)
          .toList();

      final dailyTimes = _strings(daily['time']);
      final highs = _numbers(daily['temperature_2m_max']);
      final lows = _numbers(daily['temperature_2m_min']);
      final dailyPrecipitation = _numbers(
        daily['precipitation_probability_max'],
      );
      final dailyCodes = _numbers(daily['weather_code']);
      final sunrises = _strings(daily['sunrise']);
      final sunsets = _strings(daily['sunset']);

      return WeatherForecast(
        current: CurrentWeather(
          temperature: (current['temperature_2m'] as num).toDouble(),
          feelsLike: (current['apparent_temperature'] as num).toDouble(),
          humidity: (current['relative_humidity_2m'] as num).round(),
          precipitation: (current['precipitation'] as num).toDouble(),
          windSpeed: (current['wind_speed_10m'] as num).toDouble(),
          weatherCode: (current['weather_code'] as num).round(),
          isDay: (current['is_day'] as num).round() == 1,
        ),
        hourly: upcomingHourly,
        daily: List<DailyWeather>.generate(dailyTimes.length, (index) {
          return DailyWeather(
            date: DateTime.parse(dailyTimes[index]),
            high: highs[index].toDouble(),
            low: lows[index].toDouble(),
            precipitationChance: dailyPrecipitation[index].round(),
            weatherCode: dailyCodes[index].round(),
            sunrise: DateTime.parse(sunrises[index]),
            sunset: DateTime.parse(sunsets[index]),
          );
        }),
        timezone:
            json['timezone'] as String? ?? location.timezone ?? 'Local time',
      );
    } on FormatException {
      throw WeatherException('The forecast response could not be read.');
    } on TypeError {
      throw WeatherException('The forecast response was incomplete.');
    }
  }

  List<String> _strings(dynamic values) =>
      (values as List<dynamic>).cast<String>();

  List<num> _numbers(dynamic values) => (values as List<dynamic>).cast<num>();

  void dispose() => _client.close();
}

class WeatherException implements Exception {
  const WeatherException(this.message);

  final String message;

  @override
  String toString() => message;
}
