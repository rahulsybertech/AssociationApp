
// controllers/supplier_controller.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../model/Supplier.dart';
import '../network/api.dart';
import '../routes.dart';
import '../utils/utils.dart';
import 'categoryController.dart';



class Honharkhiladicontroller extends GetxController {
  var isDataLoading = false.obs;

  var selectedcategory = "Easy".obs; //default easy
  List<dynamic> pastScores = [];
  @override
  void onInit() {
    super.onInit();
    pastScores = GetStorage().read('past_scores') ?? [];
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

    selectedcategory.value = type; // ✅ Set the selected category

    try {
      final List<Map<String, dynamic>>? mcqs =
      await apiService.honharKhiladiList(selectedcategory.value, token!);

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

}

class Honharlist {
  final String name;
  final int id;
  final String mobile;
  final String station;
  final String address;

  Honharlist({
    required this.name,
    required this.id,
    required this.mobile,
    required this.station,
    required this.address,
  });

  factory Honharlist.fromJson(Map<String, dynamic> json) {
    return Honharlist(
      name: json['accountName'] ?? '',
      id: json['id'] ?? '',
      mobile: json['mobileNo'] ?? '',
      station: json['station'] ?? '',
      address: json['address'] ?? '',
    );
  }
}




