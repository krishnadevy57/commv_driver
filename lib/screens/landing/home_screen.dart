import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // appBar: AppBar(
      //   title: const Text("Dashboard"),
      //   centerTitle: true,
      //   backgroundColor: colorScheme.primary,
      //   foregroundColor: Colors.white,
      //   elevation: 0,
      // ),
      body: Obx(() {
        final currentRide = controller.currentRide.value;
        final earnings = controller.earnings.value;
        final pendingRides = controller.pendingRides;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🚖 Current Ride Section
              if (currentRide != null)
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.toNamed(Routes.ACTIVE_TRIP);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Text(
                              "Current Ride",
                              style: textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${currentRide['from']} → ${currentRide['to']}",
                              style: textTheme.bodyLarge,
                            ),
                          ],),
                        ),

                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Chip(
                              label: Text("Status: ${currentRide['status']}"),
                              backgroundColor:
                              colorScheme.primary.withOpacity(0.1),
                              labelStyle: TextStyle(color: colorScheme.primary),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: controller.completeCurrentRide,
                              child: const Text("Complete"),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // 💰 Earnings Card
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    child: Icon(Icons.account_balance_wallet,
                        color: colorScheme.primary),
                  ),
                  title: Text("Today's Earnings",
                      style: textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  trailing: Text("₹$earnings",
                      style: textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 24),

              // 📋 Pending Requests
              Text("Pending Ride Requests",
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              ...pendingRides.map(
                    (ride) => Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      "${ride['from']} → ${ride['to']}",
                      style: textTheme.bodyLarge,
                    ),
                    subtitle: Text("Fare: ₹${ride['fare']}",
                        style: textTheme.bodyMedium),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () => controller.acceptRide(ride),
                      child: const Text("Accept"),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
