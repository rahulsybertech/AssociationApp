import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'appcolors.dart';


showSnackBar(
    String message, {
      Color backgroundColor = redColor,
      String? titleText,
    }) {
  if (!Get.isSnackbarOpen) {
    Get.snackbar(
      '', // Optional title
      message,
      backgroundColor: backgroundColor,
      colorText: whiteColor,
      snackPosition: SnackPosition.BOTTOM, // ✅ Snackbar will show at bottom
      margin: const EdgeInsets.all(12),     // Optional spacing from screen edges
      duration: const Duration(seconds: 1),
      dismissDirection: DismissDirection.horizontal,
      titleText: titleText != null
          ? Text(
        titleText,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      )
          : null,
    );
  }
}




