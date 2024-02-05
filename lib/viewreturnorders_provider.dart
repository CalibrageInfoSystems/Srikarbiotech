import 'package:flutter/cupertino.dart';
import 'package:srikarbiotech/Model/returnorders_model.dart';

class ViewReturnOrdersProvider extends ChangeNotifier {
  List<ReturnOrdersList> returnOrdersProviderData = [];

  void storeIntoReturnOrdersProvider(List<ReturnOrdersList> items) {
    returnOrdersProviderData.clear();
    returnOrdersProviderData.addAll(items);
    notifyListeners();
  }
}
