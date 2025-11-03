import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:commv_driver/services/api_service.dart';

class KycController extends GetxController {
  final ApiService apiService = ApiService();
  var isLoading = false.obs;
  var responseMessage = ''.obs;

  Future<void> updateKycDocuments({
    required String rcStatus,
    required String insuranceNumber,
    required String panNumber,
    required String aadharStatus,
    required String insuranceStatus,
    required String panStatus,
    required String dlNumber,
    required String rcNumber,
    required String dlStatus,
    required String aadharNumber,
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

      final responseStr = await streamedResponse.stream.bytesToString();
      final responseJson = jsonDecode(responseStr);

      if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) {
        responseMessage.value = responseJson['message'] ?? 'Documents updated successfully!';
        Get.snackbar('Success', responseMessage.value);
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
