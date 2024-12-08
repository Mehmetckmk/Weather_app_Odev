import 'package:flutter/material.dart';

class WeatherDataTile extends StatelessWidget {
  final String index1,index2,value1,value2;
  WeatherDataTile({
    required this.index1,
    required this.index2,
    required this.value1,
    required this.value2
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(index1,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 20),),
            Text(index2,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 20),),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(value1,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w300,fontSize: 18),),
            Text(value2,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w300,fontSize: 18),),
          ],
        ),
      ],
    );
  }
}
