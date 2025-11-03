import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/kyc_controller.dart';

class KycScreen extends StatelessWidget {
  KycScreen({super.key});

  final KycController controller = Get.put(KycController());
  final picker = ImagePicker();

  // Text controllers
  final rcController = TextEditingController();
  final insuranceController = TextEditingController();
  final panController = TextEditingController();
  final dlController = TextEditingController();
  final aadharController = TextEditingController();

  // ✅ Make this observable properly at the widget level
  final RxMap<String, File?> selectedFiles = <String, File?>{
    'RC Book': null,
    'Driving License': null,
    'Aadhaar': null,
    'PAN Card': null,
    'Insurance': null,
  }.obs;

  Future<void> pickFile(String docType) async {
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

    if (source != null) {
      final picked = await picker.pickImage(source: source, imageQuality: 75);
      if (picked != null) {
        selectedFiles[docType] = File(picked.path); // ✅ now works
        Get.snackbar('Uploaded', '$docType selected successfully');
      }
    }
  }


  void submitKyc() {
    if (rcController.text.isEmpty ||
        insuranceController.text.isEmpty ||
        panController.text.isEmpty ||
        dlController.text.isEmpty ||
        aadharController.text.isEmpty) {
      Get.snackbar('Missing Fields', 'Please fill all document numbers.');
      return;
    }

    controller.updateKycDocuments(
      rcStatus: 'pending',
      insuranceNumber: insuranceController.text,
      panNumber: panController.text,
      aadharStatus: 'pending',
      insuranceStatus: 'pending',
      panStatus: 'pending',
      dlNumber: dlController.text,
      rcNumber: rcController.text,
      dlStatus: 'pending',
      aadharNumber: aadharController.text,
      rcFile: selectedFiles['RC Book'],
      insuranceFile: selectedFiles['Insurance'],
      dlFile: selectedFiles['Driving License'],
      panFile: selectedFiles['PAN Card'],
      aadharFile: selectedFiles['Aadhaar'],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Verification'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Please enter your document numbers and upload files for verification.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Text fields
            _buildInputField(rcController, 'RC Number', 'Enter RC number'),
            _buildInputField(insuranceController, 'Insurance Number', 'Enter insurance number'),
            _buildInputField(panController, 'PAN Number', 'Enter PAN number'),
            _buildInputField(dlController, 'DL Number', 'Enter driving license number'),
            _buildInputField(aadharController, 'Aadhaar Number', 'Enter Aadhaar number'),

            const SizedBox(height: 24),

            Text(
              'Upload Documents',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // ✅ Observe selectedFiles here
            Obx(() {
              return Column(
                children: selectedFiles.keys.map((doc) {
                  final file = selectedFiles[doc];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: file != null ? Colors.green : Colors.grey.shade400,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          file != null ? Icons.check_circle : Icons.insert_drive_file,
                          color: file != null ? Colors.green : Colors.grey[700],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              if (file != null)
                                Text(
                                  file.path.split('/').last,
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.grey),
                                ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => pickFile(doc),
                          icon: const Icon(Icons.upload),
                          label: Text(file != null ? 'Replace' : 'Upload'),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }),

            const SizedBox(height: 30),

            // Submit Button
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.isLoading.value ? null : submitKyc,
                icon: const Icon(Icons.send),
                label: controller.isLoading.value
                    ? const Text('Submitting...')
                    : const Text('Submit Documents'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )),
          ],
        ),
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
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
