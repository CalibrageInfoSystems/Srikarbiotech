import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikarbiotech/Common/CommonUtils.dart';
import 'package:http/http.dart' as http;
import 'package:srikarbiotech/sb_status.dart';
import 'package:srikarbiotech/transport_payment.dart';

import 'CartProvider.dart';
import 'Common/SharedPrefsData.dart';
import 'Createorderscreen.dart';
import 'HomeScreen.dart';
import 'Model/CartHelper.dart';
import 'Model/OrderItemXrefType.dart';
import 'orderStatusScreen.dart';

class Ordersubmit_screen extends StatefulWidget {
  final String cardName;
  final String cardCode;
  final String address;
  final String proprietorName;
  final String gstRegnNo;
  final String state;
  final String phone;
  final String whsCode;
  final String whsName;
  final String whsState;

  final double creditLine;
  final double balance;

  const Ordersubmit_screen({
    super.key,
    required this.cardName,
    required this.cardCode,
    required this.address,
    required this.state,
    required this.phone,
    required this.proprietorName,
    required this.gstRegnNo,
    required this.creditLine,
    required this.balance,
    required this.whsCode,
    required this.whsName,
    required this.whsState,
  });
  @override
  Order_submit_screen createState() => Order_submit_screen();
}

class Order_submit_screen extends State<Ordersubmit_screen> {
  // List<String> cartItems = [];
  List<OrderItemXrefType> cartItems = [];
  List<String> cartlistItems = [];
  List<TextEditingController> textEditingControllers = [];
  List<int> quantities = [];
  int globalCartLength = 0;
  TextEditingController quantityController = TextEditingController();
  TextEditingController bookingplacecontroller = TextEditingController();
  TextEditingController Parcelservicecontroller = TextEditingController();
  int CompneyId = 0;
  String? userId = "";
  String? slpCode = "";
  String? Compneyname = "";
  ValueNotifier<double> totalSumNotifier = ValueNotifier<double>(0.0);
  ValueNotifier<double> totalGstAmountNotifier = ValueNotifier<double>(0.0);
  ValueNotifier<double> totalAmountWithGst = ValueNotifier<double>(0.0);
  ValueNotifier<double> totalSumIncludingGst = ValueNotifier<double>(0.0);

  // double totalSumIncludingGst = 0.0;
  @override
  initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    getshareddata();
    print('Cart Items globalCartLength: $globalCartLength');
    print('cardName: ${widget.cardName}');
    print('cardCode: ${widget.cardCode}');
    print('address: ${widget.address}');
    updateTotalSumIncludingGst();
    GetPreviousOrderBookingByPartyCode(widget.cardCode);
    // totalAmountWithGst = calculateTotalAmountWithGst();
    // print('totalAmountWithGst $totalAmountWithGst');
    // totalSumNotifier = ValueNotifier<double>(calculateTotalSum(cartItems));
  }

  @override
  Widget build(BuildContext context) {
    cartItems = Provider.of<CartProvider>(context).getCartItems();
    // print('quantityinordersubmitscreen: ${cartItems.}');

    totalSumNotifier = ValueNotifier<double>(calculateTotalSum(cartItems));
    totalGstAmountNotifier =
        ValueNotifier<double>(calculateTotalGstAmount(cartItems));

    print('totalGstAmountNotifier $totalGstAmountNotifier');

    double newTotalSumIncludingGst =
        calculateTotalSum(cartItems) + calculateTotalGstAmount(cartItems);
    print('totalSumIncludingGst: $newTotalSumIncludingGst');

    // Only update the state if the new value is different from the current value
    if (newTotalSumIncludingGst != totalSumIncludingGst.value) {
      totalSumIncludingGst.value = newTotalSumIncludingGst;
    }

    // Calculate totalSumIncludingGst in the main widget
    //  totalSumIncludingGst = calculateTotalSum(cartItems) + calculateTotalGstAmount(cartItems);
    // print('totalSumIncludingGst $totalSumIncludingGst');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFe78337),
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  child: GestureDetector(
                    onTap: () {
                      // Handle the click event for the back button
                      try {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Createorderscreen(
                              cardName: widget.cardName,
                              cardCode: widget.cardCode,
                              address: widget.address,
                              state: widget.state,
                              phone: widget.phone,
                              proprietorName: widget.proprietorName,
                              gstRegnNo: widget.gstRegnNo,
                              creditLine: widget.creditLine,
                              balance: widget.balance,
                              whsCode: widget.whsCode,
                              whsName: widget.whsName,
                              whsState: widget.whsState,
                            ),
                          ),
                        );
                      } catch (e) {
                        print("Error navigating: $e");
                      }
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
                  'Order Submission ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                FutureBuilder(
                  future: getshareddata(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      // Access the cart data from the provider
                      cartItems =
                          Provider.of<CartProvider>(context).getCartItems();
                      // Update the globalCartLength
                      globalCartLength = cartItems.length;
                    }
                    // Always return a widget in the builder
                    return Text(
                      '($globalCartLength)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    );
                  },
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
                  // Return a placeholder or loading indicator
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonUtils.buildCard(
                    widget.cardName,
                    widget.cardCode,
                    widget.proprietorName,
                    widget.gstRegnNo,
                    widget.address,
                    Colors.white,
                    BorderRadius.circular(5.0),
                  ),
                  const SizedBox(height: 10.0),
                ],
              ),
            ),
            //           }
            //         },
            //       ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0),
              child: IntrinsicHeight(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(10.0),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Credit Limit',
                                style: TextStyle(
                                  color: Color(0xFF5f5f5f),
                                  fontFamily: "Roboto",
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '₹${widget.creditLine}',
                                style: const TextStyle(
                                  color: Color(0xFF5f5f5f),
                                  fontFamily: "Roboto",
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.0,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                            height: 5.0), // Add some space between rows
                        // Third Row: Outstanding Amount
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Outstanding Amount',
                                style: TextStyle(
                                  color: Color(0xFF5f5f5f),
                                  fontFamily: "Roboto",
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '₹${widget.balance}',
                                style: const TextStyle(
                                  color: Color(0xFF5f5f5f),
                                  fontFamily: "Roboto",
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.0,
                                ),
                                textAlign: TextAlign.right,
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
            const SizedBox(height: 5),
            FutureBuilder(
              future: Future.value(),
              builder: (context, snapshot) {
                // if (snapshot.connectionState == ConnectionState.waiting) {
                //   return CircularProgressIndicator();
                // } else
                // if (snapshot.connectionState == ConnectionState.done) {
                List<OrderItemXrefType> cartItems =
                Provider.of<CartProvider>(context).getCartItems();

                return buildListView(cartItems, ValueKey(cartItems));

                // }
                // else {
                //   return Text('Error: Unable to fetch cart data');
                // }
              },
            ),
            // ListView.builder(
            //     //  key: UniqueKey(),
            //     shrinkWrap: true,
            //     physics: PageScrollPhysics(),
            //     scrollDirection: Axis.vertical,
            //     itemCount: cartItems.length,
            //     itemBuilder: (context, index) {
            //       return buildListView(cartItems, ValueKey(cartItems[index]));
            //     }),

            Column(
              children: [
                // Padding(
                //   // height: screenHeight / 2.8,
                //   // width: screenWidth,
                //   // alignment: Alignment.center,
                //
                //   padding:
                //       EdgeInsets.only(top: 10.0, left: 10, right: 10, bottom: 10),
                //   child:
                Container(
                  padding: const EdgeInsets.only(
                      top: 5.0, left: 10, right: 10, bottom: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    // color: Colors.white,
                  ),
                  child: Card(
                    // color: Colors.white,
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    // You can adjust the elevation as needed
                    // Other card properties go here

                    child: Container(
                        padding: const EdgeInsets.only(
                            top: 0.0, left: 0, right: 0, bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.white,
                        ),
                        child: IntrinsicHeight(
                            child: Column(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.only(
                                      top: 15.0, left: 15.0, right: 15.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(
                                            top: 0.0, left: 0.0, right: 0.0),
                                        child: Text(
                                          'Booking Place * ',
                                          style: TextStyle(
                                              color: Color(0xFF5f5f5f),
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                      const SizedBox(height: 2.0),
                                      //  SizedBox(height: 8.0),
                                      GestureDetector(
                                        onTap: () {
                                          // Handle the click event for the second text view
                                          print('first textview clicked');
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(5.0),
                                            border: Border.all(
                                              color: const Color(0xFFe78337),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(
                                                        left: 10.0, top: 0.0),
                                                    child: TextFormField(
                                                      controller:
                                                      bookingplacecontroller,
                                                      keyboardType:
                                                      TextInputType.name,
                                                      maxLength: 50,
                                                      style: const TextStyle(
                                                          color: Color(0xFFe78337),
                                                          fontFamily: 'Roboto',
                                                          fontWeight:
                                                          FontWeight.w600,
                                                          fontSize: 14),
                                                      decoration:
                                                      const InputDecoration(
                                                        counterText: '',
                                                        hintText:
                                                        'Enter Booking Place',
                                                        hintStyle: TextStyle(
                                                          fontSize: 14,
                                                          fontFamily: 'Roboto',
                                                          fontWeight:
                                                          FontWeight.w700,
                                                          color: Color(0xa0e78337),
                                                        ),
                                                        border: InputBorder.none,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.only(
                                      top: 15.0,
                                      left: 15.0,
                                      right: 15.0,
                                      bottom: 20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(
                                            top: 0.0, left: 0.0, right: 0.0),
                                        child: Text(
                                          'Transport Name * ',
                                          style: TextStyle(
                                            color: Color(0xFF5f5f5f),
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                      const SizedBox(height: 2.0),
                                      GestureDetector(
                                        onTap: () {
                                          print('first textview clicked');
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(5.0),
                                            border: Border.all(
                                              color: const Color(0xFFe78337),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(
                                                        left: 10.0, top: 0.0),
                                                    child: TextFormField(
                                                      controller:
                                                      Parcelservicecontroller,
                                                      keyboardType:
                                                      TextInputType.name,
                                                      maxLength: 50,
                                                      style: const TextStyle(
                                                          color: Color(0xFFe78337),
                                                          fontFamily: 'Roboto',
                                                          fontWeight:
                                                          FontWeight.w600,
                                                          fontSize: 14),
                                                      decoration:
                                                      const InputDecoration(
                                                        counterText: '',
                                                        hintText:
                                                        'Enter Transport Name',
                                                        hintStyle: TextStyle(
                                                          fontSize: 14,
                                                          fontFamily: 'Roboto',
                                                          fontWeight:
                                                          FontWeight.w700,
                                                          color: Color(0xa0e78337),
                                                        ),
                                                        border: InputBorder.none,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ))),
                  ),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0),
              child: IntrinsicHeight(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
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
                            const Text(
                              'Sub Total',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                              ),
                            ),
                            ValueListenableBuilder<double>(
                              valueListenable: totalSumNotifier,
                              builder: (context, totalSum, child) {
                                return Text(
                                  '₹${formatNumber(totalSum)}',
                                  style: const TextStyle(
                                    color: Color(0xFFe78337),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'GST',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                              ),
                            ),
                            ValueListenableBuilder<double>(
                              valueListenable: totalGstAmountNotifier,
                              builder: (context, totalGstAmount, _) {
                                return Text(
                                  '₹${formatNumber(totalGstAmount)}',
                                  style: const TextStyle(
                                    color: Color(0xFFe78337),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                              ),
                            ),
                            ValueListenableBuilder<double>(
                              valueListenable: totalSumIncludingGst,
                              builder: (context, totalsumGstAmount, _) {
                                return Text(
                                  '₹${formatNumber(totalsumGstAmount)}',
                                  style: const TextStyle(
                                    color: Color(0xFFe78337),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0,
                                  ),
                                );
                              },
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

      bottomNavigationBar: Container(
        height: 60,
        margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  if (globalCartLength > 0) {
                    AddOrder();
                    // Add logic for the download button
                  } else {
                    CommonUtils.showCustomToastMessageLong(
                        'Please Add Atleast One Product', context, 1, 4);
                  }
                  print(' button clicked');
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFFe78337),
                  ),
                  child: const Center(
                    child: Text(
                      'Place Your Order',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight:
                        FontWeight.w700, // Set the font weight to bold
                        fontFamily: 'Roboto', // Set the font family to Roboto
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      //    ),
    );
  }

  void AddOrder() async {
    DateTime currentDate = DateTime.now();

    // Format the date as 'yyyy-MM-dd'
    String formattedcurrentDate = DateFormat('yyyy-MM-dd').format(currentDate);
    print('Formatted Date: $formattedcurrentDate');
    const String apiUrl =
        'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Order/AddOrder';
    List<Map<String, dynamic>> orderItemList = cartItems.map((cartItem) {
      int NoOfPcs = cartItem.orderQty! * cartItem.numInSale!;

      double orderQty = cartItem.orderQty?.toDouble() ?? 0.0;
      double price = cartItem.price ?? 0.0;
      double numInSale = cartItem.numInSale?.toDouble() ?? 0.0;

      double totalPrice = orderQty * price * numInSale;
      double totalgstPrice = (totalPrice * cartItem.gst! / 100);
      double totalPriceWithGST =
          totalPrice + (totalPrice * cartItem.gst! / 100);

      print('Order Quantity: $orderQty');
      print('Price: $price');
      print('Num In Sale: $numInSale');
      print('Total Price: $totalPrice');
      print('Total Price With GST: $totalPriceWithGST');

      return {
        "Id": 1,
        "OrderId": 2,
        "ItemGrpCod": cartItem.itemGrpCod,
        "ItemGrpName": cartItem.itemGrpName,
        "ItemCode": cartItem.itemCode,
        "ItemName": cartItem.itemName,
        "NoOfPcs": NoOfPcs,
        "OrderQty": cartItem.orderQty,
        "Price": cartItem.price,
        "UgpName": cartItem.ugpName,
        "NumInSale": cartItem.numInSale,
        "SalUnitMsr": cartItem.salUnitMsr,
        "GST": cartItem.gst,
        "TotalPrice": totalPrice,
        "TotalPriceWithGST": totalPriceWithGST,
        "GSTPrice": totalgstPrice,
        "TaxCode":"",

        // Map other cart item properties to corresponding fields
        // ...
      };
    }).toList();
    // Calculate the sum of prices for the entire order
    double totalCost = orderItemList.fold(
        0.0, (sum, item) => sum + (item['TotalPrice'] ?? 0.0));
    double totalCostWithGST = orderItemList.fold(
        0.0, (sum, item) => sum + (item['TotalPriceWithGST'] ?? 0.0));
    double totalGSTCost =
    orderItemList.fold(0.0, (sum, item) => sum + (item['GSTPrice'] ?? 0.0));
    print('Total Price: $totalCostWithGST');
    print('Total Price With GST: $totalGSTCost');
    bool isValid = true;
    bool hasValidationFailed = false;
    if (isValid && bookingplacecontroller.text.isEmpty) {
      CommonUtils.showCustomToastMessageLong(
          'Please Enter Booking Place', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }

    if (isValid && Parcelservicecontroller.text.isEmpty) {
      CommonUtils.showCustomToastMessageLong(
          'Please Enter Transport Name', context, 1, 4);

      isValid = false;
      hasValidationFailed = true;
    }

    Map<String, dynamic> orderData = {
      "OrderItemXrefTypeList": orderItemList,
      "Id": 1,
      "CompanyId": CompneyId,
      "OrderNumber": "",
      "OrderDate": formattedcurrentDate,
      "PartyCode": widget.cardCode,
      "PartyName": widget.cardName,
      "PartyAddress": widget.address,
      "PartyState": widget.state,
      "PartyPhoneNumber": widget.phone,
      "PartyGSTNumber": widget.gstRegnNo,
      "ProprietorName": widget.proprietorName,
      "PartyOutStandingAmount": '${widget.balance}',
      "BookingPlace": bookingplacecontroller.text,
      "TransportName": Parcelservicecontroller.text,
      "FileName": "",
      "FileLocation": "",
      "FileExtension": "",
      "StatusTypeId": 1,
      "Discount": 1.1,
      "TotalCost": totalCost,
      "TotalCostWithGST": totalCostWithGST,
      "GSTCost": totalGSTCost,
      "Remarks": "",
      "IsActive": true,
      "CreatedBy": userId,
      "CreatedDate": formattedcurrentDate,
      "UpdatedBy": userId,
      "UpdatedDate": formattedcurrentDate,
      "SHRemarks": "",
      "RejectedRemarks": "",
      "WhsCode":  widget.whsCode,
      "WhsName":  widget.whsName,
      "WhsState":  widget.whsState
    };
    print(jsonEncode(orderData));
    if (isValid) {
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(orderData),
        );

        if (response.statusCode == 200) {
          // Successful request

          final responseData = jsonDecode(response.body);
          print(responseData);
          if (responseData['isSuccess']) {
            final cartProvider = context.read<CartProvider>();

            clearCartData(cartProvider);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => orderStatusScreen(
                  responseData: responseData,
                  Compneyname: Compneyname,
                ),
              ),
            );
          } else {
            CommonUtils.showCustomToastMessageLong(
                responseData['endUserMessage'], context, 1, 4);
          }
          // clearCartItems();
          // printRemainingCartItems();
        } else {
          // Handle errors
          print('Error: ${response.reasonPhrase}');
        }
      } catch (e) {
        // Handle exceptions
        print('Exception: $e');
      }
    }
  }

  void printRemainingCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? cartItems = prefs.getStringList('cartItems');
    int remainingCartItems = cartItems?.length ?? 0;
    print('RemainingCartItems: $remainingCartItems');
  }

  void clearCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('cartItems');
  }

  Future<void> getshareddata() async {
    userId = await SharedPrefsData.getStringFromSharedPrefs("userId");
    slpCode = await SharedPrefsData.getStringFromSharedPrefs("slpCode");
    CompneyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
    Compneyname = await SharedPrefsData.getStringFromSharedPrefs("companyName");
    print('User ID: $userId');
    print('SLP Code: $slpCode');
    print('Company ID: $CompneyId');
  }

  Widget buildListView(List<OrderItemXrefType> cartItems, Key key) {
    updateTotalSum(cartItems);

    return ListView.builder(
      // key: UniqueKey(),
      key: key,
      shrinkWrap: true,
      physics: const PageScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        OrderItemXrefType cartItem = cartItems[index];
        if (cartItems.length != textEditingControllers.length) {
          textEditingControllers = List.generate(
              cartItems.length, (index) => TextEditingController());
        }
        double orderQty = cartItem.orderQty?.toDouble() ?? 0.0;
        double price = cartItem.price ?? 0.0;
        double numInSale = cartItem.numInSale?.toDouble() ?? 0.0;
        double totalPrice = orderQty * price * numInSale;

        // Update totalSumNotifier with the correct value
        totalSumNotifier.value = calculateTotalSum(cartItems);
        totalGstAmountNotifier.value = calculateTotalGstAmount(cartItems);

        double totalSumForProduct = calculateTotalSumForProduct(cartItem);
        // Print totalSumNotifier
        print('totalSumNotifier: ${totalSumNotifier.value}');

        return CartItemWidget(
          key: UniqueKey(), // Ensure each item has a unique key
          cartItem: cartItem,
          onDelete: () {
            setState(() {
              cartItems.removeAt(index);
              textEditingControllers.removeAt(index);
              updateTotalSumIncludingGst(); // Update totalSumIncludingGst after removing an item
            });
          },
          totalPrice: totalPrice,
          cartItems: cartItems,
          totalSumNotifier: totalSumNotifier,
          totalGstAmountNotifier: totalGstAmountNotifier,
          onQuantityChanged: () {
            updateTotalSumIncludingGst(); // Update totalSumIncludingGst when quantity changes
          },
        );
      },
    );
  }

  double calculateTotalSum(List<OrderItemXrefType> cartItems) {
    double sum = 0.0;
    for (OrderItemXrefType cartItem in cartItems) {
      double orderQty = cartItem.orderQty?.toDouble() ?? 0.0;
      double price = cartItem.price ?? 0.0;
      double numInSale = cartItem.numInSale?.toDouble() ?? 0.0;
      sum += orderQty * price * numInSale;
    }
    return sum;
  }

  void clearCartData(CartProvider cartProvider) {
    cartProvider.clearCart();
  }

// Update totalSumNotifier when the total sum changes
  void updateTotalSum(List<OrderItemXrefType> cartItems) {
    double totalSum = calculateTotalSum(cartItems);
    totalSumNotifier.value = totalSum;
  }

  double calculateTotalGstAmount(List<OrderItemXrefType> cartItems) {
    double totalGstAmount = 0.0;
    for (OrderItemXrefType item in cartItems) {
      totalGstAmount += calculateGstPrice(
        calculateTotalSumForProduct(item),
        item.gst,
      );
    }
    return totalGstAmount;
  }

  double calculateGstPrice(double totalSum, double? gst) {
    return (totalSum * gst!) / 100.0;
  }

  double calculateTotalAmountWithGst() {
    // Calculate the total amount with GST here
    return totalSumNotifier.value + totalGstAmountNotifier.value;
  }

  void updateTotalSumIncludingGst() {
    // Recalculate totalSumIncludingGst without triggering a rebuild
    double newTotalSumIncludingGst =
        calculateTotalSum(cartItems) + calculateTotalGstAmount(cartItems);
    print('totalSumIncludingGst: $newTotalSumIncludingGst');

    // Only update the state if the new value is different from the current value
    if (newTotalSumIncludingGst != totalSumIncludingGst.value) {
      totalSumIncludingGst.value = newTotalSumIncludingGst;
    }
  }

  String formatNumber(double number) {
    NumberFormat formatter = NumberFormat("#,##,##,##,##,##,##0.00", "en_US");
    return formatter.format(number);
  }

  Future<void> GetPreviousOrderBookingByPartyCode(String cardCode) async {
    try {
      // Make a GET request to the API endpoint
      http.Response response = await http.get(Uri.parse(
          "http://182.18.157.215/Srikar_Biotech_Dev/API/api/Order/GetPreviousOrderBookingByPartyCode/$cardCode"));

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Parse the JSON response

        Map<String, dynamic> data = jsonDecode(response.body);

        // Check if 'response' field is not null
        if (data['response'] != null) {
          // Extract the values of bookingPlace and transportName
          String bookingPlace = data['response']['bookingPlace'];
          String transportName = data['response']['transportName'];

          // Update the text field controllers with the received data
          bookingplacecontroller.text = bookingPlace;
          Parcelservicecontroller.text = transportName;
        } else {
          // If 'response' field is null, show a message or handle it as per your requirement
          print('No data available.');
        }
      } else {
        // If the request was not successful, print an error message
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      // If an error occurs during the fetching process, print the error
      print('Error fetching data: $e');
    }
  }
}

// In CartItemWidget

// In CartItemWidget
class CartItemWidget extends StatefulWidget {
  final OrderItemXrefType cartItem;
  final Function onDelete;
  final double totalPrice;
  final List<OrderItemXrefType> cartItems;
  final ValueNotifier<double> totalSumNotifier;
  final ValueNotifier<double> totalGstAmountNotifier;
  final VoidCallback onQuantityChanged;

  const CartItemWidget({
    required this.cartItem,
    required this.onDelete,
    required this.totalPrice,
    required this.cartItems,
    required this.totalSumNotifier,
    required this.totalGstAmountNotifier,
    required this.onQuantityChanged,
    required UniqueKey key,
  }) : super(key: key);

  @override
  _CartItemWidgetState createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  late TextEditingController _textController;
  late int _orderQty;
  double gstPrice = 0.0;
  double totalGstAmount = 0.0;
  late int Quantity = 0;
  double totalSumForProduct = 0.0;
  double totalSum = 0.0;
  @override
  void initState() {
    super.initState();
    // _orderQty = widget.cartItem.orderQty ?? 0;
    _orderQty = widget.cartItem.orderQty ?? 1;
    Quantity = widget.cartItem.orderQty!;
    print('Quantity==$Quantity');

    _textController = TextEditingController(text: _orderQty.toString());
    widget.totalSumNotifier.value = calculateTotalSum(widget.cartItems);
    widget.totalGstAmountNotifier.value =
        calculateTotalGstAmount(widget.cartItems);
    // Initialize totalSumNotifier in initState
  }

  @override
  Widget build(BuildContext context) {
    double totalWidth = MediaQuery.of(context).size.width;

    // Calculate totalSum for all products
    // Calculate totalSum for all products

    // Calculate totalSumForProduct for the single product
    // double totalSumForProduct = calculateTotalSumForProduct(widget.cartItem);
    // gstPrice = calculateGstPrice(totalSumForProduct, widget.cartItem.gst);

    // Calculate total sum including GST
    totalSum = calculateTotalSum(widget.cartItems);
    gstPrice = calculateGstPrice(totalSumForProduct, widget.cartItem.gst);
    totalSumForProduct = calculateTotalSumForProduct(widget.cartItem);
    print('totalSumForProduct==$totalSumForProduct');

    widget.onQuantityChanged();
    double totalSumIncludingGst =
        totalSum + widget.totalGstAmountNotifier.value;
    print('totalSumIncludingGst==$totalSumIncludingGst');

    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
      child: Card(
        elevation: 5.0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(8.0),
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '${widget.cartItem.itemName}',
              style: CommonUtils.Mediumtext_14,
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '₹${formatNumber(totalSumForProduct)}',
                    style: CommonUtils.Mediumtext_o_14,
                  ),
                ),
                Text(
                  '$Quantity ${widget.cartItem.salUnitMsr} = ${Quantity * widget.cartItem.numInSale!}  Nos', // Display totalSumForProduct for the single product
                  style: CommonUtils.Mediumtext_o_14,
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: (totalWidth - 40) / 2,
                  child: SizedBox(
                    width: (totalWidth - 40) / 2,
                    child: PlusMinusButtons(
                      addQuantity: () {
                        setState(() {
                          Quantity++;
                          // totalSumForProduct =
                          //     calculateTotalSumForProduct(widget.cartItem);
                          // print('totalSumForProductplus==$totalSumForProduct');
                          formatNumber(totalSumForProduct);
                          _orderQty = (_orderQty ?? 0) + 1;
                          _textController.text = _orderQty.toString();
                          // Call the updateQuantity method in your model class
                          widget.cartItem.updateQuantity(_orderQty);
                          widget.totalSumNotifier.value =
                              calculateTotalSum(widget.cartItems);
                          widget.totalGstAmountNotifier.value =
                              calculateTotalGstAmount(widget.cartItems);
                          widget
                              .onQuantityChanged(); // Call onQuantityChanged callback
                        });
                      },
                      deleteQuantity: () {
                        setState(() {
                          if (_orderQty > 1) {
                            Quantity--;
                            // totalSumForProduct =
                            //     calculateTotalSumForProduct(widget.cartItem);
                            formatNumber(totalSumForProduct);
                            print(
                                'totalSumForProductminus==$totalSumForProduct');
                            formatNumber(totalSumForProduct);
                            _orderQty = (_orderQty ?? 0) - 1;
                            _textController.text = _orderQty.toString();
                            widget.cartItem.updateQuantity(_orderQty);
                            widget.totalSumNotifier.value =
                                calculateTotalSum(widget.cartItems);
                            widget.totalGstAmountNotifier.value =
                                calculateTotalGstAmount(widget.cartItems);
                            widget
                                .onQuantityChanged(); // Call onQuantityChanged callback
                          }
                        });
                      },
                      textController: _textController,
                      orderQuantity:
                      _orderQty, // Pass _orderQty as orderQuantity
                      // Pass the onQuantityChanged callback function
                      updateTotalPrice: (int value) {
                        // Your updateTotalPrice logic, if any
                        setState(() {
                          Quantity = value;
                          _orderQty = value;
                          widget.cartItem.updateQuantity(_orderQty);
                          widget.totalSumNotifier.value =
                              calculateTotalSum(widget.cartItems);
                          widget.totalGstAmountNotifier.value =
                              calculateTotalGstAmount(widget.cartItems);
                          widget.onQuantityChanged();
                        });
                      },
                      onQuantityChanged: (int value) {
                        setState(() {
                          _orderQty = value;
                          Quantity = value;
                          widget.cartItem.updateQuantity(_orderQty);
                          widget.totalSumNotifier.value =
                              calculateTotalSum(widget.cartItems);
                          widget.totalGstAmountNotifier.value =
                              calculateTotalGstAmount(widget.cartItems);
                          widget.onQuantityChanged();
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                GestureDetector(
                  onTap: () {
                    widget.onDelete();
                  },
                  child: Container(
                    height: 36,
                    width: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8dac2),
                      border: Border.all(
                        color: const Color(0xFFe78337),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete,
                              size: 18.0,
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
          ]),
        ),
      ),
    );
  }

  double calculateGstPrice(double totalSum, double? gst) {
    return (totalSum * gst!) / 100.0;
  }

  double calculateTotalGstAmount(List<OrderItemXrefType> cartItems) {
    double totalGstAmount = 0.0;
    for (OrderItemXrefType item in cartItems) {
      totalGstAmount += calculateGstPrice(
        calculateTotalSumForProduct(item),
        item.gst,
      );
    }
    return totalGstAmount;
  }

  String formatNumber(double number) {
    NumberFormat formatter = NumberFormat("#,##,##,##,##,##,##0.00", "en_US");
    return formatter.format(number);
  }
}

// In PlusMinusButtons widget

class PlusMinusButtons extends StatelessWidget {
  final VoidCallback deleteQuantity;
  final VoidCallback addQuantity;
  final TextEditingController textController;
  final int orderQuantity; // Add orderQuantity parameter
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<int> updateTotalPrice;

  const PlusMinusButtons({
    Key? key,
    required this.addQuantity,
    required this.deleteQuantity,
    required this.textController,
    required this.orderQuantity, // Include orderQuantity parameter
    required this.onQuantityChanged,
    required this.updateTotalPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 2.3,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFe78337),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Card(
        color: const Color(0xFFe78337),
        margin: const EdgeInsets.symmetric(horizontal: 0.0),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                deleteQuantity();
                _updateTextController();
              },
              icon: SvgPicture.asset(
                'assets/minus-small.svg', // Replace with the correct path to your SVG icon
                color: Colors.white,
                width: 20.0,
                height: 20.0,
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: 36,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width / 5,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: TextField(
                        controller: textController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(5),
                        ],
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.only(bottom: 10.0),
                        ),
                        textAlign: TextAlign.center,
                        style: CommonUtils.Mediumtext_o_14,
                        onChanged: (newValue) {
                          if (newValue.isNotEmpty) {
                            int newOrderQuantity = int.tryParse(newValue) ?? 0;
                            print('textchanged:$newOrderQuantity');
                            onQuantityChanged(newOrderQuantity);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                addQuantity();
                _updateTextController();
              },
              icon: SvgPicture.asset(
                'assets/plus-small.svg', // Replace with the correct path to your SVG icon
                color: Colors.white,
                width: 20.0,
                height: 20.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateTextController() {
    print('Current Value: ${textController.text}');
  }
}

// class PlusMinusButtons extends StatefulWidget {
//   final VoidCallback deleteQuantity;
//   final VoidCallback addQuantity;
//   final int initialValue;
//   final ValueChanged<int> onQuantityChanged;
//   final ValueChanged<int> updateTotalPrice;
//
//   PlusMinusButtons({
//     Key? key,
//     required this.addQuantity,
//     required this.deleteQuantity,
//     required this.initialValue,
//     required this.onQuantityChanged,
//     required this.updateTotalPrice,
//     required TextEditingController textController,
//   }) : super(key: key);
//
//   @override
//   _PlusMinusButtonsState createState() => _PlusMinusButtonsState();
// }

// class _PlusMinusButtonsState extends State<PlusMinusButtons> {
//   late TextEditingController _textController;
//
//   @override
//   void initState() {
//     super.initState();
//     _textController =
//         TextEditingController(text: widget.initialValue.toString());
//   }
//
//   int simpleIntInput = 0;
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: MediaQuery.of(context).size.width / 2.3,
//       height: 38,
//       decoration: BoxDecoration(
//         color: Color(0xFFe78337),
//         borderRadius: BorderRadius.circular(8.0),
//       ),
//       child: Card(
//         color: Color(0xFFe78337),
//         margin: EdgeInsets.symmetric(horizontal: 0.0),
//         child: Row(
//           children: [
//             IconButton(
//               onPressed: () {
//                 widget.deleteQuantity();
//                 _updateTextController();
//               },
//               icon: SvgPicture.asset(
//                 'assets/minus-small.svg',
//                 color: Colors.white,
//                 width: 20.0,
//                 height: 20.0,
//               ),
//             ),
//             Expanded(
//               child: Align(
//                 alignment: Alignment.center,
//                 child: Container(
//                   height: 36,
//                   child: Padding(
//                     padding: const EdgeInsets.all(2.0),
//                     child: Container(
//                       alignment: Alignment.center,
//                       width: MediaQuery.of(context).size.width / 5,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                       ),
//                       child:TextField(
//                         controller: _textController,
//                         keyboardType: TextInputType.number,
//                         inputFormatters: <TextInputFormatter>[
//                           FilteringTextInputFormatter.digitsOnly,
//                           LengthLimitingTextInputFormatter(5),
//                         ],
//                         decoration: InputDecoration(
//                           border: InputBorder.none,
//                           focusedBorder: InputBorder.none,
//                           enabledBorder: InputBorder.none,
//                           contentPadding: EdgeInsets.only(bottom: 10.0),
//                         ),
//                         textAlign: TextAlign.center,
//                         style: CommonUtils.Mediumtext_o_14,
//                         onChanged: (value) {
//                           widget.onQuantityChanged(int.parse(value));
//                           widget.updateTotalPrice(int.parse(value));
//                           // Update the text controller when the value changes
//                           _textController.text = value;
//                         },
//                       ),
//
//
//                       // TextField(
//                       //   controller: _textController,
//                       //   keyboardType: TextInputType.number,
//                       //   inputFormatters: <TextInputFormatter>[
//                       //     FilteringTextInputFormatter.digitsOnly,
//                       //     LengthLimitingTextInputFormatter(5),
//                       //   ],
//                       //   decoration: InputDecoration(
//                       //     border: InputBorder.none,
//                       //     focusedBorder: InputBorder.none,
//                       //     enabledBorder: InputBorder.none,
//                       //     contentPadding: EdgeInsets.only(bottom: 10.0),
//                       //   ),
//                       //   textAlign: TextAlign.center,
//                       //   style: CommonUtils.Mediumtext_o_14,
//                       //   onChanged: (value) {
//                       //     widget.onQuantityChanged(int.parse(value));
//                       //     // widget.updateTotalPrice();
//                       //     widget.updateTotalPrice(int.parse(value));
//                       //   },
//                       // ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             IconButton(
//               onPressed: () {
//                 widget.addQuantity();
//                 _updateTextController();
//               },
//               icon: SvgPicture.asset(
//                 'assets/plus-small.svg',
//                 color: Colors.white,
//                 width: 20.0,
//                 height: 20.0,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _updateTextController() {
//     setState(() {
//       _textController.text = widget.initialValue.toString();
//     });
//   }
//
//   @override
//   void dispose() {
//     _textController.dispose();
//     super.dispose();
//   }
// }

double calculateTotalSumForProduct(OrderItemXrefType cartItem) {
  return cartItem.orderQty! *
      cartItem.price! *
      (cartItem.numInSale?.toDouble() ?? 0.0);
}

double calculateTotalSum(List<OrderItemXrefType> cartItems) {
  double totalSum = 0.0;
  for (OrderItemXrefType cartItem in cartItems) {
    totalSum += cartItem.orderQty! *
        cartItem.price! *
        (cartItem.numInSale?.toDouble() ?? 0.0);
  }
  return totalSum;
}
