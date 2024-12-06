// Bu uygulama, bir şehir için hava durumu verilerini görüntülemek ve tahmini sıcaklık değerlerini hesaplamak amacıyla tasarlanmıştır.
// JSON dosyaları ve harici API'ler kullanılarak bugünkü hava durumu ve geçen yılın aynı gününe ait veriler alınır.
// Bu veriler, bir sıcaklık tahmini yapmak için çeşitli faktörler göz önünde bulundurularak hesaplanır.
import 'dart:convert';
import 'package:flutter/services.dart'; // JSON dosyasını okumak için gerekli
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tarih formatlama işlemleri için gerekli
import 'package:weather_app/anasayfa.dart'; // Hava durumu arayüzü için gerekli.

// WeatherData sınıfı, hava durumu verilerini alıp işleyecek olan StatelessWidget.
class WeatherData extends StatelessWidget {
  const WeatherData({super.key});

  // Hava durumu verilerini JSON dosyasından ve geçen yılki verilerden alır, tahmini sıcaklık hesaplar.
  Future<Map<String, dynamic>> fetchWeatherData() async {
    try {
      // Şu anki hava durumu verilerini al
      final weatherData = await fetchWeatherForToday("Bandırma");

      // Geçen yılın aynı gününe ait sıcaklık verilerini al
      final lastYearTemp = await fetchWeatherForLastYear("Bandırma");

      // Tahmini sıcaklığı hesapla
      final double calculatedTemperature = calculateTemperature(
        currentHumidity: weatherData['humidity']!,
        currentWindSpeed: weatherData['windSpeed']!,
        currentPressure: weatherData['pressure']!,
        lastYearTemp: lastYearTemp["Ortalama"]!,
      );

      // Hesaplanan ve alınan verileri bir map olarak döndür
      return {
        'calculatedTemperature': calculatedTemperature,
        'humidity': weatherData['humidity'],
        'windSpeed': weatherData['windSpeed'],
        'pressure': weatherData['pressure'],
      };
    } catch (e) {
      // Hata durumunda bir exception fırlat
      throw Exception('Veri alınırken bir hata oluştu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Uygulama ekranının düzeni
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hava Durumu Verileri'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              // Hava durumu verilerini al ve WeatherUI ekranına yönlendir
              final weatherData = await fetchWeatherData();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WeatherApp(),
                ),
              );
            } catch (e) {
              // Hata durumunda bir uyarı göster
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

  // Bugünkü hava durumu verilerini JSON dosyasından alır.
  Future<Map<String, double>> fetchWeatherForToday(String cityName) async {
    try {
      // Bugünün tarihini al ve formatla (d.M.yyyy)
      final today = DateFormat('d.M.yyyy').format(DateTime.now());

      // JSON dosyasını oku
      final contents = await rootBundle.loadString('assets/data/now_city_three.json');

      // JSON verisini parse et
      final data = jsonDecode(contents);

      // Şehir ve tarih verilerini kontrol et
      if (data[cityName] == null) {
        throw Exception('$cityName verisi JSON dosyasında bulunamadı.');
      }
      final cityData = data[cityName];
      if (cityData[today] == null) {
        throw Exception('Bugün ($today) tarihi için $cityName verisi bulunamadı.');
      }

      // Hava durumu verilerini al
      final weatherData = cityData[today];

      // Dinamik olarak değerleri al ve double formatına çevir
      final double humidity = (weatherData['humidity'] as num).toDouble();
      final double windSpeed = (weatherData['windspeed'] as num).toDouble();
      final double pressure = (weatherData['pressure'] as num).toDouble();

      return {
        'humidity': humidity,
        'windSpeed': windSpeed,
        'pressure': pressure,
      };
    } catch (e) {
      // Hata durumunda bir exception fırlat
      throw Exception('JSON verileri işlenirken bir hata oluştu: $e');
    }
  }
  // Geçen Yılın hava durumu verilerini JSON dosyasından alır.
  Future<Map<String, double>> fetchWeatherForLastYear(String cityName) async {
    try {
      // Bugünün tarihini al ve formatla (d.M.yyyy)
      final DateTime today = DateTime.now();
      final DateTime lastYearDate = DateTime(today.year - 1, today.month, today.day);
      final String targetDate = DateFormat('d.M.yyyy').format(lastYearDate);

      // JSON dosyasını oku
      final contents = await rootBundle.loadString('assets/data/three_city_last_year.json');

      // JSON verisini parse et
      final data = jsonDecode(contents);

      // Şehir ve tarih verilerini kontrol et
      if (data[cityName] == null) {
        throw Exception('$cityName verisi JSON dosyasında bulunamadı.');
      }

      // Şehre ait veriler
      final cityData = data[cityName];

      // Belirli bir tarih için veriyi bul
      Map<String, dynamic>? weatherData;

      // Listede döngü ile ilgili tarihi arayın
      for (var entry in cityData) {
        if (entry.containsKey(targetDate)) {
          weatherData = entry[targetDate];
          break;
        }
      }

      if (weatherData == null) {
        throw Exception('Geçen yılın ($targetDate) tarihi için $cityName verisi bulunamadı.');
      }

      // "Ortalama" verisini alın ve double olarak dönüştürün
      final double ortalama = (weatherData['Ortalama'] as num).toDouble();

      return {
        'Ortalama': ortalama,
      };
    } catch (e) {
      // Hata durumunda bir exception fırlat
      throw Exception('JSON verileri işlenirken bir hata oluştu: $e');
    }
  }


  // // Geçen yılın aynı gününe ait sıcaklık verilerini JSON dosyasından alır.
  // Future<double> fetchLastYearTemperature() async {
  //   try {
  //     // JSON dosyasını oku
  //     final String jsonString = await rootBundle.loadString('assets/data/last_year.json');
  //     final List<dynamic> jsonData = jsonDecode(jsonString);
  //
  //     // Geçen yılın tarihini hesapla
  //     final DateTime today = DateTime.now();
  //     final DateTime lastYearDate = DateTime(today.year - 1, today.month, today.day);
  //     final String targetDate = DateFormat('d.M.yyyy').format(lastYearDate);
  //
  //     // JSON verilerinde ilgili tarihi bul ve sıcaklığı al
  //     for (var data in jsonData) {
  //       if (data['Tarih'] == targetDate) {
  //         final String averageTemperature = data['Ortalama'].toString();
  //         return double.parse(averageTemperature.replaceAll(',', '.'));
  //       }
  //     }
  //
  //     // Veri bulunamazsa exception fırlat
  //     throw Exception('Geçen yılın hava durumu verisi alınamadı!');
  //   } catch (e) {
  //     // Hata durumunda bir exception fırlat
  //     throw Exception('Geçen yılın verileri alınırken hata oluştu: $e');
  //   }
  // }

  // Bugünkü sıcaklık tahminini hesaplar.
  double calculateTemperature({
    required double? currentHumidity,
    required double? currentWindSpeed,
    required double? currentPressure,
    required double lastYearTemp,
  }) {
    if (currentHumidity == null || currentWindSpeed == null || currentPressure == null) {
      throw Exception('Girdi değerlerinden biri null!');
    }

    // Faktör katsayıları
    const double humidityFactor = 0.04;
    const double windSpeedFactor = 0.2;
    const double pressureFactor = 0.02;

    // Sıcaklık tahmini hesapla
    double temperatureEstimate = (currentHumidity * humidityFactor) +
        (currentWindSpeed * windSpeedFactor) +
        (currentPressure * pressureFactor);

    // Geçmiş veri ile ağırlıklı ortalama hesapla
    double weightedAverageTemperature =
        (temperatureEstimate + lastYearTemp) / 3;

    return weightedAverageTemperature;
  }
}
