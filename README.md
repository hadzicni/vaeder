# VAEDER

"Vaeder" is a modern weather application built with [Flutter](https://flutter.dev/). It uses geolocation and geocoding packages to detect the current device location and retrieves weather information from the OpenWeatherMap API.

## Features
- Display of current weather for the user's location
- Animated weather illustrations using Lottie
- Support for Android, iOS, Web, Windows, macOS and Linux
- Switch between Celsius and Fahrenheit
- View a 5 day forecast
- Swipe horizontally to access the forecast page

## Requirements
- Flutter SDK 3.8 or higher
- API key from [OpenWeatherMap](https://openweathermap.org/)

## Setup
1. Clone the repository and install dependencies:
   ```bash
   flutter pub get
   ```
2. Optional: Insert your API key in `lib/services/weather_service.dart`.

## Running the app
- Mobile/Web:
  ```bash
  flutter run
  ```
- Desktop (e.g. Windows):
  ```bash
  flutter run -d windows
  ```

## Project structure
- **lib/** source code for models, pages and services
- **assets/** graphics, Lottie animations and fonts
- **test/** example widget tests
- Platform directories for Android, iOS, Web and desktop

## Running tests
To execute the provided widget tests:
```bash
flutter test
```

## License
This project is licensed under the Apache License 2.0. See [LICENSE](LICENSE) for details.
