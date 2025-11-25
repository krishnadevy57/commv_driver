import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/trip_controller.dart';
import '../../routes/app_routes.dart';

class ActiveTripScreen extends StatefulWidget {
  ActiveTripScreen({Key? key}) : super(key: key);

  @override
  State<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends State<ActiveTripScreen> {
  final TripController controller = Get.put(TripController());
  final otpController = TextEditingController();

  final Completer<GoogleMapController> _mapController = Completer();
  // keep a flag so we attempt fitBounds only after map created once
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    // optional: listen to polylines stream - we will also trigger camera fit inside build-obx
    // but a listener could be added if you prefer callbacks:
    // ever(controller.polylines, (_) => _fitMapToRoute());
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Active Trip", style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: cs.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null) {
          return Center(child: Text(controller.errorMessage.value!, style: tt.bodyMedium));
        }

        return Column(
          children: [
            _buildMapSection(),
            const SizedBox(height: 8),
            _buildTripSummaryCard(tt, cs),
            const SizedBox(height: 8),
            _buildStepper(tt, cs),
            const SizedBox(height: 8),
            Expanded(child: _buildActionArea(tt, cs)),
          ],
        );
      }),
    );
  }

  Widget _buildMapSection() {
    return SizedBox(
      height: 230,
      child: Obx(() {
        final p = controller.pickup.value;
        final d = controller.drop.value;
        final camTarget = p ?? controller.currentLocation.value;

        // After the polylines update, fit map to the route (if map is ready)
        // We schedule this after frame so the map controller exists.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_mapReady && controller.polylines.isNotEmpty) {
            _fitMapToRoute();
          } else if (_mapReady && controller.polylines.isEmpty) {
            // Optionally ensure current location + pickup/drop are visible when no route
            _fitMapToMarkers();
          }
        });

        return GoogleMap(
          initialCameraPosition: CameraPosition(target: camTarget, zoom: 12),
          onMapCreated: (gController) {
            if (!_mapController.isCompleted) _mapController.complete(gController);
            _mapReady = true;
            // Attempt to fit once map is ready
            if (controller.polylines.isNotEmpty) {
              Future.microtask(() => _fitMapToRoute());
            } else {
              Future.microtask(() => _fitMapToMarkers());
            }
          },
          markers: {
            if (p != null) Marker(markerId: const MarkerId('pickup'), position: p, infoWindow: const InfoWindow(title: 'Pickup')),
            if (d != null) Marker(markerId: const MarkerId('drop'), position: d, infoWindow: const InfoWindow(title: 'Drop')),
            Marker(markerId: const MarkerId('current'), position: controller.currentLocation.value, infoWindow: const InfoWindow(title: 'You')),
          },
          polylines: controller.polylines.toSet(),
          myLocationEnabled: true,
          zoomControlsEnabled: false,
        );
      }),
    );
  }

  Future<void> _fitMapToMarkers() async {
    // Fit camera to include currentLocation + pickup + drop (if present)
    try {
      final GoogleMapController gmc = await _mapController.future;
      final List<LatLng> pts = [];

      pts.add(controller.currentLocation.value);
      if (controller.pickup.value != null) pts.add(controller.pickup.value!);
      if (controller.drop.value != null) pts.add(controller.drop.value!);

      if (pts.isEmpty) return;

      final bounds = _calculateBounds(pts);
      final cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 70);
      await gmc.animateCamera(cameraUpdate);
    } catch (e) {
      // map may not be ready or bounds may be invalid
      debugPrint("fitMarkers error: $e");
    }
  }

  Future<void> _fitMapToRoute() async {
    try {
      final GoogleMapController gmc = await _mapController.future;

      // Get the first polyline (you keep only one route polyline)
      if (controller.polylines.isEmpty) return;
      final Polyline poly = controller.polylines.first;
      final pts = poly.points;
      if (pts.isEmpty) return;

      // include current location and destination markers as well to ensure they are visible
      final all = <LatLng>[];
      all.addAll(pts);
      all.add(controller.currentLocation.value);
      if (controller.pickup.value != null) all.add(controller.pickup.value!);
      if (controller.drop.value != null) all.add(controller.drop.value!);

      final bounds = _calculateBounds(all);

      // If bounds are invalid (single point), center there with zoom
      final cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 60);
      await gmc.animateCamera(cameraUpdate);
    } catch (e) {
      debugPrint("fitRoute error: $e");
    }
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    assert(points.isNotEmpty);
    double south = points[0].latitude;
    double north = points[0].latitude;
    double west = points[0].longitude;
    double east = points[0].longitude;

    for (final p in points) {
      if (p.latitude < south) south = p.latitude;
      if (p.latitude > north) north = p.latitude;
      if (p.longitude < west) west = p.longitude;
      if (p.longitude > east) east = p.longitude;
    }

    // create LatLngBounds with southwest and northeast
    final southwest = LatLng(south, west);
    final northeast = LatLng(north, east);
    return LatLngBounds(southwest: southwest, northeast: northeast);
  }

  Widget _buildTripSummaryCard(TextTheme tt, ColorScheme cs) {
    return Obx(() {
      final booking = controller.booking.value;
      final pickupAddr = booking?.pickupLocation?.fullAddress ?? 'Pickup';
      final dropAddr = booking?.dropLocation?.fullAddress ?? 'Drop';
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Verify Code: ${controller.booking.value?.verifyCode ?? "0"}", style: tt.labelMedium),

                  RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Pickup: ',
                          style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: pickupAddr,
                          style: tt.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Drop: ',
                          style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: dropAddr,
                          style: tt.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _chip(cs, "Distance ~ ${controller.estimatedDistanceKm.value.toStringAsFixed(1)} km"),
                      const SizedBox(width: 8),
                      _statusChip(tt, cs),
                    ],
                  ),
                ]),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Est. Fare", style: tt.labelMedium),
                  Text("₹${controller.estimatedFare.value.toStringAsFixed(0)}",
                      style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
        ),
      );
    });
  }

  Widget _chip(ColorScheme cs, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(color: cs.onSecondaryContainer)),
    );
  }

  Widget _statusChip(TextTheme tt, ColorScheme cs) {
    return Obx(() {
      String label = "Awaiting OTP";
      if (controller.isOtpVerified.value && !controller.tripStarted.value) label = "OTP Verified";
      if (controller.tripStarted.value && !controller.tripCompleted.value) label = "In Progress";
      if (controller.tripCompleted.value) label = "Completed";
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: tt.labelLarge?.copyWith(color: cs.onPrimaryContainer)),
      );
    });
  }

  Widget _buildStepper(TextTheme tt, ColorScheme cs) {
    Widget dot(bool done) => Container(
      width: 14, height: 14,
      decoration: BoxDecoration(
        color: done ? cs.primary : cs.outlineVariant,
        shape: BoxShape.circle,
      ),
    );

    return Obx(() {
      final s1 = controller.isOtpVerified.value;
      final s2 = controller.tripStarted.value;
      final s3 = controller.tripCompleted.value;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            dot(s1), _line(cs), dot(s2), _line(cs), dot(s3),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                s3 ? "Trip completed. Please collect payment." :
                s2 ? "Trip in progress..." :
                s1 ? "OTP verified. You can start the trip." :
                "Verify OTP to begin.",
                style: tt.bodySmall,
              ),
            )
          ],
        ),
      );
    });
  }

  Widget _line(ColorScheme cs) => Expanded(child: Container(height: 2, color: cs.outlineVariant, margin: const EdgeInsets.symmetric(horizontal: 6)));

  Widget _buildActionArea(TextTheme tt, ColorScheme cs) {
    return Obx(() {
      if (!controller.isOtpVerified.value) {
        return _otpCard(tt, cs);
      } else if (!controller.tripStarted.value) {
        return _startTripCard(tt, cs);
      } else if (!controller.tripCompleted.value) {
        return _inTripCard(tt, cs);
      } else {
        return _paymentCard(tt, cs);
      }
    });
  }

  Widget _otpCard(TextTheme tt, ColorScheme cs) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Verify OTP", style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Enter OTP",
              prefixIcon: Icon(Icons.lock_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.verifyOrder(otpController.text.trim()),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Verify OTP"),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _startTripCard(TextTheme tt, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                const Icon(Icons.route, size: 32),
                const SizedBox(width: 12),
                Expanded(child: Text("Ready to start? You can also open Google Maps turn-by-turn navigation.", style: tt.bodyMedium)),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openGoogleMaps,
                  icon: const Icon(Icons.navigation),
                  label: const Text("Navigate"),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    controller.startOrder();
                    // After starting, ensure map fits to route - controller will update polylines,
                    // and Obx will trigger _fitMapToRoute().
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Start Trip"),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openGoogleMaps() async {
    final d = controller.drop.value;
    if (d == null) {
      Get.snackbar("Navigation", "Drop location not available");
      return;
    }
    final url = Uri.parse("google.navigation:q=${d.latitude},${d.longitude}&mode=d");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar("Navigation", "Could not open Google Maps");
    }
  }

  Widget _inTripCard(TextTheme tt, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: ListTile(
            leading: const Icon(Icons.timelapse),
            title: const Text("Trip in progress"),
            subtitle: Obx(() => Text("Distance left ~ ${controller.estimatedDistanceKm.value.toStringAsFixed(1)} km")),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.completeOrder,
            icon: const Icon(Icons.check_circle),
            label: const Text("Complete Trip"),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
        ),
      ]),
    );
  }

  Widget _paymentCard(TextTheme tt, ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Payment", style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total Fare", style: tt.titleMedium),
                Obx(() => Text("₹${controller.estimatedFare.value.toStringAsFixed(0)}",
                    style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold))),
              ],
            ),
            const Divider(height: 24),

            Row(
              children: [
                Expanded(child: _payOption("Cash", Icons.payments)),
                const SizedBox(width: 8),
                Expanded(child: _payOption("UPI", Icons.qr_code_2)),
                const SizedBox(width: 8),
                Expanded(child: _payOption("Card", Icons.credit_card)),
              ],
            ),

            const SizedBox(height: 14),

            Obx(() {
              if (controller.selectedPaymentMethod.value == "Cash") {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text("Please collect cash from rider.", style: tt.bodySmall?.copyWith(color: Colors.orange)),
                );
              }
              return const SizedBox.shrink();
            }),

            const SizedBox(height: 8),

            Obx(() => controller.isProcessingPayment.value
                ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: CircularProgressIndicator()))
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.processPaymentAction,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text(controller.selectedPaymentMethod.value == "Cash" ? "Confirm Cash Received" : "Pay with ${controller.selectedPaymentMethod.value}"),
              ),
            )),

            const SizedBox(height: 10),

            Obx(() => controller.paymentStatus.value.toLowerCase() == "paid" || controller.booking.value?.paymentStatus?.toLowerCase() == "paid"
                ? _receipt(tt, cs)
                : const SizedBox.shrink()),
          ]),
        ),
      ),
    );
  }

  Widget _payOption(String label, IconData icon) {
    return Obx(() {
      final isSel = controller.selectedPaymentMethod.value == label;
      return InkWell(
        onTap: () => controller.selectedPaymentMethod.value = label,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSel ? Colors.blue : Colors.grey.shade300, width: 1.5),
            color: isSel ? Colors.blue.withOpacity(0.08) : Colors.white,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon),
            const SizedBox(height: 6),
            Text(label),
          ]),
        ),
      );
    });
  }

  Widget _receipt(TextTheme tt, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: cs.secondaryContainer, borderRadius: BorderRadius.circular(12)),
          child: Obx(() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Payment Successful", style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text("Trip ID: ${controller.tripId.value}", style: tt.bodySmall),
            Text("Method: ${controller.selectedPaymentMethod.value}", style: tt.bodySmall),
            Text("Amount: ₹${controller.booking.value?.amountPaid ?? controller.estimatedFare.value}", style: tt.bodySmall),
          ])),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: OutlinedButton(onPressed: () {
              controller.resetTrip();
              Get.offAllNamed(Routes.LANDING);
            }, child: const Text("Done")),
          ),
        ])
      ],
    );
  }
}
