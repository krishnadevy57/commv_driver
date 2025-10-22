import 'package:get/get.dart';

class EarningsController extends GetxController {
  var totalEarnings = 0.obs;
  var earningList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchEarnings();
  }

  void fetchEarnings() {
    // Simulate API response
    earningList.value = [
      {"location": "IT Park", "date": "2025-07-10", "amount": 300},
      {"location": "Airport Road", "date": "2025-07-09", "amount": 220},
    ];
    totalEarnings.value =
        earningList.fold(0, (sum, e) => sum + (e['amount'] as int));
  }
}
