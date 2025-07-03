



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as box;
import 'package:newapp/controllers/BannerScreenController.dart';

import '../controllers/HomeController.dart';
import '../routes.dart';


class homeScreen extends StatelessWidget {

  const homeScreen({super.key});



  @override
  Widget build(BuildContext context) {
    late final List<Map<String, String>> menuItems;
    final HomeController controller = Get.put(HomeController());
    final BannerScreenController bannerController = Get.put(BannerScreenController());


    final box = GetStorage();

    String? accountCate = box.read('accountType');

    menuItems = accountCate == "Admin"
        ? [
      {"icon": "assets/icons/honhar.png", "label": "Honhar khiladi"},
      {"icon": "assets/icons/accounts.png", "label": "Add Accounts"},
      {"icon": "assets/icons/bad.png", "label": "Dispute Details"},
      {"icon": "assets/icons/bad.png", "label": "Update Banners"},
      {"icon": "assets/icons/accounts.png", "label": "Update Accounts"},
    ]
        : [
      {"icon": "assets/icons/honhar.png", "label": "Honhar khiladi"},

 /*     {"icon": "assets/icons/accounts.png", "label": "Add Accounts"},
      {"icon": "assets/icons/bad.png", "label": "Dispute Details"},
      {"icon": "assets/icons/bad.png", "label": "Update Banners"},
      {"icon": "assets/icons/accounts.png", "label": "All Accounts"},*/
    ];

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            SystemNavigator.pop();
          },
        ),
        title: Image.asset(
          'assets/icons/app_icon.png',
          width: 40,
          height: 40,
        ),
        centerTitle: true,
        actions: [
          IconButton(
      icon: Image.asset(
      'assets/icons/shutdown.png',
        width: 30,
        height: 30,

      ),
            onPressed: () {
              final box = GetStorage();
              String? accountType = box.read('accountType');
              if (accountType=="Guest") {
                box.erase();
                Get.offNamed(RouteConstant.loginScreen);
              }else{
                _showLogoutDialog(context);
              }

            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // INDICATOR
            Column(
              children: [
                Obx(() {
                  if (controller.bannerList.isEmpty) {
                    return const Center(child: Text(""));
                  }

                  return SizedBox(
                    height: 200,
                    child: PageView.builder(
                      controller: controller.pageController,
                      itemCount: controller.bannerList.length * 1000, // For looping effect
                      onPageChanged: (index) {
                        controller.currentPage.value = index % controller.bannerList.length;
                      },
                      itemBuilder: (context, index) {
                        final banner = controller.bannerList[index % controller.bannerList.length];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              banner.bannerImagePath ?? '',
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.error, color: Colors.red)),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),

                const SizedBox(height: 10),

                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    controller.bannerList.length,
                        (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: controller.currentPage.value == index ? 12 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: controller.currentPage.value == index
                            ? Colors.red
                            : Colors.grey.shade400,
                      ),
                    ),
                  ),
                )),
              ],
            ),
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
                        case 'Update Banners':
                          Get.toNamed(RouteConstant.bannerScreen);
                          break;
                        case 'Update Accounts':
                          Get.toNamed(RouteConstant.honharScreen, arguments: {
                            'screen': 'All Accounts',
                          });
                          break;
                        case 'Honhar khiladi':
                          Get.toNamed(RouteConstant.honharScreen, arguments: {
                            'screen': 'Honhar',
                          });
                          break;
                        case 'Add Accounts':
                          Get.toNamed(RouteConstant.registerAccountScreen);
                          break;
                        case 'Dispute Details':
                          Get.toNamed(RouteConstant.disputeDetailsScreen);
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
  void _showLogoutDialog(BuildContext context) {
    final controller = Get.find<HomeController>(); // ✅ Access your controller

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final box = GetStorage();
              String? accountType = box.read('accountType');
              if (accountType=="Guest") {
                box.erase();
                Get.offNamed(RouteConstant.loginScreen);
              }else{
                controller.logOutParam();
                Navigator.of(context).pop();
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
  void _logout() {
    final box = GetStorage();
    box.erase(); // or box.remove('token');
    Get.offAllNamed('/loginScreen'); // Navigate to login screen
  }
}
