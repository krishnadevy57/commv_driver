import 'package:get/get.dart';

class TripHistoryController extends GetxController {
  var tripHistory = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTripHistory();
  }

  void loadTripHistory() {
    tripHistory.value = [
      {
        "id": "T001",
        "from": "Airport",
        "to": "Hotel Plaza",
        "fare": 220,
        "distance": "12 km",
        "date": "2025-07-05",
        "time": "10:30 AM",
        "status": "accepted",
        "driver": "Amit Sharma",
        "vehicle": "Sedan • DL01 AB 1234"
      },
      {
        "id": "T002",
        "from": "Bus Stand",
        "to": "University",
        "fare": 180,
        "distance": "8 km",
        "date": "2025-07-04",
        "time": "03:15 PM",
        "status": "ride started",
        "driver": "Ravi Kumar",
        "vehicle": "Auto • DL02 XY 5678"
      },
      {
        "id": "T003",
        "from": "Railway Station",
        "to": "Tech Hub",
        "fare": 190,
        "distance": "15 km",
        "date": "2025-07-07",
        "time": "09:00 AM",
        "status": "completed",
        "driver": "Sunil Yadav",
        "vehicle": "SUV • DL05 CD 7788"
      },
      {
        "id": "T004",
        "from": "City Mall",
        "to": "Main Market",
        "fare": 150,
        "distance": "5 km",
        "date": "2025-07-06",
        "time": "07:45 PM",
        "status": "canceled",
        "driver": "Naveen Gupta",
        "vehicle": "Bike • DL08 EF 9900"
      },
    ];
  }
}
