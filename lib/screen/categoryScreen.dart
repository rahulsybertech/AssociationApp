import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/categoryController.dart';
import '../customWidgets/customLoader.dart';
import '../customWidgets/customText.dart';
import '../utils/appcolors.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final CategoryController controller = Get.put(CategoryController());

    return Obx(
      () =>
          Scaffold(
        appBar: AppBar(
          backgroundColor: purpleColor,
          title: const CustomText(text: 'Quiz GK', textColor: whiteColor),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CustomText(
                text: 'Select Category',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 10),
              Column(
                children:
                    ["Easy", "Medium", "Hard"].map((difficulty) {
                      return RadioListTile(
                        title: CustomText(text: difficulty),
                        value: difficulty,
                        groupValue: controller.selectedcategory.value,
                        onChanged: (value) {
                          controller.selectedcategory.value = value!;
                        },
                      );
                    }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.getQuestions,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child:
                    controller.isDataLoading.value
                        ? const Loader(color: purpleColor)
                        : Text('Start'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Past Scores:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Flexible(
                child:
                    controller.pastScores.isEmpty
                        ? const Text(
                          'No past scores available',
                          style: TextStyle(fontSize: 16),
                        )
                        : SizedBox(
                          height: 200,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: controller.pastScores.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center, //center content horizontaly
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ), //star icon
                                    const SizedBox(
                                      width: 8,
                                    ), //spacing between icon and text
                                    Text(
                                      controller.pastScores[index],
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                visualDensity: VisualDensity.compact,
                              );
                            },
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
