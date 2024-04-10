// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:srikarbiotech/Common/CommonUtils.dart';
import 'package:srikarbiotech/Common/SharedPrefsData.dart';
import 'package:srikarbiotech/Common/styles.dart';
import 'package:srikarbiotech/Model/returnorders_model.dart';
import 'package:srikarbiotech/OrctResponse.dart';
import 'package:srikarbiotech/Payment_model.dart';
import 'package:srikarbiotech/Services/api_config.dart';
import 'package:srikarbiotech/viewreturnorders_provider.dart';

import 'HomeScreen.dart';
import 'Model/warehouse_model.dart';
import 'ReturnOrderDetailsPage.dart';

class ViewReturnorder extends StatefulWidget {
  const ViewReturnorder({super.key});

  @override
  State<ViewReturnorder> createState() => _MyReturnOrdersPageState();
}

class _MyReturnOrdersPageState extends State<ViewReturnorder> {
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
      debugPrint('_______Return Orders____1___${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['isSuccess']) {
          List<dynamic>? data = jsonResponse['response']['listResult'];
          if (data != null) {
            List<ReturnOrdersList> result =
            data.map((item) => ReturnOrdersList.fromJson(item)).toList();
            returnOrdersProvider.storeIntoReturnOrdersProvider(result);
            return result;
          } else {
            throw Exception('No collection found');
          }
        } else {
          List<ReturnOrdersList> emptyList = [];
          returnOrdersProvider.storeIntoReturnOrdersProvider(emptyList);
          return emptyList;
        }
      } else {
        debugPrint(
            'Failed to send the request. Status code: ${response.statusCode}');
        throw Exception(
            'Failed to send the request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  filterRecordsBasedOnPartyName(String input) {
    apiData.then((data) {
      setState(() {
        returnOrdersProvider.storeIntoReturnOrdersProvider(data
            .where((item) =>
            item.partyName.toLowerCase().contains(input.toLowerCase()))
            .toList());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        // Disable the back button functionality
        returnOrdersProvider.clearFilter();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        return true;
      },
      child: Consumer<ViewReturnOrdersProvider>(
        builder: (context, viewReturnOrdersProvider, _) => Scaffold(
          appBar: _appBar(),
          body: FutureBuilder(
            future: apiData,
            builder: (context, snapshot) {
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _searchBarAndFilter(),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Expanded(
                        child: Center(child: CommonStyles.progressIndicator),
                      )
                    else if (snapshot.hasError)
                      Expanded(
                        child: Center(
                          child: Text(
                            CommonUtils.extractExceptionMessage(
                                snapshot.error.toString()),
                            style: CommonStyles.txSty_12b_fb,
                          ),
                        ),
                      )
                    else if (snapshot.hasData)
                        Expanded(
                          child: ListView.builder(
                            itemCount: viewReturnOrdersProvider
                                .returnOrdersProviderData.length,
                            itemBuilder: (context, index) {
                              return ReturnCarditem(
                                index: index,
                                data: viewReturnOrdersProvider
                                    .returnOrdersProviderData[index],
                              );
                            },
                          ),
                        )
                      else
                        const Center(
                          child: Text(
                            'No data available',
                            style: CommonStyles.txSty_12b_fb,
                          ),
                        ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: CommonStyles.orangeColor,
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
                'My Return Orders',
                style: CommonStyles.txSty_18w_fb,
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
                    returnOrdersProvider.clearFilter();
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
                  hintStyle: CommonStyles.txSty_14bs_fb,
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
          Container(
            height: 45,
            width: 45,
            decoration: returnOrdersProvider.filterStatus
                ? CommonUtils.borderForAppliedFilter
                : CommonUtils.borderForFilter,
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
                  color: CommonStyles.orangeColor,
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
                style: CommonStyles.txSty_12b_fb,
              ),
            ),
          ],
        ),
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

  DateTime toDate = DateTime.now();
  DateTime fromDate = DateTime.now();
  String? selectedValue;

  List<dynamic> dropdownItems = [];
  PaymentMode? selectedPaymode;
  int? payid;
  late String selectedName;
  ApiResponse? apiResponse;
  String? selectedPaymentMode = "";
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
    try {
      final response = await http.get(Uri.parse(apiurl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final listResult = data['response']['listResult'] as List;

        setState(() {
          purposeList =
              listResult.map((item) => Purpose.fromJson(item)).toList();
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('catch: $e');
    }
  }

  Future<void> getpaymentmethods() async {
    String apiurl = baseUrl + GetTypeCdmt4;
    final response = await http.get(Uri.parse(apiurl));

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
        firstDate: selectedfromdateDate,
        lastDate: DateTime(2101),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary:
                CommonStyles.orangeColor, // Change the primary color here
                onPrimary: Colors.white,
                // onSurface: Colors.blue,// Change the text color here
              ),
              dialogBackgroundColor:
              Colors.white, // Change the dialog background color here
            ),
            child: child!,
          );
        },
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
      throw Exception('catch: $e');
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
            style: CommonStyles.txSty_14b_fb,
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
                color: CommonStyles.orangeColor,
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
                        style: CommonStyles.txSty_12o_f7,
                        decoration: InputDecoration(
                          hintText: labelText,
                          hintStyle: CommonStyles.txSty_12o_f7,
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
                      color: CommonStyles.orangeColor,
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
        initialDate = DateFormat('dd-MM-yyyy').parse(controller.text);
      } catch (e) {
        initialDate = DateTime.now();
      }
    } else {
      initialDate = DateTime.now();
    }

    try {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        firstDate: DateTime(2000),
        lastDate: currentDate,
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: CommonStyles.orangeColor,
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
        controller.text = formattedDate;
        viewReturnOrdersProvider.setFromDate = formattedDate;
        selectedfromdateDate = picked;

        selectformattedfromdate = DateFormat('yyyy-MM-dd').format(picked);
      }
    } catch (e) {
      print("Error selecting date: $e");
      throw Exception('catch: $e');
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
            style: CommonStyles.txSty_14b_fb,
            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(height: 4.0),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 40.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: CommonStyles.orangeColor,
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
                        style: CommonStyles.txSty_12o_f7,
                        decoration: InputDecoration(
                          hintText: labelText,
                          hintStyle: CommonStyles.txSty_12o_f7,
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
                      color: CommonStyles.orangeColor,
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
                    const Text(
                      'Filter By',
                      style: CommonStyles.txSty_14b_fb,
                    ),
                    GestureDetector(
                      onTap: () {
                        provider.clearFilter();
                      },
                      child: const Text(
                        'Clear all filters',
                        style: CommonStyles.txSty_14o_f7,
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
                    const Padding(
                      padding: EdgeInsets.only(left: 5.0),
                      child: Text(
                        'Party',
                        style: CommonStyles.txSty_14b_fb,
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
                          style: CommonStyles.txSty_14b_fb,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              hintText: 'Select Party',
                              hintStyle: CommonStyles.txSty_12o_f7),
                        ),
                        itemBuilder: (context, value) {
                          return ListTile(
                            dense: true,
                            title: Text(
                              '${isPartyCodeIsEmpty ? value : value['cardName']}',
                              style: CommonStyles.txSty_12o_f7,
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
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 5.0, top: 5.0),
                  child: Text(
                    'Warehouse',
                    style: CommonStyles.txSty_14b_fb,
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
                    color: CommonStyles.orangeColor,
                    size: 40.0,
                  )
                      : DropdownButton<String>(
                    focusColor: Colors.transparent,
                    hint: const Text(
                      'Select Warehouse',
                      style: CommonStyles.txSty_12o_f7,
                    ),
                    value: provider.dropDownWareHouse,
                    onChanged: (String? newValue) {
                      setState(() {
                        provider.dropDownWareHouse = newValue;
                        WareHouseList house = wareHousesData
                            .firstWhere((item) => item.whsName == newValue);
                        provider.apiWareHouse = house.whsCode;
                      });
                    },
                    items: wareHousesData.map((WareHouseList warehouse) {
                      return DropdownMenuItem<String>(
                        value: warehouse.whsName,
                        child: Text(
                          warehouse.whsName,
                          style: CommonStyles.txSty_12o_f7,
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
                      ? const Center(child: CommonStyles.progressIndicator)
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
                        currentPaymode = apiResponse!.listResult[index - 1];
                      }
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            provider.dropDownStatus = index;
                            selectedPaymode = currentPaymode;
                          });
                          payid = currentPaymode.typeCdId;
                          provider.getApiStatusId = currentPaymode.typeCdId;
                          selectedPaymentMode = currentPaymode.desc;
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? CommonStyles.orangeColor
                                : CommonStyles.orangeColor.withOpacity(0.1),
                            border: Border.all(
                              color: isSelected
                                  ? CommonStyles.orangeColor
                                  : CommonStyles.orangeColor,
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
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Roboto",
                                          color: isSelected
                                              ? CommonStyles.whiteColor
                                              : CommonStyles.blackColor,
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
                          style: CommonStyles.txSty_14r_fb,
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
                          style: CommonStyles.txSty_14w_fb,
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
            List<ReturnOrdersList> result =
            data.map((item) => ReturnOrdersList.fromJson(item)).toList();
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
        debugPrint(
            'Failed to send the request. Status code: ${response.statusCode}');
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
      String apiUrl = "$baseUrl$GetWarehouse$userId/$companyId";
      //  String apiUrl = "http://182.18.157.215/Srikar_Biotech_Dev/API/api/Account/GetWarehousesByUserandCompany/$userId/$companyId";
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
//     selectedPaymentMode = null;

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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
                      Expanded(
                        child: Padding(
                          padding:
                          const EdgeInsets.only(left: 5, top: 0, bottom: 0),
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
                                children: [
                                  const Text(
                                    'Order ID : ',
                                    style: CommonStyles.txSty_12b_fb,
                                  ),
                                  Text(
                                    widget.data.returnOrderNumber,
                                    style: CommonStyles.txSty_12o_f7,
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
                                  widget.data.whsName != null
                                      ? Text(
                                    '${widget.data.whsName}',
                                    style: CommonStyles.txSty_12o_f7,
                                  )
                                      : const SizedBox(),
                                  // Text(
                                  //   '${widget.orderResult.whsName}',
                                  //   style: CommonStyles.txSty_14b_fb,
                                  // ),
                                  Row(
                                    children: [
                                      const Text(
                                        'No.of Items: ',
                                        style: CommonStyles.txSty_12b_fb,
                                      ),
                                      Text(
                                        '${widget.data.noOfItems}',
                                        style: CommonStyles.txSty_12o_f7,
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
                                    style: CommonStyles.txSty_12b_fb,
                                  ),
                                  Text(
                                    widget.data.lrNumber,
                                    style: CommonStyles.txSty_12o_f7,
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 8),
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
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                              color: statusColor,
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
                              Row(
                                children: [
                                  Text(
                                    formattedDate,
                                    style: CommonStyles.txSty_12b_fb,
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
