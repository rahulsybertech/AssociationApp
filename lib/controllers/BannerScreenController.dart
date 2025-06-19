import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:newapp/model/ApiResponse.dart';
import 'package:newapp/model/BannerItem.dart';
import 'package:newapp/network/api.dart';
import 'package:newapp/utils/utils.dart';

class BannerScreenController extends GetxController {
  var isDataLoading = false.obs;
  var isUploading = false.obs;
  var selectedPartyType = 'Customer'.obs;
  var base64Image = RxnString(); // allows null

  RxString imagePath = ''.obs;
  var accountImage = Rx<File?>(null);
  var shopImage = Rx<File?>(null);
  var bannerList = <BannerItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    getBannerList();
  }

  Future<void> bannerAddUpdateReq() async {


    final APIService apiService = APIService();
    final box = GetStorage();
    String? token = box.read('token');
    if (base64Image.value == null) {
      Get.snackbar('Error', 'Please select an image first');
      return;
    }
    isUploading.value = true;
    try {
      final ApiResponse? model =
      await apiService.addUpdateBanner(base64Image.value.toString(), token!);

      isUploading.value = false;


      if (model != null) {

        showSnackBar(model.message);

      } else {
        showSnackBar('No records found.');
      }
    } catch (e) {
      isDataLoading.value = false;
      isUploading.value = false;
      showSnackBar('Failed to fetch data: $e');
    }
  }

  Future<void> getBannerList() async {
    isDataLoading.value = true;

    final APIService apiService = APIService();
    final box = GetStorage();
    String? token = box.read('token');


    try {
      final List<Map<String, dynamic>>? mcqs =
      await apiService.bannerList(token!);

      isDataLoading.value = false;
      if (mcqs != null && mcqs.isNotEmpty) {
        bannerList.value = mcqs.map((e) => BannerItem.fromJson(e)).toList();
      } else {
        bannerList.clear(); // optional: clear if no data
        showSnackBar('No records found.');
      }
    } catch (e) {
      isDataLoading.value = false;
      showSnackBar('Failed to fetch data: $e');
    }
  }

  @override
  void dispose() {
    Get.delete<BannerScreenController>();
    super.dispose();
  }

  void clearImage() {
    base64Image.value = null;
  }
}
