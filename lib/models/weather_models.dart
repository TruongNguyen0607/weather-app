import 'dart:convert';

class WeatherLocation {
  const WeatherLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.countryCode,
    this.region,
    this.timezone,
    this.isCurrentLocation = false,
  });

  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? countryCode;
  final String? region;
  final String? timezone;
  final bool isCurrentLocation;

  String get id =>
      '${latitude.toStringAsFixed(4)},${longitude.toStringAsFixed(4)}';

  String get subtitle {
    final parts = <String>[
      if (region != null && region!.isNotEmpty && region != name) region!,
      if (country != null && country!.isNotEmpty) country!,
    ];
    return parts.join(', ');
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'country': country,
    'countryCode': countryCode,
    'region': region,
    'timezone': timezone,
    'isCurrentLocation': isCurrentLocation,
  };

  factory WeatherLocation.fromJson(Map<String, dynamic> json) {
    return WeatherLocation(
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: json['country'] as String?,
      countryCode: json['countryCode'] as String?,
      region: json['region'] as String?,
      timezone: json['timezone'] as String?,
      isCurrentLocation: json['isCurrentLocation'] as bool? ?? false,
    );
  }

  String encode() => jsonEncode(toJson());

  factory WeatherLocation.decode(String value) =>
      WeatherLocation.fromJson(jsonDecode(value) as Map<String, dynamic>);
}

class CurrentWeather {
  const CurrentWeather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.precipitation,
    required this.windSpeed,
    required this.weatherCode,
    required this.isDay,
  });

  final double temperature;
  final double feelsLike;
  final int humidity;
  final double precipitation;
  final double windSpeed;
  final int weatherCode;
  final bool isDay;
}

class HourlyWeather {
  const HourlyWeather({
    required this.time,
    required this.temperature,
    required this.precipitationChance,
    required this.weatherCode,
  });

  final DateTime time;
  final double temperature;
  final int precipitationChance;
  final int weatherCode;
}

class DailyWeather {
  const DailyWeather({
    required this.date,
    required this.high,
    required this.low,
    required this.precipitationChance,
    required this.weatherCode,
    required this.sunrise,
    required this.sunset,
  });

  final DateTime date;
  final double high;
  final double low;
  final int precipitationChance;
  final int weatherCode;
  final DateTime sunrise;
  final DateTime sunset;
}

class WeatherForecast {
  const WeatherForecast({
    required this.current,
    required this.hourly,
    required this.daily,
    required this.timezone,
  });

  final CurrentWeather current;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;
  final String timezone;
}
