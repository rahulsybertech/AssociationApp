import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class BannerScreenController extends GetxController {
  var isDataLoading = false.obs;
  var selectedPartyType = 'Customer'.obs;
  var base64Image = RxnString(); // allows null


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

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void dispose() {
    Get.delete<BannerScreenController>();
    super.dispose();
  }
}
