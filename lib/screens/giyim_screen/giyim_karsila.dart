import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/screens/giyim_screen/%C3%B6neri_Screen.dart';

class GiyimKarsila extends StatelessWidget {
  const GiyimKarsila({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const OneriScreen()));
    });
    return Scaffold(
      backgroundColor: Colors.white, // Arka plan rengini beyaz yapar
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white, // Container'ın da arka planı beyaz
              ),
              child: Image.asset(
                'assets/images/giyim/giyim_karsilama.png',
                width: 300,
                height: 300,
                fit: BoxFit.contain, // Görselin sığdırılma şeklini belirler
              ),
            ),
            Text("Giyim üzerinde Çalışılıyor...",
            style: TextStyle(
              fontSize: 20,
              fontFamily: GoogleFonts.poppins().fontFamily,
              color: Colors.black,
              fontWeight: FontWeight.bold
            ),),
          ],
        ),
      ),
    );
  }
}
