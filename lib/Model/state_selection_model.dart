import 'dart:convert';

StateSelectionModel stateSelectionModelFromJson(String str) =>
    StateSelectionModel.fromJson(json.decode(str));

String stateSelectionModelToJson(StateSelectionModel data) =>
    json.encode(data.toJson());

class StateSelectionModel {
  Response response;
  bool isSuccess;
  dynamic endUserMessage;
  dynamic links;
  List<dynamic> validationErrors;
  dynamic exception;

  StateSelectionModel({
    required this.response,
    required this.isSuccess,
    required this.endUserMessage,
    required this.links,
    required this.validationErrors,
    required this.exception,
  });

  factory StateSelectionModel.fromJson(Map<String, dynamic> json) =>
      StateSelectionModel(
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
  List<StateListResult> stateListResult;
  int count;
  int affectedRecords;

  Response({
    required this.stateListResult,
    required this.count,
    required this.affectedRecords,
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        stateListResult: List<StateListResult>.from(
            json["stateListResult"].map((x) => StateListResult.fromJson(x))),
        count: json["count"],
        affectedRecords: json["affectedRecords"],
      );

  Map<String, dynamic> toJson() => {
        "stateListResult":
            List<dynamic>.from(stateListResult.map((x) => x.toJson())),
        "count": count,
        "affectedRecords": affectedRecords,
      };
}

class StateListResult {
  String? state;
  double? ob;
  double? sales;
  double? returns;
  double? receipts;
  double? others;
  double? closing;

  StateListResult({
    required this.state,
    required this.ob,
    required this.sales,
    required this.returns,
    required this.receipts,
    required this.others,
    required this.closing,
  });

  factory StateListResult.fromJson(Map<String, dynamic> json) =>
      StateListResult(
        state: json["state"],
        ob: json["ob"]?.toDouble(),
        sales: json["sales"]?.toDouble(),
        returns: json["returns"]?.toDouble(),
        receipts: json["receipts"]?.toDouble(),
        others: json["others"]?.toDouble(),
        closing: json["closing"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "state": state,
        "ob": ob,
        "sales": sales,
        "returns": returns,
        "receipts": receipts,
        "others": others,
        "closing": closing,
      };
}
