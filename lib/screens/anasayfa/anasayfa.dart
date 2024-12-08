import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/screens/giyim_screen/giyim_karsila.dart';


class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  final TextEditingController _controller = TextEditingController();
  String city = ""; // Varsayılan şehir
  String _bgImg = 'assets/images/clear.jpg'; // Varsayılan arka plan resmi
  String _iconImg = 'assets/icons/Clear.png'; // Varsayılan ikon resmi
  bool isLoading = true; // Yükleme durumunu kontrol eden değişken

  @override
  void initState() {
    super.initState();
    _loadWeatherData(city); // İlk başta varsayılan şehir için veriyi yükle
  }

  void _loadWeatherData(String cityName) async {
    setState(() {
      isLoading = true; // Veriyi yüklerken loading durumunu aktif et
    });

    try {
      await fetchWeatherData(cityName); // Hava durumu verisini yükle
    } catch (e) {
      print('Hata: $e'); // Hata durumunu logla
    } finally {
      setState(() {
        isLoading = false; // Veri yüklendikten sonra loading durumunu pasif et
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var ekranBilgisi = MediaQuery.of(context); // Ekran boyutlarına erişim
    var genislik = ekranBilgisi.size.width; // Ekranın genişliği

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: genislik-50,
                          height: 70,
                          child: Image.asset("assets/images/logo/logoyatay.png",))
                    ],
                  ),
                  // Şehir adı girişi için TextField
                  TextField(
                    controller: _controller,
                    onChanged: (value) {
                      // Boşluk kontrolü yap ve gereksiz boşlukları temizle
                      final cleanedValue = value.replaceAll(RegExp(r'\s+'), ' ').trim();

                      setState(() {
                        city = cleanedValue.toLowerCase(); // Küçük harfe çevir
                      });

                      _loadWeatherData(city); // Yeni şehir için veriyi yükle
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
                  const SizedBox(height: 10),
                  // CircularProgressIndicator veya Hava Durumu Verisi
                  isLoading
                      ? const Center(child: CircularProgressIndicator()) // Yükleme göstergesi
                      : FutureBuilder<Map<String, dynamic>>(
                    future: fetchWeatherData(city),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Veriler yüklenirken yükleme göstergesi
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        // Hata durumunda kullanıcı dostu mesaj
                        return const Center(child: Text('Lütfen İl Giriniz.'));
                      } else if (!snapshot.hasData) {
                        // Eğer veri yoksa
                        return const Center(child: Text('Şehir verisi bulunamadı.'));
                      } else {
                        var data = snapshot.data!;

                        // Hava durumu verilerine göre arka plan ve ikon güncellemesi
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
                              "${data["calculatedTemperature"].toStringAsFixed(2)}°C",
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
                            const SizedBox(height:70,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) =>  GiyimKarsila(Sicaklik: data["calculatedTemperature"],Nem: data["humidity"], Yagis: data["pressure"],)),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    backgroundColor: Colors.white24,
                                  ),
                                  child: Text(
                                    "Bugün Ne Giyeceğim?",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              ],
                            )
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

    const double humidityFactor = 0.04;
    const double windSpeedFactor = 0.2;
    const double pressureFactor = 0.02;

    double temperatureEstimate = (currentHumidity * humidityFactor) +
        (currentWindSpeed * windSpeedFactor) +
        (currentPressure * pressureFactor);

    return (temperatureEstimate + lastYearTemp) / 3;
  }

  Future<Map<String, double>> fetchWeatherForToday(String cityName) async {
    try {
      // Bugünün tarihini al ve formatla (d.M.yyyy)
      final today = DateFormat('d.M.yyyy').format(DateTime.now());

      // JSON dosyasını oku
      final contents = await rootBundle.loadString('assets/data/now_city_three.json');

      // JSON verisini parse et
      final data = jsonDecode(contents);

      // Şehir ve tarih verilerini kntrol et
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