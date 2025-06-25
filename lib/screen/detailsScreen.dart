




import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as box;
import 'package:newapp/controllers/detailsController.dart';
import 'package:newapp/customWidgets/customText.dart';
import 'package:newapp/utils/FullyCustomAppBar.dart';
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
            AppBar(
              title:   Text(
                controller.category.value == "Supplier" ? "Customer" : "Supplier",
          style: const TextStyle(
            color: Colors.black
            ,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0,
              leading: const BackButton(color: Colors.black),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Image.asset(
                    'assets/icons/app_icon.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover, // or BoxFit.contain
                  ),
                ),
              ],

            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16), // <-- margin left & right
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left: Records found
                  Obx(() => Text(
                    "${controller.honharList.length} Records Found",
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  )),

                  // Right: Download PDF
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
                        const SizedBox(width: 6),
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
              ),
            ),

            // 🔽 Supplier List
            Expanded(
              child: Obx(() {
                if (controller.isDataLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.honharList.isEmpty) {
                  return const Center(child: Text('No data found'));
                }

                return ListView.builder(
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
                            _infoRow(
                              'assets/icons/user.png',
                              (controller.category.value == "Supplier" ? "Customer" : "Supplier") + ' Name',
                              supplier.name,
                            ),
                            _infoRow('assets/icons/mobile.png', 'Mobile No.', supplier.mobile),
                            //   _infoRow(Icons.account_balance_wallet, 'GST', supplier.gstNo ?? '-'),

                            //    _infoRow(Icons.account_balance_wallet, 'GST', ),
                            _infoRow('assets/icons/gst.png', 'GST', supplier.gstNo),
                            _infoRow('assets/icons/user.png', 'Owner Name', supplier.name ?? '-'),
                            _infoRow('assets/icons/station.png', 'Station', supplier.station),
                            _infoRow('assets/icons/home.png', 'Address', supplier.address),

                            // 🌍 State Name + Amount Cards
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _infoCard(
                                    'assets/icons/dispute.png',
                                    'Dispute Amount',
                                    supplier.disputeAmt.toString()+ '/-',
                                    context,
                                  ),
                                  const SizedBox(width: 12),
                                  _infoCard(
                                    'assets/icons/part_payment.png',
                                    'Part Payment',
                                    supplier.settelledAmt.toString()+ '/-',
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
                );

              }),
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












  Widget _infoRow(String icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            icon,
            width: 20,
            height: 20,
            /*   color: Colors.grey[700], // Optional: tint the image*/
          ),
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

