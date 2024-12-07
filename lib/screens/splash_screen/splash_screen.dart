import 'package:flutter/material.dart';
import 'package:weather_app/screens/anasayfa/anasayfa.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const WeatherApp()));
    });

    return Scaffold(
      body: Center(
        child: Container(
          decoration:const  BoxDecoration(
            image:DecorationImage(
              image: AssetImage("assets/images/splash.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
