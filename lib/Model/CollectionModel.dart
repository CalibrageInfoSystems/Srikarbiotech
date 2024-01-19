class CollectionModel {
  int id;
  String date;
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
  String creditAccountNo;
  String creditBank;
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

  CollectionModel({
    required this.id,
    required this.date,
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
    required this.creditAccountNo,
    required this.creditBank,
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
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: json['id'],
      date: json['date'],
      partyCode: json['partyCode'],
      partyName: json['partyName'],
      stateName: json['stateName'],
      slpCode: json['slpCode'],
      salesPersonName: json['salesPersonName'],
      partyGSTNumber: json['partyGSTNumber'],
      proprietorName: json['proprietorName'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      amount: json['amount']?.toDouble() ?? 0.0,
      paymentType: json['paymentType'],
      paymentTypeName: json['paymentTypeName'],
      purposeValue: json['purposeValue'],
      purposeDesc: json['purposeDesc'],
      purposeName: json['purposeName'],
      category: json['category'],
      categoryName: json['categoryName'],
      checkNumber: json['checkNumber'],
      checkDate: json['checkDate'],
      checkIssuedBank: json['checkIssuedBank'],
      creditAccountNo: json['creditAccountNo'],
      creditBank: json['creditBank'],
      utrNumber: json['utrNumber'],
      fileName: json['fileName'],
      fileLocation: json['fileLocation'],
      fileExtension: json['fileExtension'],
      fileUrl: json['fileUrl'],
      remarks: json['remarks'],
      companyId: json['companyId'],
      companyName: json['companyName'],
      statusTypeId: json['statusTypeId'],
      statusName: json['statusName'],
      isActive: json['isActive'],
      createdBy: json['createdBy'],
      createdDate: json['createdDate'],
      updatedBy: json['updatedBy'],
      updatedDate: json['updatedDate'],
    );
  }
}