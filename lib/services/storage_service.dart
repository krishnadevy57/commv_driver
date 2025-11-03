import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/login_verify_response_model.dart';

class StorageService {
  static final StorageService instance = StorageService._internal();

  static const _KEY_TOKEN = 'auth_token';
  static const _KEY_DEVICE_TOKEN = 'device_token';
  static const _KEY_LOGGED_IN = 'is_logged_in';
  static const _KEY_USER_PROFILE = 'user_profile';

  late SharedPreferences _prefs;

  // Private constructor
  StorageService._internal();

  // Init method to be called before use
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save token
  Future<void> saveFcmDeviceToken(String deviceToken) async {
    await _prefs.setString(_KEY_DEVICE_TOKEN, deviceToken);
  }

  // Get device token
  String? get deviceToken => _prefs.getString(_KEY_DEVICE_TOKEN);


  // Save token
  Future<void> saveToken(String token) async {
    await _prefs.setString(_KEY_TOKEN, token);
  }

  // Get token
  String? get token => _prefs.getString(_KEY_TOKEN);

  // Save login state
  Future<void> setLoggedIn(bool loggedIn) async {
    await _prefs.setBool(_KEY_LOGGED_IN, loggedIn);
  }

  // Check login state
  bool get isLoggedIn => _prefs.getBool(_KEY_LOGGED_IN) ?? false;

  // Save User Profile
  Future<void> saveUserProfile(Driver? user) async {
    final userJson = jsonEncode(user?.toJson());
    await _prefs.setString(_KEY_USER_PROFILE, userJson);
  }

  // Get User Profile
  Driver? get userProfile {
    final userJson = _prefs.getString(_KEY_USER_PROFILE);
    if (userJson == null) return null;
    final Map<String, dynamic> userMap = jsonDecode(userJson);
    return Driver.fromJson(userMap);
  }

  // Clear all
  Future<void> clear() async {
    await _prefs.clear();
  }
}
