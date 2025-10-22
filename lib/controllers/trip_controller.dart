import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';

class TripController extends GetxController {
  // ---- Reactive States
  final isOtpVerified = false.obs;
  final tripStarted = false.obs;
  final tripCompleted = false.obs;

  final isProcessingPayment = false.obs;
  final paymentStatus = 'Pending'.obs;
  final selectedPaymentMethod = 'Cash'.obs; // Cash | UPI | Card

  // ---- Map / Route
  final polylines = <Polyline>{}.obs;
  final currentLocation = const LatLng(26.1800, 91.7540).obs;

  // These will be set by the screen
  final pickup = Rxn<LatLng>();
  final drop = Rxn<LatLng>();

  // ---- Fares / Meta
  final tripId = RxString("#TRIP-${DateTime.now().millisecondsSinceEpoch}");
  final baseFare = 49.0.obs;       // INR
  final perKmFare = 12.0.obs;      // INR
  final estimatedDistanceKm = 0.0.obs;
  final estimatedFare = 0.0.obs;

  // ---- Tracking
  StreamSubscription<Position>? _posSub;
  final String googleApiKey = "YOUR_GOOGLE_MAPS_API_KEY";

  // ---- Public API ----
  void initStops({required LatLng pickupLoc, required LatLng dropLoc}) {
    pickup.value = pickupLoc;
    drop.value = dropLoc;
    _estimateFare();
  }

  void verifyOtp(String otp) {
    // TODO: Replace with API call
    if (otp.isNotEmpty && otp == "1234") {
      isOtpVerified.value = true;
    } else {
      Get.snackbar("Invalid OTP", "Please check and try again");
    }
  }

  Future<void> startTrip() async {
    if (!isOtpVerified.value) {
      Get.snackbar("Verify OTP", "Please verify OTP before starting the trip");
      return;
    }
    tripStarted.value = true;
    _startLocationStream();
    // Draw route from current → drop (live)
    if (drop.value != null) {
      await drawRoute(currentLocation.value, drop.value!);
    }
  }

  Future<void> completeTrip() async {
    if (!tripStarted.value) return;
    tripCompleted.value = true;
    tripStarted.value = false;
    await _posSub?.cancel();
    _posSub = null;
    // Final fare recompute with last known distance (optional)
  }

  void resetTrip() {
    isOtpVerified.value = false;
    tripStarted.value = false;
    tripCompleted.value = false;
    paymentStatus.value = 'Pending';
    polylines.clear();
    _posSub?.cancel();
    _posSub = null;
    tripId.value = "#TRIP-${DateTime.now().millisecondsSinceEpoch}";
  }

  void choosePayment(String method) {
    selectedPaymentMethod.value = method;
  }


  // ---- Navigation Intent (open Google Maps turn-by-turn)
  Future<void> openGoogleNavigationToDrop() async {
    // Handle outside (screen) with url_launcher; this is just a hook if needed
  }

  // ---- Routing
  Future<void> drawRoute(LatLng start, LatLng end, {LatLng? via}) async {
    final points = PolylinePoints();
    final result = await points.getRouteBetweenCoordinates(
      googleApiKey,
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(end.latitude, end.longitude),
      wayPoints: via != null
          ? [PolylineWayPoint(location: "${via.latitude},${via.longitude}")]
          : [],
      travelMode: TravelMode.driving,
    );

    final coords = <LatLng>[];
    for (final p in result.points) {
      coords.add(LatLng(p.latitude, p.longitude));
    }
    polylines.clear();
    if (coords.isNotEmpty) {
      polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        width: 6,
        color: const Color(0xFF1A73E8),
        points: coords,
      ));
      // quick distance estimate from polyline
      estimatedDistanceKm.value = _measureRouteKm(coords);
      _estimateFare();
    }
  }

  // ---- Internal helpers
  void _estimateFare() {
    final p = pickup.value;
    final d = drop.value;
    if (p == null || d == null) return;

    double km = estimatedDistanceKm.value;
    if (km == 0) {
      // direct haversine if route not ready
      km = _haversineKm(p.latitude, p.longitude, d.latitude, d.longitude);
    }
    estimatedDistanceKm.value = km;
    estimatedFare.value = baseFare.value + max(0, km) * perKmFare.value;
  }

  double _measureRouteKm(List<LatLng> pts) {
    if (pts.length < 2) return 0;
    double dist = 0;
    for (var i = 0; i < pts.length - 1; i++) {
      dist += _haversineKm(
        pts[i].latitude, pts[i].longitude,
        pts[i + 1].latitude, pts[i + 1].longitude,
      );
    }
    return dist;
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // km
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat/2)*sin(dLat/2) +
        cos(_deg2rad(lat1))*cos(_deg2rad(lat2)) * sin(dLon/2)*sin(dLon/2);
    final c = 2 * atan2(sqrt(a), sqrt(1-a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * pi / 180.0;

  Future<void> _startLocationStream() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return;
    }
    _posSub?.cancel();
    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
      ),
    ).listen((pos) async {
      currentLocation.value = LatLng(pos.latitude, pos.longitude);
      if (tripStarted.value && drop.value != null) {
        // Refresh leg current -> drop (lightweight; you can throttle if needed)
        await drawRoute(currentLocation.value, drop.value!);
      }
    });
  }


  void cancelTripDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cancel Trip"),
        content: Text("Are you sure you want to cancel this trip?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("No"),
          ),
          TextButton(
            onPressed: () {
              // Cancel logic here
              Navigator.pop(context);
            },
            child: Text("Yes, Cancel"),
          ),
        ],
      ),
    );
  }

// Inside your StatefulWidget
  var paymentMethod = "Cash".obs; // default

  void setPaymentMethod(String method) {

      paymentMethod.value = method;

  }

  Future<void> processPayment() async {
    if (selectedPaymentMethod.value.isEmpty) {
      Get.snackbar("Payment", "Please select a payment method first");
      return;
    }

    // Case 1: Cash → immediate confirm
    if (selectedPaymentMethod.value == "Cash") {
      paymentStatus.value = "Paid";
      Get.snackbar("Cash Payment", "Cash received successfully for ${tripId.value}");
      return;
    }

    // Case 2: UPI / Card → simulate gateway
    isProcessingPayment.value = true;
    await Future.delayed(const Duration(seconds: 2));
    isProcessingPayment.value = false;

    paymentStatus.value = "Paid";
    Get.snackbar(
      "Payment Successful",
      "${selectedPaymentMethod.value} payment confirmed for ${tripId.value}",
    );
  }

  @override
  void onClose() {
    _posSub?.cancel();
    super.onClose();
  }
}
