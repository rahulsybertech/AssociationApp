import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:newapp/controllers/detailsController.dart';
import 'package:newapp/utils/utils.dart';
class detailsScreen extends StatelessWidget {
  const detailsScreen({super.key});
  
  

  @override
  Widget build(BuildContext context) {

    final detailsController controller = Get.put(detailsController());
    final RxString

    selectedFilter = 'SUPPLIER'.obs;
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
            SizedBox(height: 6),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
              child: headerTitle(
                (controller.category.value == "Supplier" ? "Supplier" : "Customer") + " Name",
                controller.name.value,
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
                            _infoRow('assets/icons/gst.png', 'GST', supplier.gstNo),
                            _infoRow('assets/icons/user.png', 'Brand name', supplier.ownerName ?? '-'),
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
                                    supplier.disputeAmt.toString(),
                                    context,
                                  ),
                                  const SizedBox(width: 12),
                                  _infoCard(
                                    'assets/icons/part_payment.png',
                                    'Part Payment',
                                    supplier.settelledAmt.toString(),
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
    double cardWidth = (MediaQuery.of(context).size.width - 48) / 2;

    // Convert amount string to double (safely)
    double parsedAmount = double.tryParse(amount.replaceAll(',', '').replaceAll('₹', '').trim()) ?? 0.0;

    Color amountColor;
    String lowerTitle = title.toLowerCase();

    if (lowerTitle.contains('part payment')) {
      amountColor = Colors.green;
    } else if (lowerTitle.contains('dispute amount')) {
      amountColor = Colors.red;
    } else {
      amountColor = parsedAmount >= 0 ? Colors.green : Colors.red;
    }

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
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
                  formatAmount(amount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: amountColor,
                  ),
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
  Widget headerTitle( String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

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

