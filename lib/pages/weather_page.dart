import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final WeatherService _weatherService =
      WeatherService('18acc8bc0f1204e848d9577285281a54');

  Weather? _weather;

  @override
  void initState() {
    super.initState();
    getWeather();
  }

  Future<void> getWeather() async {
    try {
      String cityName = await _weatherService.getCurrentCity();

      final weather = await _weatherService.getWeather(cityName);

      setState(() {
        _weather = weather;
      });
    } catch (e) {
    //WEather could not be loaded
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/sunny.json'),
            const SizedBox(height: 20),
            Text(
              _weather?.cityName ?? 'Loading city...',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),


            const SizedBox(height: 20),
            Text(
              _weather != null
                  ? '${_weather!.temparature.round()}°C'
                  : 'Loading temperature...',
              style: const TextStyle(
                fontSize: 50,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _weather?.mainCondition ?? 'Loading weather...',
              style: const TextStyle(
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}