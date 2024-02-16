import 'dart:convert';

ForgotModel forgotModelFromJson(String str) =>
    ForgotModel.fromJson(json.decode(str));

String forgotModelToJson(ForgotModel data) => json.encode(data.toJson());

class ForgotModel {
  final dynamic response;
  final bool isSuccess;
  final int affectedRecords;
  final String endUserMessage;
  final dynamic links;
  final List<dynamic> validationErrors;
  final dynamic exception;

  ForgotModel({
    required this.response,
    required this.isSuccess,
    required this.affectedRecords,
    required this.endUserMessage,
    required this.links,
    required this.validationErrors,
    required this.exception,
  });

  factory ForgotModel.fromJson(Map<String, dynamic> json) => ForgotModel(
    response: json["response"],
    isSuccess: json["isSuccess"],
    affectedRecords: json["affectedRecords"],
    endUserMessage: json["endUserMessage"],
    links: json["links"],
    validationErrors:
    List<dynamic>.from(json["validationErrors"].map((x) => x)),
    exception: json["exception"],
  );

  Map<String, dynamic> toJson() => {
    "response": response,
    "isSuccess": isSuccess,
    "affectedRecords": affectedRecords,
    "endUserMessage": endUserMessage,
    "links": links,
    "validationErrors": List<dynamic>.from(validationErrors.map((x) => x)),
    "exception": exception,
  };
}
