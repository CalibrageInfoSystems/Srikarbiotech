import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:srikarbiotech/Common/styles.dart';
import 'package:srikarbiotech/HomeScreen.dart';
import 'package:http/http.dart' as http;
import 'package:srikarbiotech/Services/api_config.dart';
import 'Common/CommonUtils.dart';
import 'Common/SharedPrefsData.dart';
import 'Model/OrderDetailsResponse.dart';
import 'ViewOrders.dart';
import 'orderdetails_model.dart';

class Orderdetails extends StatefulWidget {
  final int orderid;
  final String? whsName;
  final String? whscode;
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
  final Widget statusBar;

  const Orderdetails({
    super.key,
    required this.whsName,
    required this.whscode,
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
    required this.partyAddress,
    required this.statusBar,
  });

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
  late List<GetOrderDetailsResult> orderDetails = [];
  late List<OrderItemXrefList> orderItemsList = [];
  int CompneyId = 0;
  late Future<InvoiceApiResponse> futureData;
  InvoiceApiResponse? invoiceResponse;
  final bool _showBottomSheet = false;
  TextEditingController remarkstext = TextEditingController();

  final ExpansionTileController controller = ExpansionTileController();

  @override
  void initState() {
    Statusname = widget.statusname;
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
    String apiUrl = baseUrl + GetOrderDetailsById + orderid.toString();

    debugPrint("orderid====> $orderid");
    try {
      final apiData = await http.get(Uri.parse(apiUrl));

      if (apiData.statusCode == 200) {
        Map<String, dynamic> response = json.decode(apiData.body);
        if (response['isSuccess']) {
          List<dynamic> orderDetailsData =
              response['response']['getOrderDetailsResult'];
          List<GetOrderDetailsResult> getOrderDetailsListResult =
              orderDetailsData
                  .map((item) => GetOrderDetailsResult.fromJson(item))
                  .toList();
          orderDetails = List.from(getOrderDetailsListResult);

          setState(() {
            totalGst = orderDetails[0].gstCost;
            totalsum = orderDetails[0].totalCost;
            totalcost = orderDetails[0].totalCostWithGst;
          });

          List<dynamic> orderItemsData =
              response['response']['orderItemXrefList'];
          List<OrderItemXrefList> orderItemXrefListResult = orderItemsData
              .map((item) => OrderItemXrefList.fromJson(item))
              .toList();
          orderItemsList = List.from(orderItemXrefListResult);
        } else {
          debugPrint('api call unsuccessfull');
        }
      } else {
        debugPrint('else: api failed');
      }
    } catch (error) {
      CommonUtils.showCustomToastMessageLong('catch $error', context, 1, 4);
      debugPrint('catch: $error');
    }
  }

  Future<void> fetchorderproducts() async {
    print('fetchorderproducts called: $orderid');
    String apiUrl = baseUrl + GetOrderDetailsById + orderid.toString();
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      List<Map<String, dynamic>> items = [];
      for (final item in data['response']['orderItemXrefList']) {
        items.add({
          'itemGrpName': item['itemGrpName'],
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

  Future<List<String>> fetchData() async {
    tableCellValues = [
      [widget.orderdate, widget.bookingplace, widget.lrnumber],
      [widget.totalCostWithGST, widget.transportmode, widget.lrdate]
    ];

    List<String> stringList =
        tableCellValues.expand((row) => row).map((element) {
      return element.toString();
    }).toList();
    return stringList;
  }

  Color getStatusTypeBackgroundColor(String statusTypeId) {
    switch (statusTypeId) {
      case 'Pending':
        return const Color(0xFFE58338).withOpacity(0.1);
      case 'Shipped':
        return const Color(0xFF0d6efd).withOpacity(0.1);
      case 'Accepted':
        return const Color(0xFF198754).withOpacity(0.1);
      case 'Partially Shipped':
        return const Color(0xFF0dcaf0).withOpacity(0.1);
      case 'Reject':
        return const Color(0xFFdc3545).withOpacity(0.1);
        break;

      default:
        return Colors.white;
    }
  }

  Color getStatusTypeTextColor(String statusTypeId) {
    switch (statusTypeId) {
      case 'Pending':
        return const Color(0xFFe58338);
      case 'Shipped':
        return const Color(0xFF0d6efd);
      case 'Accepted':
        return const Color(0xFF198754);
      case 'Partially Shipped':
        return const Color(0xFF0dcaf0);
      case 'Reject':
        return const Color(0xFFdc3545);
        break;

      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: _appBar(),
      body: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: screenWidth,
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: CommonUtils.buildCard(
            widget.partyname,
            widget.partycode,
            widget.proprietorName,
            widget.partyGSTNumber,
            widget.partyAddress,
            Colors.white,
            BorderRadius.circular(5.0),
          ),
        ),
        isDataLoaded
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20)
                        .copyWith(top: 10),
                    child: const Text(
                      'Order Details',
                      style: CommonStyles.txSty_14b_fb,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Card(
                      elevation: 7,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: CommonStyles.whiteColor,
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Order ID',
                                        textAlign: TextAlign.start,
                                        style: CommonStyles.txSty_12b_fb,
                                      ),
                                      const SizedBox(
                                        height: 2.0,
                                      ),
                                      Text(
                                        widget.ordernumber,
                                        style: CommonStyles.txSty_12o_f7,
                                      ),
                                    ],
                                  ),
                                  widget.statusBar,
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
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
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Order Date',
                                              style: CommonStyles.txSty_12b_fb,
                                            ),
                                            const SizedBox(
                                              height: 2.0,
                                            ),
                                            Text(
                                              widget.orderdate,
                                              style: CommonStyles.txSty_12o_f7,
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
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Total Amount',
                                              style: CommonStyles.txSty_12b_fb,
                                            ),
                                            const SizedBox(
                                              height: 2.0,
                                            ),
                                            Text(
                                              '₹${formatNumber(widget.totalCostWithGST)}',
                                              style: CommonStyles.txSty_12o_f7,
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
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Booking Place',
                                              style: CommonStyles.txSty_12b_fb,
                                            ),
                                            const SizedBox(
                                              height: 2.0,
                                            ),
                                            Text(
                                              widget.bookingplace,
                                              style: CommonStyles.txSty_12o_f7,
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
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Transport Name',
                                              style: CommonStyles.txSty_12b_fb,
                                            ),
                                            const SizedBox(
                                              height: 2.0,
                                            ),
                                            Text(
                                              widget.transportmode,
                                              style: CommonStyles.txSty_12o_f7,
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
                                if (widget.whsName != null)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Warehouse',
                                                style:
                                                    CommonStyles.txSty_12b_fb,
                                              ),
                                              const SizedBox(
                                                height: 2.0,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    widget.whsName!,
                                                    style: TextStyle(
                                                      fontFamily: 'Roboto',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          HexColor('#e58338'),
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  Text(
                                                    ' (${widget.whscode})',
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
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                Visibility(
                                  visible: Remarks != null && Remarks != "",
                                  child: Column(
                                    children: [
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
                                                    'Remarks',
                                                    style: CommonStyles
                                                        .txSty_12b_fb,
                                                  ),
                                                  const SizedBox(
                                                    height: 2.0,
                                                  ),
                                                  Text(
                                                    '$Remarks',
                                                    style: CommonStyles
                                                        .txSty_12o_f7,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 0.2,
                                  color: Colors.grey,
                                ),
                                Visibility(
                                  visible: Statusname == 'Pending',
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      const Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'You can cancel this order before it got Approved ',
                                                style:
                                                    CommonStyles.txSty_12b_fb,
                                              ),
                                              Text(
                                                '',
                                                style:
                                                    CommonStyles.txSty_12o_f7,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                  "Confirmation",
                                                  style:
                                                      CommonStyles.txSty_12b_fb,
                                                ),
                                                content: const Text(
                                                  "Are you sure you want to cancel this order?",
                                                  style: CommonStyles
                                                      .txSty_12bs_fb,
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text(
                                                      "Cancel",
                                                      style: CommonStyles
                                                          .txSty_12b_fb,
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();

                                                      cancelOrder();
                                                    },
                                                    child: const Text(
                                                      "OK",
                                                      style: CommonStyles
                                                          .txSty_12o_f7,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: HexColor('#ffecee'),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          child: Row(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/crosscircle.svg',
                                                height: 18,
                                                width: 18,
                                                fit: BoxFit.fitWidth,
                                                color: HexColor('#de4554'),
                                              ),
                                              const SizedBox(width: 8.0),
                                              const Text(
                                                'Cancel',
                                                style:
                                                    CommonStyles.txSty_12o_f7,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  CustomExpansionTile(
                    title: const Text(
                      "Item Details",
                      style: CommonStyles.txSty_14w_fb,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    content: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.transparent,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: screenWidth,
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const PageScrollPhysics(),
                              itemCount: orderItemsList.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        top: 5, bottom: 2.5),
                                    color: Colors.transparent,
                                    child: Card(
                                      elevation: 5,
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: const Color.fromARGB(
                                                255, 255, 255, 255)),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      1.3,
                                                  child: Container(
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
                                                          style: CommonStyles
                                                              .txSty_14b_fb,
                                                          softWrap: true,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        const SizedBox(
                                                          height: 5.0,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              'Qty: ${orderItemsList[index].orderQty}',
                                                              style: CommonStyles
                                                                  .txSty_12b_fb,
                                                            ),
                                                            Text(
                                                              ' (${orderItemsList[index].orderQty} ${orderItemsList[index].salUnitMsr} = ${orderItemsList[index].orderQty * orderItemsList[index].numInSale}  Nos)',
                                                              style: CommonStyles
                                                                  .txSty_12o_f7,
                                                            ),
                                                          ],
                                                        ),
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 5),
                                                          width:
                                                              double.infinity,
                                                          height: 0.2,
                                                          color: Colors.grey,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Text(
                                                              '₹${formatNumber(orderItemsList[index].totalPrice)}',
                                                              style: CommonStyles
                                                                  .txSty_12o_f7,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
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
                          const SizedBox(
                            height: 15.0,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.only(
                                bottom: 5, left: 10.0, right: 10.0),
                            child: IntrinsicHeight(
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Colors.white,
                                  ),
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Sub Total',
                                            style: CommonStyles.txSty_12b_fb,
                                          ),
                                          Text(
                                            '₹${formatNumber(orderDetails[0].totalCost)}',
                                            style: CommonStyles.txSty_12o_f7,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8.0),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'GST',
                                            style: CommonStyles.txSty_12b_fb,
                                          ),
                                          Text(
                                            '₹${formatNumber(orderDetails[0].gstCost)}',
                                            style: CommonStyles.txSty_12o_f7,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8.0),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Total Amount',
                                            style: CommonStyles.txSty_12b_fb,
                                          ),
                                          Text(
                                            '₹${formatNumber(orderDetails[0].totalCostWithGst)}',
                                            style: CommonStyles.txSty_12o_f7,
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
                    ),
                    initiallyExpanded: false,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  if (invoiceResponse?.listResult != null &&
                      invoiceResponse!.listResult!.isNotEmpty)
                    CustomExpansionTile(
                      title: const Text(
                        "Invoice Details",
                        style: CommonStyles.txSty_12b_fb,
                        overflow: TextOverflow.ellipsis,
                      ),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          invoiceResponse?.listResult != null &&
                                  invoiceResponse!.listResult!.isNotEmpty
                              ? Container(
                                  width: screenWidth,
                                  padding: const EdgeInsets.only(
                                      left: 0.0, right: 0.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const PageScrollPhysics(),
                                    itemCount:
                                        invoiceResponse!.listResult!.length,
                                    itemBuilder: (context, index) {
                                      InvoiceDetails invoice =
                                          invoiceResponse!.listResult![index];
                                      DateTime date = invoice.invoiceDate;
                                      String invoicedateDate =
                                          DateFormat('dd MMM, yyyy')
                                              .format(date);

                                      return Container(
                                        width: screenWidth,
                                        padding: const EdgeInsets.only(
                                            left: 10.0, right: 10.0),
                                        child: Card(
                                          elevation: 7,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              color: invoice.isReceived ?? false
                                                  ? Colors.green
                                                  : Colors.redAccent,
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.white,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
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
                                                              style: CommonStyles
                                                                  .txSty_12b_fb,
                                                            ),
                                                            Text(
                                                              invoice.invoiceNo,
                                                              style: CommonStyles
                                                                  .txSty_12o_f7,
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
                                                            const EdgeInsets
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
                                                              style: CommonStyles
                                                                  .txSty_12b_fb,
                                                            ),
                                                            Text(
                                                              invoicedateDate,
                                                              style: CommonStyles
                                                                  .txSty_12o_f7,
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
                                                        padding:
                                                            const EdgeInsets
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
                                                            ),
                                                            Text(
                                                              '${invoice.totalInvoiceQty}',
                                                              style: CommonStyles
                                                                  .txSty_12o_f7,
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
                                                            const EdgeInsets
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
                                                              style: CommonStyles
                                                                  .txSty_12b_fb,
                                                            ),
                                                            Text(
                                                              '₹${formatNumber(invoice.totalAmountWithGST)}',
                                                              style: CommonStyles
                                                                  .txSty_12o_f7,
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
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Visibility(
                                                        visible: invoiceResponse!
                                                                .listResult![
                                                                    index]
                                                                .lrFileUrl !=
                                                            null,
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                  content:
                                                                      SizedBox(
                                                                    width: double
                                                                        .infinity,
                                                                    height: double
                                                                        .infinity,
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              Image.network(
                                                                            invoiceResponse!.listResult![index].lrFileUrl ??
                                                                                '',
                                                                            fit:
                                                                                BoxFit.contain,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  actions: [
                                                                    Container(
                                                                      margin: const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              10,
                                                                          right:
                                                                              10),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        color: Colors
                                                                            .white,
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            color:
                                                                                Colors.black.withOpacity(0.1),
                                                                            blurRadius:
                                                                                6,
                                                                            spreadRadius:
                                                                                3,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      child:
                                                                          IconButton(
                                                                        icon: const Icon(
                                                                            Icons
                                                                                .close,
                                                                            color:
                                                                                Colors.red),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
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
                                                            margin:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        4.0),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color(
                                                                  0xFFe78337),
                                                              border:
                                                                  Border.all(
                                                                color: const Color(
                                                                    0xFFe78337),
                                                                width: 1,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                            child:
                                                                IntrinsicWidth(
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Container(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            10.0),
                                                                    child: Row(
                                                                      children: [
                                                                        SvgPicture
                                                                            .asset(
                                                                          'assets/overview.svg',
                                                                          height:
                                                                              18,
                                                                          width:
                                                                              18,
                                                                          fit: BoxFit
                                                                              .fitWidth,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                        const SizedBox(
                                                                            width:
                                                                                8.0),
                                                                        const Text(
                                                                          'View LR',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.white,
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
                                                    const Spacer(),
                                                    Visibility(
                                                      visible:
                                                          invoice.isReceived ==
                                                              false,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            if (invoiceResponse
                                                                        ?.listResult !=
                                                                    null &&
                                                                invoiceResponse!
                                                                    .listResult!
                                                                    .isNotEmpty &&
                                                                !_showBottomSheet) {
                                                              for (InvoiceDetails invoice
                                                                  in invoiceResponse!
                                                                      .listResult!) {
                                                                if (invoice
                                                                        .isReceived ==
                                                                    false) {
                                                                  showBottomSheet(
                                                                      context,
                                                                      invoice
                                                                          .invoiceNo,
                                                                      invoicedateDate);
                                                                  break;
                                                                }
                                                              }
                                                            }
                                                          },
                                                          child: Container(
                                                            height: 35,
                                                            margin:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        4.0),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color(
                                                                  0xFFF8dac2),
                                                              border:
                                                                  Border.all(
                                                                color: const Color(
                                                                    0xFFe78337),
                                                                width: 1,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                            child:
                                                                IntrinsicWidth(
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Container(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            10.0),
                                                                    child: Row(
                                                                      children: [
                                                                        SvgPicture
                                                                            .asset(
                                                                          'assets/box-check.svg',
                                                                          height:
                                                                              18,
                                                                          width:
                                                                              18,
                                                                          fit: BoxFit
                                                                              .fitWidth,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                        const SizedBox(
                                                                            width:
                                                                                8.0),
                                                                        const Text(
                                                                          'Received',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.black,
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
                                                      visible: invoice
                                                                  .isReceived ==
                                                              true &&
                                                          invoice.invoiceFileUrl !=
                                                              null,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            String? pdfUrl = invoice
                                                                .invoiceFileUrl;
                                                            String? invoiceNo =
                                                                invoice
                                                                    .invoiceNo;
                                                            downloadFile(
                                                                pdfUrl!,
                                                                invoiceNo);
                                                          },
                                                          child: Container(
                                                            height: 35,
                                                            margin:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        4.0),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color(
                                                                  0xFFF8dac2),
                                                              border:
                                                                  Border.all(
                                                                color: const Color(
                                                                    0xFFe78337),
                                                                width: 1,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                            child:
                                                                IntrinsicWidth(
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Container(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            5.0),
                                                                    child: Row(
                                                                      children: [
                                                                        SvgPicture
                                                                            .asset(
                                                                          'assets/file-download.svg',
                                                                          height:
                                                                              18,
                                                                          width:
                                                                              18,
                                                                          fit: BoxFit
                                                                              .fitWidth,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                        const SizedBox(
                                                                            width:
                                                                                8.0),
                                                                        const Text(
                                                                            'Download Invoice',
                                                                            style:
                                                                                CommonUtils.Mediumtext_12),
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
                  const SizedBox(
                    height: 5.0,
                  ),
                ],
              )
            : SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: const Center(
                  child: CommonStyles.progressIndicator,
                ),
              ),
      ])),
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
                'Order Details',
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
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
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> getshareddata() async {
    CompneyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
  }

  Future<InvoiceApiResponse> fetchinvoicedata() async {
    ordernum = widget.ordernumber;
    String apiurl = baseUrl + GetInvoiceDetails + ordernum;
    print('apiurl===$apiurl');
    final response = await http.get(Uri.parse(apiurl));

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
    String apiUrl = baseUrl + UpdateOrderStatus;

    final String userId =
        await SharedPrefsData.getStringFromSharedPrefs("userId");

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
          print(responseData['endUserMessage']);
          CommonUtils.showCustomToastMessageLong(
              "Your Order Cancelled Successfully", context, 0, 3);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ViewOrders()),
          );
        } else {
          print('API request failed');
        }
      } else {
        print('HTTP error ${response.statusCode}');
      }
    } catch (error) {
      print('Network error: $error');
    }
  }

  void showBottomSheet(
      BuildContext context, String invoiceNo, String invoicedateDate) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Did party receive this $invoiceNo Shipment?',
                style: CommonUtils.Mediumtext_o_14,
              ),
              const SizedBox(height: 5),
              const Text(
                'If received, click on the Received button. If you have any queries, enter the remarks.',
                style: CommonUtils.Mediumtext_12_0,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      height: 35,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        color: const Color(0xfffffece6),
                        border: Border.all(
                          color: const Color(0xFFe6504d),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: IntrinsicWidth(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/crosscircle.svg',
                                    height: 18,
                                    width: 18,
                                    fit: BoxFit.fitWidth,
                                    color: const Color(0xFFe6504d),
                                  ),
                                  const SizedBox(width: 8.0),
                                  const Text(
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
                      Navigator.of(context).pop();

                      showRemarksBottomSheet(
                          context, invoiceNo, invoicedateDate);
                    },
                    child: Container(
                      height: 35,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        color: const Color(0xfffdfffe8),
                        border: Border.all(
                          color: const Color(0xFF009746),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: IntrinsicWidth(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/check.svg',
                                    height: 18,
                                    width: 18,
                                    fit: BoxFit.fitWidth,
                                    color: const Color(0xFF009746),
                                  ),
                                  const SizedBox(width: 8.0),
                                  const Text(
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
    remarkstext.text = "";
    ordernumber = widget.ordernumber;
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
                const Padding(
                  padding: EdgeInsets.only(
                      top: 15.0, left: 0.0, right: 0.0, bottom: 5.0),
                  child: Text(
                    'Remarks *',
                    style: CommonUtils.Mediumtext_o_14,
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
                    maxLines: null,
                    decoration: const InputDecoration(
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
                          updateInvoiceStatus(ordernumber!, invoiceNo, remarks);
                          Navigator.of(context).pop();
                        }
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
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void updateInvoiceStatus(
      String orderNumber, String invoiceNo, String remarks) async {
    final String userId =
        await SharedPrefsData.getStringFromSharedPrefs("userId");
    DateTime currentDate = DateTime.now();
    String formattedcurrentDate = DateFormat('yyyy-MM-dd').format(currentDate);
    print('Formatted Date: $formattedcurrentDate');

    String apiUrl = baseUrl + UpdateInvoiceStatus;

    final Map<String, dynamic> requestBody = {
      "OrderNumber": orderNumber,
      "InvoiceNo": invoiceNo,
      "IsReceived": true,
      "Remarks": remarks,
      "UpdatedBy": userId,
      "UpdatedDate": formattedcurrentDate,
    };
    print(jsonEncode(requestBody));

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
          print(responseData['endUserMessage']);
          CommonUtils.showCustomToastMessageLong(
              responseData['endUserMessage'], context, 0, 3);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ViewOrders()),
          );
        } else {
          print('API request failed');
        }
      } else {
        print('HTTP error ${response.statusCode}');
      }
    } catch (error) {
      print('Network error: $error');
    }
  }

  canLaunch(String? url) {}

  Future<void> downloadFile(String url, String invoiceNo) async {
    try {
      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Directory appDocDir =
            Directory('/storage/emulated/0/Download/Srikar_Groups');
        String fileName = "srikar_invoice_$invoiceNo.pdf";

        String filePath = '${appDocDir.path}/$fileName';

        if (!appDocDir.existsSync()) {
          appDocDir.createSync(recursive: true);
        }

        await File(filePath).writeAsBytes(response.bodyBytes);

        CommonUtils.showCustomToastMessageLong(
            'Invoice Downloaded Successfully', context, 0, 4);

        print('PDF path: $filePath');
      } else {
        print('Failed to download PDF: ${response.statusCode}');
      }
    } catch (e) {
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
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
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
                borderRadius: BorderRadius.circular(10.0),
                color: const Color(0xFFe78337),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(child: widget.title),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
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
              json['response']['listResult']
                  .map((x) => InvoiceDetails.fromJson(x)),
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
