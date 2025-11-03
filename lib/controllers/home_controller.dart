import 'package:commv_driver/routes/app_routes.dart';
import 'package:get/get.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'auth_controller.dart';

class HomeController extends GetxController {
  var isOnline = false.obs;
  var currentPosition = Rxn<LatLng>();
  GoogleMapController? mapController;
  final AuthController authController = AuthController.instance;

  var isUpdating = false.obs;
  var currentRide = Rxn<Map<String, dynamic>>();
  var earnings = 0.obs;
  var pendingRides = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
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
  void toggleStatus(bool val) async{
    isUpdating.value = true;
    if(val){
      await authController.updateOnlineStatus();
    }else
      {
        await authController.updateOfflineStatus();
      }
    var driverStatus = authController.userProfile.value.driverStatus;
    if(driverStatus=="online"){
      isOnline.value = true;
    }else{
      isOnline.value = false;
    }
    isUpdating.value = false;
    // isOnline.value = !isOnline.value;
    Get.snackbar("Status", isOnline.value ? "Online" : "Offline");

  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
}
