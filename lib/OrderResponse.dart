class OrderResponse {
  Response response;

  OrderResponse({
    required this.response,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      response: Response.fromJson(json['response']),
    );
  }
}

class Response {
  List<OrderResult> listResult;
  int count;
  int affectedRecords;
  bool isSuccess;
  String endUserMessage;
  List<dynamic>? links; // Replace with the actual type if needed
  List<dynamic> validationErrors; // Replace with the actual type if needed
  dynamic exception; // Replace with the actual type if needed

  Response({
    required this.listResult,
    required this.count,
    required this.affectedRecords,
    required this.isSuccess,
    required this.endUserMessage,
    required this.links,
    required this.validationErrors,
    required this.exception,
  });

  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
      listResult: List<OrderResult>.from(
          json['listResult'].map((x) => OrderResult.fromJson(x))),
      count: json['count'],
      affectedRecords: json['affectedRecords'],
      isSuccess: json['isSuccess'],
      endUserMessage: json['endUserMessage'],
      links: json['links'] != null ? List<dynamic>.from(json['links']) : null,
      validationErrors: List<dynamic>.from(json['validationErrors']),
      exception: json['exception'],
    );
  }
}

class OrderResult {
  int id;
  int? companyId;
  String?  orderNumber;
  String orderDate;
  String  partyCode;
  String  partyName;
  String partyAddress;
  String? partyState;
  String? partyPhoneNumber;
  String? partyGSTNumber;
  String? proprietorName;
  double? partyOutStandingAmount;
  String bookingPlace;
  String transportName;
  int statusTypeId;
  String? fileName;
  String? fileLocation;
  String? fileExtension;
  String? fileUrl;
  String statusName;
  double? discount;
  double totalCost;
  double? totalCostWithGST;
  int? noOfItems;
  String? remarks;
  bool? isActive;
  String? createdBy;
  DateTime? createdDate;
  String? updatedBy;
  DateTime? updatedDate;

  OrderResult({
    required  this.id,
    required this.companyId,
    required  this.orderNumber,
     required this.orderDate,
    required this.partyCode,
    required this.partyName,
    required  this.partyAddress,
    required  this.partyState,
    required this.partyPhoneNumber,
    required this.partyGSTNumber,
    required this.proprietorName,
    required   this.partyOutStandingAmount,
    required  this.bookingPlace,
    required this.transportName,
    required  this.statusTypeId,
    required this.fileName,
    required this.fileLocation,
    required  this.fileExtension,
    required   this.fileUrl,
    required  this.statusName,
    required  this.discount,
    required  this.totalCost,
    required this.totalCostWithGST,
    required this.noOfItems,
    required this.remarks,
    required this.isActive,
    required this.createdBy,
    required this.createdDate,
    required  this.updatedBy,
    required this.updatedDate,
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
      fileName: json['fileName'],
      fileLocation: json['fileLocation'],
      fileExtension: json['fileExtension'],
      fileUrl: json['fileUrl'],
      statusName: json['statusName'],
      discount: json['discount'],
      totalCost: json['totalCost'],
      totalCostWithGST: json['totalCostWithGST'],
      noOfItems: json['noOfItems'],
      remarks: json['remarks'],
      isActive: json['isActive'],
      createdBy: json['createdBy'],
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'])
          : null,
      updatedBy: json['updatedBy'],
      updatedDate: json['updatedDate'] != null
          ? DateTime.parse(json['updatedDate'])
          : null,
    );
  }
}
