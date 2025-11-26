import 'dart:convert';
import 'dart:io';
import 'package:commv_driver/controllers/auth_controller.dart';
import 'package:commv_driver/services/storage_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

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



  /// Fetch driver's order history with pagination.
  /// Example: page = 1, limit = 20
  Future<http.Response> getOrderHistory({int page = 1, int limit = 20}) async {
    final storageService = await StorageService.instance;
    final token = storageService.token;
    final url = Uri.parse('$baseUrl/api/driver/order/history?page=$page&limit=$limit');

    final headers = {
      'accept': '*/*',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    return await _get(url, headers: headers);
  }

  Future<http.Response> updateKycDocuments({
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
    final url = Uri.parse('$baseUrl/api/driver/documents');
    final storageService = await StorageService.instance;
    final token = await storageService.token;

    final request = http.MultipartRequest('PATCH', url);

    request.headers.addAll({
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    // ------------------------------
    // 🔵 ADD TEXT FIELDS (NON-EMPTY)
    // ------------------------------
    void addField(String key, String? value) {
      if (value != null && value.trim().isNotEmpty) {
        request.fields[key] = value;
      }
    }

    addField('rcStatus', rcStatus);
    addField('insuranceNumber', insuranceNumber);
    addField('panNumber', panNumber);
    addField('aadharStatus', aadharStatus);
    addField('insuranceStatus', insuranceStatus);
    addField('panStatus', panStatus);
    addField('dlNumber', dlNumber);
    addField('rcNumber', rcNumber);
    addField('dlStatus', dlStatus);
    addField('aadharNumber', aadharNumber);

    // ---------------------------------------
    // 🔵 ADD FILES (ONLY IF FILE IS NOT NULL)
    // ---------------------------------------
    Future<void> addFile(String key, File? file) async {
      if (file != null && file.path.isNotEmpty) {
        final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
        final typeSplit = mimeType.split('/');

        request.files.add(await http.MultipartFile.fromPath(
          key,
          file.path,
          contentType: MediaType(typeSplit[0], typeSplit[1]),
        ));
      }
    }

    await addFile('rcFile', rcFile);
    await addFile('insuranceFile', insuranceFile);
    await addFile('dlFile', dlFile);
    await addFile('panFile', panFile);
    await addFile('aadharFile', aadharFile);

    // ------------------------------
    // 🔵 DEBUG LOGS
    // ------------------------------
    print("🔍 FIELDS:");
    request.fields.forEach((k, v) => print("$k = '$v'"));

    print("🔍 FILES:");
    for (var f in request.files) {
      print("${f.field}: ${f.filename}");
    }

    // ------------------------------
    // 🔵 SEND REQUEST
    // ------------------------------
    final streamedResponse = await request.send();
    final respStr = await streamedResponse.stream.bytesToString();

    print("🟦 Status: ${streamedResponse.statusCode}");
    print("🟦 Response: $respStr");

    return http.Response(
      respStr,
      streamedResponse.statusCode,
      headers: streamedResponse.headers,
    );
  }






  Future<http.Response> getBookingDetail(int bookingId) async {
    final url = Uri.parse('$baseUrl/api/bookings/$bookingId');
    try {
      final storageService = await StorageService.instance;
      final token = await storageService.token;

      if (token == null || token.toString().isEmpty) {
        await _handleUnauthorized();
        return http.Response(jsonEncode({'error': 'Missing token'}), 401, headers: {
          'Content-Type': 'application/json',
        });
      }

      final headers = {
        'accept': '*/*',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token.toString()}',
      };

      return await _get(url, headers: headers);
    } catch (e, st) {
      print('Error in getBookingDetail: $e\n$st');
      return http.Response(jsonEncode({'error': 'Failed to fetch booking detail'}), 500, headers: {
        'Content-Type': 'application/json',
      });
    }
  }


// dart
// Add this inside the ApiService class in `lib/services/api_service.dart`
  Future<http.Response> orderAction({
    required int bookingId,
    required String action,
    String? reason,
  }) async {
    final url = Uri.parse('$baseUrl/api/driver/order/action');
    try {
      final storageService = await StorageService.instance;
      final token = await storageService.token;

      if (token == null || token.toString().isEmpty) {
        await _handleUnauthorized();
        return http.Response(jsonEncode({'error': 'Missing token'}), 401, headers: {
          'Content-Type': 'application/json',
        });
      }

      final headers = {
        'accept': '*/*',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token.toString()}',
      };

      final body = jsonEncode({
        'bookingId': bookingId,
        'action': action,
        'reason': reason ?? '',
      });

      return await _post(url, headers: headers, body: body);
    } catch (e, st) {
      print('Error in orderAction: $e\n$st');
      return http.Response(jsonEncode({'error': 'Failed to perform order action'}), 500, headers: {
        'Content-Type': 'application/json',
      });
    }
  }


  Future<http.Response> verifyOrder({
    required int bookingId,
    required String code,
  }) async {
    final url = Uri.parse('$baseUrl/api/driver/order/verify');
    try {
      final storageService = await StorageService.instance;
      final token = await storageService.token;

      if (token == null || token.toString().isEmpty) {
        await _handleUnauthorized();
        return http.Response(jsonEncode({'error': 'Missing token'}), 401, headers: {
          'Content-Type': 'application/json',
        });
      }

      final headers = {
        'accept': '*/*',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token.toString()}',
      };

      final body = jsonEncode({
        'bookingId': bookingId,
        'code': code,
      });

      return await _post(url, headers: headers, body: body);
    } catch (e, st) {
      print('Error in verifyOrder: $e\n$st');
      return http.Response(jsonEncode({'error': 'Failed to verify order'}), 500, headers: {
        'Content-Type': 'application/json',
      });
    }
  }


// dart
  Future<http.Response> startOrder({
    required int bookingId,
  }) async {
    final url = Uri.parse('$baseUrl/api/driver/order/start');
    try {
      final storageService = await StorageService.instance;
      final token = await storageService.token;

      if (token == null || token.toString().isEmpty) {
        await _handleUnauthorized();
        return http.Response(jsonEncode({'error': 'Missing token'}), 401, headers: {
          'Content-Type': 'application/json',
        });
      }

      final headers = {
        'accept': '*/*',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token.toString()}',
      };

      final body = jsonEncode({
        'bookingId': bookingId,
      });

      return await _post(url, headers: headers, body: body);
    } catch (e, st) {
      if (kDebugMode) {
        print('Error in startOrder: $e\n$st');
      }
      return http.Response(jsonEncode({'error': 'Failed to start order'}), 500, headers: {
        'Content-Type': 'application/json',
      });
    }
  }

  Future<http.Response> completeOrder({
    required int bookingId,
    required num actualDistance,
  }) async {
    final url = Uri.parse('$baseUrl/api/driver/order/complete');
    try {
      final storageService = await StorageService.instance;
      final token = await storageService.token;

      if (token == null || token.toString().isEmpty) {
        await _handleUnauthorized();
        return http.Response(jsonEncode({'error': 'Missing token'}), 401, headers: {
          'Content-Type': 'application/json',
        });
      }

      final headers = {
        'accept': '*/*',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token.toString()}',
      };

      final body = jsonEncode({
        'bookingId': bookingId,
        'actualDistance': actualDistance,
      });

      return await _post(url, headers: headers, body: body);
    } catch (e, st) {
      if (kDebugMode) {
        print('Error in completeOrder: $e\n$st');
      }
      return http.Response(jsonEncode({'error': 'Failed to complete order'}), 500, headers: {
        'Content-Type': 'application/json',
      });
    }
  }

  Future<http.Response> confirmPayment({
    required int bookingId,
    required num amountPaid,
    required String paymentMethod,
    String? paymentTxnId,
  }) async {
    final url = Uri.parse('$baseUrl/api/driver/order/confirmPayment');
    try {
      final storageService = await StorageService.instance;
      final token = await storageService.token;

      if (token == null || token.toString().isEmpty) {
        await _handleUnauthorized();
        return http.Response(jsonEncode({'error': 'Missing token'}), 401, headers: {
          'Content-Type': 'application/json',
        });
      }

      final headers = {
        'accept': '*/*',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token.toString()}',
      };

      final body = jsonEncode({
        'bookingId': bookingId,
        'amountPaid': amountPaid,
        'paymentMethod': paymentMethod,
        'paymentTxnId': paymentTxnId ?? '',
      });

      return await _post(url, headers: headers, body: body);
    } catch (e, st) {
      if (kDebugMode) {
        print('Error in confirmPayment: $e\n$st');
      }
      return http.Response(jsonEncode({'error': 'Failed to confirm payment'}), 500, headers: {
        'Content-Type': 'application/json',
      });
    }
  }
}

class ApiResponse {
  final bool isSuccess;
  final String? message;
  ApiResponse({required this.isSuccess, this.message});
}
