import 'dart:io';

import 'package:flutter/material.dart';
import 'HomePageWidget.dart';

void main() {
  runApp(MyApp());
  HttpOverrides.global = new MyHttpOverrides();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: HomePageWidget(showSplashScreen: true,),
    );
  }
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

