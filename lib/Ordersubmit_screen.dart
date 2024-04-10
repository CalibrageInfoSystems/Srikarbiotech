// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikarbiotech/Common/CommonUtils.dart';
import 'package:http/http.dart' as http;
import 'package:srikarbiotech/Common/styles.dart';
import 'package:srikarbiotech/Services/api_config.dart';

import 'CartProvider.dart';
import 'Common/SharedPrefsData.dart';
import 'HomeScreen.dart';
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
  bool _isButtonDisabled = false;

  @override
  initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    getshareddata();
    updateTotalSumIncludingGst();
    GetPreviousOrderBookingByPartyCode(widget.cardCode);
  }

  @override
  Widget build(BuildContext context) {
    cartItems = Provider.of<CartProvider>(context).getCartItems();

    totalSumNotifier = ValueNotifier<double>(calculateTotalSum(cartItems));
    totalGstAmountNotifier =
        ValueNotifier<double>(calculateTotalGstAmount(cartItems));

    print('totalGstAmountNotifier $totalGstAmountNotifier');

    double newTotalSumIncludingGst =
        calculateTotalSum(cartItems) + calculateTotalGstAmount(cartItems);
    print('totalSumIncludingGst: $newTotalSumIncludingGst');

    if (newTotalSumIncludingGst != totalSumIncludingGst.value) {
      totalSumIncludingGst.value = newTotalSumIncludingGst;
    }
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop();
          return true;
        },
        child: Scaffold(
            appBar: _appBar(),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 5.0, left: 10.0, right: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonUtils.buildCard(
                          widget.cardName,
                          widget.cardCode,
                          widget.proprietorName,
                          widget.gstRegnNo,
                          widget.address,
                          CommonStyles.whiteColor,
                          BorderRadius.circular(5.0),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.only(
                        top: 5.0, left: 10.0, right: 10.0),
                    child: IntrinsicHeight(
                      child: Card(
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Container(
                          // decoration: BoxDecoration(
                          //   borderRadius: BorderRadius.circular(5.0),
                          //   color: CommonStyles.whiteColor,
                          // ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: CommonStyles.whiteColor,
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
                                      style: CommonStyles.txSty_14b_fb,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '₹${widget.creditLine}',
                                      style: CommonStyles.txSty_14o_f7,
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5.0),
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Outstanding Amount',
                                      style: CommonStyles.txSty_14b_fb,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '₹${widget.balance}',
                                      style: CommonStyles.txSty_14o_f7,
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
                      List<OrderItemXrefType> cartItems =
                          Provider.of<CartProvider>(context).getCartItems();
                      return buildListView(cartItems, ValueKey(cartItems));
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Card(
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: CommonStyles.whiteColor,
                        ),
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(
                                  top: 0.0, left: 0.0, right: 0.0),
                              child: Text(
                                'Booking Place *',
                                style: CommonStyles.txSty_14b_fb,
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
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(
                                    color: CommonStyles.orangeColor,
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
                                            controller: bookingplacecontroller,
                                            keyboardType: TextInputType.name,
                                            maxLength: 50,
                                            style: CommonStyles.txSty_14o_f7,
                                            decoration: const InputDecoration(
                                              counterText: '',
                                              hintText: 'Enter Booking Place',
                                              hintStyle: TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'Roboto',
                                                fontWeight: FontWeight.w700,
                                                color: Color.fromARGB(
                                                    159, 250, 146, 67),
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
                            const SizedBox(
                              height: 10,
                            ),
                            const Padding(
                              padding: EdgeInsets.only(
                                  top: 0.0, left: 0.0, right: 0.0),
                              child: Text(
                                'Transport Name * ',
                                style: CommonStyles.txSty_14b_fb,
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
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(
                                    color: CommonStyles.orangeColor,
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
                                            controller: Parcelservicecontroller,
                                            keyboardType: TextInputType.name,
                                            maxLength: 50,
                                            style: CommonStyles.txSty_14o_f7,
                                            decoration: const InputDecoration(
                                              counterText: '',
                                              hintText: 'Enter Transport Name',
                                              hintStyle: TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'Roboto',
                                                fontWeight: FontWeight.w700,
                                                color: Color.fromARGB(
                                                    159, 250, 146, 67),
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
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.only(
                        top: 5.0, left: 10.0, right: 10.0),
                    child: IntrinsicHeight(
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: CommonStyles.whiteColor,
                          ),
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Sub Total',
                                      style: CommonStyles.txSty_12b_fb),
                                  ValueListenableBuilder<double>(
                                    valueListenable: totalSumNotifier,
                                    builder: (context, totalSum, child) {
                                      return Text(
                                        '₹${formatNumber(totalSum)}',
                                        style: CommonStyles.txSty_12o_f7,
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('GST',
                                      style: CommonStyles.txSty_12b_fb),
                                  ValueListenableBuilder<double>(
                                    valueListenable: totalGstAmountNotifier,
                                    builder: (context, totalGstAmount, _) {
                                      return Text(
                                        '₹${formatNumber(totalGstAmount)}',
                                        style: CommonStyles.txSty_12o_f7,
                                      );
                                    },
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
                                  ValueListenableBuilder<double>(
                                    valueListenable: totalSumIncludingGst,
                                    builder: (context, totalsumGstAmount, _) {
                                      return Text(
                                        '₹${formatNumber(totalsumGstAmount)}',
                                        style: CommonStyles.txSty_12o_f7,
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
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 45.0,
                      child: Center(
                        child: GestureDetector(
                          onTap: _isButtonDisabled
                              ? null
                              : () {
                                  if (globalCartLength > 0) {
                                    CommonUtils.checkInternetConnectivity()
                                        .then(
                                      (isConnected) {
                                        if (isConnected) {
                                          addOrder();
                                          print('The Internet Is Connected');
                                        } else {
                                          CommonUtils.showCustomToastMessageLong(
                                              'Please check your internet connection',
                                              context,
                                              1,
                                              4);
                                          print(
                                              'The Internet Is not Connected');
                                        }
                                      },
                                    );
                                  } else {
                                    CommonUtils.showCustomToastMessageLong(
                                        'Please Add Atleast One Product',
                                        context,
                                        1,
                                        4);
                                  }
                                },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 45.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.0),
                              color: _isButtonDisabled
                                  ? Colors.grey
                                  : CommonStyles.orangeColor,
                            ),
                            child: const Center(
                              child: Text(
                                'Place Your Order',
                                style: CommonStyles.txSty_14w_fb,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }

  void addOrder() async {
    DateTime currentDate = DateTime.now();

    String formattedcurrentDate = DateFormat('yyyy-MM-dd').format(currentDate);
    print('Formatted Date: $formattedcurrentDate');
    String apiUrl = baseUrl + SubmitCreateOrderapi;
    print('SubmitOrderApi: $apiUrl');
    bool isValid = true;
    bool hasValidationFailed = false;

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
      print('cartItem.ugpEntry: ${cartItem.ugpEntry}');
      if (isValid && orderQty == 0.0) {
        CommonUtils.showCustomToastMessageLong(
            'Please Add Quantity to Selected product(s)', context, 1, 4);
        isValid = false;
        hasValidationFailed = true;
      }

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
        "TaxCode": "",
        "UgpEntry": cartItem.ugpEntry,
      };
    }).toList();

    double totalCost = orderItemList.fold(
        0.0, (sum, item) => sum + (item['TotalPrice'] ?? 0.0));
    double totalCostWithGST = orderItemList.fold(
        0.0, (sum, item) => sum + (item['TotalPriceWithGST'] ?? 0.0));
    double totalGSTCost =
        orderItemList.fold(0.0, (sum, item) => sum + (item['GSTPrice'] ?? 0.0));
    print('Total Price: $totalCostWithGST');
    print('Total Price With GST: $totalGSTCost');

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
      "WhsCode": widget.whsCode,
      "WhsName": widget.whsName,
      "WhsState": widget.whsState
    };
    print(jsonEncode(orderData));
    if (isValid) {
      setState(() {
        _isButtonDisabled = true;
      });
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(orderData),
        );

        if (response.statusCode == 200) {
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
            _isButtonDisabled = false;
            CommonUtils.showCustomToastMessageLong(
                responseData['endUserMessage'], context, 1, 4);
          }
        } else {
          print('Error: ${response.reasonPhrase}');
          setState(() {
            _isButtonDisabled = false;
          });
        }
      } catch (e) {
        print('Exception: $e');
      }
    } else {
      _isButtonDisabled = false;
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
      key: key,
      shrinkWrap: true,
      physics: const PageScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        OrderItemXrefType cartItem = cartItems[index];
        double orderQty = cartItem.orderQty?.toDouble() ?? 0.0;
        double price = cartItem.price ?? 0.0;
        double numInSale = cartItem.numInSale?.toDouble() ?? 0.0;
        double totalPrice = orderQty * price * numInSale;
        return CartItemWidget(
          key: ValueKey(cartItem),
          cartItem: cartItem,
          index: index,
          onDelete: (int index) {
            setState(() {
              cartItems.removeAt(index);
              updateTotalSumIncludingGst();
            });
          },
          totalPrice: totalPrice,
          cartItems: cartItems,
          totalSumNotifier: totalSumNotifier,
          totalGstAmountNotifier: totalGstAmountNotifier,
          onQuantityChanged: () {
            updateTotalSumIncludingGst();
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
    return totalSumNotifier.value + totalGstAmountNotifier.value;
  }

  void updateTotalSumIncludingGst() {
    double newTotalSumIncludingGst =
        calculateTotalSum(cartItems) + calculateTotalGstAmount(cartItems);
    print('totalSumIncludingGst: $newTotalSumIncludingGst');

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
      final apiurl = baseUrl + getPreviousOrderBookingByPartyCode + cardCode;
      http.Response response = await http.get(Uri.parse(apiurl));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        if (data['response'] != null) {
          String bookingPlace = data['response']['bookingPlace'];
          String transportName = data['response']['transportName'];

          bookingplacecontroller.text = bookingPlace;
          Parcelservicecontroller.text = transportName;
        } else {
          print('No data available.');
        }
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: CommonStyles.orangeColor,
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
                    Navigator.of(context).pop();
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
                'Order Submission',
                style: CommonStyles.txSty_18w_fb,
              ),
              FutureBuilder(
                future: getshareddata(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    cartItems =
                        Provider.of<CartProvider>(context).getCartItems();

                    globalCartLength = cartItems.length;
                  }

                  return Text(
                    '($globalCartLength)',
                    style: CommonStyles.txSty_18w_fb,
                  );
                },
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
}

class CartItemWidget extends StatefulWidget {
  final OrderItemXrefType cartItem;

  final Function(int) onDelete;
  final int index;
  final double totalPrice;
  final List<OrderItemXrefType> cartItems;
  final ValueNotifier<double> totalSumNotifier;
  final ValueNotifier<double> totalGstAmountNotifier;
  final VoidCallback onQuantityChanged;

  const CartItemWidget({
    Key? key,
    required this.cartItem,
    required this.onDelete,
    required this.index,
    required this.totalPrice,
    required this.cartItems,
    required this.totalSumNotifier,
    required this.totalGstAmountNotifier,
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  _CartItemWidgetState createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  late TextEditingController _textController;
  late int _orderQty;
  double gstPrice = 0.0;
  double totalGstAmount = 0.0;
  late int Quantity = 1;

  double totalSumForProduct = 0.0;
  double totalSum = 0.0;
  @override
  void initState() {
    super.initState();

    _orderQty = widget.cartItem.orderQty ?? 1;
    Quantity = widget.cartItem.orderQty!;
    print('Quantity==$Quantity');

    _textController = TextEditingController(text: _orderQty.toString());
    widget.totalSumNotifier.value = calculateTotalSum(widget.cartItems);
    widget.totalGstAmountNotifier.value =
        calculateTotalGstAmount(widget.cartItems);
  }

  @override
  Widget build(BuildContext context) {
    double totalWidth = MediaQuery.of(context).size.width;

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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: CommonStyles.whiteColor,
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '${widget.cartItem.itemName}',
              style: CommonStyles.txSty_14b_fb,
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '₹${formatNumber(totalSumForProduct)}',
                    style: CommonStyles.txSty_14o_f7,
                  ),
                ),
                Text(
                  '$Quantity ${widget.cartItem.salUnitMsr} = ${Quantity * widget.cartItem.numInSale!}  Nos',
                  style: CommonStyles.txSty_14o_f7,
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

                          formatNumber(totalSumForProduct);
                          _orderQty = (_orderQty ?? 0) + 1;
                          _textController.text = _orderQty.toString();

                          widget.cartItem.updateQuantity(_orderQty);
                          widget.totalSumNotifier.value =
                              calculateTotalSum(widget.cartItems);
                          widget.totalGstAmountNotifier.value =
                              calculateTotalGstAmount(widget.cartItems);
                          widget.onQuantityChanged();
                        });
                      },
                      deleteQuantity: () {
                        setState(() {
                          if (_orderQty > 1) {
                            Quantity--;

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
                            widget.onQuantityChanged();
                          }
                        });
                      },
                      textController: _textController,
                      orderQuantity: _orderQty,
                      updateTotalPrice: (int value) {
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
                    widget.onDelete(widget.index);
                    setState(() {
                      Quantity = widget.cartItem.orderQty ?? 1;
                    });
                  },
                  child: Container(
                    height: 36,
                    width: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8dac2),
                      border: Border.all(
                        color: CommonStyles.orangeColor,
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

class PlusMinusButtons extends StatelessWidget {
  final VoidCallback deleteQuantity;
  final VoidCallback addQuantity;
  final TextEditingController textController;
  final int orderQuantity;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<int> updateTotalPrice;

  const PlusMinusButtons({
    Key? key,
    required this.addQuantity,
    required this.deleteQuantity,
    required this.textController,
    required this.orderQuantity,
    required this.onQuantityChanged,
    required this.updateTotalPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 2.3,
      height: 38,
      decoration: BoxDecoration(
        color: CommonStyles.orangeColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Card(
        color: CommonStyles.orangeColor,
        margin: const EdgeInsets.symmetric(horizontal: 0.0),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                deleteQuantity();
                _updateTextController();
              },
              icon: SvgPicture.asset(
                'assets/minus-small.svg',
                color: CommonStyles.whiteColor,
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
                        color: CommonStyles.whiteColor,
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
                        style: CommonStyles.txSty_14o_f7,
                        onChanged: (newValue) {
                          int newOrderQuantity;
                          if (newValue.isNotEmpty) {
                            newOrderQuantity = int.tryParse(newValue) ?? 0;
                            onQuantityChanged(newOrderQuantity);
                          } else {
                            if (textController.text.isNotEmpty) {
                              newOrderQuantity = 1;
                              onQuantityChanged(newOrderQuantity);
                            } else {
                              newOrderQuantity = 0;
                              onQuantityChanged(newOrderQuantity);
                            }
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
                'assets/plus-small.svg',
                color: CommonStyles.whiteColor,
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
