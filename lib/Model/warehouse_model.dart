// To parse this JSON data, do
//
//     final wareHouseModel = wareHouseModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

WareHouseModel wareHouseModelFromJson(String str) =>
    WareHouseModel.fromJson(json.decode(str));

String wareHouseModelToJson(WareHouseModel data) => json.encode(data.toJson());

class WareHouseModel {
  final Response response;
  final bool isSuccess;
  final String endUserMessage;
  final dynamic links;
  final List<dynamic> validationErrors;
  final dynamic exception;

  WareHouseModel({
    required this.response,
    required this.isSuccess,
    required this.endUserMessage,
    required this.links,
    required this.exception,
    required this.validationErrors,
  });

  factory WareHouseModel.fromJson(Map<String, dynamic> json) => WareHouseModel(
    response: Response.fromJson(json["response"]),
    isSuccess: json["isSuccess"],
    endUserMessage: json["endUserMessage"],
    links: json["links"],
    validationErrors:
    List<dynamic>.from(json["validationErrors"].map((x) => x)),
    exception: json["exception"],
  );

  Map<String, dynamic> toJson() => {
    "response": response.toJson(),
    "isSuccess": isSuccess,
    "endUserMessage": endUserMessage,
    "links": links,
    "validationErrors": List<dynamic>.from(validationErrors.map((x) => x)),
    "exception": exception,
  };
}

class Response {
  final List<WareHouseList> wareHouseList;
  final int count;
  final int affectedRecords;

  Response({
    required this.wareHouseList,
    required this.count,
    required this.affectedRecords,
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
    wareHouseList: List<WareHouseList>.from(
        json["wareHouseList"].map((x) => WareHouseList.fromJson(x))),
    count: json["count"],
    affectedRecords: json["affectedRecords"],
  );

  Map<String, dynamic> toJson() => {
    "wareHouseList":
    List<dynamic>.from(wareHouseList.map((x) => x.toJson())),
    "count": count,
    "affectedRecords": affectedRecords,
  };
}

class WareHouseList {
  final int id;
  final String userId;
  final String whsCode;
  final String whsName;
  final String whsState;
  final int companyId;
  final String name;
  final String fullName;
  final String? address;
  final String? email;
  final String? city;

  WareHouseList({
    required this.id,
    required this.userId,
    required this.whsCode,
    required this.whsName,
    required this.whsState,
    required this.companyId,
    required this.name,
    required this.fullName,
    required this.address,
    required this.email,
    required this.city,
  });

  factory WareHouseList.fromJson(Map<String, dynamic> json) => WareHouseList(
    id: json["id"],
    userId: json["userId"],
    whsCode: json["whsCode"],
    whsName: json["whsName"],
    whsState: json["whsState"],
    companyId: json["companyId"],
    name: json["name"],
    fullName: json["fullName"],
    address: json["address"],
    email: json["email"],
    city: json["city"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "whsCode": whsCode,
    "whsName": whsName,
    "whsState": whsState,
    "companyId": companyId,
    "name": name,
    "fullName": fullName,
    "address": address,
    "email": email,
    "city": city,
  };
}
