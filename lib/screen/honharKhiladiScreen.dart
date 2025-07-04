




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
    final box = GetStorage();
    String? accountType = box.read('accountType');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// Custom App Bar
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (controller.screen == 'Honhar') ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              /// 🔙 Back Icon
                              GestureDetector(
                                onTap: () => Get.back(),
                                child: const Icon(Icons.arrow_back, color: Colors.red,size: 35,),

                              ),

                              /// 🔽 Dropdown Filter
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0), // 👈 Add start margin here
                                child: Obx(() => PopupMenuButton<String>(
                                  onSelected: (value) {
                                    selectedFilter.value = value;
                                    GetStorage().write('category', value);
                                    controller.searchController.clear();
                                    controller.filterHonharList("");
                                    controller.getList(value);
                                    controller.downloadAccountDetailsReportPdf(value);
                                    controller.downloadAccountDetailsReportXml(value);
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
                              ),

                            ],
                          ),
                        ),
                      ]

                      /// For All Accounts
                      else if (controller.screen == 'All Accounts') ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              BackButton(color: Colors.black),
                              Text(
                                'All Accounts',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],


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
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0,right: 16),
                    child: Row(
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
                        if(controller.screen=='Honhar')
                          if(controller.filteredList.length>0)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // PDF Icon with tap
                            GestureDetector(
                              onTap: controller.downloadAndOpenPdf,
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/icons/download_pdf.png',
                                    width: 30,
                                    height: 30,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'PDF',
                                    style: TextStyle(fontSize: 12, color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20), // spacing between PDF and XML

                            // XML Icon with tap
                            GestureDetector(
                              onTap: controller.downloadAndOpenXml, // define this in your controller
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/icons/xml.png',
                                    width: 30,
                                    height: 30,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'XML',
                                    style: TextStyle(fontSize: 12, color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                      ],
                    ),
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
                        if(controller.screen=='Honhar'){
                          GetStorage().write('id', supplier.id);
                          Get.toNamed(
                            RouteConstant.detailsScreen,
                            arguments: {
                              'supplier': supplier, // passing full object
                            },
                          );
                        }
                        // 👉 Open details screen

                        /*Get.toNamed(
                          RouteConstant.detailsScreen,
                          arguments: {
                            'supplier': supplier, // passing full object
                          },
                        );*/
                      },
                      child: Card(
                        margin: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 👤 Left Side: Image + Info
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10, left: 10), // 👈 top & start (left) margin
                                    child: GestureDetector(
                                      onTap: () {
                                        if (supplier.accountImagePath != null &&
                                            supplier.accountImagePath!.isNotEmpty) {
                                          Get.to(() => FullScreenImageView(assetPath: supplier.accountImagePath));
                                        }
                                      },
                                      child: CircleAvatar(
                                        radius: 28,
                                        backgroundImage: (supplier.accountImagePath != null &&
                                            supplier.accountImagePath!.isNotEmpty)
                                            ? NetworkImage(supplier.accountImagePath!)
                                            : const AssetImage('assets/icons/user.png') as ImageProvider,
                                        backgroundColor: Colors.grey[200],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 10), // 👈 Add top margin here
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
                                  ),
                                ],
                              ),
                            ),

                            // ✏️ Edit Icon Button
                            if(accountType=="Admin")
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Colors.black),
                              onPressed: () {
                                // 👉 Same as tap or different edit logic
                                Get.toNamed(
                                  RouteConstant.registerAccountScreen,
                                  arguments: {
                                    'supplier': supplier,
                                  },
                                );
                              },
                            ),
                          ],
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
            maxLines: 1,
          ),
          Expanded(
            child: Text(value,
              maxLines: 1,),
          ),
        ],
      ),
    );
  }




}

