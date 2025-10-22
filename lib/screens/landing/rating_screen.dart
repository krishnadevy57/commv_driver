import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/rating_controller.dart';

class RatingScreen extends StatelessWidget {
  final controller = Get.put(RatingController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final appBarTheme = theme.appBarTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Rate Your Trip",
          style: appBarTheme.titleTextStyle ?? textTheme.titleLarge,
        ),
        backgroundColor: appBarTheme.backgroundColor ?? colorScheme.surface,
        elevation: appBarTheme.elevation,
        iconTheme: appBarTheme.iconTheme,
        foregroundColor: appBarTheme.iconTheme?.color,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "How was the customer?",
              style: textTheme.bodyLarge?.copyWith(fontSize: 18),
            ),
            SizedBox(height: 20),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    Icons.star,
                    color: controller.rating.value > index
                        ? colorScheme.secondary
                        : colorScheme.onSurface.withOpacity(0.3),
                    size: 32,
                  ),
                  onPressed: () => controller.setRating(index + 1),
                );
              }),
            )),
            SizedBox(height: 20),
            TextField(
              controller: controller.feedbackTextController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Additional comments (optional)",
                labelStyle: textTheme.bodyMedium,
                border: OutlineInputBorder(),
              ),
              style: textTheme.bodyMedium,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              onPressed: controller.submitFeedback,
              child: Text(
                "Submit",
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}