



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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Logincontroller controller = Get.put(Logincontroller());
  final TextEditingController mobileController = TextEditingController();

  @override
  void dispose() {
    mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Hide keyboard
      },
      child: Obx(
            () => Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/icons/app_icon.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 20),
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
                    maxLength: 10,
                    textInputAction: TextInputAction.done,
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
                        ? const Loader(color: Colors.white)
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
                      controller.callAccessWithoutLogin();
                    },
                    child: const Text(
                      'Continue without login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


void showOtpBottomSheet(BuildContext context, {
  required String mobileNumber,
  required String otp,
})
{
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

  final OtpController otpcontrollerNew = Get.put(OtpController());
  otpcontrollerNew.startOTPTimer(); // Start the timer before showing bottom sheet

  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Enter 4-digit OTP", style: TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          TextField(
            controller: otpcontrollerNew.otpController,
            maxLength: 4,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "OTP",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Obx(() => GestureDetector(
            onTap: otpcontrollerNew.isResendEnabled.value
                ? () => otpcontrollerNew.resendOtp(mobileNumber)
                : null,
            child: Text(
              otpcontrollerNew.timerText.value,
              style: TextStyle(
                color: otpcontrollerNew.isResendEnabled.value
                    ? Colors.blue
                    : Colors.grey,
                decoration: otpcontrollerNew.isResendEnabled.value
                    ? TextDecoration.underline
                    : null,
              ),
            ),
          )),
          const SizedBox(height: 20),
          Obx(() => ElevatedButton(
            onPressed: () {
              final enteredOtp = otpcontrollerNew.otpController.text.trim();

              if (enteredOtp.isEmpty) {
                showSnackBar('Please enter your OTP');
                return;
              }

              controller.verifyOTPDetails(
                mobileNumber,
                enteredOtp,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              textStyle: const TextStyle(fontSize: 18),
            ),
            child: controller.isVerifyOtp.value
                ? const Loader(color: Colors.white) // 👈 show loader
                : const CustomText(
              text: 'Verify OTP',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              textColor: Colors.white,
            ),
          ))


        ],
      ),
    ),
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
  );


}



void goNextScreen(BuildContext context, {required String otp}) {
  final TextEditingController otpController = TextEditingController();
  Get.toNamed(RouteConstant.homeScreen);
}


class OtpController extends GetxController {
  RxInt seconds = 60.obs;
  RxString timerText = "Resend in 60s".obs;
  RxBool isResendEnabled = false.obs;
  Timer? timer;

  TextEditingController otpController = TextEditingController();
  Logincontroller logincontroller = Logincontroller();

  void startOTPTimer() {
    seconds.value = 60;
    isResendEnabled.value = false;
    timerText.value = "Resend in 60s";

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds.value > 0) {
        seconds.value--;
        timerText.value = "Resend in ${seconds.value}s";
      } else {
        t.cancel();
        isResendEnabled.value = true;
        timerText.value = "Resend OTP";
      }
    });
  }

  Future<void> resendOtp(String mobileNumber) async {
    if (!isResendEnabled.value) return;

    isResendEnabled.value = false;
    timerText.value = "Sending OTP...";
    logincontroller.resendOtp(mobileNumber);
    // Call your actual resend OTP API here
    await Future.delayed(const Duration(seconds: 1)); // simulate delay


    startOTPTimer(); // Restart the timer
  }

  @override
  void onClose() {
    timer?.cancel();
    otpController.dispose();
    super.onClose();
  }
}

