class CompanyModel {
  final int companyId;
  final String companyName;
  final String companyAddress;
  final bool isActive;
  final String createdDate;
  final String updatedDate;
  final String fileUrl;

  CompanyModel({
    required this.companyId,
    required this.companyName,
    required this.companyAddress,
    required this.isActive,
    required this.createdDate,
    required this.updatedDate,
    required this.fileUrl,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      companyId: json['companyId'],
      companyName: json['companyName'],
      companyAddress: json['companyAddress'],
      isActive: json['isActive'],
      createdDate: json['createdDate'],
      updatedDate: json['updatedDate'],
      fileUrl: json['fileUrl'],
    );
  }
}
