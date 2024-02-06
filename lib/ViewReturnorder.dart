import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:srikarbiotech/Common/CommonUtils.dart';
import 'package:srikarbiotech/Model/returnorders_model.dart';
import 'package:srikarbiotech/OrctResponse.dart';
import 'package:srikarbiotech/Payment_model.dart';
import 'package:srikarbiotech/viewreturnorders_provider.dart';

import 'HomeScreen.dart';
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
  final _borderforContainer = BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: HexColor('#e58338'),
      ));
  final List<String> orderStatusList = [
    'Shipped',
    'Pending',
    'Delivered',
    'Pending',
    'Rejected',
    'Shipped',
    'Delivered',
  ];
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
      print('Error initializing data: $error');
    });
  }

  Future<List<ReturnOrdersList>> getReturnOrderApi() async {
    final url = Uri.parse(
        'http://182.18.157.215/Srikar_Biotech_Dev/API/api/ReturnOrder/GetAppReturnOrdersBySearch');
    try {
      final requestBody = {
        "PartyCode": null,
        "StatusId": null,
        "FormDate": "2023-12-01",
        "ToDate": "2024-02-05",
        "CompanyId": 1
      };
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
          List<ReturnOrdersList> result =
          data.map((item) => ReturnOrdersList.fromJson(item)).toList();
          returnOrdersProvider.storeIntoReturnOrdersProvider(result);
          return result;
        } else {
          List<ReturnOrdersList> emptyList = [];
          returnOrdersProvider.storeIntoReturnOrdersProvider(emptyList);
          return emptyList;
        }
      } else {
        print(
            'Failed to send the request. Status code: ${response.statusCode}');
        throw Exception(
            'Failed to send the request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
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
    return Consumer<ViewReturnOrdersProvider>(
      builder: (context, viewReturnOrdersProvider, _) => Scaffold(
        appBar: _appBar(),
        body: FutureBuilder(
            future: apiData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator.adaptive());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error occurred: ${snapshot.error}'),
                );
              } else {
                if (snapshot.hasData) {
                  // List<ListResult> data = snapshot.data!;
                  List<ReturnOrdersList> data =
                      viewReturnOrdersProvider.returnOrdersProviderData;
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _searchBarAndFilter(),
                        if (viewReturnOrdersProvider
                            .returnOrdersProviderData.isNotEmpty)
                        // card items
                          Expanded(
                            child: ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                return ReturnCarditem(
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
                  );
                } else {
                  return const Center(
                    child: Text('No data available'),
                  );
                }
              }
            }),
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
                MaterialPageRoute(builder: (context) => HomeScreen()),
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
                onChanged: (input) =>
                    filterRecordsBasedOnPartyName(input), // search
                decoration: InputDecoration(
                  hintText: 'Order Search',
                  hintStyle: _hintTextStyle,
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
            decoration: _borderforContainer,
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => const FilterBottomSheet(), //here
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
                'No collection found!',
                style: CommonUtils.Mediumtext_14_cb,
              ),
            ),
          ],
        ),
      ),
    );
  }
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
    borderRadius: BorderRadius.circular(10),
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
      case 'Delivered':
        assetPath = 'assets/box-circle-check.svg';
        iconColor = Colors.green;
        statusColor = Colors.green;
        statusBgColor = Colors.green.shade100;
        break;
      case 'Partially Shipped':
        assetPath = 'assets/boxes.svg';
        iconColor = Colors.purple;
        statusColor = Colors.purple;
        statusBgColor = Colors.purple.shade100;
        break;
      case 'Rejected':
        assetPath = 'assets/shipping-timed.svg';
        iconColor = Colors.red;
        statusColor = Colors.red;
        statusBgColor = Colors.red.shade100;
        break;
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

  @override
  Widget build(BuildContext context) {
    String dateString = widget.data.lrDate;
    DateTime date = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd MMM, yyyy').format(date);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                ReturnOrderDetailsPage(orderId: widget.data.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Card(
          color: Colors.white,
          elevation: 5,
          child: Container(
            padding: const EdgeInsets.all(10), // here
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              // two part of row left icon and right info
              children: [
                SizedBox(
                  // part one
                  width: MediaQuery.of(context).size.width / 4.7,
                  child: Column(
                    children: [
                      // top card icon
                      Card(
                        elevation: 5,
                        child: Container(
                          //here
                          // height: 80,
                          // width: 75,
                          padding: const EdgeInsets.all(12),
                          decoration: _iconBoxBorder,
                          child: Center(
                            child: getSvgAsset(widget.data.statusName),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      // bottom status name
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 3, horizontal: 11),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: statusBgColor,
                        ),
                        child: Text(
                          widget.data.statusName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: statusColor),
                        ),
                      ),
                    ],
                  ),
                ),

                // part two
                Expanded(
                  child: Container(
                    height: 100,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.data.partyName,
                          style: CommonUtils.txSty_13B_Fb,
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Order ID :  ',
                                  style: CommonUtils.txSty_13B_Fb,
                                ),
                                Text(
                                  widget.data.returnOrderNumber,
                                  style: CommonUtils.txSty_13O_F6,
                                ),
                              ],
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
                            Row(
                              children: [
                                const Text(
                                  'No of items :  ',
                                  style: CommonUtils.txSty_13B_Fb,
                                ),
                                Text(
                                  widget.data.noOfItems.toString(),
                                  style: CommonUtils.txSty_13O_F6,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  // here
                                  formattedDate, //widget.data.lrDate.toString()
                                  style: CommonUtils.txSty_13O_F6,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  widget.data.totalCost.toString(),
                                  style: CommonUtils.txSty_13O_F6,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// here
class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final _labelTextStyle = const TextStyle(
      color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold);
  List<Dealer> dealers = [];
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
  List dropDownItems = [
    'item 1',
    'item 2',
    'item 3',
    'item 4',
    'item 5',
  ];
  List<dynamic> dropdownItems = [];
  PaymentMode? selectedPaymode;
  int? payid;
  late String selectedName;
  ApiResponse? apiResponse;
  int indexselected = -1;
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

  @override
  void initState() {
    fetchData();
    getpaymentmethods();
    fetchdropdownitems();
    super.initState();
  }

  Future<void> fetchdropdownitems() async {
    String apiUrl =
        'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Collections/GetPurposes/1';
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
        'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Master/GetAllTypeCdDmt/1'));

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

        // Save selected dates as DateTime objects
        selectedDate = picked;
        print("todate selected: $selectedDate");

        // Print formatted date
        print("fromatted todate: ${DateFormat('yyyy-MM-dd').format(picked)}");
        selectformattedtodate = DateFormat('yyyy-MM-dd').format(picked);
        print("selectformattedtodate: $selectformattedtodate");
      }
    } catch (e) {
      print("Error selecting date: $e");
      // Handle the error, e.g., show a message to the user or log it.
    }
  }

  Widget buildDateInput(
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
            style: const TextStyle(
              fontSize: 16.0,
              color: Color(0xFF5f5f5f),
              fontWeight: FontWeight.bold,
            ),
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
                      padding: const EdgeInsets.only(left: 10.0, top: 0.0),
                      child: TextFormField(
                        controller: controller,
                        enabled: false,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFe78337),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Select to date',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFe78337),
                          ),
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

        // Save selected dates as DateTime objects
        selectedfromdateDate = picked;
        print("fromdate selected: $selectedfromdateDate");

        // Print formatted date
        print("fromattedfromdate: ${DateFormat('yyyy-MM-dd').format(picked)}");
        selectformattedfromdate = DateFormat('yyyy-MM-dd').format(picked);
        print("selectformattedfromdate: $selectformattedfromdate");
      }
    } catch (e) {
      print("Error selecting date: $e");
      // Handle the error, e.g., show a message to the user or log it.
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
            style: const TextStyle(
              fontSize: 16.0,
              color: Color(0xFF5f5f5f),
              fontWeight: FontWeight.bold,
            ),
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
                      padding: const EdgeInsets.only(left: 10.0, top: 0.0),
                      child: TextFormField(
                        controller: controller,
                        enabled: false,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFe78337),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Select from date',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFe78337),
                          ),
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

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Account/GetAllDealersBySlpCode/1/100'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      if (data['isSuccess']) {
        // Check if 'listResult' key exists and is not null
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
    return SingleChildScrollView(
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
                  // Text('Clear all filters', style: _labelTextStyle,),
                  Text(
                    'Clear all filters',
                    style: _clearTextStyle,
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
                      style: _labelTextStyle,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 5.0, right: 0),
                    child: Container(
                      // width: double.infinity,
                      height: 40.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFe58338),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: ButtonTheme(
                          alignedDropdown: true,
                          child: DropdownButton<int>(
                              value: selectedCardCode,
                              iconSize: 20,
                              icon: null,
                              isExpanded: true,
                              underline: const SizedBox(),
                              style: const TextStyle(
                                color: Color(0xFFe58338),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  selectedCardCode = value!;
                                  if (selectedCardCode != -1) {
                                    selectedValue =
                                    dropdownItems[selectedCardCode]['cardCode'];
                                    selectedName =
                                    dropdownItems[selectedCardCode]['cardName'];

                                    print("selectedValue:$selectedValue");
                                  } else {
                                    print(selectedValue);
                                    print(selectedName);
                                  }
                                  // isDropdownValid = selectedTypeCdId != -1;
                                });
                              },
                              items: [
                                const DropdownMenuItem<int>(
                                  value: -1,
                                  child: Text('Select Party'), // Static text
                                ),
                                ...dropdownItems.asMap().entries.map((entry) {
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
                              ]),
                        ),
                      ),
                    ),
                  ),
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
                    bool isSelected = index == indexselected;
                    PaymentMode currentPaymode;

                    // Handle the "All" option
                    if (index == 0) {
                      currentPaymode = PaymentMode(
                        // Provide default values or handle the null case as needed
                        typeCdId: 1, // typeCdId: null,
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
                          indexselected = index;
                          selectedPaymode = currentPaymode;
                        });
                        payid = currentPaymode.typeCdId;
                        selectedPaymentMode = currentPaymode.desc;
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
                  buildDateInput(
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
        ));
  }

  late ViewReturnOrdersProvider viewReturnOrdersProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    viewReturnOrdersProvider = Provider.of<ViewReturnOrdersProvider>(context);
  }

  Future<void> getappliedfilterData(BuildContext context) async {
    print('filter called');
    final url = Uri.parse(
        'http://182.18.157.215/Srikar_Biotech_Dev/API/api/ReturnOrder/GetAppReturnOrdersBySearch');
    try {
      final requestBody = {
        "PartyCode": selectedValue,
        "StatusId": payid,
        "FormDate": selectformattedfromdate,
        "ToDate": selectformattedtodate,
        "CompanyId": 1
      };

      print('PartyCode : $selectedValue');
      print('StatusId : $payid');
      print('FormDate : $selectformattedfromdate');
      print('ToDate : $selectformattedtodate');
      print('CompanyId : $savedCompanyId');

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
          List<ReturnOrdersList> result =
          data.map((item) => ReturnOrdersList.fromJson(item)).toList();
          viewReturnOrdersProvider.storeIntoReturnOrdersProvider(result);
          print('response is successs');
        } else {
          List<ReturnOrdersList> emptyList = [];
          viewReturnOrdersProvider.storeIntoReturnOrdersProvider(emptyList);
          print('response is unsuccesss');
        }
      } else {
        print(
            'Failed to send the request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    Navigator.of(context).pop();
  }
}
