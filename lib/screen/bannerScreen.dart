import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newapp/controllers/BannerScreenController.dart';
import 'package:newapp/controllers/RegisterAccountController.dart';
import 'package:newapp/routes.dart';
import 'package:newapp/utils/CrossPlatformImagePicker.dart';
import 'package:newapp/utils/ImagePickerScreen.dart';
import 'package:newapp/utils/utils.dart';


class bannerScreen extends StatelessWidget {
  const bannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BannerScreenController controller = Get.put(BannerScreenController());
    final ImagePickerController imageController = Get.put(ImagePickerController());
    final GlobalKey imageKey = GlobalKey();
    final ScrollController scrollController = ScrollController();
    String? base64Image;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Update banners'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              final File? imageFile = imageController.pickedImage.value;
              final type = controller.selectedPartyType.value;

              if (imageFile != null) {
                final bytes = imageFile.readAsBytesSync();
                base64Image = base64Encode(bytes);
              }

              return Column(
                children: [

               /*   if (controller.bannerList.length<5)*/
                  GestureDetector(
                    onTap: () => _showSourcePicker(context),
                    child: Expanded(
                      child:
                      Obx(() {
                        final pickedFile = imageController.pickedImage.value;

                        return Container(
                          key: imageKey, // 👈 Add the key here
                          child: pickedFile != null
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
                        );
                      })

                    ),
                  ),
/*
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () => _showSourcePicker(context),
                      child: Obx(() {
                        final pickedFile = imageController.pickedImage.value;

                        return Container(
                          key: imageKey,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: pickedFile != null
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
                        );
                      }),
                    ),
                  ),*/



                  const SizedBox(height: 30),
                  Center(
                    child: Obx(() {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: controller.isUploading.value
                            ? null
                            : () async {
                          final File? imageFile = imageController.pickedImage.value;

                          if (imageFile == null) {
                            showSnackBar('Please select an image');
                            return;
                          }

                          controller.isUploading.value = true;

                          try {
                            final String base64Img = base64Encode(imageFile.readAsBytesSync());
                            controller.base64Image.value = base64Img;

                            await controller.bannerAddUpdateReq();

                            // ✅ Clear image after successful upload
                            imageController.pickedImage.value = null;
                            controller.base64Image.value = '';

                          } catch (e) {
                            showSnackBar('Error: $e');
                          } finally {
                            controller.isUploading.value = false;
                          }
                        },
                        child: controller.isUploading.value
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

            const SizedBox(height: 30),

            /// 🔽 Banner List View (fix layout inside scroll)
            Obx(() {
              if (controller.isDataLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.bannerList.isEmpty) {
                return const Center(child: Text('No data found'));
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.bannerList.length,
                itemBuilder: (context, index) {
                  final supplier = controller.bannerList[index];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        clipBehavior: Clip.none, // Allows overflow for negative top
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              supplier.bannerImagePath!,
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          ),

                          // Positioned icons cleanly *slightly above* image
                          Positioned(
                            top: -20,
                            right: 10,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                                    onPressed: () => controller.editBanner(supplier,imageController,imageKey,scrollController),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                    onPressed: () =>
                                        _showDeleteConfirmation(context, supplier.id.toString()),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30), // to give space for icons above
                    ],
                  );

                },
              );
            })


          ],
        ),
      ),

    );
  }

  void _showDeleteConfirmation(BuildContext context, String id) {
    final BannerScreenController controller = Get.put(BannerScreenController());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Banner"),
        content: const Text("Are you sure you want to delete this banner?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              controller.deleteBanner(id);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
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
                imagePickerController.pickImage3(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                imagePickerController.pickImage3(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }



  Widget _infoRow(String icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
      Expanded(
        child: Container(
          height: 180, // fixed height
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: AspectRatio(
                  aspectRatio: 2.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      icon,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.error, color: Colors.red));
                      },
                    ),
                  ),
                ),
              )



            ],
          ),
        ),
    ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }



}
