import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newapp/utils/CrossPlatformImagePicker.dart';


class ImagePickerScreen extends StatelessWidget {
  final ImagePickerController controller = Get.find<ImagePickerController>();

  void _showSourcePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text("Take a Photo"),
              onTap: () {
                Navigator.pop(context);
                controller.pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                controller.pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('GetX Image Picker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Obx(() {
              File? image = controller.pickedImage.value;
              return image != null
                  ? Image.file(image, height: 200, width: 200, fit: BoxFit.cover)
                  : Container(
                height: 200,
                width: 200,
                color: Colors.grey[300],
                child: Icon(Icons.image, size: 100),
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showSourcePicker(context),
              child: Text("Pick Image"),
            ),
            const SizedBox(height: 20),
            Obx(() {
              final path = controller.imagePath;
              return Text(
                path != null ? "Path: $path" : "No image selected",
                style: TextStyle(fontSize: 14),
              );
            }),
          ],
        ),
      ),
    );
  }
}
