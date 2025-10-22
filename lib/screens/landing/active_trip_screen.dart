import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/trip_controller.dart';

class ActiveTripScreen extends StatelessWidget {
  ActiveTripScreen({super.key});

  final controller = Get.put(TripController());
  final otpController = TextEditingController();

  final LatLng pickupLocation = const LatLng(26.182245, 91.754723); // Paltan Bazaar
  final LatLng dropLocation = const LatLng(26.1493, 91.7861);       // Ganeshguri

  @override
  Widget build(BuildContext context) {
    controller.initStops(pickupLoc: pickupLocation, dropLoc: dropLocation);

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Active Trip",
          style: tt.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white, // ✅ Force white text
          ),
        ),
        backgroundColor: cs.primary, // keep your theme color
        iconTheme: const IconThemeData(
          color: Colors.white, // ✅ makes back icon white
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildMap(),
          const SizedBox(height: 8),
          _buildTripSummaryCard(tt, cs),
          const SizedBox(height: 8),
          _buildStepper(tt, cs),
          const SizedBox(height: 8),
          Expanded(child: _buildActionArea(tt, cs)),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return SizedBox(
      height: 230,
      child: Obx(() {
        return GoogleMap(
          initialCameraPosition: CameraPosition(target: pickupLocation, zoom: 12),
          markers: {
            Marker(markerId: const MarkerId('pickup'), position: pickupLocation, infoWindow: const InfoWindow(title: 'Pickup')),
            Marker(markerId: const MarkerId('drop'), position: dropLocation, infoWindow: const InfoWindow(title: 'Drop')),
            Marker(markerId: const MarkerId('current'), position: controller.currentLocation.value, infoWindow: const InfoWindow(title: 'You')),
          },
          polylines: controller.polylines.toSet(),
          myLocationEnabled: true,
          zoomControlsEnabled: false,
          onMapCreated: (_) async {
            // Before OTP: Current → Pickup → Drop
            if (!controller.isOtpVerified.value) {
              await controller.drawRoute(controller.currentLocation.value, dropLocation, via: pickupLocation);
            }
          },
        );
      }),
    );
  }

  Widget _buildTripSummaryCard(TextTheme tt, ColorScheme cs) {
    return Obx(() {
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
                  Text('Pickup: Paltan Bazaar', style: tt.bodyMedium),
                  Text('Drop: Ganeshguri', style: tt.bodyMedium),
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
        // ---- OTP Section
        return _otpCard(tt, cs);
      } else if (!controller.tripStarted.value) {
        // ---- Start Trip
        return _startTripCard(tt, cs);
      } else if (!controller.tripCompleted.value) {
        // ---- Complete Trip
        return _inTripCard(tt, cs);
      } else {
        // ---- Payment
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
              hintText: "Enter 4-digit OTP",
              prefixIcon: Icon(Icons.lock_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.verifyOtp(otpController.text.trim()),
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
                  onPressed: controller.startTrip,
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
    final url = Uri.parse("google.navigation:q=${dropLocation.latitude},${dropLocation.longitude}&mode=d");
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
            onPressed: controller.completeTrip,
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

            // 🔹 Total Fare
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total Fare", style: tt.titleMedium),
                Obx(() => Text(
                  "₹${controller.estimatedFare.value.toStringAsFixed(0)}",
                  style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                )),
              ],
            ),
            const Divider(height: 24),

            // 🔹 Payment Methods
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

            // 🔹 Note for cash
            Obx(() {
              if (controller.selectedPaymentMethod.value == "Cash") {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text("Please collect cash from rider.",
                      style: tt.bodySmall?.copyWith(color: Colors.orange)),
                );
              }
              return const SizedBox.shrink();
            }),

            // 🔹 Payment button
            Obx(() => controller.isProcessingPayment.value
                ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: CircularProgressIndicator(),
              ),
            )
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.processPayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  controller.selectedPaymentMethod.value == "Cash"
                      ? "Confirm Cash Received"
                      : "Pay with ${controller.selectedPaymentMethod.value}",
                ),
              ),
            )),

            const SizedBox(height: 10),

            // 🔹 Show receipt after payment success
            Obx(() => controller.paymentStatus.value == "Paid"
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
        onTap: () => controller.choosePayment(label),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSel ? Colors.blue : Colors.grey.shade300, width: 1.5),
            color: isSel ? Colors.blue.withOpacity(0.08) : Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon),
              const SizedBox(height: 6),
              Text(label),
            ],
          ),
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
          decoration: BoxDecoration(
            color: cs.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Payment Successful", style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text("Trip ID: ${controller.tripId.value}", style: tt.bodySmall),
              Text("Method: ${controller.selectedPaymentMethod.value}", style: tt.bodySmall),
              Text("Amount: ₹${controller.estimatedFare.value.toStringAsFixed(0)}", style: tt.bodySmall),
            ],
          )),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  controller.resetTrip();
                  Get.back(); // optional: pop screen
                },
                child: const Text("Done"),
              ),
            ),
          ],
        )
      ],
    );
  }
}
