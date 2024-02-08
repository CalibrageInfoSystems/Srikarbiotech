// Static product details
class ProductResponse {
  String? itemCode;
  String? itemName;
  String? itmsGrpCod;
  String? itmsGrpNam;
  String? priceUnit;
  String? gstTaxCtg;
  double? price;
  double? gst;
  String? ugpEntry;
  String? ugpCode;
  String? ugpName;
  int? numInSale;
  String? salUnitMsr;
  ProductResponse({
    required this.itemCode,
    required this.itemName,
    required this.itmsGrpCod,
    required this.itmsGrpNam,
    required this.priceUnit,
    required this.gstTaxCtg,
    required this.price,
    required this.gst,
    required this.ugpEntry,
    required this.ugpCode,
    required this.ugpName,
    required this.numInSale,
    required this.salUnitMsr,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      itemCode: json['itemCode'] ?? '',
      itemName: json['itemName'] ?? '',
      itmsGrpCod: json['itmsGrpCod'] ?? '',
      itmsGrpNam: json['itmsGrpNam'] ?? '',
      priceUnit: json['priceUnit'] ?? '',
      gstTaxCtg: json['gstTaxCtg'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      gst: (json['gst'] as num?)?.toDouble() ?? 0.0,
      ugpEntry: json['ugpEntry'] ?? '',
      ugpCode: json['ugpCode'] ?? '',
      ugpName: json['ugpName'] ?? '',
      numInSale: json['numInSale'] ?? 0,
      salUnitMsr: json['salUnitMsr'] ?? '',
    );
  }
}

class Product {
  final List<ProductResponse> listResult;
  final int count;
  final int affectedRecords;
  final bool isSuccess;

  Product({
    required this.listResult,
    required this.count,
    required this.affectedRecords,
    required this.isSuccess,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      listResult: (json['listResult'] as List)
          .map((itemJson) => ProductResponse.fromJson(itemJson))
          .toList(),
      count: json['count'],
      affectedRecords: json['affectedRecords'],
      isSuccess: json['isSuccess'],
    );
  }
}