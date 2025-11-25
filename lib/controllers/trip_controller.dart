// lib/controllers/trip_controller.dart

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:commv_driver/models/order_detail_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import 'package:http/http.dart' as http;

class TripController extends GetxController {
  // ---- Reactive States
  final isOtpVerified = false.obs;
  final tripStarted = false.obs;
  final tripCompleted = false.obs;

  final isProcessingPayment = false.obs;
  final paymentStatus = 'Pending'.obs;
  final selectedPaymentMethod = 'Cash'.obs;

  // Map
  final polylines = <Polyline>{}.obs;
  final currentLocation = const LatLng(26.1800, 91.7540).obs;

  final pickup = Rxn<LatLng>();
  final drop = Rxn<LatLng>();

  // Fare
  final tripId = RxString("#TRIP-${DateTime.now().millisecondsSinceEpoch}");
  final baseFare = 49.0.obs;
  final perKmFare = 12.0.obs;
  final estimatedDistanceKm = 0.0.obs;
  final estimatedFare = 0.0.obs;

  StreamSubscription<Position>? _posSub;

  final googleApiKey = "AIzaSyCZS8BFO35e-deCgcJYcXtccNKstXFgQMQ";

  var isLoading = false.obs;
  var errorMessage = RxnString();
  var booking = Rxn<BookingOrder>();

  late int orderId;

  bool _routeInitialized = false; // avoid double routes

  @override
  void onInit() {
    super.onInit();
    orderId = Get.arguments?['orderId'] ?? -1;
    fetchOrderDetails();
  }

  // Parse Order
  BookingOrder? _parseOrderFromResponse(Map<String, dynamic> body) {
    final orderJson = body['order'] ?? body['booking'];
    if (orderJson == null) return null;
    return BookingOrder.fromJson(Map<String, dynamic>.from(orderJson));
  }

  // --------------------------------------------------------------------------
  // FETCH ORDER DETAILS
  // --------------------------------------------------------------------------
  Future<void> fetchOrderDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final resp = await ApiService().getBookingDetail(orderId);
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        final b = _parseOrderFromResponse(body);

        if (b != null) {
          booking.value = b;

          // set pickup + drop
          if (b.pickupLocation?.latitude != null) {
            pickup.value = LatLng(
              b.pickupLocation!.latitude!,
              b.pickupLocation!.longitude!,
            );
          }

          if (b.dropLocation?.latitude != null) {
            drop.value = LatLng(
              b.dropLocation!.latitude!,
              b.dropLocation!.longitude!,
            );
          }

          // states
          isOtpVerified.value = b.isVerified ?? false;
          tripStarted.value =
          (b.startedAt != null && (b.bookingStatus == "started" || b.bookingStatus == "in_progress"));
          tripCompleted.value = b.completedAt != null;

          // ---- Route logic on load ----
          if (!_routeInitialized) {
            _routeInitialized = true;

            if (tripStarted.value && drop.value != null) {
              // Show DROP route after START
              await drawRoute(currentLocation.value, drop.value!);
            } else if (pickup.value != null) {
              // Before START → show PICKUP
              await drawRoute(currentLocation.value, pickup.value!);
            }
          }
        }
      } else {
        errorMessage.value = "Failed to load";
      }
    } catch (e) {
      errorMessage.value = "Error: $e";
    } finally {
      isLoading.value = false;
    }
  }

  // --------------------------------------------------------------------------
  // VERIFY OTP
  // --------------------------------------------------------------------------
  Future<void> verifyOrder(String code) async {
    try {
      isLoading.value = true;

      final resp = await ApiService().verifyOrder(
        bookingId: orderId,
        code: code,
      );

      if (resp.statusCode == 200) {
        final updated = _parseOrderFromResponse(jsonDecode(resp.body));
        if (updated != null) {
          booking.value = updated;
          isOtpVerified.value = true;

          // After verify → still show route to PICKUP
          if (pickup.value != null) {
            await drawRoute(currentLocation.value, pickup.value!);
          }
        }
      }
    } catch (e) {
      Get.snackbar("Error", "$e");
    } finally {
      isLoading.value = false;
    }
  }

  // --------------------------------------------------------------------------
  // START TRIP → show DROP route
  // --------------------------------------------------------------------------
  Future<void> startOrder() async {
    try {
      isLoading.value = true;

      final resp = await ApiService().startOrder(bookingId: orderId);
      final body = jsonDecode(resp.body);

      if (resp.statusCode == 200) {
        final updated = _parseOrderFromResponse(body);
        if (updated != null) {
          booking.value = updated;
          tripStarted.value = true;

          // Switch route to DROP
          if (drop.value != null) {
            await drawRoute(currentLocation.value, drop.value!);
          }
        }
      }
    } finally {
      isLoading.value = false;
      _startLocationStream();
    }
  }

  // --------------------------------------------------------------------------
  // COMPLETE ORDER
  // --------------------------------------------------------------------------
  Future<void> completeOrder() async {
    try {
      isLoading.value = true;

      final actualDistance = booking.value?.actualDistance ?? estimatedDistanceKm.value;

      final resp = await ApiService().completeOrder(
        bookingId: orderId,
        actualDistance: actualDistance,
      );

      if (resp.statusCode == 200) {
        tripCompleted.value = true;
        tripStarted.value = false;
      }
    } finally {
      isLoading.value = false;
      _posSub?.cancel();
    }
  }

  // --------------------------------------------------------------------------
  // LIVE LOCATION STREAM
  // --------------------------------------------------------------------------
  Future<void> _startLocationStream() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Get.snackbar("Location", "Permission required");
      return;
    }

    _posSub?.cancel();
    _posSub = Geolocator.getPositionStream().listen((pos) async {
      currentLocation.value = LatLng(pos.latitude, pos.longitude);

      if (!tripStarted.value) {
        if (pickup.value != null) {
          await drawRoute(currentLocation.value, pickup.value!);
        }
      } else {
        if (drop.value != null) {
          await drawRoute(currentLocation.value, drop.value!);
        }
      }
    });
  }

  // --------------------------------------------------------------------------
  // DRAW POLYLINE
  // --------------------------------------------------------------------------
  Future<void> drawRoute(LatLng start, LatLng end) async {
    try {
      final points = PolylinePoints();
      final result = await points.getRouteBetweenCoordinates(
        googleApiKey,
        PointLatLng(start.latitude, start.longitude),
        PointLatLng(end.latitude, end.longitude),
        travelMode: TravelMode.driving,
      );

      if (result.points.isEmpty) {
        print("❌ No points found");
        return;
      }

      final coords = result.points
          .map((e) => LatLng(e.latitude, e.longitude))
          .toList();

      polylines.clear(); // remove old route
      polylines.add(
        Polyline(
          polylineId: const PolylineId("route"),
          width: 6,
          color: const Color(0xFF1A73E8),
          points: coords,
        ),
      );
    } catch (e) {
      print("Route error → $e");
    }
  }

  // --------------------------------------------------------------------------
  // PAYMENT
  // --------------------------------------------------------------------------
  Future<void> processPaymentAction() async {
    final amt = booking.value?.amountPaid ?? estimatedFare.value;
    await confirmPayment(
      amountPaid: amt,
      paymentMethod: selectedPaymentMethod.value,
      paymentTxnId: null,
    );
  }

  Future<void> confirmPayment({
    required num amountPaid,
    required String paymentMethod,
    String? paymentTxnId,
  }) async {
    if (orderId < 0) {
      Get.snackbar("Error", "Invalid order id");
      return;
    }

    try {
      isProcessingPayment.value = true;
      final resp = await ApiService().confirmPayment(
        bookingId: orderId,
        amountPaid: amountPaid,
        paymentMethod: paymentMethod,
        paymentTxnId: paymentTxnId,
      );

      final body = jsonDecode(resp.body);

      if (resp.statusCode == 200) {
        final updated = _parseOrderFromResponse(body);
        if (updated != null) {
          booking.value = updated;
          paymentStatus.value = booking.value?.paymentStatus ?? 'Paid';
        }
        Get.snackbar("Success", body['message'] ?? "Payment confirmed");
      } else {
        Get.snackbar("Payment failed", body['message'] ?? 'Failed');
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to confirm payment: $e");
    } finally {
      isProcessingPayment.value = false;
    }
  }

  // Reset All
  void resetTrip() {
    isOtpVerified.value = false;
    tripStarted.value = false;
    tripCompleted.value = false;

    isProcessingPayment.value = false;
    paymentStatus.value = "Pending";
    selectedPaymentMethod.value = "Cash";

    polylines.clear();
    estimatedDistanceKm.value = 0.0;
    estimatedFare.value = 0.0;

    pickup.value = null;
    drop.value = null;

    booking.value = null;
    errorMessage.value = null;

    _routeInitialized = false;

    _posSub?.cancel();
    _posSub = null;
  }

  @override
  void onClose() {
    _posSub?.cancel();
    super.onClose();
  }
}
