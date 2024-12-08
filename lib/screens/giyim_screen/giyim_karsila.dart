import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/screens/giyim_screen/%C3%B6neri_Screen.dart';

class GiyimKarsila extends StatelessWidget {
  final double Sicaklik;
  final double Nem;
  final double Yagis;
  const GiyimKarsila({super.key,required this.Sicaklik,required this.Nem,required this.Yagis});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) =>  OneriScreen(Sicaklik:Sicaklik ,Nem: Nem,Yagis: Yagis,)));
    });
    var genislik=MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white, // Arka plan rengini beyaz yapar
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: genislik-50,
                    height: 100,
                    child: Image.asset("assets/images/logo/logoyatay.png",))
              ],
            ),
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
