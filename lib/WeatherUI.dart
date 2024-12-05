import 'package:flutter/material.dart';

class WeatherUI extends StatelessWidget {
  final Map<String, dynamic> weatherData;

  const WeatherUI({super.key, required this.weatherData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hava Durumu Tahmini'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tahmini Sıcaklık: ${weatherData['calculatedTemperature']}°C',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text('Nem: ${weatherData['humidity']}%'),
            Text('Rüzgar Hızı: ${weatherData['windSpeed']} m/s'),
            Text('Basınç: ${weatherData['pressure']} hPa'),
          ],
        ),
      ),
    );
  }
}
