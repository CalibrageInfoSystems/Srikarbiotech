import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:srikarbiotech/Common/styles.dart';
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

    String apiUrl = baseUrl + GetAppOrder;
    final url = Uri.parse(apiUrl);
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

        if (filterorderesponselist.isEmpty) {}

        return filterorderesponselist;
      } else {
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
    return WillPopScope(
      onWillPop: () async {
        viewOrdersProvider.clearFilter();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        return true;
      },
      child: Consumer<ViewOrdersProvider>(
        builder: (context, ordersProvider, _) => Scaffold(
          appBar: _appBar(),
          body: FutureBuilder(
            future: apiData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CommonStyles.progressIndicator);
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    CommonUtils.extractExceptionMessage(
                        snapshot.error.toString()),
                    style: CommonStyles.txSty_12b_fb,
                  ),
                );
              } else {
                List<OrderResult> data = ordersProvider.viewOrderProviderData;
                return WillPopScope(
                  onWillPop: () async {
                    viewOrdersProvider.clearFilter();
                    return true;
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
                                      style: CommonStyles.txSty_12b_fb,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                );
              }
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
                    color: CommonStyles.whiteColor,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              const Text(
                'My Orders',
                style: CommonStyles.txSty_18w_fb,
              ),
            ],
          ),
          FutureBuilder(
            future: getshareddata(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
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
                  color: CommonStyles.orangeColor,
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

  late final partyInfo;
  PaymentMode? selectedPaymode;
  int? payid;
  late String selectedName;
  ApiResponse? apiResponse;
  String? Selected_PaymentMode = "";
  TextEditingController todateController = TextEditingController();
  TextEditingController fromdateController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  bool dateSelected = false;
  DateTime selectedfromdateDate =
      DateTime.now().subtract(const Duration(days: 7));
  List<Purpose> purposeList = [];
  String? selectedPurpose, selectformattedfromdate, selectformattedtodate;
  Purpose? selectedPurposeObj;
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

    fetchData();
    getpaymentmethods();
    getWareHouses();
  }

  Future<void> getWareHouses() async {
    String userId = await SharedPrefsData.getStringFromSharedPrefs("userId");
    int companyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
    String apiurl = "$baseUrl$GetWarehouse$userId/$companyId";
    try {
      String apiUrl = "$baseUrl$GetWarehouse$userId/$companyId";
      debugPrint('apiUrl: $apiUrl');

      final jsonResponse = await http.get(Uri.parse(apiUrl));
      if (jsonResponse.statusCode == 200) {
        Map<String, dynamic> response = jsonDecode(jsonResponse.body);
        if (response['response']['listResult'] != null) {
          List<dynamic> wareHouseList = response['response']['listResult'];
          wareHousesData = wareHouseList
              .map((house) => WareHouseList.fromJson(house))
              .toList();
        } else {
          debugPrint('No warehouse found');
          throw Exception('No warehouse found');
        }
      } else {
        debugPrint('error: api call failed');
        throw Exception('api got failed: ${jsonResponse.statusCode}');
      }
    } catch (e) {
      throw Exception('$e');
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
    String apiurl = baseUrl + GetTypeCdmt;

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
    DateTime currentDate = DateTime.now();
    DateTime initialDate = selectedDate ?? currentDate;
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
                primary: CommonStyles.orangeColor,
                onPrimary: CommonStyles.whiteColor,
              ),
              dialogBackgroundColor: CommonStyles.whiteColor,
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
        controller.text = formattedDate;
        viewOrdersProvider.setToDate = formattedDate;

        selectedDate = picked;

        selectformattedtodate = DateFormat('yyyy-MM-dd').format(picked);
      }
    } catch (e) {
      print('catch: $e');
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
        const SizedBox(height: 4.0),
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
    DateTime initialDate;
    DateTime currentDate = DateTime.now();
    print('===>current date,${DateTime.now()}');
    if (controller.text.isNotEmpty) {
      try {
        print('===> date,${DateFormat('dd-MM-yyyy').parse(controller.text)}');
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
                onPrimary: CommonStyles.whiteColor,
              ),
              dialogBackgroundColor: CommonStyles.whiteColor,
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
        controller.text = formattedDate;
        viewOrdersProvider.setFromDate = formattedDate;
        selectedfromdateDate = picked;
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
    print('SLP Code:2 $slpCode');
    if (slpCode!.isEmpty) {
      slpCode = null;
    }
    print('SLP Code:3 $slpCode');
    savedCompanyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
    final response = await http.get(Uri.parse(baseUrl +
        GetAllDealersBySlpCode +
        '$savedCompanyId' +
        "/" +
        '$slpCode'));

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
                  decoration: CommonUtils.decorationO_R10W1,
                  child: TypeAheadField(
                    controller: provider.getPartyController,
                    builder: (context, controller, focusNode) => TextField(
                      controller: controller,
                      focusNode: focusNode,
                      autofocus: false,
                      style: CommonStyles.txSty_12o_f7,
                      decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(top: 18, left: 15),
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
                const SizedBox(
                  height: 10.0,
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 5.0),
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
                      color: Colors.blue,
                      size: 40.0,
                    )
                  : DropdownButton<String>(
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
                      itemCount: apiResponse!.listResult.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        bool isSelected = index == provider.dropDownStatus;
                        PaymentMode currentPaymode;

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
                            Selected_PaymentMode = currentPaymode.desc;
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        color: CommonStyles.redColor,
                      ),
                      side: const BorderSide(
                        color: CommonStyles.redColor,
                      ),
                      backgroundColor: CommonStyles.whiteColor,
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
                      getAppliedFilterData(context);
                    },
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                        color: CommonStyles.whiteColor,
                      ),
                      backgroundColor: CommonStyles.orangeColor,
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

  Future<void> getAppliedFilterData(BuildContext context) async {
    viewOrdersProvider.filterStatus = true;
    userId = await SharedPrefsData.getStringFromSharedPrefs("userId");
    savedCompanyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
    DateTime todate = DateFormat('dd-MM-yyyy').parse(todateController.text);
    selectformattedtodate = DateFormat('yyyy-MM-dd').format(todate);

    DateTime pickedFromDate =
        DateFormat('dd-MM-yyyy').parse(fromdateController.text);
    selectformattedfromdate = DateFormat('yyyy-MM-dd').format(pickedFromDate);

    String apiurl = baseUrl + GetAppOrder;
    print('ApplyFilterapi:$apiurl');
    try {
      final url = Uri.parse(apiurl);
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

          debugPrint('_______view orders____filter___$data');
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
      debugPrint('_______view orders____filter___${e.toString()}');
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
    color: CommonStyles.whiteColor,
  );

  final _iconBoxBorder = BoxDecoration(
    borderRadius: BorderRadius.circular(5.0),
    color: CommonStyles.whiteColor,
  );

  late ViewOrdersProvider viewOrdersProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    viewOrdersProvider = Provider.of<ViewOrdersProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        viewOrdersProvider.clearFilter();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Orderdetails(
              orderid: widget.orderResult.id,
              whsName: widget.orderResult.whsName,
              whscode: widget.orderResult.whsCode,
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
            padding:
                const EdgeInsets.only(left: 5, right: 5, top: 12, bottom: 12),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: CommonStyles.whiteColor,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Card(
                            elevation: 3,
                            color: CommonStyles.whiteColor,
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
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w700,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
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
                                        style: CommonStyles.txSty_12b_fb,
                                      ),
                                      Text(
                                        widget.orderResult.orderNumber
                                            .toString(),
                                        style: CommonStyles.txSty_12o_f7,
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
                                          style: CommonStyles.txSty_12o_f7,
                                        )
                                      : const SizedBox(),
                                  Row(
                                    children: [
                                      const Text(
                                        'No.of Items: ',
                                        style: CommonStyles.txSty_12b_fb,
                                      ),
                                      Text(
                                        '${widget.orderResult.noOfItems}',
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    widget.formattedDate,
                                    style: CommonStyles.txSty_12o_f7,
                                  ),
                                  Text(
                                    '₹${formatNumber(widget.orderResult.totalCostWithGST)}',
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
      case 1:
        assetPath = 'assets/shipping-timed.svg';
        iconColor = const Color(0xFFE58338);
        statusColor = const Color(0xFFe58338);
        statusBgColor = const Color(0xFFe58338).withOpacity(0.2);
        break;
      case 2:
        assetPath = 'assets/shipping-fast.svg';
        iconColor = const Color(0xFF0d6efd);
        statusColor = const Color(0xFF0d6efd);
        statusBgColor = const Color(0xFF0d6efd).withOpacity(0.2);
        break;
      case 3:
        assetPath = 'assets/box-circle-check.svg';
        iconColor = Colors.green;
        statusColor = Colors.green;
        statusBgColor = Colors.green.withOpacity(0.2);
        break;
      case 10:
        assetPath = 'assets/boxes.svg';
        iconColor = const Color(0xFF0dcaf0);
        statusColor = const Color(0xFF0dcaf0);
        statusBgColor = const Color(0xFF0dcaf0).withOpacity(0.2);
        break;
      case 11:
        assetPath = 'assets/shipping-timed.svg';
        iconColor = Colors.green;
        statusColor = Colors.green;
        statusBgColor = Colors.green.withOpacity(0.2);
        break;
      case 12:
        assetPath = 'assets/reject.svg';
        iconColor = HexColor('#C42121');
        statusColor = HexColor('#C42121');
        statusBgColor = HexColor('#C42121').withOpacity(0.2);
        break;
      case 14:
        assetPath = 'assets/srikar_biotech_logo.svg';
        iconColor = Colors.grey;
        statusColor = Colors.grey;
        statusBgColor = Colors.grey.withOpacity(0.2);
        break;
      case 16:
        assetPath = 'assets/order-cancel.svg';
        iconColor = HexColor('#dc3545');
        statusColor = HexColor('#dc3545');
        statusBgColor = HexColor('#dc3545').withOpacity(0.2);
        break;
      case 17:
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
      case 1:
        svgIcon = 'assets/shipping-timed.svg';
        statusColor = const Color(0xFFe58338);
        svgIconBgColor = const Color(0xFFe58338).withOpacity(0.2);
        break;
      case 2:
        svgIcon = 'assets/shipping-fast.svg';
        statusColor = const Color(0xFF0d6efd);
        svgIconBgColor = const Color(0xFF0d6efd).withOpacity(0.2);
        break;
      case 3:
        svgIcon = 'assets/box-circle-check.svg';
        statusColor = Colors.green;
        svgIconBgColor = Colors.green.withOpacity(0.2);
        break;
      case 10:
        svgIcon = 'assets/boxes.svg';
        statusColor = const Color(0xFF0dcaf0);
        svgIconBgColor = const Color(0xFF0dcaf0).withOpacity(0.2);
        break;
      case 11:
        svgIcon = 'assets/shipping-timed.svg';
        statusColor = Colors.green;
        svgIconBgColor = Colors.green.withOpacity(0.2);
        break;
      case 12:
        svgIcon = 'assets/reject.svg';
        statusColor = HexColor('#C42121');
        svgIconBgColor = HexColor('#C42121').withOpacity(0.2);
        break;
      case 16:
        svgIcon = 'assets/order-cancel.svg';
        statusColor = HexColor('#dc3545');
        svgIconBgColor = HexColor('#dc3545').withOpacity(0.2);
        break;
      case 17:
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
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              fontFamily: "Roboto",
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
