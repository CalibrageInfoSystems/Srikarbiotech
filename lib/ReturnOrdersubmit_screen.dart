import 'dart:convert';
import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikarbiotech/Common/CommonUtils.dart';
import 'package:http/http.dart' as http;
import 'package:srikarbiotech/Returntransportdetails.dart';
import 'package:srikarbiotech/Services/api_config.dart';
import 'package:srikarbiotech/sb_status.dart';

import 'CartProvider.dart';
import 'Common/SharedPrefsData.dart';
import 'HomeScreen.dart';
import 'Model/OrderItemXrefType.dart';
import 'Model/ReturnOrderItemXrefType.dart';
import 'ReturnorderStatusScreen.dart';
import 'orderStatusScreen.dart';

class ReturnOrdersubmit_screen extends StatefulWidget {
  final String cardName;
  final String cardCode;
  final String address;
  final String proprietorName;
  final String gstRegnNo;
  final String state;
  final String phone;
  final String LrNumber;
  final String Lrdate;
  final String Remarks;
  final String LRAttachment;
  final String ReturnOrderReceipt;
  final String addlattchments;
  final double creditLine;
  final double balance;
  final String transportname;
  final String whsCode;
  final String whsName;
  final String whsState;

  const ReturnOrdersubmit_screen(
      {super.key,
      required this.cardName,
      required this.cardCode,
      required this.address,
      required this.state,
      required this.phone,
      required this.proprietorName,
      required this.gstRegnNo,
      required this.LrNumber,
      required this.Lrdate,
      required this.Remarks,
      required this.LRAttachment,
      required this.ReturnOrderReceipt,
      required this.addlattchments,
      required this.creditLine,
      required this.balance,
      required this.transportname,
      required this.whsCode,
      required this.whsName,
      required this.whsState});
  @override
  returnOrder_submit_screen createState() => returnOrder_submit_screen();
}

class returnOrder_submit_screen extends State<ReturnOrdersubmit_screen> {
  final _orangeColor = HexColor('#e58338');

  final _titleTextStyle = const TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w700,
    color: Colors.black,
    fontSize: 16,
  );

  final _dataTextStyle = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.bold,
    color: HexColor('#e58338'),
    fontSize: 12,
  );

  final dividerForHorizontal = Container(
    width: double.infinity,
    height: 1,
    color: Colors.grey,
  );
  final dividerForVertical = Container(
    width: 1,
    height: 60,
    color: Colors.grey,
  );

  List attachments = [];
  List<ReturnOrderItemXrefType> cartItems = [];
  List<String> cartlistItems = [];
  List<TextEditingController> textEditingControllers = [];
  List<int> quantities = [];
  int globalCartLength = 0;
  TextEditingController quantityController = TextEditingController();
  late List<String> imageUrls;
  int CompneyId = 0;
  String? userId = "";
  String? slpCode = "";
  double totalSum = 0.0;
  String LrDate1 = "";
  String LrDate2 = "";
  int currentIndex = 0;
// late String lrattachment, ReturnOrderReceipt, addlattchments;
  @override
  initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    getshareddata();
    imageUrls = [
      'data:image/png;base64,${widget.LRAttachment}',
      'data:image/png;base64,${widget.ReturnOrderReceipt}',
      'data:image/png;base64,${widget.addlattchments}',
    ];

    // work
    setAttachments(
      att1: widget.LRAttachment,
      att2: widget.ReturnOrderReceipt,
      att3: widget.addlattchments,
    );
  }

  void setAttachments({
    required String att1,
    required String att2,
    required String att3,
  }) {
    if (att1.isNotEmpty) {
      attachments.add(att1);
    }
    if (att2.isNotEmpty) {
      attachments.add(att2);
    }
    if (att3.isNotEmpty) {
      attachments.add(att3);
    }
  }

  @override
  Widget build(BuildContext context) {
    cartItems = Provider.of<CartProvider>(context).getReturnCartItems();
    totalSum = calculateTotalSum(cartItems);

    String dateString = widget.Lrdate;
    print('dateString==>$dateString');
    // Format: dd MMM, yyyy
    LrDate1 = formatDate(dateString, "dd MMM, yyyy");
    print("Formatted Date 1: $LrDate1");

    // Format: yyyy-MM-dd
    LrDate2 = formatDate(dateString, "yyyy-MM-dd");
    print("Formatted Date 2: $LrDate2");
    // DateTime date = DateTime.parse(dateString);
    // String formattedDate = DateFormat('dd MMM, yyyy').format(date);
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
                  'Return Order Submission ',
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
                      cartItems = Provider.of<CartProvider>(context).getReturnCartItems();
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
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    },
                    child: Image.asset(
                      CompneyId == 1 ? 'assets/srikar-home-icon.png' : 'assets/seeds-home-icon.png',
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
                  // const SizedBox(height: 5.0),
                ],
              ),
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
                        const SizedBox(height: 5.0), // Add some space between rows
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
            // const SizedBox(height: 5),
            FutureBuilder(
              future: Future.value(),
              builder: (context, snapshot) {
                // if (snapshot.connectionState == ConnectionState.waiting) {
                //   return CircularProgressIndicator();
                // } else
                // if (snapshot.connectionState == ConnectionState.done) {
                cartItems = Provider.of<CartProvider>(context).getReturnCartItems();

                return buildListView(cartItems, ValueKey(cartItems));

                // }
                // else {
                //   return Text('Error: Unable to fetch cart data');
                // }
              },
            ),

            // FutureBuilder(
            //   future: Future.value(),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return CircularProgressIndicator();
            //     } else if (snapshot.connectionState == ConnectionState.done) {
            //       // Assuming `buildListView` is defined elsewhere
            //       cartItems =
            //           Provider.of<CartProvider>(context).getReturnCartItems();
            //       return buildListView(); // Assuming this function returns a widget
            //     } else {
            //       return Text('Error: Unable to fetch cart data');
            //     }
            //   },
            // ),
            // const SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 0.0, left: 10.0, right: 10.0),
              child: IntrinsicHeight(
                child: Card(
                  elevation: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    width: double.infinity, // remove padding here
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // row one
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Transport Details',
                                style: _titleTextStyle,
                              ),
                              InkWell(
                                onTap: () {
                                  // Your click listener logic here
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Returntransportdetails(
                                            cardName: widget.cardName,
                                            cardCode: widget.cardCode,
                                            address: widget.address,
                                            state: widget.state,
                                            phone: widget.phone,
                                            proprietorName: widget.proprietorName,
                                            gstRegnNo: widget.gstRegnNo,
                                            lrnumber: widget.LrNumber,
                                            lrdate: widget.Lrdate,
                                            remarks: widget.Remarks,
                                            creditLine: double.parse('${widget.creditLine}'), // Convert to double
                                            balance: double.parse('${widget.balance}'),
                                            transportname: widget.transportname,
                                            whsCode: widget.whsCode,
                                            whsName: widget.whsName,
                                            whsState: widget.whsState)),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8), // Adjust padding as needed
                                  child: SvgPicture.asset(
                                    'assets/edit.svg', // Replace 'your_icon.svg' with your SVG asset path
                                    width: 20, // Adjust width as needed
                                    height: 22, // Adjust height as needed
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        dividerForHorizontal,

                        // row two
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'LR Number',
                                      style: _titleTextStyle,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.LrNumber,
                                      style: _dataTextStyle,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            dividerForVertical,
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'LR Date',
                                      style: _titleTextStyle,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      LrDate1,
                                      style: _dataTextStyle,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        dividerForHorizontal,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Transport Name',
                                      style: _titleTextStyle,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.transportname,
                                      style: _dataTextStyle,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        dividerForHorizontal,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Remarks',
                                      style: _titleTextStyle,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.Remarks,
                                      style: _dataTextStyle,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        dividerForHorizontal,

                        // row four
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                border: Border.all(
                                  color: _orangeColor,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  // Add your click listener logic here
                                  // showDialog(
                                  //   context: context,
                                  //   builder: (context) => AlertDialog(
                                  //     content: Image.memory(
                                  //       base64Decode(
                                  //           widget.LRAttachment.split(',')
                                  //               .last),
                                  //     ),
                                  //   ),
                                  // );
                                  // showDialog(
                                  //   context: context,
                                  //   builder: (context) => ImageDialog(
                                  //     imageString: widget.LRAttachment,
                                  //     imageList: base64ImageStrings,
                                  //   ),
                                  // ); // work

                                  showAttachmentsDialog(attachments);

                                  // showDialog(
                                  //   context: context,
                                  //   builder: (context) => ImageSliderDialog(
                                  //     LRAttachment: widget.LRAttachment,
                                  //     ReturnOrderReceipt:
                                  //         widget.ReturnOrderReceipt,
                                  //     addlattchments: widget.addlattchments,
                                  //   ),
                                  // );
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.link),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Attachment',
                                      style: _titleTextStyle,
                                    ),
                                  ],
                                ),
                              )),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Container(
            //     width: MediaQuery.of(context).size.width,
            //     padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
            //     child: IntrinsicHeight(
            //         child: Card(
            //       color: Colors.white,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(5.0),
            //       ),
            //       child: Container(
            //         padding: EdgeInsets.all(10.0),
            //         decoration: BoxDecoration(
            //           borderRadius: BorderRadius.circular(5.0),
            //           color: Colors.white,
            //         ),
            //         width: MediaQuery.of(context).size.width,
            //         child: Column(
            //           children: [
            //             Row(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               mainAxisAlignment: MainAxisAlignment.start,
            //               children: [
            //                 Container(
            //                   padding: EdgeInsets.only(top: 5.0),
            //                   child: Text(
            //                     'Total',
            //                     style: TextStyle(
            //                       color: Colors.black,
            //                       fontWeight: FontWeight.bold,
            //                       fontSize: 14.0,
            //                     ),
            //                   ),
            //                 ),
            //                 Spacer(),
            //                 Row(
            //                   crossAxisAlignment: CrossAxisAlignment.end,
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Container(
            //                       //   width: MediaQuery.of(context).size.width / 1.8,
            //                       padding: EdgeInsets.only(top: 5.0),
            //                       child: Row(
            //                         crossAxisAlignment: CrossAxisAlignment.end,
            //                         mainAxisAlignment: MainAxisAlignment.end,
            //                         children: [
            //                           Text(
            //                             '₹${totalSum.toStringAsFixed(2)}',
            //                             style: TextStyle(
            //                               color: Color(0xFFe78337),
            //                               fontWeight: FontWeight.bold,
            //                               fontSize: 16.0,
            //                             ),
            //                           ),
            //                         ],
            //                       ),
            //                     )
            //                   ],
            //                 ),
            //               ],
            //             ),
            //           ],
            //         ),
            //       ),
            //     )))
          ],
        ),
      ),

      bottomNavigationBar: InkWell(
        onTap: () {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //     content: Text('Payment Successful'),
          //     duration: Duration(seconds: 2),
          //   ),
          // );
          print('clicked ');
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 0.0, left: 14.0, right: 14.0, bottom: 10.0),
          child: Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            height: 55.0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  if (globalCartLength > 0) {
                    Addreturnorder();
                    // Add logic for the download button
                  } else {
                    CommonUtils.showCustomToastMessageLong('Please Add Atleast One Product', context, 1, 4);
                  }
                },
                child: Container(
                  // width: desiredWidth * 0.9,
                  width: MediaQuery.of(context).size.width,
                  height: 55.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                    color: const Color(0xFFe78337),
                  ),
                  child: const Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(
                      'Place Your Return Order',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
      //    ),
    );
  }

  Future<void> getshareddata() async {
    userId = await SharedPrefsData.getStringFromSharedPrefs("userId");
    slpCode = await SharedPrefsData.getStringFromSharedPrefs("slpCode");
    CompneyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
    print('User ID: $userId');
    print('SLP Code: $slpCode');
    print('Company ID: $CompneyId');
  }

  Widget buildListView(List<ReturnOrderItemXrefType> cartItems, Key key) {
    // updateTotalSum(cartItems);

    return ListView.builder(
      // key: UniqueKey(),
      key: key,
      shrinkWrap: true,
      physics: const PageScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        ReturnOrderItemXrefType cartItem = cartItems[index];
        if (cartItems.length != textEditingControllers.length) {
          textEditingControllers = List.generate(cartItems.length, (index) => TextEditingController());
        }
        double orderQty = cartItem.orderQty?.toDouble() ?? 0.0;
        double price = cartItem.price ?? 0.0;
        // double numInSale = cartItem.numInSale?.toDouble() ?? 0.0;
        //  double totalPrice = orderQty * price * numInSale;

        // Update totalSumNotifier with the correct value

        return CartItemWidget(
          cartItem: cartItem,
          onDelete: () {
            setState(() {
              cartItems.removeAt(index);

              textEditingControllers.removeAt(index);
            });
          },
          cartItems: cartItems,
          onQuantityChanged: () {
            // updateTotalSumIncludingGst(); // Update totalSumIncludingGst when quantity changes
          },
        );
      },
    );
  }

  double calculateTotalSum(List<ReturnOrderItemXrefType> cartItems) {
    double sum = 0.0;
    for (ReturnOrderItemXrefType cartItem in cartItems) {
      double orderQty = cartItem.orderQty?.toDouble() ?? 0.0;
      double price = cartItem.price ?? 0.0;
      //  double numInSale = cartItem.numInSale?.toDouble() ?? 0.0;
      sum += orderQty * price;
    }
    return sum;
  }

  void clearCartData(CartProvider cartProvider) {
    cartProvider.clearreturnCart();
  }

  void Addreturnorder() async {
    DateTime currentDate = DateTime.now();
    //
    // Format the date as 'yyyy-MM-dd'
    String formattedcurrentDate = DateFormat('yyyy-MM-dd').format(currentDate);
    print('Formatted Date: $formattedcurrentDate');
    //const String apiUrl = 'http://182.18.157.215/Srikar_Biotech_Dev/API/api/ReturnOrder/AddReturnOrder';
    String apiUrl = baseUrl + AddReturnorder;
    print('AddReturnorderApi: $apiUrl');
    List<Map<String, dynamic>> returnorderItemList = cartItems.map((cartItem) {
      double orderQty = cartItem.orderQty?.toDouble() ?? 0.0;
      double price = cartItem.price ?? 0.0;

      double totalPrice = orderQty * price;
      return {
        "Id": 1,
        "ReturnOrderId": 2,
        "itemGrpCod": cartItem.itemGrpCod,
        "itemGrpName": cartItem.itemGrpName,
        "itemCode": cartItem.itemCode,
        "itemName": cartItem.itemName,
        "StatusTypeId": 13,
        "OrderQty": cartItem.orderQty,
        "Price": cartItem.price,
        "TotalPrice": totalPrice
      };
    }).toList();

    Map<String, dynamic> orderData = {
      "ReturnOrderItemXrefList": returnorderItemList,
      "Id": 1,
      "CompanyId": CompneyId,
      "ReturnOrderNumber": "",
      "ReturnOrderDate": formattedcurrentDate,
      "partyCode": widget.cardCode,
      "PartyName": widget.cardName,
      "PartyAddress": widget.address,
      "PartyState": widget.state,
      "PartyPhoneNumber": widget.phone,
      "PartyGSTNumber": widget.gstRegnNo,
      "ProprietorName": widget.proprietorName,
      "PartyOutStandingAmount": '${widget.balance}',
      "LRNumber": widget.LrNumber,
      "LRDate": LrDate2,
      "StatusTypeId": 13,
      "Discount": 1.1,
      "TotalCost": totalSum,
      "Remarks": widget.Remarks,
      "IsActive": true,
      "CreatedBy": userId,
      "CreatedDate": formattedcurrentDate,
      "UpdatedBy": userId,
      "UpdatedDate": formattedcurrentDate,
      "LRFileString": widget.LRAttachment,
      "LRFileName": "",
      "LRFileExtension": ".jpg",
      "LRFileLocation": "",
      "OrderFileString": widget.ReturnOrderReceipt,
      "OrderFileName": "",
      "OrderFileExtension": ".jpg",
      "OrderFileLocation": "",
      "OtherFileString": widget.addlattchments,
      "OtherFileName": "",
      "OtherFileExtension": ".jpg",
      "OtherFileLocation": "",
      "TransportName": widget.transportname,
      "WhsCode": widget.whsCode,
      "WhsName": widget.whsName,
      "WhsState": widget.whsState
    };
    print(jsonEncode(orderData));

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
        String returnOrderNumber = responseData['response']['returnOrderNumber'];

// Navigate to the next screen while passing the returnOrderNumber

        final cartProvider = context.read<CartProvider>();

        clearCartData(cartProvider);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReturnorderStatusScreen(responseData: responseData),
          ),
        );
      } else {
        // Handle errors
        print('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception: $e');
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

  String formatDate(String inputDate, String outputFormat) {
    // Parse the input date
    DateTime parsedDate = DateFormat("dd-MM-yyyy").parse(inputDate);

    // Format the date based on the output format
    String formattedDate = DateFormat(outputFormat).format(parsedDate);

    return formattedDate;
  }

  void showAttachmentsDialog(List data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int currentPage = 0; // Track the current page index

        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            width: double.infinity,
            height: 500,
            child: Stack(
              children: [
                PhotoViewGallery.builder(
                  itemCount: data.length,
                  builder: (context, index) {
                    Uint8List imgBytes = base64Decode(data[index]);
                    return PhotoViewGalleryPageOptions(
                      imageProvider: MemoryImage(imgBytes),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered,
                    );
                  },
                  scrollDirection: Axis.horizontal,
                  scrollPhysics: const PageScrollPhysics(),
                  allowImplicitScrolling: true,
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(data.length, (index) {
                        return Container(
                          width: 8.0,
                          height: 8.0,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentPage == index ? Colors.red : Colors.grey,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  // void showAttachmentsDialog(List data) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('Attachments'),
  //         elevation: 5.0,
  //         contentPadding: const EdgeInsets.all(5.0),
  //         content: SizedBox(
  //           height: 120,
  //           width: 300,
  //           child: Stack(
  //             children: [
  //               CarouselSlider(
  //                 items: data.map((base64String) {
  //                   Uint8List imgBytes = base64Decode(base64String);
  //                   return GestureDetector(
  //                     onTap: () {
  //                       _showZoomedAttachments(imgBytes);
  //                     },
  //                     child: Image.memory(
  //                       imgBytes,
  //                       fit: BoxFit.cover,
  //                     ),
  //                   );
  //                 }).toList(),
  //                 options: CarouselOptions(
  //                   scrollPhysics: const BouncingScrollPhysics(),
  //                   autoPlay: true,
  //                   enableInfiniteScroll: false,
  //                   height: MediaQuery.of(context).size.height,
  //                   aspectRatio: 23 / 9,
  //                   viewportFraction: 1,
  //                   onPageChanged: (index, reason) {
  //                     // Handle page change if needed
  //                     setState(() {
  //                       currentIndex = index;
  //                     });
  //                   },
  //                 ),
  //               ),
  //               SizedBox(
  //                 width: MediaQuery.of(context).size.width,
  //                 height: MediaQuery.of(context).size.height,
  //                 child: Align(
  //                   alignment: Alignment.bottomCenter,
  //                   child: Padding(
  //                     padding: const EdgeInsets.only(bottom: 25.0),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: List.generate(
  //                         data.length,
  //                             (index) {
  //                           return buildIndicator(index);
  //                         },
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: const Text('Close'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _showZoomedAttachments(Uint8List imgBytes) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white),
            width: double.infinity,
            height: 500,
            child: Stack(
              children: [
                Center(
                  child: PhotoViewGallery.builder(
                    itemCount: 1,
                    builder: (context, index) {
                      return PhotoViewGalleryPageOptions(
                        imageProvider: MemoryImage(imgBytes),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered,
                      );
                    },
                    scrollDirection: Axis.vertical,
                    scrollPhysics: const PageScrollPhysics(),
                    allowImplicitScrolling: true,
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                        child: const Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildIndicator(int index) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: index == currentIndex ? Colors.orange : Colors.grey,
      ),
    );
  }
}

class CartItemWidget extends StatefulWidget {
  final ReturnOrderItemXrefType cartItem;
  final Function onDelete;

  final List<ReturnOrderItemXrefType> cartItems;

  final VoidCallback onQuantityChanged; // Callback function to notify when quantity changes

  CartItemWidget({required this.cartItem, required this.onDelete, required this.cartItems, required this.onQuantityChanged // Initialize here
      });

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

    widget.onQuantityChanged();

    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
      child: Card(
        elevation: 5.0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(8.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '${widget.cartItem.itemName}',
              style: CommonUtils.Mediumtext_14,
            ),
            const SizedBox(height: 8.0),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Expanded(
                //   child: Text(
                //     '₹${formatNumber(totalSumForProduct)}',
                //     style: CommonUtils.Mediumtext_o_14,
                //   ),
                // ),
                // Text(
                //   '$Quantity ${widget.cartItem.salUnitMsr} = ${Quantity * widget.cartItem.numInSale!}  Nos', // Display totalSumForProduct for the single product
                //   style: CommonUtils.Mediumtext_o_14,
                // ),
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

                          widget.onQuantityChanged(); // Call onQuantityChanged callback
                        });
                      },
                      deleteQuantity: () {
                        setState(() {
                          if (_orderQty > 1) {
                            Quantity--;
                            // totalSumForProduct =
                            //     calculateTotalSumForProduct(widget.cartItem);
                            formatNumber(totalSumForProduct);
                            print('totalSumForProductminus==$totalSumForProduct');
                            formatNumber(totalSumForProduct);
                            _orderQty = (_orderQty ?? 0) - 1;
                            _textController.text = _orderQty.toString();
                            widget.cartItem.updateQuantity(_orderQty);

                            widget.onQuantityChanged(); // Call onQuantityChanged callback
                          }
                        });
                      },
                      textController: _textController,
                      orderQuantity: _orderQty, // Pass _orderQty as orderQuantity
                      // Pass the onQuantityChanged callback function
                      updateTotalPrice: (int value) {
                        // Your updateTotalPrice logic, if any
                        setState(() {
                          Quantity = value;
                          _orderQty = value;
                          widget.cartItem.updateQuantity(_orderQty);

                          widget.onQuantityChanged();
                        });
                      },
                      onQuantityChanged: (int value) {
                        setState(() {
                          _orderQty = value;
                          Quantity = value;
                          widget.cartItem.updateQuantity(_orderQty);

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

  // double calculateTotalGstAmount(List<OrderItemXrefType> cartItems) {
  //   double totalGstAmount = 0.0;
  //   for (OrderItemXrefType item in cartItems) {
  //     totalGstAmount += calculateGstPrice(
  //       calculateTotalSumForProduct(item),
  //       item.gst,
  //     );
  //   }
  //   return totalGstAmount;
  // }

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

class ImageSliderDialog extends StatefulWidget {
  final String LRAttachment;
  final String ReturnOrderReceipt;
  final String addlattchments;

  const ImageSliderDialog({
    super.key,
    required this.LRAttachment,
    required this.ReturnOrderReceipt,
    required this.addlattchments,
  });

  @override
  State<ImageSliderDialog> createState() => _ImageSliderDialogState();
}

class _ImageSliderDialogState extends State<ImageSliderDialog> {
  List attachments = [];

  @override
  void initState() {
    setAttachments(widget.LRAttachment, widget.ReturnOrderReceipt, widget.addlattchments);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        width: double.infinity,
        height: 500,
        child: Stack(
          children: [
            Center(
              child: SizedBox(
                width: 300,
                child: PhotoViewGallery.builder(
                  itemCount: getAttchementsLength,
                  builder: (context, index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: MemoryImage(
                        base64Decode(attachments[index]),
                      ),
                      minScale: PhotoViewComputedScale.covered,
                      maxScale: PhotoViewComputedScale.covered * 2,
                    );
                  },
                  scrollDirection: Axis.horizontal,
                  scrollPhysics: const BouncingScrollPhysics(),
                  allowImplicitScrolling: true,
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  } // work

  int get getAttchementsLength => attachments.length;

  void setAttachments(
    String att1,
    String att2,
    String att3,
  ) {
    if (att1.isNotEmpty) {
      attachments.add(att1);
    }
    if (att2.isNotEmpty) {
      attachments.add(att2);
    }
    if (att3.isNotEmpty) {
      attachments.add(att3);
    }
  }
}
