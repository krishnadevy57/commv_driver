import 'dart:convert';

LoginVerifyModel loginVerifyModelFromJson(String str) => LoginVerifyModel.fromJson(json.decode(str));

String loginVerifyModelToJson(LoginVerifyModel data) => json.encode(data.toJson());

class LoginVerifyModel {
  Driver? driver;
  String? token;

  LoginVerifyModel({this.driver, this.token});

  factory LoginVerifyModel.fromJson(Map<String, dynamic> json) => LoginVerifyModel(
    driver: json.containsKey("driver") && json["driver"] != null
        ? Driver.fromJson(json["driver"])
        : null,
    token: json["token"],
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
  Documents? documents;
  Location? location;
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
    documents: json.containsKey("documents") && json["documents"] != null?Documents.fromJson(json["documents"]):null,
    location: json.containsKey("location") && json["location"] != null
        ? Location.fromJson(json["location"])
        : null,
    createdAt: json.containsKey("createdAt") && json["createdAt"] != null
        ? DateTime.tryParse(json["createdAt"])
        : null,
    updatedAt: json.containsKey("updatedAt") && json["updatedAt"] != null
        ? DateTime.tryParse(json["updatedAt"])
        : null,
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
    "location": location?.toJson(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class Location {
  double? lat;
  double? lng;
  DateTime? updatedAt;

  Location({
     this.lat,
     this.lng,
     this.updatedAt,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    lat: json["lat"]?.toDouble(),
    lng: json["lng"]?.toDouble(),
    updatedAt: DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "lat": lat,
    "lng": lng,
    "updatedAt": updatedAt?.toIso8601String(),
  };
}



class Documents {
  Aadhar? pan;
  Aadhar? aadhar;
  Aadhar? rc;
  Aadhar? dl;
  Aadhar? insurance;

  Documents({
     this.pan,
     this.aadhar,
     this.rc,
     this.dl,
     this.insurance,
  });

  factory Documents.fromJson(Map<String, dynamic> json) => Documents(
    pan: Aadhar.fromJson(json["pan"]),
    aadhar: Aadhar.fromJson(json["aadhar"]),
    rc: Aadhar.fromJson(json["rc"]),
    dl: Aadhar.fromJson(json["dl"]),
    insurance: Aadhar.fromJson(json["insurance"]),
  );

  Map<String, dynamic> toJson() => {
    "pan": pan?.toJson(),
    "aadhar": aadhar?.toJson(),
    "rc": rc?.toJson(),
    "dl": dl?.toJson(),
    "insurance": insurance?.toJson(),
  };
}

class Aadhar {
  String? number;
  String? photoUrl;
  String? status;

  Aadhar({
     this.number,
     this.photoUrl,
     this.status,
  });

  factory Aadhar.fromJson(Map<String, dynamic> json) => Aadhar(
    number: json["number"],
    photoUrl: json["photoUrl"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "number": number,
    "photoUrl": photoUrl,
    "status": status,
  };
}