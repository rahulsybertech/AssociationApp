



import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:newapp/model/ApiResponse.dart';
import 'package:newapp/network/api.dart';
import 'package:newapp/routes.dart';
import 'package:newapp/screen/loginScreen.dart';
import 'package:newapp/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';


class SplashController extends GetxController {
  var isDataLoading = false.obs;
  var isVerifyOtp = false.obs;

  var mobileNumber = "Easy".obs; //default easy
  List<dynamic> pastScores = [];

  @override
  void onInit() {
    super.onInit();
    getAppVersion();
  }

  Future<void> getAppVersion() async {
    isDataLoading.value = true;

    try {
      final url = Uri.parse('https://association.ssspltd.com/api/Account/GetAppVersion');
      final box = GetStorage();
      String? token = box.read('token');
      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $token ',
        'Content-Type': 'application/json',
      };
      final response = await http.post(
        url,
        headers: headers,
        body: '', // send mobileNumber if needed
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final double serverVersion = data['data'] is double
              ? data['data']
              : double.tryParse(data['data'].toString()) ?? 0.0;

          // Get current app version
          //   final packageInfo = await PackageInfo.fromPlatform();
          final currentVersion = 1.10;


          if (serverVersion > currentVersion) {
            // 🔴 Outdated version - force logout or update
            showForceUpdateDialog();
          } else {
            Get.offNamed(RouteConstant.homeScreen);
          }
        } else {
          showSnackBar(data['message'] ?? 'Something went wrong');
        }
      } else {
        showSnackBar('Error: ${response.statusCode}');
      }
    } catch (e) {
      showSnackBar('Login Error: $e');
    } finally {
      isDataLoading.value = false;
    }
  }

  void showForceUpdateDialog() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // prevent closing with back button
        child: AlertDialog(
          title: const Text('App Update Required'),
          content: const Text(
              'Your app version is outdated. Please update to continue.'),
          actions: [
           /* TextButton(
              onPressed: () {
                // Clear storage or token if needed
                logOutParam();
              //  Get.offAllNamed('/login'); // Navigate to login or splash
              },
              child: const Text('Logout'),
            ),*/
            TextButton(
              onPressed: () {
                // Redirect to Play Store or app page
                launchUrl(Uri.parse(
                    "https://play.google.com/store/apps/details?id=com.sss.newapp"));
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
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
        showSnackBar(
          model.message,
          backgroundColor: Colors.green,
          titleText: 'Success',
        );
        // showSnackBar(model.message);
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
}

