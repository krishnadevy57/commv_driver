import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/document_controller.dart';

class DocumentScreen extends StatelessWidget {
  final controller = Get.put(DocumentController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Upload Documents",
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white, // force white
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white), // back arrow color
        actionsIconTheme: const IconThemeData(color: Colors.white), // if you add actions
        foregroundColor: Colors.white, // fallback for text/icons
      ),
      backgroundColor: Colors.grey[100],
      body: Obx(() => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoCard(
              context,
              title: "Vehicle Info",
              subtitle: controller.vehicleInfo.value.isEmpty
                  ? "No vehicle info added"
                  : controller.vehicleInfo.value,
              icon: Icons.directions_car,
              color: Colors.blue,
              onTap: () => _showVehicleDialog(context),
              buttonText: controller.vehicleInfo.value.isEmpty
                  ? "Add Vehicle Info"
                  : "Update Vehicle Info",
            ),
            _buildInfoCard(
              context,
              title: "Driver KYC",
              subtitle: controller.driverKyc.value.isEmpty
                  ? "No KYC info added"
                  : controller.driverKyc.value,
              icon: Icons.verified_user,
              color: Colors.green,
              onTap: () => _showDriverDialog(context),
              buttonText: controller.driverKyc.value.isEmpty
                  ? "Add Driver KYC"
                  : "Update Driver KYC",
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Upload Documents",
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            _buildUploadBtn(context, "Driving License", Icons.badge),
            _buildUploadBtn(context, "RC Book", Icons.book),
            _buildUploadBtn(context, "Aadhaar", Icons.credit_card),
            const SizedBox(height: 80),
          ],
        ),
      )),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            backgroundColor: colorScheme.primary,
          ),
          onPressed: controller.submitDocuments,
          child: Text("Submit",
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              )),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInfoCard(BuildContext context,
      {required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required String buttonText,
        required VoidCallback onTap}) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: onTap,
              child: Text(buttonText),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildUploadBtn(
      BuildContext context, String docType, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3))
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primary.withOpacity(0.1),
          child: Icon(icon, color: colorScheme.primary),
        ),
        title: Text(
          controller.uploadedDocs[docType] != null
              ? "$docType ✔"
              : "Upload $docType",
          style: theme.textTheme.bodyLarge,
        ),
        trailing: IconButton(
          icon: Icon(Icons.upload, color: colorScheme.primary),
          onPressed: () => controller.pickFile(docType),
        ),
      ),
    );
  }

  void _showVehicleDialog(BuildContext context) {
    final typeController = TextEditingController();
    final nameController = TextEditingController();
    final modelController = TextEditingController();
    final numberController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Vehicle Info",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildTextField(typeController, "Vehicle Type", Icons.category),
                _buildTextField(nameController, "Vehicle Name", Icons.drive_eta),
                _buildTextField(modelController, "Vehicle Model", Icons.directions_car),
                _buildTextField(numberController, "Vehicle Number", Icons.numbers),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel")),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (typeController.text.isNotEmpty &&
                            nameController.text.isNotEmpty &&
                            modelController.text.isNotEmpty &&
                            numberController.text.isNotEmpty) {
                          controller.vehicleInfo.value =
                          "Type: ${typeController.text}\n"
                              "Name: ${nameController.text}\n"
                              "Model: ${modelController.text}\n"
                              "Number: ${numberController.text}";
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Vehicle info saved")));
                        }
                      },
                      child: const Text("Save"),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDriverDialog(BuildContext context) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final licenseController = TextEditingController();
    final aadhaarController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Driver KYC",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildTextField(nameController, "Driver Name", Icons.person),
                _buildTextField(addressController, "Driver Address", Icons.home),
                _buildTextField(licenseController, "License Number", Icons.badge),
                _buildTextField(aadhaarController, "Aadhaar Number", Icons.credit_card),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel")),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (nameController.text.isNotEmpty &&
                            addressController.text.isNotEmpty &&
                            licenseController.text.isNotEmpty &&
                            aadhaarController.text.isNotEmpty) {
                          controller.driverKyc.value =
                          "Name: ${nameController.text}\n"
                              "Address: ${addressController.text}\n"
                              "License: ${licenseController.text}\n"
                              "Aadhaar: ${aadhaarController.text}";
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Driver KYC saved")));
                        }
                      },
                      child: const Text("Save"),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Reusable text field builder with icons
  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

}
