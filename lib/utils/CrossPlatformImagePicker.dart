import 'dart:io';
import 'package:flutter/material.dart';
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

  String? get imagePath => pickedImage.value?.path;
  String? get imagePath2 => shopImage.value?.path;
}

