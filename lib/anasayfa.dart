import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/services/weather_services.dart';
import 'package:weather_app/widget/weather_data.dart';

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  final TextEditingController _controller = TextEditingController();
  String _bgImg = 'assets/images/clear.jpg';
  String _iconImg = 'assets/icons/Clear.png';
  String _cityName = '';
  String _temperature = '';
  String _sunrise = '';
  String _sunset = '';
  String _main = '';
  String _presure = '';
  String _humidity = '';
  String _visibility = '';
  String _windSpeed = '';

  getData(String cityName) async {
    final weatherService = WeatherServices();
    var weatherData;
    if (cityName == '')
      weatherData = await weatherService.fetchWeather();
    else
      weatherData = await weatherService.getWeather(cityName);

    debugPrint(weatherData.toString());
    setState(() {
      _cityName = weatherData['name'];
      _temperature = weatherData['main']['temp'].toStringAsFixed(1);
      _main = weatherData['weather'][0]['main'];
      _sunrise = DateFormat('hh:mm a').format(
          DateTime.fromMillisecondsSinceEpoch(
              weatherData['sys']['sunrise'] * 1000));
      _sunset = DateFormat('hh:mm a').format(
          DateTime.fromMillisecondsSinceEpoch(
              weatherData['sys']['sunset'] * 1000));
      _presure = weatherData['main']['pressure'].toString();
      _humidity = weatherData['main']['humidity'].toString();
      _visibility = weatherData['visibility'].toString();
      _windSpeed = weatherData['wind']['speed'].toString();
      if (_main == 'Clear') {
        _bgImg = 'assets/images/clear.jpg';
        _iconImg = 'assets/icons/Clear.png';
      } else if (_main == 'Clouds') {
        _bgImg = 'assets/images/clouds.jpg';
        _iconImg = 'assets/icons/Clouds.png';
      } else if (_main == 'Rain') {
        _bgImg = 'assets/images/rain.jpg';
        _iconImg = 'assets/icons/Rain.png';
      } else if (_main == 'Fog') {
        _bgImg = 'assets/images/fog.jpg';
        _iconImg = 'assets/icons/Haze.png';
      } else if (_main == 'Thunderstorm') {
        _bgImg = 'assets/images/thunderstorm.jpg';
        _iconImg = 'assets/icons/Thunderstorm.png';
      } else {
        _bgImg = 'assets/images/haze.jpg';
        _iconImg = 'assets/icons/Haze.png';
      }
    });
  }

  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
      getData('');
    }
    getData('');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    var ekranbilgisi=MediaQuery.of(context);
    var genislik=ekranbilgisi.size.width;
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(_bgImg,
            fit: BoxFit.cover,
            width:double.infinity,
            height: double.infinity,
          ),
          Padding(padding: const EdgeInsets.all(15),
            child:SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20,),
                  TextField(
                    controller: _controller,
                    onChanged: (value){
                      getData(value);
                    },
                    decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.black26,
                      hintText: "Konumu Girin",
                      border: OutlineInputBorder(
                        borderRadius:BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on),
                      Text(_cityName,style: const TextStyle(fontSize: 20,fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 40,),
                  Text("$_temperature C",style: const TextStyle(color: Colors.black38,fontSize: 90,fontWeight: FontWeight.bold),),
                  Row(
                    children: [
                      Text(_main,style: const TextStyle(fontSize: 22,fontWeight: FontWeight.w500),),
                      SizedBox(width: genislik/1.349,
                          child: Image.asset(_iconImg)),
                    ],
                  ),
                  const SizedBox(height: 25,),
                  Card(
                    elevation: 5,
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        child: Column(
                          children: [
                            WeatherDataTile(index1: "Gün Doğumu", index2: "Gün Batımı", value1: _sunrise, value2: _sunset),
                            const SizedBox(height: 15,),
                            WeatherDataTile(index1: "Nem", index2: "Görüş Mesafesi", value1:_humidity, value2: _visibility),
                            const SizedBox(height: 15,),
                            WeatherDataTile(index1: "Yağış", index2: "Rüzgar Hızı", value1: _presure, value2: _windSpeed),
                            const SizedBox(height: 15,),
                          ]
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}