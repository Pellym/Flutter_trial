import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    getWeather();
  }

  Future<void> getWeather() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final cityName = await _weatherService.getCurrentCity();

      final weather = await _weatherService.getWeather(cityName);

      if (!mounted) return;

      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Weather error: $e');

      if (!mounted) return;

      setState(() {
        _error = 'Could not load weather';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> getActivities() {
    final condition = _weather?.mainCondition.toLowerCase() ?? '';

    if (condition.contains('rain') ||
        condition.contains('drizzle')) {
      return [
        {
          'icon': Icons.menu_book,
          'title': 'Read a book',
        },
        {
          'icon': Icons.movie,
          'title': 'Watch a movie',
        },
        {
          'icon': Icons.local_cafe,
          'title': 'Make some coffee',
        },
      ];
    }

    if (condition.contains('storm') ||
        condition.contains('thunder')) {
      return [
        {
          'icon': Icons.home,
          'title': 'Relax at home',
        },
        {
          'icon': Icons.videogame_asset,
          'title': 'Play a game',
        },
        {
          'icon': Icons.music_note,
          'title': 'Listen to music',
        },
      ];
    }

    if (condition.contains('cloud')) {
      return [
        {
          'icon': Icons.directions_walk,
          'title': 'Go for a walk',
        },
        {
          'icon': Icons.headphones,
          'title': 'Listen to music',
        },
        {
          'icon': Icons.camera_alt,
          'title': 'Take some photos',
        },
      ];
    }

    return [
      {
        'icon': Icons.wb_sunny,
        'title': 'Enjoy the sunshine',
      },
      {
        'icon': Icons.directions_walk,
        'title': 'Go for a walk',
      },
      {
        'icon': Icons.park,
        'title': 'Have a picnic',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final activities = getActivities();

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
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 20),

            const Icon(
              Icons.cloud,
              size: 120,
            ),

            const SizedBox(height: 20),

            Text(
              _weather?.cityName ?? 'Loading city...',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              _weather != null
                  ? '${_weather!.temparature.round()}°C'
                  : 'Loading temperature...',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              _weather?.mainCondition ?? 'Loading weather...',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
              ),
            ),

            const SizedBox(height: 35),

            // Today's activities
            const Text(
              '✨ Things to do today',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            ...activities.map(
              (activity) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(activity['icon']),
                    ),
                    title: Text(
                      activity['title'],
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Great idea! ${activity['title']}',
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),

            if (_error != null) ...[
              const SizedBox(height: 20),

              Center(
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: ElevatedButton(
                  onPressed: getWeather,
                  child: const Text('Try Again'),
                ),
              ),
            ],

            const SizedBox(height: 25),

            Center(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : getWeather,
                icon: const Icon(Icons.refresh),
                label: const Text('Update Weather'),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
