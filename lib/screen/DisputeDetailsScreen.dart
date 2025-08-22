import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:newapp/controllers/DisputeController.dart';
import 'package:newapp/customWidgets/customLoader.dart';
import 'package:newapp/customWidgets/customText.dart';
import 'package:newapp/utils/CrossPlatformImagePicker.dart';


class DisputeDetailsScreen extends StatelessWidget {
  const DisputeDetailsScreen({super.key});



  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>(); // Put this in your widget class (e.g., controller or stateful widget)
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final GlobalKey<FormState> caseNumberKey = GlobalKey<FormState>();
    final DisputeController controller = Get.put(DisputeController());
    final ImagePickerController imageController = Get.put(ImagePickerController());
    final partyTypes = ['138', 'Civil',];
    final List<String> suggestions = [
      'Apple',
      'Banana',
      'Cherry',
      'Mango',
      'Orange',
      'Pineapple',
      'Strawberry',
      'Watermelon',
    ];
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Hide keyboard when tapped outside
        },
    child:  Scaffold(
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
        key: controller.selectCustomerKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Customer Dropdown
              Autocomplete<CustomerList>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return controller.customerList;
                  }
                  return controller.customerList.where((customer) {
                    return (customer.accountName ?? "")
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase());
                  });
                },
                displayStringForOption: (customer) => customer.accountName ?? "",
                onSelected: (CustomerList selection) {
                  controller.customerId.value = selection.id.toString();
                  controller.selectedCustomerlist.value = selection;
                  controller.formKey.currentState?.validate();
                  controller.customerError.value = null;
                },
                fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                  if (controller.selectedCustomerlist.value != null) {
                    textEditingController.text =
                        controller.selectedCustomerlist.value!.accountName ?? "";
                  }

                  // Wrap only this part in Obx for error text
                  return Obx(() => TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: 'Select Customer',
                      border: OutlineInputBorder(),
                      errorText: controller.customerError.value,
                    ),
                  ));
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 200, maxWidth: 300),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final customer = options.elementAt(index);
                            return ListTile(
                              title: Text(customer.accountName ?? ""),
                              onTap: () => onSelected(customer),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              )

              ,

              const SizedBox(height: 12),

              // Supplier Dropdown
              Autocomplete<CustomerList>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return controller.supplierList; // show all when empty
                  }
                  return controller.supplierList.where((supplier) =>
                      (supplier.accountName ?? '')
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase()));
                },
                displayStringForOption: (CustomerList supplier) =>
                supplier.accountName ?? '',
                onSelected: (CustomerList selection) {
                  controller.supplierId.value = selection.id.toString();
                  controller.selectedSuplierlist.value = selection;
                  controller.getDisputeDetails();
                },
                fieldViewBuilder:
                    (context, textEditingController, focusNode, onFieldSubmitted) {
                  // Set initial value if already selected
                  if (controller.selectedSuplierlist.value != null) {
                    textEditingController.text =
                        controller.selectedSuplierlist.value?.accountName ?? '';
                  }
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Select Supplier',
                      border: OutlineInputBorder(),
                    ),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200, maxWidth: 300),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final CustomerList option = options.elementAt(index);
                            return ListTile(
                              title: Text(option.accountName ?? ''),
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: controller.dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Dispute Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: controller.caseDate.value,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    controller.caseDate.value = pickedDate;
                    controller.dateController.text =
                        DateFormat('dd-MM-yyyy').format(pickedDate);
                  }
                },
          /*      validator: (value) =>
                value == null || value.isEmpty ? 'Select a dispute date' : null,*/
              ),
              const SizedBox(height: 12),
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'Case Type: ',
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                  ...partyTypes.map((type) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: type,
                        groupValue: controller.selectedCaseType.value,
                        activeColor: Colors.red,
                        onChanged: controller.isEditing
                            ? null
                            : (val) {
                          controller.selectedCaseType.value = val!;
                        },
                      ),
                      Text(
                        type,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: controller.selectedCaseType.value == type
                              ? Colors.red
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ))
                ],
              )),



              //const SizedBox(height: 12),


              Form(
                key: controller.formKey1,
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: controller.advocateNameController,
                            decoration: const InputDecoration(
                              labelText: 'Advocate Name',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.text,
                            validator: (_) => null, // ✅ Optional now
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Form(
                key: controller.formKey2,
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: controller.caseNumberController,
                            decoration: const InputDecoration(
                              labelText: 'Case No',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.text,
                            validator: (_) => null, // ✅ Optional now
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(), // Hides keyboard
                child: SingleChildScrollView( // Optional for scrollable content
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Column(
                      children: [

                        /// Disputed Amount
                        TextFormField(
                          controller: controller.disputeAmtController,
                          decoration: const InputDecoration(
                            labelText: 'Disputed Amt.',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),

                        const SizedBox(height: 12),

                        /// Settled Amount
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

                            controller.isSettledAmtInvalid.value = settled > dispute;
                          },
                        ),

                      ],
                    ),
                  ),
                ),
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
                    ? null
                    : () async {
                  // 🔍 Validate both forms
                  final isForm1Valid = controller.formKey1.currentState?.validate() ?? false;
                  final isForm2Valid = controller.formKey2.currentState?.validate() ?? false;
                  final isSelectCustomerKey = controller.selectCustomerKey.currentState?.validate() ?? false;

             if(!isSelectCustomerKey){
               return;
             }
                  if (!isForm1Valid || !isForm2Valid) {
                    // ❌ If any form is invalid, return early
                    return;
                  }

                  controller.isDataLoading.value = true;

                  final File? imageFile = imageController.pickedImage.value;
                  final String base64Image = imageFile != null
                      ? base64Encode(imageFile.readAsBytesSync())
                      : "";

                  controller.selectedFileName.value = base64Image;

                  // ✅ Save logic
                  await controller.saveDispute();

                  controller.isDataLoading.value = false;
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
    ));
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
