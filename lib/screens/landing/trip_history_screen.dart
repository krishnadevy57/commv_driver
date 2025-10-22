import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/trip_history_controller.dart';
import '../../routes/app_routes.dart';

class TripHistoryScreen extends StatelessWidget {
  final controller = Get.put(TripHistoryController());

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'canceled':
        return Colors.redAccent;
      case 'accepted':
        return Colors.blueAccent;
      case 'ride started':
        return Colors.orangeAccent;
      default:
        return colorScheme.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(

      backgroundColor: colorScheme.background,
      body: Obx(() => ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: controller.tripHistory.length,
        itemBuilder: (_, index) {
          final trip = controller.tripHistory[index];
          final status = trip['status'] ?? 'Unknown';

          return GestureDetector(
            onTap: () {
              Get.toNamed(Routes.ACTIVE_TRIP);
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // from -> to with icons
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.green),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            trip['from'],
                            style: textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                        const SizedBox(width: 6),
                        const Icon(Icons.flag, color: Colors.red),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            trip['to'],
                            style: textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // date & time row
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          "${trip['date']}  ${trip['time'] ?? ''}",
                          style: textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // status + distance + vehicle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(
                          label: Text(
                            status.toUpperCase(),
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor:
                          _getStatusColor(status, colorScheme),
                        ),
                        if (trip['distance'] != null)
                          Row(
                            children: [
                              const Icon(Icons.directions_car, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                trip['distance'],
                                style: textTheme.bodyMedium,
                              ),
                            ],
                          ),
                      ],
                    ),
                    const Divider(),

                    // fare + driver
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "₹${trip['fare']}",
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        if (trip['driver'] != null)
                          Text(
                            "Driver: ${trip['driver']}",
                            style: textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[700]),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      )),
    );
  }
}
