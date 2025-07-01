import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newapp/controllers/DisputeController.dart';
import 'package:newapp/customWidgets/customLoader.dart';
import 'package:newapp/customWidgets/customText.dart';
import 'package:newapp/utils/CrossPlatformImagePicker.dart';


class DisputeDetailsScreen extends StatelessWidget {
  const DisputeDetailsScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final DisputeController controller = Get.put(DisputeController());
    final ImagePickerController imageController = Get.put(ImagePickerController());
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
              TextFormField(
                controller: controller.disputeAmtController,
                decoration: const InputDecoration(
                  labelText: 'Disputed Amt.',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: controller.settelledAmtController,
                decoration: const InputDecoration(
                  labelText: 'Settled Amt.',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  final dispute = double.tryParse(controller.disputeAmt.value) ?? 0;
                  final settled = double.tryParse(val) ?? 0;

                  controller.settelledAmt.value = val;

                  if (settled > dispute) {
                    controller.isSettledAmtInvalid.value = true;
                  } else {
                    controller.isSettledAmtInvalid.value = false;
                  }
                },
              ),

              // ❗ Error message
              Obx(() => controller.isSettledAmtInvalid.value
                  ? const Padding(
                padding: EdgeInsets.only(top: 4, left: 8),
                child: Text(
                  'Settled amount cannot be greater than disputed amount.',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              )
                  : const SizedBox()),

              const SizedBox(height: 12),

              // Upload File
              Obx(() => GestureDetector(
                onTap: () {
                  _showSourcePicker(context); // Open camera/gallery picker
                },
                child: DottedBorder(
                  color: Colors.red,
                  dashPattern: [6, 4],
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Picked image or icon
                        imageController.pickedImage.value != null
                            ? Stack(
                          alignment: Alignment.topRight,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                imageController.pickedImage.value!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                imageController.pickedImage.value = null;
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.close, color: Colors.red, size: 25),
                              ),
                            ),
                          ],
                        )
                            : const Icon(Icons.upload_file, size: 40, color: Colors.red),

                        const SizedBox(height: 10),

                        // Info text
                        const Text('5.0 MB maximum file size', style: TextStyle(fontSize: 12, color: Colors.grey)),

                        const SizedBox(height: 6),

                        Text(
                          imageController.pickedImage.value != null
                              ? 'Image Selected'
                              : 'Upload Document',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
              )),

              const SizedBox(height: 24),

              // Save Button
              Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: controller.isDataLoading.value
                    ? null // Disable while loading
                    : () async {
                  controller.isDataLoading.value = true;

                  final File? imageFile = imageController.pickedImage.value;
                  final String? base64Image = imageFile != null
                      ? base64Encode(imageFile.readAsBytesSync())
                      : null;

                  controller.isDataLoading.value = false;
                  controller.selectedFileName.value = base64Image!;
                    controller.saveDispute(); // ⬅️ Call your save method

                },
                child: controller.isDataLoading.value
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text("SAVE", style: TextStyle(color: Colors.white)),
              ))


            ],

          ),
        ),
      ),
    );
  }
}

void _showSourcePicker(BuildContext context) {
  final ImagePickerController imagePickerController = Get.put(ImagePickerController());
  showModalBottomSheet(
    context: context,
    builder: (_) => SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text("Take a Photo"),
            onTap: () {
              Navigator.pop(context);
              imagePickerController.pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text("Choose from Gallery"),
            onTap: () {
              Navigator.pop(context);
              imagePickerController.pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    ),
  );
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
