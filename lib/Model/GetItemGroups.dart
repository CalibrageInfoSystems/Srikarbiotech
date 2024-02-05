class ItemGroup {
  final String itmsGrpCod;
  final String itmsGrpNam;


  ItemGroup({
    required this.itmsGrpCod,
    required this.itmsGrpNam,

  });

  factory ItemGroup.fromJson(Map<String, dynamic> json) {
    return ItemGroup(
      itmsGrpCod: json['itmsGrpCod'],
      itmsGrpNam: json['itmsGrpNam'],

    );
  }
}

class ApiResponse {
  final List<ItemGroup> listResult;
  final int count;
  final int affectedRecords;
  final bool isSuccess;
  final String? endUserMessage;
  final dynamic links;
  final List<dynamic>? validationErrors;
  final dynamic exception;

  ApiResponse({
    required this.listResult,
    required this.count,
    required this.affectedRecords,
    required this.isSuccess,
    this.endUserMessage,
    this.links,
    this.validationErrors,
    this.exception,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      listResult: (json['response']['listResult'] as List)
          .map((item) => ItemGroup.fromJson(item))
          .toList(),
      count: json['response']['count'],
      affectedRecords: json['response']['affectedRecords'],
      isSuccess: json['isSuccess'],
      endUserMessage: json['endUserMessage'],
      links: json['links'],
      validationErrors: json['validationErrors'],
      exception: json['exception'],
    );
  }
}
