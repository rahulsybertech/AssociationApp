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
      '',
      message,
      backgroundColor: backgroundColor,
      titleText:
          titleText != null
              ? Text(
                titleText,
                style: TextStyle(
                  color: whiteColor,
                  fontWeight: FontWeight.bold,
                ),
              )
              : SizedBox.shrink(),
      dismissDirection: DismissDirection.horizontal,
      colorText: whiteColor,
    );
  }
}
