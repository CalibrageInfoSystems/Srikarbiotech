import 'dart:convert';
import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:badges/src/badge.dart' as badge;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikarbiotech/transport_payment.dart';

import '../CartProvider.dart';
import '../Common/CommonUtils.dart';
import '../Model/GetItemGroups.dart';
import '../Model/OrderItemXrefType.dart';
import 'Common/SharedPrefsData.dart';
import 'Createorderscreen.dart';
import 'HomeScreen.dart';
import 'Model/ReturnOrderItemXrefType.dart';
import 'Returntransportdetails.dart';

class CreateReturnorderscreen extends StatefulWidget {
  final String cardName;
  final String cardCode;
  final String address;
  final String proprietorName;
  final String gstRegnNo;
  final String state;
  final String phone;
  final double creditLine;
  final double balance;

  CreateReturnorderscreen(
      {required this.cardName,
      required this.cardCode,
      required this.address,
      required this.state,
      required this.phone,
      required this.proprietorName,
      required this.gstRegnNo,
      required this.creditLine,
      required this.balance});

  @override
  State<CreateReturnorderscreen> createState() => _ProductListState();
}

class _ProductListState extends State<CreateReturnorderscreen> {
  // DBHelper dbHelper = DBHelper();
  bool isLoading = false;
  List<bool> isItemAddedToCart = [];

  // List<ProductResponse> products = [];
  List<int> quantities = [];
  List<TextEditingController> textEditingControllers = [];
  int selectedIndex = -1;
  late List<bool> isSelectedList;
  List<ItemGroup> filtereditemgroup = [];
  TextEditingController searchController = TextEditingController();
  bool isButtonClicked = false;
  int globalCartLength = 0;

  // List<int> selectedIndices = [];
  String Groupname = "";
  String ItemCode = "";
  int? selectindex;
  List<ProductResponse> totalproducts = [];
  List<ProductResponse> filteredproducts = [];
  String getgropcode = "";
  ApiResponse? apiResponse;
  String parts = "";

  List<String>? cartItemsJson = [];
  List<ReturnOrderItemXrefType> savedDataList = [];
  int cartitemslength = 0;
  int CompneyId = 0;
  String? userId = "";
  String? slpCode = "";
  ReturnOrderItemXrefType? returnorderItem; // Initialize orderItem to null
  late SharedPreferences prefs;

// Declare ApiResponse globally
  @override
  void initState() {
    super.initState();
    print('Total items in the cart: ${cartItemsJson!.length}');
    // fetchProducts();
    //  fetchProducts();
    selectindex = 0;
    getshareddata();
    initSharedPreferences();
  }

  Future<ApiResponse> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(
          'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Item/GetItemGroups/$CompneyId/null'));
      print('product group response: ${response.body}');

      if (response.statusCode == 200) {
        final ApiResponse apiResponse =
            ApiResponse.fromJson(json.decode(response.body));

        if (response.statusCode == 200) {
          return ApiResponse.fromJson(json.decode(response.body));
        } else {
          throw Exception('Failed to load products');
        }
      } else {
        throw Exception('Failed to load products');
      }
    } catch (error) {
      print('Error: $error');
      throw error; // Rethrow the error to be caught by the FutureBuilder
    }
  }

  @override
  Widget build(BuildContext context) {

    savedDataList = Provider.of<CartProvider>(context).getReturnCartItems();

    // Update the globalCartLength
    globalCartLength = savedDataList.length;
    return WillPopScope(
        onWillPop: () async {
          // Clear the cart data here
          final cartProvider = context.read<CartProvider>();

          clearCartData(cartProvider);

          return true; // Allow the back navigation
        },

        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFFe78337),
            leading: IconButton(
              icon: Icon(Icons.chevron_left, color: Colors.white),
              onPressed: () {
                final cartProvider = context.read<CartProvider>();

                // Clear the cart data here
                clearCartData(cartProvider);
                Navigator.pop(context); // This line will navigate back
              },
            ),
            title: Row(
              children: [
                SizedBox(width: 10), // Adjust spacing if needed
                Text(
                  'Select Products',
                  style: TextStyle(
                      fontSize: 18, color: Colors.white, letterSpacing: 1),
                ),
              ],
            ),
            titleSpacing: -10,
            centerTitle: false,
            actions: [
              GestureDetector(
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
              ),
              Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      // Navigate to the CartScreen
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const CartScreen(),
                      //   ),
                      // );
                    },
                    icon: Icon(
                      Icons.shopping_cart,
                      size: 30.0,
                    ),
                  ),
                  Positioned(
                    right: 5,
                    top: 1,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFD6D6D6), // Customize the badge color
                      ),
                      child: Text(
                        '${globalCartLength}',
                        style: TextStyle(
                          color: Color(0xFFe78337),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 20.0),
            ],
          ),
          body: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(top: 5.0, left: 8.0, right: 10.0),
                child: IntrinsicHeight(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.white,
                      ),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // First Row: Card Name
                          Text(
                            '${widget.cardName}',
                            style: CommonUtils.header_Styles16,
                            maxLines: 2, // Display in 2 lines
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 5.0), // Add some space between rows
                          // Second Row: Credit Limit
                          Row(
                            children: [
                              Expanded(
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
                                  style: TextStyle(
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
                          SizedBox(height: 5.0), // Add some space between rows
                          // Third Row: Outstanding Amount
                          Row(
                            children: [
                              Expanded(
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
                                  style: TextStyle(
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

              Padding(
                padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.0),
                    GestureDetector(
                      onTap: () {
                        // Handle the click event for the second text view
                        print('first textview clicked');
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(
                            color: Colors.black26,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: 10.0),
                                child: TextFormField(
                                  controller: searchController,
                                  onChanged: (value) {
                                    filterproducts();
                                  },
                                  keyboardType: TextInputType.name,
                                  style: CommonUtils.Mediumtext_12,
                                  decoration: InputDecoration(
                                    hintText: 'Product Search ',
                                    hintStyle: CommonUtils.hintstyle_14,
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Icon(
                                Icons.search,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 40.0,
                  child: apiResponse == null
                      ? Center(
                          child: CircularProgressIndicator.adaptive(),
                        )
                      : ListView.builder(
                          shrinkWrap: false,
                          scrollDirection: Axis.horizontal,
                          itemCount: apiResponse!.listResult.length + 1,
                          itemBuilder: (BuildContext context, int i) {
                            bool isAll = i == 0;
                            bool isSelected = selectindex == i;

                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 0.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: BorderSide(
                                    color: Color(0xFFe78337),
                                    width: 1.0,
                                  ),
                                ),
                                color: isSelected
                                    ? Color(0xFFe78337) // Selected color
                                    : Color(0xFFffefdf),
                                // Default color for other items
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectindex = i;
                                    });

                                    if (isAll) {
                                      getgropcode =
                                          ""; // Reset group code to null or your default value
                                      print('getitemgroupcode: All');
                                      fetchproductlist("");
                                      // Call your function for All
                                    } else {
                                      ItemGroup? itemGroup =
                                          apiResponse?.listResult[i - 1];
                                      getgropcode = itemGroup!.itmsGrpCod;
                                      print('getitemgroupcode:$getgropcode');
                                      fetchproductlist(getgropcode);
                                    }
                                  },
                                  child: Container(
                                    height: double.infinity,
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 8.0,
                                      horizontal: 12.0,
                                    ),
                                    child: Text(
                                      isAll
                                          ? 'All'
                                          : '${apiResponse?.listResult[i - 1]?.itmsGrpNam}',
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                        fontFamily: 'Roboto',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),

              Expanded(
                  child: Padding(
                padding:
                    const EdgeInsets.all(8.0), // Adjust the padding as needed
                child: filteredproducts == null
                    ? (isLoading
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator.adaptive(),
                                SizedBox(height: 16.0),
                                Text(
                                  'Loading, please wait...',
                                  style: TextStyle(
                                      fontSize: 18.0, color: Color(0xFF424242)),
                                ),
                              ],
                            ),
                          )
                        : Center(
                            child: Text(
                              'No products available for this Category',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Color(0xFF424242),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ))
                    : Consumer<CartProvider>(builder: (context, cartProvider, _) {
                        List<ReturnOrderItemXrefType> cartItems = cartProvider.getReturnCartItems();
                        // Set the global cart length
                        globalCartLength = cartItems.length;
                        print('Added cart: ${globalCartLength}');
                        return ListView.builder(
                          itemCount: filteredproducts.length,
                          itemBuilder: (context, index) {
                            if (index < 0 || index >= filteredproducts.length) {
                              return Container(
                                child: Text('Error: Index out of bounds'),
                              );
                            }

                            final productresp = filteredproducts[index];
                            if (globalCartLength > 0) {
                              String itemcode = productresp.itemCode!;

// Check if the current item is already added to the cart
                              for (var cartItem in cartProvider.getReturnCartItems()) {
                                if (cartItem.itemCode == itemcode) {
                                  isItemAddedToCart[index] = true;
                                  textEditingControllers[index].text = cartItem.orderQty.toString();
                                  print('previousscreen:${textEditingControllers[index].text}');
                                  break; // Exit the loop once the item is found in the cart
                                }
                              }
                            }
                            return GestureDetector(
                                onTap: () {
                                  print(
                                      'Tapped on ID: ${productresp.itemCode}');
                                },
                                // child: Container(
                                child: Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  elevation: 5.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      color: Colors.white,
                                    ),
                                    padding: const EdgeInsets.all(5.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        RichText(
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          text: TextSpan(
                                            text:
                                                '${productresp.itemName.toString()}\n',
                                            style: TextStyle(
                                              color: Color(0xFF424242),
                                              fontSize: 16,
                                              fontFamily: "Roboto",
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8.0,
                                        ),
                                        Row(
                                          // crossAxisAlignment: CrossAxisAlignment.start,
                                          // mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              child: Text(
                                                '${productresp.itmsGrpNam.toString()}',
                                                style: TextStyle(
                                                  color: Color(0xFF404040),
                                                  fontFamily: "Roboto",
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12.0,
                                                ),
                                              ),
                                            ),
                                            Spacer(),
                                            // Row(
                                            //   crossAxisAlignment:
                                            //       CrossAxisAlignment.end,
                                            //   mainAxisAlignment:
                                            //       MainAxisAlignment.end,
                                            //   children: [
                                            //     Container(
                                            //       child: Row(
                                            //         crossAxisAlignment:
                                            //             CrossAxisAlignment.end,
                                            //         mainAxisAlignment:
                                            //             MainAxisAlignment.end,
                                            //         children: [
                                            //           Text(
                                            //             '${productresp.ugpCode.toString()}',
                                            //             style: TextStyle(
                                            //               color:
                                            //                   Color(0xFFe78337),
                                            //               fontFamily: "Roboto",
                                            //               fontWeight:
                                            //                   FontWeight.w600,
                                            //               fontSize: 12.0,
                                            //             ),
                                            //           )
                                            //         ],
                                            //       ),
                                            //     )
                                            //   ],
                                            // ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5.0,
                                        ),
                                        // RichText(
                                        //   maxLines: 1,
                                        //   text: TextSpan(
                                        //     text:
                                        //         '₹${productresp.price.toString()}',
                                        //     style: TextStyle(
                                        //       color: Color(0xFFe78337),
                                        //       fontFamily: "Roboto",
                                        //       fontWeight: FontWeight.w600,
                                        //       fontSize: 16.0,
                                        //     ),
                                        //     children: [
                                        //       TextSpan(
                                        //         text: '/ Item',
                                        //         style: TextStyle(
                                        //           color: Color(0xFF8b8b8b),
                                        //           fontWeight: FontWeight.bold,
                                        //           fontSize: 13.0,
                                        //           // decoration: TextDecoration.lineThrough,
                                        //         ),
                                        //       ),
                                        //       // TextSpan(
                                        //       //   text: '${productresp.}',
                                        //       //   style: TextStyle(
                                        //       //     color: Color(0xFFa6a6a6),
                                        //       //     fontFamily: "Roboto",
                                        //       //     fontWeight: FontWeight.w600,
                                        //       //     fontSize: 12.0,
                                        //       //   ),
                                        //       // ),
                                        //     ],
                                        //   ),
                                        // ),
                                        // SizedBox(
                                        //   height: 5.0,
                                        // ),
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 0, left: 0, bottom: 0),
                                              child:
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    height: 36,
                                                    width: MediaQuery.of(context).size.width / 2.3,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFFe78337),
                                                      borderRadius: BorderRadius.circular(8.0),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        IconButton(
                                                          icon: SvgPicture.asset('assets/minus-small.svg',
                                                            color: Colors.white, // Replace with the correct path to your SVG iconcolor: Colors.white,width: 20.0,height: 20.0,
                                                          ),
                                                          onPressed: () {
                                                            if (quantities[index] > 1) {
                                                              setState(() {
                                                                quantities[index]--;
                                                                if (globalCartLength > 1) {
                                                                  String itemcode = productresp.itemCode!;
                                                                  for (var cartItem in cartProvider.getCartItems()) {
                                                                    if (cartItem.itemCode == itemcode) {
                                                                      cartItem.updateQuantity(quantities[index]);
                                                                    }}}});
                                                              textEditingControllers[index].text = quantities[index].toString();
                                                            }}, iconSize: 30.0,
                                                        ),
                                                        Expanded(
                                                          child: Align(
                                                            alignment: Alignment.center,
                                                            child: Container(
                                                              height: 35,
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(2.0),
                                                                child: Container(
                                                                  alignment: Alignment.center,
                                                                  width: MediaQuery.of(context).size.width / 5,
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.white,
                                                                  ),
                                                                  child: TextField(
                                                                    controller: textEditingControllers[index],
                                                                    keyboardType: TextInputType.number,
                                                                    inputFormatters: <TextInputFormatter>[
                                                                      FilteringTextInputFormatter
                                                                          .digitsOnly,
                                                                      LengthLimitingTextInputFormatter(
                                                                          5),
                                                                    ],
                                                                    onChanged: (value) {
                                                                      setState(() {
                                                                        //  quantities[index] = 1;
                                                                        quantities[index] = int.parse(value.isEmpty ? '1' : value);
                                                                        if (globalCartLength > 1) {
                                                                          String itemcode = productresp.itemCode!;
                                                                          for (var cartItem in cartProvider.getCartItems()) {
                                                                            if (cartItem.itemCode == itemcode) {
                                                                              cartItem.updateQuantity(quantities[index]);
                                                                            }}}});},
                                                                    decoration: InputDecoration(
                                                                      hintText: '1',
                                                                      hintStyle: CommonUtils.Mediumtext_o_14,
                                                                      border: InputBorder.none,
                                                                      focusedBorder: InputBorder.none,
                                                                      enabledBorder: InputBorder.none,
                                                                      contentPadding: EdgeInsets.only(bottom: 12.0),),
                                                                    textAlign: TextAlign.center,
                                                                    style: CommonUtils.Mediumtext_o_14,
                                                                  ),),),),),),
                                                        IconButton(
                                                          icon: SvgPicture.asset('assets/plus-small.svg',
                                                            color: Colors.white,
                                                            width: 20.0,
                                                            height: 20.0,
                                                          ),
                                                          onPressed: () {
                                                            setState(() {
                                                              quantities[index]++;
                                                              if (globalCartLength > 1) {
                                                                String itemcode = productresp.itemCode!;
                                                                for (var cartItem in cartProvider.getCartItems()) {
                                                                  if (cartItem.itemCode == itemcode) {
                                                                    cartItem.updateQuantity(quantities[index]);}}}
                                                            });
                                                            textEditingControllers[index].text = quantities[index].toString();
                                                          },
                                                          alignment: Alignment.centerLeft,
                                                          iconSize: 30.0,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(width: 8.0,),
                                                  Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        if (CompneyId == 1) {
                                                          if (!isItemAddedToCart[index]) {
                                                            setState(() {
                                                              isSelectedList[index] = !isSelectedList[index];
                                                            });

                                                            if (isSelectedList[index]) {
                                                              print('Adding ${quantities[index]} of ${filteredproducts[index].itemName} to the cart');

                                                              String itemGrpCod;

                                                              if (CompneyId == 1 || globalCartLength > 1) {
                                                                itemGrpCod = productresp.itmsGrpCod!;
                                                              } else {
                                                                itemGrpCod = productresp.itmsGrpCod!;
                                                              }

                                                              if (cartProvider.isSamereturnItemGroup(itemGrpCod)) {
                                                                returnorderItem = ReturnOrderItemXrefType(
                                                                    id: 1,
                                                                    returnOrderId: 1001,
                                                                    itemGrpCod: itemGrpCod,
                                                                    itemGrpName: productresp.itmsGrpNam,
                                                                    itemCode: productresp.itemCode,
                                                                    itemName: productresp.itemName,
                                                                    statusTypeId: 13,
                                                                    orderQty: quantities[index],
                                                                    price: productresp.price,
                                                                    remarks: "",
                                                                    totalPrice: null);

                                                                await cartProvider.addToreturnorderCart(
                                                                    returnorderItem!);
                                                                await prefs.setBool('isItemAddedToCart_$index', true);
                                                                List<OrderItemXrefType>cartItems = cartProvider.getCartItems();
                                                                print('Added items length: ${cartItems.length}');
                                                                globalCartLength = cartItems.length;

                                                                print('Item added successfully');
                                                                setState(() {
                                                                  isItemAddedToCart[index] = true;
                                                                });
                                                              } else {
                                                                // Display an error message, as itemGrpCod is not the same
                                                                print('Error: Cannot add items with different itemGrpCod to the cart');
                                                                CommonUtils.showCustomToastMessageLong('You can add items from one category in one order. For each category, you need to place a different order.', context, 1,
                                                                    4);
                                                                setState(() {
                                                                  isSelectedList[index] = false;
                                                                });}}}
                                                        }
                                                        else if (CompneyId == 2) {
                                                          if (!isItemAddedToCart[index]) {
                                                            setState(() {
                                                              isSelectedList[index] = !isSelectedList[
                                                              index];
                                                            });

                                                            if (isSelectedList[
                                                            index]) {
                                                              print(
                                                                  'Adding ${quantities[index]} of ${filteredproducts[index].itemName} to the cart');

                                                              String itemGrpCod;

                                                              if (CompneyId == 2 || globalCartLength > 1) {
                                                                itemGrpCod = productresp.itmsGrpCod!;
                                                              } else {
                                                                itemGrpCod = productresp.itmsGrpCod!;
                                                              }

                                                              // if (cartProvider
                                                              //     .isSameItemGroup(
                                                              //     itemGrpCod)) {

                            returnorderItem = ReturnOrderItemXrefType(
                            id: 1,
                            returnOrderId: 1001,
                            itemGrpCod: itemGrpCod,
                            itemGrpName: productresp.itmsGrpNam,
                            itemCode: productresp.itemCode,
                            itemName: productresp.itemName,
                            statusTypeId: 13,
                            orderQty: quantities[index],
                            price: productresp.price,
                            remarks: "",
                            totalPrice: null);

                            await cartProvider.addToreturnorderCart(
                            returnorderItem!);

                                                              await prefs.setBool('isItemAddedToCart_$index', true);
                                                              List<OrderItemXrefType>cartItems = cartProvider.getCartItems();
                                                              print('Added items length: ${cartItems.length}');
                                                              globalCartLength = cartItems.length;
                                                              print('Item added successfully');
                                                              setState(() {
                                                                isItemAddedToCart[index] = true;
                                                              });

                                                            }
                                                          }
                                                        }
                                                      },
                                                      child: Container(height: 36,
                                                        decoration: BoxDecoration(
                                                          color: isItemAddedToCart[index] ? Color(0xFFe78337) : Color(0xFFffefdf),
                                                          border: Border.all(
                                                            color: Color(0xFFe78337),
                                                            width: 1.0,
                                                          ),
                                                          borderRadius: BorderRadius.circular(8.0),
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                                          child: Row(
                                                            children: [Icon(Icons.add_shopping_cart,
                                                              size: 18.0,
                                                              color: isItemAddedToCart[index]
                                                                  ? Color(
                                                                  0xFFffefdf)
                                                                  : Color(
                                                                  0xFFe78337),
                                                            ),
                                                              SizedBox(
                                                                  width: 8.0),
                                                              // Display "Added" if the item is already added to the cart
                                                              Text(
                                                                isItemAddedToCart[index] ? 'Added' : 'Add',
                                                                style:
                                                                TextStyle(
                                                                  color: isItemAddedToCart[
                                                                  index]
                                                                      ? Color(
                                                                      0xFFffefdf)
                                                                      : Color(
                                                                      0xFFe78337),
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                  "Roboto",
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 6.0),
                                                            ],),),),),),
                                                  SizedBox(width: 8.0),
                                                  if (isItemAddedToCart[index]) // Render delete button only when item is added to cart
                                                    GestureDetector(


                                                      onTap: () {
                                                        // Update state to show "Add" button and reset quantity
                                                        setState(() {
                                                          isItemAddedToCart[index] = false;
                                                          quantities[index] = 1;
                                                        });

                                                        // Find the index of the item in the cart based on the product code
                                                        int deleteIndex = cartItems.indexWhere(
                                                              (item) => item.itemCode == productresp.itemCode,
                                                        );

                                                        if (deleteIndex != -1) {
                                                          // Remove the item from the cart
                                                          cartItems.removeAt(deleteIndex);
                                                          textEditingControllers.removeAt(deleteIndex);
                                                        }

                                                        fetchproductlist(getgropcode);
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
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                //  )
                                );
                            // rest of your code...
                          },
                        );
                      }),
              ))
            ],
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
                        onTap: () {
                          if (globalCartLength > 0) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    Returntransportdetails(
                                        cardName: widget.cardName,
                                        cardCode: widget.cardCode,
                                        address: widget.address,
                                        state: widget.state,
                                        phone: widget.phone,
                                        proprietorName: widget.proprietorName,
                                        gstRegnNo: widget.gstRegnNo,
                                        creditLine: double.parse('${widget.creditLine}'),
                                        balance: double.parse('${widget.balance}'),
                                        lrnumber: '',
                                        lrdate: '',
                                        remarks: '',
                                        transportname: ''

                                    ),
                              ),
                            );
                          }

                          else {
                          CommonUtils.showCustomToastMessageLong(
                          'Please Select Atleast One Product', context, 1, 4);

                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 45.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.0),
                            color: const Color(0xFFe78337),
                          ),
                          child: const Center(
                            child: Text(
                              'Select Transport',
                              style: CommonUtils.Buttonstyle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        ));
  }

  Widget buildweight(int index, String mode, Function onTap,
      {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        onTap(); // Call the onTap function passed as a parameter
      },
      child: Container(
        width: 60,
        height: 36,
        child: Card(
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.0),
            side: BorderSide(
              color: isSelected ? Color(0xFFe78337) : Color(0xFFe78337),
            ),
          ),
          color: isSelected ? Color(0xFFe78337) : Color(0xFFF8dac2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                mode,
                style: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void filterproducts() {
    final String searchTerm = searchController.text.toLowerCase();
    setState(() {
      filteredproducts = totalproducts.where((product) {
        return product.itemName!.toLowerCase().contains(searchTerm) ||
            product.itemCode!.toLowerCase().contains(searchTerm);
      }).toList();
      print('filteredproducts : ${filteredproducts}');
      print('filteredproducts : ${filteredproducts!.length}');
    });
  }

  Future<void> getshareddata() async {
    userId = await SharedPrefsData.getStringFromSharedPrefs("userId");
    slpCode = await SharedPrefsData.getStringFromSharedPrefs("slpCode");
    CompneyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
    print('User ID: $userId');
    print('SLP Code: $slpCode');
    print('Company ID: $CompneyId');

    fetchProducts().then((response) {
      setState(() {
        isLoading = true; // or false
        // clearSharedPreferences();
        apiResponse = response;
        fetchproductlist("");
      });
    });
  }

  void fetchproductlist(String getgropcode) async {
    totalproducts.clear();
    final String apiUrl =
        'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Item/GetAllItemsByItemGroupCode';
    final requestBody = {
      "CompanyId": '$CompneyId',
      "PartyCode": '${widget.cardCode}',
      "ItmsGrpCod": getgropcode
    };

    print(jsonEncode(requestBody));

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print('productListResponse: ${response.body}');

    try {
      if (response.statusCode == 200) {
        final Map<String, dynamic>? responseData = jsonDecode(response.body);

        if (responseData == null) {
          throw Exception('Response data is null');
        }

        final List<dynamic>? responseDataList =
            responseData['response']['listResult'];

        if (responseDataList == null) {
          print('List result is null');
        } else {
          // Print the length directly on the list
          print('productLength ${responseDataList.length}');

          setState(() {
            isLoading = true; // or false
            totalproducts = responseDataList
                .map((response) => ProductResponse.fromJson(response))
                .toList();
            filteredproducts = List.from(totalproducts);
            isItemAddedToCart =
                List.generate(filteredproducts.length, (index) => false);
            quantities = List.generate(filteredproducts.length, (index) => 1);
            isSelectedList =
                List.generate(filteredproducts.length, (index) => false);
            textEditingControllers = List.generate(
                filteredproducts.length, (index) => TextEditingController());
            print('productResponse ${filteredproducts.length}');
          });
        }
      } else {
        throw Exception('Failed to fetch Products');
      }
    } catch (error) {
      print('Error: $error');
      throw Exception('Failed to connect to the API');
    }
  }

  void initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  void clearCartData(CartProvider cartProvider) {
    cartProvider.clearreturnCart();
  }
}
