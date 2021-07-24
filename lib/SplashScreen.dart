import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class splashScreen extends StatefulWidget {
  const splashScreen({Key key}) : super(key: key);

  @override
  _splashScreenState createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Image.asset("assets/home_image.png",width: double.infinity,height: double.infinity, fit: BoxFit.cover,),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeInImage(placeholder: MemoryImage(kTransparentImage), image:AssetImage("assets/logo_flutterMet_white.png") )
              ],
            ),
          )
        ],
      ),
    );
  }
}
