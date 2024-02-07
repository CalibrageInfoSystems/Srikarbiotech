import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:srikarbiotech/HomeScreen.dart';
import 'package:http/http.dart' as http;
import 'Common/CommonUtils.dart';
import 'Common/SharedPrefsData.dart';
import 'Model/OrderDetailsResponse.dart';
import 'orderdetails_model.dart';

class Orderdetails extends StatefulWidget {
  final int orderid;
  final String orderdate;
  final double totalprice;
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
        required this.totalprice,
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
  bool isDataLoaded = false;
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
  late List<GetOrderDetailsResult> orderDetails;
  late List<OrderItemXrefList> orderItemsList = [];
  int CompneyId = 0;
  @override
  void initState() {
    print('OrderId: ${widget.orderid}');
    super.initState();
    fetchData();
    getOrderDetails();
    fetchorderproducts().then((value) {
      setState(() {
        isDataLoaded = true;
      });
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
          });
          print("partyname====> ${partyname}");
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
      [widget.totalprice, widget.transportmode, widget.lrdate]
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

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: _appBar(),
        body: SingleChildScrollView(
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
                  child: Card(
                    color: Colors.white,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                top: 0.0, left: 0.0, right: 0.0),
                            child: Text(
                              '${partyname}',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Color(0xFFe78337),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          SizedBox(
                            height: 1.0,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 0.0, left: 0.0, right: 0.0),
                            child: Text(
                              '${partycode}',
                              style: TextStyle(
                                fontSize: 13.0,
                                color: Color(0xFF414141),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 0.0, left: 0.0, right: 0.0),
                            child: Text(
                              '${salesname}',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Color(0xFFe78337),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                  top: 0.0, left: 0.0, right: 0.0),
                              child: Container(
                                child: Row(
                                  children: [
                                    Text(
                                      'GST NO.',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                    Text(
                                      '${partygstnumber}',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Color(0xFFe78337),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                  ],
                                ),
                              )),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 0.0, left: 0.0, right: 0.0),
                            child: Text(
                              'Address',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Color(0xFF414141),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 0.0, left: 0.0, right: 0.0),
                            child: Text(
                              '${partyaddress}',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Color(0xFFe78337),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          // Add more widgets as needed
                        ],
                      ),
                    ),
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

                                //+  Spacer(),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    // height: 30,
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 10),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(25),
                                      color: getStatusTypeBackgroundColor(
                                          widget.statusname),
                                    ),
                                    child: IntrinsicWidth(
                                      stepWidth: 80.0,
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${widget.statusname}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color:
                                              getStatusTypeTextColor(
                                                  widget.statusname),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
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
                                              'Total',
                                              style: CommonUtils
                                                  .txSty_13B_Fb,
                                            ),
                                            Text(
                                              '${widget.totalprice}',
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
                                              'Transport Mode',
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
                                              'Preferable Transport',
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
                                              'PaymentMode',
                                              style: CommonUtils
                                                  .txSty_13B_Fb,
                                            ),
                                            Text(
                                              'Road',
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
                                              'LR Number',
                                              style: CommonUtils
                                                  .txSty_13B_Fb,
                                            ),
                                            Text(
                                              '${widget.lrnumber}',
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
                                              'LR Date',
                                              style: CommonUtils
                                                  .txSty_13B_Fb,
                                            ),
                                            Text(
                                              '',
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
                  height: 0.0,
                ),
                Container(
                  width: screenWidth,
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  //   height: screenHeight / 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    //        color: Colors.white,
                  ),
                  child: ListView.builder(
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

                              child: Column(
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
                                    child: Row(
                                      children: [
                                        // starting icon of card

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
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Text(
                                                          'Qty: ',
                                                          style: TextStyle(
                                                              fontFamily:
                                                              'Roboto',
                                                              fontSize:
                                                              14,
                                                              color: Colors
                                                                  .black,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w400),
                                                        ),
                                                        Text(
                                                          orderItemsList[
                                                          index]
                                                              .orderQty
                                                              .toString(),
                                                          style: const TextStyle(
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
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 5.0,
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      '₹${orderItemsList[index].totalPrice.toString()}',
                                                      style: const TextStyle(
                                                          fontFamily:
                                                          'Roboto',
                                                          fontSize: 14,
                                                          color: Color(
                                                              0xFFe58338),
                                                          fontWeight:
                                                          FontWeight
                                                              .w600),
                                                    ),
                                                    const SizedBox(
                                                      width: 15.0,
                                                    ),
                                                    // Text(
                                                    //   '',
                                                    //   style: TextStyle(
                                                    //     color:
                                                    //         Color(0xFFa6a6a6),
                                                    //     fontWeight:
                                                    //         FontWeight.bold,
                                                    //     fontSize: 13.0,
                                                    //     decoration:
                                                    //         TextDecoration
                                                    //             .lineThrough,
                                                    //   ),
                                                    // ),
                                                  ],
                                                )
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
                //     ),
                //    ),
                SizedBox(
                  height: 5.0,
                ),
                Container(
                    width: screenWidth,
                    padding: EdgeInsets.only(
                        top: 0.0, left: 10.0, right: 10.0),
                    child: IntrinsicHeight(
                        child: Card(
                          color: Colors.white,
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            width: screenWidth,
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(top: 0.0),
                                      child: Text(
                                        'Total',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                    Spacer(),
                                    Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                      MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          //   width: MediaQuery.of(context).size.width / 1.8,
                                          padding: EdgeInsets.only(top: 0.0),
                                          child: Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                            MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                '₹${totalcost}',
                                                style: TextStyle(
                                                  color: Color(0xFFe78337),
                                                  fontFamily: 'Roboto',
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )))
              ])
              : CircularProgressIndicator(),
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
}
