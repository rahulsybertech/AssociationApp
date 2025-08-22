




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
    return GestureDetector(
      behavior: HitTestBehavior.translucent, // ✅ Important: lets taps pass through to children
      onTap: () {
        FocusScope.of(context).unfocus(); // ✅ Hides keyboard
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              /// Custom App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: controller.screen == 'Honhar'
                    ? Row(
                  children: [
                    /// 🔙 Back Button (Left)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.red, size: 30),
                      onPressed: () => Get.back(),
                      splashRadius: 24, // Optional: controls ripple size
                    ),


                    /// 🔽 Dropdown Filter (Center)
                    Expanded(
                      child: Center(
                        child: Obx(() => PopupMenuButton<String>(
                          onSelected: (value) {
                            controller.selectedFilter.value = value;

                            // ✅ Correct
                            GetStorage().write('category', value);
                            GetStorage().write('category1', value);
                            controller.searchController.clear();
                            controller.filterHonharList("");
                            controller.getList(value);
                            controller.downloadAccountDetailsReportPdf(value);
                            controller.downloadAccountDetailsReportXml(value);
                          },
                          onCanceled: () {
                            // 👇 Optional: Reset to default or perform fallback logic
                            controller.selectedFilter.value = GetStorage().read('category') ?? 'Customer';
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: "Customer", child: Text("Customer")),
                            PopupMenuItem(value: "Supplier", child: Text("Supplier")),
                          ],
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.filter_alt, color: Colors.red),
                              const SizedBox(width: 6),
                              Text(
                                controller.selectedFilter.value,
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
                    ),

                    /// 🛠 App Icon (Right)
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Image.asset(
                          'assets/icons/app_icon.png',
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// Left - Back Button
                    const Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: BackButton(color: Colors.black),
                      ),
                    ),

                    /// Center - Title
                    const Expanded(
                      child: Center(
                        child: Text(
                          'All Accounts',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    /// Right - App Icon
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Image.asset(
                          'assets/icons/app_icon.png',
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],

                ),
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0), // ⬅️ Add left & right padding here
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// Left: Record Count
                    Obx(() => Text(
                      "${controller.filteredList.length} Records Found",
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    )),

                    /// Right: PDF/XML Buttons (reactive)
                    Obx(() {
                      if (controller.screen == 'Honhar' && controller.filteredList.isNotEmpty) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            /// PDF Icon
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
                                  const Text('PDF', style: TextStyle(fontSize: 12, color: Colors.black)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),

                            /// XML Icon
                            GestureDetector(
                              onTap: controller.downloadAndOpenXml,
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/icons/xml.png',
                                    width: 30,
                                    height: 30,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text('XML', style: TextStyle(fontSize: 12, color: Colors.black)),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else {
                        return const SizedBox(); // If no icons needed, return empty widget
                      }
                    }),
                  ],
                ),
              ),

              /// List of Suppliers
              Expanded(
                child: Obx(() {
                  if (controller.isDataLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.isInitialLoadComplete.value && controller.filteredList.isEmpty) {
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
                            if(controller.selectedFilter.value=="Customer"){
                              GetStorage().write('category', controller.selectedFilter.value);
                            }else{
                              GetStorage().write('category', controller.selectedFilter.value);
                            }
                            GetStorage().write('NAME', supplier.name);
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

