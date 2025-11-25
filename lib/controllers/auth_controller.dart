import 'dart:async';
import 'dart:convert';
import 'package:commv_driver/models/otp_response_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';
import '../models/login_verify_response_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  static AuthController get instance {
    try {
      return Get.find<AuthController>();
    } catch (e) {
      return Get.put(AuthController());
    }
  }

  final ApiService _userService = ApiService();

  /// Observables
  OtpResponseModel? otpResponseModel;
  var userProfile = Driver().obs;

  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  var isOtpSent = false.obs;
  var isLoading = false.obs;
  final otpError = RxnString();

  // resend logic
  var isResendAvailable = false.obs;
  var resendSeconds = 30.obs;
  Timer? _resendTimer;
  var resendAttempts = 0.obs;
  final maxResendAttempts = 3;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  // ---------------------------------------------------------------------------
  // SEND OTP
  // ---------------------------------------------------------------------------
  void sendOtp() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      Get.snackbar("Error", "Enter mobile number");
      return;
    }

    isLoading.value = true;
    try {
      final response = await _userService.sendOtp(phone);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        otpResponseModel = OtpResponseModel.fromJson(data);

        isOtpSent.value = true;
        resendAttempts.value = 0;

        Get.snackbar(
          "OTP Sent",
          "${otpResponseModel?.message}  OTP: ${otpResponseModel?.otp}",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        startResendTimer();
      } else {
        final error = jsonDecode(response.body);
        Get.snackbar("Error", error['message'] ?? "Failed to send OTP");
      }
    } catch (e) {
      Get.snackbar("Error", "$e");
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // VERIFY OTP
  // ---------------------------------------------------------------------------
  void verifyOtp() async {
    final otp = otpController.text.trim();
    final phone = phoneController.text.trim();

    if (otp.length != 6) {
      otpError.value = "OTP must be 6 digits";
      return;
    }

    isLoading.value = true;
    otpError.value = null;

    var deviceToken = StorageService.instance.deviceToken ?? "";

    try {
      final response = await _userService.loginVerifyOtp(
        otp: otp,
        userphoneNo: phone,
        deviceToken: deviceToken,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final verifyModel = LoginVerifyModel.fromJson(data);

        StorageService.instance.setLoggedIn(true);
        StorageService.instance.saveToken(verifyModel.token ?? "");
        StorageService.instance.saveUserProfile(verifyModel.driver);

        _getUserProfile();

        Get.snackbar("Success", "Login successful",
            backgroundColor: Colors.green, colorText: Colors.white);

        if (!(verifyModel.driver?.isKycVerified ?? false)) {
          Get.offAllNamed(Routes.LANDING);

        } else {
          Get.offAllNamed(Routes.LANDING);
        }
      } else {
        otpController.clear();
        final error = jsonDecode(response.body);
        Get.snackbar("Error", error["message"] ?? "OTP verification failed");
      }
    } catch (e) {
      otpController.clear();
      otpError.value = "Something went wrong";
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // UPDATE PROFILE
  // ---------------------------------------------------------------------------
  Future<bool> updateProfile({
    required String mfirstName,
    String? mlastName,
    required String memail,
  }) async {
    isLoading.value = true;

    try {
      final response = await _userService.updateProfile(
        userFirstName: mfirstName.trim(),
        userLastName: mlastName?.trim() ?? "",
        userEmail: memail.trim(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedModel = LoginVerifyModel.fromJson(data);

        updatedModel.token = StorageService.instance.token;

        StorageService.instance.saveUserProfile(updatedModel.driver);

        _getUserProfile();

        Get.snackbar("Success", "Profile updated",
            backgroundColor: Colors.green, colorText: Colors.white);

        return true;
      } else {
        final error = jsonDecode(response.body);
        Get.snackbar("Error", error["error"] ?? "Failed to update profile");
      }
    } catch (e) {
      Get.snackbar("Error", "$e");
    } finally {
      isLoading.value = false;
    }

    return false;
  }

  // ---------------------------------------------------------------------------
  // KYC DOCUMENT UPLOAD
  // ---------------------------------------------------------------------------
  // Future<bool> uploadDocument({
  //   required String docType, // "aadhar" | "pan" | "rc" | "dl" | "insurance"
  //   required File file,
  //   String? number,
  // }) async {
  //   isLoading.value = true;
  //
  //   try {
  //     final response = await _userService.updateKycDocuments(
  //       file: file,
  //       docType: docType,
  //       number: number,
  //     );
  //
  //     if (response.statusCode == 200) {
  //       Get.snackbar("Success", "$docType uploaded",
  //           backgroundColor: Colors.green, colorText: Colors.white);
  //
  //       getProfile();
  //       return true;
  //     } else {
  //       final error = jsonDecode(response.body);
  //       Get.snackbar("Error", error['message'] ?? "Failed to upload");
  //     }
  //   } catch (e) {
  //     Get.snackbar("Error", "$e");
  //   } finally {
  //     isLoading.value = false;
  //   }
  //
  //   return false;
  // }

  // ---------------------------------------------------------------------------
  // GET PROFILE
  // ---------------------------------------------------------------------------
  Future<bool> getProfile() async {
    isLoading.value = true;

    try {
      final response = await _userService.getProfile();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final model = LoginVerifyModel.fromJson(data);

        model.token = StorageService.instance.token;

        StorageService.instance.saveUserProfile(model.driver);
        _getUserProfile();
        if (!(AuthController.instance.userProfile.value.isKycVerified ?? false)) {
          Get.toNamed(Routes.DOCUMENT);
        }
        return true;
      }
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  // ---------------------------------------------------------------------------
  // LOCAL PROFILE REFRESH
  // ---------------------------------------------------------------------------
  Driver _getUserProfile() {
    userProfile.value = StorageService.instance.userProfile ?? Driver();
    userProfile.refresh();
    return userProfile.value;
  }

  // ---------------------------------------------------------------------------
  // CHECK LOGIN STATUS
  // ---------------------------------------------------------------------------
  Future<bool> checkLoginStatus() async {
    if (StorageService.instance.isLoggedIn) {
      return await getProfile();
    }
    return false;
  }

  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Get.offAllNamed(Routes.LOGIN);
  }

  // ---------------------------------------------------------------------------
  // RESEND TIMER
  // ---------------------------------------------------------------------------
  void resetOtpFlow() {
    otpController.clear();
    isOtpSent.value = false;
    isResendAvailable.value = false;
    resendSeconds.value = 30;
    resendAttempts.value = 0;
    _resendTimer?.cancel();
  }

  void startResendTimer() {
    isResendAvailable.value = false;
    resendSeconds.value = 30;

    _resendTimer?.cancel();
    _resendTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
          if (resendSeconds.value == 0) {
            isResendAvailable.value = true;
            timer.cancel();
          } else {
            resendSeconds.value--;
          }
        });
  }

  void resendOtp() {
    if (resendAttempts.value >= maxResendAttempts) {
      Get.snackbar("Limit Reached",
          "You cannot resend OTP more than $maxResendAttempts times.");
      return;
    }
    resendAttempts.value++;
    sendOtp();
  }

  Future<bool> updateOnlineStatus() async {
    isLoading.value = true;

    try {
      final response = await _userService.updateOnlineStatus();

      if (response.statusCode == 200) {
        try{
          final data = jsonDecode(response.body);
          final otpResponse = LoginVerifyModel.fromJson(data);
          final storageService = StorageService.instance; // Get stored token
          var token = storageService.token;
          otpResponse.token = token ?? "";
          otpResponse.driver?.id;
          // Use the model fields for logic or UI
          Get.snackbar("Success", "Successfully updated availability status",
              backgroundColor: Colors.green, colorText: Colors.white);

          // You can pass the OTP to OTP screen via arguments if needed

          StorageService.instance.setLoggedIn(true);
          StorageService.instance.saveToken(otpResponse.token ?? "");
          StorageService.instance.saveUserProfile(otpResponse.driver);
          getProfile();
          return true;
        }catch(e){
          print(e);
        }
        return false;
      } else {
        // otpController.value.text = "";
        final error = jsonDecode(response.body);
        Get.snackbar("Error", error['error'] ?? "Failed to update availability status",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
      return false;
    } catch (e) {
      otpError.value = 'Something went wrong';
      otpController.text = "";
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  Future<bool> updateOfflineStatus() async {
    isLoading.value = true;

    try {
      final response = await _userService.updateOfflineStatus();

      if (response.statusCode == 200) {
        try{
          final data = jsonDecode(response.body);
          final otpResponse = LoginVerifyModel.fromJson(data);
          final storageService = StorageService.instance; // Get stored token
          var token = storageService.token;
          otpResponse.token = token ?? "";
          otpResponse.driver?.id;
          // Use the model fields for logic or UI
          Get.snackbar("Success", "Successfully updated availability status",
              backgroundColor: Colors.green, colorText: Colors.white);
          StorageService.instance.setLoggedIn(true);
          StorageService.instance.saveToken(otpResponse.token ?? "");
          StorageService.instance.saveUserProfile(otpResponse.driver);
          getProfile();
          return true;
        }catch(e){
          print(e);
        }
        return false;
      } else {
        // otpController.value.text = "";
        final error = jsonDecode(response.body);
        Get.snackbar("Error", error['error'] ?? "Failed to update availability status",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
      return false;
    } catch (e) {
      otpError.value = 'Something went wrong';
      otpController.text = "";
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    super.onClose();
  }
}
