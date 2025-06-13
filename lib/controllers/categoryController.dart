// ignore_for_file: body_might_complete_normally_nullable

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../network/api.dart';
import '../routes.dart';
import '../utils/utils.dart';

class CategoryController extends GetxController {
  var isDataLoading = false.obs;

  var selectedcategory = "Easy".obs; //default easy
  List<dynamic> pastScores = [];
  @override
  void onInit() {
    super.onInit();
    pastScores = GetStorage().read('past_scores') ?? [];
  }

  Future getQuestions() async {
    isDataLoading.value = true;
    final APIService apiService = APIService();

    try {
      final mcqs = await apiService.generateMCQs(selectedcategory.value);
      if (mcqs != null && mcqs.isNotEmpty) {
        Get.offAllNamed(
          RouteConstant.quizScreen,
          arguments: {"mcqs": mcqs, "category": selectedcategory.value},
        );
      } else {
        showSnackBar('No questions received. Try again.');
      }
      isDataLoading.value = false;
    } catch (e) {
      isDataLoading.value = false;
      showSnackBar('Failed to fetch quiz: $e');
    }
  }

  @override
  void dispose() {
    Get.delete<CategoryController>();
    super.dispose();
  }
}
