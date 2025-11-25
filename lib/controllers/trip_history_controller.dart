import 'dart:convert';
import 'package:commv_driver/models/order_detail_model.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../models/order_model.dart';

class TripHistoryController extends GetxController {
  var tripHistory = <BookingOrder>[].obs;
  var page = 1.obs;
  var limit = 20.obs;
  var total = 0.obs;
  var isLoading = false.obs;
  RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    getOrderHistory();
  }

  /// Fetch order history from API and update reactive state.
  Future<void> getOrderHistory({int page = 1, int limit = 20, bool append = false}) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final response = await ApiService().getOrderHistory(page: page, limit: limit);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final resp = OrderHistoryResponse.fromJson(data);

        // update pagination info
        this.page.value = resp.page;
        this.limit.value = resp.limit;
        total.value = resp.total;

        if (append) {
          tripHistory.addAll(resp.orders);
        } else {
          tripHistory.assignAll(resp.orders);
        }
      } else {
        errorMessage.value = 'Error ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Backwards-compatible loader used previously by the UI.
  Future<void> loadTripHistory({bool loadMore = false}) async {
    if (isLoading.value) return;
    final requestPage = loadMore ? page.value + 1 : 1;
    await getOrderHistory(page: requestPage, limit: limit.value, append: loadMore);
  }


  Future<BookingOrder?> fetchBookingDetailModel(int bookingId) async {
    final resp = await ApiService().getBookingDetail(bookingId);

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      print('getBookingDetail returned status ${resp.statusCode}');
      return null;
    }

    try {
      final decoded = jsonDecode(resp.body);
      Map<String, dynamic>? payload;

      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('data') && decoded['data'] is Map) {
          payload = Map<String, dynamic>.from(decoded['data'] as Map);
        } else if (decoded.containsKey('order') && decoded['order'] is Map) {
          payload = Map<String, dynamic>.from(decoded['order'] as Map);
        } else if (decoded.containsKey('booking') && decoded['booking'] is Map) {
          payload = Map<String, dynamic>.from(decoded['booking'] as Map);
        } else {
          payload = Map<String, dynamic>.from(decoded);
        }
      } else {
        return null;
      }

      return BookingOrder.fromJson(payload);
    } catch (e, st) {
      print('Error parsing booking detail: $e\n$st');
      return null;
    }
  }
}
