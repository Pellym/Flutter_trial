import 'dart:async';

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

  String? _error;

  bool _isLoading = true;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Load weather immediately
    getWeather();

    // Refresh weather every 10 minutes
    _timer = Timer.periodic(
      const Duration(minutes: 10),
      (timer) {
        getWeather();
      },
    );
  }

  Future<void> getWeather() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      // Get the user's current city
      final cityName = await _weatherService.getCurrentCity();

      // Get latest weather for that city
      final weather =
          await _weatherService.getWeather(cityName);

      if (!mounted) return;

      setState(() {
        _weather = weather;
        _isLoading = false;
      });

      debugPrint(
        'Weather updated: ${weather.cityName}, '
        '${weather.temparature}°C, '
        '${weather.mainCondition}',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Could not load weather';
        _isLoading = false;
      });

      debugPrint('Weather error: $e');
    }
  }

  String getWeatherAnimation(String? condition) {
    if (condition == null) {
      return 'assets/sunny.json';
    }

    final weather = condition.toLowerCase();

    if (weather.contains('rain') ||
        weather.contains('drizzle') ||
        weather.contains('shower')) {
      return 'assets/Rain icon.json';
    }

    if (weather.contains('thunder') ||
        weather.contains('storm')) {
      return 'assets/Weather-storm.json';
    }

    if (weather.contains('wind')) {
      return 'assets/Weather-windy.json';
    }

    if (weather.contains('cloud')) {
      return 'assets/Weather-windy.json';
    }

    return 'assets/sunny.json';
  }

  @override
  void dispose() {
    // Stop the timer when leaving the page
    _timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
        centerTitle: true,

        actions: [
          IconButton(
            onPressed: _isLoading ? null : getWeather,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: getWeather,

        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),

          children: [
            const SizedBox(height: 40),

            // Lottie animation
            SizedBox(
              height: 250,

              child: Lottie.asset(
                getWeatherAnimation(
                  _weather?.mainCondition,
                ),

                fit: BoxFit.contain,
                repeat: true,
                animate: true,

                errorBuilder:
                    (context, error, stackTrace) {
                  debugPrint(
                    'Lottie error: $error',
                  );

                  return const Icon(
                    Icons.cloud,
                    size: 120,
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // City
            Text(
              _weather?.cityName ?? 'Loading city...',

              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Temperature
            Text(
              _weather != null
                  ? '${_weather!.temparature.round()}°C'
                  : 'Loading temperature...',

              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.w300,
              ),
            ),

            const SizedBox(height: 15),

            // Weather condition
            Text(
              _weather?.mainCondition ??
                  'Loading weather...',

              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 24,
              ),
            ),

            const SizedBox(height: 30),

            // Loading indicator
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),

            const SizedBox(height: 20),

            // Error
            if (_error != null)
              Column(
                children: [
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: getWeather,
                    child: const Text(
                      'Try Again',
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 40),

            // Manual refresh
            Center(
              child: ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : getWeather,

                icon: const Icon(
                  Icons.refresh,
                ),

                label: const Text(
                  'Update Weather',
                ),
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}