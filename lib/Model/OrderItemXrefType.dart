// class OrderItemXrefType {
//   String itemName;
//   int price;
//   int orderQty;
//
//   OrderItemXrefType({
//     required this.itemName,
//     required this.price,
//     required this.orderQty,
//   });
//
//   // Factory constructor to create an instance from a JSON map
//   factory OrderItemXrefType.fromJson(Map<String, dynamic> json) {
//     return OrderItemXrefType(
//       itemName: json['itemName'],
//       price: json['price'],
//       orderQty: json['orderQty'],
//     );
//   }

//
//
//   // Method to convert the object to a JSON map
//   Map<String, dynamic> toJson() {
//     return {
//       'itemName': itemName,
//       'price': price,
//       'orderQty': orderQty,
//       // Add other fields as needed
//     };
//   }
// }


class OrderItemXrefType {
  int? id;
  int? orderId;
  String? itemGrpCod;
  String? itemGrpName;
  String? itemCode;
  String? itemName;
  String? noOfPcs;
  int? orderQty;
  double? price;
  String? ugpName;
  String? ugpEntry;
  int? numInSale;
  String? salUnitMsr;
  double? gst;
  double? totalPrice;
  double? totalPriceWithGST;

  OrderItemXrefType({
    required this.id,
    required this.orderId,
    required this.itemGrpCod,
    required this.itemGrpName,
    required this.itemCode,
    required this.itemName,
    required this.noOfPcs,
    required this.orderQty,
    required this.price,
    required this.ugpName,
    required this.ugpEntry,
    required this.numInSale,
    required this.salUnitMsr,
    required this.gst,
    required this.totalPrice,
    required this.totalPriceWithGST,
  });

  // Factory constructor to create an instance from a JSON map
  factory OrderItemXrefType.fromJson(Map<String, dynamic>? json) {
    return OrderItemXrefType(
      id: json?['Id'],
      orderId: json?['OrderId'],
      itemGrpCod: json?['ItemGrpCod'],
      itemGrpName: json?['ItemGrpName'],
      itemCode: json?['ItemCode'],
      itemName: json?['ItemName'],
      noOfPcs: json?['NoOfPcs'],
      orderQty: json?['OrderQty'],
      price: json?['Price'],
      ugpName: json?['UgpName'],
      ugpEntry:json?['ugpEntry'],
      numInSale: json?['NumInSale'],
      salUnitMsr: json?['SalUnitMsr'],
      gst: json?['GST'],
      totalPrice: json?['TotalPrice'],
      totalPriceWithGST: json?['TotalPriceWithGST'],
    );
  }

  // Method to convert the object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'OrderId': orderId,
      'ItemGrpCod': itemGrpCod,
      'ItemGrpName': itemGrpName,
      'ItemCode': itemCode,
      'ItemName': itemName,
      'NoOfPcs': noOfPcs,
      'OrderQty': orderQty,
      'Price': price,
      'UgpName': ugpName,
      "ugpEntry":ugpEntry,
      'NumInSale': numInSale,
      'SalUnitMsr': salUnitMsr,
      'GST': gst,
      'TotalPrice': totalPrice,
      'TotalPriceWithGST': totalPriceWithGST,
    };
  }

  // Method to update quantity
  void updateQuantity(int newQuantity) {
    orderQty = newQuantity;
  }
}


//     return OrderItemXrefType(
//       id: json['Id'] as int?,
//       orderId: json['OrderId'] as int?,
//       itemGrpCod: json['ItemGrpCod'] as String?,
//       itemGrpName: json['ItemGrpName'] as String?,
//       itemCode: json['ItemCode'] as String?,
//       itemName: json['ItemName'] as String?,
//       noOfPcs: json['NoOfPcs'] as String?,
//       orderQty: json['OrderQty'] as int?,
//       price: (json['Price'] as num?)?.toDouble(),
//       igst: (json['IGST'] as num?)?.toDouble(),
//       cgst: (json['CGST'] as num?)?.toDouble(),
//       sgst: (json['SGST'] as num?)?.toDouble(),
//     );
//   }
// }
