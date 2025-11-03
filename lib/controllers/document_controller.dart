import 'dart:io';
import 'package:commv_driver/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../services/api_service.dart'; // ✅ Add this
import '../services/storage_service.dart'; // ✅ Add this if needed for token

class DocumentController extends GetxController {
  var uploadedDocs = <String, String>{}.obs;
  final vehicleInfo = ''.obs;
  final driverKyc = ''.obs;

  final apiService = ApiService(context: Get.context); // ✅ initialize service

  Future<void> pickFile(String docType) async {
    final picker = ImagePicker();

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

  /// ✅ NEW: Submit all KYC data + uploaded files to backend
  Future<void> submitDocuments() async {
    if (uploadedDocs.isEmpty) {
      Get.snackbar("Missing", "Please upload at least one document");
      return;
    }

    try {
      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);

      final response = await apiService.updateKycDocuments(
        rcStatus: 'pending',
        insuranceNumber: 'INS-9988-7766',
        panNumber: 'ABCDE1234F',
        aadharStatus: 'pending',
        insuranceStatus: 'pending',
        panStatus: 'pending',
        dlNumber: 'DL-0123-4567',
        rcNumber: 'UP80AB1234',
        dlStatus: 'pending',
        aadharNumber: '1234-5678-9012',

        // ✅ Attach selected files if available
        rcFile: uploadedDocs['RC Book'] != null ? File(uploadedDocs['RC Book']!) : null,
        dlFile: uploadedDocs['Driving License'] != null ? File(uploadedDocs['Driving License']!) : null,
        aadharFile: uploadedDocs['Aadhaar'] != null ? File(uploadedDocs['Aadhaar']!) : null,
      );

      Get.back(); // close loader

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("✅ Success", "Documents submitted successfully");
        Get.offAllNamed(Routes.LANDING);
      } else {
        Get.snackbar("Error ${response.statusCode}", "Upload failed");
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Error", "Something went wrong: $e");
    }
  }
}
