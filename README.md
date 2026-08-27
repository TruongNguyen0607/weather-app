# Weather

A colorful Flutter weather app for Android and iOS.

## Features

- Detect the device's current location
- Search cities and towns worldwide
- Browse every country, then search within that country
- Current conditions in Fahrenheit
- 24-hour and 7-day forecasts
- Save favorite locations on the device
- Weather-aware colors and icons

Weather and location search data are provided by Open-Meteo. No API key is
stored in the project.

## Run

```sh
flutter pub get
flutter run
```

On Windows, Android's build tools require the project to live in a path that
contains only ASCII characters. If Gradle reports a non-ASCII path error, move
the project to a path such as `C:\dev\weather` before running it.

## Verify

```sh
dart analyze
flutter test
```
