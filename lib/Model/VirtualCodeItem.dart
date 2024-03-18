class VirtualcodeApiResponse {
  final ResponseData response;
  final bool isSuccess;
  final String? endUserMessage;
  final List<dynamic> links; // Adjust the type as needed
  final List<dynamic> validationErrors; // Adjust the type as needed
  final dynamic exception; // Adjust the type as needed

  VirtualcodeApiResponse({
    required this.response,
    required this.isSuccess,
    this.endUserMessage,
    required this.links,
    required this.validationErrors,
    this.exception,
  });

  factory VirtualcodeApiResponse.fromJson(Map<String, dynamic> json) {
    return VirtualcodeApiResponse(
      response: ResponseData.fromJson(json['response']),
      isSuccess: json['isSuccess'],
      endUserMessage: json['endUserMessage'],
      links: json['links'] ?? [], // Adjust the default value as needed
      validationErrors: json['validationErrors'] ?? [], // Adjust the default value as needed
      exception: json['exception'], // Adjust the type as needed
    );
  }
}

class ResponseData {
  final List<VirtualCodeItem> listResult;
  final int count;
  final int affectedRecords;

  ResponseData({
    required this.listResult,
    required this.count,
    required this.affectedRecords,
  });

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    var list = json['listResult'] as List;
    List<VirtualCodeItem> virtualCodesList = list.map((item) => VirtualCodeItem.fromJson(item)).toList();

    return ResponseData(
      listResult: virtualCodesList,
      count: json['count'],
      affectedRecords: json['affectedRecords'],
    );
  }
}

class VirtualCodeItem {
  final String virtualCode;

  VirtualCodeItem({required this.virtualCode});

  factory VirtualCodeItem.fromJson(Map<String, dynamic> json) {
    return VirtualCodeItem(
      virtualCode: json['virtualCode'],
    );
  }
}
