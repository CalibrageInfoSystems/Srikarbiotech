import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:srikarbiotech/OrderResponse.dart';

class ViewOrdersProvider extends ChangeNotifier {
  List<OrderResult> viewOrderProviderData = [];
  int? _displayParty;
  String? _displayWareHouse;
  String? _apiWareHouse;
  // String? apiPurpose;
  String? apiPartyCode;
  int? apiStatusId;
  int selectedStatusIndex = 0;
  String fromDate = DateFormat('dd-MM-yyyy').format(DateTime.now().subtract(const Duration(days: 7)));
  String toDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  bool filterIconStatus = false;

  final TextEditingController _partyController = TextEditingController();

  String? partyCode;

  TextEditingController get getPartyController => _partyController;

  String? get getPartyCode => partyCode;
  set getPartyCode(String? newCode) {
    partyCode = newCode;
  }

  bool get filterStatus => filterIconStatus;
  set filterStatus(bool newStatus) {
    filterIconStatus = newStatus;
  }

  String get displayFromDate => fromDate;
  String get apiFromDate {
    DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(fromDate);
    String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
    return formattedDate;
  }

  set setFromDate(String newFromDate) {
    fromDate = newFromDate;
    notifyListeners();
  }

  String get displayToDate => toDate;
  String get apiToDate {
    DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(toDate);
    String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
    return formattedDate;
  }

  set setToDate(String newToDate) {
    toDate = newToDate;
    notifyListeners();
  }

  String? get getApiPartyCode => apiPartyCode;
  set getApiPartyCode(String? newApiPartyCode) {
    apiPartyCode = newApiPartyCode;
    notifyListeners();
  }

  // String? get getApiPurpose => apiPurpose;
  // set getApiPurpose(String? newApiPurpose) {
  //   apiPurpose = newApiPurpose;
  //   notifyListeners();
  // }

  int? get getApiStatusId => apiStatusId;
  set getApiStatusId(int? newApiStatusId) {
    apiStatusId = newApiStatusId;
    notifyListeners();
  }

  int get dropDownStatus => selectedStatusIndex;
  set dropDownStatus(int newStatus) {
    selectedStatusIndex = newStatus;
    notifyListeners();
  }

  int? get dropDownParty => _displayParty;
  set dropDownParty(int? newParty) {
    _displayParty = newParty;
    notifyListeners();
  }

  String? get dropDownWareHouse => _displayWareHouse;
  set dropDownWareHouse(String? newPurpose) {
    _displayWareHouse = newPurpose;
    notifyListeners();
  }

  String? get apiWareHouse => _apiWareHouse;
  set apiWareHouse(String? newPurpose) {
    _apiWareHouse = newPurpose;
    notifyListeners();
  }

  void clearFilter() {
    filterStatus = false;
    fromDate = DateFormat('dd-MM-yyyy')
        .format(DateTime.now().subtract(const Duration(days: 7)));
    toDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    selectedStatusIndex = 0;
    _displayWareHouse = null;
    _apiWareHouse = null;

    _displayParty = null;
    apiPartyCode = null;
    partyCode = null;
    apiStatusId = null;
    _partyController.clear();

    notifyListeners();
  }

  void storeIntoViewOrderProvider(List<OrderResult> items) {
    viewOrderProviderData.clear();
    viewOrderProviderData.addAll(items);
    notifyListeners();
  }
}
