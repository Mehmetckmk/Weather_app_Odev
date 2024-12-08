import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../fullscreen/fullscreenImage.dart'; // Lottie kaldırıldı çünkü kullanılmıyor

class OneriScreen extends StatefulWidget {
  final double? Sicaklik;
  final double? Nem;
  final double? Yagis;

  OneriScreen(
      {super.key,
      required this.Sicaklik,
      required this.Nem,
      required this.Yagis});

  @override
  State<OneriScreen> createState() => _OneriScreenState();
}

class _OneriScreenState extends State<OneriScreen> {
  // Fotoğraf listesini nullable olmayacak şekilde tanımlıyoruz.
  final List<String> photos =
      List.generate(10, (index) => "assets/images/giyim/kıs${index + 1}.jpg");
  final List<String> photosyaz =
      List.generate(10, (index) => "assets/images/giyim/yaz${index + 1}.jpg");

  @override
  Widget build(BuildContext context) {
    var genislik=MediaQuery.of(context).size.width;
    // Şartlara göre gösterilecek fotoğraf listesini seçiyoruz.
    final List<String> selectedPhotos =
        (widget.Sicaklik! < 15 && widget.Nem! > 60 && widget.Yagis! > 1000)
            ? photos
            : photosyaz;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: genislik-50,
                    height: 70,
                    child: Image.asset("assets/images/logo/logoyatay.png",))
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          "Hava Sıcaklığı: " +
                              widget.Sicaklik!.toStringAsFixed(2) +
                              "°C",
                          style: GoogleFonts.getFont(
                            "Montserrat",
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50,),
                  widget.Yagis! > 1000
                      ? const Row(
                          children: [
                            Expanded(
                                child: Text(
                              "HAVA YAĞIŞLI OLABİLİR YAĞIŞ İHTİMALİ YÜKSEK",
                                  textAlign: TextAlign.center,
                            ))
                          ],
                        )
                      : const SizedBox(),
                ],
              ),
            ),
            const SizedBox(
              height: 100,
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Text(
                    "Giyim Önerileri",
                    style: GoogleFonts.getFont(
                      "Montserrat",
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: selectedPhotos.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenImage(
                                  imagePaths: selectedPhotos,
                                  initialIndex: index,
                                  tag: 'imageHero$index',
                                ),
                              ),
                            );
                          },
                          child: Hero(
                            tag: 'imageHero$index',
                            child: Container(
                              width: 140,
                              padding: const EdgeInsets.all(20),
                              margin: const EdgeInsets.only(left: 15),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                  colorFilter: const ColorFilter.mode(
                                      Colors.white, BlendMode.colorBurn),
                                  fit: BoxFit.cover,
                                  image: AssetImage(
                                    selectedPhotos[index],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
