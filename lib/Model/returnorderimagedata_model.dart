
import 'package:meta/meta.dart';
import 'dart:convert';

ReturnOrderImagesModel returnOrderImagesModelFromJson(String str) => ReturnOrderImagesModel.fromJson(json.decode(str));

String returnOrderImagesModelToJson(ReturnOrderImagesModel data) => json.encode(data.toJson());

class ReturnOrderImagesModel {
    final Response response;
    final bool isSuccess;
    final String endUserMessage;
    final dynamic links;
    final List<dynamic> validationErrors;
    final dynamic exception;

    ReturnOrderImagesModel({
        required this.response,
        required this.isSuccess,
        required this.endUserMessage,
        required this.links,
        required this.validationErrors,
        required this.exception,
    });

    factory ReturnOrderImagesModel.fromJson(Map<String, dynamic> json) => ReturnOrderImagesModel(
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
    final List<ReturnOrdersImageList> returnOrdersImageList;
    final int count;
    final int affectedRecords;

    Response({
        required this.returnOrdersImageList,
        required this.count,
        required this.affectedRecords,
    });

    factory Response.fromJson(Map<String, dynamic> json) => Response(
        returnOrdersImageList: List<ReturnOrdersImageList>.from(json["returnOrdersImageList"].map((x) => ReturnOrdersImageList.fromJson(x))),
        count: json["count"],
        affectedRecords: json["affectedRecords"],
    );

    Map<String, dynamic> toJson() => {
        "returnOrdersImageList": List<dynamic>.from(returnOrdersImageList.map((x) => x.toJson())),
        "count": count,
        "affectedRecords": affectedRecords,
    };
}

class ReturnOrdersImageList {
    final int id;
    final int returnOrderId;
    final String fileName;
    final String fileLocation;
    final String fileExtension;
    final String createdBy;
    final String imageString;
    final String createdByUser;
    final DateTime createdDate;

    ReturnOrdersImageList({
        required this.id,
        required this.returnOrderId,
        required this.fileName,
        required this.fileLocation,
        required this.fileExtension,
        required this.createdBy,
        required this.imageString,
        required this.createdByUser,
        required this.createdDate,
    });

    factory ReturnOrdersImageList.fromJson(Map<String, dynamic> json) => ReturnOrdersImageList(
        id: json["id"],
        returnOrderId: json["returnOrderId"],
        fileName: json["fileName"],
        fileLocation: json["fileLocation"],
        fileExtension: json["fileExtension"],
        createdBy: json["createdBy"],
        imageString: json["imageString"],
        createdByUser: json["createdByUser"],
        createdDate: DateTime.parse(json["createdDate"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "returnOrderId": returnOrderId,
        "fileName": fileName,
        "fileLocation": fileLocation,
        "fileExtension": fileExtension,
        "createdBy": createdBy,
        "imageString": imageString,
        "createdByUser": createdByUser,
        "createdDate": createdDate.toIso8601String(),
    };
}
