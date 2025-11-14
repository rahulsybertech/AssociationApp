

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:newapp/controllers/splashController.dart';

class demoScreen extends StatefulWidget {
  const demoScreen({super.key});

  @override
  State<demoScreen> createState() => _StartScreenState();
}
class _StartScreenState extends State<demoScreen> {
  final SplashController controller = Get.put(SplashController());

  final box = GetStorage();

  @override
  void initState() {
    super.initState();
  //  _checkToken();

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
              Image.asset(
                'assets/icons/app_icon.png',
                height: 250,
                width: 250,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),

              // Play Now Button
              /*   ElevatedButton(
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
                  text: 'Start Now',
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  textColor: Colors.white,
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }


}