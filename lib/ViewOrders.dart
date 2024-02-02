import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:srikarbiotech/vieworders_provider.dart';
import 'Common/CommonUtils.dart';
import 'Common/SharedPrefsData.dart';
import 'HomeScreen.dart';
import 'OrctResponse.dart';
import 'OrderResponse.dart';
import 'Payment_model.dart';
import 'order_details.dart';

class ViewOrders extends StatefulWidget {
  const ViewOrders({super.key});

  @override
  State<ViewOrders> createState() => _VieworderPageState();
}

class _VieworderPageState extends State<ViewOrders> {
  final _orangeColor = HexColor('#e58338');
  final _borderforContainer = BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: HexColor('#e58338'),
      ));

  final _searchBarOutPutInlineBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Colors.black38),
  );
  final _searchBarEnabledNdFocuedOutPutInlineBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Colors.black),
  );

  String url =
      'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Order/GetOrders/null';

  List<OrderResult> orderesponselist = [];

  List<OrderResult> filterorderesponselist = [];

  TextEditingController searchController = TextEditingController();

  late  Future<List<OrderResult>?> apiData;

  late ViewOrdersProvider viewOrdersProvider;
  int CompneyId = 0;
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
      setState(() {
        viewOrdersProvider.storeIntoViewOrderProvider(data!);
      });
    }).catchError((error) {
      print('Error initializing data: $error');
    });
  }

  Future<List<OrderResult>> getorder() async {
    DateTime currentDate = DateTime.now();

    // Get one week back date
    DateTime oneWeekBackDate = currentDate.subtract(Duration(days: 7));

    // Format dates as 'yyyy-MM-dd'
    String formattedCurrentDate = DateFormat('yyyy-MM-dd').format(currentDate);
    String formattedOneWeekBackDate = DateFormat('yyyy-MM-dd').format(oneWeekBackDate);
    CompneyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");

      final url = Uri.parse(
          'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Order/GetAppOrdersBySearch');
      final requestBody = {
        "PartyCode":null, //selectedValue
        "StatusId": 2,
        "FormDate": formattedOneWeekBackDate,
        "ToDate": formattedCurrentDate,
        "CompanyId": CompneyId // passing 0
      };
      print('===========>${jsonEncode(requestBody)}');




      final response = await http.post(
      url,
      body: json.encode(requestBody),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> listResult = data['response']['listResult'];

      setState(() {
        orderesponselist =
            listResult.map((json) => OrderResult.fromJson(json)).toList();
        // print('>>orderlistresp$orderesponselist');
        filterorderesponselist = List.from(orderesponselist);
        //  filteredDealers = List.from(dealers);
      });
      return filterorderesponselist;
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

              return Padding(
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
                            OrderResult orderresul = data[index];
                            print('orderdate======>,${data[index].orderDate}');
                            // String fromatteddates = orderresul.orderDate;
                            String dateString =data[index].orderDate;
                            DateTime date = DateTime.parse(dateString);
                            String formattedDate = DateFormat('dd MMM, yyyy').format(date);



                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => Orderdetails(
                                        orderid: data[index].id,
                                        orderdate: formattedDate,
                                        totalprice: data[index].totalCost,
                                        bookingplace: data[index].bookingPlace,
                                        transportmode: data[index].transportName,
                                        lrnumber: 12345,
                                        lrdate: "",
                                        statusname: data[index].statusName,
                                        partyname: data[index].partyName,
                                        partycode: data[index].partyCode,
                                        proprietorName:
                                            data[index].proprietorName,
                                        partyGSTNumber:
                                            data[index].partyGSTNumber,
                                        ordernumber: data[index].orderNumber,
                                        partyAddress: data[index].partyAddress),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                color: Colors.transparent,
                                child: Card(
                                  elevation: 5,
                                  color: Colors.white,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    //   width: double.infinity,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              // starting icon of card
                                              Card(
                                                elevation: 2,
                                                color: Colors.white70,
                                                child: Container(
                                                  height: 65,
                                                  width: 90,
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: Colors.white30,
                                                  ),
                                                  child: Center(
                                                    child: getSvgAsset(
                                                        orderresul.statusName),

                                                    //    color: Colors.black, // Set color as needed
                                                  ),
                                                ),
                                              ),

                                              // beside info
                                              Container(
                                                //height: 90,
                                                // width: ,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.8,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10,
                                                          top: 0,
                                                          bottom: 0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        '${orderresul.partyName}',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Roboto',
                                                            fontSize: 12,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        softWrap: true,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      SizedBox(
                                                        height: 5.0,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Container(
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  'Order id :',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Roboto',
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                ),
                                                                Text(
                                                                  ' ${orderresul.orderNumber}',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Roboto',
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Spacer(),
                                                          // Container(
                                                          //   child: Row(
                                                          //     children: [
                                                          //       Text(
                                                          //         'No.of Items: ',
                                                          //         style: TextStyle(
                                                          //             fontFamily:
                                                          //                 'Roboto',
                                                          //             fontSize: 12,
                                                          //             color: Colors.black,
                                                          //             fontWeight:
                                                          //                 FontWeight
                                                          //                     .w400),
                                                          //       ),
                                                          //       Text(
                                                          //         '$numberOfItems',
                                                          //         style: TextStyle(
                                                          //             fontFamily:
                                                          //                 'Roboto',
                                                          //             fontSize: 13,
                                                          //             color: Color(
                                                          //                 0xFFe58338),
                                                          //             fontWeight:
                                                          //                 FontWeight
                                                          //                     .w600),
                                                          //       ),
                                                          //     ],
                                                          //   ),
                                                          // ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 5.0,
                                                      ),
                                                      SizedBox(
                                                        child: Row(
                                                          children: [
                                                            const Text(
                                                              'Total Amount: ',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Roboto',
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                            Text(
                                                              '₹${orderresul.totalCost}',
                                                              style: const TextStyle(
                                                                  fontFamily:
                                                                      'Roboto',
                                                                  fontSize: 13,
                                                                  color: Color(
                                                                      0xFFe58338),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                      // SizedBox(
                                                      //   height: 5.0,
                                                      // ),
                                                      // Container(
                                                      //     child: Row(
                                                      //   children: [
                                                      //     Text(
                                                      //       'Payment Mode: ',
                                                      //       style: TextStyle(
                                                      //           fontFamily: 'Roboto',
                                                      //           fontSize: 12,
                                                      //           color: Colors.black,
                                                      //           fontWeight:
                                                      //               FontWeight.w400),
                                                      //     ),
                                                      //     Text(
                                                      //       'paymentTypeName',
                                                      //       style: TextStyle(
                                                      //           fontFamily: 'Roboto',
                                                      //           fontSize: 13,
                                                      //           color: Color(0xFFe58338),
                                                      //           fontWeight:
                                                      //               FontWeight.w600),
                                                      //     ),
                                                      //   ],
                                                      // ))
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
                                            Container(
                                              height: 30,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color:
                                                    getStatusTypeBackgroundColor(
                                                        orderresul.statusName),
                                              ),
                                              child: IntrinsicWidth(
                                                stepWidth: 60.0,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      '${orderresul.statusName}',
                                                      style: TextStyle(
                                                        color:
                                                            getStatusTypeTextColor(
                                                                orderresul
                                                                    .statusName),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),

                                            SizedBox(
                                              width: 5.0,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Container(
                                                    child: Row(
                                                  children: [
                                                    Text(
                                                      'Date: ',
                                                      style: TextStyle(
                                                          fontFamily: 'Roboto',
                                                          fontSize: 12,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                    Text(
                                                      "$formattedDate",
                                                      style: TextStyle(
                                                          fontFamily: 'Roboto',
                                                          fontSize: 13,
                                                          color:
                                                              Color(0xFFe58338),
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ],
                                                )),
                                                SizedBox(
                                                  width: 10.0,
                                                ),
                                                //Spacer(),
                                                // Container(
                                                //   child: Row(
                                                //     children: [
                                                //       Text(
                                                //         'Total Amount: ',
                                                //         style: TextStyle(
                                                //             fontFamily: 'Roboto',
                                                //             fontSize: 13,
                                                //             color: Colors.black,
                                                //             fontWeight: FontWeight.w400),
                                                //       ),
                                                //       Text(
                                                //         '₹ 555.006',
                                                //         style: TextStyle(
                                                //             fontFamily: 'Roboto',
                                                //             fontSize: 13,
                                                //             color: Color(0xFFe58338),
                                                //             fontWeight: FontWeight.w600),
                                                //       ),
                                                //     ],
                                                //   ),
                                                // )
                                                Container(
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        'No.of Items: ',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Roboto',
                                                            fontSize: 12,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                      Text(
                                                        '${orderresul.noOfItems}',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Roboto',
                                                            fontSize: 13,
                                                            color: Color(
                                                                0xFFe58338),
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // SizedBox(
                                            //   width: 10.0,
                                            // ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
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
              );
            }
          },
        ),
      ),
    );
  }

  Color getStatusTypeBackgroundColor(String statusTypeId) {
    switch (statusTypeId) {
      case 'Pending':
        return Color(0xFFE58338).withOpacity(0.1);
      case 'Shipped':
        // Set background color for statusTypeId 8
        return Color(0xFF0d6efd).withOpacity(0.1);
      case 'Accept':
        // Set background color for statusTypeId 9
        return Color(0xFF198754).withOpacity(0.1);
      case 'Partially Shipped':
        // Set background color for statusTypeId 9
        return Color(0xFF0dcaf0).withOpacity(0.1);
      case 'Reject':
        return Color(0xFFdc3545).withOpacity(0.1);
        break;
      // Add more cases as needed for other statusTypeId values

      default:
        // Default background color or handle other cases if needed
        return Colors.white;
    }
  }

  Color getStatusTypeTextColor(String statusTypeId) {
    switch (statusTypeId) {
      case 'Pending':
        return Color(0xFFe58338);
      case 'Shipped':
        // Set background color for statusTypeId 8
        return Color(0xFF0d6efd);
      case 'Accept':
        // Set background color for statusTypeId 9
        return Color(0xFF198754);
      case 'Partially Shipped':
        // Set background color for statusTypeId 9
        return Color(0xFF0dcaf0);
      case 'Reject':
        return Color(0xFFdc3545);
        break;

      default:
        return Colors.white;
    }
  }

  Widget getSvgAsset(String status) {
    String assetPath;
    late Color iconColor;
    switch (status) {
      case "Pending":
        assetPath = 'assets/shipping-timed.svg';
        iconColor = Color(0xFFe58338);
        break;
      case 'Shipped':
        assetPath = 'assets/shipping-fast.svg';
        iconColor = Color(0xFF0d6efd);
        break;
      case 'Accept':
        assetPath = 'assets/box-circle-check.svg';
        iconColor = Color(0xFF198754);
        break;
      case 'Partially Shipped':
        assetPath = 'assets/boxes.svg';
        iconColor = Color(0xFF0dcaf0);
        break;
      case 'Reject':
        assetPath = 'assets/shipping-timed.svg';
        iconColor = Color(0xFFdc3545);
        break;
      // Add more cases for other statusnames
      default:
        assetPath = 'assets/sb_home.svg';
        iconColor = Colors.black26;
        break;
    }
    return SvgPicture.asset(
      assetPath,
      width: 40,
      height: 35,
      color: iconColor,
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
                'My Orders',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              // Handle the click event for the home icon
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            child: const Icon(
              Icons.home,
              size: 30,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewOrdersSearchBarAndFilter() {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: Container(
            // height: 55.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(
                color: Colors.black26,
                width: 2,
              ),
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 0.0),
                child: TextFormField(
                  controller: searchController,
                  onChanged: (value) {
                    filterDealers();
                    filterOrderBasedOnProduct(value);
                  },
                  keyboardType: TextInputType.name,
                  style: CommonUtils.Mediumtext_12,
                  decoration: InputDecoration(
                    suffixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFFC4C2C2),
                    ),
                    hintText: 'Search for Party Name or Id',
                    hintStyle: CommonUtils.hintstyle_14,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          )),
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
              decoration: _borderforContainer,
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
}

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
          padding: EdgeInsets.only(top: 0.0, left: 5.0, right: 0.0),
          child: Text(
            labelText,
            style: TextStyle(
              fontSize: 16.0,
              color: Color(0xFF5f5f5f),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
        ),
        SizedBox(height: 4.0), // Add space between labelText and TextFormField
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 40.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: Color(0xFFe78337),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0, top: 0.0),
                      child: TextFormField(
                        controller: controller,
                        enabled: false,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFe78337),
                        ),
                        decoration: InputDecoration(
                          hintText: labelText,
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
                  child: Padding(
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
          padding: EdgeInsets.only(top: 0.0, left: 5.0, right: 0.0),
          child: Text(
            labelText,
            style: TextStyle(
              fontSize: 16.0,
              color: Color(0xFF5f5f5f),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
        ),
        SizedBox(height: 4.0), // Add space between labelText and TextFormField
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 40.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: Color(0xFFe78337),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0, top: 0.0),
                      child: TextFormField(
                        controller: controller,
                        enabled: false,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFe78337),
                        ),
                        decoration: InputDecoration(
                          hintText: labelText,
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
                  child: Padding(
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

      // if (data['isSuccess']) {
      //   List<dynamic> dealerList = data['response']['listResult'];
      //
      //   setState(() {
      //     // dealers = dealerList
      //     //     .map((dealer) => Dealer(
      //     //           cardCode: dealer['cardCode'],
      //     //           cardName: dealer['cardName'],
      //     //         ))
      //     //     .toList();
      //
      //     setState(() {
      //       dropdownItems = data['listResult'];
      //     });
      //   });
      // }
      // Map<String, dynamic> data1 = json.decode(response.body);

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
                padding: EdgeInsets.only(left: 0, top: 5.0, right: 0),
                child: Container(
                  // width: double.infinity,
                  height: 40.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Color(0xFFe58338),
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
                          style: TextStyle(
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
                            DropdownMenuItem<int>(
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
              // SizedBox(
              //   height: 10.0,
              // ),
              // Padding(
              //   padding: const EdgeInsets.only(left: 5.0),
              //   child: Text(
              //     'Purpose',
              //     style: _labelTextStyle,
              //   ),
              // ),
              // SizedBox(
              //   height: 4.0,
              // ),
              // Container(
              //     width: MediaQuery.of(context).size.width,
              //     height: 40.0,
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(12.0),
              //       border: Border.all(
              //         color: Color(0xFFe78337),
              //         width: 1.0,
              //       ),
              //     ),
              //     child: Padding(
              //       padding: EdgeInsets.all(8.0),
              //       child: purposeList.isEmpty
              //           ? CircularProgressIndicator
              //               .adaptive() // Show a loading indicator
              //           : DropdownButton<String>(
              //               hint: Text(
              //                 'Select Purpose',
              //                 style: TextStyle(
              //                   fontSize: 14,
              //                   fontFamily: 'Roboto',
              //                   //    fontWeight: FontWeight.w600,
              //                   color: Color(0xFFe78337),
              //                 ),
              //               ),
              //               value: selectedPurpose,
              //               onChanged: (String? newValue) {
              //                 setState(() {
              //                   selectedPurpose = newValue;

              //                   // Find the selected Purpose object
              //                   selectedPurposeObj = purposeList.firstWhere(
              //                     (purpose) => purpose.fldValue == newValue,
              //                     orElse: () => Purpose(
              //                         fldValue: '', descr: '', purposeName: ''),
              //                   );

              //                   purposename = selectedPurposeObj!.fldValue;
              //                   print('selectpurposeName: $purposename');
              //                 });
              //               },
              //               items: purposeList.map((Purpose purpose) {
              //                 return DropdownMenuItem<String>(
              //                   value: purpose.fldValue,
              //                   child: Text(
              //                     purpose.purposeName,
              //                     style: TextStyle(
              //                       fontSize: 14,
              //                       fontFamily: 'Roboto',
              //                       fontWeight: FontWeight.w600,
              //                       color: Color(0xFFe78337),
              //                     ),
              //                   ),
              //                 );
              //               }).toList(),
              //               icon: Icon(Icons.arrow_drop_down),
              //               iconSize: 24,
              //               isExpanded: true,
              //               underline: SizedBox(),
              //             ),
              //     ))
            ],
          ),

          SizedBox(
            height: 10.0,
          ),
          Container(
            height: 40,
            //  child: Expanded(
            child: apiResponse == null
                ? Center(child: CircularProgressIndicator.adaptive())
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: apiResponse!.listResult.length,
                    itemBuilder: (BuildContext context, int index) {
                      bool isSelected = index == indexselected;
                      PaymentMode currentPaymode = apiResponse!.listResult[
                          index]; // Store the current paymode in a local variable

                      IconData iconData;
                      switch (currentPaymode.desc) {
                        case 'Cheque':
                          // iconData = Icons.payment;
                          break;
                        case 'Online':
                          //   iconData = Icons.access_alarm;
                          break;
                        case 'UPI':
                          //   iconData = Icons.payment;
                          break;
                        // Add more cases as needed
                        default:
                          //   iconData = Icons.payment; // Default icon
                          break;
                      }

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            indexselected = index;
                            selectedPaymode =
                                currentPaymode; // Update the selectedPaymode outside the build method
                          });
                          payid = currentPaymode.typeCdId;
                          Selected_PaymentMode = currentPaymode.desc;
                          print('payid:$payid');
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(0xFFe78337)
                                : Color(0xFFe78337).withOpacity(0.1),
                            border: Border.all(
                              color: isSelected
                                  ? Color(0xFFe78337)
                                  : Color(0xFFe78337),
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
                                      // Icon(
                                      //   iconData, // Use the dynamically determined icon
                                      //   color: isSelected
                                      //       ? Colors.white
                                      //       : Colors.black,
                                      // ),
                                      // SizedBox(
                                      //     width:
                                      //         8.0), // Add some spacing between icon and text
                                      Text(
                                        '${currentPaymode.desc.toString()}',
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
          ), // From date
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
          SizedBox(
            height: 10.0,
          ),
          // To Date
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
          SizedBox(
            height: 10.0,
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
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
    ));
  }

  late ViewOrdersProvider viewOrdersProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    viewOrdersProvider = Provider.of<ViewOrdersProvider>(context);
  }

//x000
  Future<void> getappliedflitters(BuildContext context) async {
    print('getappliedflitters called');
    try {
      final url = Uri.parse(
          'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Order/GetAppOrdersBySearch');
      final requestBody = {
        "PartyCode": 'SRIKARKA00002', //selectedValue
        "StatusId": 2,
        "FormDate": selectformattedfromdate,
        "ToDate": selectformattedtodate,
        "CompanyId": 1 // passing 0
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
          List<OrderResult> result =
              data.map((item) => OrderResult.fromJson(item)).toList();
          viewOrdersProvider.storeIntoViewOrderProvider(result);
        } else {
          List<OrderResult> emptyList = [];
          viewOrdersProvider.storeIntoViewOrderProvider(emptyList);
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

class Dealer {
  final String cardCode;
  final String cardName;

  Dealer({required this.cardCode, required this.cardName});
}
