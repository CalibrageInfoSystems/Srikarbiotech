// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:srikarbiotech/Common/CommonUtils.dart';

import 'package:srikarbiotech/view_collection_checkout.dart';

import 'Common/SharedPrefsData.dart';
import 'HomeScreen.dart';
import 'Model/card_collection.dart';
import 'OrctResponse.dart';
import 'Payment_model.dart';
import 'Services/api_config.dart';
import 'ViewCollectionProvider.dart';

class ViewCollectionPage extends StatefulWidget {
  const ViewCollectionPage({super.key});

  @override
  State<ViewCollectionPage> createState() => _ViewCollectionPageState();
}

class _ViewCollectionPageState extends State<ViewCollectionPage> {
  // String url = 'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Collections/GetCollections/null';

  final _orangeColor = HexColor('#e58338');
  final _borderForFilter = BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: HexColor('#e58338'),
      ));

  final _borderForAppliedFilter = BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: const Color.fromARGB(255, 250, 214, 152),
      border: Border.all(
        color: HexColor('#e58338'),
      ));

  final _hintTextStyle = const TextStyle(
      fontSize: 14, color: Colors.black38, fontWeight: FontWeight.bold);

  final _customTextStyle = const TextStyle(
      fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold);
  final _searchBarOutPutInlineBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Colors.black38),
  );
  final _searchBarEnabledNdFocuedOutPutInlineBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Colors.black),
  );

  late Future<List<ListResult>> apiData;
  List<ListResult> filteredData = [];
  late ViewCollectionProvider viewProvider;
  int CompneyId = 0;
  String? slpCode = "";
  String? userId = "";

  @override
  void initState() {
    super.initState();
    getshareddata();
    initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    viewProvider = Provider.of<ViewCollectionProvider>(context);
  }

  void filterRecordsBasedOnPartyName(String input) {
    apiData.then((data) {
      setState(() {
        viewProvider.storeIntoProvider(data
            .where((item) =>
            item.partyName.toLowerCase().contains(input.toLowerCase()))
            .toList());
      });
    });
  }

  Future<List<ListResult>> getCollection() async {
    userId = await SharedPrefsData.getStringFromSharedPrefs("userId");
    CompneyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
    DateTime currentDate = DateTime.now();
    DateTime oneWeekBackDate = currentDate.subtract(const Duration(days: 7));
    String formattedCurrentDate = DateFormat('yyyy-MM-dd').format(currentDate);
    String formattedOneWeekBackDate =
    DateFormat('yyyy-MM-dd').format(oneWeekBackDate);

    try {
      final url = Uri.parse(
          'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Collections/GetCollectionsbyMobileSearch');
      final requestBodyObj = {
        "PurposeName": null,
        "StatusId": null,
        "PartyCode": null,
        "FormDate": formattedOneWeekBackDate,
        "ToDate": formattedCurrentDate,
        "CompanyId": CompneyId,
        "UserId": userId
      };
      print('===========>${jsonEncode(requestBodyObj)}');
      final response = await http.post(
        url,
        body: json.encode(requestBodyObj),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);

        if (json['response']['listResult'] != null) {
          List<dynamic> listResult = json['response']['listResult'];
          List<ListResult> result = listResult
              .map((element) => ListResult.fromJson(element))
              .toList();
          return result;
        } else {
          print('listResult is null.');
          // Handle the case where "listResult" is null.
          // You can return an empty list or handle it based on your application's requirements.
          return [];
        }
      } else {
        throw Exception('Error occurred');
      }
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ViewCollectionProvider>(
      builder: (context, viewCollectionProvider, _) => Scaffold(
        appBar: _viewCollectionAppBar(),
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
              if (snapshot.hasData) {
                // List<ListResult> data = snapshot.data!;
                List<ListResult> data = viewCollectionProvider.providerData;
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // search bar
                      _searchBarAndFilter(),

                      // list of cards
                      if (viewCollectionProvider.providerData.isNotEmpty)
                        Expanded(
                          child: ListView.builder(
                            itemCount: data.length,
                            itemBuilder: ((context, index) {
                              return MyCard(
                                  listResult: data[index], index: index);
                            }),
                          ),
                        )
                      // no results
                      else
                        Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      'No collection found!',
                                      style: _customTextStyle,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                    ],
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

  AppBar _viewCollectionAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFe78337),
      automaticallyImplyLeading: false,
      // This line removes the default back arrow
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                child: GestureDetector(
                  onTap: () {
                    // call clear filter method to clear the data
                    viewProvider.clearFilter();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
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
                'View Collection',
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
                    // Handle the click event for the home icon
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                  child: Image.asset(
                    CompneyId == 1
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
                onChanged: (input) => filterRecordsBasedOnPartyName(input),
                decoration: InputDecoration(
                  hintText: 'Collection Search',
                  hintStyle: _hintTextStyle,
                  suffixIcon: const Icon(Icons.search),
                  border: _searchBarOutPutInlineBorder,
                  focusedBorder: _searchBarEnabledNdFocuedOutPutInlineBorder,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () {
              // Handle the click action here
              showModalBottomSheet(
                context: context,
                builder: (context) => const FilterBottomSheet(),
              );
              // Add your specific logic or navigation here
            },
            child: Container(
              height: 45,
              width: 45,
              decoration: viewProvider.filterStatus
                  ? _borderForAppliedFilter
                  : _borderForFilter,
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
    CompneyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
    userId = await SharedPrefsData.getStringFromSharedPrefs("userId");

    print('Company ID: $CompneyId');
  }

  void initializeData() {
    apiData = getCollection();
    apiData.then((data) {
      setState(() {
        filteredData.addAll(data);
        viewProvider.storeIntoProvider(data);
      });
    }).catchError((error) {
      // print('Error initializing data: $error');
    });
  }
}

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

// X000
class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final _labelTextStyle = const TextStyle(
      color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold);
  // List<Dealer> dealers = [];
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
  @override
  void initState() {
    // todateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    // DateTime oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    // fromdateController.text = DateFormat('dd-MM-yyyy').format(oneWeekAgo);
    fetchData();
    getpaymentmethods();
    fetchdropdownitems();
    super.initState();
  }

  late ViewCollectionProvider viewProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    viewProvider = Provider.of<ViewCollectionProvider>(context);
    initializeFromAndToDates();
  }

  void initializeFromAndToDates() {
    fromdateController.text = viewProvider.fromDateValue;
    todateController.text = viewProvider.toDateValue;
  }

  Future<void> fetchdropdownitems() async {
    savedCompanyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
    final apiUrl =
        'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Collections/GetPurposes/'
        '$savedCompanyId';

    try {
      final response = await http.get(Uri.parse(apiUrl));

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
      print('Error: $e');
    }
  }

  Future<void> getpaymentmethods() async {
    final response = await http.get(Uri.parse(
        'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Master/GetAllTypeCdDmt/3'));

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

    if (controller.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(controller.text);
      } catch (e) {
        print("Invalid date format: $e");
        initialDate = currentDate;
      }
    } else {
      initialDate = currentDate;
    }

    try {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (picked != null) {
        String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
        controller.text = formattedDate;
        viewProvider.toDateValue = formattedDate;
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
      print('###########controller.text: ${controller.text}');
      try {
        initialDate = DateTime.parse(controller.text);
      } catch (e) {
        print("Invalid date format: $e");
        initialDate = currentDate;
      }
    } else {
      initialDate = currentDate;
    }

    try {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (picked != null) {
        String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
        controller.text = formattedDate;
        viewProvider.fromDateValue = formattedDate;
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ViewCollectionProvider>(
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
                   //todo
                decoration: CommonUtils.decorationO_R10W1,
                      child: DropdownButtonHideUnderline(
                        child: ButtonTheme(
                          alignedDropdown: true,
                          child: DropdownButton<int>(
                            hint: Text(
                              'Select Party',
                              style: CommonUtils.txSty_13O_F6,
                            ),
                            value: provider.dropDownParty,
                            onChanged: (int? value) {
                              setState(() {
                                selectedCardCode = value!;
                                provider.dropDownParty = value;
                                if (selectedCardCode != -1) {
                                  selectedValue =
                                  dropdownItems[selectedCardCode]['cardCode'];
                                  selectedName =
                                  dropdownItems[selectedCardCode]['cardName'];
                                  provider.getApiPartyCode =
                                  dropdownItems[selectedCardCode]['cardCode'];
                                  print("selectedValue:$selectedValue");
                                  print("selectedName:$selectedName");
                                } else {
                                  print("==========");
                                  print(selectedValue);
                                  print(selectedName);
                                }
                                // isDropdownValid = selectedTypeCdId != -1;
                              });
                            },
                            items: dropdownItems.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              return DropdownMenuItem<int>(
                                  value: index,
                                  child: Text(
                                    item['cardName'],
                                    overflow: TextOverflow.visible,
                                    // wrapText: true,
                                  ));
                            }).toList(),
                            iconSize: 20,
                            icon: null,
                            isExpanded: true,
                            underline: const SizedBox(),
                            style: const TextStyle(
                              color: Color(0xFFe58338),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(
                        'Purpose',
                        style: CommonUtils.txSty_13O_F6,
                      ),
                    ),
                    const SizedBox(
                      height: 4.0,
                    ),
                    Container(
                        height: 40.0,
                        padding: const EdgeInsets.only(left: 15, right: 5),
                      //TODO
                     decoration: CommonUtils.decorationO_R10W1,
                        child: purposeList.isEmpty
                            ? LoadingAnimationWidget.newtonCradle(
                          color: Colors.blue,
                          size: 40.0,
                        )
                            : DropdownButton<String>(
                          hint: Text(
                            'Select Purpose', // Purpose
                            style: CommonUtils.txSty_13O_F6,
                          ),
                          value: provider.dropDownPurpose,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedPurpose = newValue;
                              provider.dropDownPurpose = newValue;
                              selectedPurposeObj = purposeList.firstWhere(
                                    (purpose) => purpose.fldValue == newValue,
                                orElse: () => Purpose(
                                    fldValue: '', descr: '', purposeName: ''),
                              );
                              purposename = selectedPurposeObj!.fldValue;
                              provider.getApiPurpose = newValue;
                            });
                          },
                          items: purposeList.map((Purpose purpose) {
                            return DropdownMenuItem<String>(
                              value: purpose.fldValue,
                              child: Text(
                                purpose.purposeName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFe78337),
                                ),
                              ),
                            );
                          }).toList(),
                          icon: const Icon(Icons.arrow_drop_down),
                          iconSize: 20,
                          isExpanded: true,
                          underline: const SizedBox(),
                        ))
                  ],
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
                          //apply
                          getappliedflitters(context);
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

// x000
  Future<void> getappliedflitters(BuildContext context) async {
    print('_____________getappliedflitters___________');
    viewProvider.filterStatus = true;

    int companyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
    String userId = await SharedPrefsData.getStringFromSharedPrefs("userId");
    DateTime todate = DateFormat('dd-MM-yyyy').parse(todateController.text);
    selectformattedtodate = DateFormat('yyyy-MM-dd').format(todate);

// Convert the fromdateController text to 'yyyy-MM-dd'
    DateTime pickedFromDate =
    DateFormat('dd-MM-yyyy').parse(fromdateController.text);
    selectformattedfromdate = DateFormat('yyyy-MM-dd').format(pickedFromDate);
    print('Converted to date: $selectformattedtodate');
    print('Converted from date: $selectformattedfromdate');
    try {
      final url = Uri.parse(
          'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Collections/GetCollectionsbyMobileSearch');
      final requestBodyObj = {
        "PurposeName": viewProvider.getApiPurpose,
        "StatusId": viewProvider.getApiStatusId,
        "PartyCode": viewProvider.getApiPartyCode,
        "FormDate": selectformattedfromdate,
        "ToDate": selectformattedtodate,
        "CompanyId": companyId,
        "UserId": userId
      };
      print('###########${jsonEncode(requestBodyObj)}');
      final response = await http.post(
        url,
        body: json.encode(requestBodyObj),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['isSuccess']) {
          List<dynamic>? data = jsonResponse['response']['listResult'];

          if (data != null) {
            List<ListResult> result =
            data.map((item) => ListResult.fromJson(item)).toList();
            viewProvider.storeIntoProvider(result);
          } else {
            print('listResult is null');
            List<ListResult> emptyList = [];
            viewProvider.storeIntoProvider(emptyList);
            CommonUtils.showCustomToastMessageLong(
                'No collection found!', context, 2, 2);
          }
        } else {
          print('Request failed: ${jsonResponse['endUserMessage']}');
          List<ListResult> emptyList = [];
          viewProvider.storeIntoProvider(emptyList);
          CommonUtils.showCustomToastMessageLong(
              'No collection found!', context, 2, 2);
        }
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      CommonUtils.showCustomToastMessageLong(
          'Something went wrong', context, 2, 2);
    }
    Navigator.of(context).pop();
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

class MyCard extends StatefulWidget {
  final ListResult listResult;
  final int index;

  const MyCard({
    Key? key,
    required this.listResult,
    required this.index,
  }) : super(key: key);

  @override
  State<MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  final _boxBorder = BoxDecoration(
    borderRadius: BorderRadius.circular(5.0),
    color: Colors.white,
  );

  final _iconBoxBorder = BoxDecoration(
    borderRadius: BorderRadius.circular(5.0),
    color: Colors.white,
  );

  final _textStyle = const TextStyle(
      fontFamily: 'Roboto',
      fontSize: 13,
      color: Colors.black,
      fontWeight: FontWeight.bold);

  final _orangeTextStyle = TextStyle(
      fontFamily: 'Roboto',
      fontSize: 13,
      color: HexColor('#e58338'),
      fontWeight: FontWeight.w600);
  late ViewCollectionProvider viewProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    viewProvider = Provider.of<ViewCollectionProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    String dateString = widget.listResult.date;
    DateTime date = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd MMM, yyyy').format(date);
    return GestureDetector(
      onTap: () {
        viewProvider.clearFilter();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ViewCollectionCheckOut(
              listResult: widget.listResult,
              position: widget.index, // Assuming you have the index available
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
            padding:
            // const EdgeInsets.only(left: 12, right: 5, top: 12, bottom: 12),
            const EdgeInsets.all(12),
            //   width: double.infinity,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  // height: 70,
                  // width: double.infinity,
                  // margin: const EdgeInsets.only(bottom: 12),
                  width: MediaQuery.of(context).size.width,
                  decoration: _boxBorder,
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
                          width: 60,
                          padding: const EdgeInsets.all(10),
                          decoration: _iconBoxBorder,
                          child: Center(
                            child: getStatusTypeImage(
                                widget.listResult.statusTypeId),
                          ),
                        ),
                      ),

                      // beside info
                      SizedBox(
                        //height: 90,
                        // width: ,
                        width: MediaQuery.of(context).size.width / 1.6,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10, top: 0, bottom: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // here
                              Text(
                                widget.listResult.partyName,
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
                                      Text(
                                        'Purpose: ',
                                        style: _textStyle,
                                      ),
                                      Text(
                                        widget.listResult.purposeName,
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
                                children: [
                                  Text(
                                    'Payment Mode: ',
                                    style: _textStyle,
                                  ),
                                  Text(
                                    widget.listResult.paymentTypeName,
                                    style: CommonUtils.txSty_13O_F6,
                                  ),
                                ],
                              )
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
                //bottom date and amount in card
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Container(
                    //   height: 30,
                    //   width: 65,
                    //   decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(10),
                    //       color: HexColor('#e58338').withOpacity(0.1)),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       Text(
                    //         widget.listResult.statusName,
                    //         style: CommonUtils.,
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    // 202
                    Container(
                      width: 65,
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: getStatusTypeBackgroundColor(
                            widget.listResult.statusTypeId),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.listResult.statusName,
                            style: TextStyle(
                              fontSize: 12,
                              color: getStatusTypeTextColor(
                                  widget.listResult.statusTypeId),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // Text(
                              //   'Date: ',
                              //   style: _textStyle,
                              // ),
                              Text(
                                formattedDate,
                                style: CommonUtils.txSty_13O_F6,
                              ),
                            ],
                          ),
                          // const SizedBox(
                          //   width: 10.0,
                          // ),
                          //Spacer(),
                          Row(
                            children: [
                              Icon(
                                Icons.currency_rupee,
                                size: 12,
                                color: HexColor('#e58338'),
                              ),
                              Text(
                                '${widget.listResult.amount}',
                                style: CommonUtils.txSty_13O_F6,
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

  Color getStatusTypeBackgroundColor(int statusTypeId) {
    switch (statusTypeId) {
      case 7:
        return Colors.green.withOpacity(0.1);
      case 8:
      // Set background color for statusTypeId 8
        return const Color(0xFFE58338).withOpacity(0.1);
      case 9:
      // Set background color for statusTypeId 9
        return Colors.red.withOpacity(0.1);
    // Add more cases as needed for other statusTypeId values

      default:
      // Default background color or handle other cases if needed
        return Colors.white;
    }
  }

  Color getStatusTypeTextColor(int statusTypeId) {
    switch (statusTypeId) {
      case 7:
        return Colors.green;
      case 8:
      // Set text color for statusTypeId 8
        return const Color(0xFFE58338);
      case 9:
      // Set text color for statusTypeId 9
        return Colors.red;
    // Add more cases as needed for other statusTypeId values

      default:
      // Default text color or handle other cases if needed
        return Colors.black;
    }
  }

  Widget getStatusTypeImage(int statusTypeId) {
    String assetPath;
    late Color iconColor;

    switch (statusTypeId) {
      case 7:
        assetPath = 'assets/hourglass-start.svg';
        iconColor = const Color.fromARGB(255, 0, 146, 5);
        break;
      case 8:
        assetPath = 'assets/sb_money-bill-wave.svg';
        iconColor = const Color(0xFFE58338); // Color for statusTypeId 8

        // Set color filter or other customization as needed
        break;
      case 9:
        assetPath = 'assets/sensor-alert.svg';
        iconColor = Colors.red;
        // Set color filter or other customization as needed
        break;
    // Add more cases as needed for other statusTypeId values

      default:
        assetPath = 'assets/sb_home.svg';
    // Set default image or handle other cases if needed
    }

    return SvgPicture.asset(
      assetPath,
      width: 50,
      height: 50,
      color: iconColor,
    );
  }
}
