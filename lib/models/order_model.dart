// dart
// Top-level helpers + OrderHistoryResponse
import 'dart:convert';

import 'package:commv_driver/models/order_detail_model.dart';

int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

bool? _parseBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  final s = v.toString().toLowerCase();
  if (s == 'true') return true;
  if (s == 'false') return false;
  return null;
}

DateTime? _parseDate(dynamic v) {
  if (v == null) return null;
  try {
    return DateTime.parse(v.toString()).toLocal();
  } catch (_) {
    return null;
  }
}

Map<String, dynamic>? _parseMap(dynamic v) {
  if (v == null) return null;
  if (v is Map) return Map<String, dynamic>.from(v);
  if (v is String) {
    try {
      final decoded = jsonDecode(v);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
  }
  return null;
}

class OrderHistoryResponse {
  final String? message;
  final int page;
  final int limit;
  final int total;
  final List<BookingOrder> orders;

  OrderHistoryResponse({
    this.message,
    required this.page,
    required this.limit,
    required this.total,
    required this.orders,
  });

  factory OrderHistoryResponse.fromJson(Map<String, dynamic> json) {
    try {
      final ordersRaw = json['orders'];
      final orders = <BookingOrder>[];
      if (ordersRaw is List) {
        for (final e in ordersRaw) {
          final m = _parseMap(e);
          if (m != null) {
            orders.add(BookingOrder.fromJson(m));
          }
        }
      }
      return OrderHistoryResponse(
        message: json['message']?.toString(),
        page: _parseInt(json['page']) ?? 1,
        limit: _parseInt(json['limit']) ?? 20,
        total: _parseInt(json['total']) ?? 0,
        orders: orders,
      );
    } catch (_) {
      return OrderHistoryResponse(message: null, page: 1, limit: 20, total: 0, orders: []);
    }
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'page': page,
        'limit': limit,
        'total': total,
        'orders': orders.map((o) => o.toJson()).toList(),
      };

  @override
  String toString() => jsonEncode(toJson());
}
