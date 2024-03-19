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
  final String returnOrderDate;
  final String partyCode;
  final String partyName;
  final String partyAddress;
  final String partyState;
  final String partyPhoneNumber;
  final String partyGstNumber;
  final String proprietorName;
  final double partyOutStandingAmount;
  final String lrNumber;
  final String lrDate;
  final int statusTypeId;
  final String? fileName;
  final String? fileLocation;
  final String? fileExtension;
  final String? fileUrl;
  final String statusName;
  final double discount;
  final double totalCost;
  final int noOfItems;
  final String dealerRemarks;
  final bool isActive;
  final String createdBy;
  final String createdDate;
  final String updatedBy;
  final String updatedDate;
  final String? transportName;
  final String? whsCode;
  final String? whsName;
  final String? whsState;

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
    required this.totalCost,
    required this.noOfItems,
    required this.dealerRemarks,
    required this.isActive,
    required this.createdBy,
    required this.createdDate,
    required this.updatedBy,
    required this.updatedDate,
    required this.transportName,
    required this.whsCode,
    required this.whsName,
    required this.whsState
  });

  factory ReturnOrderDetailsResult.fromJson(Map<String, dynamic> json) =>
      ReturnOrderDetailsResult(
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
        lrNumber: json["lrNumber"],
        lrDate: json["lrDate"],
        statusTypeId: json["statusTypeId"],
        fileName: json["fileName"],
        fileLocation: json["fileLocation"],
        fileExtension: json["fileExtension"],
        fileUrl: json["fileUrl"],
        statusName: json["statusName"],
        discount: json["discount"]?.toDouble(),
        totalCost: json["totalCost"]?.toDouble(),
        noOfItems: json["noOfItems"],
        dealerRemarks: json["dealerRemarks"],
        isActive: json["isActive"],
        createdBy: json["createdBy"],
        createdDate: json["createdDate"],
        updatedBy: json["updatedBy"],
        updatedDate: json["updatedDate"],
        transportName: json["transportName"],
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
    "lrNumber": lrNumber,
    "lrDate": lrDate,
    "statusTypeId": statusTypeId,
    "fileName": fileName,
    "fileLocation": fileLocation,
    "fileExtension": fileExtension,
    "fileUrl": fileUrl,
    "statusName": statusName,
    "discount": discount,
    "totalCost": totalCost,
    "noOfItems": noOfItems,
    "dealerRemarks": dealerRemarks,
    "isActive": isActive,
    "createdBy": createdBy,
    "createdDate": createdDate,
    "updatedBy": updatedBy,
    "updatedDate": updatedDate,
    "transportName": transportName,
    "whsCode":whsCode,
    "whsName" : whsName,
    "whsState": whsState
  };
}

class ReturnOrderItemXrefList {
  final String statusName;
  final String? fileUrl;
  final int id;
  final int returnOrderId;
  final String itemGrpCod;
  final String itemGrpName;
  final String itemCode;
  final String itemName;
  final int statusTypeId;
  final int orderQty;
  final double price;
  final String? remarks;
  final double totalPrice;
  final int? partialQty;
  final String? fileName;
  final String? fileLocation;
  final String? fileExtension;

  factory ReturnOrderItemXrefList.fromJson(Map<String, dynamic> json) =>
      ReturnOrderItemXrefList(
        statusName: json['statusName'] ?? "",
        fileUrl: json['fileUrl'],
        id: json['id'] ?? 0,
        returnOrderId: json['returnOrderId'] ?? 0,
        itemGrpCod: json['itemGrpCod'] ?? "",
        itemGrpName: json['itemGrpName'] ?? "",
        itemCode: json['itemCode'] ?? "",
        itemName: json['itemName'] ?? "",
        statusTypeId: json['statusTypeId'] ?? 0,
        orderQty: json['orderQty'] ?? 0,
        price: json['price']?.toDouble() ?? 0.0,
        remarks: json['remarks'],
        totalPrice: json['totalPrice']?.toDouble() ?? 0.0,
        partialQty: json['partialQty'],
        fileName: json['fileName'],
        fileLocation: json['fileLocation'],
        fileExtension: json['fileExtension'],
      );

  ReturnOrderItemXrefList(
      {required this.statusName,
        required this.fileUrl,
        required this.id,
        required this.returnOrderId,
        required this.itemGrpCod,
        required this.itemGrpName,
        required this.itemCode,
        required this.itemName,
        required this.statusTypeId,
        required this.orderQty,
        required this.price,
        required this.remarks,
        required this.totalPrice,
        required this.partialQty,
        required this.fileName,
        required this.fileLocation,
        required this.fileExtension});

  Map<String, dynamic> toJson() => {
    "statusName": statusName,
    "fileUrl": fileUrl,
    "id": id,
    "returnOrderId": returnOrderId,
    "itemGrpCod": itemGrpCod,
    "itemGrpName": itemGrpName,
    "itemCode": itemCode,
    "itemName": itemName,
    "statusTypeId": statusTypeId,
    "orderQty": orderQty,
    "price": price,
    "remarks": remarks,
    "totalPrice": totalPrice,
    "partialQty": partialQty,
    "fileName": fileName,
    "fileLocation": fileLocation,
    "fileExtension": fileExtension,
  };
}
