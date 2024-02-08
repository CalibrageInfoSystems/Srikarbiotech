import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:srikarbiotech/Model/returnorders_model.dart';

class ViewReturnOrdersProvider extends ChangeNotifier {
  List<ReturnOrdersList> returnOrdersProviderData = [];
  int? _selectedParty;
  String? _selectedPurpose;
  String? apiPurpose;
  String? apiPartyCode = '';
  int? apiStatusId;
  int selectedStatusIndex = 0;
  String fromDate = DateFormat('dd-MM-yyyy')
      .format(DateTime.now().subtract(const Duration(days: 7)));
  String toDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  bool filterIconStatus = false;

  bool get filterStatus => filterIconStatus;
  set filterStatus(bool newStatus) {
    filterIconStatus = newStatus;
  }

  String get fromDateValue => fromDate;
  set fromDateValue(String newFromDate) {
    fromDate = newFromDate;
    notifyListeners();
  }

  String? get getApiPartyCode => apiPartyCode;
  set getApiPartyCode(String? newApiPartyCode) {
    apiPartyCode = newApiPartyCode;
    notifyListeners();
  }

  String? get getApiPurpose => apiPurpose;
  set getApiPurpose(String? newApiPurpose) {
    apiPurpose = newApiPurpose;
    notifyListeners();
  }

  int? get getApiStatusId => apiStatusId;
  set getApiStatusId(int? newApiStatusId) {
    apiStatusId = newApiStatusId;
    notifyListeners();
  }

  String get toDateValue => toDate;
  set toDateValue(String newToDate) {
    toDate = newToDate;
    notifyListeners();
  }

  int get dropDownStatus => selectedStatusIndex;
  set dropDownStatus(int newStatus) {
    selectedStatusIndex = newStatus;
    notifyListeners();
  }

  int? get dropDownParty => _selectedParty;
  set dropDownParty(int? newParty) {
    _selectedParty = newParty;
    notifyListeners();
  }

  String? get dropDownPurpose => _selectedPurpose;
  set dropDownPurpose(String? newPurpose) {
    _selectedPurpose = newPurpose;
    notifyListeners();
  }

  void clearFilter() {
    filterStatus = false;
    fromDate = DateFormat('dd-MM-yyyy')
        .format(DateTime.now().subtract(const Duration(days: 7)));
    toDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    selectedStatusIndex = 0;
    _selectedPurpose = null;
    _selectedParty = null;

    apiPurpose = null;
    apiPartyCode = null;
    apiStatusId = null;

    notifyListeners();
  }

  void storeIntoReturnOrdersProvider(List<ReturnOrdersList> items) {
    returnOrdersProviderData.clear();
    returnOrdersProviderData.addAll(items);
    notifyListeners();
  }
}
