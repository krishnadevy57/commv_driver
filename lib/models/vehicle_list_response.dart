// To parse this JSON data, do
//
//     final vehicleTypeListResponse = vehicleTypeListResponseFromJson(jsonString);

import 'dart:convert';

class VehicleTypeListResponse {

  VehicleTypeListResponse vehicleTypeListResponseFromJson(String str) => VehicleTypeListResponse.fromJson(json.decode(str));

  String vehicleTypeListResponseToJson(VehicleTypeListResponse data) => json.encode(data.toJson());

  String? message;
  List<Vehicle>? vehicles;

  VehicleTypeListResponse({
    this.message,
    this.vehicles,
  });

  factory VehicleTypeListResponse.fromJson(Map<String, dynamic> json) => VehicleTypeListResponse(
    message: json["message"],
    vehicles: json["vehicles"] == null ? [] : List<Vehicle>.from(json["vehicles"]!.map((x) => Vehicle.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "vehicles": vehicles == null ? [] : List<dynamic>.from(vehicles!.map((x) => x.toJson())),
  };
}

class Vehicle {
  String? id;
  String? type;
  int? baseFare;
  int? farePerKm;
  int? capacityKg;
  DateTime? createdAt;
  DateTime? updatedAt;

  Vehicle({
    this.id,
    this.type,
    this.baseFare,
    this.farePerKm,
    this.capacityKg,
    this.createdAt,
    this.updatedAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    id: json["id"],
    type: json["type"],
    baseFare: json["base_fare"],
    farePerKm: json["fare_per_km"],
    capacityKg: json["capacity_kg"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "base_fare": baseFare,
    "fare_per_km": farePerKm,
    "capacity_kg": capacityKg,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}
