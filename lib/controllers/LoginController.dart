import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:newapp/network/api.dart';
import 'package:newapp/routes.dart';
import 'package:newapp/screen/loginScreen.dart';
import 'package:newapp/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class Logincontroller extends GetxController {
  var isDataLoading = false.obs;
  var isVerifyOtp = false.obs;

  var mobileNumber = "Easy".obs; //default easy
  List<dynamic> pastScores = [];
  @override
  void onInit() {
    super.onInit();
    pastScores = GetStorage().read('past_scores') ?? [];
  }

  Future login(String mobileNumber) async {
    isDataLoading.value = true;

    try {
      final url = Uri.parse(
        'https://association.ssspltd.com/api/Login/GetLoginDetails?mobileNo=$mobileNumber',
      );

      final response = await http.post(
        url,
        headers: {'accept': 'application/json'},
        body: '',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check the "success" field in the response JSON
        if (data['success'] == true && data['data'] != null) {
          final otp = data['data']['otp'];
          final name = data['data']['name'];
          final loginStatus = data['data']['loginStatus'];

          // Store user info if needed
          GetStorage().write('user_name', name);
        //  GetStorage().write('token', name);

          // Show OTP bottom sheet
          showOtpBottomSheet(Get.context!,mobileNumber: mobileNumber,otp: otp);
        } else {
          // Handle error scenario from the API response
          final errorMessage = data['message'] ?? 'Login failed';
          showSnackBar(errorMessage);
        }
      } else {
        // Non-200 HTTP status
        showSnackBar('Login failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      showSnackBar('Login Error: $e');
    } finally {
      isDataLoading.value = false;
    }
  }

  Future resendOtp(String mobileNumber) async {
 //   isDataLoading.value = true;

    try {
      final url = Uri.parse(
        'https://association.ssspltd.com/api/Login/ResendOTPDetails?mobileNo=$mobileNumber',
      );

      final response = await http.post(
        url,
        headers: {'accept': 'application/json'},
        body: '',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check the "success" field in the response JSON
        if (data['success'] == true) {
       /*   final otp = data['data']['otp'];

          final loginStatus = data['data']['loginStatus'];
*/
          // Store user info if needed
      //    GetStorage().write('user_name', name);
        //  GetStorage().write('token', name);
     //     showSnackBar(errorMessage);
          // Show OTP bottom sheet
        //  showOtpBottomSheet(Get.context!,mobileNumber: mobileNumber,otp: otp);
        } else {
          // Handle error scenario from the API response
          final errorMessage = data['message'] ?? 'Login failed';
          showSnackBar(errorMessage);
        }
      } else {
        // Non-200 HTTP status
        showSnackBar('Login failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      showSnackBar('Login Error: $e');
    } finally {
     // isVerifyOtp.value = false;
    }
  }

  Future verifyOTPDetails(String mobileNumber,String otp) async {
    isVerifyOtp.value = true;

    try {
      final url = Uri.parse(
        'https://association.ssspltd.com/api/Login/VerifyOTPDetails?mobileNo=$mobileNumber&otp=$otp',
      );

      final response = await http.post(
        url,
        headers: {'accept': 'application/json'},
        body: '',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check the "success" field in the response JSON
        if (data['success'] == true && data['data'] != null) {
   /*       final otp = data['data']['otp'];
          final name = data['data']['name'];*/
          final accessToken = data['data']['accessToken'];
          final mobileNo = data['data']['mobileNo'];
          final accountType = data['data']['accountType'];

          // Store user info if needed
          GetStorage().write('token', accessToken);
          GetStorage().write('mobileNo', mobileNo);
          GetStorage().write('accountType', accountType);

          // Show OTP bottom sheet
          Get.offAllNamed(RouteConstant.homeScreen);
        } else {
          // Handle error scenario from the API response
          final errorMessage = data['message'] ?? 'Login failed';
          showSnackBar(errorMessage);
        }
      } else {
        // Non-200 HTTP status
        showSnackBar('Login failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      showSnackBar('Login Error: $e');
    } finally {
      isVerifyOtp.value = false;
    }
  }

  Future<void> callAccessWithoutLogin() async {

    final response = await APIService.accessWithoutLogin();
  //  isDataLoading.value = false;

    if (response != null && response['success'] == true) {
      final accessToken = response['data']['accessToken'];
      final mobileNo = response['data']['mobileNo'];
      final accountType = response['data']['accountType'];

      // Store user info
      GetStorage().write('token', accessToken);
      GetStorage().write('mobileNo', mobileNo);
      GetStorage().write('accountType', accountType);
      getAppVersion();
      // Navigate to home screen
   //   Get.toNamed(RouteConstant.homeScreen);
    }
    else {
      // ❌ Show message
      print("Access failed: ${response?['ResponseMessage'] ?? 'Unknown error'}");
    }
  }


  @override
  void dispose() {
    Get.delete<Logincontroller>();
    super.dispose();
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
          /*  TextButton(
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


}