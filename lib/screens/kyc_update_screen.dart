import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/auth_controller.dart';
import '../controllers/kyc_controller.dart';
import '../models/login_verify_response_model.dart';

class KycScreen extends StatefulWidget {
  KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final KycController controller = Get.put(KycController());
  final auth = AuthController.instance;
  final picker = ImagePicker();

  // Text controllers
  final rcController = TextEditingController();
  final insuranceController = TextEditingController();
  final panController = TextEditingController();
  final dlController = TextEditingController();
  final aadharController = TextEditingController();

  // Local selected files
  final RxMap<String, File?> selectedFiles = <String, File?>{
    'RC Book': null,
    'Driving License': null,
    'Aadhaar': null,
    'PAN Card': null,
    'Insurance': null,
  }.obs;

  // Uploaded document tick status
  final RxMap<String, bool> uploadedStatus = <String, bool>{
    'RC Book': false,
    'Driving License': false,
    'Aadhaar': false,
    'PAN Card': false,
    'Insurance': false,
  }.obs;

  @override
  void initState() {
    super.initState();

    ever(auth.userProfile, (_) => _prefillDocumentsFromProfile());

    if (auth.userProfile.value.documents != null) {
      _prefillDocumentsFromProfile();
    }
  }

  // ------------------------------------------------------------------------
  void _prefillDocumentsFromProfile() {
    final Driver user = auth.userProfile.value;
    final docs = user.documents;
    if (docs == null) return;

    // RC
    if (docs.rc != null) {
      rcController.text = docs.rc!.number ?? "";
      uploadedStatus["RC Book"] = true;
    }

    // DL
    if (docs.dl != null) {
      dlController.text = docs.dl!.number ?? "";
      uploadedStatus["Driving License"] = true;
    }

    // Aadhaar
    if (docs.aadhar != null) {
      aadharController.text = docs.aadhar!.number ?? "";
      uploadedStatus["Aadhaar"] = true;
    }

    // PAN
    if (docs.pan != null) {
      panController.text = docs.pan!.number ?? "";
      uploadedStatus["PAN Card"] = true;
    }

    // Insurance
    if (docs.insurance != null) {
      insuranceController.text = docs.insurance!.number ?? "";
      uploadedStatus["Insurance"] = true;
    }

    uploadedStatus.refresh();
    selectedFiles.refresh();
  }

  // ------------------------------------------------------------------------
  Future<void> pickFile(String docType) async {
    final source = await Get.dialog<ImageSource>(
      AlertDialog(
        title: const Text("Select Image Source"),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: ImageSource.camera),
            child: const Text("Camera"),
          ),
          TextButton(
            onPressed: () => Get.back(result: ImageSource.gallery),
            child: const Text("Gallery"),
          ),
        ],
      ),
    );

    if (source != null) {
      final picked = await picker.pickImage(source: source, imageQuality: 75);
      if (picked != null) {
        selectedFiles[docType] = File(picked.path);
        uploadedStatus[docType] = true; // show tick
        selectedFiles.refresh();
        uploadedStatus.refresh();
      }
    }
  }

  // ------------------------------------------------------------------------
  void submitKyc() {
    controller.updateKycDocuments(
      rcNumber: rcController.text,
      insuranceNumber: insuranceController.text,
      panNumber: panController.text,
      dlNumber: dlController.text,
      aadharNumber: aadharController.text,

      rcStatus: uploadedStatus["RC Book"]! ? "uploaded" : "pending",
      insuranceStatus: uploadedStatus["Insurance"]! ? "uploaded" : "pending",
      panStatus: uploadedStatus["PAN Card"]! ? "uploaded" : "pending",
      dlStatus: uploadedStatus["Driving License"]! ? "uploaded" : "pending",
      aadharStatus: uploadedStatus["Aadhaar"]! ? "uploaded" : "pending",

      rcFile: selectedFiles["RC Book"],
      insuranceFile: selectedFiles["Insurance"],
      dlFile: selectedFiles["Driving License"],
      panFile: selectedFiles["PAN Card"],
      aadharFile: selectedFiles["Aadhaar"],
    );
  }

  // ------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KYC Verification"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),

      body: Obx(
            () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : _buildForm(context),
      ),
    );
  }

  // ------------------------------------------------------------------------
  Widget _buildForm(context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            "Enter document numbers and upload files for verification.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),

          const SizedBox(height: 20),

          _buildInputField(rcController, "RC Number", "Enter RC number"),
          _buildInputField(
              insuranceController, "Insurance Number", "Enter insurance number"),
          _buildInputField(panController, "PAN Number", "Enter PAN number"),
          _buildInputField(dlController, "DL Number",
              "Enter Driving License number"),
          _buildInputField(
              aadharController, "Aadhaar Number", "Enter Aadhaar number"),

          const SizedBox(height: 20),

          Text("Upload Documents", style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),

          Obx(() {
            return Column(
              children: selectedFiles.keys.map((doc) {
                final hasUploaded = uploadedStatus[doc] ?? false;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(
                      color: hasUploaded ? Colors.green : Colors.grey.shade400,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        hasUploaded ? Icons.check_circle : Icons.upload_file,
                        color: hasUploaded ? Colors.green : Colors.grey[700],
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          doc,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      ElevatedButton(
                        onPressed: () => pickFile(doc),
                        child: Text(hasUploaded ? "Replace" : "Upload"),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),

          const SizedBox(height: 25),

          Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value ? null : submitKyc,
            child: controller.isLoading.value
                ? const Text("Submitting...")
                : const Text("Submit"),
          )),
        ],
      ),
    );
  }

  Widget _buildInputField(
      TextEditingController controller, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          label: Text(label),
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
