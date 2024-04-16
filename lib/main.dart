// ignore_for_file: prefer_const_constructors, deprecated_member_use, unused_import

import 'package:calibre_product_checker/product_checker.dart';
import 'package:calibre_product_checker/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.yellow,
          textTheme: TextTheme(
            subtitle1: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          ),
        ),
        home: SplashScreen());
  }
}
