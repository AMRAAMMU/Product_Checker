import 'dart:async';
import 'dart:convert';
import 'package:calibre_product_checker/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

class ProductChecker extends StatefulWidget {
  final String appBarText;
  final String currencyDetails;
  final String apiUrl;

  ProductChecker({
    required this.appBarText,
    required this.currencyDetails,
    required this.apiUrl,
  });

  @override
  State<ProductChecker> createState() => _ProductCheckerState(
        appBarText: appBarText,
        currencyDetails: currencyDetails,
        apiUrl: apiUrl,
      );
}

class _ProductCheckerState extends State<ProductChecker> {
  final String appBarText;
  String currencyDetails;
  final String apiUrl;

  _ProductCheckerState({
    required this.appBarText,
    required this.currencyDetails,
    required this.apiUrl,
  });

  int currentImageIndex = 0;
  List<String> backgroundImages = [
    'assets/img1.jpg',
    'assets/img2.jpg',
    'assets/img3.webp',
    'assets/img4.jpg',
    'assets/img6.webp',
    'assets/img7.jpg',
  ];
  late Timer backgroundTimer;
  final PageController pageController = PageController();
  final TextEditingController textController = TextEditingController();
  Timer? popUpTimer;
  bool visibleContainer = false;
  Product? product = null;
  bool notFound = false;

  Future<Product?> fetchProductDetails(
      String apiUrl, String productCode) async {
    final response = await http
        .get(Uri.parse('$apiUrl/api/Sales/GetProductsFilter/$productCode'));
    if (response.statusCode == 200) {
      try {
        final List<dynamic> dataList = json.decode(response.body);
        if (dataList.isNotEmpty) {
          return Product.fromJson(dataList.first);
        } else {
          return null; // No product found
        }
      } catch (e) {
        print("Error parsing the response data: $e");
        return null;
      }
    } else {
      print("API request failed with status code: ${response.statusCode}");
      return null;
    }
  }

  void startBackgroundTimer() {
    backgroundTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          currentImageIndex = (currentImageIndex + 1) % backgroundImages.length;
          pageController.animateToPage(currentImageIndex,
              duration: Duration(seconds: 3), curve: Curves.ease);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startBackgroundTimer();
    loadPreferences();
  }

  @override
  void dispose() {
    backgroundTimer.cancel();
    popUpTimer?.cancel();
    pageController.dispose();
    textController.dispose();
    savePreferences();
    super.dispose();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currencyDetails =
          prefs.getString('currencyDetails') ?? widget.currencyDetails;
    });
  }

  Future<void> savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currencyDetails', currencyDetails);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.appBarText,
          style: TextStyle(
              fontSize: 40,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SplashScreen(),
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            itemCount: backgroundImages.length,
            onPageChanged: (index) {
              setState(() {
                currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(backgroundImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          Visibility(
            visible: visibleContainer,
            child: Center(
              child: Container(
                width: 550,
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (product != null)
                      Center(
                        child: Text(
                          "${product?.name}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 45,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    if (product != null)
                      Center(
                        child: Text(
                          "Price: ${currencyDetails}${product?.price.toStringAsFixed(2)}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 45,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: notFound,
            child: Center(
              child: Container(
                width: 500,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (product != null)
                      Center(
                        child: Text(
                          "No Product Found",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 45,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.white.withOpacity(0.4),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 11.0),
                child: SizedBox(
                  width: 600,
                  height: 50,
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: 'Product Code',
                      border: InputBorder.none,
                    ),
                    style: TextStyle(fontSize: 25),
                    textInputAction: TextInputAction.none,
                    autofocus: true,
                    onChanged: (text) async {
                      final apiUrl = widget.apiUrl;
                      var product = await fetchProductDetails(apiUrl, text);
                      if (product != null) {
                        visibleContainer = true;
                        notFound = false;
                        this.product = product;
                        textController.clear();
                        setState(() {});
                        popUpTimer = Timer(Duration(seconds: 5), () {
                          visibleContainer = false;
                          setState(() {});
                        });
                      } else {
                        visibleContainer = false;
                        notFound = true;
                        textController.clear();
                        setState(() {});
                        popUpTimer = Timer(Duration(seconds: 5), () {
                          notFound = false;
                          setState(() {});
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
