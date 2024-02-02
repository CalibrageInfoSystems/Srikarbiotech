import 'dart:convert';

OrderDetailsModel orderDetailsModelFromJson(String str) =>
    OrderDetailsModel.fromJson(json.decode(str));

String orderDetailsModelToJson(OrderDetailsModel data) =>
    json.encode(data.toJson());

class OrderDetailsModel {
  final Response response;
  final bool isSuccess;
  final int affectedRecords;
  final String endUserMessage;
  final dynamic links;
  final List<dynamic> validationErrors;
  final dynamic exception;

  OrderDetailsModel({
    required this.response,
    required this.isSuccess,
    required this.affectedRecords,
    required this.endUserMessage,
    required this.links,
    required this.validationErrors,
    required this.exception,
  });

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) =>
      OrderDetailsModel(
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
  final List<GetOrderDetailsResult> getOrderDetailsResult;
  final List<OrderItemXrefList> orderItemXrefList;

  Response({
    required this.getOrderDetailsResult,
    required this.orderItemXrefList,
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        getOrderDetailsResult: List<GetOrderDetailsResult>.from(
            json["getOrderDetailsResult"]
                .map((x) => GetOrderDetailsResult.fromJson(x))),
        orderItemXrefList: List<OrderItemXrefList>.from(
            json["orderItemXrefList"]
                .map((x) => OrderItemXrefList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "getOrderDetailsResult":
            List<dynamic>.from(getOrderDetailsResult.map((x) => x.toJson())),
        "orderItemXrefList":
            List<dynamic>.from(orderItemXrefList.map((x) => x.toJson())),
      };
}
class GetOrderDetailsResult {
  final int id;
  final int companyId;
  final String orderNumber;
  final DateTime orderDate;
  final String partyCode;
  final String partyName;
  final String partyAddress;
  final String partyState;
  final String partyPhoneNumber;
  final String partyGstNumber;
  final String proprietorName;
  final double partyOutStandingAmount;
  final String bookingPlace;
  final String transportName;
  final int statusTypeId;
  final String fileName;
  final String fileLocation;
  final String fileExtension;
  final dynamic fileUrl;
  final String statusName;
  final double discount;
  final double igst;
  final double cgst;
  final double sgst;
  final double totalCost;
  final int noOfItems;
  final String remarks;
  final bool isActive;
  final String createdBy;
  final DateTime createdDate;
  final String updatedBy;
  final DateTime updatedDate;

  GetOrderDetailsResult({
    required this.id,
    required this.companyId,
    required this.orderNumber,
    required this.orderDate,
    required this.partyCode,
    required this.partyName,
    required this.partyAddress,
    required this.partyState,
    required this.partyPhoneNumber,
    required this.partyGstNumber,
    required this.proprietorName,
    required this.partyOutStandingAmount,
    required this.bookingPlace,
    required this.transportName,
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
    required this.remarks,
    required this.isActive,
    required this.createdBy,
    required this.createdDate,
    required this.updatedBy,
    required this.updatedDate,
  });

  factory GetOrderDetailsResult.fromJson(Map<String, dynamic> json) =>
      GetOrderDetailsResult(
        id: json["id"] ?? 0,
        companyId: json["companyId"] ?? 0,
        orderNumber: json["orderNumber"] ?? "",
        orderDate: json["orderDate"] != null ? DateTime.parse(json["orderDate"]) : DateTime.now(),
        partyCode: json["partyCode"] ?? "",
        partyName: json["partyName"] ?? "",
        partyAddress: json["partyAddress"] ?? "",
        partyState: json["partyState"] ?? "",
        partyPhoneNumber: json["partyPhoneNumber"] ?? "",
        partyGstNumber: json["partyGSTNumber"] ?? "",
        proprietorName: json["proprietorName"] ?? "",
        partyOutStandingAmount: json["partyOutStandingAmount"]?.toDouble() ?? 0.0,
        bookingPlace: json["bookingPlace"] ?? "",
        transportName: json["transportName"] ?? "",
        statusTypeId: json["statusTypeId"] ?? 0,
        fileName: json["fileName"] ?? "",
        fileLocation: json["fileLocation"] ?? "",
        fileExtension: json["fileExtension"] ?? "",
        fileUrl: json["fileUrl"],
        statusName: json["statusName"] ?? "",
        discount: json["discount"]?.toDouble() ?? 0.0,
        igst: json["igst"]?.toDouble() ?? 0.0,
        cgst: json["cgst"]?.toDouble() ?? 0.0,
        sgst: json["sgst"]?.toDouble() ?? 0.0,
        totalCost: json["totalCost"]?.toDouble() ?? 0.0,
        noOfItems: json["noOfItems"] ?? 0,
        remarks: json["remarks"] ?? "",
        isActive: json["isActive"] ?? false,
        createdBy: json["createdBy"] ?? "",
        createdDate: json["createdDate"] != null ? DateTime.parse(json["createdDate"]) : DateTime.now(),
        updatedBy: json["updatedBy"] ?? "",
        updatedDate: json["updatedDate"] != null ? DateTime.parse(json["updatedDate"]) : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "companyId": companyId,
    "orderNumber": orderNumber,
    "orderDate": orderDate.toIso8601String(),
    "partyCode": partyCode,
    "partyName": partyName,
    "partyAddress": partyAddress,
    "partyState": partyState,
    "partyPhoneNumber": partyPhoneNumber,
    "partyGSTNumber": partyGstNumber,
    "proprietorName": proprietorName,
    "partyOutStandingAmount": partyOutStandingAmount,
    "bookingPlace": bookingPlace,
    "transportName": transportName,
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
    "remarks": remarks,
    "isActive": isActive,
    "createdBy": createdBy,
    "createdDate": createdDate.toIso8601String(),
    "updatedBy": updatedBy,
    "updatedDate": updatedDate.toIso8601String(),
  };
}

class OrderItemXrefList {
  final int id;
  final int orderId;
  final String itemGrpCod;
  final String itemGrpName;
  final String itemCode;
  final String itemName;
  final String noOfPcs;
  final int orderQty;
  final double price;
  final double igst;
  final double cgst;
  final double sgst;

  OrderItemXrefList({
    required this.id,
    required this.orderId,
    required this.itemGrpCod,
    required this.itemGrpName,
    required this.itemCode,
    required this.itemName,
    required this.noOfPcs,
    required this.orderQty,
    required this.price,
    required this.igst,
    required this.cgst,
    required this.sgst,
  });

  factory OrderItemXrefList.fromJson(Map<String, dynamic> json) =>
      OrderItemXrefList(
        id: json["id"] ?? 0,
        orderId: json["orderId"] ?? 0,
        itemGrpCod: json["itemGrpCod"] ?? "",
        itemGrpName: json["itemGrpName"] ?? "",
        itemCode: json["itemCode"] ?? "",
        itemName: json["itemName"] ?? "",
        noOfPcs: json["noOfPcs"] ?? "",
        orderQty: json["orderQty"] ?? 0,
        price: json["price"]?.toDouble() ?? 0.0,
        igst: json["igst"]?.toDouble() ?? 0.0,
        cgst: json["cgst"]?.toDouble() ?? 0.0,
        sgst: json["sgst"]?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "orderId": orderId,
    "itemGrpCod": itemGrpCod,
    "itemGrpName": itemGrpName,
    "itemCode": itemCode,
    "itemName": itemName,
    "noOfPcs": noOfPcs,
    "orderQty": orderQty,
    "price": price,
    "igst": igst,
    "cgst": cgst,
    "sgst": sgst,
  };
}
