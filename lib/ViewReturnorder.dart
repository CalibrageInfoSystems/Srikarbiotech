import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:srikarbiotech/Common/CommonUtils.dart';
import 'package:srikarbiotech/Common/SharedPrefsData.dart';
import 'package:srikarbiotech/Model/returnorders_model.dart';
import 'package:srikarbiotech/OrctResponse.dart';
import 'package:srikarbiotech/Payment_model.dart';
import 'package:srikarbiotech/Services/api_config.dart';
import 'package:srikarbiotech/viewreturnorders_provider.dart';

import 'HomeScreen.dart';
import 'Model/warehouse_model.dart';
import 'ReturnOrderDetailsPage.dart';
import 'ViewOrders.dart';

class ViewReturnorder extends StatefulWidget {
  const ViewReturnorder({super.key});

  @override
  State<ViewReturnorder> createState() => _MyReturnOrdersPageState();
}

class _MyReturnOrdersPageState extends State<ViewReturnorder> {
  final _orangeColor = HexColor('#e58338');

  final _hintTextStyle = const TextStyle(
    fontSize: 14,
    color: Colors.black38,
    fontWeight: FontWeight.bold,
  );
  final searchBarBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Colors.black),
  );
  final List<String> orderStatusList = [
    'Shipped',
    'Pending',
    'Delivered',
    'Pending',
    'Rejected',
    'Shipped',
    'Delivered',
  ];
  String? userId = "";
  int? companyId = 0;
  late Future<List<ReturnOrdersList>> apiData;
  late ViewReturnOrdersProvider returnOrdersProvider;
  @override
  void initState() {
    super.initState();
    initializeApiData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    returnOrdersProvider = Provider.of<ViewReturnOrdersProvider>(context);
  }

  void initializeApiData() {
    apiData = getReturnOrderApi();
    apiData.then((data) {
      setState(() {
        returnOrdersProvider.storeIntoReturnOrdersProvider(data);
      });
    }).catchError((error) {
      debugPrint('catchError initializing data: $error');
    });
  }

  Future<List<ReturnOrdersList>> getReturnOrderApi() async {
    userId = await SharedPrefsData.getStringFromSharedPrefs("userId");
    companyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
    String apiurl = baseUrl + GetAppReturnOrdersBySearch;
    final url = Uri.parse(apiurl);
    try {
      final requestBody = {
        "PartyCode": returnOrdersProvider.getApiPartyCode,
        "StatusId": returnOrdersProvider.getApiStatusId,
        "FormDate": returnOrdersProvider.apiFromDate,
        "ToDate": returnOrdersProvider.apiToDate,
        "CompanyId": companyId,
        "UserId": userId,
        "WhsCode": returnOrdersProvider.apiWareHouse
      };

      debugPrint('_______Return Orders____1___${jsonEncode(requestBody)}');
      final response = await http.post(
        url,
        body: json.encode(requestBody),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['isSuccess']) {
          List<dynamic> data = jsonResponse['response']['listResult'];
          List<ReturnOrdersList> result = data.map((item) => ReturnOrdersList.fromJson(item)).toList();
          returnOrdersProvider.storeIntoReturnOrdersProvider(result);
          return result;
        } else {
          List<ReturnOrdersList> emptyList = [];
          returnOrdersProvider.storeIntoReturnOrdersProvider(emptyList);
          return emptyList;
        }
      } else {
        debugPrint('Failed to send the request. Status code: ${response.statusCode}');
        throw Exception('Failed to send the request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('catch: ${e.toString()}');
      throw Exception('catch: $e');
    }
  }

  filterRecordsBasedOnPartyName(String input) {
    apiData.then((data) {
      setState(() {
        returnOrdersProvider.storeIntoReturnOrdersProvider(data.where((item) => item.partyName.toLowerCase().contains(input.toLowerCase())).toList());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ViewReturnOrdersProvider>(
      builder: (context, viewReturnOrdersProvider, _) => Scaffold(
        appBar: _appBar(),
        body: FutureBuilder(
          future: apiData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator.adaptive());
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('No return orders found'),
              );
            } else {
              if (snapshot.hasData) {
                // List<ListResult> data = snapshot.data!;
                List<ReturnOrdersList> data = viewReturnOrdersProvider.returnOrdersProviderData;

                return WillPopScope(
                  onWillPop: () async {
                    // Clear the cart data here
                    returnOrdersProvider.clearFilter();
                    //  viewOrdersProvider.clearFilter();
                    return true; // Allow the back navigation
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _searchBarAndFilter(),
                        if (viewReturnOrdersProvider.returnOrdersProviderData.isNotEmpty)
                          // card items
                          Expanded(
                            child: ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                return ReturnCarditem(
                                  // work
                                  index: index,
                                  data: data[index],
                                );
                              },
                            ),
                          )
                        else
                          noCollectionText(),
                      ],
                    ),
                  ),
                );
              } else {
                return const Center(
                  child: Text('No data available'),
                );
              }
            }
          },
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: const Color(0xFFe78337),
      automaticallyImplyLeading: false,
      elevation: 5,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                child: GestureDetector(
                  onTap: () {
                    returnOrdersProvider.clearFilter();
                    Navigator.of(context).pop();
                  },
                  child: const Icon(
                    Icons.chevron_left,
                    size: 30.0,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              const Text(
                'My Return Orders',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            child: Image.asset(
              'assets/srikar-home-icon.png',
              width: 30,
              height: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBarAndFilter() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
              height: 45,
              child: TextField(
                cursorColor: CommonUtils.orangeColor,
                onChanged: (input) => filterRecordsBasedOnPartyName(input),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(top: 10, left: 15),
                  hintText: 'Order Search',
                  hintStyle: _hintTextStyle,
                  suffixIcon: const Icon(Icons.search),
                  border: CommonUtils.searchBarOutPutInlineBorder,
                  focusedBorder: CommonUtils.searchBarEnabledNdFocuedOutPutInlineBorder,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Container(
            height: 45,
            width: 45,
            decoration: returnOrdersProvider.filterStatus ? CommonUtils.borderForAppliedFilter : CommonUtils.borderForFilter,
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (context) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: const FilterBottomSheet(),
                  ),
                );
              },
              child: Center(
                child: SvgPicture.asset(
                  'assets/apps-sort.svg',
                  color: _orangeColor,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget noCollectionText() {
    return const Expanded(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Text(
                'No return orders found',
                style: CommonUtils.txSty_13B,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final _labelTextStyle = const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold);
  // List<Dealer> dealers = [];
  int selectedCardCode = -1;

  // ... Other variables and methods
  final _primaryOrange = const Color(0xFFe58338);
  int selectedChipIndex = 1;

  final _titleTextStyle = const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold);

  final _clearTextStyle = const TextStyle(color: Color(0xFFe58338), fontSize: 16, decoration: TextDecoration.underline, decorationColor: Color(0xFFe58338));

  DateTime toDate = DateTime.now();
  DateTime fromDate = DateTime.now();
  String? selectedValue;

  List<dynamic> dropdownItems = [];
  PaymentMode? selectedPaymode;
  int? payid;
  late String selectedName;
  ApiResponse? apiResponse;
  String? Selected_PaymentMode = "";
  TextEditingController todateController = TextEditingController();
  TextEditingController fromdateController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  DateTime selectedfromdateDate = DateTime.now();
  List<Purpose> purposeList = [];
  String? selectedPurpose, selectformattedfromdate, selectformattedtodate;
  Purpose? selectedPurposeObj; // Declare it globally
  String purposename = '';
  int? savedCompanyId = 0;
  String? slpCode = "";
  late List<WareHouseList> wareHousesData = [];
  @override
  void initState() {
    // todateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    // DateTime oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    // fromdateController.text = DateFormat('dd-MM-yyyy').format(oneWeekAgo);
    fetchData();
    getpaymentmethods();
    fetchdropdownitems();
    getWareHouses();
    super.initState();
  }

  late ViewReturnOrdersProvider viewReturnOrdersProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    viewReturnOrdersProvider = Provider.of<ViewReturnOrdersProvider>(context);
    initializeFromAndToDates();
  }

  void initializeFromAndToDates() {
    fromdateController.text = viewReturnOrdersProvider.displayFromDate;
    todateController.text = viewReturnOrdersProvider.displayToDate;
  }

  Future<void> fetchdropdownitems() async {
    savedCompanyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
    String apiurl = baseUrl + GetPurpose + savedCompanyId.toString();
    // final apiUrl = 'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Collections/GetPurposes/'
    //     '$savedCompanyId';

    try {
      final response = await http.get(Uri.parse(apiurl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final listResult = data['response']['listResult'] as List;

        setState(() {
          purposeList = listResult.map((item) => Purpose.fromJson(item)).toList();
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('catch: $e');
    }
  }

  Future<void> getpaymentmethods() async {
    String apiurl = baseUrl + GetTypeCdmt4;
    final response = await http.get(Uri.parse(apiurl));

    if (response.statusCode == 200) {
      setState(() {
        apiResponse = ApiResponse.fromJson(jsonDecode(response.body));
        print('========>apiResponse$apiResponse');
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime currentDate = DateTime.now();
    DateTime initialDate;

    print('===>current date,${DateTime.now()}');
    if (controller.text.isNotEmpty) {
      try {
        print('===> date,${DateFormat('dd-MM-yyyy').parse(controller.text)}');
        initialDate = DateFormat('dd-MM-yyyy').parse(controller.text);
      } catch (e) {
        // If parsing fails, default to current date
        initialDate = DateTime.now();
      }
    } else {
      // If controller.text is empty, default to current date
      initialDate = DateTime.now();
    }

    try {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (picked != null) {
        String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
        controller.text = formattedDate;
        viewReturnOrdersProvider.setToDate = formattedDate;
        // Save selected dates as DateTime objects
        selectedDate = picked;

        // Print formatted date
        selectformattedtodate = DateFormat('yyyy-MM-dd').format(picked);
        print("selectformatted_todate: $selectformattedtodate");
      }
    } catch (e) {
      print("Error selecting date: $e");
    }
  }

  Widget buildDateToInput(
    BuildContext context,
    String labelText,
    TextEditingController controller,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 0.0, left: 5.0, right: 0.0),
          child: Text(
            labelText,
            style: CommonUtils.txSty_13O_F6,
            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(height: 4.0), // Add space between labelText and TextFormField
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 40.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: const Color(0xFFe78337),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 5),
                      child: TextFormField(
                        controller: controller,
                        enabled: false,
                        style: CommonUtils.txSty_13O_F6,
                        decoration: InputDecoration(
                          hintText: labelText,
                          hintStyle: CommonUtils.txSty_13O_F6,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: onTap,
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.calendar_today,
                      color: Color(0xFFe78337),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectfromDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime currentDate = DateTime.now();
    DateTime initialDate;

    print('===>current date,${DateTime.now()}');
    if (controller.text.isNotEmpty) {
      try {
        print('===> date,${DateFormat('dd-MM-yyyy').parse(controller.text)}');
        initialDate = DateFormat('dd-MM-yyyy').parse(controller.text);
      } catch (e) {
        // If parsing fails, default to current date
        initialDate = DateTime.now();
      }
    } else {
      // If controller.text is empty, default to current date
      initialDate = DateTime.now();
    }

    try {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (picked != null) {
        String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
        controller.text = formattedDate;
        viewReturnOrdersProvider.setFromDate = formattedDate;
        // Save selected dates as DateTime objects
        selectedfromdateDate = picked;

        // Print formatted date
        // print("fromattedfromdate: ${DateFormat('yyyy-MM-dd').format(picked)}");
        selectformattedfromdate = DateFormat('yyyy-MM-dd').format(picked);
      }
    } catch (e) {
      print("Error selecting date: $e");
    }
  }

  Widget buildDateInputfromdate(
    BuildContext context,
    String labelText,
    TextEditingController controller,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 0.0, left: 5.0, right: 0.0),
          child: Text(
            labelText,
            style: CommonUtils.txSty_13O_F6,
            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(height: 4.0), // Add space between labelText and TextFormField
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 40.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: const Color(0xFFe78337),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 5),
                      child: TextFormField(
                        controller: controller,
                        // initialValue: viewReturnOrdersProvider.fromDateValue,
                        enabled: false,
                        style: CommonUtils.txSty_13O_F6,
                        decoration: InputDecoration(
                          hintText: labelText,
                          hintStyle: CommonUtils.txSty_13O_F6,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.calendar_today,
                      color: Color(0xFFe78337),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> fetchData() async {
    slpCode = await SharedPrefsData.getStringFromSharedPrefs("slpCode");
    savedCompanyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
    final response = await http.get(Uri.parse(baseUrl + GetAllDealersBySlpCode + '$savedCompanyId' + "/" + '$slpCode'));

    // print("apiUrl: ${apiUrl}");
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);

      if (data['isSuccess']) {
        if (data['response']['listResult'] != null) {
          setState(() {
            dropdownItems = List.from(data['response']['listResult']);
          });
        }
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  bool isPartyCodeIsEmpty = false;
  @override
  Widget build(BuildContext context) {
    return Consumer<ViewReturnOrdersProvider>(
      builder: (context, provider, _) => SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Filter By',
                  style: _titleTextStyle,
                ),
                GestureDetector(
                  onTap: () {
                    provider.clearFilter();
                  },
                  child: Text(
                    'Clear all filters',
                    style: _clearTextStyle,
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 5, bottom: 12),
              child: const Divider(
                height: 5,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text(
                    'Party',
                    style: CommonUtils.txSty_13O_F6,
                  ),
                ),
                const SizedBox(
                  height: 4.0,
                ),
                Container(
                  height: 40.0,
                  padding: const EdgeInsets.only(top: 18),
                  decoration: CommonUtils.decorationO_R10W1,
                  child: TypeAheadField(
                    controller: provider.getPartyController,
                    builder: (context, controller, focusNode) => TextField(
                      controller: controller,
                      focusNode: focusNode,
                      autofocus: false,
                      style: CommonUtils.Mediumtext_12_0,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Select Party',
                          hintStyle: CommonUtils.Mediumtext_12_0),
                    ),
                    itemBuilder: (context, value) {
                      return ListTile(
                        dense: true,
                        title: Text(
                          '${isPartyCodeIsEmpty ? value : value['cardName']}',
                          style: CommonUtils.Mediumtext_12_0,
                        ),
                      );
                    },
                    suggestionsCallback: (search) {
                      if (search == '') {
                        return null;
                      }
                      final filteredSuggestions = dropdownItems.where((party) => party['cardName'].toLowerCase().startsWith(search.toLowerCase())).toList();

                      isPartyCodeIsEmpty = false;
                      // partyInfo = dropdownItems.where((party) =>
                      //     party['cardName']
                      //         .toLowerCase()
                      //         .startsWith(search.toLowerCase()));
                      if (filteredSuggestions.isEmpty) {
                        isPartyCodeIsEmpty = true;
                        return ['No party found'];
                      }

                      return filteredSuggestions;
                    },
                    onSelected: (selectedValue) {
                      provider.getPartyController.text = selectedValue['cardName'];
                      provider.getPartyCode = selectedValue['cardCode'];
                    },
                  ),

                  // TypeAheadField(
                  //   controller: provider.getPartyController,
                  //   builder: (context, controller, focusNode) => TextField(
                  //     controller: controller,
                  //     focusNode: focusNode,
                  //     autofocus: false,
                  //     style: CommonUtils.hintstyle_13,
                  //     decoration: const InputDecoration(
                  //         border: OutlineInputBorder(
                  //           borderSide: BorderSide.none,
                  //         ),
                  //         hintText: 'Select Party',
                  //         hintStyle: CommonUtils.hintstyle_13),
                  //   ),
                  //   itemBuilder: (context, value) {
                  //     return ListTile(
                  //       dense: true,
                  //       title: Text(
                  //         value,
                  //         style: CommonUtils.hintstyle_12,
                  //       ),
                  //     );
                  //   },
                  //   onSelected: (selectedValue) {
                  //     provider.getPartyController.text = selectedValue;
                  //   },
                  //   suggestionsCallback: (search) {
                  //     if (search == '') {
                  //       return null;
                  //     }
                  //     final filteredSuggestions = dropdownItems
                  //         .where((party) => party['cardName']
                  //             .toLowerCase()
                  //             .startsWith(search.toLowerCase()))
                  //         .map((party) => party['cardName'])
                  //         .toList();
                  //     if (filteredSuggestions.isEmpty) {
                  //       return ['No party found'];
                  //     }

                  //     return filteredSuggestions;
                  //   },
                  // ),

                  // DropdownButtonHideUnderline(
                  //   child: ButtonTheme(
                  //     alignedDropdown: true,
                  //     child: DropdownButton<int>(
                  //       hint: Text(
                  //         'Select Party',
                  //         style: CommonUtils.txSty_13O_F6,
                  //       ),
                  //       value: provider.dropDownParty,
                  //       onChanged: (int? value) {
                  //         setState(() {
                  //           selectedCardCode = value!;
                  //           provider.dropDownParty = value;
                  //           if (selectedCardCode != -1) {
                  //             selectedValue =
                  //                 dropdownItems[selectedCardCode]['cardCode'];
                  //             selectedName =
                  //                 dropdownItems[selectedCardCode]['cardName'];
                  //             provider.getApiPartyCode =
                  //                 dropdownItems[selectedCardCode]['cardCode'];
                  //             print("selectedValue:$selectedValue");
                  //             print("selectedName:$selectedName");
                  //           } else {
                  //             print("==========");
                  //             print(selectedValue);
                  //             print(selectedName);
                  //           }
                  //           // isDropdownValid = selectedTypeCdId != -1;
                  //         });
                  //       },
                  //       items: dropdownItems.asMap().entries.map((entry) {
                  //         final index = entry.key;
                  //         final item = entry.value;
                  //         return DropdownMenuItem<int>(
                  //             value: index,
                  //             child: Text(
                  //               item['cardName'],
                  //               overflow: TextOverflow.visible,
                  //               // wrapText: true,
                  //             ));
                  //       }).toList(),
                  //       style: CommonUtils.txSty_13O_F6,
                  //       iconSize: 20,
                  //       icon: null,
                  //       isExpanded: true,
                  //       underline: const SizedBox(),
                  //     ),
                  //   ),
                  // ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0, top: 5.0),
              child: Text(
                'Warehouse',
                style: CommonUtils.txSty_13O_F6,
              ),
            ),
            const SizedBox(
              height: 4.0,
            ),
            Container(
              width: double.infinity,
              height: 40.0,
              padding: const EdgeInsets.only(left: 15, right: 20),
              decoration: CommonUtils.decorationO_R10W1,
              child: wareHousesData.isEmpty
                  ? LoadingAnimationWidget.newtonCradle(
                      color: Colors.blue,
                      size: 40.0,
                    )
                  : DropdownButton<String>(
                      hint: Text(
                        'Select Warehouse',
                        style: CommonUtils.txSty_13O_F6,
                      ),
                      value: provider.dropDownWareHouse,
                      onChanged: (String? newValue) {
                        setState(() {
                          provider.dropDownWareHouse = newValue;
                          WareHouseList house = wareHousesData.firstWhere((item) => item.whsName == newValue);
                          // for (WareHouseList house in wareHousesData) {
                          //   if (house.whsName == newValue) {
                          //     provider.apiWareHouse = house.whsCode;
                          //     break;
                          //   }
                          // }
                          provider.apiWareHouse = house.whsCode;
                        });
                      },
                      items: wareHousesData.map((WareHouseList warehouse) {
                        return DropdownMenuItem<String>(
                          value: warehouse.whsName,
                          child: Text(
                            warehouse.whsName,
                            style: CommonUtils.txSty_13O_F6,
                          ),
                        );
                      }).toList(),
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 20,
                      isExpanded: true,
                      underline: const SizedBox(),
                    ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            SizedBox(
              height: 40,
              child: apiResponse == null
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: apiResponse!.listResult.length + 1, // Add 1 for the "All" option
                      itemBuilder: (BuildContext context, int index) {
                        bool isSelected = index == provider.dropDownStatus;
                        PaymentMode currentPaymode;

                        // Handle the "All" option
                        if (index == 0) {
                          currentPaymode = PaymentMode(
                            // Provide default values or handle the null case as needed
                            typeCdId: null,
                            classTypeId: 3,
                            name: 'All',
                            desc: 'All',
                            tableName: 'all',
                            columnName: 'all',
                            sortOrder: 0,
                            isActive: true,
                          );
                        } else {
                          currentPaymode = apiResponse!.listResult[index - 1]; // Adjust index for actual data
                        }
                        return GestureDetector(
                          onTap: () {
                            // ###
                            setState(() {
                              provider.dropDownStatus = index;
                              selectedPaymode = currentPaymode;
                            });
                            payid = currentPaymode.typeCdId;
                            provider.getApiStatusId = currentPaymode.typeCdId;
                            Selected_PaymentMode = currentPaymode.desc;
                            print('payid:$payid');
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFe78337) : const Color(0xFFe78337).withOpacity(0.1),
                              border: Border.all(
                                color: isSelected ? const Color(0xFFe78337) : const Color(0xFFe78337),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: IntrinsicWidth(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          currentPaymode.desc.toString(),
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(
              height: 10.0,
            ),

            // From date
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildDateInputfromdate(
                  context,
                  'From Date',
                  fromdateController,
                  () => _selectfromDate(context, fromdateController),
                ),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),

            // To Date
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //333
                buildDateToInput(
                  context,
                  'To Date',
                  todateController,
                  () => _selectDate(context, todateController),
                ),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                        color: Colors.red,
                      ),
                      side: const BorderSide(
                        color: Colors.red,
                      ),
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      getappliedfilterData(context);
                    },
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                        color: Colors.white,
                      ),
                      backgroundColor: _primaryOrange,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                    child: const Text(
                      'Apply',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      )),
    );
  }

  Future<void> getappliedfilterData(BuildContext context) async {
    viewReturnOrdersProvider.filterStatus = true;
    int companyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
    String userId = await SharedPrefsData.getStringFromSharedPrefs("userId");
    String apiurl = baseUrl + GetAppReturnOrdersBySearch;
    final url = Uri.parse(apiurl);
    try {
      final requestBody = {
        "PartyCode": viewReturnOrdersProvider.getPartyCode,
        "StatusId": viewReturnOrdersProvider.getApiStatusId,
        "FormDate": viewReturnOrdersProvider.apiFromDate,
        "ToDate": viewReturnOrdersProvider.apiToDate,
        "CompanyId": companyId,
        "UserId": userId, // "e39536e2-89d3-4cc7-ae79-3dd5291ff156"
        "WhsCode": viewReturnOrdersProvider.apiWareHouse
      };
      debugPrint('_______Return Orders____2___${jsonEncode(requestBody)}');

      final response = await http.post(
        url,
        body: json.encode(requestBody),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['isSuccess']) {
          if (jsonResponse['response']['listResult'] != null) {
            List<dynamic> data = jsonResponse['response']['listResult'];
            List<ReturnOrdersList> result = data.map((item) => ReturnOrdersList.fromJson(item)).toList();
            viewReturnOrdersProvider.storeIntoReturnOrdersProvider(result);
          } else {
            List<ReturnOrdersList> emptyList = [];
            viewReturnOrdersProvider.storeIntoReturnOrdersProvider(emptyList);

            debugPrint('api response is null.');
          }
        } else {
          List<ReturnOrdersList> emptyList = [];
          viewReturnOrdersProvider.storeIntoReturnOrdersProvider(emptyList);
          debugPrint('api call unsuccess, so we are passing empty list.');
        }
      } else {
        debugPrint('Failed to send the request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('catch: $e');
    }
    Navigator.of(context).pop();
  }

  Future<void> getWareHouses() async {
    String userId = await SharedPrefsData.getStringFromSharedPrefs("userId");
    int companyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");

    try {
      String apiurl = baseUrl + GetWarehouse + userId + companyId.toString();
      //  String apiUrl = "http://182.18.157.215/Srikar_Biotech_Dev/API/api/Account/GetWarehousesByUserandCompany/$userId/$companyId";
      // String apiUrl = '$baseUrl$GetWarehousesByUserandCompany$userId 1';
      final jsonResponse = await http.get(Uri.parse(apiurl));
      if (jsonResponse.statusCode == 200) {
        Map<String, dynamic> response = jsonDecode(jsonResponse.body);
        if (response['response']['listResult'] != null) {
          List<dynamic> wareHouseList = response['response']['listResult'];

          debugPrint('wareHouseList: ${wareHouseList[0]['whsName']}');
          wareHousesData = wareHouseList.map((house) => WareHouseList.fromJson(house)).toList();
          debugPrint('wareHousesData: ${wareHousesData[0].whsName}');
        } else {
          debugPrint('warehouse list is empty');
        }
      } else {
        debugPrint('error: api call failed');
      }
    } catch (e) {
      throw Exception('catch: $e');
    }
  }

// void clearAllFilters() {
//   setState(() {
//     // Reset the selected values to their initial state or default values
//     selectedCardCode = -1;
//     selectedValue = null;
//     selectedName = "";

//     selectedPurpose = null;
//     selectedPurposeObj = null;
//     purposename = "";

//     selectedPaymode = null;
//     payid = null;
//     Selected_PaymentMode = null;

//     // Add similar reset logic for other filter options

//     // Clear date controllers if you have date filters
//     todateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
//     DateTime oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
//     fromdateController.text = DateFormat('dd-MM-yyyy').format(oneWeekAgo);
//   });
// }
}

class ReturnCarditem extends StatefulWidget {
  final int index;
  final ReturnOrdersList data;
  const ReturnCarditem({super.key, required this.index, required this.data});

  @override
  State<ReturnCarditem> createState() => _ReturnCarditemState();
}

class _ReturnCarditemState extends State<ReturnCarditem> {
  final _iconBoxBorder = BoxDecoration(
    borderRadius: BorderRadius.circular(5.0),
    color: Colors.white,
  );

  late Color statusColor;
  late Color statusBgColor;
  Widget getSvgAsset(String status) {
    String assetPath;
    late Color iconColor;
    switch (status) {
      case "Shipped":
        assetPath = 'assets/shipping-fast.svg';
        iconColor = const Color(0xFFe58338);
        statusColor = const Color(0xFFe58338);
        statusBgColor = const Color.fromARGB(255, 250, 214, 187);
        break;
      case 'Pending':
        assetPath = 'assets/shipping-timed.svg';
        iconColor = const Color(0xFFc04f51);
        statusColor = const Color(0xFFc04f51);
        statusBgColor = const Color.fromARGB(255, 241, 183, 184);
        break;
      case 'Received':
        assetPath = 'assets/truck-check.svg';
        iconColor = Colors.green;
        statusColor = Colors.green;
        statusBgColor = Colors.green.shade100;
        break;
      case 'Partially Received':
        assetPath = 'assets/boxes.svg';
        iconColor = const Color(0xFF31b3cc);
        statusColor = const Color(0xFF31b3cc);
        statusBgColor = const Color(0xFF31b3cc).withOpacity(0.2);
        break;
      case 'Not Received':
        assetPath = 'assets/order-cancel.svg';
        iconColor = Colors.red;
        statusColor = Colors.red;
        statusBgColor = Colors.red.shade100;
        break;
      // case 'Received':
      //   assetPath = 'assets/srikar_biotech_logo.svg';
      //   iconColor = Colors.grey;
      //   statusColor = Colors.grey;
      //   statusBgColor = Colors.grey.withOpacity(0.2);
      //   break;
      default:
        assetPath = 'assets/sb_home.svg';
        iconColor = Colors.black26;
        statusColor = Colors.black26;
        statusBgColor = const Color.fromARGB(31, 124, 124, 124);
        break;
    }
    return SvgPicture.asset(
      assetPath,
      width: 50,
      height: 50,
      fit: BoxFit.fill,
      color: iconColor,
    );
  }

  Widget sendingSvgImagesAndColors(String statusName) {
    String svgIcon;
    Color svgIconBgColor;
    switch (statusName) {
      case "Shipped":
        svgIcon = 'assets/shipping-fast.svg';
        statusColor = const Color(0xFFe58338);
        svgIconBgColor = const Color.fromARGB(255, 250, 214, 187);
        break;
      case 'Pending':
        svgIcon = 'assets/shipping-timed.svg';
        statusColor = const Color(0xFFc04f51);
        svgIconBgColor = const Color.fromARGB(255, 241, 183, 184);
        break;
      case 'Received':
        svgIcon = 'assets/truck-check.svg';
        statusColor = Colors.green;
        svgIconBgColor = Colors.green.shade100;
        break;
      case 'Partially Received':
        svgIcon = 'assets/boxes.svg';
        statusColor = const Color(0xFF31b3cc);
        svgIconBgColor = const Color(0xFF31b3cc).withOpacity(0.2);
        break;
      case 'Not Received':
        svgIcon = 'assets/order-cancel.svg';
        statusColor = Colors.red;
        svgIconBgColor = Colors.red.shade100;
        break;
      // case 'Received':
      //   svgIcon = 'assets/srikar_biotech_logo.svg';
      //   statusColor = Colors.grey;
      //   svgIconBgColor = Colors.grey.withOpacity(0.2);
      //   break;
      default:
        svgIcon = 'assets/sb_home.svg';
        statusColor = Colors.black26;
        svgIconBgColor = const Color.fromARGB(31, 124, 124, 124);
        break;
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: svgIconBgColor,
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        children: [
          SvgPicture.asset(
            svgIcon,
            fit: BoxFit.fill,
            width: 15,
            height: 15,
            color: statusColor,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            statusName,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 13,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String dateString = widget.data.createdDate;
    DateTime date = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd MMM, yyyy').format(date);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ReturnOrderDetailsPage(
              orderId: widget.data.id,
              statusBar: sendingSvgImagesAndColors(
                widget.data.statusName,
              ),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        color: Colors.transparent,
        child: Card(
          elevation: 5,
          child: Container(
            padding: const EdgeInsets.all(12),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: CommonUtils.boxBorder,
                  child: Row(
                    children: [
                      // starting icon of card
                      Card(
                        elevation: 3,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Container(
                          height: 65,
                          width: 65,
                          padding: const EdgeInsets.all(10),
                          decoration: _iconBoxBorder,
                          child: Center(
                            child: getSvgAsset(widget.data.statusName),
                          ),
                        ),
                      ),

                      // beside info
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.6,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, top: 0, bottom: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.data.partyName,
                                style: CommonUtils.Mediumtext_14_cb,
                                softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Order ID : ',
                                        style: CommonUtils.txSty_13B_Fb,
                                      ),
                                      Text(
                                        widget.data.returnOrderNumber,
                                        style: CommonUtils.txSty_13O_F6,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  widget.data.whsName != null
                                      ? Text(
                                          '${widget.data.whsName}',
                                          style: CommonUtils.txSty_13O_F6,
                                        )
                                      : const SizedBox(),
                                  // Text(
                                  //   '${widget.orderResult.whsName}',
                                  //   style: CommonUtils.txSty_13O_F6,
                                  // ),
                                  Row(
                                    children: [
                                      const Text(
                                        'No.of Items: ',
                                        style: CommonUtils.txSty_13B_Fb,
                                      ),
                                      Text(
                                        '${widget.data.noOfItems}',
                                        style: CommonUtils.txSty_13O_F6,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              Row(
                                children: [
                                  const Text(
                                    'LR No :  ',
                                    style: CommonUtils.txSty_13B_Fb,
                                  ),
                                  Text(
                                    widget.data.lrNumber,
                                    style: CommonUtils.txSty_13O_F6,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 5.0),
                      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: statusBgColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.data.statusName,
                            style: TextStyle(
                              fontSize: 11,
                              color: statusColor,
                              // Add other text styles as needed
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Expanded(child: SizedBox()),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Row(
                              //   children:[
                              //   const Text(
                              //     'LR No :  ',
                              //     style: CommonUtils.txSty_13B_Fb,
                              //   ),
                              //   Text(
                              //     widget.data.lrNumber,
                              //     style: CommonUtils.txSty_13O_F6,
                              //   ),
                              // ],
                              // ),
                              // Row(
                              //   children: [
                              //     const Text(
                              //       'No.of Items : ',
                              //       style: CommonUtils.txSty_13B_Fb,
                              //     ),
                              //     Text(
                              //       '${widget.data.noOfItems}',
                              //       style: CommonUtils.txSty_13O_F6,
                              //     ),
                              //   ],
                              // ),
                              Row(
                                children: [
                                  // const Text(
                                  //   'Date : ',
                                  //   style: CommonUtils.txSty_13B_Fb,
                                  // ),
                                  // Text(
                                  //   '${widget.data.noOfItems}',
                                  //   style: CommonUtils.txSty_13O_F6,
                                  // ),
                                  Text(
                                    formattedDate,
                                    style: CommonUtils.txSty_13O_F6,
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
