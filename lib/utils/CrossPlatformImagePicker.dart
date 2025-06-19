import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  Rx<File?> pickedImage = Rx<File?>(null);
  Rx<File?> shopImage = Rx<File?>(null);

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        pickedImage.value = File(pickedFile.path);
        print('Picked image path: ${pickedFile.path}');
      }
    } catch (e) {
      print('Image picking failed: $e');
    }
  }
  Future<void> pickImage2(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        shopImage.value = File(pickedFile.path);
        print('Picked image path: ${pickedFile.path}');
      }
    } catch (e) {
      print('Image picking failed: $e');
    }
  }

  Future<void> pickImage3(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        final file = File(pickedFile.path);

        final decodedImage = await decodeImageFromList(file.readAsBytesSync());

        // 🔴 Add size validation: Minimum 800x400 pixels
        if (decodedImage.width < 500 || decodedImage.height < 300) {
          Get.snackbar(
            'Invalid Banner Size',
            'Minimum size should be 500x300 pixels',
            backgroundColor: Colors.red.shade100,
            colorText: Colors.black,
          );
          return;
        }

        pickedImage.value = file;
      }
    } on PlatformException catch (e) {
      Get.snackbar('Error', e.message ?? 'Unknown error');
    }
  }

  String? get imagePath => pickedImage.value?.path;
  String? get imagePath2 => shopImage.value?.path;
}

