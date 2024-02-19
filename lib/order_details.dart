import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:srikarbiotech/HomeScreen.dart';
import 'package:http/http.dart' as http;
import 'Common/CommonUtils.dart';
import 'Common/SharedPrefsData.dart';
import 'Model/OrderDetailsResponse.dart';
import 'ViewOrders.dart';
import 'orderdetails_model.dart';

class Orderdetails extends StatefulWidget {
  final int orderid;
  final String orderdate;
  final double totalCostWithGST;
  final String bookingplace;
  final String transportmode;
  final int lrnumber;
  final String lrdate;
  final String statusname;
  final String partyname;
  final String partycode;
  final String proprietorName;
  final String partyGSTNumber;
  final String ordernumber;
  final String partyAddress;

  const Orderdetails(
      {super.key,
      required this.orderid,
      required this.orderdate,
      required this.totalCostWithGST,
      required this.bookingplace,
      required this.transportmode,
      required this.lrnumber,
      required this.lrdate,
      required this.statusname,
      required this.partyname,
      required this.partycode,
      required this.proprietorName,
      required this.partyGSTNumber,
      required this.ordernumber,
      required this.partyAddress});

  @override
  State<Orderdetails> createState() => _OrderdetailsPageState();
}

class _OrderdetailsPageState extends State<Orderdetails> {
  List tableCellTitles = [
    ['Order Date', 'Booking Place', 'LR Number'],
    [
      'Total',
      'Transport Name',
      'LR Date',
    ]
  ];
  int orderid = 0;
  String ordernum = "";
  bool isDataLoaded = false;
  String Statusname = "";
  //List<OrderDetailsResponse> orderdetailslist = [];
  late List tableCellValues;
  late Future<OrderDetailsResponse?> orderDetailsList;
  String? partyname,
      partycode,
      itemname,
      salesname,
      partygstnumber,
      partyaddress,
      ordernumber;
  OrderItemXref? orderItemXref;
  List<OrderItemXref> orderitemxreflist = [];
  List<Map<String, dynamic>> itemList = [];
  int orderqty = 0;
  double price = 0.0;
  double totalcost = 0.0;
  double totalGst = 0.0;
  double totalsum = 0.0;
  String? Remarks;
  late List<GetOrderDetailsResult> orderDetails;
  late List<OrderItemXrefList> orderItemsList = [];
  int CompneyId = 0;
  late Future<InvoiceApiResponse> futureData;
  InvoiceApiResponse? invoiceResponse; // Make invoiceResponse nullable
  bool _showBottomSheet = false;
  TextEditingController remarkstext = TextEditingController();

  final ExpansionTileController controller = ExpansionTileController();
  @override
  void initState() {
    print('OrderId: ${Statusname}');
    Statusname = widget.statusname;
    print('Statusname: ${Statusname}');
    super.initState();
    fetchData();
    getOrderDetails();
    fetchorderproducts().then((value) {
      setState(() {
        isDataLoaded = true;
      });
    });
    fetchinvoicedata().then((invoiceResponse) {
      setState(() {
        this.invoiceResponse = invoiceResponse;
      });
    }).catchError((error) {
      print('Error fetching invoice data: $error');
    });

  }

  Future<void> getOrderDetails() async {
    orderid = widget.orderid;
    String apiUrl =
        'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Order/GetOrderDetailsById/$orderid';
    print("apiUrl====> ${apiUrl}");
    try {
      final apiData = await http.get(Uri.parse(apiUrl));

      if (apiData.statusCode == 200) {
        Map<String, dynamic> response = json.decode(apiData.body);
        if (response['isSuccess']) {
          // extracting the getOrderDetailsResult
          List<dynamic> orderDetailsData =
              response['response']['getOrderDetailsResult'];
          List<GetOrderDetailsResult> getOrderDetailsListResult =
              orderDetailsData
                  .map((item) => GetOrderDetailsResult.fromJson(item))
                  .toList();
          orderDetails = List.from(getOrderDetailsListResult);
          print("/*${orderDetails}");
          setState(() {
            partyname = getOrderDetailsListResult[0].partyName;
            partyaddress = getOrderDetailsListResult[0].partyAddress;
            partycode = getOrderDetailsListResult[0].partyCode;
            partygstnumber = getOrderDetailsListResult[0].partyGSTNumber;
            salesname = getOrderDetailsListResult[0].proprietorName;
            ordernumber = getOrderDetailsListResult[0].orderNumber;
            totalcost = getOrderDetailsListResult[0].totalCost;
            totalGst = getOrderDetailsListResult[0].gstCost;
            totalsum = getOrderDetailsListResult[0].totalCostWithGST;
            Remarks =  getOrderDetailsListResult[0].remarks;

          });
          print("partyname====> ${partyname}");
          print("Remarks====> ${Remarks}");
          print("ordernumber====> ${ordernumber}");
          // extracting the orderItemXrefList
          List<dynamic> orderItemsData =
              response['response']['orderItemXrefList'];
          List<OrderItemXrefList> orderItemXrefListResult = orderItemsData
              .map((item) => OrderItemXrefList.fromJson(item))
              .toList();
          orderItemsList = List.from(orderItemXrefListResult);
//        setState(() {
//           itemname = orderItemXrefListResult;
//           itemList = orderItemXrefListResult;
//           orderqty = orderItemXrefListResult;
//           price = orderItemXrefListResult;
//         });
        } else {
          print('api call unsuccessfull');
        }
      } else {
        print('else: api failed');
      }
    } catch (error) {
      CommonUtils.showCustomToastMessageLong('$error', context, 1, 4);
      print('Error: $error');
    }
  }

  Future<void> fetchorderproducts() async {
    print('fetchorderproducts called');
    final response = await http.get(Uri.parse(
        'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Order/GetOrderDetailsById/$orderid'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      List<Map<String, dynamic>> items = [];
      for (final item in data['response']['orderItemXrefList']) {
        items.add({
          'itemGrpName': item['itemGrpName'],
          // Replace 'fieldX' with the actual field name you want to use
          // Add other fields as needed
        });
        setState(() {
          itemname = item['itemGrpName'];
          itemList = items;
          orderqty = item['orderQty'];
          price = item['price'];
        });
      }
    } else {
      print('Failed to load data. Status code: ${response.statusCode}');
    }
  }

// here
  Future<List<String>> fetchData() async {
    // Retrieve saved cart items using CartHelper
    tableCellValues = [
      [widget.orderdate, widget.bookingplace, widget.lrnumber],
      [widget.totalCostWithGST, widget.transportmode, widget.lrdate]
    ];

    // Convert the elements to strings if needed
    List<String> stringList =
        tableCellValues.expand((row) => row).map((element) {
      return element.toString(); // Adjust the conversion as needed
    }).toList();
    return stringList;
  }

  Color getStatusTypeBackgroundColor(String statusTypeId) {
    switch (statusTypeId) {
      case 'Pending':
        return Color(0xFFE58338).withOpacity(0.1);
      case 'Shipped':
        // Set background color for statusTypeId 8
        return Color(0xFF0d6efd).withOpacity(0.1);
      case 'Accepted':
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
      case 'Accepted':
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

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: _appBar(),
        body:
        SingleChildScrollView(
          child: isDataLoaded
              ? Column(
            //mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // Set mainAxisSize to min for intrinsic height
                  children: [

                      Container(
                        width: screenWidth,
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child:

                        CommonUtils.buildCard(
                          widget.partyname,
                          widget.partycode,
                          widget.proprietorName,
                          widget.partyGSTNumber,
                          widget.partyAddress,
                          Colors.white,
                          BorderRadius.circular(5.0),
                        ),
                      ),
                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10),
                      child: Text(
                        'Order Details',
                        style: CommonUtils.header_Styles16,
                      ),
                    ),
                      Container(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        child: Card(
                            elevation: 7,
                            child: Container(
                                //   padding: const EdgeInsets.all(10),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                child: Column(children: [
                                  // Table
                                  Row(
                                    //  crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Order ID',
                                                textAlign: TextAlign.start,
                                                style: CommonUtils.txSty_13B_Fb,
                                              ),
                                              Text(
                                                '${ordernumber}',
                                                style: TextStyle(
                                                    fontFamily: 'Roboto',
                                                    fontSize: 13,
                                                    color: Color(0xFFe58338),
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ]),
                                      ),
                                      _orderStatus(widget.statusname),

                                    ],
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      // row one

                                      Container(
                                        width: double.infinity,
                                        height: 0.2,
                                        color: Colors.grey,
                                      ),

                                      // row two
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'OrderDate',
                                                    style: CommonUtils
                                                        .txSty_13B_Fb,
                                                  ),
                                                  Text(
                                                    '${widget.orderdate}',
                                                    style: TextStyle(
                                                      fontFamily: 'Roboto',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          HexColor('#e58338'),
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 0.2,
                                            height: 60,
                                            color: Colors.grey,
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Total Amount',
                                                    style: CommonUtils
                                                        .txSty_13B_Fb,
                                                  ),
                                                  Text(
                                                    '₹${formatNumber(widget.totalCostWithGST)}',
                                                    style: TextStyle(
                                                      fontFamily: 'Roboto',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          HexColor('#e58338'),
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: 0.2,
                                        color: Colors.grey,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Booking Place',
                                                    style: CommonUtils
                                                        .txSty_13B_Fb,
                                                  ),
                                                  Text(
                                                    '${widget.bookingplace}',
                                                    style: TextStyle(
                                                      fontFamily: 'Roboto',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          HexColor('#e58338'),
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 0.2,
                                            height: 60,
                                            color: Colors.grey,
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Transport Name',
                                                    style: CommonUtils
                                                        .txSty_13B_Fb,
                                                  ),
                                                  Text(
                                                    '${widget.transportmode}',
                                                    style: TextStyle(
                                                      fontFamily: 'Roboto',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          HexColor('#e58338'),
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                     Visibility(
                                        visible: Remarks != null  && Remarks != "",
                                      child:Column(children: [Container(
                                        width: double.infinity,
                                        height: 0.2,
                                        color: Colors.grey,
                                      ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                // Check if remarks are not null or empty
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'Remarks',
                                                      style: CommonUtils.txSty_13B_Fb,
                                                    ),
                                                    Text(
                                                      '$Remarks',
                                                      style: TextStyle(
                                                        fontFamily: 'Roboto',
                                                        fontWeight: FontWeight.bold,
                                                        color: HexColor('#e58338'),
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),

                                          ],
                                        ),],), ),

                                      // Container(
                                      //   width: double.infinity,
                                      //   height: 0.2,
                                      //   color: Colors.grey,
                                      // ),
                                      // Row(
                                      //   mainAxisAlignment:
                                      //       MainAxisAlignment.spaceBetween,
                                      //   children: <Widget>[
                                      //     Expanded(
                                      //       child: Padding(
                                      //         padding:
                                      //             const EdgeInsets.symmetric(
                                      //                 horizontal: 12,
                                      //                 vertical: 10),
                                      //         child:
                                      //         Column(
                                      //           crossAxisAlignment:
                                      //               CrossAxisAlignment.start,
                                      //           children: [
                                      //             const Text(
                                      //               'LR Number',
                                      //               style: CommonUtils
                                      //                   .txSty_13B_Fb,
                                      //             ),
                                      //             Text(
                                      //               '${widget.lrnumber}',
                                      //               style: TextStyle(
                                      //                 fontFamily: 'Roboto',
                                      //                 fontWeight:
                                      //                     FontWeight.bold,
                                      //                 color:
                                      //                     HexColor('#e58338'),
                                      //                 fontSize: 13,
                                      //               ),
                                      //             ),
                                      //           ],
                                      //         ),
                                      //       ),
                                      //     ),
                                      //     Container(
                                      //       width: 0.2,
                                      //       height: 60,
                                      //       color: Colors.grey,
                                      //     ),
                                      //     Expanded(
                                      //       child: Padding(
                                      //         padding:
                                      //             const EdgeInsets.symmetric(
                                      //                 horizontal: 12,
                                      //                 vertical: 10),
                                      //         child: Column(
                                      //           crossAxisAlignment:
                                      //               CrossAxisAlignment.start,
                                      //           children: [
                                      //             const Text(
                                      //               'LR Date',
                                      //               style: CommonUtils
                                      //                   .txSty_13B_Fb,
                                      //             ),
                                      //             Text(
                                      //               '',
                                      //               style: TextStyle(
                                      //                 fontFamily: 'Roboto',
                                      //                 fontWeight:
                                      //                     FontWeight.bold,
                                      //                 color:
                                      //                     HexColor('#e58338'),
                                      //                 fontSize: 13,
                                      //               ),
                                      //             ),
                                      //           ],
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),

                                      Container(
                                        width: double.infinity,
                                        height: 0.2,
                                        color: Colors.grey,
                                      ),

                                      Visibility(
                                        visible: Statusname == 'Pending', // Set the visibility based on statustypeid
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 10,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'You can cancel this order before it got Approved ',
                                                      style: CommonUtils.txSty_13B_Fb,
                                                    ),
                                                    Text(
                                                      '',
                                                      style: TextStyle(
                                                        fontFamily: 'Roboto',
                                                        fontWeight: FontWeight.bold,
                                                        color: HexColor('#e58338'),
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                          // Show confirmation dialog
                          showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Confirmation"),
                              content: Text("Are you sure you want to cancel this order?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close the dialog
                                  },
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close the dialog
                                    // Call function to cancel order
                                    cancelOrder();
                                  },
                                  child: Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: HexColor('#ffecee'), // Background color of the card
                                                  borderRadius: BorderRadius.circular(20), // Adjust the radius as needed
                                                ),
                                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Adjust padding as needed
                                                child: Row(
                                                  children: [
                                                    SvgPicture.asset(
                                                      'assets/crosscircle.svg',
                                                      height: 18,
                                                      width: 18,
                                                      fit: BoxFit.fitWidth,
                                                      color: HexColor('#de4554'),
                                                    ),
                                                    SizedBox(width: 8.0), // Add some spacing between icon and text
                                                    Text(
                                                      'Cancel',
                                                      style: TextStyle(
                                                        fontFamily: 'Roboto',
                                                        fontWeight: FontWeight.bold,
                                                        color: HexColor('#de4554'),
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                          ],
                                        ),
                                      ),

                                    ],
                                  ),

                                  // Table(
                                  //   border: TableBorder.all(
                                  //     width: 1,
                                  //     color: Colors.grey.shade500,
                                  //   ),
                                  //   children: [
                                  //     ...List.generate(3, (index) {
                                  //       return TableRow(
                                  //         children: [
                                  //           TableCell(
                                  //             child: Container(
                                  //               padding: const EdgeInsets.all(10),
                                  //               child: Column(
                                  //                 crossAxisAlignment:
                                  //                     CrossAxisAlignment.start,
                                  //                 children: <Widget>[
                                  //                   Text(
                                  //                     tableCellTitles[0][index],
                                  //                     //   style: _titleTextStyle,
                                  //                   ),
                                  //                   SizedBox(height: 5),
                                  //                   Text(
                                  //                     tableCellValues[0][index]
                                  //                         .toString(),
                                  //                     style: TextStyle(
                                  //                         fontFamily: 'Roboto',
                                  //                         fontSize: 13,
                                  //                         color: Color(0xFFe58338),
                                  //                         fontWeight: FontWeight.w600),
                                  //                     //style: _dataTextStyle,
                                  //                   )
                                  //                 ],
                                  //               ),
                                  //             ),
                                  //           ),
                                  //           TableCell(
                                  //             child: Container(
                                  //               padding: EdgeInsets.all(10),
                                  //               child: Column(
                                  //                 crossAxisAlignment:
                                  //                     CrossAxisAlignment.start,
                                  //                 children: <Widget>[
                                  //                   Text(
                                  //                     tableCellTitles[1][index],
                                  //                   ),
                                  //                   SizedBox(height: 5),
                                  //                   Text(
                                  //                     tableCellValues[1][index]
                                  //                         .toString(),
                                  //                     style: TextStyle(
                                  //                         fontFamily: 'Roboto',
                                  //                         fontSize: 13,
                                  //                         color: Color(0xFFe58338),
                                  //                         fontWeight: FontWeight.w600),
                                  //                   )
                                  //                 ],
                                  //               ),
                                  //             ),
                                  //           ),
                                  //         ],
                                  //       );
                                  //     })
                                  //   ],
                                  // ),
                                ]))),
                      ),


                    SizedBox(
                      height: 5.0,
                    ),


                    //_buildBody(context),
                    CustomExpansionTile(
                      title: Text(
                        "Item Details",
                        style: TextStyle(color: Colors.white), // Adjust text color as needed
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: screenWidth,
                            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                            //   height: screenHeight / 2,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              //        color: Colors.white,
                            ),
                            child:
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const PageScrollPhysics(),
                              itemCount: orderItemsList.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    // Navigator.of(context)
                                    //     .pushNamed('/statusScreen', arguments: widget.listResult);
                                    // Navigator.of(context).push(
                                    //   MaterialPageRoute(
                                    //     builder: (context) => ViewCollectionCheckOut(
                                    //       //
                                    //       listResult: widget.listResult,
                                    //       position: widget.index, // Assuming you have the index available
                                    //     ),
                                    //   ),
                                    // );
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

                                        child:
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              // height: 70,
                                              // width: double.infinity,
                                              // margin: const EdgeInsets.only(bottom: 12),
                                              width:
                                              MediaQuery.of(context).size.width,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(10),
                                              ),
                                              child:
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  // starting icon of card

                                                  // beside info
                                                  Container(
                                                    //height: 90,
                                                    // width: ,
                                                   width: MediaQuery.of(context).size.width/1.3,
                                                    child:
                                                    Container(
                                                      padding:
                                                      const EdgeInsets.only(
                                                          left: 0,
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
                                                            orderItemsList[index]
                                                                .itemName,
                                                            style: const TextStyle(
                                                                fontFamily:
                                                                'Roboto',
                                                                fontSize: 14,
                                                                color: Colors.black,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                            softWrap: true,
                                                            maxLines: 2,
                                                            overflow: TextOverflow
                                                                .ellipsis,
                                                          ),
                                                          const SizedBox(
                                                            height: 5.0,
                                                          ),
                                                          Row(
                                                         mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                            children: [
                                                              Container(
                                                                child: Row(
                                                                children: [
                                                                  Text(
                                                                    'Qty: ${orderItemsList[index].orderQty}',
                                                                    style: TextStyle(
                                                                      fontFamily: 'Roboto',
                                                                      fontSize: 14,
                                                                      color: Colors.black,
                                                                      fontWeight: FontWeight.w400,
                                                                    ),
                                                                  ),
                                                                  // Text(
                                                                  //   orderItemsList[index].orderQty.toString(),
                                                                  //   style: CommonUtils.Mediumtext_12,
                                                                  // ),

                                                                  Text(
                                                                    ' (${orderItemsList[index].orderQty} ${orderItemsList[index].salUnitMsr} = ${orderItemsList[index].orderQty * orderItemsList[index].numInSale!}  Nos)', // Display totalSumForProduct for the single product
                                                                    style: CommonUtils.Mediumtext_o_14,
                                                                  ),
                                                                ],
                                                              ),),
                                                              //  Text(
                                                              //   'Qty: ${orderItemsList[index].orderQty}',
                                                              //   style: TextStyle(
                                                              //     fontFamily: 'Roboto',
                                                              //     fontSize: 14,
                                                              //     color: Colors.black,
                                                              //     fontWeight: FontWeight.w400,
                                                              //   ),
                                                              // ),
                                                              // // Text(
                                                              // //   orderItemsList[index].orderQty.toString(),
                                                              // //   style: CommonUtils.Mediumtext_12,
                                                              // // ),
                                                              //
                                                              // Text(
                                                              //   ' (${orderItemsList[index].orderQty} ${orderItemsList[index].salUnitMsr} = ${orderItemsList[index].orderQty * orderItemsList[index].numInSale!}  Nos)', // Display totalSumForProduct for the single product
                                                              //   style: CommonUtils.Mediumtext_o_14,
                                                              // ),
                                                              Expanded(
                                                                child: Container(), // This Expanded widget ensures that the additional text is positioned at the end of the row
                                                              ),
                                                              // SizedBox(width: 20.0,),

                                                              Text(
                                                                '₹${formatNumber(orderItemsList[index].totalPrice)}',
                                                                style: CommonUtils.Mediumtext_o_14,
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
                              },
                            ),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0),
                            child: IntrinsicHeight(
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: Colors.white,
                                  ),
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Sub Total',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.0,
                                            ),
                                          ),
                                          Text(
                                            '₹${formatNumber(totalcost)}',
                                            style: TextStyle(
                                              color: Color(0xFFe78337),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8.0),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'GST',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.0,
                                            ),
                                          ),
                                          Text(
                                            '₹${formatNumber(totalGst)}',
                                            style: TextStyle(
                                              color: Color(0xFFe78337),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8.0),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Total Amount',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.0,
                                            ),
                                          ),
                                          Text(
                                            '₹${formatNumber(totalsum)}',
                                            style: TextStyle(
                                              color: Color(0xFFe78337),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          ),

                        ],
                      ),
                        initiallyExpanded: false,

                         ),
                      //    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    if (invoiceResponse?.listResult != null && invoiceResponse!.listResult!.isNotEmpty)
                    CustomExpansionTile(
                      title: Text(
                        "Invoice Details",
                        style: TextStyle(color: Colors.white), // Adjust text color as needed
                        overflow: TextOverflow.ellipsis,
                      ),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          invoiceResponse?.listResult != null && invoiceResponse!.listResult!.isNotEmpty
                              ? Container(
                            width: screenWidth,
                            height: 250,
                            child:
                            ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: invoiceResponse!.listResult!.length,
                              itemBuilder: (context, index) {
                                InvoiceDetails invoice = invoiceResponse!.listResult![index];
                                DateTime date = invoice.invoiceDate;
                                String invoicedateDate = DateFormat('dd MMM, yyyy').format(date);



                                return
                                  Container(
                                  width: screenWidth,
                                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                                  child:
                                  Card(
                                    elevation: 7,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: invoice.isReceived ?? false ? Colors.green : Colors.redAccent,
                                        width: 2.0, // Set your desired border width here
                                      ),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: <Widget>[
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      const Text(
                                                        'Invoice Number',
                                                        style: CommonUtils
                                                            .txSty_13B_Fb,
                                                      ),
                                                      Text(
                                                        '${invoice.invoiceNo}',
                                                        style: TextStyle(
                                                          fontFamily:
                                                          'Roboto',
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          color: HexColor(
                                                              '#e58338'),
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 0.2,
                                                height: 60,
                                                color: Colors.grey,
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      const Text(
                                                        'Invoice Date',
                                                        style: CommonUtils.txSty_13B_Fb,
                                                      ),
                                                      Text(
                                                        '${invoicedateDate}',
                                                        style: TextStyle(
                                                          fontFamily: 'Roboto',
                                                          fontWeight: FontWeight.bold,
                                                          color: HexColor('#e58338'),
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            width: double.infinity,
                                            height: 0.2,
                                            color: Colors.grey,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: <Widget>[
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      const Text(
                                                        'Quantity',
                                                        style: CommonUtils
                                                            .txSty_13B_Fb,
                                                      ),
                                                      Text(
                                                        '${invoice.totalInvoiceQty}',
                                                        style: TextStyle(
                                                          fontFamily:
                                                          'Roboto',
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          color: HexColor(
                                                              '#e58338'),
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 0.2,
                                                height: 60,
                                                color: Colors.grey,
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      const Text(
                                                        'Invoice Amount',
                                                        style: CommonUtils
                                                            .txSty_13B_Fb,
                                                      ),
                                                      Text(
                                                        '${formatNumber(invoice.totalInvoiceAmount)}',
                                                        style: TextStyle(
                                                          fontFamily: 'Roboto',
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          color: HexColor(
                                                              '#e58338'),
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            width: double.infinity,
                                            height: 0.2,
                                            color: Colors.grey,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: <Widget>[
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      const Text(
                                                        'LR Number',
                                                        style: CommonUtils
                                                            .txSty_13B_Fb,
                                                      ),
                                                      Text(
                                                        '${widget.lrnumber}',
                                                        style: TextStyle(
                                                          fontFamily:
                                                          'Roboto',
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          color: HexColor(
                                                              '#e58338'),
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 0.2,
                                                height: 60,
                                                color: Colors.grey,
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      const Text(
                                                        'LR Date',
                                                        style: CommonUtils
                                                            .txSty_13B_Fb,
                                                      ),
                                                      Text(
                                                        '',
                                                        style: TextStyle(
                                                          fontFamily:
                                                          'Roboto',
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          color: HexColor(
                                                              '#e58338'),
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          Container(
                                            width: double.infinity,
                                            height: 0.2,
                                            color: Colors.grey,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Container(padding: EdgeInsets.all(8.0),
                                                  child:
                                                  Visibility(
                                                    visible: invoiceResponse!.listResult![index].lrFileUrl != null,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return AlertDialog(
                                                              content: Container(
                                                                width: double.infinity,
                                                                height: double.infinity,
                                                                child: Column(
                                                                  children: [
                                                                    Expanded(
                                                                      child: Image.network(
                                                                        invoiceResponse!.listResult![index].lrFileUrl ?? '',
                                                                        fit: BoxFit.contain,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              actions: [
                                                                Container(
                                                                  margin: EdgeInsets.only(top: 10, right: 10),
                                                                  decoration: BoxDecoration(
                                                                    shape: BoxShape.circle,
                                                                    color: Colors.white,
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: Colors.black.withOpacity(0.1),
                                                                        blurRadius: 6,
                                                                        spreadRadius: 3,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  child: IconButton(
                                                                    icon: Icon(Icons.close, color: Colors.red),
                                                                    onPressed: () {
                                                                      Navigator.of(context).pop();
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                      child: Container(
                                                        height: 35,
                                                        margin: EdgeInsets.symmetric(horizontal: 4.0),
                                                        decoration: BoxDecoration(
                                                          color: Color(0xFFe78337),
                                                          border: Border.all(
                                                            color: Color(0xFFe78337),
                                                            width: 1,
                                                          ),
                                                          borderRadius: BorderRadius.circular(8.0),
                                                        ),
                                                        child: IntrinsicWidth(
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Container(
                                                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                                                child: Row(
                                                                  children: [
                                                                    SvgPicture.asset(
                                                                      'assets/overview.svg',
                                                                      height: 18,
                                                                      width: 18,
                                                                      fit: BoxFit.fitWidth,
                                                                      color: Colors.white,
                                                                    ),
                                                                    SizedBox(width: 8.0),
                                                                    Text(
                                                                      'View LR',
                                                                      style: TextStyle(
                                                                        color: Colors.white,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                              ),

                                              Visibility(
                                                visible: invoice.isReceived == false,
                                                child: Container(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: GestureDetector(
                                                    onTap: () async {


                                                        if (invoiceResponse?.listResult != null && invoiceResponse!.listResult!.isNotEmpty && !_showBottomSheet) {
                                                          for (InvoiceDetails invoice in invoiceResponse!.listResult!) {
                                                            if (invoice.isReceived == false) {
                                                              // setState(() {
                                                              //   _showBottomSheet = true;
                                                              // });
                                                              showBottomSheet(context,invoice.invoiceNo,invoicedateDate);
                                                              break; // Stop looping after finding the first invoice with isReceived == false
                                                            }
                                                          }


                                                      //Add your download functionality here
                                                    };},
                                                    child: Container(
                                                      height: 35,
                                                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                                                      decoration: BoxDecoration(
                                                        color: Color(0xFFF8dac2),
                                                        border: Border.all(
                                                          color: Color(0xFFe78337),
                                                          width: 1,
                                                        ),
                                                        borderRadius: BorderRadius.circular(8.0),
                                                      ),
                                                      child: IntrinsicWidth(
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Container(
                                                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                                                              child: Row(
                                                                children: [
                                                                  SvgPicture.asset(
                                                                    'assets/box-check.svg',
                                                                    height: 18,
                                                                    width: 18,
                                                                    fit: BoxFit.fitWidth,
                                                                    color: Colors.black,
                                                                  ),
                                                                  SizedBox(width: 8.0),
                                                                  Text(
                                                                    'Received',
                                                                    style: TextStyle(
                                                                      color: Colors.black,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: invoice.isReceived == true && invoice.invoiceFileUrl != null ,
                                                child: Container(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      String? pdfUrl = invoice.invoiceFileUrl;
                                                      String? invoiceNo = invoice.invoiceNo;
                                                      downloadFile(pdfUrl!,invoiceNo);


                                                      //Add your download functionality here
                                                    },
                                                    child: Container(
                                                      height: 35,
                                                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                                                      decoration: BoxDecoration(
                                                        color: Color(0xFFF8dac2),
                                                        border: Border.all(
                                                          color: Color(0xFFe78337),
                                                          width: 1,
                                                        ),
                                                        borderRadius: BorderRadius.circular(8.0),
                                                      ),
                                                      child: IntrinsicWidth(
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Container(
                                                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                                                              child: Row(
                                                                children: [
                                                                  SvgPicture.asset(
                                                                    'assets/file-download.svg',
                                                                    height: 18,
                                                                    width: 18,
                                                                    fit: BoxFit.fitWidth,
                                                                    color: Colors.black,
                                                                  ),
                                                                  SizedBox(width: 8.0),
                                                                  Text(
                                                                    'Download Invoice',
                                                                    style: TextStyle(
                                                                      color: Colors.black,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                              : Container(),

                        ],
                      ),
                      initiallyExpanded: false,

                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                  ])
              :  Center(child: CircularProgressIndicator())

        ));

  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: Color(0xFFe78337),
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
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => const ViewOrders()),
                    // );
                  },
                  child: const Icon(
                    Icons.chevron_left,
                    size: 30.0,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                'Order Details',
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
                return SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> getshareddata() async {
    CompneyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");

    print('Company ID: $CompneyId');
  }
  Future<InvoiceApiResponse> fetchinvoicedata() async {
    ordernum = widget.ordernumber;
    final response = await http.get(Uri.parse('http://182.18.157.215/Srikar_Biotech_Dev/API/api/Order/GetInvoiceDetailsByOrderNumber/$ordernum'));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData != null && responseData['response'] != null) {
        return InvoiceApiResponse.fromJson(responseData);
      } else {
        throw Exception('Invalid response data');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }


  String formatNumber(double number) {
    NumberFormat formatter = NumberFormat("#,##,##,##,##,##,##0.00", "en_US");
    return formatter.format(number);
  }

  Future<void> cancelOrder() async {
    orderid = widget.orderid;
    DateTime currentDate = DateTime.now();
    String formattedcurrentDate = DateFormat('yyyy-MM-dd').format(currentDate);
    print('Formatted Date: $formattedcurrentDate');
    final String apiUrl = 'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Order/UpdateOrderStatus';
    final String userId = await SharedPrefsData.getStringFromSharedPrefs("userId");

    final Map<String, dynamic> requestData = {
      "Id": orderid,
      "StatusTypeId": 16,
      "Remarks": "",
      "UpdatedBy": userId,
      "UpdatedDate": formattedcurrentDate,
    };
    print(jsonEncode(requestData));
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['isSuccess']) {
          // Status updated successfully
          print(responseData['endUserMessage']);
          CommonUtils.showCustomToastMessageLong("Your Order Cancelled Successfully", context, 0, 3);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ViewOrders()),
          );
        } else {
          // Handle API failure
          print('API request failed');
        }
      } else {
        // Handle HTTP error
        print('HTTP error ${response.statusCode}');
      }
    } catch (error) {
      // Handle network error
      print('Network error: $error');
    }
  }

  void showBottomSheet(BuildContext context, String invoiceNo, String invoicedateDate) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Did party receive this $invoiceNo Shipment?',
                style: CommonUtils.Mediumtext_o_14,
              ),
              SizedBox(height: 5),
              Text(
                'If received, click on the Received button. If you have any queries, enter the remarks.',
                style: CommonUtils.Mediumtext_12_0,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(); // Close the bottom sheet
                      // Show a new bottom sheet for entering remarks

                    },
                    child: Container(
                      height: 35,
                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        color: Color(0xFFFffece6),
                        border: Border.all(
                          color: Color(0xFFe6504d),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: IntrinsicWidth(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/crosscircle.svg',
                                    height: 18,
                                    width: 18,
                                    fit: BoxFit.fitWidth,
                                    color: Color(0xFFe6504d),
                                  ),
                                  SizedBox(width: 8.0),
                                  Text(
                                    'Not Received',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 12,
                                      color: Color(0xFFe6504d),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(); // Close the bottom sheet
                      // Show a new bottom sheet for entering remarks
                      showRemarksBottomSheet(context, invoiceNo,invoicedateDate);
                    },
                    child: Container(
                      height: 35,
                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        color: Color(0xFFFdfffe8),
                        border: Border.all(
                          color: Color(0xFF009746),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child:
                      IntrinsicWidth(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child:
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/check.svg',
                                    height: 18,
                                    width: 18,
                                    fit: BoxFit.fitWidth,
                                    color: Color(0xFF009746),
                                  ),
                                  SizedBox(width: 8.0),
                                  Text(
                                    ' Received',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 12,
                                      color: Color(0xFF009746),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void showRemarksBottomSheet(
      BuildContext context, String invoiceNo, String invoicedateDate) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ' $invoiceNo ($invoicedateDate)',
                  style: CommonUtils.Mediumtext_o_14,
                ),
                const SizedBox(height: 10),
                 Padding(
                  padding: EdgeInsets.only(
                      top: 15.0, left: 0.0, right: 0.0, bottom: 5.0),
                  child: Text(
                    'Remarks',
                    style:CommonUtils.Mediumtext_o_14,
                    textAlign: TextAlign.start,
                  ),
                ),
                Container(
                  height: 70,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    border:
                    Border.all(color: const Color(0xFFe78337), width: 1),
                    borderRadius: BorderRadius.circular(5.0),
                    color: Colors.white,
                  ),
                  child: TextFormField(
                    controller: remarkstext,
                    maxLength: 100,
                    style: CommonUtils.Mediumtext_o_14,
                    maxLines: null, // Set maxLines to null for multiline input
                    decoration:  InputDecoration(
                      counterText: '',
                      hintText: 'Enter Remarks',
                      hintStyle: CommonUtils.hintstyle_o_14,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 0.0,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        String remarks = remarkstext.text.trim();
                        if (remarks.isEmpty) {
                          CommonUtils.showCustomToastMessageLong(
                              'Please Enter Remarks', context, 1, 4);
                        } else {
                          // Call the API to update invoice status with remarks
                          updateInvoiceStatus(ordernumber!, invoiceNo, remarks);
                          Navigator.of(context).pop(); // Close the bottom sheet
                        }
                        // updateInvoiceStatus(ordernumber!, invoiceNo);
                        // Navigator.of(context).pop(); // Close the bottom sheet
                      },
                      child: Container(
                        height: 35,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8dac2),
                          border: Border.all(
                            color: const Color(0xFFe78337),
                            width: 1,
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
                                    SvgPicture.asset(
                                      'assets/check.svg',
                                      height: 18,
                                      width: 18,
                                      fit: BoxFit.fitWidth,
                                      color: const Color(0xFFe78337),
                                    ),
                                    const SizedBox(width: 8.0),
                                    const Text(
                                      ' Submit',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 12,
                                        color: Color(0xFFe78337),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     // Implement your logic to handle the remarks
                    //     Navigator.of(context).pop(); // Close the bottom sheet
                    //   },
                    //   child: Text('Submit'),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void updateInvoiceStatus(String orderNumber, String invoiceNo, String remarks) async {
    final String userId = await SharedPrefsData.getStringFromSharedPrefs("userId");
    DateTime currentDate = DateTime.now();
    String formattedcurrentDate = DateFormat('yyyy-MM-dd').format(currentDate);
    print('Formatted Date: $formattedcurrentDate');
    // Your API URL
    final String apiUrl = 'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Order/UpdateInvoiceStatus';

    // Your API request body
    final Map<String, dynamic> requestBody = {
      "OrderNumber": orderNumber,
      "InvoiceNo": invoiceNo,
      "IsReceived": true,
      "Remarks": remarks,
      "UpdatedBy": userId,
      "UpdatedDate": formattedcurrentDate,
    };
    print(jsonEncode(requestBody));
    // Send the API request
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['isSuccess']) {
          // Status updated successfully
          print(responseData['endUserMessage']);
          CommonUtils.showCustomToastMessageLong(responseData['endUserMessage'], context, 0, 3);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ViewOrders()),
          );
        } else {
          // Handle API failure
          print('API request failed');
        }
      } else {
        // Handle HTTP error
        print('HTTP error ${response.statusCode}');
      }
    } catch (error) {
      // Handle network error
      print('Network error: $error');
    }
  }

  canLaunch(String? url) {}

  Future<void> downloadFile(String url, String invoiceNo) async {
    try {
      // Send a GET request to the provided URL
      http.Response response = await http.get(Uri.parse(url));

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Get the application documents directory

        Directory appDocDir = Directory('/storage/emulated/0/Download');
        String fileName = "srikar_invoice_${invoiceNo}.pdf";

        String filePath = '${appDocDir.path}/$fileName';
        // Get the download directory

        if (!appDocDir.existsSync()) {
          appDocDir.createSync(recursive: true);
        }
        await File(filePath).writeAsBytes(response.bodyBytes);
        // Create a File instance to save the PDF


        // Show a message indicating successful download
        // print('PDF downloaded successfully');
        CommonUtils.showCustomToastMessageLong('Invoice Downloaded Successfully', context, 0, 4);
        // You can use this file path to open the PDF file, or display it in your app

        print('PDF path: $filePath');
      } else {
        // If the request was not successful, print an error message
        print('Failed to download PDF: ${response.statusCode}');
      }
    } catch (e) {
      // If an error occurs during the download process, print the error
      print('Error downloading PDF: $e');
    }
  }
  Widget _orderStatus(String statusName) {
    final Color statusColor;
    final Color statusBgColor;
    switch (statusName) {
      case 'Pending':
        statusColor = const Color(0xFFe58338);
        statusBgColor = const Color(0xFFe58338).withOpacity(0.2);
        break;
      case 'Shipped':
        statusColor = const Color(0xFF0d6efd);
        statusBgColor = const Color(0xFF0d6efd).withOpacity(0.2);
        break;
      case 'Delivered':
        statusColor = Colors.green;
        statusBgColor = Colors.green.withOpacity(0.2);
        break;
      case 'Partially Shipped':
        statusColor = const Color(0xFF0dcaf0);
        statusBgColor = const Color(0xFF0dcaf0).withOpacity(0.2);
        break;
      case 'Accepted':
        statusColor = Colors.green;
        statusBgColor = Colors.green.withOpacity(0.2);
        break;
      case 'Rejected':
        statusColor = HexColor('#C42121');
        statusBgColor = HexColor('#C42121').withOpacity(0.2);
        break;
      case 'Cancelled':
        statusColor = HexColor('#dc3545');
        statusBgColor = HexColor('#dc3545').withOpacity(0.2);
        break;
      default:
        statusColor = Colors.black26;
        statusBgColor = Colors.black26.withOpacity(0.2);
        break;
    }
    return Container(
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: statusBgColor,
        borderRadius: BorderRadius.circular(14.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Text(
        statusName,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 13,
          color: statusColor,
        ),
      ),
    );
  }

}

class CustomExpansionTile extends StatefulWidget {
  final Widget title;
  final Widget content;
  final bool initiallyExpanded;

  const CustomExpansionTile({
    Key? key,
    required this.title,
    required this.content,
    this.initiallyExpanded = false,
  }) : super(key: key);

  @override
  _CustomExpansionTileState createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              decoration: BoxDecoration(

                borderRadius: BorderRadius.circular(8.0),
                // borderRadius: BorderRadius.only(
                //   topLeft: Radius.circular(8.0),
                //   topRight: Radius.circular(8.0),
                // ),
                color: Color(0xFFe78337),// Adjust the color as needed
              ),
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(child: widget.title),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) widget.content,
        ],
      ),
    );
  }
}

class InvoiceApiResponse {
  final List<InvoiceDetails>? listResult;
  final int count;
  final int affectedRecords;

  InvoiceApiResponse({
    required this.listResult,
    required this.count,
    required this.affectedRecords,
  });

  factory InvoiceApiResponse.fromJson(Map<String, dynamic> json) {
    return InvoiceApiResponse(
      listResult: json['response']['listResult'] != null
          ? List<InvoiceDetails>.from(
        json['response']['listResult'].map((x) => InvoiceDetails.fromJson(x)),
      )
          : null,
      count: json['response']['count'],
      affectedRecords: json['response']['affectedRecords'],
    );
  }
}

class InvoiceDetails {
  final String invoiceNo;
  final DateTime invoiceDate;
  final double totalInvoiceAmount;
  final double totalAmountWithGST;
  final int totalInvoiceQty;
  final String? lrFileName;
  final String? lrFileLocation;
  final String? lrFileExtension;
  final String? lrFileUrl;
  final String? invoiceFileName;
  final String? invoiceFileLocation;
  final String? invoiceFileExtension;
  final String? invoiceFileUrl;
  final String? remarks;
  final bool? isReceived;

  InvoiceDetails({
    required this.invoiceNo,
    required this.invoiceDate,
    required this.totalInvoiceAmount,
    required this.totalAmountWithGST,
    required this.totalInvoiceQty,
    required this.lrFileName,
    required this.lrFileLocation,
    required this.lrFileExtension,
    required this.lrFileUrl,
    required this.invoiceFileName,
    required this.invoiceFileLocation,
    required this.invoiceFileExtension,
    required this.invoiceFileUrl,
    this.remarks,
    this.isReceived,
  });

  factory InvoiceDetails.fromJson(Map<String, dynamic> json) {
    return InvoiceDetails(
      invoiceNo: json['invoiceNo'],
      invoiceDate: DateTime.parse(json['invoiceDate']),
      totalInvoiceAmount: json['totalInvoiceAmount'].toDouble(),
      totalAmountWithGST: json['totalAmountWithGST'].toDouble(),
      totalInvoiceQty: json['totalInvoiceQty'],
      lrFileName: json['lrFileName'],
      lrFileLocation: json['lrFileLocation'],
      lrFileExtension: json['lrFileExtension'],
      lrFileUrl: json['lrFileUrl'],
      invoiceFileName: json['invoiceFileName'],
      invoiceFileLocation: json['invoiceFileLocation'],
      invoiceFileExtension: json['invoiceFileExtension'],
      invoiceFileUrl: json['invoiceFileUrl'],
      remarks: json['remarks'],
      isReceived: json['isReceived'],
    );
  }
}

