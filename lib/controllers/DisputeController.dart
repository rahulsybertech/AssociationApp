import 'dart:convert';

import 'package:get/get.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:newapp/model/DisputeDetailsModel.dart';
import 'package:newapp/network/api.dart';
import 'package:newapp/utils/utils.dart';

class DisputeController extends GetxController {
  var selectedCustomer = ''.obs;
  var selectedSupplier = ''.obs;
  var disputedAmount = ''.obs;
  var settledAmount = ''.obs;
  var customerId = ''.obs;
  var supplierId = ''.obs;

  var selectedFileName = ''.obs;
  var imagePath = ''.obs;
  var isDataLoading = false.obs;
  var isSaveLoading = false.obs;


 /* final RxList<CustomerList> customerList = <CustomerList>[].obs;
  final RxList<CustomerList> supplierList = <CustomerList>[].obs;*/
  RxList<CustomerList> customerList = <CustomerList>[].obs;
  Rx<CustomerList?> selectedCustomerlist = Rx<CustomerList?>(null);
   RxList<CustomerList> supplierList = <CustomerList>[].obs;
  Rx<CustomerList?> selectedSuplierlist = Rx<CustomerList?>(null);
  @override
  void onInit() {
    super.onInit();
    _fetchBothLists();
  }


  Future<bool> saveUpdateAccountDetails(
  ) async
  {
    isSaveLoading.value = true;

    final url = Uri.parse('https://association.ssspltd.com/api/Account/SaveUpdateDisputeDetail');
    print("URl"+url.toString());
    final box = GetStorage();
    String? token = box.read('token');
    String? accountCate = box.read('accountType');


    final headers = {
      'accept': '*/*',
      'Authorization': 'Bearer $token ',
      'Content-Type': 'application/json',
    };
//    String? image = selectedFileName.isEmpty ? null : selectedFileName;
    {
  }

    final body = jsonEncode({
      "id": recordId.value.isEmpty ? 0 : recordId.value,
      "customerId": customerId.value,
      "supplierId": supplierId.value,
      "disputeAmt": disputeAmt.value,
      "settelledAmt":settelledAmt .value,
      "disputeImagePath": selectedFileName.value,
    });
    print("Body"+body.toString());
    try {
      final response = await http.post(url, headers: headers, body: body);


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        if (data['success'] == true) {
        //  clearFormFields();
          Get.back();
          showSnackBar("Record Save Successfully!!.");
          return true;
        } else {
          showSnackBar(data['message'] ?? "Something went wrong.");
        }
      } else {
        showSnackBar("Failed: ${response.statusCode}");
      }
    } catch (e) {
      print(e);
      showSnackBar("Error: $e");
    } finally {
      isSaveLoading.value = false;
    }

    return false;
  }
  Future<void> _fetchBothLists() async {
    isDataLoading.value = true;

    await Future.wait([
      getList("Customer"),
      getList("Supplier"),
    ]);

    isDataLoading.value = false;
  }


  Future<void> getList(String type) async {
    final APIService apiService = APIService();
    final box = GetStorage();
    String? token = box.read('token');

    if (token == null) {
      showSnackBar('Token not found.');
      return;
    }

    try {
      final List<Map<String, dynamic>>? dataList = await apiService.customerList(type, token);
      print(dataList.toString());
      if (dataList != null && dataList.isNotEmpty) {
        if (type == 'Customer') {
          customerList.value = dataList.map((e) => CustomerList.fromJson(e)).toList();
        } else if (type == 'Supplier') {
          supplierList.value = dataList.map((e) => CustomerList.fromJson(e)).toList();
        }
      } else {
        if (type == 'Customer') {
          customerList.clear();
        } else if (type == 'Supplier') {
          supplierList.clear();
        }
        showSnackBar('No records found.');
      }
    } catch (e) {
      showSnackBar('Failed to fetch data: $e');
    }
  }


  final disputeAmt = ''.obs;
  var settelledAmt = ''.obs;
  var recordId = ''.obs;

  Future<void> getDisputeDetails() async {
    isDataLoading.value = true;

    final APIService apiService = APIService();
    final box = GetStorage();
    String? token = box.read('token');

    try {
      final DisputeDetailsModel? model =
      await apiService.getDisputeDetailData(customerId.toString(), supplierId.toString(), token!);

      isDataLoading.value = false;

      if (model != null) {
        disputeAmt.value = model.disputeAmt;
        settelledAmt.value = model.settelledAmt;
        recordId.value = model.id.toString();
      } else {
        disputeAmt.value = "";
        settelledAmt.value = "";
        showSnackBar('No records found.');
      }
    } catch (e) {
      isDataLoading.value = false;
      showSnackBar('Failed to fetch data: $e');
    }
  }



  final formKey = GlobalKey<FormState>();

  void uploadDocument() async {
    final XFile? file = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(label: 'documents', extensions: ['pdf', 'doc', 'jpg', 'png'])
      ],
    );

    if (file != null) {
      final sizeInBytes = await file.length();
      if (sizeInBytes <= 5 * 1024 * 1024) {
        selectedFileName.value = file.name;
      } else {
        Get.snackbar('Error', 'File is larger than 5 MB');
      }
    } else {
      Get.snackbar('Error', 'No file selected');
    }
  }

  void saveDispute() async {
    if (formKey.currentState?.validate() ?? false) {
      if (disputeAmt.value.isEmpty) {
        showSnackBar('Enter disputed amt.');
        return;
      } else if (settelledAmt.value.isEmpty) {
        showSnackBar('No settled amt.');
        return;
      }

      try {
        isDataLoading.value = true; // ✅ Show loader

        await saveUpdateAccountDetails(); // 👈 This should be an async method

        Get.snackbar('Success', 'Dispute saved');
      } catch (e) {
        showSnackBar('Something went wrong');
      } finally {
        isDataLoading.value = false; // ✅ Hide loader
      }
    }
  }

}



class CustomerList {
  final int id;
  final String accountName;

  CustomerList({
    required this.id,
    required this.accountName,
  });

  factory CustomerList.fromJson(Map<String, dynamic> json) {
    return CustomerList(
      id: json['id'],
      accountName: json['accountName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountName': accountName,
    };
  }

  @override
  String toString() => accountName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CustomerList && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

