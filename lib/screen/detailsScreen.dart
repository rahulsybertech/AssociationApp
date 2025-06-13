




import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as box;
import 'package:newapp/controllers/detailsController.dart';
import 'package:newapp/customWidgets/customText.dart';
import 'package:newapp/utils/appcolors.dart';

import '../controllers/HomeController.dart';
import '../controllers/HonharKhiladiController.dart';
import '../model/Supplier.dart';

class detailsScreen extends StatelessWidget {
  const detailsScreen({super.key});
  
  

  @override
  Widget build(BuildContext context) {

    final detailsController controller = Get.put(detailsController());
    //   controller.getList();
    final RxString selectedFilter = 'SUPPLIER'.obs;
   // final String id = Get.arguments['id'];


    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 🔺 Custom App Bar with Back + Warning Icon
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.red),
                            onPressed: () => Get.back(),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            controller.category.value,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 🔍 Search Field
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search',
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
                  const SizedBox(height: 6),

                  // 🧾 Count Text
                  Obx(() => Text(
                    "${controller.honharList.length} Records Found",
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  )),
                ],
              ),
            ),

            // 🔽 Supplier List
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: controller.honharList.length,
                itemBuilder: (context, index) {
                  final supplier = controller.honharList[index];
                  return Card(
                    margin: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow(Icons.business, 'Firm Name', supplier.name),
                          _infoRow(Icons.phone, 'Mobile No.', supplier.mobile),
                       //   _infoRow(Icons.account_balance_wallet, 'GST', supplier.gstNo ?? '-'),
                      //    _infoRow(Icons.account_balance_wallet, 'GST', ),
                          _infoRow(Icons.person, 'Owner Name', ""),
                         _infoRow(Icons.person, 'Owner Name', supplier.name ?? '-'),
                          _infoRow(Icons.location_city, 'Station', supplier.station),
                          _infoRow(Icons.home, 'Address', supplier.address),

                          // 🌍 State Name + Amount Cards
                          const SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _infoCard(
                                  'assets/icons/accounts.png',
                                  'Dispute Amount',
                                  '1,02,433 /-',
                                  context,
                                ),
                                const SizedBox(width: 12),
                                _infoCard(
                                  'assets/icons/accounts.png',
                                  'Part Payment',
                                  '1,02,433 /-',
                                  context,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );

  }
  Widget _infoCard(String iconPath, String title, String amount, BuildContext context) {
    double cardWidth = (MediaQuery.of(context).size.width - 48) / 2; // 24 total horizontal padding + 12 spacing

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(

       /* boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],*/
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(iconPath, width: 24, height: 24, fit: BoxFit.contain),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }












  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.black87),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: "$title : ",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

