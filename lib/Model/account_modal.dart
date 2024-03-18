import 'dart:convert';

AccountModal accountModalFromJson(String str) =>
    AccountModal.fromJson(json.decode(str));

String accountModalToJson(AccountModal data) => json.encode(data.toJson());

class AccountModal {
  final Response response;
  final bool isSuccess;
  final dynamic endUserMessage;
  final dynamic links;
  final List<dynamic> validationErrors;
  final dynamic exception;

  AccountModal({
    required this.response,
    required this.isSuccess,
    required this.endUserMessage,
    required this.links,
    required this.validationErrors,
    required this.exception,
  });

  factory AccountModal.fromJson(Map<String, dynamic> json) => AccountModal(
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
  final List<AccountList> accountList;
  final int count;
  final int affectedRecords;

  Response({
    required this.accountList,
    required this.count,
    required this.affectedRecords,
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        accountList: List<AccountList>.from(
            json["accountList"].map((x) => AccountList.fromJson(x))),
        count: json["count"],
        affectedRecords: json["affectedRecords"],
      );

  Map<String, dynamic> toJson() => {
        "accountList": List<dynamic>.from(accountList.map((x) => x.toJson())),
        "count": count,
        "affectedRecords": affectedRecords,
      };
}

class AccountList {
  final String bankCode;
  final String account;
  final String branch;
  final String swiftNum;

  AccountList({
    required this.bankCode,
    required this.account,
    required this.branch,
    required this.swiftNum,
  });

  factory AccountList.fromJson(Map<String, dynamic> json) => AccountList(
        bankCode: json["bankCode"],
        account: json["account"],
        branch: json["branch"],
        swiftNum: json["swiftNum"],
      );

  Map<String, dynamic> toJson() => {
        "bankCode": bankCode,
        "account": account,
        "branch": branch,
        "swiftNum": swiftNum,
      };
}
