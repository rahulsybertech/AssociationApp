import 'dart:convert';
import 'dart:developer';

import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:newapp/network/api.dart';
import 'package:newapp/routes.dart';
import 'package:newapp/screen/loginScreen.dart';
import 'package:newapp/utils/utils.dart';

class Logincontroller extends GetxController {
  var isDataLoading = false.obs;

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

  Future verifyOTPDetails(String mobileNumber,String otp) async {
    isDataLoading.value = true;

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
          Get.toNamed(RouteConstant.homeScreen);;
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


  @override
  void dispose() {
    Get.delete<Logincontroller>();
    super.dispose();
  }


}