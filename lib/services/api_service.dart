import 'dart:convert';
import 'dart:io';
import 'package:commv_driver/controllers/auth_controller.dart';
import 'package:commv_driver/services/storage_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../models/address_model.dart';
import '../models/vehicle_list_response.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:commv_driver/services/storage_service.dart';


class ApiService {
  final String baseUrl = 'https://commv.skillupstream.com';

  // 👇 Pass BuildContext optionally (needed for navigation on logout)
  ApiService({this.context});
  final BuildContext? context;

  // 🔹 Common method to print all request details
  void _logRequest({
    required String method,
    required Uri url,
    required Map<String, String> headers,
    dynamic body,
  }) {
    print('----------------------------------------');
    print('📤 REQUEST [$method] => ${url.toString()}');
    print('🔸 Headers: ${jsonEncode(headers)}');
    if (body != null) {
      try {
        print('🔸 Body: ${jsonEncode(jsonDecode(body))}');
      } catch (_) {
        print('🔸 Body: $body');
      }
    }
    print('----------------------------------------');
  }

  // 🔹 Handle unauthorized logout
  Future<void> _handleUnauthorized() async {
    print("🚨 Unauthorized detected → logging out...");
    await AuthController.instance.logout(); // clear token and session
  }

  // 🔹 Common method to print all response details
  Future<void> _logResponse(http.Response response) async {
    print('----------------------------------------');
    print('📥 RESPONSE [${response.statusCode}]');
    print('🔹 URL: ${response.request?.url}');
    print('🔹 Body: ${response.body}');
    print('----------------------------------------');

    // 👇 Handle unauthorized (401)
    if (response.statusCode == 401) {
      await _handleUnauthorized();
    }
  }

  // 🔹 Helper wrapper for POST requests
  Future<http.Response> _post(Uri url,
      {Map<String, String>? headers, dynamic body}) async {
    _logRequest(method: 'POST', url: url, headers: headers ?? {}, body: body);
    final response = await http.post(url, headers: headers, body: body);
    await _logResponse(response);
    return response;
  }

  // 🔹 Helper wrapper for PUT requests
  Future<http.Response> _put(Uri url,
      {Map<String, String>? headers, dynamic body}) async {
    _logRequest(method: 'PUT', url: url, headers: headers ?? {}, body: body);
    final response = await http.put(url, headers: headers, body: body);
    await _logResponse(response);
    return response;
  }

  // 🔹 Helper wrapper for GET requests
  Future<http.Response> _get(Uri url, {Map<String, String>? headers}) async {
    _logRequest(method: 'GET', url: url, headers: headers ?? {});
    final response = await http.get(url, headers: headers);
    await _logResponse(response);
    return response;
  }

  // 🔹 Helper wrapper for PATCH multipart requests
  Future<void> _patchMultipart(http.MultipartRequest request) async {
    print('----------------------------------------');
    print('📤 REQUEST [PATCH Multipart] => ${request.url}');
    print('🔸 Headers: ${jsonEncode(request.headers)}');
    print('🔸 Fields: ${jsonEncode(request.fields)}');
    print('🔸 Files: ${request.files.map((f) => f.filename).toList()}');
    print('----------------------------------------');

    final streamedResponse = await request.send();
    final respStr = await streamedResponse.stream.bytesToString();

    print('----------------------------------------');
    print('📥 RESPONSE [${streamedResponse.statusCode}]');
    print('🔹 Body: $respStr');
    print('----------------------------------------');

    if (streamedResponse.statusCode == 401) {
      await _handleUnauthorized();
    }
  }

  // ----------------------------------------------------------
  // 🔸 Actual API calls below (logging + unauthorized auto logout)
  // ----------------------------------------------------------

  Future<http.Response> sendOtp(String phoneNumber) async {
    final url = Uri.parse('$baseUrl/api/driver/phone/send-otp');
    final headers = {'accept': '*/*', 'Content-Type': 'application/json'};
    final body = jsonEncode({"driverPhoneNo": phoneNumber});
    return await _post(url, headers: headers, body: body);
  }

  Future<http.Response> loginVerifyOtp({
    required String otp,
    required String userphoneNo,
    required String deviceToken,
  }) async {
    final url = Uri.parse('$baseUrl/api/driver/phone/verify');
    final headers = {'accept': '*/*', 'Content-Type': 'application/json'};
    final deviceDetails = await getDeviceDetails();
    final body = jsonEncode({
      "driverPhoneNo": userphoneNo,
      "otp": otp,
      "deviceId": deviceDetails['deviceId'],
      "deviceType": deviceDetails['deviceType'],
      "deviceToken": deviceToken,
    });
    return await _post(url, headers: headers, body: body);
  }

  Future<http.Response> updateProfile({
    required String userFirstName,
    required String userLastName,
    required String userEmail,
  }) async {
    final url = Uri.parse('$baseUrl/api/driver/profile/update');
    final storageService = await StorageService.instance;
    final token = await storageService.token;
    final headers = {
      'accept': '*/*',
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
    final body = jsonEncode({
      "driverFirstName": userFirstName,
      "driverLastName": userLastName,
      "driverEmail": userEmail,
    });
    return await _put(url, headers: headers, body: body);
  }



  Future<http.Response> updateOnlineStatus() async {
    final url = Uri.parse('$baseUrl/api/driver/status/online');
    final storageService = await StorageService.instance;
    final token = await storageService.token;
    final headers = {
      'accept': '*/*',
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
    return await _post(url, headers: headers);
  }

  Future<http.Response> updateOfflineStatus() async {
    final url = Uri.parse('$baseUrl/api/driver/status/offline');
    final storageService = await StorageService.instance;
    final token = await storageService.token;
    final headers = {
      'accept': '*/*',
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
    return await _post(url, headers: headers);
  }

  Future<http.Response> getProfile() async {
    final url = Uri.parse('$baseUrl/api/driver/me');
    final storageService = await StorageService.instance;
    final token = await storageService.token;
    final headers = {
      'accept': '*/*',
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
    return await _get(url, headers: headers);
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
    } else {
      deviceType = 'other';
    }

    return {'deviceId': deviceId, 'deviceType': deviceType};
  }


  Future<http.StreamedResponse> updateKycDocuments({
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

    // 👇 Optional file parameters (use File objects or null)
    File? rcFile,
    File? insuranceFile,
    File? dlFile,
    File? panFile,
    File? aadharFile,
  }) async {
    final url = Uri.parse('$baseUrl/api/driver/documents');
    final storageService = await StorageService.instance;
    final token = await storageService.token;

    final request = http.MultipartRequest('PATCH', url);

    // ✅ Correct headers (DON’T manually set Content-Type)
    request.headers.addAll({
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    // ✅ Add text fields (same as curl)
    request.fields.addAll({
      'rcStatus': rcStatus,
      'insuranceNumber': insuranceNumber,
      'panNumber': panNumber,
      'aadharStatus': aadharStatus,
      'insuranceStatus': insuranceStatus,
      'panStatus': panStatus,
      'dlNumber': dlNumber,
      'rcNumber': rcNumber,
      'dlStatus': dlStatus,
      'aadharNumber': aadharNumber,
    });

    // ✅ Attach files only if provided
    if (rcFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'rcFile',
        rcFile.path,
        contentType: MediaType('image', 'png'),
      ));
    }
    if (insuranceFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'insuranceFile',
        insuranceFile.path,
        contentType: MediaType('image', 'png'),
      ));
    }
    if (dlFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'dlFile',
        dlFile.path,
        contentType: MediaType('image', 'png'),
      ));
    }
    if (panFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'panFile',
        panFile.path,
        contentType: MediaType('image', 'png'),
      ));
    }
    if (aadharFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'aadharFile',
        aadharFile.path,
        contentType: MediaType('image', 'png'),
      ));
    }

    // ✅ Add empty file fields (to match curl -F 'field=')
    final expectedFileFields = [
      'rcFile',
      'insuranceFile',
      'panFile',
      'dlFile',
      'aadharFile',
    ];

    for (var field in expectedFileFields) {
      final hasFile = request.files.any((f) => f.field == field);
      if (!hasFile && !request.fields.containsKey(field)) {
        request.fields[field] = ''; // mimic curl’s empty file key
      }
    }

    // 🧾 Log request for debugging
    print('----------------------------------------');
    print('📤 REQUEST [PATCH Multipart] => ${request.url}');
    print('🔸 Headers: ${request.headers}');
    print('🔸 Fields: ${jsonEncode(request.fields)}');
    print('🔸 Files: ${request.files.map((f) => f.filename).toList()}');
    print('----------------------------------------');

    // 🕓 Send with timeout
    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 180),
      onTimeout: () {
        throw Exception("Request timed out. Please try again.");
      },
    );

    final respStr = await streamedResponse.stream.bytesToString();

    print('----------------------------------------');
    print('📥 RESPONSE [${streamedResponse.statusCode}]');
    print('🔹 Body: $respStr');
    print('----------------------------------------');

    if (streamedResponse.statusCode == 401) {
      await _handleUnauthorized();
    }

    return http.StreamedResponse(
      Stream.value(utf8.encode(respStr)),
      streamedResponse.statusCode,
      reasonPhrase: streamedResponse.reasonPhrase,
      headers: streamedResponse.headers,
    );
  }



}

class ApiResponse {
  final bool isSuccess;
  final String? message;
  ApiResponse({required this.isSuccess, this.message});
}
