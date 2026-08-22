import 'dart:convert';

import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/weather_model.dart';

class WeatherService {
  static const String baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  final String apiKey;

  WeatherService(this.apiKey);

  // Get weather for a city
  Future<Weather> getWeather(String cityName) async {
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: {
        'q': cityName,
        'appid': apiKey,
        'units': 'metric',
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      return Weather.fromJson(data);
    } else {
      throw Exception(
        'Failed to load weather data. '
        'Status code: ${response.statusCode}',
      );
    }
  }

  // Get the user's current GPS location
  Future<Position> getCurrentPosition() async {
    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception(
        'Location permission denied.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission permanently denied. '
        'Please enable location permission in Android settings.',
      );
    }

    final bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception(
        'Location services are disabled.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    ).timeout(
      const Duration(seconds: 10),
    );
  }

  // Convert GPS coordinates into a city name
  Future<String> getCurrentCity() async {
    final Position position = await getCurrentPosition();

    final geo.Geocoding geocoding = geo.Geocoding();

    final List<geo.Placemark> placemarks =
        await geocoding.placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isEmpty) {
      throw Exception(
        'Could not determine the current city.',
      );
    }

    final geo.Placemark place = placemarks.first;

    final String city =
        place.locality ??
        place.subAdministrativeArea ??
        place.administrativeArea ??
        '';

    if (city.isEmpty) {
      throw Exception(
        'Could not determine the current city.',
      );
    }

    return city;
  }
}
