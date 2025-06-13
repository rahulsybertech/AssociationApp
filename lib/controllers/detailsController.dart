
// controllers/supplier_controller.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../model/Supplier.dart';
import '../network/api.dart';
import '../routes.dart';
import '../utils/utils.dart';
import 'categoryController.dart';



class detailsController extends GetxController {
  var isDataLoading = false.obs;
  RxString category = ''.obs;

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

    getList("Customer");
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





