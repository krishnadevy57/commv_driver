class OtpResponseModel {
  final String message;
  final String otp;
  final String action;

  OtpResponseModel({
    required this.message,
    required this.otp,
    required this.action,
  });

  factory OtpResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpResponseModel(
      message: json['message'] ?? '',
      otp: json['otp'] ?? '',
      action: json['action'] ?? '',
    );
  }
}
