// class OrderResponse {
//   Response response;

//   OrderResponse({
//     required this.response,
//   });

//   factory OrderResponse.fromJson(Map<String, dynamic> json) {
//     return OrderResponse(
//       response: Response.fromJson(json['response']),
//     );
//   }
// }

// class Response {
//   List<OrderResult> listResult;
//   int count;
//   int affectedRecords;
//   bool isSuccess;
//   String endUserMessage;
//   List<dynamic>? links; // Replace with the actual type if needed
//   List<dynamic> validationErrors; // Replace with the actual type if needed
//   dynamic exception; // Replace with the actual type if needed

//   Response({
//     required this.listResult,
//     required this.count,
//     required this.affectedRecords,
//     required this.isSuccess,
//     required this.endUserMessage,
//     required this.links,
//     required this.validationErrors,
//     required this.exception,
//   });

//   factory Response.fromJson(Map<String, dynamic> json) {
//     return Response(
//       listResult: List<OrderResult>.from(
//           json['listResult'].map((x) => OrderResult.fromJson(x))),
//       count: json['count'],
//       affectedRecords: json['affectedRecords'],
//       isSuccess: json['isSuccess'],
//       endUserMessage: json['endUserMessage'],
//       links: json['links'] != null ? List<dynamic>.from(json['links']) : null,
//       validationErrors: List<dynamic>.from(json['validationErrors']),
//       exception: json['exception'],
//     );
//   }
// }

// class OrderResult {
//   int id;
//   int? companyId;
//   String?  orderNumber;
//   String orderDate;
//   String  partyCode;
//   String  partyName;
//   String partyAddress;
//   String? partyState;
//   String? partyPhoneNumber;
//   String? partyGSTNumber;
//   String? proprietorName;
//   double? partyOutStandingAmount;
//   String bookingPlace;
//   String transportName;
//   int statusTypeId;
//   String? fileName;
//   String? fileLocation;
//   String? fileExtension;
//   String? fileUrl;
//   String statusName;
//   double? discount;
//   double totalCost;
//   double? totalCostWithGST;
//   int? noOfItems;
//   String? remarks;
//   bool? isActive;
//   String? createdBy;
//   DateTime? createdDate;
//   String? updatedBy;
//   DateTime? updatedDate;

//   OrderResult({
//     required  this.id,
//     required this.companyId,
//     required  this.orderNumber,
//      required this.orderDate,
//     required this.partyCode,
//     required this.partyName,
//     required  this.partyAddress,
//     required  this.partyState,
//     required this.partyPhoneNumber,
//     required this.partyGSTNumber,
//     required this.proprietorName,
//     required   this.partyOutStandingAmount,
//     required  this.bookingPlace,
//     required this.transportName,
//     required  this.statusTypeId,
//     required this.fileName,
//     required this.fileLocation,
//     required  this.fileExtension,
//     required   this.fileUrl,
//     required  this.statusName,
//     required  this.discount,
//     required  this.totalCost,
//     required this.totalCostWithGST,
//     required this.noOfItems,
//     required this.remarks,
//     required this.isActive,
//     required this.createdBy,
//     required this.createdDate,
//     required  this.updatedBy,
//     required this.updatedDate,
//   });

//   factory OrderResult.fromJson(Map<String, dynamic> json) {
//     return OrderResult(
//       id: json['id'],
//       companyId: json['companyId'],
//       orderNumber: json['orderNumber'],
//       orderDate: json['orderDate'],

//       partyCode: json['partyCode'],
//       partyName: json['partyName'],
//       partyAddress: json['partyAddress'],
//       partyState: json['partyState'],
//       partyPhoneNumber: json['partyPhoneNumber'],
//       partyGSTNumber: json['partyGSTNumber'],
//       proprietorName: json['proprietorName'],
//       partyOutStandingAmount: json['partyOutStandingAmount'],
//       bookingPlace: json['bookingPlace'],
//       transportName: json['transportName'],
//       statusTypeId: json['statusTypeId'],
//       fileName: json['fileName'],
//       fileLocation: json['fileLocation'],
//       fileExtension: json['fileExtension'],
//       fileUrl: json['fileUrl'],
//       statusName: json['statusName'],
//       discount: json['discount'],
//       totalCost: json['totalCost'],
//       totalCostWithGST: json['totalCostWithGST'],
//       noOfItems: json['noOfItems'],
//       remarks: json['remarks'],
//       isActive: json['isActive'],
//       createdBy: json['createdBy'],
//       createdDate: json['createdDate'] != null
//           ? DateTime.parse(json['createdDate'])
//           : null,
//       updatedBy: json['updatedBy'],
//       updatedDate: json['updatedDate'] != null
//           ? DateTime.parse(json['updatedDate'])
//           : null,
//     );
//   }
// }

class OrderResponse {
  final ResponseData response;
  final bool isSuccess;
  final String endUserMessage;
  final List<dynamic>? links;
  final List<dynamic> validationErrors;
  final dynamic exception;

  OrderResponse({
    required this.response,
    required this.isSuccess,
    required this.endUserMessage,
    this.links,
    required this.validationErrors,
    this.exception,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      response: ResponseData.fromJson(json['response']),
      isSuccess: json['isSuccess'],
      endUserMessage: json['endUserMessage'],
      links: json['links'],
      validationErrors: json['validationErrors'],
      exception: json['exception'],
    );
  }
}

class ResponseData {
  final List<OrderResult> orderResults;
  final int count;
  final int affectedRecords;

  ResponseData({
    required this.orderResults,
    required this.count,
    required this.affectedRecords,
  });

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    List<OrderResult> orderResults = (json['OrderResult'] as List<dynamic>)
        .map((orderResultJson) => OrderResult.fromJson(orderResultJson))
        .toList();

    return ResponseData(
      orderResults: orderResults,
      count: json['count'],
      affectedRecords: json['affectedRecords'],
    );
  }
}

class OrderResult {
  final int id;
  final int companyId;
  final String orderNumber;
  final String orderDate;
  final String partyCode;
  final String partyName;
  final String partyAddress;
  final String partyState;
  final String partyPhoneNumber;
  final String partyGSTNumber;
  final String proprietorName;
  final double partyOutStandingAmount;
  final String bookingPlace;
  final String transportName;
  final int statusTypeId;
  final String statusName;
  final double discount;
  final double totalCost;
  final double totalCostWithGST;
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
  final String? whsName;
  final String? whsState;

  OrderResult({
    required this.id,
    required this.companyId,
    required this.orderNumber,
    required this.orderDate,
    required this.partyCode,
    required this.partyName,
    required this.partyAddress,
    required this.partyState,
    required this.partyPhoneNumber,
    required this.partyGSTNumber,
    required this.proprietorName,
    required this.partyOutStandingAmount,
    required this.bookingPlace,
    required this.transportName,
    required this.statusTypeId,
    required this.statusName,
    required this.discount,
    required this.totalCost,
    required this.totalCostWithGST,
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
    this.whsCode,
    this.whsName,
    this.whsState,
  });

  factory OrderResult.fromJson(Map<String, dynamic> json) {
    return OrderResult(
      id: json['id'],
      companyId: json['companyId'],
      orderNumber: json['orderNumber'],
      orderDate: json['orderDate'],
      partyCode: json['partyCode'],
      partyName: json['partyName'],
      partyAddress: json['partyAddress'],
      partyState: json['partyState'],
      partyPhoneNumber: json['partyPhoneNumber'],
      partyGSTNumber: json['partyGSTNumber'],
      proprietorName: json['proprietorName'],
      partyOutStandingAmount: json['partyOutStandingAmount'],
      bookingPlace: json['bookingPlace'],
      transportName: json['transportName'],
      statusTypeId: json['statusTypeId'],
      statusName: json['statusName'],
      discount: json['discount'],
      totalCost: json['totalCost'],
      totalCostWithGST: json['totalCostWithGST'] ?? 0.0,
      gstCost: json['gstCost'],
      noOfItems: json['noOfItems'],
      remarks: json['remarks'],
      isActive: json['isActive'],
      createdBy: json['createdBy'],
      createdDate: json['createdDate'],
      updatedBy: json['updatedBy'],
      updatedDate: json['updatedDate'],
      shRemarks: json['shRemarks'],
      rejectedRemarks: json['rejectedRemarks'],
      whsCode: json['whsCode'],
      whsName: json['whsName'],
      whsState: json['whsState'],
    );
  }
}
