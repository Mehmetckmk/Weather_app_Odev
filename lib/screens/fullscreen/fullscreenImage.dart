import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final List<dynamic> imagePaths; // orijinal tür dynamic
  final int initialIndex;
  final String tag;

  const FullScreenImage({super.key,
    required this.imagePaths,
    required this.initialIndex,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    // List<String> türüne dönüştürme
    List<String> stringImagePaths = imagePaths.cast<String>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: stringImagePaths.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Center(
              child: Hero(
                tag: 'imageHero$index',
                child: Image.asset(stringImagePaths[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
