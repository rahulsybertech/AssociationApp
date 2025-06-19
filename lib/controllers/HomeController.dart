import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:newapp/model/ApiResponse.dart';
import 'package:newapp/model/BannerItem.dart';
import 'package:newapp/network/api.dart';
import 'package:newapp/routes.dart';
import 'package:newapp/utils/utils.dart';

class HomeController extends GetxController {
  var currentPage = 0.obs;
  var isDataLoading = false.obs;
  var bannerList = <BannerItem>[].obs;
  late final PageController pageController;
  Timer? _timer;
  void updatePage(int index) {
    currentPage.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    getBannerList();
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

        if (bannerList.isNotEmpty) {
          startAutoSlide();
        }
      } else {
        bannerList.clear(); // optional: clear if no data
        showSnackBar('No records found.');
      }
    } catch (e) {
      isDataLoading.value = false;
      showSnackBar('Failed to fetch data: $e');
    }
  }
  void startAutoSlide() {
    _timer?.cancel();

    _timer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (bannerList.isEmpty || !pageController.hasClients) return;

      int nextPage = (pageController.page?.round() ?? 0) + 1;
      if (nextPage >= bannerList.length) nextPage = 0;

      pageController.animateToPage(
        nextPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> logOutParam() async {
    isDataLoading.value = true;

    final APIService apiService = APIService();
    final box = GetStorage();
    String? token = box.read('token');
    String? mobile = box.read('mobileNo');

    try {
      final ApiResponse? model = await apiService.logOut(mobile!, token!);
      isDataLoading.value = false;
      if (model != null) {
        showSnackBar(model.message);
        await box.erase();

        Get.offAllNamed(RouteConstant.loginScreen);
      } else {
        showSnackBar('No records found.');
      }
    } catch (e) {
      isDataLoading.value = false;
      showSnackBar('Failed to fetch data: $e');
    }
  }


  @override
  void dispose() {
    _timer?.cancel();

    // TODO: implement dispose
    super.dispose();
  }


}