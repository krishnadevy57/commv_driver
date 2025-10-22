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

class AuthController extends GetxController {
  static AuthController get instance {
    try {
      return Get.find<AuthController>();
    } catch (e) {
      return Get.put(AuthController());
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getUserProfile();
  }
  final ApiService _userService = ApiService();
  OtpResponseModel? otpResponseModel;

  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  var isOtpSent = false.obs;
  var isLoading = false.obs;
  final otpError = RxnString();

  // 🔁 Resend OTP
  var isResendAvailable = false.obs;
  var resendSeconds = 30.obs;
  Timer? _resendTimer;
  var resendAttempts = 0.obs;
  final maxResendAttempts = 3;
  var userProfile = Driver().obs;

  void sendOtp() async {
    final phone = phoneController.value.text.trim();
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
        // Get.snackbar("OTP Sent", "OTP has been sent to ${phoneController.text}");

        // Use the model fields for logic or UI
        Get.snackbar(
            "Success", "${otpResponseModel?.message}  ${otpResponseModel?.otp}",
            backgroundColor: Colors.green, colorText: Colors.white);

        // You can pass the OTP to OTP screen via arguments if needed
        isOtpSent.value = true;
        isLoading.value = false;
        resendAttempts.value = 0; // reset attempts on first send

        startResendTimer();
        // Get.toNamed(
        //   AppRoutes.otp,
        // );
      } else {
        final error = jsonDecode(response.body);
        Get.snackbar("Error", error['message'] ?? "Failed to send OTP",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }

  }

  void verifyOtp() async {
    final otp = otpController.value.text.trim();
    final phone = phoneController.value.text.trim();

    if (otp.length != 6) {
      otpError.value = 'OTP must be 6 digits';
      return;
    }

    isLoading.value = true;
    otpError.value = null;

    // Replace with your actual FCM/device token retrieval logic
    const deviceToken = 'your_device_token';

    try {
      final response = await _userService.loginVerifyOtp(
          otp: otp,
          userphoneNo: phone,
          deviceToken: deviceToken);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final otpResponse = LoginVerifyModel.fromJson(data);

        otpResponse.driver?.id;
        // Use the model fields for logic or UI
        Get.snackbar("Success", "Successfully verified",
            backgroundColor: Colors.green, colorText: Colors.white);
        StorageService.instance.setLoggedIn(true);
        StorageService.instance.saveToken(otpResponse.token ?? "");
        StorageService.instance.saveUserProfile(otpResponse.driver);
        getUserProfile();
        // You can pass the OTP to OTP screen via arguments if needed
        if ((otpResponseModel?.action ?? "") == "login") {
          Get.offAllNamed(Routes.LANDING);
          if(!(otpResponse.driver?.isKycVerified??false)){
            Get.toNamed(Routes.DOCUMENT);
          }
        } else {
          Get.offAllNamed(Routes.LANDING);
          if(!(otpResponse.driver?.isKycVerified??false)){
            Get.toNamed(Routes.DOCUMENT);
          }
          Get.toNamed(
            Routes.SIGNUP,
          );
        }

      } else {
        otpController.text = "";
        final error = jsonDecode(response.body);
        Get.snackbar("Error", error['message'] ?? "Failed to verify OTP",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      otpError.value = 'Something went wrong';
      otpController.text = "";
    } finally {
      isLoading.value = false;
    }

  }

  Future<bool> updateProfile({required String mfirstName,String? mlastName,required String memail}) async {
    final firstName = mfirstName.trim();
    final lastName = mlastName?.trim();
    final email = memail.trim();

    if (firstName.isEmpty || email.isEmpty) {
      Get.snackbar("Error", "Please fill all fields",
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    isLoading.value = true;

    try {
      final response = await _userService.updateProfile(
          userFirstName: firstName,
          userLastName: lastName??"",
          userEmail: email);

      if (response.statusCode == 200) {
        try{


          final data = jsonDecode(response.body);
          final otpResponse = LoginVerifyModel.fromJson(data);
          final storageService = StorageService.instance; // Get stored token
          var token = storageService.token;
          otpResponse.token = token ?? "";
          otpResponse.driver?.id;
          // Use the model fields for logic or UI
          Get.snackbar("Success", "Successfully updated profile",
              backgroundColor: Colors.green, colorText: Colors.white);

          // You can pass the OTP to OTP screen via arguments if needed

          StorageService.instance.setLoggedIn(true);
          StorageService.instance.saveToken(otpResponse.token ?? "");
          StorageService.instance.saveUserProfile(otpResponse.driver);
          getUserProfile();
          // Get.offAllNamed(Routes.LANDING);
          return true;
        }catch(e){
          print(e);
        }
        return false;
      } else {
        // otpController.value.text = "";
        final error = jsonDecode(response.body);
        Get.snackbar("Error", error['error'] ?? "Failed to updated profile",
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
          getUserProfile();
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
          getUserProfile();
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

  Future<bool> getProfile() async {

    isLoading.value = true;

    try {
      final response = await _userService.getProfile();

      if (response.statusCode == 200) {
        try{


          final data = jsonDecode(response.body);
          final otpResponse = LoginVerifyModel.fromJson(data);
          final storageService = StorageService.instance; // Get stored token
          var token = storageService.token;
          otpResponse.token = token ?? "";
          otpResponse.driver?.id;
          // Use the model fields for logic or UI
          Get.snackbar("Success", "Successfully verified",
              backgroundColor: Colors.green, colorText: Colors.white);

          // You can pass the OTP to OTP screen via arguments if needed

          StorageService.instance.setLoggedIn(true);
          StorageService.instance.saveToken(otpResponse.token ?? "");
          StorageService.instance.saveUserProfile(otpResponse.driver);
          getUserProfile();
          // Get.offAllNamed(Routes.LANDING);
          return true;
        }catch(e){
          print(e);
        }
        return false;
      } else {
        // otpController.value.text = "";
        final error = jsonDecode(response.body);
        Get.snackbar("Error", error['error'] ?? "Failed to verify OTP",
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

  Future<bool> checkLoginStatus() async {
    var prefs = StorageService.instance;
    if (prefs.isLoggedIn) {
      getUserProfile();
      return true;
    } else {
      return false;
    }
  }
  Driver getUserProfile()  {
    var prefs = StorageService.instance;
    userProfile.value = prefs.userProfile??Driver();
    userProfile.refresh();
    return userProfile.value;
  }
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Get.offAllNamed(Routes.LOGIN);
  }

  void resetOtpFlow() {
    otpController.clear();
    isOtpSent.value = false;
    isResendAvailable.value = false;
    resendSeconds.value = 30;
    resendAttempts.value = 0;
    _resendTimer?.cancel();
  }

  // 🔁 Resend OTP
  void startResendTimer() {
    isResendAvailable.value = false;
    resendSeconds.value = 30;

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
      Get.snackbar("Limit Reached", "You cannot resend OTP more than $maxResendAttempts times.");
      return;
    }

    resendAttempts.value++;
    sendOtp(); // just reuse same sendOtp()
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    super.onClose();
  }
}
