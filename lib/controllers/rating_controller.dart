import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RatingController extends GetxController {
  var rating = 0.obs;
  final feedbackTextController = TextEditingController();

  void setRating(int value) {
    rating.value = value;
  }

  void submitFeedback() {
    if (rating.value == 0) {
      Get.snackbar("Rating Required", "Please select at least 1 star");
      return;
    }

    final feedback = {
      "rating": rating.value,
      "comment": feedbackTextController.text.trim(),
    };

    // TODO: Send feedback to API
    print("Feedback Submitted: $feedback");
    Get.snackbar("Thank you", "Your feedback has been submitted");

    // Reset UI
    rating.value = 0;
    feedbackTextController.clear();
    Get.back(); // go to home or previous screen
  }
}
