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
  final String BookingPlace;
  final String TransportName;
  final double creditLine;
  final double balance;

  Ordersubmit_screen(
      {required this.cardName,
      required this.cardCode,
      required this.address,
      required this.state,
      required this.phone,
      required this.proprietorName,
      required this.gstRegnNo,
      required this.BookingPlace,
      required this.TransportName,
      required this.creditLine,
      required this.balance});
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

  int CompneyId = 0;
  String? userId = "";
  String? slpCode = "";
  double totalSum = 0.0;
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
  }

  @override
  Widget build(BuildContext context) {
    cartItems = Provider.of<CartProvider>(context).getCartItems();
    totalSum = calculateTotalSum(cartItems);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFe78337),
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
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      Icons.chevron_left,
                      size: 30.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                Text(
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
                      style: TextStyle(
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
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0),
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
                  SizedBox(height: 16.0),
                ],
              ),
            ),
            //           }
            //         },
            //       ),

            FutureBuilder(
              future: Future.value(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.connectionState == ConnectionState.done) {
                  List<OrderItemXrefType> cartItems =
                      Provider.of<CartProvider>(context).getCartItems();

                  // Print the total sum
                  print('Total Sum of Product Prices: $totalSum');

                  return buildListView(cartItems);
                } else {
                  return Text('Error: Unable to fetch cart data');
                }
              },
            ),

            SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
              child: IntrinsicHeight(
                child: Card(
                  // color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.white,

                      // color: Colors.white
                    ),
                    //  color: Colors.white,
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 0.0, top: 8.0),
                                  child: Text(
                                    'Transport  Details',
                                    style: TextStyle(
                                      fontSize: 13.0,
                                      color: Color(0xFF414141),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(right: 5.0, top: 8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                transport_payment(
                                                  cardName: widget.cardName,
                                                  cardCode: widget.cardCode,
                                                  address: widget.address,
                                                  state: widget.state,
                                                  phone: widget.phone,
                                                  proprietorName:
                                                      widget.proprietorName,
                                                  gstRegnNo: widget.gstRegnNo,
                                                  preferabletransport:
                                                      widget.TransportName,
                                                  bookingplace:
                                                      widget.BookingPlace,
                                                  creditLine: 0.0,
                                                  balance: 0.0,
                                                )),
                                      );
                                    },
                                    child: SvgPicture.asset(
                                      'assets/edit.svg',
                                      width: 20.0,
                                      height: 20.0,
                                      color: Color(0xFFe78337),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  Colors.grey, // specify your border color here
                              width: 1.0, // specify the border width
                            ),
                            borderRadius: BorderRadius.circular(
                                8.0), // specify the border radius
                          ),
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2.2,
                                    padding: EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: 0.0,
                                            left: 10.0,
                                            right: 0.0,
                                          ),
                                          child: Text(
                                            'Booking Place',
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
                                              top: 0.0, left: 10.0, right: 0.0),
                                          child: Text(
                                            '${widget.BookingPlace}',
                                            style: TextStyle(
                                              fontSize: 13.0,
                                              color: Color(0xFFe78337),
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2.9,
                                    padding: EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 0.0, left: 0.0, right: 0.0),
                                          child: Text(
                                            'Transport Name',
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
                                            '${widget.TransportName}',
                                            style: TextStyle(
                                              fontSize: 13.0,
                                              color: Color(0xFFe78337),
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0),
                child: IntrinsicHeight(
                    child: Card(
                  //  color: Colors.white,
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
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.only(top: 5.0),
                              child: Text(
                                'Total',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                            Spacer(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  //   width: MediaQuery.of(context).size.width / 1.8,
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        '₹${totalSum.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Color(0xFFe78337),
                                          fontWeight: FontWeight.bold,
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
                  AddOrder();
                  // Add logic for the download button

                  print(' button clicked');
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xFFe78337),
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
    final String apiUrl =
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

        // Map other cart item properties to corresponding fields
        // ...
      };
    }).toList();
    // Calculate the sum of prices for the entire order
    double totalOrderPrice =
        orderItemList.fold(0.0, (sum, item) => sum + (item['Price'] ?? 0.0));
    print('totalOrderPrice====$totalOrderPrice');

    Map<String, dynamic> orderData = {
      "OrderItemXrefTypeList": orderItemList,
      "Id": 1,
      "CompanyId": CompneyId,
      "OrderNumber": "",
      "OrderDate": formattedcurrentDate,
      "PartyCode": '${widget.cardCode}',
      "PartyName": '${widget.cardName}',
      "PartyAddress": '${widget.address}',
      "PartyState": '${widget.state}',
      "PartyPhoneNumber": '${widget.phone}',
      "PartyGSTNumber": '${widget.gstRegnNo}',
      "ProprietorName": '${widget.proprietorName}',
      "PartyOutStandingAmount": '${widget.balance}',
      "BookingPlace": '${widget.BookingPlace}',
      "TransportName": '${widget.TransportName}',
      "FileName": "",
      "FileLocation": "",
      "FileExtension": "",
      "StatusTypeId": 1,
      "Discount": 1.1,
      "TotalCost": totalSum,
      "Remarks": null,
      "IsActive": true,
      "CreatedBy": userId,
      "CreatedDate": formattedcurrentDate,
      "UpdatedBy": userId,
      "UpdatedDate": formattedcurrentDate,
      "TotalCostWithGST": 1.1,
      "GSTCost": 1.1
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

        final cartProvider = context.read<CartProvider>();

        clearCartData(cartProvider);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => orderStatusScreen(responseData: responseData),
          ),
        );
        clearCartItems();
        printRemainingCartItems();
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

  Future<void> getshareddata() async {
    userId = await SharedPrefsData.getStringFromSharedPrefs("userId");
    slpCode = await SharedPrefsData.getStringFromSharedPrefs("slpCode");
    CompneyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
    print('User ID: $userId');
    print('SLP Code: $slpCode');
    print('Company ID: $CompneyId');
  }

  Widget buildListView(List<OrderItemXrefType> cartItems) {
    return ListView.builder(
      key: UniqueKey(),
      shrinkWrap: true,
      physics: PageScrollPhysics(),
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

        return CartItemWidget(
          cartItem: cartItem,
          onDelete: () {
            setState(() {
              cartItems.removeAt(index);
            });
          },
          totalPrice: totalPrice,
          cartItems: cartItems,
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
}

class CartItemWidget extends StatefulWidget {
  final OrderItemXrefType cartItem;
  final Function onDelete;
  final double totalPrice;
  final List<OrderItemXrefType> cartItems;
  ValueNotifier<double> totalSumNotifier;

  CartItemWidget({
    required this.cartItem,
    required this.onDelete,
    required this.totalPrice,
    required this.cartItems,
  }) : totalSumNotifier = ValueNotifier<double>(
          calculateTotalSum(cartItems),
        ); // Initialize in the constructor

  @override
  _CartItemWidgetState createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  late TextEditingController _textController;
  late int _orderQty;

  @override
  void initState() {
    super.initState();
    _orderQty = widget.cartItem.orderQty ?? 0;
    _textController = TextEditingController(text: _orderQty.toString());
    widget.totalSumNotifier = ValueNotifier<double>(calculateTotalSum(
        widget.cartItems)); // Initialize totalSumNotifier in initState
  }

  @override
  Widget build(BuildContext context) {
    double totalWidth = MediaQuery.of(context).size.width;

    // Calculate totalSum for all products
    double totalSum = calculateTotalSum(widget.cartItems);
    print('totalSum==$totalSum');

    // Calculate totalSumForProduct for the single product
    double totalSumForProduct = calculateTotalSumForProduct(widget.cartItem);

    // Calculate GST price based on totalSum
    double gstPrice =
        calculateGstPrice(totalSumForProduct, widget.cartItem.gst);

    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
      child: Card(
        elevation: 5.0,
        //  color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Container(
          // color: Colors.white,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Colors.white,

            // color: Colors.white
          ),
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.cartItem.itemName}',
                style: CommonUtils.Mediumtext_14,
              ),
              SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '₹${totalSumForProduct.toStringAsFixed(2)}',
                      style: CommonUtils.Mediumtext_o_14,
                    ),
                  ),
                  Text(
                    '  ${widget.cartItem.numInSale}', // Display totalSumForProduct for the single product
                    style: CommonUtils.Mediumtext_o_14,
                  ),
                  // Add the GST price column
                  // Text(
                  //   'GST: ₹${gstPrice.toStringAsFixed(2)}',
                  //   style: CommonUtils.Mediumtext_o_14,
                  // ),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: (totalWidth - 40) / 2,
                    child: PlusMinusButtons(
                      addQuantity: () {
                        setState(() {
                          _orderQty = (_orderQty ?? 0) + 1;
                          _textController.text = _orderQty.toString();
                          widget.cartItem.updateQuantity(_orderQty);
                          widget.totalSumNotifier.value =
                              calculateTotalSum(widget.cartItems);
                          print(
                              'totalSumNotifier ${widget.totalSumNotifier.value}');
                        });
                      },
                      deleteQuantity: () {
                        setState(() {
                          if (_orderQty! > 1) {
                            _orderQty = (_orderQty ?? 0) - 1;
                            _textController.text = _orderQty.toString();
                            widget.cartItem.updateQuantity(_orderQty);
                            widget.totalSumNotifier.value =
                                calculateTotalSum(widget.cartItems);
                            print(
                                'totalSumNotifier ${widget.totalSumNotifier.value}');
                          }
                        });
                      },
                      textController: _textController,
                      updateTotalPrice: () {
                        widget.totalSumNotifier.value =
                            calculateTotalSumForProduct(widget.cartItem);
                      },
                      onQuantityChanged: (int value) {},
                    ),
                  ),
                  SizedBox(width: 8.0),
                  GestureDetector(
                    onTap: () {
                      widget.onDelete();
                    },
                    child: Container(
                      height: 36,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Color(0xFFF8dac2),
                        border: Border.all(
                          color: Color(0xFFe78337),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
            ],
          ),
        ),
      ),
    );
  }

  double calculateGstPrice(double totalSum, double? gst) {
    return (totalSum * gst!) / 100.0;
  }
}

class PlusMinusButtons extends StatelessWidget {
  final VoidCallback deleteQuantity;
  final VoidCallback addQuantity;
  final TextEditingController textController;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback updateTotalPrice; // Add this callback

  PlusMinusButtons({
    Key? key,
    required this.addQuantity,
    required this.deleteQuantity,
    required this.textController,
    required this.onQuantityChanged,
    required this.updateTotalPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 2.3,
      height: 38,
      decoration: BoxDecoration(
        color: Color(0xFFe78337),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Card(
        color: Color(0xFFe78337),
        margin: EdgeInsets.symmetric(horizontal: 0.0),
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
                child: Container(
                  height: 36,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width / 5,
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: TextField(
                        controller: textController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(5),
                        ],
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.only(bottom: 10.0),
                        ),
                        textAlign: TextAlign.center,
                        style: CommonUtils.Mediumtext_o_14,
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
    onQuantityChanged(int.parse(textController.text));
    updateTotalPrice(); // Notify parent about quantity change and update total price
    print('Current Value: ${textController.text}');
  }
}

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
