import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:srikarbiotech/Model/returnorders_model.dart';

class ViewReturnOrdersProvider extends ChangeNotifier {
  List<ReturnOrdersList> returnOrdersProviderData = [];
  int? _selectedParty;
  String? _selectedPurpose;
  String? apiPurpose;
  String? apiPartyCode;
  int? apiStatusId;
  int selectedStatusIndex = 0;
  String fromDate = DateFormat('dd-MM-yyyy')
      .format(DateTime.now().subtract(const Duration(days: 7)));
  String toDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  bool filterIconStatus = false;

  final TextEditingController _partyController = TextEditingController();

  TextEditingController get getPartyController => _partyController;

  String partyCode = '';
  String get getPartyCode => partyCode;
  set getPartyCode(String newCode) {
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

    _partyController.clear();

    notifyListeners();
  }

  void storeIntoReturnOrdersProvider(List<ReturnOrdersList> items) {
    returnOrdersProviderData.clear();
    returnOrdersProviderData.addAll(items);
    notifyListeners();
  }

  int _changePage = 0;

  int get changeIndex => _changePage;

  set changeIndex(int index) {
    _changePage = index;
    notifyListeners();
  }
}
