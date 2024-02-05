class PaymentMode {
  final int? typeCdId;
  final int? classTypeId; // Make it nullable by adding '?'
  final String name;
  final String desc;
  final String tableName;
  final String columnName;
  final int sortOrder;
  final bool isActive;

  PaymentMode({
    required this.typeCdId,
    required this.classTypeId,
    required this.name,
    required this.desc,
    required this.tableName,
    required this.columnName,
    required this.sortOrder,
    required this.isActive,
  });



factory PaymentMode.fromJson(Map<String, dynamic> json) {
    return PaymentMode(
      typeCdId: json['typeCdId'],
      classTypeId: json['classTypeId'],
      name: json['name'],
      desc: json['desc'],
      tableName: json['tableName'],
      columnName: json['columnName'],
      sortOrder: json['sortOrder'],
      isActive: json['isActive'],
    );
  }
}

class ApiResponse {
  final List<PaymentMode> listResult;
  final Map<String, dynamic> response;

  final int count;
  final int affectedRecords;
  final bool isSuccess;
  final String endUserMessage;

  ApiResponse({
    required this.listResult,
    required this.response,
    required this.count,
    required this.affectedRecords,
    required this.isSuccess,
    required this.endUserMessage,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      listResult: (json['response']['listResult'] as List)
          .map((data) => PaymentMode.fromJson(data))
          .toList(),
      response: json['response'],
      count: json['response']['count'],
      affectedRecords: json['response']['affectedRecords'],
      isSuccess: json['isSuccess'],
      endUserMessage: json['endUserMessage'],
    );
  }
}
