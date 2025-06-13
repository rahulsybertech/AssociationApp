



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';

import '../controllers/HomeController.dart';
import '../routes.dart';


class homeScreen extends StatelessWidget {

  const homeScreen({super.key});



  @override
  Widget build(BuildContext context) {
    late final List<Map<String, String>> menuItems;
    final HomeController controller = Get.put(HomeController());
     final List<String> bannerImages = [
    'assets/images/image.png',
    'assets/images/image.png',
    'assets/images/image.png',
  ];

    final box = GetStorage();

    String? accountCate = box.read('accountType');

    menuItems = accountCate == "Admin"
        ? [
      {"icon": "assets/icons/honhar.png", "label": "Honhar khiladi"},
      {"icon": "assets/icons/accounts.png", "label": "Add Accounts"},
      {"icon": "assets/icons/bad.png", "label": "Dispute Details"},
      {"icon": "assets/icons/bad.png", "label": "Update Banners"},
    ]
        : [
      {"icon": "assets/icons/honhar.png", "label": "Honhar khiladi"},
      {"icon": "assets/icons/accounts.png", "label": "Add Accounts"},
      {"icon": "assets/icons/bad.png", "label": "Dispute Details"},
      {"icon": "assets/icons/bad.png", "label": "Update Banners"},
    ];

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title:   Image.asset(
        'assets/icons/app_icon.png',
        width: 40,
        height: 40,
      ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // BANNER SLIDER
            SizedBox(
              height: size.height * 0.25,
              child: PageView.builder(
                itemCount: bannerImages.length,
                onPageChanged: controller.updatePage,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        bannerImages[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // INDICATOR
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(bannerImages.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: controller.currentPage.value == index ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: controller.currentPage.value == index
                        ? Colors.redAccent
                        : Colors.grey.shade400,
                  ),
                );
              }),
            )),
            const SizedBox(height: 20),

            // MENU BUTTONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: menuItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (_, index) {
                  final item = menuItems[index];
                  final label = item['label'];
                  return GestureDetector(
                    onTap: () {
                      switch (label) {
                        case 'Honhar khiladi':
                          Get.toNamed(RouteConstant.honharScreen);
                          break;
                        case 'Add Accounts':
                          Get.toNamed(RouteConstant.registerAccountScreen);
                          break;
                        case 'Dispute Details':
                          Get.toNamed(RouteConstant.disputeDetailsScreen);
                          break;
                          case 'Update Banner':
                          Get.toNamed(RouteConstant.registerAccountScreen);
                          break;
                      // Add more cases as needed
                        default:
                          Get.snackbar('Error', 'No screen defined for "$label"');
                      }
                   //   Get.toNamed(RouteConstant.honharScreen);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(item['icon']!, height: 40),
                          const SizedBox(height: 10),
                          Text(
                            item['label']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
