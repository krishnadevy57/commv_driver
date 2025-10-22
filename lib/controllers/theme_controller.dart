import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  var isDark = false.obs;

  ThemeMode get theme => isDark.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    // Detect system theme
    final Brightness systemBrightness = WidgetsBinding.instance.window.platformBrightness;
    // isDark.value = systemBrightness == Brightness.dark;
    // Apply theme
    Get.changeThemeMode(theme);
  }

  void toggleTheme() {
    isDark.value = !isDark.value;
    Get.changeThemeMode(theme);
  }
}



// // lib/controllers/theme_controller.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class ThemeController extends GetxController {
//   var isDark = false.obs;
//   ThemeMode get theme => isDark.value ? ThemeMode.dark : ThemeMode.light;
//
//   void toggleTheme() {
//     isDark.value = !isDark.value;
//     Get.changeThemeMode(theme);
//   }
// }
