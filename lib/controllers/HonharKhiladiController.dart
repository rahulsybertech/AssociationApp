
// controllers/supplier_controller.dart
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
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
  var isInitialLoadComplete = false.obs;
  var pdtUrl = 'Customer'.obs;
  var selectFilter = 'Customer'.obs;
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
    requestStoragePermission();
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
        isInitialLoadComplete.value = true;
        honharList.clear(); // optional: clear if no data
        filteredList.clear();
      //  showSnackBar('No records found.');
        showSnackBar(
          'No records found.',
          backgroundColor: Colors.green,
          titleText: 'Success',
        );
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
         item.gstNo.toLowerCase().contains(searchLower) ||
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
    final granted = await requestStoragePermission();
    if (!granted) {
      showSnackBar(
        'Storage permission is required.',
        backgroundColor: Colors.red,
        titleText: 'Permission Denied',
      );
      return;
    }

    final String pdfUrl = pdtUrl.value;
    const String fileName = "Downloaded_PDF.pdf";
    if(pdfUrl.isNotEmpty){

      try {
        Directory? saveDir;

        if (Platform.isAndroid) {
          saveDir = await getExternalStorageDirectory();
        } else if (Platform.isIOS) {
          saveDir = await getApplicationDocumentsDirectory();
        }

        if (saveDir == null) {
          showSnackBar(
            'Unable to access file directory.',
            backgroundColor: Colors.red,
            titleText: 'Error',
          );
          //   Get.snackbar("Error", "Unable to access file directory.");
          return;
        }

        final String filePath = "${saveDir.path}/$fileName";

        Dio dio = Dio();
        await dio.download(pdfUrl, filePath);

        showSnackBar(
          'PDF saved to: $filePath',
          backgroundColor: Colors.green,
          titleText: 'Download Complete',
        );
        //  Get.snackbar("Download Complete", "PDF saved to: $filePath");

        final result = await OpenFile.open(filePath);
        if (result.type == ResultType.noAppToOpen) {
          Get.snackbar("Notice", "PDF downloaded, but no app found to open it.");
        }

      } catch (e) {
        showSnackBar(
          'Failed to download/open PDF',
          backgroundColor: Colors.red,
          titleText: 'Error',
        );
        //  Get.snackbar("Error", "Failed to download/open PDF: $e");
      }
    }else{
      showSnackBar(
        'Pdf not found.',
        backgroundColor: Colors.red,
        titleText: 'Error',
      );
    }

  }

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        // Android 13+ — no runtime permission needed if you're saving to app folder
        return true;
      } else {
        var status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return true;
  }



  Future<void> downloadAndOpenXml() async {
    final String fileUrl = xmlUrl.value;
    const String fileName = "Downloaded_File.xlsx";

    // ✅ Optional: Only needed on Android 10+ for file access
    final granted = await requestStoragePermission();
    if (!granted) {
      showSnackBar(
        'Storage permission is required.',
        backgroundColor: Colors.red,
        titleText: 'Permission Denied',
      );
     // Get.snackbar("Permission Denied", "Storage permission is required.");
      return;
    }

    if(fileUrl.isNotEmpty){
      try {
        // ✅ Choose directory based on platform
        Directory? appDir;
        if (Platform.isAndroid) {
          appDir = await getExternalStorageDirectory(); // Android
        } else if (Platform.isIOS) {
          appDir = await getApplicationDocumentsDirectory(); // iOS safe
        }

        if (appDir == null) {
          showSnackBar('Could not access device storage."');
          // Get.snackbar("Error", "Could not access device storage.");
          return;
        }

        final String filePath = "${appDir.path}/$fileName";

        // ⬇️ Download file
        Dio dio = Dio();
        await dio.download(fileUrl, filePath);

        showSnackBar(
          'File saved to: $filePath',
          backgroundColor: Colors.green,
          titleText: 'Download Complete',
        );
        // Get.snackbar("Download Complete", "File saved to: $filePath");

        // 📂 Open the downloaded file
        final result = await OpenFile.open(filePath);
        if (result.type == ResultType.noAppToOpen) {
         /*  showSnackBar(
             'Install an app to open .xlsx files.',
             backgroundColor: Colors.green,
            titleText: 'No App Found',
           );*/
        //  Get.snackbar("No App Found", "Install an app to open .xlsx files.");
        }

      } catch (e) {
        showSnackBar(
          'Failed to download/open file',
          backgroundColor: Colors.red,
          titleText: 'Error',
        );
        //  Get.snackbar("Error", "Failed to download/open file: $e");
      }
    }else{
      showSnackBar(
        'xlsx not found',
        backgroundColor: Colors.red,
        titleText: 'Error',
      );
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




