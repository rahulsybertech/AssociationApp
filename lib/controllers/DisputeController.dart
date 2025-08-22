import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:newapp/model/DisputeDetailsModel.dart';
import 'package:newapp/network/api.dart';
import 'package:newapp/utils/CrossPlatformImagePicker.dart';
import 'package:newapp/utils/utils.dart';
import 'package:path_provider/path_provider.dart';

class DisputeController extends GetxController {
  var selectedCustomer = ''.obs;
  final isSettledAmtEditable = true.obs;
  final disputeAmtController = TextEditingController();
  final advocateNameController = TextEditingController();
  final caseNumberController = TextEditingController();
  final settelledAmtController = TextEditingController();
  final GlobalKey<FormState> formKey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> selectCustomerKey = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey2 = GlobalKey<FormState>();
  final ImagePickerController imageController = Get.put(ImagePickerController());
  RxString selectedCaseType = '138'.obs;
  var id = '0'.obs;
  bool get isEditing => id.value != "0";
  TextEditingController dateController = TextEditingController();
  Rx<DateTime> selectedDate = DateTime.now().obs;
  RxString selectedDateText = ''.obs;

  var selectedSupplier = ''.obs;
  var base64Path = ''.obs;
  var disputedAmount = ''.obs;
  var settledAmount = ''.obs;
  var customerError = RxnString();
  var customerId = ''.obs;

  var supplierId = ''.obs;

  var selectedFileName = ''.obs;
  var imagePath = ''.obs;
  var isDataLoading = false.obs;
  var isSaveLoading = false.obs;


 /* final RxList<CustomerList> customerList = <CustomerList>[].obs;
  final RxList<CustomerList> supplierList = <CustomerList>[].obs;*/
  final customerSearchController = TextEditingController();
  final customerSearchFocus = FocusNode();
  RxList<CustomerList> customerList = <CustomerList>[].obs;
  Rx<CustomerList?> selectedCustomerlist = Rx<CustomerList?>(null);
   RxList<CustomerList> supplierList = <CustomerList>[].obs;
  Rx<CustomerList?> selectedSuplierlist = Rx<CustomerList?>(null);
  @override
  void onInit() {
    super.onInit();
    _fetchBothLists();
    // 1. Listen to field changes and update .value
    disputeAmtController.addListener(() {
      disputeAmt.value = disputeAmtController.text;
    });

    settelledAmtController.addListener(() {
      settelledAmt.value = settelledAmtController.text;
    });

    advocateNameController.addListener(() {
      advocateName.value = advocateNameController.text;
    });
    caseNumberController.addListener(() {
      caseNo.value = caseNumberController.text;
    });

    // 2. Listen to .value changes and update controller (one-time sync)
    ever(disputeAmt, (val) {
      if (disputeAmtController.text != val) {
        disputeAmtController.text = val;
        disputeAmtController.selection =
            TextSelection.collapsed(offset: val.length);
      }
    });

    ever(settelledAmt, (val) {
      if (settelledAmtController.text != val) {
        settelledAmtController.text = val;
        settelledAmtController.selection =
            TextSelection.collapsed(offset: val.length);
      }
    });

    ever(advocateName, (val) {
      if (advocateNameController.text != val) {
        advocateNameController.text = val;
        advocateNameController.selection =
            TextSelection.collapsed(offset: val.length);
      }
    });
    ever(caseNo, (val) {
      if (caseNumberController.text != val) {
        caseNumberController.text = val;
        caseNumberController.selection =
            TextSelection.collapsed(offset: val.length);
      }
    });
  }


  Future<bool>saveUpdateAccountDetails(
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
      "caseNo": caseNo.value,
      "caseDate":  DateFormat('yyyy-MM-dd').format(caseDate.value!),
      "caseType": selectedCaseType.value,
      "advocateName": advocateName.value,
      "disputeImagePath": selectedFileName.value,
      "settelledAmt": settelledAmt.value.isEmpty ? 0 : double.parse(settelledAmt.value),

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
          showSnackBar(
            'Record Save Successfully!!',
            backgroundColor: Colors.green,
            titleText: 'Success',
          );

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
  //      showSnackBar('No records found.');
      }
    } catch (e) {
      showSnackBar('Failed to fetch data: $e');
    }
  }


  final disputeAmt = '0'.obs;
  var settelledAmt = ''.obs;
  var advocateName = ''.obs;
  var caseNo = ''.obs;
  var caseDate = Rxn<DateTime>();
 // var caseDate = DateTime.now().obs;
  var recordId = ''.obs;
  var caseType = ''.obs;
  var isSettledAmtInvalid = false.obs;

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
        advocateName.value = model.advocateName;

        DateTime parsedDate = DateTime.parse(model.caseDate); // parses ISO format
   //     caseDate.value = parsedDate; // ✅ Store as DateTime
        // converts to string like 07-07-2025
        caseNo.value = model.caseNo;
        caseType.value = model.caseType;
        recordId.value = model.id.toString();
        dateController.text = DateFormat('dd-MM-yyyy').format(parsedDate);
        String caseTypeFromApi = model.caseType.toString();

        if (caseTypeFromApi == '138') {
          selectedCaseType.value = '138';
        } else if (caseTypeFromApi == 'Civil') {
          selectedCaseType.value = 'Civil';
        } else {
          selectedCaseType.value = '138'; // or handle other cases
        }
        if (model.disputeImagePath.isNotEmpty) {
          loadImageFromUrl(model.disputeImagePath);
        }
      } else {
        disputeAmt.value = "";
        settelledAmt.value = "";
        caseNo.value = "";
        caseType.value = "";
        advocateName.value = "";
        dateController.text="";
        selectedCaseType.value = '138';
        //   showSnackBar('No records found.');
      }
    } catch (e) {
      isDataLoading.value = false;
    //  showSnackBar('Failed to fetch data: $e');
    }
  }
  Future<void> loadImageFromUrl(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final bytes = response.bodyBytes;

      // Save to temp file with a unique name (timestamp)
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/temp_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(bytes);

      imageController.pickedImage.value = file; // ✅ triggers UI update
    } catch (e) {
      print("Image load error: $e");
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

  Future<void> saveDispute() async {
    final isForm1Valid = formKey1.currentState?.validate() ?? false;
    final isForm2Valid = formKey2.currentState?.validate() ?? false;
    final isSelectCustomerKey = selectCustomerKey.currentState?.validate() ?? false;
    if (!isSelectCustomerKey) return;
    if (!isForm1Valid || !isForm2Valid) return;


    if (customerId.value.isEmpty) {
      showSnackBar('Select customer.');
      return;
    }
    if (supplierId.value.isEmpty) {
      showSnackBar('Select supplier.');
      return;
    }
    if (caseDate.value == null) {
      showSnackBar('Select dispute date.');
      return;
    }
   if (disputeAmt.value.isEmpty) {
      showSnackBar('Enter disputed amt.');
      return;
    }

    if (settelledAmt.value.isNotEmpty) {
      final settled = double.tryParse(settelledAmt.value);
      final dispute = double.tryParse(disputeAmt.value);

      if (settled != null && dispute != null && settled > dispute) {
        showSnackBar('Settled amt. cannot be greater than disputed amt.');
        return;
      }
    }

    try {
      isDataLoading.value = true;
      await saveUpdateAccountDetails(); // implement this function
 //     Get.snackbar('Success', 'Dispute saved');
    } catch (e) {
      showSnackBar('Something went wrong');
    } finally {
      isDataLoading.value = false;
    }
  }

  void showSnackBar1(String message) {
    Get.snackbar('Error', message, backgroundColor: Colors.red, colorText: Colors.white);
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

