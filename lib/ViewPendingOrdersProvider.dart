import 'package:flutter/cupertino.dart';
import 'package:srikarbiotech/OrderResponse.dart';

class ViewPendingOrdersProvider extends ChangeNotifier {
  List<OrderResult> viewPendingData = [];
  late List<bool> checkBoxValues = List<bool>.generate(getLengthOfList, (index) => false);
  List<int> selectedOrderIds = []; // List to store selected order IDs

  bool isSelectedAll = false;

  bool get getSelectAllStatus => isSelectedAll;

  void setSelectAllStatus() {
    isSelectedAll = !isSelectedAll;
    notifyListeners();
  }

  void storeIntoViewPendingOrders(List<OrderResult> items) {
    viewPendingData.clear();
    viewPendingData.addAll(items);
    notifyListeners();
  }

  int get getLengthOfList => viewPendingData.length;

  void toggleSelectAll() {
    checkBoxValues = List<bool>.generate(getLengthOfList, (index) => true);
    selectedOrderIds = viewPendingData.map((order) => order.id).toList(); // Select all order IDs
    notifyListeners();
  }

  void toggleUnSelectAll() {
    checkBoxValues = List<bool>.generate(getLengthOfList, (index) => false);
    selectedOrderIds.clear(); // Clear selected order IDs
    notifyListeners();
  }

  List<bool> get getCheckBoxValues => checkBoxValues;

  void setCheckBoxStatusByIndex(int orderIndex, bool? newValue) {
    checkBoxValues[orderIndex] = newValue!;
    final int orderId = viewPendingData[orderIndex].id;
    if (newValue) {
      selectedOrderIds.add(orderId); // Add the selected order ID
    } else {
      selectedOrderIds.remove(orderId); // Remove the deselected order ID
    }
    notifyListeners();
  }

  List<int> getSelectedOrderIds() {
    return selectedOrderIds;
  }
}
