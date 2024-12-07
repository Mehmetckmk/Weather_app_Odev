import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_app/screens/anasayfa/anasayfa.dart';
import 'package:weather_app/screens/giyim_screen/%C3%B6neri_Screen.dart';
import 'package:weather_app/screens/giyim_screen/giyim_karsila.dart';
import 'package:weather_app/screens/splash_screen/splash_screen.dart';
import 'package:weather_app/services/algoritmic_weather_services.dart';

void main() {
  runApp(const MyApp());
  //Ekranı odaklayıp durum çubuklarını gizleme
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // Sistem çubuklarının arka plan rengini ve ikon rengini ayarla
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    // Durum çubuğunu şeffaf yap
    statusBarColor: Colors.transparent,
    // Durum çubuğu ikonlarını beyaz yap
    statusBarIconBrightness: Brightness.light,
    // Alt çubuğu şeffaf yap
    systemNavigationBarColor: Colors.transparent,
    // Alt çubuk ikonlarını beyaz yap
    systemNavigationBarIconBrightness: Brightness.light,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Splash (),
    );
  }
}
