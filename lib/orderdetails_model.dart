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
  final String orderDate;
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
  final String statusName;
  final double discount;
  final double totalCost;
  final double totalCostWithGst;
  final double gstCost;
  final int noOfItems;
  final String? remarks;
  final bool isActive;
  final String createdBy;
  final String createdDate;
  final String updatedBy;
  final String updatedDate;
  final String? shRemarks;
  final String? rejectedRemarks;
  final String? whsCode;
  final String? whsState;
  final String? whsName;

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
    required this.statusName,
    required this.discount,
    required this.totalCost,
    required this.totalCostWithGst,
    required this.gstCost,
    required this.noOfItems,
    required this.remarks,
    required this.isActive,
    required this.createdBy,
    required this.createdDate,
    required this.updatedBy,
    required this.updatedDate,
    required this.shRemarks,
    required this.rejectedRemarks,
    required this.whsCode,
    required this.whsName,
    required this.whsState,
  });

  factory GetOrderDetailsResult.fromJson(Map<String, dynamic> json) =>
      GetOrderDetailsResult(
        id: json["id"],
        companyId: json["companyId"],
        orderNumber: json["orderNumber"],
        orderDate: json["orderDate"],
        partyCode: json["partyCode"],
        partyName: json["partyName"],
        partyAddress: json["partyAddress"],
        partyState: json["partyState"],
        partyPhoneNumber: json["partyPhoneNumber"],
        partyGstNumber: json["partyGSTNumber"],
        proprietorName: json["proprietorName"],
        partyOutStandingAmount: json["partyOutStandingAmount"]?.toDouble(),
        bookingPlace: json["bookingPlace"],
        transportName: json["transportName"],
        statusTypeId: json["statusTypeId"],
        statusName: json["statusName"],
        discount: json["discount"]?.toDouble(),
        totalCost: json["totalCost"]?.toDouble(),
        totalCostWithGst: json["totalCostWithGST"]?.toDouble(),
        gstCost: json["gstCost"]?.toDouble(),
        noOfItems: json["noOfItems"],
        remarks: json["remarks"],
        isActive: json["isActive"],
        createdBy: json["createdBy"],
        createdDate: json["createdDate"],
        updatedBy: json["updatedBy"],
        updatedDate: json["updatedDate"],
        shRemarks: json["shRemarks"],
        rejectedRemarks: json["rejectedRemarks"],
        whsCode: json["whsCode"],
        whsName: json["whsName"],
        whsState: json["whsState"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "companyId": companyId,
    "orderNumber": orderNumber,
    "orderDate": orderDate,
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
    "statusName": statusName,
    "discount": discount,
    "totalCost": totalCost,
    "totalCostWithGST": totalCostWithGst,
    "gstCost": gstCost,
    "noOfItems": noOfItems,
    "remarks": remarks,
    "isActive": isActive,
    "createdBy": createdBy,
    "createdDate": createdDate,
    "updatedBy": updatedBy,
    "updatedDate": updatedDate,
    "shRemarks": shRemarks,
    "rejectedRemarks": rejectedRemarks,
    "whsCode": whsCode,
    "whsName": whsName,
    "whsState": whsState,
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
  final String ugpName;
  final double numInSale;
  final String salUnitMsr;
  final double gst;
  final double totalPrice;
  final double totalPriceWithGst;
  final double gstPrice;
  final String? taxCode;

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
    required this.ugpName,
    required this.numInSale,
    required this.salUnitMsr,
    required this.gst,
    required this.totalPrice,
    required this.totalPriceWithGst,
    required this.gstPrice,
    required this.taxCode,
  });

  factory OrderItemXrefList.fromJson(Map<String, dynamic> json) =>
      OrderItemXrefList(
        id: json["id"],
        orderId: json["orderId"],
        itemGrpCod: json["itemGrpCod"],
        itemGrpName: json["itemGrpName"],
        itemCode: json["itemCode"],
        itemName: json["itemName"],
        noOfPcs: json["noOfPcs"],
        orderQty: json["orderQty"],
        price: json["price"]?.toDouble(),
        ugpName: json["ugpName"],
        numInSale: json["numInSale"]?.toDouble(),
        salUnitMsr: json["salUnitMsr"],
        gst: json["gst"]?.toDouble(),
        totalPrice: json["totalPrice"]?.toDouble(),
        totalPriceWithGst: json["totalPriceWithGST"]?.toDouble(),
        gstPrice: json["gstPrice"]?.toDouble(),
        taxCode: json["taxCode"],
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
    "ugpName": ugpName,
    "numInSale": numInSale,
    "salUnitMsr": salUnitMsr,
    "gst": gst,
    "totalPrice": totalPrice,
    "totalPriceWithGST": totalPriceWithGst,
    "gstPrice": gstPrice,
    "taxCode": taxCode,
  };
}
