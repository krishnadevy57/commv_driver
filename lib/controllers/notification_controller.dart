// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  // final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  @override
  void onInit() {
    super.onInit();
    initNotifications();
  }

  void initNotifications() async {
    // NotificationSettings settings = await _fcm.requestPermission();
    //
    // String? token = await _fcm.getToken();
    // print("FCM Token: $token");
    //
    // FirebaseMessaging.onMessage.listen((message) {
    //   Get.snackbar("🔔 New Notification", message.notification?.body ?? '');
    // });
    //
    // FirebaseMessaging.onMessageOpenedApp.listen((message) {
    //   // Handle tap on notification
    // });
  }
}
