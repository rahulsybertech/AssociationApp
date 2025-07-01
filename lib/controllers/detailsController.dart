
// controllers/supplier_controller.dart
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../model/Supplier.dart';
import '../network/api.dart';
import '../routes.dart';
import '../utils/utils.dart';
import 'categoryController.dart';



class detailsController extends GetxController {
  var isDataLoading = false.obs;
  RxString category = ''.obs;
  var pdtUrl = 'Customer'.obs;

  var selectedcategory = "Easy".obs; //default easy
  List<dynamic> pastScores = [];
  @override
  void onInit() {
    super.onInit();
    pastScores = GetStorage().read('past_scores') ?? [];
    // Read initial value from GetStorage
    category.value = GetStorage().read('category')?.toString() ?? '';
    // Listen to changes if needed
    GetStorage().listenKey('category', (value) {
      category.value = value.toString();
    });
    String actualCategory;

    if (category.value.trim().isEmpty) {
      actualCategory = "customer";
    } else if (category.value.toLowerCase() == "customer") {
      actualCategory = "customer";
    } else {
      actualCategory = "supplier";
    }

    getList(actualCategory);
    downloadAccountDetailsReportPdf(actualCategory);
    /* suppliers.addAll([
      Supplier(name: "XYZ Corp", mobile: "1234567890", station: "Mumbai", address: "Sector 10"),
      Supplier(name: "LMN Ltd.", mobile: "9998887776", station: "Pune", address: "Main Road, Block B"),
    ]);*/
  }

  Future<void> getList(String type) async {
    isDataLoading.value = true;

    final APIService apiService = APIService();
    final box = GetStorage();
    String? token = box.read('token');
    String? category = box.read('category');
    String? id = box.read('id')?.toString();

    selectedcategory.value = type; // ✅ Set the selected category


// If category is null or empty, assign 'customer'
    if (category == null || category.isEmpty) {
      category = 'Customer';
    }



    try {
      final List<Map<String, dynamic>>? mcqs =
     await apiService.disputeDetailsByAccountId(category!,id!, token!);
    //  await apiService.disputeDetailsByAccountId("Customer","6", token!);

      isDataLoading.value = false;

      if (mcqs != null && mcqs.isNotEmpty) {
        honharList.value = mcqs.map((e) => Honharlist.fromJson(e)).toList();
      } else {
        honharList.clear(); // optional: clear if no data
        showSnackBar('No records found.');
      }
    } catch (e) {
      isDataLoading.value = false;
      showSnackBar('Failed to fetch data: $e');
    }
  }
  Future<void> downloadAndOpenPdf() async {
    final String pdfUrl = pdtUrl.value;
    final String fileName = "Downloaded_PDF.pdf";

    try {
      // Step 1: Ask permission (only on Android)
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          Get.snackbar("Permission Denied", "Storage access is required.");
          return;
        }
      }

      // Step 2: Get download directory
      Directory appDir;
      if (Platform.isAndroid) {
        appDir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      } else {
        appDir = await getApplicationDocumentsDirectory();
      }

      final String filePath = "${appDir.path}/$fileName";

      // Step 3: Download the file
      Dio dio = Dio();
      await dio.download(pdfUrl, filePath);

      Get.snackbar("Download Complete", "PDF saved to ${appDir.path}");

      // Step 4: Open the PDF
      await OpenFile.open(filePath);
    } catch (e) {
      Get.snackbar(
        "Oops!",
        "PDF Not Available.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
  Future downloadAccountDetailsReportPdf(String accountType) async {
    isDataLoading.value = true;
    final box = GetStorage();
    String? token = box.read('token');
    String? id = box.read('id')?.toString();
    try {
      final url = Uri.parse(
        'https://association.ssspltd.com/api/Account/DownloadAccountDetailsPdfByAccountId?accountId=$id&accountType=$accountType',
      );
      print("Url"+url.toString());
      final response = await http.post(
        url,
        headers: {
          'Accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: '',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Body"+data.toString());
        // Check the "success" field in the response JSON
        if (data['success'] == true && data['data'] != null) {
          var url=data['data'].toString();
          pdtUrl.value=url.toString();
          // GetStorage().write('user_name', name);

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

  Future downloadAccountDetailsReportXml(String accountType) async {
    isDataLoading.value = true;
    final box = GetStorage();
    String? token = box.read('token');
    String? id = box.read('id')?.toString();
    try {
      final url = Uri.parse(
        'https://association.ssspltd.com/api/Account/DownloadAccountDetailsPdfByAccountId?accountId=$id&accountType=$accountType',
      );
      print("Url"+url.toString());
      final response = await http.post(
        url,
        headers: {
          'Accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: '',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Body"+data.toString());
        // Check the "success" field in the response JSON
        if (data['success'] == true && data['data'] != null) {
          var url=data['data'].toString();
          pdtUrl.value=url.toString();
          // GetStorage().write('user_name', name);

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
    Get.delete<detailsController>();
    super.dispose();
  }
  var suppliers = <Supplier>[].obs;
  var honharList = <Honharlist>[].obs;

  void addSupplier(Supplier supplier) {
    suppliers.add(supplier);
  }

  void removeSupplier(int index) {
    suppliers.removeAt(index);
  }

}

class Honharlist {
  final String name;
  final int id;
  final String mobile;
  final String station;
  final String address;
  final double disputeAmt;
  final double settelledAmt;
  final String gstNo;
  final String disputeImagePath;

  Honharlist({
    required this.name,
    required this.id,
    required this.mobile,
    required this.station,
    required this.address,
    required this.disputeAmt,
    required this.settelledAmt,
    required this.gstNo,
    required this.disputeImagePath,
  });

  factory Honharlist.fromJson(Map<String, dynamic> json) {
    return Honharlist(
      name: json['accountName'] ?? '',
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      mobile: json['mobileNo'] ?? '',
      station: json['station'] ?? '',
      address: json['address'] ?? '',
      disputeAmt: double.tryParse(json['disputeAmt']?.toString() ?? '0') ?? 0.0,
      settelledAmt: double.tryParse(json['settelledAmt']?.toString() ?? '0') ?? 0.0,
      gstNo: json['gstNo'] ?? '',
      disputeImagePath: json['disputeImagePath'] ?? '',
    );
  }
}





