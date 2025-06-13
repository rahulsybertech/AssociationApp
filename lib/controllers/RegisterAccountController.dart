import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:newapp/utils/CrossPlatformImagePicker.dart';
import 'package:newapp/utils/ImagePickerScreen.dart';
import 'package:newapp/utils/utils.dart';

class RegisterAccountController extends GetxController {
  var isDataLoading = false.obs;
  var selectedPartyType = 'Customer'.obs;

  final firmNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final mobileController = TextEditingController();
  final gstController = TextEditingController();
  final categoryController = TextEditingController();
  final addressController = TextEditingController();
  final stationNameController = TextEditingController();
  RxString imagePath = ''.obs;
  var selectedCategory = ''.obs;
  var accountImage = Rx<File?>(null);
  var shopImage = Rx<File?>(null);


  void setPartyType(String type) {
    selectedPartyType.value = type;
  }


  Future<bool> saveUpdateAccountDetails({
    String? accountType,
    required String accountName,
    required String ownerName,
    required String mobileNo,
    required String address,
    required String station,
    required String stateName,
    required String gstNo,
    required String deviceID,
    required String accountImagePath,
    required String shopImagePath,
  }) async
  {
    isDataLoading.value = true;

    final url = Uri.parse('https://association.ssspltd.com/api/Account/SaveUpdateAccountDetails');

    final box = GetStorage();
    String? token = box.read('token');
    String? accountCate = box.read('accountType');

    final headers = {
      'accept': '*/*',
      'Authorization': 'Bearer $token ',
      'Content-Type': 'application/json',
    };
    String? image = accountImagePath.isEmpty ? null : accountImagePath;

    final body = jsonEncode({
      "id": 0,
      "accountType": accountType,
      "accountCategory": accountCate,
      "accountName": accountName,
      "ownerName": ownerName,
      "mobileNo": mobileNo,
      "address": address,
      "station": station,
      "stateName": stateName,
      "gstNo": gstNo,
      "deviceID": deviceID,

      "accountImagePath": image,
      "shopImagePath": image,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        if (data['success'] == true) {
          clearFormFields();
          showSnackBar("Account saved successfully.");
          return true;
        } else {
          showSnackBar(data['message'] ?? "Something went wrong.");
        }
      } else {
        showSnackBar("Failed: ${response.statusCode}");
      }
    } catch (e) {
      showSnackBar("Error: $e");
    } finally {
      isDataLoading.value = false;
    }

    return false;
  }




  void setImagePath(String path) {
    imagePath.value = path;
    print("Received image path: $path");
  }
  void uploadImage() {
    // Handle image upload
    final ImagePickerController imagePickerController = Get.put(ImagePickerController());
    ImagePickerScreen();

  }
  Future<bool> validation(String? imageFile, String? accountType) async {
    final ownerName = ownerNameController.text.trim();
    final mobile = mobileController.text.trim();
    final address = addressController.text.trim();
    final category = categoryController.text.trim();
    final firmName = firmNameController.text.trim();
    final gst = gstController.text.trim();

    // 1. Check owner name
    if (ownerName.isEmpty) {
      showSnackBar('Enter owner name');
      return false;
    }

    // 2. Now check mobile number (after owner name)
    if (mobile.isEmpty || mobile.length < 8 || mobile.length > 10 || !RegExp(r'^\d{8,10}$').hasMatch(mobile)) {
      showSnackBar('Mobile number must be 8 to 10 digits');
      return false;
    }

    // 3. Continue other required field checks
    if (address.isEmpty) {
      showSnackBar('Enter address');
      return false;
    }

    if (accountType == "Others") {
      if (category.isEmpty) {
        showSnackBar('Enter category');
        return false;
      }
    }


    if (accountType == "Customer") {
      if (firmName.isEmpty) {
        showSnackBar('Enter Name');
        return false;
      }

  /*    if (gst.isEmpty) {
        showSnackBar('Enter GST number');
        return false;
      }

      if (gst.length < 15) {
        showSnackBar('GST number must be at least 15 characters');
        return false;
      }*/
    }

    String imagefileNew="";
    // Validate image
    if (imageFile == null || imageFile.isEmpty) {
      imagefileNew="";
    }else{
      imagefileNew=imageFile;
    }


    // All checks passed → save
    return await saveUpdateAccountDetails(
      accountType: accountType,
      accountName: firmName,
      ownerName: ownerName,
      mobileNo: mobile,
      address: address,
      station: stationNameController.text.trim(),
      stateName: stationNameController.text.trim(),
      gstNo: gst,
      deviceID: 'YOUR_DEVICE_ID',
      accountImagePath: imagefileNew!!,
      shopImagePath: imagefileNew,
    );
  }






  @override
  void onClose() {
    firmNameController.dispose();
    ownerNameController.dispose();
    mobileController.dispose();
    gstController.dispose();
    addressController.dispose();
    super.onClose();
  }

  void clearFormFields() {
    firmNameController.clear();
    ownerNameController.clear();
    mobileController.clear();
    addressController.clear();
    categoryController.clear();
/*    stationController.clear();
    stateNameController.clear();*/
    gstController.clear();
    // Clear image paths if needed
    /*accountImagePath.value = '';
    shopImagePath.value = '';*/
  }

}
