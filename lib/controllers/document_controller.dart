import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../routes/app_routes.dart';

class DocumentController extends GetxController {
  var uploadedDocs = <String, String>{}.obs;

// dart
  final vehicleInfo = ''.obs;
  final driverKyc = ''.obs;

  // dart
  Future<void> pickFile(String docType) async {
    final picker = ImagePicker();

    // Show dialog to choose source
    final source = await Get.dialog<ImageSource>(
      AlertDialog(
        title: const Text('Select Image Source'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: ImageSource.camera),
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () => Get.back(result: ImageSource.gallery),
            child: const Text('Gallery'),
          ),
        ],
      ),
    );

    if (source == null) {
      Get.snackbar("Cancelled", "No source selected for $docType");
      return;
    }

    final file = await picker.pickImage(source: source);

    if (file != null) {
      uploadedDocs[docType] = file.path;
      Get.snackbar("Success", "$docType uploaded");
    } else {
      Get.snackbar("Cancelled", "No file selected for $docType");
    }
  }

  void submitDocuments() {
    if (uploadedDocs.length < 3) {
      Get.snackbar("Missing", "Please upload all documents");
      return;
    }

    // TODO: Send to backend
    Get.snackbar("Submitted", "Documents submitted for review");
    Get.offAllNamed(Routes.LANDING);
  }
}
