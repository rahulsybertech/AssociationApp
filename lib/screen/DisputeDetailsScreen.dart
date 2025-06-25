import 'dart:ffi';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newapp/controllers/DisputeController.dart';
import 'package:newapp/customWidgets/customLoader.dart';
import 'package:newapp/customWidgets/customText.dart';


class DisputeDetailsScreen extends StatelessWidget {
  const DisputeDetailsScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final DisputeController controller = Get.put(DisputeController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispute Details'),
        leading: BackButton(),
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
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Customer Dropdown
              Obx(() => DropdownSearch<CustomerList>(
                selectedItem: controller.selectedCustomerlist.value,
                items: controller.customerList,
                itemAsString: (customer) => customer.accountName ?? "",
                onChanged: (val) {
                  if (val != null) {
                    controller.customerId.value = val.id.toString();
                    controller.selectedCustomerlist.value = val;
                  }
                },
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: 'Select Customer',
                    border: OutlineInputBorder(),
                  ),
                ),
                validator: (val) => val == null ? 'Select a customer' : null,
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(hintText: "Search Customer"),
                  ),
                ),
              ))
              ,

              const SizedBox(height: 12),

              // Supplier Dropdown
              Obx(() => DropdownSearch<CustomerList>(
                selectedItem: controller.selectedSuplierlist.value,
                items: controller.supplierList,
                itemAsString: (supplier) => supplier.accountName ?? "",
                onChanged: (val) {
                  if (val != null) {
                    controller.supplierId.value = val.id.toString();
                    controller.selectedSuplierlist.value = val;
                    controller.getDisputeDetails();
                  }
                },
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: 'Select Supplier',
                    border: OutlineInputBorder(),
                  ),
                ),
                validator: (val) => val == null ? 'Select a supplier' : null,
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(hintText: "Search Supplier"),
                  ),
                ),
              )),

              const SizedBox(height: 12),

              // Disputed Amount
              Obx(() => TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Disputed Amt.',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: controller.disputeAmt.value)
                  ..selection = TextSelection.collapsed(offset: controller.disputeAmt.value.length),
                onChanged: (val) {
                  controller.disputeAmt.value = val; // allow empty string
                },
              )),

              const SizedBox(height: 12),
              // Settled Amount
              Obx(() => TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Settled Amt.',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: controller.settelledAmt.value)
                  ..selection = TextSelection.collapsed(offset: controller.settelledAmt.value.length),
                onChanged: (val) {
                  final dispute = double.tryParse(controller.disputeAmt.value) ?? 0;
                  final settled = double.tryParse(val) ?? 0;

                  if (settled > dispute) {
                    // Show error message
                    Get.snackbar(
                      'Invalid Amount',
                      'Settled amount cannot be greater than disputed amount.',
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                    );

                    // Remove the last digit that was just typed
                    if (val.length > 1) {
                      if (settled < dispute){
                        final correctedVal = val.substring(0, val.length - 1);
                        controller.settelledAmt.value = correctedVal;
                      }else{
                    /*    final correctedVal = val.substring(0, val.length - 1);
                        controller.settelledAmt.value = correctedVal;*/
                        controller.settelledAmt.value = "";

                      }

                    } else {
                      controller.settelledAmt.value = "";
                    }
                  } else {
                    controller.settelledAmt.value = val;
                  }
                }

                ,
              )),
              const SizedBox(height: 12),

              // Upload File
              Obx(() => GestureDetector(
                onTap: controller.uploadDocument,
                child: DottedBorderBox(
                  child: Column(
                    children: [
                      const Text('5.0 MB maximum file size'),
                      const SizedBox(height: 8),
                      const Icon(Icons.upload_file, size: 30),
                      Text(
                        controller.selectedFileName.isEmpty
                            ? 'Upload Document'
                            : controller.selectedFileName.value,
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 24),

              // Save Button
              Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                ),
                onPressed: controller.saveDispute,
                child: controller.isSaveLoading.value
                    ? const Loader(color: Colors.white)
                    : const CustomText(
                  text: 'SAVE',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  textColor: Colors.white,
                ),
              ))

            ],

          ),
        ),
      ),
    );
  }
}

// Custom dotted box
class DottedBorderBox extends StatelessWidget {
  final Widget child;

  const DottedBorderBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.red,
          style: BorderStyle.solid,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
