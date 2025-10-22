import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/trip_controller.dart';

class ActiveTripScreen extends StatelessWidget {
  final controller = Get.find<TripController>();
  final otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Active Trip"),
        actions: [
          IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () {
              controller.cancelTripDialog(context);
            },
          )
        ],
      ),
      body: Obx(() {
        if (!controller.isOtpVerified.value) {
          return _buildOtpVerification(context);
        } else if (!controller.tripStarted.value) {
          return _buildStartTrip(context);
        } else {
          return _buildEndTrip(context);
        }
      }),
    );
  }

  Widget _buildOtpVerification(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text("Enter OTP provided by customer to start the ride:"),
          TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "OTP"),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => controller.verifyOtp(otpController.text.trim()),
            child: Text("Verify OTP"),
          )
        ],
      ),
    );
  }

  Widget _buildStartTrip(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: Icon(Icons.navigation),
        label: Text("Start Ride & Navigate"),
        onPressed: controller.startTrip,
      ),
    );
  }

  Widget _buildEndTrip(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Trip in progress...", style: TextStyle(fontSize: 18)),
          SizedBox(height: 30),
          Text("Select payment method:"),
          SizedBox(height: 10),
          Obx(() => Column(
            children: ["Cash", "UPI", "Other"].map((method) {
              return RadioListTile(
                title: Text(method),
                value: method,
                groupValue: controller.paymentMethod.value,
                onChanged: (value) {
                  controller.setPaymentMethod(value??"");
                },
              );
            }).toList(),
          )),
          SizedBox(height: 20),
          ElevatedButton.icon(
            icon: Icon(Icons.done),
            label: Text("Complete Trip"),
            onPressed: controller.completeTrip,
          )
        ],
      ),
    );
  }
}
