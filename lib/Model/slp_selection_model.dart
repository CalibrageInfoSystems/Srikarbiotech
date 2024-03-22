import 'dart:convert';

SlpSelectionModel slpSelectionModelFromJson(String str) =>
    SlpSelectionModel.fromJson(json.decode(str));

String slpSelectionModelToJson(SlpSelectionModel data) =>
    json.encode(data.toJson());

class SlpSelectionModel {
  Response response;
  bool isSuccess;
  dynamic endUserMessage;
  dynamic links;
  List<dynamic> validationErrors;
  dynamic exception;

  SlpSelectionModel({
    required this.response,
    required this.isSuccess,
    required this.endUserMessage,
    required this.links,
    required this.validationErrors,
    required this.exception,
  });

  factory SlpSelectionModel.fromJson(Map<String, dynamic> json) =>
      SlpSelectionModel(
        response: Response.fromJson(json["response"]),
        isSuccess: json["isSuccess"],
        endUserMessage: json["endUserMessage"],
        links: json["links"],
        validationErrors:
            List<dynamic>.from(json["validationErrors"].map((x) => x)),
        exception: json["exception"],
      );

  Map<String, dynamic> toJson() => {
        "response": response.toJson(),
        "isSuccess": isSuccess,
        "endUserMessage": endUserMessage,
        "links": links,
        "validationErrors": List<dynamic>.from(validationErrors.map((x) => x)),
        "exception": exception,
      };
}

class Response {
  List<SlpListResult> slpListResult;
  int count;
  int affectedRecords;

  Response({
    required this.slpListResult,
    required this.count,
    required this.affectedRecords,
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        slpListResult: List<SlpListResult>.from(
            json["slpListResult"].map((x) => SlpListResult.fromJson(x))),
        count: json["count"],
        affectedRecords: json["affectedRecords"],
      );

  Map<String, dynamic> toJson() => {
        "slpListResult":
            List<dynamic>.from(slpListResult.map((x) => x.toJson())),
        "count": count,
        "affectedRecords": affectedRecords,
      };
}

class SlpListResult {
  int? slpCode;
  String? slpName;
  String? state;
  double? ob;
  double? sales;
  double? returns;
  double? receipts;
  double? others;
  double? closing;

  SlpListResult({
    required this.slpCode,
    required this.slpName,
    required this.state,
    required this.ob,
    required this.sales,
    required this.returns,
    required this.receipts,
    required this.others,
    required this.closing,
  });

  factory SlpListResult.fromJson(Map<String, dynamic> json) => SlpListResult(
        slpCode: json["slpCode"],
        slpName: json["slpName"],
        state: json["state"],
        ob: json["ob"]?.toDouble(),
        sales: json["sales"]?.toDouble(),
        returns: json["returns"]?.toDouble(),
        receipts: json["receipts"]?.toDouble(),
        others: json["others"]?.toDouble(),
        closing: json["closing"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "slpCode": slpCode,
        "slpName": slpName,
        "state": state,
        "ob": ob,
        "sales": sales,
        "returns": returns,
        "receipts": receipts,
        "others": others,
        "closing": closing,
      };
}
