// To parse this JSON data, do
//
//     final loginVerifyModel = loginVerifyModelFromJson(jsonString);

import 'dart:convert';

LoginVerifyModel loginVerifyModelFromJson(String str) => LoginVerifyModel.fromJson(json.decode(str));

String loginVerifyModelToJson(LoginVerifyModel data) => json.encode(data.toJson());

class LoginVerifyModel {
  Driver? driver;
  String? token;

  LoginVerifyModel({
     this.driver,
     this.token,
  });

  factory LoginVerifyModel.fromJson(Map<String, dynamic> json) => LoginVerifyModel(
    driver: Driver.fromJson(json["driver"]),
    token: json.containsKey("token")?json["token"]:null,
  );

  Map<String, dynamic> toJson() => {
    "driver": driver?.toJson(),
    "token": token,
  };
}

class Driver {
  int? id;
  String? driverFirstName;
  String? driverLastName;
  String? driverEmail;
  String? driverPhoneNo;
  String? driverIdentity;
  String? deviceId;
  String? deviceType;
  String? deviceToken;
  bool? isOtpVerified;
  bool? isVerifiedEmail;
  bool? isVerifiedMobile;
  bool? isProfileVerified;
  bool? isKycVerified;
  String? driverStatus;
  String? vehicleNumber;
  String? vehicleType;
  String? vehicleColor;
  String? vehicleModel;
  String? vehicleCapacity;
  String? documents;
  String? location;
  DateTime? createdAt;
  DateTime? updatedAt;

  Driver({
     this.id,
     this.driverFirstName,
     this.driverLastName,
     this.driverEmail,
     this.driverPhoneNo,
     this.driverIdentity,
     this.deviceId,
     this.deviceType,
     this.deviceToken,
     this.isOtpVerified,
     this.isVerifiedEmail,
     this.isVerifiedMobile,
     this.isProfileVerified,
     this.isKycVerified,
     this.driverStatus,
     this.vehicleNumber,
     this.vehicleType,
     this.vehicleColor,
     this.vehicleModel,
     this.vehicleCapacity,
     this.documents,
     this.location,
     this.createdAt,
     this.updatedAt,
  });

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
    id: json["id"],
    driverFirstName: json["driverFirstName"],
    driverLastName: json["driverLastName"],
    driverEmail: json["driverEmail"],
    driverPhoneNo: json["driverPhoneNo"],
    driverIdentity: json["driverIdentity"],
    deviceId: json["deviceId"],
    deviceType: json["deviceType"],
    deviceToken: json["deviceToken"],
    isOtpVerified: json["isOtpVerified"],
    isVerifiedEmail: json["isVerifiedEmail"],
    isVerifiedMobile: json["isVerifiedMobile"],
    isProfileVerified: json["isProfileVerified"],
    isKycVerified: json["isKycVerified"],
    driverStatus: json["driverStatus"],
    vehicleNumber: json["vehicleNumber"],
    vehicleType: json["vehicleType"],
    vehicleColor: json["vehicleColor"],
    vehicleModel: json["vehicleModel"],
    vehicleCapacity: json["vehicleCapacity"],
    documents: json["documents"],
    location: json["location"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "driverFirstName": driverFirstName,
    "driverLastName": driverLastName,
    "driverEmail": driverEmail,
    "driverPhoneNo": driverPhoneNo,
    "driverIdentity": driverIdentity,
    "deviceId": deviceId,
    "deviceType": deviceType,
    "deviceToken": deviceToken,
    "isOtpVerified": isOtpVerified,
    "isVerifiedEmail": isVerifiedEmail,
    "isVerifiedMobile": isVerifiedMobile,
    "isProfileVerified": isProfileVerified,
    "isKycVerified": isKycVerified,
    "driverStatus": driverStatus,
    "vehicleNumber": vehicleNumber,
    "vehicleType": vehicleType,
    "vehicleColor": vehicleColor,
    "vehicleModel": vehicleModel,
    "vehicleCapacity": vehicleCapacity,
    "documents": documents,
    "location": location,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

