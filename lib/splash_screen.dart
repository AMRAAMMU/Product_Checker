// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, use_key_in_widget_constructors, library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:calibre_product_checker/change.dart';
import 'package:calibre_product_checker/product_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Timer _countdownTimer;

  @override
  void initState() {
    super.initState();

    _countdownTimer = Timer(Duration(seconds: 7), () {
      loadControllerValuesAndNavigate();
    });
  }

  void loadControllerValuesAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final apiUrl = prefs.getString('apiUrl') ?? '';
    final appBarText = prefs.getString('appBarText') ?? '';
    final currencyDetails = prefs.getString('currencyDetails') ?? '';

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ProductChecker(
          apiUrl: apiUrl,
          appBarText: appBarText,
          currencyDetails: currencyDetails,
        ),
      ),
    );
  }

  void _onArrowIconPressed() {
    _countdownTimer.cancel();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => Change()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/img12.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: IconButton(
              icon: Icon(
                Icons.arrow_circle_right_outlined,
                size: 53,
                color: Colors.white,
              ),
              onPressed: _onArrowIconPressed,
            ),
          ),
        ],
      ),
    );
  }
}
