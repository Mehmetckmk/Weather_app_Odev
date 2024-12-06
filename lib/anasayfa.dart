import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  final TextEditingController _controller = TextEditingController();
  String city = "Bandırma";
  String _bgImg = 'assets/images/clear.jpg';
  String _iconImg = 'assets/icons/Clear.png';
  String _cityName = '';

  @override
  Widget build(BuildContext context) {
    var ekranBilgisi = MediaQuery.of(context);
    var genislik = ekranBilgisi.size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Dinamik arka plan resmi
          Image.asset(
            _bgImg,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Şehir adı girişi için TextField
                  TextField(
                    controller: _controller,
                    onChanged: (value) {
                      setState(() {
                        city = value;
                      });
                    },
                    decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.black26,
                      hintText: "Konumu Girin",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on),
                      Text(
                        city,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Use FutureBuilder to fetch the weather data asynchronously
                  FutureBuilder<Map<String, dynamic>>(
                    future: fetchWeatherData(city), // Pass the city name to the fetch method
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData) {
                        return Center(child: Text('No data found'));
                      } else {
                        var data = snapshot.data!; // Access the weather data here

                        // Update the background image and icon based on weather data
                        if (data["calculatedTemperature"] > 20 && data["pressure"] < 1000) {
                          _bgImg = 'assets/images/clear.jpg';
                          _iconImg = 'assets/icons/Clear.png';
                        } else if (data["calculatedTemperature"] < 15 && data["pressure"] > 1000) {
                          _bgImg = 'assets/images/clouds.jpg';
                          _iconImg = 'assets/icons/Clouds.png';
                        } else if (data["calculatedTemperature"] < 10 && data["pressure"] > 1000) {
                          _bgImg = 'assets/images/rain.jpg';
                          _iconImg = 'assets/icons/Rain.png';
                        } else if (data["calculatedTemperature"] > 10 && data["pressure"] < 20) {
                          _bgImg = 'assets/images/fog.jpg';
                          _iconImg = 'assets/icons/Haze.png';
                        } else {
                          _bgImg = 'assets/images/haze.jpg';
                          _iconImg = 'assets/icons/Haze.png';
                        }

                        return Column(
                          children: [
                            Text(
                              "${data["calculatedTemperature"].toStringAsFixed(2)} °C",
                              style: const TextStyle(
                                  color: Colors.black38,
                                  fontSize: 90,
                                  fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: genislik / 1.349,
                                  child: Image.asset(_iconImg),
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),
                            Card(
                              elevation: 5,
                              color: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  children: [
                                    // Nem bilgisi
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Nem",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 20),
                                        ),
                                        Text(
                                          data["humidity"].toString(),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                    // Yağış ve Rüzgar Hızı bilgileri
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            const Text("Yağış",
                                                style: TextStyle(
                                                    color: Colors.white, fontSize: 18)),
                                            Text(
                                              data["pressure"].toString(),
                                              style: const TextStyle(
                                                  color: Colors.white, fontSize: 16),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            const Text("Rüzgar Hızı",
                                                style: TextStyle(
                                                    color: Colors.white, fontSize: 18)),
                                            Text(
                                              data["windSpeed"].toString(),
                                              style: const TextStyle(
                                                  color: Colors.white, fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> fetchWeatherData(String cityName) async {
    try {
      final weatherData = await fetchWeatherForToday(cityName);
      final lastYearTemp = await fetchWeatherForLastYear(cityName);

      final double calculatedTemperature = calculateTemperature(
        currentHumidity: weatherData['humidity']!,
        currentWindSpeed: weatherData['windSpeed']!,
        currentPressure: weatherData['pressure']!,
        lastYearTemp: lastYearTemp["Ortalama"]!,
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
        throw Exception('$cityName verisiii JSON dosyasında bulunamadı.');
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
}
