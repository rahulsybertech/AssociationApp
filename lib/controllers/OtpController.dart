import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

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
