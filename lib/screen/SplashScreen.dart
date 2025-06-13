import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../customWidgets/customText.dart';
import '../routes.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// Assuming you have this CustomText widget somewhere
class CustomText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color textColor;

  const CustomText({
    super.key,
    required this.text,
    required this.fontSize,
    required this.fontWeight,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: textColor),
    );
  }
}

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  void _checkToken() async {
    // Simulate a small delay (optional)
    await Future.delayed(const Duration(seconds: 1));

    String? token = box.read('token');

    if (token != null && token.isNotEmpty) {
      // Token exists, navigate to home screen
      // Replace with your actual home route or screen widget
      Get.offNamed(RouteConstant.homeScreen);
    }else{
      Get.offNamed(RouteConstant.loginScreen);
    }

    // else do nothing and stay on this screen (show Play Now button)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FlutterLogo(size: 100),
              const SizedBox(height: 24),

              // Play Now Button
              ElevatedButton(
                onPressed: () {
                  Get.toNamed(RouteConstant.loginScreen);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const CustomText(
                  text: 'Play Now',
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

