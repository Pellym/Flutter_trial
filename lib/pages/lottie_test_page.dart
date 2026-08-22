import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lottie Test'),
      ),
      body: Center(
        child: Lottie.asset(
          'assets/sunny.json',
          width: 250,
          height: 250,
          fit: BoxFit.contain,
          repeat: true,
          animate: true,
        ),
      ),
    );
  }
}