import 'dart:convert';

DealerSummaryModel dealerSummaryModelFromJson(String str) => DealerSummaryModel.fromJson(json.decode(str));

String dealerSummaryModelToJson(DealerSummaryModel data) => json.encode(data.toJson());

class DealerSummaryModel {
  Response response;
  bool isSuccess;
  dynamic endUserMessage;
  dynamic links;
  List<dynamic> validationErrors;
  dynamic exception;

  DealerSummaryModel({
    required this.response,
    required this.isSuccess,
    required this.endUserMessage,
    required this.links,
    required this.validationErrors,
    required this.exception,
  });

  factory DealerSummaryModel.fromJson(Map<String, dynamic> json) => DealerSummaryModel(
        response: Response.fromJson(json["response"]),
        isSuccess: json["isSuccess"],
        endUserMessage: json["endUserMessage"],
        links: json["links"],
        validationErrors: List<dynamic>.from(json["validationErrors"].map((x) => x)),
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
  List<DealerSummarylist> dealerSummarylist;
  int count;
  int affectedRecords;

  Response({
    required this.dealerSummarylist,
    required this.count,
    required this.affectedRecords,
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        dealerSummarylist: List<DealerSummarylist>.from(json["dealerSummarylist"].map((x) => DealerSummarylist.fromJson(x))),
        count: json["count"],
        affectedRecords: json["affectedRecords"],
      );

  Map<String, dynamic> toJson() => {
        "dealerSummarylist": List<dynamic>.from(dealerSummarylist.map((x) => x.toJson())),
        "count": count,
        "affectedRecords": affectedRecords,
      };
}

class DealerSummarylist {
  String? cardCode;
  String? cardName;
  int? slpCode;
  String? slpName;
  double? ob;
  double? sales;
  double? returns;
  double? receipts;
  double? others;
  double? closing;

  DealerSummarylist({
    required this.cardCode,
    required this.cardName,
    required this.slpCode,
    required this.slpName,
    required this.ob,
    required this.sales,
    required this.returns,
    required this.receipts,
    required this.others,
    required this.closing,
  });

  factory DealerSummarylist.fromJson(Map<String, dynamic> json) => DealerSummarylist(
        cardCode: json["cardCode"],
        cardName: json["cardName"],
        slpCode: json["slpCode"],
        slpName: json["slpName"],
        ob: json["ob"],
        sales: json["sales"],
        returns: json["returns"],
        receipts: json["receipts"],
        others: json["others"],
        closing: json["closing"],
      );

  Map<String, dynamic> toJson() => {
        "cardCode": cardCode,
        "cardName": cardName,
        "slpCode": slpCode,
        "slpName": slpName,
        "ob": ob,
        "sales": sales,
        "returns": returns,
        "receipts": receipts,
        "others": others,
        "closing": closing,
      };
}
