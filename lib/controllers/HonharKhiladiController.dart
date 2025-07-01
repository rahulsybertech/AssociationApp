
// controllers/supplier_controller.dart
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/Supplier.dart';
import '../network/api.dart';
import '../routes.dart';
import '../utils/utils.dart';
import 'categoryController.dart';



class Honharkhiladicontroller extends GetxController {
  var isDataLoading = false.obs;
  var pdtUrl = 'Customer'.obs;
  var xmlUrl = 'Customer'.obs;
  var screen = 'Honhar'.obs;
  var selectedcategory = "Easy".obs; //default easy
  List<dynamic> pastScores = [];
//  var honharList = <Honharlist>[].obs;        // full list
  var filteredList = <Honharlist>[].obs;      // filtered list
  TextEditingController searchController = TextEditingController();
  @override
  void onInit() {
    super.onInit();
    pastScores = GetStorage().read('past_scores') ?? [];

    final args = Get.arguments;
    if (args != null && args['screen'] != null) {
      final s = args['screen'];
      screen.value=s;
      getList("Customer");
    }else{
      getList("Customer");
    }

    downloadAccountDetailsReportPdf('Customer');
    downloadAccountDetailsReportXml('Customer');

    // Initially show full list
    ever(honharList, (_) => filteredList.value = honharList);



  }

  Future<void> getList(String type) async {
    isDataLoading.value = true;

    final APIService apiService = APIService();
    final box = GetStorage();
    String? token = box.read('token');

    selectedcategory.value = type; // ✅ Set the selected category

    try {
      final List<Map<String, dynamic>>? mcqs =
      await apiService.honharKhiladiList(screen.toString(),selectedcategory.value, token!);

      isDataLoading.value = false;

      if (mcqs != null && mcqs.isNotEmpty) {
        honharList.value = mcqs.map((e) => Honharlist.fromJson(e)).toList();
        filteredList.value = honharList; // 👈 Initialize filtered list
      } else {
        honharList.clear(); // optional: clear if no data
        filteredList.clear();
        showSnackBar('No records found.');
      }
    } catch (e) {
      isDataLoading.value = false;
      showSnackBar('Failed to fetch data: $e');
    }
  }


  void filterHonharList(String query) {
    if (query.isEmpty) {
      filteredList.value = honharList;
    } else {
      filteredList.value = honharList.where((item) {
        final searchLower = query.toLowerCase();
        return item.name.toLowerCase().contains(searchLower) ||
            item.mobile.toLowerCase().contains(searchLower) ||
            item.station.toLowerCase().contains(searchLower) ||
            item.address.toLowerCase().contains(searchLower);
      }).toList();
    }
  }

  @override
  void dispose() {
    searchController.dispose(); // ✅ clean up
    Get.delete<Honharkhiladicontroller>();
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
  void launchPdfUrl() async {
    final Uri url = Uri.parse("https://image.ssspltd.com/sybererp/AssociationPdfFiles/ListOfCasesDoc_055935404.pdf");

    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.platformDefault, // safer across platforms
      );
      if (!launched) {
        Get.snackbar("Error", "Could not open PDF");
      }
    } catch (e) {
      Get.snackbar("Error", "Exception: $e");
    }
  }

  Future<void> downloadAndOpenPdf() async {
    final String pdfUrl = pdtUrl.value;
    final String fileName = "Downloaded_PDF.pdf";

    try {
      // ✅ STEP 1: Ask for permission based on Android version
      if (Platform.isAndroid) {
        if (await Permission.manageExternalStorage.request().isDenied) {
          Get.snackbar("Permission Denied", "Storage access is required.");
          return;
        }
      }

      // ✅ STEP 2: Use a valid path like /storage/emulated/0/Download
      final Directory downloadDir = Directory('/storage/emulated/0/Download');
      final String filePath = "${downloadDir.path}/$fileName";

      // ✅ STEP 3: Download the file
      Dio dio = Dio();
      await dio.download(pdfUrl, filePath);

      Get.snackbar("Download Complete", "PDF saved to ${downloadDir.path}");

      // ✅ STEP 4: Open the file
      final result = await OpenFile.open(filePath);
      if (result.type == ResultType.noAppToOpen) {
        Get.snackbar("Notice", "File downloaded but no app found to open PDF.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to download or open PDF: $e");
    }
  }


  Future<void> downloadAndOpenXml() async {
    final String pdfUrl = xmlUrl.value;
    final String fileName = "Download.xlsx";

    try {
      // ✅ Step 1: Ask for proper permission
      if (Platform.isAndroid) {
        final status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          Get.snackbar("Permission Denied", "Storage access is required.");
          return;
        }
      }

      // ✅ Step 2: Save in Download folder (public)
      final Directory downloadDir = Directory('/storage/emulated/0/Download');
      final String filePath = "${downloadDir.path}/$fileName";

      // ✅ Step 3: Download the file
      Dio dio = Dio();
      await dio.download(pdfUrl, filePath);

      Get.snackbar("Download Complete", "File saved to ${downloadDir.path}");

      // ✅ Step 4: Open the file
      final result = await OpenFile.open(filePath);
      if (result.type == ResultType.noAppToOpen) {
        Get.snackbar("Notice", "Downloaded, but no app found to open XML file.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to download/open XML: $e");
    }
  }





  Future downloadAccountDetailsReportPdf(String accountType) async {
    isDataLoading.value = true;
    final box = GetStorage();
    String? token = box.read('token');
    try {
      final url = Uri.parse(
        'https://association.ssspltd.com/api/Account/DownloadAccountDetailsReportPdf?accountType=$accountType',
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
    try {
      final url = Uri.parse(
        'https://association.ssspltd.com/api/Account/DownloadDisputeDetailsExcelFile?accountType=$accountType',
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
          xmlUrl.value=url.toString();
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

}



class Honharlist {
  final String name;
  final String accountType;
  final String accountCategory;
  final String ownerName;
  final int id;
  final String mobile;
  final String gstNo;
  final String station;
  final String address;
  final String accountImagePath;

  Honharlist({
    required this.name,
    required this.accountType,
    required this.accountCategory,
    required this.ownerName,
    required this.id,
    required this.mobile,
    required this.gstNo,
    required this.station,
    required this.address,
    required this.accountImagePath,
  });

  factory Honharlist.fromJson(Map<String, dynamic> json) {
    return Honharlist(
      name: json['accountName'] ?? '',
      accountType: json['accountType'] ?? '',
      accountCategory: json['accountCategory'] ?? '',
      ownerName: json['ownerName'] ?? '',
      id: json['id'] ?? '',
      mobile: json['mobileNo'] ?? '',
      gstNo: json['gstNo'] ?? '',
      station: json['station'] ?? '',
      address: json['address'] ?? '',
      accountImagePath: json['accountImagePath'] ?? '',
    );
  }
}




