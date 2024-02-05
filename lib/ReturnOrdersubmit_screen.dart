import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikarbiotech/Common/CommonUtils.dart';
import 'package:http/http.dart' as http;
import 'package:srikarbiotech/sb_status.dart';

import 'CartProvider.dart';
import 'Common/SharedPrefsData.dart';
import 'HomeScreen.dart';
import 'Model/OrderItemXrefType.dart';
import 'ReturnorderStatusScreen.dart';
import 'orderStatusScreen.dart';

class ReturnOrdersubmit_screen extends StatefulWidget {
  final String cardName;
  final String  cardCode;
  final String  address;
  final String proprietorName;
  final String gstRegnNo;
  final String state;
  final String phone;
  final String  LrNumber;
  final String  Lrdate;
  final String Remarks;
  final String LRAttachment;
  final String ReturnOrderReceipt;
  final String addlattchments;
  final double creditLine;
  final double balance;

  ReturnOrdersubmit_screen(
      {required this.cardName, required this.cardCode,
        required this.address,
        required  this.state,
        required  this.phone,
        required  this.proprietorName,
        required  this.gstRegnNo,
        required this.LrNumber,
        required this.Lrdate,
        required  this.Remarks,
        required  this.LRAttachment,
        required  this.ReturnOrderReceipt,
        required  this.addlattchments,   required this.creditLine,
        required this.balance});
  @override
  returnOrder_submit_screen createState() => returnOrder_submit_screen();
}

class returnOrder_submit_screen extends State<ReturnOrdersubmit_screen> {

  final _orangeColor = HexColor('#e58338');

  final _titleTextStyle = const TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w700,
    color: Colors.black,
    fontSize: 14,
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
  String LrDate1 = "";
  String LrDate2 = "";
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

    String dateString = widget.Lrdate;
    print('dateString==>$dateString');
    // Format: dd MMM, yyyy
    LrDate1= formatDate(dateString, "dd MMM, yyyy");
    print("Formatted Date 1: $LrDate1");

    // Format: yyyy-MM-dd
    LrDate2 = formatDate(dateString, "yyyy-MM-dd");
    print("Formatted Date 2: $LrDate2");
    // DateTime date = DateTime.parse(dateString);
    // String formattedDate = DateFormat('dd MMM, yyyy').format(date);
    return Scaffold(
      appBar:
      AppBar(
        backgroundColor: Color(0xFFe78337),
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
                    child: Icon(
                      Icons.chevron_left,
                      size: 30.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                Text(
                  'Place Return Order ',
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
                      cartItems = Provider.of<CartProvider>(context).getCartItems();
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

                  return   GestureDetector(
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

      body:  SingleChildScrollView(
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
                    BorderRadius.circular(10.0),
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
                  cartItems = Provider.of<CartProvider>(context).getCartItems();


                  // Print the total sum
                  print('Total Sum of Product Prices: $totalSum');

                  return buildListView();
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
                child:
                Card(
                  elevation: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: double.infinity, // remove padding here
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // row one
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Trasport Details',
                                style: _titleTextStyle,
                              ),
                              const Icon(Icons.home),
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'LR Number',
                                      style: _titleTextStyle,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${widget.LrNumber}',
                                      style: _dataTextStyle,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            dividerForVertical,
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'LR Date',
                                      style: _titleTextStyle,
                                    ),
                                    SizedBox(height: 4),
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

                        // row four
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              border: Border.all(
                                color: _orangeColor,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.link),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Attachment',
                                  style: _titleTextStyle,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(

                width: MediaQuery.of(context).size.width,

                padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                child: IntrinsicHeight(
                    child: Card(
                      color: Colors.white,
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(top: 10.0),
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
                                      padding: EdgeInsets.only(top: 10.0),
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






      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ElevatedButton(
          onPressed: () {
            Addreturnorder();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ReturnorderStatusScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            primary: Color(0xFFe78337), // Set your desired background color
          ),
          child: Text(
            'Place Your Order',
            style: TextStyle(
              color: Colors.white, // Set your desired text color
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

  Widget buildListView() {
    return ListView.builder(
      key: UniqueKey(),
      shrinkWrap: true,
      physics: PageScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        OrderItemXrefType cartItem = cartItems[index];
        if (cartItems.length != textEditingControllers.length) {
          textEditingControllers = List.generate(cartItems.length,
                  (index) => TextEditingController());
        }
        double orderQty = cartItem.orderQty.toDouble();
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
        );
      },
    );
  }

  double calculateTotalSum(List<OrderItemXrefType> cartItems) {
    double sum = 0.0;
    for (OrderItemXrefType cartItem in cartItems) {
      double orderQty = cartItem.orderQty.toDouble();
      double price = cartItem.price ?? 0.0;
      double numInSale = cartItem.numInSale?.toDouble() ?? 0.0;
      sum += orderQty * price * numInSale;
    }
    return sum;
  }

  void clearCartData(CartProvider cartProvider) {
    cartProvider.clearCart();
  }



  void Addreturnorder() async {

    DateTime currentDate = DateTime.now();

    // Format the date as 'yyyy-MM-dd'
    String formattedcurrentDate = DateFormat('yyyy-MM-dd').format(currentDate);
    print('Formatted Date: $formattedcurrentDate');
    final String apiUrl = 'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Order/AddOrder';
    List<Map<String, dynamic>> returnorderItemList = cartItems.map((cartItem) {

      return {

        "Id": 1,
        "ReturnOrderId": 2,
        "itemGrpCod": cartItem.itemGrpCod,
        "itemGrpName":  cartItem.itemGrpName,
        "itemCode": cartItem.itemCode,
        "itemName":  cartItem.itemName,
        "StatusTypeId": 1,
        "OrderQty": cartItem.orderQty,
        "Price":  cartItem.price,
        "IGST":cartItem.igst,
        "CGST": cartItem.cgst,
        "SGST":  cartItem.cgst,
        "Remarks": "test"

      };
    }).toList();

    Map<String, dynamic> orderData = {


      "ReturnOrderItemXrefList": returnorderItemList,
      "LRFileString":  '${widget.LRAttachment}',
      "LRFileName": "",
      "LRFileExtension": ".jpg",
      "LRFileLocation": "",
      "OrderFileString":  '${widget.ReturnOrderReceipt}',
      "OrderFileName": "",
      "OrderFileExtension": ".jpg",
      "OrderFileLocation": "",
      "OtherFileString":  '${widget.addlattchments}',
      "OtherFileName": ".jpg",
      "OtherFileExtension": "",
      "OtherFileLocation": "",

      "Id": 1,
      "CompanyId": CompneyId,
      "ReturnOrderNumber": "",
      "ReturnOrderDate": formattedcurrentDate,
      "partyCode": '${widget.cardCode}',
      "PartyName": '${widget.cardName}',
      "PartyAddress": '${widget.address}',
      "PartyState": '${widget.state}',
      "PartyPhoneNumber": '${widget.phone}',
      "PartyGSTNumber": '${widget.gstRegnNo}',
      "ProprietorName": '${widget.proprietorName}',
      "PartyOutStandingAmount": '${widget.balance}',
      "LRNumber": '${widget.LrNumber}',
      "LRDate": '$LrDate2',
      "StatusTypeId": 1,
      "Discount": 1.1,
      "IGST": 1.1,
      "CGST": 1.1,
      "SGST": 1.1,
      "TotalCost": totalSum,
      "Remarks": "test",
      "IsActive": true,
      "CreatedBy": userId,
      "CreatedDate": formattedcurrentDate,
      "UpdatedBy": userId,
      "UpdatedDate": formattedcurrentDate
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


}

class CartItemWidget extends StatefulWidget {
  final OrderItemXrefType cartItem;
  final Function onDelete;
  final double totalPrice;

  CartItemWidget({
    required this.cartItem,
    required this.onDelete,
    required this.totalPrice,
  });

  @override
  _CartItemWidgetState createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  late TextEditingController _textController;
  late int _orderQty;


  @override
  void initState() {
    super.initState();
    _orderQty = widget.cartItem.orderQty;
    _textController = TextEditingController(text: _orderQty.toString());

  }



  @override
  Widget build(BuildContext context) {
    double totalWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 10.0),
      child: Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
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
                      '₹${widget.cartItem.price}',
                      style: CommonUtils.Mediumtext_o_14,
                    ),
                  ),
                  Text(
                    '₹${widget.totalPrice.toStringAsFixed(2)}',
                    style: CommonUtils.Mediumtext_o_14,
                  ),
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
                          // Call the updateQuantity method in your model class
                          widget.cartItem.updateQuantity(_orderQty);
                        });

                      },
                      deleteQuantity: () {
                        setState(() {
                          if (_orderQty! > 1) {
                            _orderQty = (_orderQty ?? 0) - 1;
                            _textController.text = _orderQty.toString();
                            widget.cartItem.updateQuantity(_orderQty);
                          }
                        });

                      },
                      textController: _textController,
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


}
class PlusMinusButtons extends StatelessWidget {
  final VoidCallback deleteQuantity;
  final VoidCallback addQuantity;
  final TextEditingController textController;

  PlusMinusButtons({
    Key? key,
    required this.addQuantity,
    required this.deleteQuantity,
    required this.textController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 2.3,
      height: 38,
      decoration: BoxDecoration(
        color: Color(0xFFe78337),
        borderRadius:
        BorderRadius.circular(
            8.0),
      ),
      child:
      Card(
        color: Color(0xFFe78337),

        margin: EdgeInsets.symmetric(horizontal: 0.0),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                deleteQuantity();
                _updateTextController();
              },
              icon:  SvgPicture.asset(
                'assets/minus-small.svg',  // Replace with the correct path to your SVG icon
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
                'assets/plus-small.svg',  // Replace with the correct path to your SVG icon
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

  // Helper method to update the text controller
  void _updateTextController() {
    // Update the text controller based on your logic
    // For example, you might want to increment or decrement the value
    // Here, I'm just printing the current value to the console
    print('Current Value: ${textController.text}');
  }
}








