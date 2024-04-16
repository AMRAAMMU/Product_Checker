// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, unused_import

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:calibre_product_checker/product_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Product {
  final String name;
  final double price;

  Product({required this.name, required this.price});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      price: json['price'].toDouble(),
    );
  }
}

class Change extends StatefulWidget {
  const Change({Key? key}) : super(key: key);

  @override
  State<Change> createState() => _ChangeState();
}

class _ChangeState extends State<Change> {
  late TextEditingController apiUrlController;
  TextEditingController appBarController = TextEditingController();
  TextEditingController currencyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    apiUrlController = TextEditingController();
    loadStoredValues();
  }

  @override
  void dispose() {
    apiUrlController.dispose();
    appBarController.dispose();
    currencyController.dispose();
    super.dispose();
  }

  Future<void> loadStoredValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      apiUrlController.text = prefs.getString('apiUrl') ?? '';
      appBarController.text = prefs.getString('appBarText') ?? '';
      currencyController.text = prefs.getString('currencyDetails') ?? '';
    });
  }

  Future<void> saveValues() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('apiUrl', apiUrlController.text);
    prefs.setString('appBarText', appBarController.text);
    prefs.setString('currencyDetails', currencyController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/img11.jpg',
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                height: 300,
                width: 500,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.6),
                ),
                child: Column(
                  children: [
                    _buildCircularTextField("URL", apiUrlController, true),
                    _buildCircularTextField("App Bar", appBarController, false),
                    _buildCircularTextField(
                        "Currency Details", currencyController, false),
                    SizedBox(
                      height: 40,
                      width: 100,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                        ),
                        onPressed: () {
                          saveValues();

                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => ProductChecker(
                                appBarText: appBarController.text,
                                currencyDetails: currencyController.text,
                                apiUrl: apiUrlController.text,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "OK",
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularTextField(
      String label, TextEditingController controller, bool autoFocus) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        style: TextStyle(color: Colors.black),
        onChanged: (text) {
          saveValues();
        },
        autofocus: autoFocus,
        textInputAction: TextInputAction.none,
      ),
    );
  }
}
