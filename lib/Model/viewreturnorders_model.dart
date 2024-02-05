import 'dart:convert';

ViewReturnOrdersModel viewReturnOrdersModelFromJson(String str) =>
    ViewReturnOrdersModel.fromJson(json.decode(str));

String viewReturnOrdersModelToJson(ViewReturnOrdersModel data) =>
    json.encode(data.toJson());

class ViewReturnOrdersModel {
  final Response response;
  final bool isSuccess;
  final int affectedRecords;
  final String endUserMessage;
  final dynamic links;
  final List<dynamic> validationErrors;
  final dynamic exception;

  ViewReturnOrdersModel({
    required this.response,
    required this.isSuccess,
    required this.affectedRecords,
    required this.endUserMessage,
    required this.links,
    required this.validationErrors,
    required this.exception,
  });

  factory ViewReturnOrdersModel.fromJson(Map<String, dynamic> json) =>
      ViewReturnOrdersModel(
        response: Response.fromJson(json["response"]),
        isSuccess: json["isSuccess"],
        affectedRecords: json["affectedRecords"],
        endUserMessage: json["endUserMessage"],
        links: json["links"],
        validationErrors:
            List<dynamic>.from(json["validationErrors"].map((x) => x)),
        exception: json["exception"],
      );

  Map<String, dynamic> toJson() => {
        "response": response.toJson(),
        "isSuccess": isSuccess,
        "affectedRecords": affectedRecords,
        "endUserMessage": endUserMessage,
        "links": links,
        "validationErrors": List<dynamic>.from(validationErrors.map((x) => x)),
        "exception": exception,
      };
}

class Response {
  final List<ReturnOrderDetailsResult> returnOrderDetailsResult;
  final List<ReturnOrderItemXrefList> returnOrderItemXrefList;

  Response({
    required this.returnOrderDetailsResult,
    required this.returnOrderItemXrefList,
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        returnOrderDetailsResult: List<ReturnOrderDetailsResult>.from(
            json["returnOrderDetailsResult"]
                .map((x) => ReturnOrderDetailsResult.fromJson(x))),
        returnOrderItemXrefList: List<ReturnOrderItemXrefList>.from(
            json["returnOrderItemXrefList"]
                .map((x) => ReturnOrderItemXrefList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "returnOrderDetailsResult":
            List<dynamic>.from(returnOrderDetailsResult.map((x) => x.toJson())),
        "returnOrderItemXrefList":
            List<dynamic>.from(returnOrderItemXrefList.map((x) => x.toJson())),
      };
}

class ReturnOrderDetailsResult {
  final int id;
  final int companyId;
  final String returnOrderNumber;
  final DateTime returnOrderDate;
  final String partyCode;
  final String partyName;
  final String partyAddress;
  final String partyState;
  final String partyPhoneNumber;
  final String partyGstNumber;
  final String proprietorName;
  final double partyOutStandingAmount;
  final String lrNumber;
  final DateTime lrDate;
  final int statusTypeId;
  final String fileName;
  final String fileLocation;
  final String fileExtension;
  final String fileUrl;
  final String statusName;
  final double discount;
  final double igst;
  final double cgst;
  final double sgst;
  final double totalCost;
  final int noOfItems;
  final String dealerRemarks;
  final bool isActive;
  final String createdBy;
  final DateTime createdDate;
  final String updatedBy;
  final DateTime updatedDate;

  ReturnOrderDetailsResult({
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
    required this.lrNumber,
    required this.lrDate,
    required this.statusTypeId,
    required this.fileName,
    required this.fileLocation,
    required this.fileExtension,
    required this.fileUrl,
    required this.statusName,
    required this.discount,
    required this.igst,
    required this.cgst,
    required this.sgst,
    required this.totalCost,
    required this.noOfItems,
    required this.dealerRemarks,
    required this.isActive,
    required this.createdBy,
    required this.createdDate,
    required this.updatedBy,
    required this.updatedDate,
  });

  factory ReturnOrderDetailsResult.fromJson(Map<String, dynamic> json) =>
      ReturnOrderDetailsResult(
        id: json["id"],
        companyId: json["companyId"],
        returnOrderNumber: json["returnOrderNumber"],
        returnOrderDate: DateTime.parse(json["returnOrderDate"]),
        partyCode: json["partyCode"],
        partyName: json["partyName"],
        partyAddress: json["partyAddress"],
        partyState: json["partyState"],
        partyPhoneNumber: json["partyPhoneNumber"],
        partyGstNumber: json["partyGSTNumber"],
        proprietorName: json["proprietorName"],
        partyOutStandingAmount: json["partyOutStandingAmount"]?.toDouble(),
        lrNumber: json["lrNumber"],
        lrDate: DateTime.parse(json["lrDate"]),
        statusTypeId: json["statusTypeId"],
        fileName: json["fileName"],
        fileLocation: json["fileLocation"],
        fileExtension: json["fileExtension"],
        fileUrl: json["fileUrl"],
        statusName: json["statusName"],
        discount: json["discount"]?.toDouble(),
        igst: json["igst"]?.toDouble(),
        cgst: json["cgst"]?.toDouble(),
        sgst: json["sgst"]?.toDouble(),
        totalCost: json["totalCost"]?.toDouble(),
        noOfItems: json["noOfItems"],
        dealerRemarks: json["dealerRemarks"],
        isActive: json["isActive"],
        createdBy: json["createdBy"],
        createdDate: DateTime.parse(json["createdDate"]),
        updatedBy: json["updatedBy"],
        updatedDate: DateTime.parse(json["updatedDate"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "companyId": companyId,
        "returnOrderNumber": returnOrderNumber,
        "returnOrderDate": returnOrderDate.toIso8601String(),
        "partyCode": partyCode,
        "partyName": partyName,
        "partyAddress": partyAddress,
        "partyState": partyState,
        "partyPhoneNumber": partyPhoneNumber,
        "partyGSTNumber": partyGstNumber,
        "proprietorName": proprietorName,
        "partyOutStandingAmount": partyOutStandingAmount,
        "lrNumber": lrNumber,
        "lrDate": lrDate.toIso8601String(),
        "statusTypeId": statusTypeId,
        "fileName": fileName,
        "fileLocation": fileLocation,
        "fileExtension": fileExtension,
        "fileUrl": fileUrl,
        "statusName": statusName,
        "discount": discount,
        "igst": igst,
        "cgst": cgst,
        "sgst": sgst,
        "totalCost": totalCost,
        "noOfItems": noOfItems,
        "dealerRemarks": dealerRemarks,
        "isActive": isActive,
        "createdBy": createdBy,
        "createdDate": createdDate.toIso8601String(),
        "updatedBy": updatedBy,
        "updatedDate": updatedDate.toIso8601String(),
      };
}

class ReturnOrderItemXrefList {
  final String statusName;
  final int id;
  final int returnOrderId;
  final String itemGrpCod;
  final String itemGrpName;
  final String itemCode;
  final String itemName;
  final int statusTypeId;
  final int orderQty;
  final double price;
  final double igst;
  final double cgst;
  final double sgst;
  final String remarks;

  ReturnOrderItemXrefList({
    required this.statusName,
    required this.id,
    required this.returnOrderId,
    required this.itemGrpCod,
    required this.itemGrpName,
    required this.itemCode,
    required this.itemName,
    required this.statusTypeId,
    required this.orderQty,
    required this.price,
    required this.igst,
    required this.cgst,
    required this.sgst,
    required this.remarks,
  });

  factory ReturnOrderItemXrefList.fromJson(Map<String, dynamic> json) =>
      ReturnOrderItemXrefList(
        statusName: json["statusName"],
        id: json["id"],
        returnOrderId: json["returnOrderId"],
        itemGrpCod: json["itemGrpCod"],
        itemGrpName: json["itemGrpName"],
        itemCode: json["itemCode"],
        itemName: json["itemName"],
        statusTypeId: json["statusTypeId"],
        orderQty: json["orderQty"],
        price: json["price"]?.toDouble(),
        igst: json["igst"]?.toDouble(),
        cgst: json["cgst"]?.toDouble(),
        sgst: json["sgst"]?.toDouble(),
        remarks: json["remarks"],
      );

  Map<String, dynamic> toJson() => {
        "statusName": statusName,
        "id": id,
        "returnOrderId": returnOrderId,
        "itemGrpCod": itemGrpCod,
        "itemGrpName": itemGrpName,
        "itemCode": itemCode,
        "itemName": itemName,
        "statusTypeId": statusTypeId,
        "orderQty": orderQty,
        "price": price,
        "igst": igst,
        "cgst": cgst,
        "sgst": sgst,
        "remarks": remarks,
      };
}
