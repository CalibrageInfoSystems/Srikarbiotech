class ReturnOrderItemXrefType {
  int? id;
  int? returnOrderId;
  String? itemGrpCod;
  String? itemGrpName;
  String? itemCode;
  String? itemName;
  int? statusTypeId;
  int? orderQty;
  double? price;
  String? remarks;
  double? totalPrice;

  ReturnOrderItemXrefType({
    required this.id,
    required this.returnOrderId,
    required this.itemGrpCod,
    required this.itemGrpName,
    required this.itemCode,
    required this.itemName,
    required this.statusTypeId,
    required this.orderQty,
    required this.price,
    required this.remarks,
    required this.totalPrice,
  });

  factory ReturnOrderItemXrefType.fromJson(Map<String, dynamic> json) {
    return ReturnOrderItemXrefType(
      id: json['Id'],
      returnOrderId: json['ReturnOrderId'],
      itemGrpCod: json['ItemGrpCod'],
      itemGrpName: json['ItemGrpName'],
      itemCode: json['ItemCode'],
      itemName: json['ItemName'],
      statusTypeId: json['StatusTypeId'],
      orderQty: json['OrderQty'],
      price: json['Price']?.toDouble(), // Convert to double and handle null
      remarks: json['Remarks'],
      totalPrice: json['TotalPrice']?.toDouble(), // Convert to double and handle null
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['ReturnOrderId'] = this.returnOrderId;
    data['ItemGrpCod'] = this.itemGrpCod;
    data['ItemGrpName'] = this.itemGrpName;
    data['ItemCode'] = this.itemCode;
    data['ItemName'] = this.itemName;
    data['StatusTypeId'] = this.statusTypeId;
    data['OrderQty'] = this.orderQty;
    data['Price'] = this.price;
    data['Remarks'] = this.remarks;
    data['TotalPrice'] = this.totalPrice;
    return data;
  }

  // Method to update quantity
  void updateQuantity(int newQuantity) {
    orderQty = newQuantity;
  }
}
