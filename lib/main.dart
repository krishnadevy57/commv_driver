// import 'package:commv/services/storage_service.dart';
// import 'package:commv/themes/themes.dart';
import 'package:commv_driver/services/storage_service.dart';
import 'package:commv_driver/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/theme_controller.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService.instance;
  await storageService.init();

  Get.put(storageService); // inject globally

  runApp(CommVApp());
}

class CommVApp extends StatelessWidget {
  CommVApp({super.key});

  final ThemeController themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => GetMaterialApp(
      title: 'CommV Driver',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeController.theme,
      initialRoute: Routes.SPLASH,
      getPages: AppPages.routes,
    ));
  }
}
