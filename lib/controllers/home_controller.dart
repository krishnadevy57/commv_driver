// import 'package:commv_driver/routes/app_routes.dart';
// import 'package:get/get.dart';
// // import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// import 'auth_controller.dart';
//
// class HomeController extends GetxController {
//   var isOnline = false.obs;
//   var currentPosition = Rxn<LatLng>();
//   GoogleMapController? mapController;
//   final AuthController authController = AuthController.instance;
//
//   var isUpdating = false.obs;
//   var currentRide = Rxn<Map<String, dynamic>>();
//   var earnings = 0.obs;
//   var pendingRides = <Map<String, dynamic>>[].obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//      authController.getProfile();
//     if(authController.userProfile.value.driverStatus == "online"){
//       isOnline.value = true;
//     }else{
//       isOnline.value = false;
//     }
//     getLocation();
//
//     currentRide.value = {
//       "from": "Airport",
//       "to": "Hotel Plaza",
//       "status": "accepted",
//       "fare": 220,
//     };
//     earnings.value = 500;
//     pendingRides.value = [
//       {
//         "from": "City Mall",
//         "to": "Main Market",
//         "fare": 150,
//       },
//       {
//         "from": "Bus Stand",
//         "to": "University",
//         "fare": 180,
//       },
//     ];
//   }
//
//   void completeCurrentRide() {
//     currentRide.value = null;
//   }
//
//   void acceptRide(Map<String, dynamic> ride) {
//     currentRide.value = ride;
//     pendingRides.remove(ride);
//   }
//
//   void goToHistory() {
//     // Navigation logic, e.g.:
//     Get.toNamed('/tripHistory');
//   }
//
//   void goToProfile() {
//     // Navigation logic, e.g.:
//     Get.toNamed('/profile');
//   }
//
//   Future<void> getLocation() async {
//     // bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     // if (!serviceEnabled) {
//     //   Get.snackbar("Location Required", "Enable location services");
//     //   return;
//     // }
//
//     // LocationPermission permission = await Geolocator.checkPermission();
//     // if (permission == LocationPermission.denied) {
//     //   permission = await Geolocator.requestPermission();
//     // }
//     //
//     // Position position = await Geolocator.getCurrentPosition(
//     //     desiredAccuracy: LocationAccuracy.high);
//     // currentPosition.value = LatLng(position.latitude, position.longitude);
//
//    await Future.delayed(Duration(seconds: 5));
//   }
//   void toggleStatus(bool val) async{
//     isUpdating.value = true;
//     if(val){
//       await authController.updateOnlineStatus();
//     }else
//       {
//         await authController.updateOfflineStatus();
//       }
//     var driverStatus = authController.userProfile.value.driverStatus;
//     if(driverStatus=="online"){
//       isOnline.value = true;
//     }else{
//       isOnline.value = false;
//     }
//     isUpdating.value = false;
//     // isOnline.value = !isOnline.value;
//     Get.snackbar("Status", isOnline.value ? "Online" : "Offline");
//
//   }
//
//   void onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//   }
// }

import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/socket_service.dart';
import '../services/background_service.dart';
import '../services/storage_service.dart';
import 'auth_controller.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class HomeController extends GetxController {
  // final SocketService socketService = Get.find();
  final AuthController authController = Get.put(AuthController());

  var isOnline = false.obs;
  var isUpdating = false.obs;
  var socketLog = <String>[].obs;

  Timer? foregroundTimer;
  int seq = 1;

  @override
  void onInit() {
    super.onInit();
    authController.getProfile().then((_) {
      final status = authController.userProfile.value.driverStatus ?? 'offline';
      isOnline.value = status == 'online';
    });

    // keep UI logs synced
    // ever(socketService.logs, (_) {
    //   socketLog.assignAll(socketService.getLogSnapshot());
    // });
    authController.getProfile();
    if(authController.userProfile.value.driverStatus == "online"){
      isOnline.value = true;
    }else{
      isOnline.value = false;
    }
    getLocation();

    currentRide.value = {
      "from": "Airport",
      "to": "Hotel Plaza",
      "status": "accepted",
      "fare": 220,
    };
    earnings.value = 500;
    pendingRides.value = [
      {
        "from": "City Mall",
        "to": "Main Market",
        "fare": 150,
      },
      {
        "from": "Bus Stand",
        "to": "University",
        "fare": 180,
      },
    ];
  }

  Future<void> toggleStatus(bool val) async {
    isUpdating.value = true;
    isOnline.value = val;

    if (val) {
      await authController.updateOnlineStatus();

      // start foreground/background service
      final service = FlutterBackgroundService();
      // ensure background service starts (it will run on background isolate and start its own socket)
      await service.startService();

      // start a lightweight foreground timer to show UI sends (optional)
      // _startForegroundSending();
    } else {
      await authController.updateOfflineStatus();

      // stop background service
      final service = FlutterBackgroundService();
      service.invoke('stopService');

      _stopForegroundSending();
    }

    isUpdating.value = false;
    Get.snackbar('Status', val ? 'Online' : 'Offline');
  }

  // void _startForegroundSending() {
  //   // start quick foreground location updates to keep UI responsive
  //   foregroundTimer?.cancel();
  //   foregroundTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
  //     try {
  //       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //       if (!serviceEnabled) return;
  //       LocationPermission permission = await Geolocator.checkPermission();
  //       if (permission == LocationPermission.denied) {
  //         permission = await Geolocator.requestPermission();
  //       }
  //       if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;
  //
  //       final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
  //
  //       socketService.sendLocation(
  //         lat: pos.latitude,
  //         lng: pos.longitude,
  //         seq: seq++,
  //         rideId: 'RIDE_123',
  //       );
  //     } catch (e) {
  //       socketService.log('❌ foreground send error: $e');
  //     }
  //   });
  // }

  void _stopForegroundSending() {
    foregroundTimer?.cancel();
  }

  // void joinTestRide() {
  //   socketService.joinRide('RIDE_123');
  // }

  @override
  void onClose() {
    foregroundTimer?.cancel();
    super.onClose();
  }


  var currentPosition = Rxn<LatLng>();
  GoogleMapController? mapController;

  var currentRide = Rxn<Map<String, dynamic>>();
  var earnings = 0.obs;
  var pendingRides = <Map<String, dynamic>>[].obs;

  // @override
  // void onInit() {
  //   super.onInit();
  //   authController.getProfile();
  //   if(authController.userProfile.value.driverStatus == "online"){
  //     isOnline.value = true;
  //   }else{
  //     isOnline.value = false;
  //   }
  //   getLocation();
  //
  //   currentRide.value = {
  //     "from": "Airport",
  //     "to": "Hotel Plaza",
  //     "status": "accepted",
  //     "fare": 220,
  //   };
  //   earnings.value = 500;
  //   pendingRides.value = [
  //     {
  //       "from": "City Mall",
  //       "to": "Main Market",
  //       "fare": 150,
  //     },
  //     {
  //       "from": "Bus Stand",
  //       "to": "University",
  //       "fare": 180,
  //     },
  //   ];
  // }

  void completeCurrentRide() {
    currentRide.value = null;
  }

  void acceptRide(Map<String, dynamic> ride) {
    currentRide.value = ride;
    pendingRides.remove(ride);
  }

  void goToHistory() {
    // Navigation logic, e.g.:
    Get.toNamed('/tripHistory');
  }

  void goToProfile() {
    // Navigation logic, e.g.:
    Get.toNamed('/profile');
  }

  Future<void> getLocation() async {
    // bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // if (!serviceEnabled) {
    //   Get.snackbar("Location Required", "Enable location services");
    //   return;
    // }

    // LocationPermission permission = await Geolocator.checkPermission();
    // if (permission == LocationPermission.denied) {
    //   permission = await Geolocator.requestPermission();
    // }
    //
    // Position position = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.high);
    // currentPosition.value = LatLng(position.latitude, position.longitude);

    await Future.delayed(Duration(seconds: 5));
  }


  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
}

