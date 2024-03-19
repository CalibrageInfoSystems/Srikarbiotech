class ResponseModel {
  ResponseData response;
  bool isSuccess;
  String endUserMessage;
  dynamic links;
  List<dynamic> validationErrors;
  dynamic exception;

  ResponseModel({
    required this.response,
    required this.isSuccess,
    required this.endUserMessage,
    required this.links,
    required this.validationErrors,
    required this.exception,
  });

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
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
  List<ListResult> listResult;
  int count;
  int affectedRecords;

  ResponseData({
    required this.listResult,
    required this.count,
    required this.affectedRecords,
  });

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      listResult: List<ListResult>.from(
          json['listResult'].map((x) => ListResult.fromJson(x))),
      count: json['count'],
      affectedRecords: json['affectedRecords'],
    );
  }
}

class ListResult {
  int id;
  String date;
  String collectionNumber;
  String partyCode;
  String partyName;
  String stateName;
  int slpCode;
  String salesPersonName;
  String partyGSTNumber;
  String proprietorName;
  String address;
  String phoneNumber;
  double amount;
  int paymentType;
  String paymentTypeName;
  String purposeValue;
  String purposeDesc;
  String purposeName;
  int category;
  String categoryName;
  String checkNumber;
  String checkDate;
  String checkIssuedBank;
  // String creditAccountNo;
  // String creditBank;
  String utrNumber;
  String fileName;
  String fileLocation;
  String fileExtension;
  String fileUrl;
  String remarks;
  int companyId;
  String companyName;
  int statusTypeId;
  String statusName;
  bool isActive;
  String createdBy;
  String createdDate;
  String updatedBy;
  String updatedDate;
  String virtualBankCode;
  String otherAccountNo;
  String otherBankName;
  String otherBankCode;

  ListResult({
    required this.id,
    required this.date,
    required this.collectionNumber,
    required this.partyCode,
    required this.partyName,
    required this.stateName,
    required this.slpCode,
    required this.salesPersonName,
    required this.partyGSTNumber,
    required this.proprietorName,
    required this.address,
    required this.phoneNumber,
    required this.amount,
    required this.paymentType,
    required this.paymentTypeName,
    required this.purposeValue,
    required this.purposeDesc,
    required this.purposeName,
    required this.category,
    required this.categoryName,
    required this.checkNumber,
    required this.checkDate,
    required this.checkIssuedBank,
    // required this.creditAccountNo,
    // required this.creditBank,
    required this.utrNumber,
    required this.fileName,
    required this.fileLocation,
    required this.fileExtension,
    required this.fileUrl,
    required this.remarks,
    required this.companyId,
    required this.companyName,
    required this.statusTypeId,
    required this.statusName,
    required this.isActive,
    required this.createdBy,
    required this.createdDate,
    required this.updatedBy,
    required this.updatedDate,
    required this.virtualBankCode,
    required this.otherAccountNo,
    required this.otherBankName,
    required this.otherBankCode,
  });

  factory ListResult.fromJson(Map<String, dynamic> json) {
    return ListResult(
      id: json['id'] ?? 0, // Provide a default value for id
      date: json['date'] ?? "",
      collectionNumber: json['collectionNumber'] ?? "",
      partyCode: json['partyCode'] ?? "",
      partyName: json['partyName'] ?? "",
      stateName: json['stateName'] ?? "",
      slpCode: json['slpCode'] ?? 0, // Provide a default value for slpCode
      salesPersonName: json['salesPersonName'] ?? "",
      partyGSTNumber: json['partyGSTNumber'] ?? "",
      proprietorName: json['proprietorName'] ?? "",
      address: json['address'] ?? "",
      phoneNumber: json['phoneNumber'] ?? "",
      amount: json['amount']?.toDouble() ?? 0.0,
      paymentType: json['paymentType'] ?? 0, // Provide a default value for paymentType
      paymentTypeName: json['paymentTypeName'] ?? "",
      purposeValue: json['purposeValue'] ?? "",
      purposeDesc: json['purposeDesc'] ?? "",
      purposeName: json['purposeName'] ?? "",
      category: json['category'] ?? 0, // Provide a default value for category
      categoryName: json['categoryName'] ?? "",
      checkNumber: json['checkNumber'] ?? "",
      checkDate: json['checkDate'] ?? "",
      checkIssuedBank: json['checkIssuedBank'] ?? "",
      // creditAccountNo: json['creditAccountNo'] ?? "",
      // creditBank: json['creditBank'] ?? "",
      utrNumber: json['utrNumber'] ?? "",
      fileName: json['fileName'] ?? "",
      fileLocation: json['fileLocation'] ?? "",
      fileExtension: json['fileExtension'] ?? "",
      fileUrl: json['fileUrl'] ?? "",
      remarks: json['remarks'] ?? "",
      companyId: json['companyId'] ?? 0, // Provide a default value for companyId
      companyName: json['companyName'] ?? "",
      statusTypeId: json['statusTypeId'] ?? 0, // Provide a default value for statusTypeId
      statusName: json['statusName'] ?? "",
      isActive: json['isActive'] ?? false,
      createdBy: json['createdBy'] ?? "",
      createdDate: json['createdDate'] ?? "",
      updatedBy: json['updatedBy'] ?? "",
      updatedDate: json['updatedDate'] ?? "",
      virtualBankCode: json['virtualBankCode'] ?? "",
      otherAccountNo: json['otherAccountNo'] ?? "",
      otherBankName: json['otherBankName'] ?? "",
      otherBankCode: json['otherBankCode'] ?? "",
    );
  }

}

