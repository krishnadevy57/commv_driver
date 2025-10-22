import 'dart:convert';
import 'dart:io';
import 'package:commv_driver/services/storage_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;

import '../models/address_model.dart';
import '../models/vehicle_list_response.dart';

class ApiService {
  final String baseUrl = 'https://commv.skillupstream.com';

  Future<http.Response> sendOtp(String phoneNumber) async {
    final url = Uri.parse('$baseUrl/api/driver/phone/send-otp');

    final headers = {
      'accept': '*/*',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({"driverPhoneNo": phoneNumber});

    return await http.post(url, headers: headers, body: body);
  }


  Future<http.Response> loginVerifyOtp({
    required String otp,
    required String userphoneNo,
    required String deviceToken,
  }) async {
    final url = Uri.parse('$baseUrl/api/driver/phone/verify');

    final headers = {
      'accept': '*/*',
      'Content-Type': 'application/json',
    };

    final deviceDetails = await getDeviceDetails();

    final body = jsonEncode({
      "driverPhoneNo": userphoneNo,
      "otp": otp,
      "deviceId": deviceDetails['deviceId'],
      "deviceType": deviceDetails['deviceType'],
      "deviceToken": deviceToken,
    });

    return await http.post(url, headers: headers, body: body);
  }

  Future<http.Response> updateProfile({
    required String userFirstName,
    required String userLastName,
    required String userEmail,
  }) async {
    final url = Uri.parse('$baseUrl/api/driver/profile/update');

    final storageService = await StorageService.instance; // Get stored token
    var token = await storageService.token;
    final headers = {
      'accept': '*/*',
      "Content-Type": "application/json",
      "Authorization": "Bearer ${storageService.token}", // Include the token here
    };


    final body = jsonEncode({
      "driverFirstName": userFirstName,
      "driverLastName": userLastName,
      "driverEmail": userEmail,
    });

    return await http.put(url, headers: headers, body: body);
  }


  Future<void> updateDriverDocuments() async {
    final url = Uri.parse('$baseUrl/api/driver/documents');
    final storageService = await StorageService.instance; // Get stored token
    var token = await storageService.token;


    // Example file paths (replace with actual picked files or File objects)
    File? dlFile; // e.g., File('/path/to/dlFile.png')
    File? rcFile;
    File? aadharFile;
    File? insuranceFile;
    File? panFile;

    var request = http.MultipartRequest("PATCH", url);

    // Add headers
    request.headers.addAll({
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'multipart/form-data',
    });

    // Add fields
    request.fields['rcStatus'] = 'pending';
    request.fields['insuranceNumber'] = 'INS-9988-7766';
    request.fields['panNumber'] = 'ABCDE1234F';
    request.fields['aadharStatus'] = 'pending';
    request.fields['insuranceStatus'] = 'pending';
    request.fields['panStatus'] = 'pending';
    request.fields['dlNumber'] = 'DL-0123-4567';
    request.fields['rcNumber'] = 'UP80AB1234';
    request.fields['dlStatus'] = 'pending';
    request.fields['aadharNumber'] = '1234-5678-9012';

    // Add files if available
    if (dlFile != null) {
      request.files.add(await http.MultipartFile.fromPath('dlFile', dlFile.path));
    }
    if (rcFile != null) {
      request.files.add(await http.MultipartFile.fromPath('rcFile', rcFile.path));
    }
    if (aadharFile != null) {
      request.files.add(await http.MultipartFile.fromPath('aadharFile', aadharFile.path));
    }
    if (insuranceFile != null) {
      request.files.add(await http.MultipartFile.fromPath('insuranceFile', insuranceFile.path));
    }
    if (panFile != null) {
      request.files.add(await http.MultipartFile.fromPath('panFile', panFile.path));
    }

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        print("✅ Success: $respStr");
      } else {
        print("❌ Failed with status: ${response.statusCode}");
        print(await response.stream.bytesToString());
      }
    } catch (e) {
      print("⚠️ Error: $e");
    }
  }


  Future<http.Response> updateOnlineStatus() async {
    final url = Uri.parse('$baseUrl/api/driver/status/online');

    final storageService = await StorageService.instance; // Get stored token
    var token = await storageService.token;
    final headers = {
      'accept': '*/*',
      "Content-Type": "application/json",
      "Authorization": "Bearer ${storageService.token}", // Include the token here
    };


    return await http.post(url, headers: headers);
  }

  Future<http.Response> updateOfflineStatus() async {
    final url = Uri.parse('$baseUrl/api/driver/status/offline');

    final storageService = await StorageService.instance; // Get stored token
    var token = await storageService.token;
    final headers = {
      'accept': '*/*',
      "Content-Type": "application/json",
      "Authorization": "Bearer ${storageService.token}", // Include the token here
    };


    return await http.post(url, headers: headers);
  }

  Future<http.Response> getProfile() async {
    final url = Uri.parse('$baseUrl/api/driver/me');

    final storageService = await StorageService.instance; // Get stored token
    var token = await storageService.token;
    final headers = {
      'accept': '*/*',
      "Content-Type": "application/json",
      "Authorization": "Bearer ${storageService.token}", // Include the token here
    };

    return await http.get(url, headers: headers);
  }



  Future<Map<String, String>> getDeviceDetails() async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceId = '';
    String deviceType = '';

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id ?? 'unknown';
      deviceType = 'android';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? 'unknown';
      deviceType = 'ios';
    }else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? 'unknown';
      deviceType = 'other';
    }

    return {
      'deviceId': deviceId,
      'deviceType': deviceType,
    };
  }


  Future<void> fetchVehicleList() async {
    final url = Uri.parse('$baseUrl/api/vehicle');

    try {
      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        print('Response Body: ${response.body}');
        // You can decode JSON here if needed
        // final data = jsonDecode(response.body);
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  static Future<ApiResponse> submitReview({
    required AddressModel pickupAddress,
    required AddressModel dropAddress,
    required Vehicle vehicle,
    required String packageType,
    required int numberOfPieces,
  }) async {
    try {
      final url = Uri.parse('https://your.api/submit-review');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pickup_address': pickupAddress.toMap(),
          'drop_address': dropAddress.toMap(),
          'vehicle': vehicle.toJson(),
          'package_type': packageType,
          'number_of_pieces': numberOfPieces,
        }),
      );

      if (response.statusCode == 200) {
        return ApiResponse(isSuccess: true);
      } else {
        return ApiResponse(isSuccess: false, message: 'Failed: ${response.body}');
      }
    } catch (e) {
      return ApiResponse(isSuccess: false, message: e.toString());
    }
  }
}
class ApiResponse {
  final bool isSuccess;
  final String? message;
  ApiResponse({required this.isSuccess, this.message});
}