




import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:newapp/customWidgets/customText.dart';
import 'package:newapp/routes.dart';
import 'package:newapp/utils/FullScreenImageView.dart';
import 'package:newapp/utils/appcolors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/HomeController.dart';
import '../controllers/HonharKhiladiController.dart';
import '../model/Supplier.dart';

class honharKhiladiScreen extends StatelessWidget {

  const honharKhiladiScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final Honharkhiladicontroller controller = Get.put(Honharkhiladicontroller());
 //   controller.getList();
    final RxString selectedFilter = 'Customer'.obs;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// Custom App Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [

                      /// 🔙 Back Icon with action
                      GestureDetector(
                        onTap: () {
                          Get.back(); // or Navigator.pop(context);
                        },
                        child: const Icon(Icons.arrow_back, color: Colors.red),
                      ),

                      /// ⬇️ Filter Dropdown (center item)

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// 🔽 Left Side Dropdown Filter
                          Obx(() => PopupMenuButton<String>(
                            onSelected: (value) {
                              selectedFilter.value = value;
                              GetStorage().write('category', value);
                              controller.searchController.clear(); //  clear the search field
                              controller.filterHonharList("");     // reset the filtered list
                              controller.getList(value);
                              controller.downloadAccountDetailsReportPdf(value);
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: "Customer", child: Text("Customer")),
                              PopupMenuItem(value: "Supplier", child: Text("Supplier")),
                            ],
                            child: Row(
                              children: [
                                const Icon(Icons.filter_alt, color: Colors.red),
                                const SizedBox(width: 6),
                                Text(
                                  selectedFilter.value,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down, color: Colors.red),
                              ],
                            ),
                          )),

                          /// ⚠️ Right Side Icon
            /*              Container(
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                          ),*/
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 5),
                  Container(
                    height: 50,
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.searchController,
                            onChanged: controller.filterHonharList,
                            decoration: const InputDecoration(
                              hintText: 'Search by name, station, etc.',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.search, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left: Records found
                      Obx(() => Text(
                        "${controller.filteredList.length} Records Found",
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      )),

                      // Right: Clickable image to open PDF
                      GestureDetector(
                        onTap: controller.downloadAndOpenPdf,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/icons/download_pdf.png',
                              width: 25,
                              height: 25,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 6), // spacing between icon and text
                            const Text(
                              "Download PDF",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )

                ],
              ),
            ),

            /// List of Suppliers
            Expanded(
              child: Obx(() {
                if (controller.isDataLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.filteredList.isEmpty) {
                  return const Center(child: Text('No data found'));
                }

                return ListView.builder(
                  itemCount: controller.filteredList.length,
                  itemBuilder: (context, index) {
                    final supplier = controller.filteredList[index];
                    return GestureDetector(
                      onTap: () {
                        // 👉 Open details screen
                        GetStorage().write('id', supplier.id);
                       /* Get.toNamed(
                          RouteConstant.registerAccountScreen,
                            arguments: {
                              'supplier': supplier, // passing full object
                            },
                        );*/
                        Get.toNamed(
                          RouteConstant.detailsScreen,
                          arguments: {
                            'supplier': supplier, // passing full object
                          },
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 👤 Profile Image - open image full screen
                              GestureDetector(
                                onTap: () {
                                  if (supplier.accountImagePath != null &&
                                      supplier.accountImagePath!.isNotEmpty) {

                                        Get.to(() => FullScreenImageView(assetPath: supplier.accountImagePath));
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 28,
                                  backgroundImage:
                                  (supplier.accountImagePath != null && supplier.accountImagePath!.isNotEmpty)
                                      ? NetworkImage(supplier.accountImagePath!)
                                      : const AssetImage('assets/icons/user.png') as ImageProvider,
                                  backgroundColor: Colors.grey[200],
                                ),
                              ),
                              const SizedBox(width: 12),

                              // 📝 Info column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _infoRow('assets/icons/user.png', 'Name', supplier.name),
                                    _infoRow('assets/icons/mobile.png', 'Mobile', supplier.mobile),
                                    _infoRow('assets/icons/gst.png', 'GST', supplier.gstNo),
                                    _infoRow('assets/icons/station.png', 'Station', supplier.station),
                                    _infoRow('assets/icons/home.png', 'Address', supplier.address),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                    ;
                  },
                );
              }),
            ),


          ],
        ),
      ),
    );
  }

  Widget _infoRow(String assetPath, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Get.to(() => FullScreenImageView(assetPath: assetPath));

            },
            child: Image.asset(
              assetPath,
              width: 20,
              height: 20,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }




}

