import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:newapp/controllers/HomeController.dart';
import 'package:newapp/model/ApiResponse.dart';
import 'package:newapp/model/BannerItem.dart';
import 'package:newapp/network/api.dart';
import 'package:newapp/utils/CrossPlatformImagePicker.dart';
import 'package:newapp/utils/utils.dart';
import 'package:path_provider/path_provider.dart';

class BannerScreenController extends GetxController {
  var isDataLoading = false.obs;
  var isUploading = false.obs;
  var selectedPartyType = 'Customer'.obs;
  var id = '0'.obs;
  var base64Image = RxnString(); // allows null


  RxString imagePath = ''.obs;
  var accountImage = Rx<File?>(null);
  var shopImage = Rx<File?>(null);
  var bannerList = <BannerItem>[].obs;
  final HomeController controller = Get.put(HomeController());

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
      await apiService.addUpdateBanner(id.toString(),base64Image.value.toString(), token!);
      id.value="0";
      getBannerList();
      isUploading.value = false;
      if (model != null) {
        controller.getBannerList();
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
        bannerList.value = mcqs
            .map((e) => BannerItem.fromJson(e))
            .take(5) // This limits the list to the first 5 items
            .toList();
      } else {
        bannerList.clear();
        showSnackBar('No records found.');
      }
    } catch (e) {
      isDataLoading.value = false;
      showSnackBar('Failed to fetch data: $e');
    }
  }
  Future<void> deleteBannerReq(String id) async {
    isDataLoading.value = true;
    final APIService apiService = APIService();
    final box = GetStorage();
    String? token = box.read('token');

    try {
      final result = await apiService.deleteBanner(id, token!);
      isDataLoading.value = false;

      if (result != null && result.isNotEmpty) {
        showSnackBar('Banner deleted successfully.');

        controller.bannerList();

        // Optionally, refresh list
        await getBannerList();
      } else {
        showSnackBar('No response from server.');
      }
    } catch (e) {
      isDataLoading.value = false;
      showSnackBar('Failed to delete banner: $e');
    }
  }



  void deleteBanner(String id) {
    bannerList.removeWhere((item) => item.id == id);
    bannerList.refresh(); // RxList update
    deleteBannerReq(id);

  }
  void editBanner(
      BannerItem banner,
      ImagePickerController imageController,
      GlobalKey imageKey,
      ScrollController scrollController,
      ) async {
    final file = await downloadImageToFile(banner.bannerImagePath.toString());

    if (file != null) {
      imageController.pickedImage.value = file;
      base64Image.value=banner.bannerImagePath;


      // Wait for the UI to update
      await Future.delayed(Duration(milliseconds: 100));

      // Scroll to the image preview
      final context = imageKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.1, // slightly above
        );
      }
      int someId = banner.id!;
      id.value = someId.toString();

    }
  }

  Future<File?> downloadImageToFile(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.png');
        return await file.writeAsBytes(response.bodyBytes);
      }
    } catch (e) {
      print("Download failed: $e");
    }
    return null;
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
