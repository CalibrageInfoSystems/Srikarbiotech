import 'dart:convert';
import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'HomeScreen.dart';

class Createorderscreen extends StatefulWidget {
  final String cardName;
  final String cardCode;
  final String address;
  final String proprietorName;
  final String gstRegnNo;
  final String state;
  final String phone;

  Createorderscreen(
      {required this.cardName,
        required this.cardCode,
        required this.address,
        required this.state,
        required this.phone,
        required this.proprietorName,
        required this.gstRegnNo});

  @override
  State<Createorderscreen> createState() => _ProductListState();
}
// class OrderItemXrefType {
//   final String itemName;
//   final int price;
//   final int orderQty;
//
//   OrderItemXrefType({
//     required this.itemName,
//     required this.price,
//     required this.orderQty,
//   });
//   Map<String, dynamic> toJson() => {
//     'itemName': itemName,
//     'price': price,
//     'orderQty': orderQty,
//   };
//
// }

class _ProductListState extends State<Createorderscreen> {
  // DBHelper dbHelper = DBHelper();
  bool isLoading = false;
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
  List<OrderItemXrefType> savedDataList = [];
  int cartitemslength = 0;
  int CompneyId = 0;
  String? userId = "";
  String? slpCode = "";

// Function to save cart items to SharedPreferences
  Future<void> saveCartItems(List<OrderItemXrefType> selectedProducts) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve existing cart items from SharedPreferences
    cartItemsJson = prefs.getStringList('cart_items') ?? [];

    // Convert the selected products to a JSON string
    List<String> selectedProductStrings =
    selectedProducts.map((product) => jsonEncode(product.toJson())).toList();

    // Add the selected products to the existing cart items
    cartItemsJson!.addAll(selectedProductStrings);

    // Save the updated cart items back to SharedPreferences
    prefs.setStringList('cart_items', cartItemsJson!);

    // Log the cart items
    print('Cart Items: $cartItemsJson');
    // cartitemslength = '${cartItemsJson.length}';
    print('Cart Items Length: ${cartItemsJson!.length}');


  }

// Declare ApiResponse globally
  @override
  void initState() {
    super.initState();
    print('Total items in the cart: ${cartItemsJson!.length}');
    // fetchProducts();
    //  fetchProducts();
    selectindex = 0;
    getshareddata();


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
    // ... (the rest of your existing build method)

    return Scaffold(
      appBar:
      AppBar(
        backgroundColor: Color(0xFFe78337),
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // This line will navigate back
          },
        ),
        title: Row(
          children: [

            SizedBox(width: 10), // Adjust spacing if needed
            Text(
              'Select Products',
              style: TextStyle(fontSize: 18, color: Colors.white, letterSpacing: 1),
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
                  : 'assets/srikar-seed.png',
              width: CompneyId == 1 ? 30 : 60,
              height: CompneyId == 1 ? 30 : 40,
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
                icon: Icon(Icons.shopping_cart),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red, // Customize the badge color
                  ),
                  child: Text(
                    '${globalCartLength}',
                    style: TextStyle(
                      color: Colors.white,
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
              height: 50.0,
              child: apiResponse == null
                  ? Center(
                child: CircularProgressIndicator.adaptive(),
              )
                  :
              ListView.builder(
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
                          : Color(0xFFF8dac2), // Default color for other items
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectindex = i;
                          });

                          if (isAll) {
                            getgropcode = ""; // Reset group code to null or your default value
                            print('getitemgroupcode: All');
                            fetchproductlist("");
                            // Call your function for All
                          } else {
                            ItemGroup? itemGroup = apiResponse?.listResult[i - 1];
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
                            isAll ? 'All' : '${apiResponse?.listResult[i - 1]?.itmsGrpNam}',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
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
                    :
                Consumer<CartProvider>(
                    builder: (context, cartProvider, _) {
                      List<OrderItemXrefType> cartItems = cartProvider.getCartItems();
                      // Set the global cart length

                      return
                        ListView.builder(
                          itemCount: filteredproducts.length,
                          itemBuilder: (context, index) {
                            if (index < 0 || index >= filteredproducts.length) {
                              return Container(
                                child: Text('Error: Index out of bounds'),
                              );
                            }

                            final productresp = filteredproducts[index];

                            return GestureDetector(
                                onTap: () {
                                  print('Tapped on ID: ${productresp.itemCode}');
                                },
                                child: Container(
                                    child: Card(
                                      color: Colors.white,
                                      elevation: 5.0,
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
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
                                                      color: Color(0xFF848484),
                                                      fontFamily: "Roboto",
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 12.0,
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
                                                      child: Row(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                        children: [

                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5.0,
                                            ),
                                            RichText(
                                              maxLines: 1,
                                              text: TextSpan(
                                                text:
                                                '₹${productresp.price.toString()}  ',
                                                style: TextStyle(
                                                  color: Color(0xFFe78337),
                                                  fontFamily: "Roboto",
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16.0,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: '/ ',
                                                    style: TextStyle(
                                                      color: Color(0xFFa6a6a6),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13.0,
                                                      // decoration: TextDecoration.lineThrough,
                                                    ),
                                                  ),
                                                  // TextSpan(
                                                  //   text: '${productresp.}',
                                                  //   style: TextStyle(
                                                  //     color: Color(0xFFa6a6a6),
                                                  //     fontFamily: "Roboto",
                                                  //     fontWeight: FontWeight.w600,
                                                  //     fontSize: 12.0,
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5.0,
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      right: 0, left: 0, bottom: 0),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        height: 36,
                                                        width: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                            2.5,
                                                        decoration: BoxDecoration(
                                                          color: Color(0xFFe78337),
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            IconButton(
                                                              icon: Icon(Icons.remove,
                                                                  color: Colors.white),
                                                              onPressed: () {
                                                                if (quantities[index] >
                                                                    1) {
                                                                  setState(() {
                                                                    quantities[index]--;
                                                                  });
                                                                  textEditingControllers[
                                                                  index]
                                                                      .text =
                                                                      quantities[index]
                                                                          .toString();
                                                                }
                                                              },
                                                              iconSize: 25.0,
                                                            ),
                                                            Expanded(
                                                              child: Align(
                                                                alignment:
                                                                Alignment.center,
                                                                child: Container(
                                                                  height: 35,
                                                                  child: Padding(
                                                                    padding:
                                                                    const EdgeInsets
                                                                        .all(2.0),
                                                                    child: Container(
                                                                      alignment:
                                                                      Alignment
                                                                          .center,
                                                                      width: MediaQuery.of(
                                                                          context)
                                                                          .size
                                                                          .width /
                                                                          5.1,
                                                                      decoration:
                                                                      BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      child: TextField(
                                                                        controller:
                                                                        textEditingControllers[
                                                                        index],
                                                                        keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                        inputFormatters: <TextInputFormatter>[
                                                                          FilteringTextInputFormatter
                                                                              .digitsOnly,
                                                                          LengthLimitingTextInputFormatter(
                                                                              5),
                                                                        ],
                                                                        onChanged:
                                                                            (value) {
                                                                          setState(() {
                                                                            quantities[
                                                                            index] = int.parse(value
                                                                                .isEmpty
                                                                                ? '1'
                                                                                : value);
                                                                          });
                                                                        },
                                                                        decoration:
                                                                        InputDecoration(
                                                                          hintText: '1',
                                                                          hintStyle:
                                                                          CommonUtils
                                                                              .Mediumtext_o_14,
                                                                          border:
                                                                          InputBorder
                                                                              .none,
                                                                          focusedBorder:
                                                                          InputBorder
                                                                              .none,
                                                                          enabledBorder:
                                                                          InputBorder
                                                                              .none,
                                                                          contentPadding:
                                                                          EdgeInsets.only(
                                                                              bottom:
                                                                              10.0),
                                                                        ),
                                                                        textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                        style: CommonUtils
                                                                            .Mediumtext_o_14,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            IconButton(
                                                              icon: Icon(Icons.add,
                                                                  color: Colors.white),
                                                              onPressed: () {
                                                                setState(() {
                                                                  quantities[index]++;
                                                                });
                                                                textEditingControllers[
                                                                index]
                                                                    .text =
                                                                    quantities[index]
                                                                        .toString();
                                                              },
                                                              alignment:
                                                              Alignment.centerLeft,
                                                              iconSize: 25.0,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 8.0,
                                                      ),
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets.symmetric(
                                                            horizontal: 4.0),
                                                        child:
                                                        GestureDetector(
                                                          onTap: () async {
                                                            setState(() {
                                                              isSelectedList[index] = !isSelectedList[index];

                                                            });

                                                            if (isSelectedList[index]) {
                                                              print(
                                                                  'Adding ${quantities[index]} of ${filteredproducts[index].itemName} to the cart');

                                                              // Create an OrderItemXrefType object with necessary details
                                                              OrderItemXrefType orderItem = OrderItemXrefType(
                                                                id: 1, // Sample value, adjust as needed
                                                                orderId: 1001, // Sample value, adjust as needed
                                                                itemGrpCod: productresp.itmsGrpCod, // Sample value, adjust as needed
                                                                itemGrpName: productresp.itmsGrpNam, // Sample value, adjust as needed
                                                                itemCode:productresp.itemCode, // Sample value, adjust as needed
                                                                itemName: productresp.itemName,
                                                                noOfPcs: '10', // Sample value, adjust as needed
                                                                orderQty: quantities[index],
                                                                price: 5000, // Adjust the price based on your requirement
                                                                igst: 18.0, // Sample value, adjust as needed
                                                                cgst: 9.0, // Sample value, adjust as needed
                                                                sgst: 9.0, // Sample value, adjust as needed
                                                              );

                                                              cartProvider.addToCart(orderItem);
                                                              setState(() {
                                                                isSelectedList[index] = true;
                                                              });
                                                              // Get the added item
                                                              print('Added item: ${orderItem.itemName}');

                                                              // Get the total number of items in the cart
                                                              List<OrderItemXrefType> cartItems = cartProvider.getCartItems();
                                                              print('Added items length: ${cartItems.length}');
                                                              globalCartLength = cartItems.length;

                                                            }

                                                          },
                                                          child: Container(
                                                            height: 36,
                                                            decoration: BoxDecoration(
                                                              color: isSelectedList[
                                                              index]
                                                                  ? Color(0xFFe78337)
                                                                  : Color(0xFFF8dac2),
                                                              border: Border.all(
                                                                color:
                                                                Color(0xFFe78337),
                                                                width: 1.0,
                                                              ),
                                                              borderRadius:
                                                              BorderRadius.circular(
                                                                  8.0),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 4.0),
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .add_shopping_cart,
                                                                    size: 18.0,
                                                                    color: isSelectedList[
                                                                    index]
                                                                        ? Color(
                                                                        0xFFfff6eb)
                                                                        : Color(
                                                                        0xFFe78337),
                                                                  ),
                                                                  SizedBox(
                                                                      width:
                                                                      4.0), // Adjust the spacing between icon and text
                                                                  Text(
                                                                    isSelectedList[
                                                                    index]
                                                                        ? 'Added'
                                                                        : 'Add',
                                                                    style: TextStyle(
                                                                      color: isSelectedList[
                                                                      index]
                                                                          ? Color(
                                                                          0xFFfff6eb)
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
                                                                  SizedBox(width: 4.0),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    )));
                            // rest of your code...
                          },
                        ); }
                ) ,
              )
          )],
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
                  // Add logic for the download button
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => transport_payment(
                        cardName: '${widget.cardName}',
                        cardCode: '${widget.cardCode}',
                        address: '${widget.address}',
                        state: '${widget.state}',
                        phone: '${widget.phone}',
                        proprietorName: '${widget.proprietorName}',
                        gstRegnNo: '${widget.gstRegnNo}',
                        bookingplace: '',
                        preferabletransport: '',
                      ),
                    ),
                  );

                  print('Download button clicked');
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xFFe78337),
                  ),
                  child: const Center(
                    child: Text(
                      'Select Transport',
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
    );
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

  void saveData(int index) async {
    // Get the SharedPreferences instance
    List<OrderItemXrefType> savedDataList = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final productresp = filteredproducts[index];

    Map<String, dynamic> savedData = {
      "Id": 1,
      "OrderId": 123,
      "ItemGrpCod": productresp.itmsGrpCod,
      "ItemGrpName": productresp.itmsGrpNam,
      "ItemCode": productresp.itemCode,
      "ItemName": productresp.itemName,
      "NoOfPcs": quantities,
      "OrderQty": quantities,
      "Price":  productresp.price,
      "IGST":productresp.gst,
      "CGST": productresp.gst!/2,
      "SGST": productresp.gst!/2,
    };

    setState(() {
      savedDataList.add(savedData as OrderItemXrefType);
    });
  }

  // Future<void> clearSharedPreferences() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.clear();
  // }

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
    userId= await SharedPrefsData.getStringFromSharedPrefs("userId");
    slpCode= await SharedPrefsData.getStringFromSharedPrefs("slpCode");
    CompneyId= await SharedPrefsData.getIntFromSharedPrefs("companyId");
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

            quantities = List.generate(filteredproducts.length, (index) => 0);
            isSelectedList =
                List.generate(filteredproducts.length, (index) => false);
            textEditingControllers = List.generate(
                filteredproducts.length,
                    (index) => TextEditingController());
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



}

// Static product details
class ProductResponse {
  String? itemCode;
  String? itemName;
  String? itmsGrpCod;
  String? itmsGrpNam;
  String? priceUnit;
  String? gstTaxCtg;
  double? price;
  double? gst;
  String? ugpEntry;
  String? ugpCode;
  String? ugpName;
  int? numInSale;

  ProductResponse({
    required this.itemCode,
    required this.itemName,
    required this.itmsGrpCod,
    required this.itmsGrpNam,
    required this.priceUnit,
    required this.gstTaxCtg,
    required this.price,
    required this.gst,
    required this.ugpEntry,
    required this.ugpCode,
    required this.ugpName,
    required this.numInSale,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      itemCode: json['itemCode'] ?? '',
      itemName: json['itemName'] ?? '',
      itmsGrpCod: json['itmsGrpCod'] ?? '',
      itmsGrpNam: json['itmsGrpNam'] ?? '',
      priceUnit: json['priceUnit'] ?? '',
      gstTaxCtg: json['gstTaxCtg'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      gst: (json['gst'] as num?)?.toDouble() ?? 0.0,
      ugpEntry: json['ugpEntry'] ?? '',
      ugpCode: json['ugpCode'] ?? '',
      ugpName: json['ugpName'] ?? '',
      numInSale: json['numInSale'] ?? 0,
    );
  }
}

class Product {
  final List<ProductResponse> listResult;
  final int count;
  final int affectedRecords;
  final bool isSuccess;

  Product({
    required this.listResult,
    required this.count,
    required this.affectedRecords,
    required this.isSuccess,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      listResult: (json['listResult'] as List)
          .map((itemJson) => ProductResponse.fromJson(itemJson))
          .toList(),
      count: json['count'],
      affectedRecords: json['affectedRecords'],
      isSuccess: json['isSuccess'],
    );
  }
}
