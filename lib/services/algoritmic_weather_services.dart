import 'dart:convert';
import 'package:flutter/services.dart'; // JSON dosyasını okumak için gerekli
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_app/WeatherUI.dart';

const String apiKey = 'd73a42c58731ba78504b39577b6545f0';
const String city = 'Bandırma';
const String currentWeatherUrl =
    'https://api.openweathermap.org/data/2.5/weather';

class WeatherData extends StatelessWidget {
  const WeatherData({super.key});

  Future<Map<String, dynamic>> fetchWeatherData() async {
    try {
      final weatherData = await fetchCurrentWeather();
      final lastYearTemp = await fetchLastYearTemperature();

      final double calculatedTemperature = calculateTemperature(
        currentHumidity: weatherData['humidity']!,
        currentWindSpeed: weatherData['windSpeed']!,
        currentPressure: weatherData['pressure']!,
        lastYearTemp: lastYearTemp,
      );

      return {
        'calculatedTemperature': calculatedTemperature,
        'humidity': weatherData['humidity'],
        'windSpeed': weatherData['windSpeed'],
        'pressure': weatherData['pressure'],
      };
    } catch (e) {
      throw Exception('Veri alınırken bir hata oluştu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hava Durumu Verileri'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              final weatherData = await fetchWeatherData();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WeatherUI(weatherData: weatherData),
                ),
              );
            } catch (e) {
              // Hata durumu
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Hata"),
                  content: Text('Veri alınırken bir hata oluştu: $e'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Tamam'),
                    ),
                  ],
                ),
              );
            }
          },
          child: const Text('Hava Durumu Tahmini Gör'),
        ),
      ),
    );
  }

  Future<Map<String, double>> fetchCurrentWeather() async {
    final response = await http.get(
        Uri.parse('$currentWeatherUrl?q=$city&appid=$apiKey&units=metric'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final double humidity = (data['main']['humidity'] is int)
          ? (data['main']['humidity'] as int).toDouble()
          : (data['main']['humidity'] as double);

      final double windSpeed = (data['wind']['speed'] is int)
          ? (data['wind']['speed'] as int).toDouble()
          : (data['wind']['speed'] as double);

      final double pressure = (data['main']['pressure'] is int)
          ? (data['main']['pressure'] as int).toDouble()
          : (data['main']['pressure'] as double);

      return {
        'humidity': humidity,
        'windSpeed': windSpeed,
        'pressure': pressure,
      };
    } else {
      throw Exception('Hava durumu verileri alınamadı!');
    }
  }

  Future<double> fetchLastYearTemperature() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/last_year.json');
      final List<dynamic> jsonData = jsonDecode(jsonString);

      final DateTime today = DateTime.now();
      // Bugünün tarihini tam olarak d.M.yyyy formatında alın
      final DateTime lastYearDate =
          DateTime(today.year - 1, today.month, today.day + 2);
      final String targetDate = DateFormat('d.M.yyyy')
          .format(lastYearDate); // Tarihi "d.M.yyyy" formatında alıyoruz
      print("tarih" + targetDate);
      for (var data in jsonData) {
        if (data['Tarih'] == targetDate) {
          final String averageTemperature = data['Ortalama'].toString();
          return double.parse(averageTemperature.replaceAll(',', '.'));
        }
      }

      // Eğer veriyi bulamazsanız
      throw Exception('Geçen yılın hava durumu verisi alınamadı!');
    } catch (e) {
      throw Exception('Geçen yılın verileri alınırken hata oluştu: $e');
    }
  }

  /// Bugünün sıcaklık tahminini hesaplar.
  double calculateTemperature({
    required double currentHumidity,
    required double currentWindSpeed,
    required double currentPressure,
    required double lastYearTemp,
  }) {
    // Nem, rüzgar hızı ve basınç faktörlerini kullanarak bugünün tahmini sıcaklığını hesapla.
    // Bu faktörler üzerinde ağırlıklı bir hesaplama yapacağız.

    const double humidityFactor = 0.04; // Nem oranının etkisi
    const double windSpeedFactor = 0.2; // Rüzgar hızının etkisi
    const double pressureFactor = 0.02; // Basıncın etkisi

    // Nem oranı ve rüzgar hızı ile bir tahmin oluşturuyoruz.
    double temperatureEstimate = (currentHumidity * humidityFactor) +
        (currentWindSpeed * windSpeedFactor) +
        (currentPressure * pressureFactor);

    // Geçen yılın verisiyle bu tahmini sıcaklık birleştiriyoruz.
    // Bu hesaplama için ağırlıklı bir ortalama kullanalım.
    double weightedAverageTemperature =
        (temperatureEstimate + lastYearTemp) / 3;

    return weightedAverageTemperature;
  }
}
