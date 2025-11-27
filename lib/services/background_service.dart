import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'socket_service.dart';
import 'storage_service.dart';

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'driver_channel',
      initialNotificationTitle: 'Driver service',
      initialNotificationContent: 'Service stopped',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

bool onIosBackground(ServiceInstance service) {
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Required for plugin usage in background isolate
  DartPluginRegistrant.ensureInitialized();

  // load token and initialize socket inside background isolate
  final socketService = SocketService();
  await socketService.init(backgroundMode: true);

  // update notification content to running
  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(title: "Driver Online", content: "Sending location");
  }

  // start listening to commands from UI
  service.on('stopService').listen((_) {
    socketService.onClose();
    service.stopSelf();
  });

  // Periodic location send every 5s
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    // If user turned off service from UI, plugin may stop it - we still attempt to read location
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // cannot get location
        socketService.log('⚠️ Location service disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        socketService.log('⚠️ Location permission denied in background');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);

      // You should persist rideId/seq info appropriately; this is a simple example.
      final rideId = 'RIDE_123';
      final seq = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      socketService.sendLocation(
        lat: pos.latitude,
        lng: pos.longitude,
        seq: seq,
        rideId: rideId,
      );
    } catch (e) {
      socketService.log('❌ background error: $e');
    }
  });
}
