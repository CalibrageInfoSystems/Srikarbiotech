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
  int orderQty;
  double? price;
  double? igst;
  double? cgst;
  double? sgst;
  int? numInSale;
  OrderItemXrefType({
    required this.id,
    required this.orderId,
    required this.itemGrpCod,
    this.itemGrpName,
    this.itemCode,
    required  this.itemName,
    required this.noOfPcs,
    required this.orderQty,
    this.price,
    this.igst,
    this.cgst,
    this.sgst,
    this.numInSale,
  });

  // Factory constructor to create an instance from a JSON map
  factory OrderItemXrefType.fromJson(Map<String, dynamic> json) {
    return OrderItemXrefType(
      id: json['id'],
      orderId: json['orderId'],
      itemGrpCod: json['itemGrpCod'],
      itemGrpName: json['itemGrpName'],
      itemCode: json['itemCode'],
      itemName: json['itemName'],
      noOfPcs: json['noOfPcs'],
      orderQty: json['orderQty'],
      price: json['price'],
      igst: json['igst'],
      cgst: json['cgst'],
      sgst: json['sgst'],
        numInSale :json['numInSale'],
    );
  }

  // Method to convert the object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'itemGrpCod': itemGrpCod,
      'itemGrpName': itemGrpName,
      'itemCode': itemCode,
      'itemName': itemName,
      'noOfPcs': noOfPcs,
      'orderQty': orderQty,
      'price': price,
      'igst': igst,
      'cgst': cgst,
      'sgst': sgst,
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
