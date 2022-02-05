import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarouselPage extends StatefulWidget {
  CarouselPage({Key? key}) : super(key: key);

  @override
  _CarouselPageState createState() => _CarouselPageState();
}

class _CarouselPageState extends State<CarouselPage> {
  
  final List<String> imgList = [
    'https://cdn.discordapp.com/attachments/641353198568996876/903690105007521832/unknown.png',
    'https://cdn.discordapp.com/attachments/641353198568996876/903691724042424330/unknown.png',
    'https://cdn.discordapp.com/attachments/641353198568996876/903691841529061436/unknown.png',
    'https://cdn.discordapp.com/attachments/641353198568996876/903693259187056700/unknown.png',
    'https://cdn.discordapp.com/attachments/641353198568996876/903692386545336341/unknown.png',
    'https://cdn.discordapp.com/attachments/641353198568996876/903692812581748756/unknown.png',
    'https://cdn.discordapp.com/attachments/641353198568996876/903688548169949184/unknown.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text('Fullscreen sliding carousel demo')),
      body: Builder(
        builder: (context) {
          final double height = MediaQuery.of(context).size.height;
          return CarouselSlider(
            options: CarouselOptions(
              height: height,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              // autoPlay: false,
            ),
            items: imgList
                .map((item) => Container(
                      child: Center(
                          child: Image.network(
                        item,
                        fit: BoxFit.cover,
                        height: height,
                      )),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}
