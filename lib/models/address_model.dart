class AddressModel {
  final String? houseNumber;
  final String? landmark;
  final String? addressUserName;
  final String? addressUserMobileNumber;
  final String? addressUserPincode;
  final double? latitude;
  final double? longitude;
  final String? fullAddress;
  final String? addressType;

  AddressModel({
    this.houseNumber,
    this.landmark,
    this.addressUserName,
    this.addressUserMobileNumber,
    this.addressUserPincode,
    this.latitude,
    this.longitude,
    this.fullAddress,
    this.addressType,
  });

  Map<String, dynamic> toMap() {
    return {
      'houseNumber': houseNumber,
      'landmark': landmark,
      'addressUserName': addressUserName,
      'addressUserMobileNumber': addressUserMobileNumber,
      'addressUserPincode': addressUserPincode,
      'latitude': latitude,
      'longitude': longitude,
      'fullAddress': fullAddress,
      'addressType': addressType,
    };
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      houseNumber: map['houseNumber'],
      landmark: map['landmark'],
      addressUserName: map['addressUserName'],
      addressUserMobileNumber: map['addressUserMobileNumber'],
      addressUserPincode: map['addressUserPincode'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      fullAddress: map['fullAddress'],
      addressType: map['addressType'],
    );
  }
}