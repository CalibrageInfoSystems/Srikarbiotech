class ReturnOrderCredit {
  int id;
  int returnOrderId;
  String creditedDate;
  double creditedAmount;
  String fileName;
  String fileLocation;
  String fileExtension;
  String fileUrl;
  String remarks;
  String createdBy;
  String createdDate;
  String updatedBy;
  String updatedDate;

  ReturnOrderCredit({
    required this.id,
    required this.returnOrderId,
    required this.creditedDate,
    required this.creditedAmount,
    required this.fileName,
    required this.fileLocation,
    required this.fileExtension,
    required this.fileUrl,
    required this.remarks,
    required this.createdBy,
    required this.createdDate,
    required this.updatedBy,
    required this.updatedDate,
  });

  factory ReturnOrderCredit.fromJson(Map<String, dynamic> json) {
    return ReturnOrderCredit(
      id: json['id'],
      returnOrderId: json['returnOrderId'],
      creditedDate: json['creditedDate'],
      creditedAmount: json['creditedAmount'] != null ? json['creditedAmount'].toDouble() : 0.0,
      fileName: json['fileName'],
      fileLocation: json['fileLocation'],
      fileExtension: json['fileExtension'],
      fileUrl: json['fileUrl'],
      remarks: json['remarks'] ?? "", // Remarks can be null, so provide a default value
      createdBy: json['createdBy'],
      createdDate: json['createdDate'],
      updatedBy: json['updatedBy'],
      updatedDate: json['updatedDate'],
    );
  }
}
