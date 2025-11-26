import 'dart:io';
import 'dart:convert';
import 'package:commv_driver/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:commv_driver/services/api_service.dart';

class KycController extends GetxController {
  final ApiService apiService = ApiService();
  var isLoading = false.obs;
  var responseMessage = ''.obs;
  final RxMap<String, String> serverFiles = <String, String>{}.obs;


  Future<void> updateKycDocuments({
     String? rcStatus,
     String? insuranceNumber,
     String? panNumber,
     String? aadharStatus,
     String? insuranceStatus,
     String? panStatus,
     String? dlNumber,
     String? rcNumber,
     String? dlStatus,
     String? aadharNumber,
    File? rcFile,
    File? insuranceFile,
    File? dlFile,
    File? panFile,
    File? aadharFile,
  }) async {
    try {
      isLoading(true);

      final streamedResponse = await apiService.updateKycDocuments(
        rcStatus: rcStatus,
        insuranceNumber: insuranceNumber,
        panNumber: panNumber,
        aadharStatus: aadharStatus,
        insuranceStatus: insuranceStatus,
        panStatus: panStatus,
        dlNumber: dlNumber,
        rcNumber: rcNumber,
        dlStatus: dlStatus,
        aadharNumber: aadharNumber,
        rcFile: rcFile,
        insuranceFile: insuranceFile,
        dlFile: dlFile,
        panFile: panFile,
        aadharFile: aadharFile,
      );

      final responseStr =  streamedResponse.body;
      final responseJson = jsonDecode(responseStr);

      if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) {
        responseMessage.value = responseJson['message'] ?? 'Documents updated successfully!';
        Get.snackbar('Success', responseMessage.value);
        AuthController.instance.getProfile();
        Future.delayed(const Duration(milliseconds: 600), () {
          Get.back();      // Go back 1 screen
          // Get.back();   // If you want to go back 2 screens
        });
      } else {
        final errorMessage = responseJson['message'] ?? 'Something went wrong';
        responseMessage.value = errorMessage;
        Get.snackbar('Error', errorMessage);
      }
    } catch (e) {
      print('❌ Exception: $e');
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }
}
