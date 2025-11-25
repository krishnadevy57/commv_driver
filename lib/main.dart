import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:commv_driver/services/storage_service.dart';
import 'package:commv_driver/themes/themes.dart';
import 'controllers/theme_controller.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

// 🔔 Background message handler (MUST be top-level)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('📩 Background message received: ${message.messageId}');
  print('➡️ Title: ${message.notification?.title}');
  print('➡️ Body: ${message.notification?.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  try{
    // ✅ Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // ✅ Register background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }catch(e){
if (kDebugMode) {
  print(e);
}
  }

  // ✅ Initialize StorageService
  final storageService = StorageService.instance;
  await storageService.init();
  Get.put(storageService);
try{
  // ✅ Setup Firebase Messaging
  await _setupFirebaseMessaging();
}catch(e){

}
  runApp(CommVApp());
}

// 🔧 Firebase Messaging Setup
Future<void> _setupFirebaseMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // ✅ Request permission for notifications
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print('🔐 Notification permission: ${settings.authorizationStatus}');

  // ✅ Get FCM Token
  String? token = await messaging.getToken();
  print('🔥 FCM Token: $token');
  StorageService.instance.saveFcmDeviceToken(token ?? "");

  // ✅ Listen for token refresh
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    print('🔁 Token refreshed: $newToken');
    StorageService.instance.saveFcmDeviceToken(newToken ?? "");

  });

  // ✅ Foreground message handler
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('📱 Foreground message received!');
    print('➡️ Title: ${message.notification?.title}');
    print('➡️ Body: ${message.notification?.body}');
  });

  // ✅ When user opens app via notification
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('🚀 App opened from notification!');
    print('➡️ Title: ${message.notification?.title}');
    print('➡️ Body: ${message.notification?.body}');
  });
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
