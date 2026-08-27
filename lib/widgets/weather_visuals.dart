import 'package:flutter/material.dart';

class WeatherVisual {
  const WeatherVisual({
    required this.label,
    required this.icon,
    required this.colors,
  });

  final String label;
  final IconData icon;
  final List<Color> colors;
}

WeatherVisual weatherVisual(int code, {bool isDay = true}) {
  if (!isDay && code <= 3) {
    return const WeatherVisual(
      label: 'Clear night',
      icon: Icons.nights_stay_rounded,
      colors: <Color>[Color(0xFF172A74), Color(0xFF6A4C93)],
    );
  }
  if (code == 0) {
    return const WeatherVisual(
      label: 'Clear sky',
      icon: Icons.wb_sunny_rounded,
      colors: <Color>[Color(0xFF3B82F6), Color(0xFFFFB347)],
    );
  }
  if (code <= 3) {
    return const WeatherVisual(
      label: 'Partly cloudy',
      icon: Icons.cloud_rounded,
      colors: <Color>[Color(0xFF4F8EF7), Color(0xFF8EC5FC)],
    );
  }
  if (code == 45 || code == 48) {
    return const WeatherVisual(
      label: 'Foggy',
      icon: Icons.blur_on_rounded,
      colors: <Color>[Color(0xFF667EEA), Color(0xFF9FA8DA)],
    );
  }
  if (code >= 71 && code <= 77 || code == 85 || code == 86) {
    return const WeatherVisual(
      label: 'Snow',
      icon: Icons.ac_unit_rounded,
      colors: <Color>[Color(0xFF4FACFE), Color(0xFFB7E9F7)],
    );
  }
  if (code >= 95) {
    return const WeatherVisual(
      label: 'Thunderstorms',
      icon: Icons.thunderstorm_rounded,
      colors: <Color>[Color(0xFF42275A), Color(0xFF734B6D)],
    );
  }
  if (code >= 51 && code <= 67 || code >= 80 && code <= 82) {
    return const WeatherVisual(
      label: 'Rain',
      icon: Icons.water_drop_rounded,
      colors: <Color>[Color(0xFF2774AE), Color(0xFF56CCF2)],
    );
  }
  return const WeatherVisual(
    label: 'Cloudy',
    icon: Icons.cloud_rounded,
    colors: <Color>[Color(0xFF5C7AEA), Color(0xFF8AAAE5)],
  );
}

String formatTemperature(double value) => '${value.round()}°';

String formatHour(DateTime value) {
  var hour = value.hour;
  final suffix = hour >= 12 ? 'PM' : 'AM';
  hour %= 12;
  if (hour == 0) hour = 12;
  return '$hour $suffix';
}

String weekdayName(DateTime value) {
  const names = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return names[value.weekday - 1];
}
