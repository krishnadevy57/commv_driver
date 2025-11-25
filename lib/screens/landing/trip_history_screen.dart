// dart
import 'package:commv_driver/models/order_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/trip_history_controller.dart';
import '../../models/order_model.dart';
import '../../routes/app_routes.dart';

class TripHistoryScreen extends StatefulWidget {
  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  final controller = Get.put(TripHistoryController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!controller.isLoading.value && controller.tripHistory.length < controller.total.value) {
        controller.loadTripHistory(loadMore: true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'canceled':
      case 'cancelled':
        return Colors.redAccent;
      case 'assigned':
      case 'accepted':
        return Colors.blueAccent;
      case 'ride started':
      case 'started':
        return Colors.orangeAccent;
      default:
        return colorScheme.onSurface;
    }
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '';
    final d = dt.toLocal();
    final y = d.year;
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    final h = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$y-$m-$day  $h:$min';
  }

  String _formatFare(BookingOrder order) {
    final raw = order.totalPrice ?? order.approxTotalPrice ?? '0';
    final v = double.tryParse(raw.toString()) ?? 0.0;
    return v.toStringAsFixed(2);
  }

  String _formatDistance(BookingOrder order) {
    final d = (order.distance ?? order.actualDistance ?? '').toString();
    if (d.isEmpty) return '';
    // if numeric, append ' km' otherwise keep as-is
    final numVal = double.tryParse(d);
    if (numVal != null) return '${numVal.toStringAsFixed(2)} km';
    return d;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                controller.errorMessage.value!,
                style: textTheme.bodyLarge?.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (controller.tripHistory.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 56, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text('No trips yet', style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Your past bookings will appear here.', style: textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadTripHistory(loadMore: false),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            itemCount: controller.tripHistory.length,
            itemBuilder: (_, index) {
              final BookingOrder order = controller.tripHistory[index];

              final status = (order.bookingStatus ?? 'unknown').toString();
              final from = order.pickupLocation?.toString() ?? 'Unknown';
              final to = order.dropLocation?.toString() ?? 'Unknown';
              final dateTime = _formatDateTime(order.createdAt ?? order.assignedAt);
              final distanceText = _formatDistance(order);
              final fareStr = _formatFare(order);
              final driverLabel = order.driverId != null ? 'Driver #${order.driverId}' : '';
              final vehicleLabel = order.vehicle?.toString() ?? '';

              return GestureDetector(
                onTap: () {
                  // pass a stable JSON map to the next route
                  // Get.toNamed(Routes.ACTIVE_TRIP, arguments: order.toJson());
                  Get.toNamed(
                    Routes.ACTIVE_TRIP,
                    arguments: {"orderId": order.id},
                  );

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
                                from,
                                style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                            const SizedBox(width: 6),
                            const Icon(Icons.flag, color: Colors.red),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                to,
                                style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
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
                              dateTime,
                              style: textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
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
                              backgroundColor: _getStatusColor(status, colorScheme),
                            ),
                            Row(
                              children: [
                                if (distanceText.isNotEmpty) ...[
                                  const Icon(Icons.directions_car, size: 16),
                                  const SizedBox(width: 4),
                                  Text(distanceText, style: textTheme.bodyMedium),
                                  const SizedBox(width: 8),
                                ],
                                if (vehicleLabel.isNotEmpty)
                                  Text(vehicleLabel, style: textTheme.bodyMedium),
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
                              "₹$fareStr",
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            if (driverLabel.isNotEmpty)
                              Text(
                                driverLabel,
                                style: textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}