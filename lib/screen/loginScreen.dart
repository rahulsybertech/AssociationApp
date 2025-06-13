



import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:newapp/controllers/LoginController.dart';
import 'package:newapp/utils/utils.dart';

import '../controllers/categoryController.dart';
import '../customWidgets/customLoader.dart';
import '../customWidgets/customText.dart';
import '../routes.dart';
import '../utils/appcolors.dart';

class loginScreen extends StatelessWidget {
  const loginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final Logincontroller controller = Get.put(Logincontroller());
    final TextEditingController mobileController = TextEditingController();
    return Obx(
          () => Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 150),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/icons/app_icon.png',
                  width: 100,
                  height: 100,
                ),
              ),
              const CustomText(
                text: 'Garment Association',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                textColor: redColor2,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: mobileController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: "Enter your Mobile Number",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  final number = mobileController.text.trim();
                  if (number.isNotEmpty && number.length == 10) {
                    controller.login(number);
                  } else {
                    showSnackBar('Enter valid mobile number');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: controller.isDataLoading.value
                    ? const Loader(color: purpleColor)
                    : const CustomText(
                  text: 'Send OTP',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  textColor: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  // Your skip logic
                },
                child: Text(
                  'Skip Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.redAccent,
                  ),
                ),
              )
              // Other UI...
            ],
          ),
        ),
      ),
    );
  }
}




void showOtpBottomSheet(BuildContext context, {
  required String mobileNumber,
  required String otp,
}) {
  final TextEditingController otpController = TextEditingController();
  final Logincontroller controller = Get.put(Logincontroller());
  RxInt seconds = 60.obs;

  // Timer countdown
  Timer? timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (seconds.value > 0) {
      seconds.value--;
    } else {
      timer.cancel();
    }
  });

  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Enter 4-digit OTP", style: TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          TextField(
            controller: otpController,
            maxLength: 4,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "OTP",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Obx(() => Text("Resend in ${seconds.value}s")),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (otpController.text == otp) {
                Get.back(); // close bottom sheet
                controller.verifyOTPDetails(mobileNumber,otpController.text);
                showSnackBar('OTP Verified');
          //      Get.toNamed(RouteConstant.homeScreen);

                // Proceed to next screen
              } else {
                showSnackBar('Invalid OTP');
              }
            },
            child: const Text("Verify OTP"),
          ),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}

void goNextScreen(BuildContext context, {required String otp}) {
  final TextEditingController otpController = TextEditingController();
  Get.toNamed(RouteConstant.homeScreen);
}


class OtpController extends GetxController {
  final otpController = TextEditingController();
  final isOtpValid = false.obs;
  final timerText = "01:00".obs;
  final isResendEnabled = false.obs;

  late Timer _timer;
  int _start = 60;

  void startTimer() {
    _start = 60;
    isResendEnabled.value = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        timer.cancel();
        isResendEnabled.value = true;
      } else {
        _start--;
        timerText.value = _formatTime(_start);
      }
    });
  }

  String _formatTime(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  void validateOtp() {
    if (otpController.text.trim().length == 4) {
      isOtpValid.value = true;
    } else {
      isOtpValid.value = false;
    }
  }

  void resendOtp() {
    otpController.clear();
    startTimer();
    Get.snackbar("OTP Sent", "A new OTP has been sent to your number");
  }

  @override
  void onClose() {
    otpController.dispose();
    _timer.cancel();
    super.onClose();
  }
}

