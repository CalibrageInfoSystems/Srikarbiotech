// To parse this JSON data, do
//
//     final returnOrdersModel = returnOrdersModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

ReturnOrdersModel returnOrdersModelFromJson(String str) =>
    ReturnOrdersModel.fromJson(json.decode(str));

String returnOrdersModelToJson(ReturnOrdersModel data) =>
    json.encode(data.toJson());

class ReturnOrdersModel {
  final Response response;
  final bool isSuccess;
  final String endUserMessage;
  final dynamic links;
  final List<dynamic> validationErrors;
  final dynamic exception;

  ReturnOrdersModel({
    required this.response,
    required this.isSuccess,
    required this.endUserMessage,
    required this.links,
    required this.validationErrors,
    required this.exception,
  });

  factory ReturnOrdersModel.fromJson(Map<String, dynamic> json) =>
      ReturnOrdersModel(
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
  final List<ReturnOrdersList> returnOrdersList;
  final int count;
  final int affectedRecords;

  Response({
    required this.returnOrdersList,
    required this.count,
    required this.affectedRecords,
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
    returnOrdersList: List<ReturnOrdersList>.from(
        json["returnOrdersList"].map((x) => ReturnOrdersList.fromJson(x))),
    count: json["count"],
    affectedRecords: json["affectedRecords"],
  );

  Map<String, dynamic> toJson() => {
    "returnOrdersList":
    List<dynamic>.from(returnOrdersList.map((x) => x.toJson())),
    "count": count,
    "affectedRecords": affectedRecords,
  };
}

class ReturnOrdersList {
  final int id;
  final int companyId;
  final String returnOrderNumber;
  final String returnOrderDate;
  final String partyCode;
  final String partyName;
  final String partyAddress;
  final String partyState;
  final String partyPhoneNumber;
  final String partyGstNumber;
  final String proprietorName;
  final double partyOutStandingAmount;
  final String lrDate;
  final String lrNumber;
  final int statusTypeId;
  final String statusName;
  final double discount;
  final double totalCost;
  final int noOfItems;
  final String remarks;
  final bool isActive;
  final String createdBy;
  final String createdDate;
  final String updatedBy;
  final DateTime updatedDate;
  final String? whsCode;
  final String? whsName;
  final String? whsState;

  ReturnOrdersList({
    required this.id,
    required this.companyId,
    required this.returnOrderNumber,
    required this.returnOrderDate,
    required this.partyCode,
    required this.partyName,
    required this.partyAddress,
    required this.partyState,
    required this.partyPhoneNumber,
    required this.partyGstNumber,
    required this.proprietorName,
    required this.partyOutStandingAmount,
    required this.lrDate,
    required this.lrNumber,
    required this.statusTypeId,
    required this.statusName,
    required this.discount,
    required this.totalCost,
    required this.noOfItems,
    required this.remarks,
    required this.isActive,
    required this.createdBy,
    required this.createdDate,
    required this.updatedBy,
    required this.updatedDate,
    required this.whsCode,
    required this.whsName,
    required this.whsState,
  });

  factory ReturnOrdersList.fromJson(Map<String, dynamic> json) =>
      ReturnOrdersList(
        id: json["id"],
        companyId: json["companyId"],
        returnOrderNumber: json["returnOrderNumber"],
        returnOrderDate: json["returnOrderDate"],
        partyCode: json["partyCode"],
        partyName: json["partyName"],
        partyAddress: json["partyAddress"],
        partyState: json["partyState"],
        partyPhoneNumber: json["partyPhoneNumber"],
        partyGstNumber: json["partyGSTNumber"],
        proprietorName: json["proprietorName"],
        partyOutStandingAmount: json["partyOutStandingAmount"]?.toDouble(),
        lrDate: json["lrDate"],
        lrNumber: json["lrNumber"],
        statusTypeId: json["statusTypeId"],
        statusName: json["statusName"],
        discount: json["discount"]?.toDouble(),
        totalCost: json["totalCost"]?.toDouble(),
        noOfItems: json["noOfItems"],
        remarks: json["remarks"],
        isActive: json["isActive"],
        createdBy: json["createdBy"],
        createdDate: json["createdDate"],
        updatedBy: json["updatedBy"],
        updatedDate: DateTime.parse(json["updatedDate"]),
        whsCode: json['whsCode'],
        whsName: json['whsName'],
        whsState: json['whsState'],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "companyId": companyId,
    "returnOrderNumber": returnOrderNumber,
    "returnOrderDate": returnOrderDate,
    "partyCode": partyCode,
    "partyName": partyName,
    "partyAddress": partyAddress,
    "partyState": partyState,
    "partyPhoneNumber": partyPhoneNumber,
    "partyGSTNumber": partyGstNumber,
    "proprietorName": proprietorName,
    "partyOutStandingAmount": partyOutStandingAmount,
    "lrDate": lrDate,
    "lrNumber": lrNumber,
    "statusTypeId": statusTypeId,
    "statusName": statusName,
    "discount": discount,
    "totalCost": totalCost,
    "noOfItems": noOfItems,
    "remarks": remarks,
    "isActive": isActive,
    "createdBy": createdBy,
    "createdDate": createdDate,
    "updatedBy": updatedBy,
    "updatedDate": updatedDate.toIso8601String(),
    "whsCode":whsCode,
    "whsName" : whsName,
    "whsState": whsState

  };
}
