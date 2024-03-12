import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:srikarbiotech/Model/warehouse_model.dart';
import 'package:srikarbiotech/vieworders_provider.dart';
import 'Common/CommonUtils.dart';
import 'Common/SharedPrefsData.dart';
import 'HomeScreen.dart';
import 'OrctResponse.dart';
import 'OrderResponse.dart';
import 'Payment_model.dart';
import 'Services/api_config.dart';
import 'order_details.dart';

class ViewOrders extends StatefulWidget {
  const ViewOrders({super.key});

  @override
  State<ViewOrders> createState() => _VieworderPageState();
}

class _VieworderPageState extends State<ViewOrders> {
  final _orangeColor = HexColor('#e58338');

  List<OrderResult> orderesponselist = [];

  List<OrderResult> filterorderesponselist = [];

  TextEditingController searchController = TextEditingController();

  late Future<List<OrderResult>?> apiData;

  late ViewOrdersProvider viewOrdersProvider;
  int companyId = 0;
  String? userId = "";
  @override
  void initState() {
    super.initState();
    initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    viewOrdersProvider = Provider.of<ViewOrdersProvider>(context);
  }

  void initializeData() {
    apiData = getorder();
    apiData.then((data) {
      if (data != null) {
        setState(() {
          viewOrdersProvider.storeIntoViewOrderProvider(data);
        });
      } else {}
    }).catchError((error) {
      throw Exception('catchError: ${error.toString()}');
    });
  }

  Future<List<OrderResult>> getorder() async {
    companyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
    userId = await SharedPrefsData.getStringFromSharedPrefs("userId");

    final url = Uri.parse(
        'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Order/GetAppOrdersBySearch');
    final requestBody = {
      "PartyCode": viewOrdersProvider.getPartyCode,
      "StatusId": viewOrdersProvider.getApiStatusId,
      "FormDate": viewOrdersProvider.apiFromDate,
      "ToDate": viewOrdersProvider.apiToDate,
      "CompanyId": companyId,
      "UserId": userId,
      "WhsCode": viewOrdersProvider.apiWareHouse
    };

    debugPrint('_______view orders____1___${jsonEncode(requestBody)}');

    final response = await http.post(
      url,
      body: json.encode(requestBody),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['response']['listResult'] != null) {
        final List<dynamic> listResult = data['response']['listResult'];

        setState(() {
          orderesponselist =
              listResult.map((json) => OrderResult.fromJson(json)).toList();
          filterorderesponselist = List.from(orderesponselist);
        });

        if (filterorderesponselist.isEmpty) {
          // Display a message or set a variable to show a message in your UI.
        }

        return filterorderesponselist;
      } else {
        // Handle the case where "listResult" is null.
        // You can return an empty list or handle it based on your application's requirements.
        return [];
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  void filterOrderBasedOnProduct(String input) {
    apiData.then((data) {
      setState(() {
        viewOrdersProvider.storeIntoViewOrderProvider(data!
            .where((item) =>
            item.partyName.toLowerCase().contains(input.toLowerCase()))
            .toList());
      });
    });
  }

  void filterDealers() {
    final String searchTerm = searchController.text.toLowerCase();
    setState(() {
      filterorderesponselist = orderesponselist.where((dealer) {
        return dealer.partyName.toLowerCase().contains(searchTerm) ||
            dealer.partyGSTNumber.toLowerCase().contains(searchTerm);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ViewOrdersProvider>(
      builder: (context, ordersProvider, _) => Scaffold(
        appBar: _appBar(),
        body: FutureBuilder(
          future: apiData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator.adaptive());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error occurred: ${snapshot.error}'),
              );
            } else {
              List<OrderResult> data = ordersProvider.viewOrderProviderData;
              return WillPopScope(
                  onWillPop: () async {
                    // Clear the cart data here
                    viewOrdersProvider.clearFilter();
                    return true; // Allow the back navigation
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _viewOrdersSearchBarAndFilter(),
                        const SizedBox(
                          height: 10.0,
                        ),
                        if (ordersProvider.viewOrderProviderData.isNotEmpty)
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: data.length,
                              // Change this to the number of static items you want
                              itemBuilder: (context, index) {
                                String dateString = data[index].orderDate;
                                DateTime date = DateTime.parse(dateString);
                                String formattedDate =
                                DateFormat('dd MMM, yyyy').format(date);

                                return OrderCard(
                                    orderResult: data[index],
                                    formattedDate: formattedDate);
                              },
                            ),
                          )
                        else
                          const Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: Text(
                                      'No Orders found!',
                                      style: CommonUtils.Mediumtext_14_cb,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                      ],
                    ),
                  ));
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
                    // Handle the click event for the back button
                    viewOrdersProvider.clearFilter();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                    );
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
                'My Orders',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          FutureBuilder(
            future: getshareddata(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // Access the companyId after shared data is retrieved

                return GestureDetector(
                  onTap: () {
                    viewOrdersProvider.clearFilter();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                    );
                  },
                  child: Image.asset(
                    companyId == 1
                        ? 'assets/srikar-home-icon.png'
                        : 'assets/seeds-home-icon.png',
                    width: 30,
                    height: 30,
                  ),
                );
              } else {
                // Return a placeholder or loading indicator
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _viewOrdersSearchBarAndFilter() {
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
                onChanged: (input) => filterOrderBasedOnProduct(input),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(top: 10, left: 15),
                  hintText: 'Order Search',
                  hintStyle: CommonUtils.hintstyle_14,
                  suffixIcon: const Icon(Icons.search),
                  border: CommonUtils.searchBarOutPutInlineBorder,
                  focusedBorder:
                  CommonUtils.searchBarEnabledNdFocuedOutPutInlineBorder,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          GestureDetector(
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
            child: Container(
              height: 45,
              width: 45,
              decoration: viewOrdersProvider.filterStatus
                  ? CommonUtils.borderForAppliedFilter
                  : CommonUtils.borderForFilter,
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

  Future<void> getshareddata() async {
    companyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
  }
}

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  int selectedCardCode = -1;

  // ... Other variables and methods
  final _primaryOrange = const Color(0xFFe58338);
  int selectedChipIndex = 1;

  final _titleTextStyle = const TextStyle(
      color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold);

  final _clearTextStyle = const TextStyle(
      color: Color(0xFFe58338),
      fontSize: 16,
      decoration: TextDecoration.underline,
      decorationColor: Color(0xFFe58338));

  DateTime toDate = DateTime.now();
  DateTime fromDate = DateTime.now();
  String? selectedValue;

  List<dynamic> dropdownItems = [];
  // List<dynamic> partyInfo = [];
  late final partyInfo;
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
  String? userId = "";
  String? wareHouse;
  late ViewOrdersProvider viewOrdersProvider;
  late List<WareHouseList> wareHousesData = [];

  @override
  void initState() {
    super.initState();
    // todateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    // DateTime oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    // fromdateController.text = DateFormat('dd-MM-yyyy').format(oneWeekAgo);
    fetchData();
    getpaymentmethods();
    getWareHouses();
  }

  Future<void> getWareHouses() async {
    try {
      String apiUrl =
          'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Account/GetWarehousesByUserandCompany/e39536e2-89d3-4cc7-ae79-3dd5291ff156/1';
      // String apiUrl = '$baseUrl$GetWarehousesByUserandCompany$userId 1';
      final jsonResponse = await http.get(Uri.parse(apiUrl));
      if (jsonResponse.statusCode == 200) {
        Map<String, dynamic> response = jsonDecode(jsonResponse.body);
        if (response['response']['listResult'] != null) {
          List<dynamic> wareHouseList = response['response']['listResult'];

          debugPrint('wareHouseList: ${wareHouseList[0]['whsName']}');
          wareHousesData = wareHouseList
              .map((house) => WareHouseList.fromJson(house))
              .toList();
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    viewOrdersProvider = Provider.of<ViewOrdersProvider>(context);
    initializeFromAndToDates();
  }

  void initializeFromAndToDates() {
    fromdateController.text = viewOrdersProvider.displayFromDate;
    todateController.text = viewOrdersProvider.displayToDate;
  }

  Future<void> getpaymentmethods() async {
    final response = await http.get(Uri.parse(
        'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Master/GetAllTypeCdDmt/1'));

    if (response.statusCode == 200) {
      setState(() {
        apiResponse = ApiResponse.fromJson(jsonDecode(response.body));
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

    if (controller.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(controller.text);
      } catch (e) {
        initialDate = currentDate;
      }
    } else {
      initialDate = currentDate;
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
        viewOrdersProvider.setToDate = formattedDate;
        // Save selected dates as DateTime objects
        selectedDate = picked;

        //
        selectformattedtodate = DateFormat('yyyy-MM-dd').format(picked);
      }
    } catch (e) {}
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
        const SizedBox(
            height: 4.0), // Add space between labelText and TextFormField
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

    if (controller.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(controller.text);
      } catch (e) {
        initialDate = currentDate;
      }
    } else {
      initialDate = currentDate;
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
        viewOrdersProvider.setFromDate = formattedDate;
        // Save selected dates as DateTime objects
        selectedfromdateDate = picked;

        //
        //
        selectformattedfromdate = DateFormat('yyyy-MM-dd').format(picked);
      }
    } catch (e) {}
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
        const SizedBox(
            height: 4.0), // Add space between labelText and TextFormField
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
                        // initialValue: viewProvider.fromDateValue,
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
    final response = await http.get(Uri.parse(baseUrl +
        GetAllDealersBySlpCode +
        '$savedCompanyId' +
        "/" +
        '$slpCode'));

    //
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
    return Consumer<ViewOrdersProvider>(
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
                      decoration: CommonUtils.decorationO_R10W1,
                      child: TypeAheadField(
                        controller: provider.getPartyController,
                        builder: (context, controller, focusNode) => TextField(
                          controller: controller,
                          focusNode: focusNode,
                          autofocus: false,
                          style: CommonUtils.Mediumtext_12_0,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(top: 18, left: 15),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                // borderSide: BorderSide(color: Colors.grey),
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
                          final filteredSuggestions = dropdownItems
                              .where((party) => party['cardName']
                              .toLowerCase()
                              .startsWith(search.toLowerCase()))
                              .toList();

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
                          provider.getPartyController.text =
                          selectedValue['cardName'];
                          provider.getPartyCode = selectedValue['cardCode'];
                        },
                      ),

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
                      //
                      //
                      //           } else {
                      //
                      //
                      //
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
                    const SizedBox(
                      height: 10.0,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text(
                    'Ware House',
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
                      'Select WareHouse',
                      style: CommonUtils.txSty_13O_F6,
                    ),
                    value: provider.dropDownWareHouse,
                    onChanged: (String? newValue) {
                      setState(() {
                        provider.dropDownWareHouse = newValue;
                        WareHouseList house = wareHousesData
                            .firstWhere((item) => item.whsName == newValue);
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
                    itemCount: apiResponse!.listResult.length +
                        1, // Add 1 for the "All" option
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
                        currentPaymode = apiResponse!.listResult[
                        index - 1]; // Adjust index for actual data
                      }
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            provider.dropDownStatus = index;
                            selectedPaymode = currentPaymode;
                          });
                          payid = currentPaymode.typeCdId;
                          provider.getApiStatusId = currentPaymode.typeCdId;
                          Selected_PaymentMode = currentPaymode.desc;
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFe78337)
                                : const Color(0xFFe78337).withOpacity(0.1),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFe78337)
                                  : const Color(0xFFe78337),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: IntrinsicWidth(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        currentPaymode.desc.toString(),
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
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
                          getAppliedFilterData(context);
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

  Future<void> getAppliedFilterData(BuildContext context) async {
    viewOrdersProvider.filterStatus = true;
    userId = await SharedPrefsData.getStringFromSharedPrefs("userId");
    savedCompanyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
    DateTime todate = DateFormat('dd-MM-yyyy').parse(todateController.text);
    selectformattedtodate = DateFormat('yyyy-MM-dd').format(todate);

// Convert the fromdateController text to 'yyyy-MM-dd'
    DateTime pickedFromDate =
    DateFormat('dd-MM-yyyy').parse(fromdateController.text);
    selectformattedfromdate = DateFormat('yyyy-MM-dd').format(pickedFromDate);

    try {
      final url = Uri.parse(
          'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Order/GetAppOrdersBySearch');
      final requestBody = {
        "PartyCode": viewOrdersProvider.getPartyCode,
        "StatusId": viewOrdersProvider.getApiStatusId,
        "FormDate": viewOrdersProvider.apiFromDate,
        "ToDate": viewOrdersProvider.apiToDate,
        "CompanyId": savedCompanyId,
        "UserId": userId,
        "WhsCode": viewOrdersProvider.apiWareHouse
      };

      debugPrint('_______view orders____2___${jsonEncode(requestBody)}');

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
          List<dynamic>? data = jsonResponse['response']['listResult'];

          if (data != null) {
            List<OrderResult> result =
            data.map((item) => OrderResult.fromJson(item)).toList();
            viewOrdersProvider.storeIntoViewOrderProvider(result);
          } else {
            List<OrderResult> emptyList = [];
            viewOrdersProvider.storeIntoViewOrderProvider(emptyList);
            CommonUtils.showCustomToastMessageLong(
                'No Order found!', context, 2, 2);
          }
        } else {
          List<OrderResult> emptyList = [];
          viewOrdersProvider.storeIntoViewOrderProvider(emptyList);
          CommonUtils.showCustomToastMessageLong(
              'No Order found!', context, 2, 2);
        }
      } else {}
    } catch (e) {
      CommonUtils.showCustomToastMessageLong(
          'Something went wrong', context, 2, 2);
    }
    Navigator.of(context).pop();
  }
}

class Dealer {
  final String cardCode;
  final String cardName;

  Dealer({required this.cardCode, required this.cardName});
}

class OrderCard extends StatefulWidget {
  final OrderResult orderResult;
  final String formattedDate;
  const OrderCard({
    super.key,
    required this.orderResult,
    required this.formattedDate,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  final _boxBorder = BoxDecoration(
    borderRadius: BorderRadius.circular(5.0),
    color: Colors.white,
  );

  final _iconBoxBorder = BoxDecoration(
    borderRadius: BorderRadius.circular(5.0),
    color: Colors.white,
  );

  late ViewOrdersProvider viewOrdersProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    viewOrdersProvider = Provider.of<ViewOrdersProvider>(context);
  }

// start

  @override
  Widget build(BuildContext context) {
    // String dateString = widget.listResult.date;
    // DateTime date = DateTime.parse(dateString);
    // String formattedDate = DateFormat('dd MMM, yyyy').format(date);
    return GestureDetector(
      onTap: () {
        viewOrdersProvider.clearFilter();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Orderdetails(
              orderid: widget.orderResult.id,
              whsName: widget.orderResult.whsName,
              orderdate: widget.formattedDate,
              totalCostWithGST: widget.orderResult.totalCostWithGST,
              bookingplace: widget.orderResult.bookingPlace,
              transportmode: widget.orderResult.transportName,
              lrnumber: 1,
              lrdate: "",
              statusname: widget.orderResult.statusName,
              partyname: widget.orderResult.partyName,
              partycode: widget.orderResult.partyCode,
              proprietorName: widget.orderResult.proprietorName,
              partyGSTNumber: widget.orderResult.partyGSTNumber,
              ordernumber: widget.orderResult.orderNumber,
              partyAddress: widget.orderResult.partyAddress,
              statusBar: sendingSvgImagesAndColors(
                widget.orderResult.statusTypeId,
                widget.orderResult.statusName,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
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
                                child: getSvgImagesAndColors(
                                  widget.orderResult.statusTypeId,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5.0,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 3, horizontal: 7),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: statusBgColor,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.orderResult.statusName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: statusColor,
                                    // Add other text styles as needed
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // beside info
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10, top: 0, bottom: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.orderResult.partyName,
                                style: CommonUtils.Mediumtext_14_cb,
                                softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Order ID : ',
                                        style: CommonUtils.txSty_13B_Fb,
                                      ),
                                      Text(
                                        widget.orderResult.orderNumber
                                            .toString(),
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
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  widget.orderResult.whsName != null
                                      ? Text(
                                    '${widget.orderResult.whsName}',
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
                                        '${widget.orderResult.noOfItems}',
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
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  // Text(
                                  //   'whsCode', // '${widget.orderResult.noOfItems}', //
                                  //   style: CommonUtils.txSty_13O_F6,
                                  // ),
                                  Text(
                                    widget.formattedDate,
                                    style: CommonUtils.txSty_13O_F6,
                                  ),
                                  Text(
                                    '₹${formatNumber(widget.orderResult.totalCostWithGST)}',
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
                // const SizedBox(
                //   height: 5.0,
                // ),
                // Row(
                //   children: [
                //     Container(
                //       margin: const EdgeInsets.only(left: 5.0),
                //       padding: const EdgeInsets.symmetric(
                //           vertical: 3, horizontal: 7),
                //       decoration: BoxDecoration(
                //         borderRadius: BorderRadius.circular(10),
                //         color: statusBgColor,
                //       ),
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           Text(
                //             widget.orderResult.statusName,
                //             style: TextStyle(
                //               fontSize: 11,
                //               color: statusColor,
                //               // Add other text styles as needed
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //     const SizedBox(
                //       width: 10.0,
                //     ),
                //     const Expanded(
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.end,
                //         children: [
                //           Expanded(child: SizedBox()),
                //           // Row(
                //           //   children: [
                //           //     const Text(
                //           //       'No.of Items: ',
                //           //       style: CommonUtils.txSty_13B_Fb,
                //           //     ),
                //           //     Text(
                //           //       '${widget.orderResult.noOfItems}',
                //           //       style: CommonUtils.txSty_13O_F6,
                //           //     ),
                //           //   ],
                //           // )
                //           // Text(
                //           //   '₹${formatNumber(widget.orderResult.totalCostWithGST)}',
                //           //   style: CommonUtils.txSty_13O_F6,
                //           // ),
                //         ],
                //       ),
                //     ),
                //   ],
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }

  late Color statusColor;
  late Color statusBgColor;
  Widget getSvgImagesAndColors(int statusTypeCode) {
    String assetPath;
    late Color iconColor;
    switch (statusTypeCode) {
      case 1: // 'Pending'
        assetPath = 'assets/shipping-timed.svg';
        iconColor = const Color(0xFFE58338);
        statusColor = const Color(0xFFe58338);
        statusBgColor = const Color(0xFFe58338).withOpacity(0.2);
        break;
      case 2: // 'Shipped'
        assetPath = 'assets/shipping-fast.svg';
        iconColor = const Color(0xFF0d6efd);
        statusColor = const Color(0xFF0d6efd);
        statusBgColor = const Color(0xFF0d6efd).withOpacity(0.2);
        break;
      case 3: // 'Delivered'
        assetPath = 'assets/box-circle-check.svg';
        iconColor = Colors.green;
        statusColor = Colors.green;
        statusBgColor = Colors.green.withOpacity(0.2);
        break;
      case 10: // 'Partially Shipped'
        assetPath = 'assets/boxes.svg';
        iconColor = const Color(0xFF0dcaf0);
        statusColor = const Color(0xFF0dcaf0);
        statusBgColor = const Color(0xFF0dcaf0).withOpacity(0.2);
        break;
      case 11: // 'Accepted'
        assetPath = 'assets/shipping-timed.svg';
        iconColor = Colors.green;
        statusColor = Colors.green;
        statusBgColor = Colors.green.withOpacity(0.2);
        break;
      case 12: // 'Rejected'
        assetPath = 'assets/reject.svg';
        iconColor = HexColor('#C42121');
        statusColor = HexColor('#C42121');
        statusBgColor = HexColor('#C42121').withOpacity(0.2);
        break;
      case 14: // Received
        assetPath = 'assets/srikar_biotech_logo.svg';
        iconColor = Colors.grey;
        statusColor = Colors.grey;
        statusBgColor = Colors.grey.withOpacity(0.2);
        break;
      case 16: // 'Cancelled'
        assetPath = 'assets/order-cancel.svg';
        iconColor = HexColor('#dc3545');
        statusColor = HexColor('#dc3545');
        statusBgColor = HexColor('#dc3545').withOpacity(0.2);
        break;
      case 17: // 'SH Approval'
        assetPath = 'assets/memo-circle-check.svg';
        iconColor = HexColor('#039487');
        statusColor = HexColor('#039487');
        statusBgColor = HexColor('#039487').withOpacity(0.2);
        break;
      default:
        assetPath = 'assets/plus-small.svg';
        iconColor = Colors.black26;
        statusColor = Colors.black26;
        statusBgColor = Colors.black26.withOpacity(0.2);
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

  Widget sendingSvgImagesAndColors(int statusTypeId, String statusName) {
    String svgIcon;
    Color svgIconBgColor;

    switch (statusTypeId) {
      case 1: // 'Pending'
        svgIcon = 'assets/shipping-timed.svg';
        statusColor = const Color(0xFFe58338);
        svgIconBgColor = const Color(0xFFe58338).withOpacity(0.2);
        break;
      case 2: // 'Shipped'
        svgIcon = 'assets/shipping-fast.svg';
        statusColor = const Color(0xFF0d6efd);
        svgIconBgColor = const Color(0xFF0d6efd).withOpacity(0.2);
        break;
      case 3: // 'Delivered'
        svgIcon = 'assets/box-circle-check.svg';
        statusColor = Colors.green;
        svgIconBgColor = Colors.green.withOpacity(0.2);
        break;
      case 10: // 'Partially Shipped'
        svgIcon = 'assets/boxes.svg';
        statusColor = const Color(0xFF0dcaf0);
        svgIconBgColor = const Color(0xFF0dcaf0).withOpacity(0.2);
        break;
      case 11: // 'Accepted'
        svgIcon = 'assets/shipping-timed.svg';
        statusColor = Colors.green;
        svgIconBgColor = Colors.green.withOpacity(0.2);
        break;
      case 12: // 'Rejected'
        svgIcon = 'assets/reject.svg';
        statusColor = HexColor('#C42121');
        svgIconBgColor = HexColor('#C42121').withOpacity(0.2);
        break;
      case 16: // 'Cancelled'
        svgIcon = 'assets/order-cancel.svg';
        statusColor = HexColor('#dc3545');
        svgIconBgColor = HexColor('#dc3545').withOpacity(0.2);
        break;
      case 17: // 'SH Approval'
        svgIcon = 'assets/memo-circle-check.svg';
        statusColor = HexColor('#039487');
        svgIconBgColor = HexColor('#039487').withOpacity(0.2);
        break;
      default:
        svgIcon = 'assets/plus-small.svg';
        statusColor = Colors.black26;
        svgIconBgColor = Colors.black26.withOpacity(0.2);
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

  String formatNumber(double number) {
    NumberFormat formatter = NumberFormat("#,##,##,##,##,##,##0.00", "en_US");
    return formatter.format(number);
  }
}
