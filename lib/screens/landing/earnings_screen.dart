import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/earnings_controller.dart';

class EarningsScreen extends StatelessWidget {
  final controller = Get.put(EarningsController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Earnings",
          style: textTheme.titleLarge,
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme,
        elevation: theme.appBarTheme.elevation,
      ),
      body: Obx(() => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total Earnings: ₹${controller.totalEarnings.value}",
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: controller.earningList.length,
                itemBuilder: (_, index) {
                  final trip = controller.earningList[index];
                  return ListTile(
                    title: Text(
                      "Trip to ${trip['location']}",
                      style: textTheme.bodyLarge,
                    ),
                    subtitle: Text(
                      trip['date'],
                      style: textTheme.bodyMedium,
                    ),
                    trailing: Text(
                      "₹${trip['amount']}",
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      )),
    );
  }
}