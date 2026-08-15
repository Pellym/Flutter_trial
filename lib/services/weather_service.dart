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

Future<Weather> getWeather(String cityName) async {
final response = await http.get(
Uri.parse(
'$baseUrl?q=$cityName&appid=$apiKey&units=metric',
),
);

if (response.statusCode == 200) {
  return Weather.fromJson(jsonDecode(response.body));
} else {
  throw Exception('Failed to load weather data');
}

}

Future<String> getCurrentCity() async {
LocationPermission permission =
await Geolocator.checkPermission();

if (permission == LocationPermission.denied) {
  permission = await Geolocator.requestPermission();
}

if (permission == LocationPermission.denied ||
    permission == LocationPermission.deniedForever) {
  throw Exception('Location permission denied');
}

final Position position =
    await Geolocator.getCurrentPosition(
  locationSettings: const LocationSettings(
    accuracy: LocationAccuracy.high,
  ),
);

final geo.Geocoding geocoding = geo.Geocoding();

final List<geo.Placemark> placemarks =
    await geocoding.placemarkFromCoordinates(
  position.latitude,
  position.longitude,
);

final String? city = placemarks.first.locality;

return city ?? '';

}
}

