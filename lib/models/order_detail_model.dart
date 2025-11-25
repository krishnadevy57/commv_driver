// booking_model.dart
import 'dart:convert';

/// Custom exception thrown when parsing fails.
class ParseException implements Exception {
  final String message;
  ParseException(this.message);
  @override
  String toString() => 'ParseException: $message';
}

/// Helper parsing utilities to safely read values from dynamic maps.
class _Parse {
  static String? asString(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    return v.toString();
  }

  static int? asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    if (v is double) return v.toInt();
    return null;
  }

  static double? asDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static bool? asBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v is String) {
      final s = v.toLowerCase();
      if (s == 'true' || s == '1') return true;
      if (s == 'false' || s == '0') return false;
    }
    if (v is num) return v != 0;
    return null;
  }

  static DateTime? asDateTime(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) {
      try {
        return DateTime.parse(v);
      } catch (_) {
        // try other formats? for now return null
        return null;
      }
    }
    return null;
  }

  static Map<String, dynamic>? asMap(dynamic v) {
    if (v == null) return null;
    if (v is Map<String, dynamic>) return v;
    if (v is Map) {
      // try to cast
      return Map<String, dynamic>.from(v);
    }
    return null;
  }

  static List? asList(dynamic v) {
    if (v == null) return null;
    if (v is List) return v;
    return null;
  }
}

/// Top-level wrapper because your JSON has {"booking": { ... }}
class BookingResponse {
  final BookingOrder? booking;

  BookingResponse({required this.booking});

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    try {
      final bookingJson = _Parse.asMap(json['booking']);
      return BookingResponse(
        booking: bookingJson == null ? null : BookingOrder.fromJson(bookingJson),
      );
    } catch (e, st) {
      throw ParseException('BookingResponse.fromJson failed: $e\n$st');
    }
  }

  Map<String, dynamic> toJson() => {
    'booking': booking?.toJson(),
  };

  static BookingResponse fromRawJson(String str) =>
      BookingResponse.fromJson(json.decode(str) as Map<String, dynamic>);
  String toRawJson() => json.encode(toJson());
}

/// Booking model
class BookingOrder {
  final int? id;
  final String? approxTotalPrice;
  final String? bookingStatus;
  final String? couponCode;
  final bool? deliveryByPin;
  final String? discountPrice;
  final String? paymentInfo;
  final String? totalPrice;
  final double? distance;
  final int? numberOfGoods;
  final String? packageType;
  final Location? pickupLocation;
  final Location? dropLocation;
  final Vehicle? vehicle;
  final int? driverId;
  final DateTime? assignedAt;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancelReason;
  final String? verifyCode;
  final bool? isVerified;
  final DateTime? verifiedAt;
  final String? paymentStatus;
  final String? paymentMethod;
  final String? paymentTxnId;
  final double? amountPaid;
  final double? actualDistance;
  final List<ActionHistory>? actionHistory;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookingOrder({
    this.id,
    this.approxTotalPrice,
    this.bookingStatus,
    this.couponCode,
    this.deliveryByPin,
    this.discountPrice,
    this.paymentInfo,
    this.totalPrice,
    this.distance,
    this.numberOfGoods,
    this.packageType,
    this.pickupLocation,
    this.dropLocation,
    this.vehicle,
    this.driverId,
    this.assignedAt,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancelReason,
    this.verifyCode,
    this.isVerified,
    this.verifiedAt,
    this.paymentStatus,
    this.paymentMethod,
    this.paymentTxnId,
    this.amountPaid,
    this.actualDistance,
    this.actionHistory,
    this.createdAt,
    this.updatedAt,
  });

  factory BookingOrder.fromJson(Map<String, dynamic> json) {
    try {
      return BookingOrder(
        id: _Parse.asInt(json['id']),
        approxTotalPrice: _Parse.asString(json['ApproxTotalPrice']),
        bookingStatus: _Parse.asString(json['BookingStatus']),
        couponCode: _Parse.asString(json['CouponCode']),
        deliveryByPin: _Parse.asBool(json['DeliveryByPin']),
        discountPrice: _Parse.asString(json['DiscountPrice']),
        paymentInfo: _Parse.asString(json['PaymentInfo']),
        totalPrice: _Parse.asString(json['TotalPrice']),
        distance: _Parse.asDouble(json['distance']),
        numberOfGoods: _Parse.asInt(json['numberOfGoods']),
        packageType: _Parse.asString(json['packageType']),
        pickupLocation: _Parse.asMap(json['pickupLocation']) == null
            ? null
            : Location.fromJson(
            Map<String, dynamic>.from(json['pickupLocation'])),
        dropLocation: _Parse.asMap(json['dropLocation']) == null
            ? null
            : Location.fromJson(Map<String, dynamic>.from(json['dropLocation'])),
        vehicle: _Parse.asMap(json['vehicle']) == null
            ? null
            : Vehicle.fromJson(Map<String, dynamic>.from(json['vehicle'])),
        driverId: _Parse.asInt(json['driverId']),
        assignedAt: _Parse.asDateTime(json['assignedAt']),
        acceptedAt: _Parse.asDateTime(json['acceptedAt']),
        startedAt: _Parse.asDateTime(json['startedAt']),
        completedAt: _Parse.asDateTime(json['completedAt']),
        cancelledAt: _Parse.asDateTime(json['cancelledAt']),
        cancelReason: _Parse.asString(json['cancelReason']),
        verifyCode: _Parse.asString(json['verifyCode']),
        isVerified: _Parse.asBool(json['isVerified']),
        verifiedAt: _Parse.asDateTime(json['verifiedAt']),
        paymentStatus: _Parse.asString(json['paymentStatus']),
        paymentMethod: _Parse.asString(json['paymentMethod']),
        paymentTxnId: _Parse.asString(json['paymentTxnId']),
        amountPaid: _Parse.asDouble(json['amountPaid']),
        actualDistance: _Parse.asDouble(json['actualDistance']),
        actionHistory: () {
          final list = _Parse.asList(json['actionHistory']);
          if (list == null) return null;
          final out = <ActionHistory>[];
          for (var i = 0; i < list.length; i++) {
            final el = list[i];
            if (el is Map) {
              out.add(ActionHistory.fromJson(Map<String, dynamic>.from(el)));
            } else {
              // attempt to parse if stringified JSON
              throw ParseException('actionHistory[$i] is not an object');
            }
          }
          return out;
        }(),
        createdAt: _Parse.asDateTime(json['createdAt']),
        updatedAt: _Parse.asDateTime(json['updatedAt']),
      );
    } catch (e, st) {
      throw ParseException('Booking.fromJson failed: $e\n$st');
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ApproxTotalPrice': approxTotalPrice,
    'BookingStatus': bookingStatus,
    'CouponCode': couponCode,
    'DeliveryByPin': deliveryByPin,
    'DiscountPrice': discountPrice,
    'PaymentInfo': paymentInfo,
    'TotalPrice': totalPrice,
    'distance': distance?.toStringAsFixed(3),
    'numberOfGoods': numberOfGoods,
    'packageType': packageType,
    'pickupLocation': pickupLocation?.toJson(),
    'dropLocation': dropLocation?.toJson(),
    'vehicle': vehicle?.toJson(),
    'driverId': driverId,
    'assignedAt': assignedAt?.toIso8601String(),
    'acceptedAt': acceptedAt?.toIso8601String(),
    'startedAt': startedAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'cancelledAt': cancelledAt?.toIso8601String(),
    'cancelReason': cancelReason,
    'verifyCode': verifyCode,
    'isVerified': isVerified,
    'verifiedAt': verifiedAt?.toIso8601String(),
    'paymentStatus': paymentStatus,
    'paymentMethod': paymentMethod,
    'paymentTxnId': paymentTxnId,
    'amountPaid': amountPaid,
    'actualDistance': actualDistance,
    'actionHistory': actionHistory?.map((e) => e.toJson()).toList(),
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}

/// Location model used for pickup/drop
class Location {
  final String? landmark;
  final double? latitude;
  final double? longitude;
  final String? addressType;
  final String? fullAddress;
  final String? houseNumber;
  final String? addressUserName;
  final String? addressUserPincode;
  final String? addressUserMobileNumber;

  Location({
    this.landmark,
    this.latitude,
    this.longitude,
    this.addressType,
    this.fullAddress,
    this.houseNumber,
    this.addressUserName,
    this.addressUserPincode,
    this.addressUserMobileNumber,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    try {
      return Location(
        landmark: _Parse.asString(json['landmark']) ?? '',
        latitude: _Parse.asDouble(json['latitude']),
        longitude: _Parse.asDouble(json['longitude']),
        addressType: _Parse.asString(json['addressType']),
        fullAddress: _Parse.asString(json['fullAddress']),
        houseNumber: _Parse.asString(json['houseNumber']),
        addressUserName: _Parse.asString(json['addressUserName']),
        addressUserPincode: _Parse.asString(json['addressUserPincode']),
        addressUserMobileNumber:
        _Parse.asString(json['addressUserMobileNumber']),
      );
    } catch (e, st) {
      throw ParseException('Location.fromJson failed: $e\n$st');
    }
  }

  Map<String, dynamic> toJson() => {
    'landmark': landmark,
    'latitude': latitude,
    'longitude': longitude,
    'addressType': addressType,
    'fullAddress': fullAddress,
    'houseNumber': houseNumber,
    'addressUserName': addressUserName,
    'addressUserPincode': addressUserPincode,
    'addressUserMobileNumber': addressUserMobileNumber,
  };
}

/// Vehicle model
class Vehicle {
  final int? id;
  final String? type;
  final double? baseFare;
  final double? capacityKg;
  final double? farePerKm;

  Vehicle({
    this.id,
    this.type,
    this.baseFare,
    this.capacityKg,
    this.farePerKm,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    try {
      return Vehicle(
        id: _Parse.asInt(json['id']),
        type: _Parse.asString(json['type']),
        baseFare: _Parse.asDouble(json['base_fare']),
        capacityKg: _Parse.asDouble(json['capacity_kg']),
        farePerKm: _Parse.asDouble(json['fare_per_km']),
      );
    } catch (e, st) {
      throw ParseException('Vehicle.fromJson failed: $e\n$st');
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'base_fare': baseFare,
    'capacity_kg': capacityKg,
    'fare_per_km': farePerKm,
  };
}

/// ActionHistory entries
class ActionHistory {
  final DateTime? at;
  final String? by;
  final String? role;
  final String? action;
  final ActionMeta? meta;

  ActionHistory({
    this.at,
    this.by,
    this.role,
    this.action,
    this.meta,
  });

  factory ActionHistory.fromJson(Map<String, dynamic> json) {
    try {
      return ActionHistory(
        at: _Parse.asDateTime(json['at']),
        by: _Parse.asString(json['by']),
        role: _Parse.asString(json['role']),
        action: _Parse.asString(json['action']),
        meta: _Parse.asMap(json['meta']) == null
            ? null
            : ActionMeta.fromJson(Map<String, dynamic>.from(json['meta'])),
      );
    } catch (e, st) {
      throw ParseException('ActionHistory.fromJson failed: $e\n$st');
    }
  }

  Map<String, dynamic> toJson() => {
    'at': at?.toIso8601String(),
    'by': by,
    'role': role,
    'action': action,
    'meta': meta?.toJson(),
  };
}

/// Meta object inside actionHistory (keeps driverId in your sample)
class ActionMeta {
  final int? driverId;
  // extend later for other keys

  ActionMeta({this.driverId});

  factory ActionMeta.fromJson(Map<String, dynamic> json) {
    try {
      return ActionMeta(
        driverId: _Parse.asInt(json['driverId']),
      );
    } catch (e, st) {
      throw ParseException('ActionMeta.fromJson failed: $e\n$st');
    }
  }

  Map<String, dynamic> toJson() => {
    'driverId': driverId,
  };
}
