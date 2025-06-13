import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newapp/controllers/RegisterAccountController.dart';
import 'package:newapp/utils/CrossPlatformImagePicker.dart';
import 'package:newapp/utils/ImagePickerScreen.dart';


class RegisterAccountScreen extends StatelessWidget {
  const RegisterAccountScreen({super.key});



  @override
  Widget build(BuildContext context) {
    final RegisterAccountController controller = Get.put(RegisterAccountController());
    final ImagePickerController imageController = Get.put(ImagePickerController());
    String? base64Image;
    String? accountType="Customer";





    final partyTypes = ['Customer', 'Supplier', 'Other'];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Register Accounts'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              backgroundColor: Colors.red,
              child: Text("AC", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*const Text("Party Type*", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),*/

              // Party Type Choice Chips
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: partyTypes.map((type) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: type,
                        groupValue: controller.selectedPartyType.value,
                        activeColor: Colors.red,
                        onChanged: (val) {
                          controller.selectedPartyType.value = val!;
                          controller.clearFormFields();
                          imageController.pickedImage.value = null;
                          accountType = val;
                        },
                      ),
                      Text(
                        type,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: controller.selectedPartyType.value == type ? Colors.red : Colors.black,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  );
                }).toList(),
              )),

             /* const SizedBox(height: 20),*/

              // Conditionally render fields based on party type
              Obx(() {
                final File? imageFile = imageController.pickedImage.value;
                final type = controller.selectedPartyType.value;


                if (imageFile != null) {
                  final bytes = imageFile.readAsBytesSync(); // Read file bytes
                  base64Image = base64Encode(bytes);         // Convert to Base64
                }
                return Column(
                  children: [
                    if (type == 'Customer' || type == 'Supplier' || type == 'Other') ...[
                      _buildTextField("Firm Name", controller.firmNameController),
                    ],

                    _buildTextField("Owner Name", controller.ownerNameController),
                    _buildTextField("Mobile Number", controller.mobileController, keyboardType: TextInputType.phone,),
                    _buildTextField("Address", controller.addressController),
               /*     _buildTextField("Station Name", controller.stationNameController),
                    _buildTextField("User Category", controller.categoryController),*/
          /*          DropdownButton<String>(
                      value: controller.selectedCategory.value.isEmpty ? null : controller.selectedCategory.value,
                      items: ['Admin', 'Supplier', 'Customer'].map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        controller.selectedCategory.value = value!;
                        controller.categoryController.text = value; // Keep in sync if needed
                      },
                    ),*/

                    if (type == 'Customer') ...[
                      _buildTextField("GST No.", controller.gstController),

                    ],
                    if (type == 'Other') ...[
                      _buildTextField("Station Name", controller.stationNameController),
                      Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedCategory.value.isEmpty
                            ? null
                            : controller.selectedCategory.value,
                        decoration: InputDecoration(
                          labelText: "User Category",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: ['Admin', 'Executive'].map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          controller.selectedCategory.value = value!;
                          controller.categoryController.text = value;
                        },
                      )),


                    ],


                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () {
                        _showSourcePicker(context); // open camera/gallery picker
                      },
                      child:
                      Row(
                        children: [
                          // Account Image
                          Expanded(
                            child: Obx(() {
                              final pickedFile = imageController.pickedImage.value;

                              return DottedBorder(
                                color: Colors.red,
                                dashPattern: [6, 4],
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      pickedFile != null
                                          ? Stack(
                                        alignment: Alignment.topRight,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.file(
                                              pickedFile,
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
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.red,
                                                size: 25,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                          : const Icon(Icons.upload_file, color: Colors.red, size: 40),
                                      const SizedBox(height: 10),
                                      Text(
                                        (type == 'Customer' || type == 'Supplier')
                                            ? "Account Image"
                                            : "Upload Document",
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                      const SizedBox(height: 5),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),


                          const SizedBox(width: 10),
                          // Shop Image
                       /*   if((type == 'Customer' || type == 'Supplier'))
                          Expanded(
                            child: Obx(() {
                              final pickedFile = imageController.shopImage.value;
                              return DottedBorder(
                                color: Colors.red,
                                dashPattern: [6, 4],
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      pickedFile != null
                                          ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          pickedFile,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                          : const Icon(Icons.upload_file, color: Colors.red, size: 40),

                                      const SizedBox(height: 10),

                                      // Always show label and size info
                                      Text(
                                        (type == 'Customer' || type == 'Supplier')
                                            ? "Shop Image"
                                            : "Upload Document",
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                      const SizedBox(height: 5),
                                   *//*   const Text(
                                        "10.0 MB maximum file size",
                                        style: TextStyle(fontSize: 12, color: Colors.grey),
                                      ),*//*
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),*/
                        ],
                      )

                    ),

                    const SizedBox(height: 30),
                    Center(
                      child: Obx(() {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: controller.isDataLoading.value
                              ? null // Disable button when loading
                              : () async {
                            controller.isDataLoading.value = true;
                            final File? imageFile = imageController.shopImage.value;

                            final String? base64Image = imageFile != null
                                ? base64Encode(imageFile.readAsBytesSync())
                                : null;

// Also handle accountType
                            final String? accountType = controller.selectedPartyType.value.isEmpty
                                ? null
                                : controller.selectedPartyType.value;
                            bool success = await controller.validation(base64Image, accountType);
                            controller.isDataLoading.value = false;

                            if (success) {
                              // controller.saveUpdateAccountDetails();
                            }
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
                        );
                      }),
                    ),
                  ],
                );
              }),
            ]

        ),
      ),
    );
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


  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    );
  }




}
