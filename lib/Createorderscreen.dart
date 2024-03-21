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
import 'package:shimmer/shimmer.dart';
import 'package:srikarbiotech/Ordersubmit_screen.dart';
import 'package:srikarbiotech/Services/api_config.dart';
import 'package:srikarbiotech/transport_payment.dart';

import '../CartProvider.dart';
import '../Common/CommonUtils.dart';
import '../Model/GetItemGroups.dart';
import '../Model/OrderItemXrefType.dart';
import 'Common/SharedPrefsData.dart';
import 'HomeScreen.dart';
import 'WareHouseScreen.dart';

class Createorderscreen extends StatefulWidget {
  final String cardName;
  final String cardCode;
  final String address;
  final String proprietorName;
  final String gstRegnNo;
  final String state;
  final String phone;
  final double creditLine;
  final double balance;
  final String whsCode;
  final String whsName;
  final String whsState;

  const Createorderscreen(
      {super.key,
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
      required this.whsState});

  @override
  State<Createorderscreen> createState() => _ProductListState();
}

class _ProductListState extends State<Createorderscreen> {
  // DBHelper dbHelper = DBHelper();
  bool isLoading = false;
  List<bool> isItemAddedToCart = [];

  bool _dataLoaded = false; // Initially set dataLoaded to false

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
  OrderItemXrefType? orderItem; // Initialize orderItem to null
  late SharedPreferences prefs;

// Declare ApiResponse globally
  @override
  void initState() {
    super.initState();
    print('Total items in the cart: ${cartItemsJson!.length}');
    // fetchProducts();
    //  fetchProducts();
    selectindex = 0;
    CommonUtils.checkInternetConnectivity().then(
          (isConnected) {
        if (isConnected) {
          getshareddata();
          fetchproductlist("");
          initSharedPreferences();
          print('The Internet Is Connected');
        } else {
          CommonUtils.showCustomToastMessageLong(
              'Please check your internet  connection', context, 1, 4);
          print('The Internet Is not  Connected');
        }
      },
    );

  }

  Future<ApiResponse> fetchProducts() async {
    String apiurl = baseUrl + FetchCreateOrderapi + CompneyId.toString() + "/null";
    try {
      final response = await http.get(Uri.parse(apiurl));
      print('product group response: ${response.body}');

      if (response.statusCode == 200) {
        final ApiResponse apiResponse = ApiResponse.fromJson(json.decode(response.body));

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
      rethrow; // Rethrow the error to be caught by the FutureBuilder
    }
  }

  @override
  Widget build(BuildContext context) {
    savedDataList = Provider.of<CartProvider>(context).getCartItems();

    // Update the globalCartLength
    globalCartLength = savedDataList.length;
    return WillPopScope(
        onWillPop: () async {
          // Clear the cart data here
          final cartProvider = context.read<CartProvider>();

          clearCartData(cartProvider);
          Navigator.of(context).pop();
          // Navigator.pushReplacement(
          //     context,
          //     MaterialPageRoute(builder: (context) =>  WareHouseScreen(
          //         from: 'CreateOrder',
          //         cardName: widget.cardName,
          //         cardCode: widget.cardCode,
          //         address: widget.address,
          //         state: widget.state,
          //         phone: widget.phone,
          //         proprietorName: widget.proprietorName,
          //         gstRegnNo: widget.gstRegnNo,
          //
          //         creditLine: double.parse('${widget.creditLine}'),
          //         // Convert to double
          //         balance: double.parse('${widget.balance}'
          //
          //         ))));
          return true; // Allow the back navigation
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFe78337),
            leading: IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white),
              onPressed: () {
                final cartProvider = context.read<CartProvider>();

                // Clear the cart data here
                clearCartData(cartProvider);
                Navigator.of(context).pop();
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(builder: (context) =>  WareHouseScreen(
                //       from: 'CreateOrder',
                //       cardName: widget.cardName,
                //       cardCode: widget.cardCode,
                //       address: widget.address,
                //       state: widget.state,
                //       phone: widget.phone,
                //       proprietorName: widget.proprietorName,
                //       gstRegnNo: widget.gstRegnNo,
                //
                //       creditLine: double.parse('${widget.creditLine}'),
                //       // Convert to double
                //       balance: double.parse('${widget.balance}'
                //
                // )))); // This line will navigate back
                // Navigator.pop(context); // This line will navigate back
              },
            ),
            title: const Row(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Handle the click event for the home icon
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    },
                    child: SizedBox(
                      width: 30, // Same width as the cart icon
                      height: 30, // Same height as the cart icon
                      child: Image.asset(
                        CompneyId == 1 ? 'assets/srikar-home-icon.png' : 'assets/seeds-home-icon.png',
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (globalCartLength > 0) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Ordersubmit_screen(
                                  cardName: widget.cardName,
                                  cardCode: widget.cardCode,
                                  address: widget.address,
                                  state: widget.state,
                                  phone: widget.phone,
                                  proprietorName: widget.proprietorName,
                                  gstRegnNo: widget.gstRegnNo,

                                  creditLine: double.parse('${widget.creditLine}'),
                                  // Convert to double
                                  balance: double.parse('${widget.balance}'),
                                  whsCode: widget.whsCode,
                                  whsName: widget.whsName,
                                  whsState: widget.whsState,
                                ),
                              ),
                            );

                            print(' button clicked');
                          } else {
                            CommonUtils.showCustomToastMessageLong('Please Select Atleast One Product', context, 1, 4);
                          }
                        },
                        icon: const Icon(
                          Icons.shopping_cart,
                          size: 30.0,
                        ),
                      ),
                      Positioned(
                        right: 5,
                        top: 1,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFD6D6D6), // Customize the badge color
                          ),
                          child: Text(
                            '$globalCartLength',
                            style: const TextStyle(
                              color: Color(0xFFe78337),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 20.0),
            ],
          ),
          body: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.only(top: 5.0, left: 8.0, right: 10.0),
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
                            widget.cardName,
                            style: CommonUtils.header_Styles16,
                            maxLines: 2, // Display in 2 lines
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5.0), // Add some space between rows
                          // Second Row: Credit Limit
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
              Padding(
                padding: const EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Handle the click event for the second text view
                        print('first textview clicked');
                      },
                      child: Container(
                        height: 45,
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
                                padding: const EdgeInsets.only(left: 10.0),
                                child: TextFormField(
                                  controller: searchController,
                                  onChanged: (value) {
                                    filterproducts();
                                  },
                                  keyboardType: TextInputType.name,
                                  style: CommonUtils.Mediumtext_12,
                                  decoration: const InputDecoration(
                                    hintText: 'Product Search ',
                                    hintStyle: CommonUtils.hintstyle_14,
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            const Padding(
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
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 5.0),
                child: SizedBox(
                  height: 40.0,
                  child: apiResponse == null
                      ? const Center(
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
                              padding: const EdgeInsets.symmetric(horizontal: 0.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: const BorderSide(
                                    color: Color(0xFFe78337),
                                    width: 1.0,
                                  ),
                                ),
                                color: isSelected
                                    ? const Color(0xFFe78337) // Selected color
                                    : const Color(0xFFffefdf), // Default color for other items
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                      horizontal: 12.0,
                                    ),
                                    child: Text(
                                      isAll ? 'All' : '${apiResponse?.listResult[i - 1].itmsGrpNam}',
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
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 0.0), // Adjust the padding as needed

    child: Consumer<CartProvider>(
    builder: (context, cartProvider, _) {
    if (isLoading) {
    // Show loading indicator while waiting for data
    return buildShimmerEffect();
    } else
      if (filteredproducts.isEmpty) {
    // Show "No products available" message if data is not loaded or both lists are empty
    return Center(
    child: Text(
    'No products available',
    style: TextStyle(
    fontSize: 18.0,
    color: Color(0xFF424242),
    fontWeight: FontWeight.bold,
    ),
    ),
    );
    }
    else{
    // Display the data
    // Modify this part according to your data display logic
    // return YourDataDisplayWidget();


      return Consumer<CartProvider>(builder: (context, cartProvider, _) {
                        List<OrderItemXrefType> cartItems = cartProvider.getCartItems();
                        // Set the global cart length
                        globalCartLength = cartItems.length;
                        print('Added cart: $globalCartLength');
                        return ListView.builder(
                          itemCount: isLoading ? 5 : filteredproducts.length,
                          itemBuilder: (context, index) {
                            if (index < 0 || index >= filteredproducts.length) {
                              return Container(
                                child: const Text('Error: Index out of bounds'),
                              );
                            }
                            final productresp = filteredproducts[index];
                            if (globalCartLength > 0) {
                              String itemcode = productresp.itemCode!;
                              for (var cartItem in cartProvider.getCartItems()) {
                                if (cartItem.itemCode == itemcode) {
                                  isItemAddedToCart[index] = true;
                                  textEditingControllers[index].text = cartItem.orderQty.toString();
                                  int productIndex = filteredproducts.indexWhere((product) => product.itemCode == itemcode);
                                  if (productIndex != -1) {
                                    quantities[productIndex] = cartItem.orderQty!;
                                  }
                                  print('previousscreen:${textEditingControllers[index].text}');
                                  break; // Exit the loop once the item is found in the cart
                                }
                              }
                            }

                            return GestureDetector(
                                onTap: () {
                                  print('Tapped on ID: ${productresp.itemCode}');
                                },
                                // child: Container(
                                //     //  color: Colors.white,
                                //
                                child: Card(
                                  //     color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  elevation: 10.0,
                                  child: Container(
                                    //color: Colors.white,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      color: Colors.white,
                                    ),
                                    padding: const EdgeInsets.all(5.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 6,
                                              child: Container(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    RichText(
                                                      overflow: TextOverflow.clip,
                                                      //    maxLines: 2,
                                                      text: TextSpan(
                                                        text: productresp.itemName.toString(),
                                                        style: const TextStyle(
                                                          color: Color(0xFF424242),
                                                          fontSize: 16,
                                                          fontFamily: "Roboto",
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5.0,
                                                    ),
                                                    Container(
                                                      child: Text(
                                                        productresp.itmsGrpNam.toString(),
                                                        style: const TextStyle(
                                                          color: Color(0xFF404040),
                                                          fontFamily: "Roboto",
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 12.0,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5.0,
                                                    ),
                                                    Row(
                                                      children: [
                                                        RichText(
                                                          maxLines: 1,
                                                          text: TextSpan(
                                                            text: '₹${productresp.price.toString()}',
                                                            style: const TextStyle(
                                                              color: Color(0xFFe78337),
                                                              fontFamily: "Roboto",
                                                              fontWeight: FontWeight.w600,
                                                              fontSize: 16.0,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 15.0,
                                                        ),
                                                        Container(
                                                          child: Row(
                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                            children: [
                                                              Text(
                                                                productresp.ugpCode.toString(),
                                                                style: const TextStyle(
                                                                  color: Color(0xFFe78337),
                                                                  fontFamily: "Roboto",
                                                                  fontWeight: FontWeight.w600,
                                                                  fontSize: 12.0,
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
                                            ),
                                            const Spacer(),

                                            // productresp.itemImage != null
                                            //     ? Image.network(
                                            //   productresp.itemImage!,
                                            //   width: 85,
                                            // )
                                            //     : Image.asset(
                                            //   'assets/srikargroups_logo.png',
                                            //   width: 85,
                                            // ),

                                            if (productresp.itemImage != null && productresp.itemImage!.isNotEmpty)
                                              Image.network(
                                                productresp.itemImage!,
                                                width: 85,
                                                height: 85,
                                              )
                                            else
                                              Image.asset(
                                                CompneyId == 1 ? 'assets/srikar-bio.png' : 'assets/srikar-seed.png',
                                                width: 85,
                                                height: 85,
                                              ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 5.0,
                                        ),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(right: 0, left: 0, bottom: 0),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    height: 36,
                                                    width: MediaQuery.of(context).size.width / 2.3,
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFe78337),
                                                      borderRadius: BorderRadius.circular(8.0),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        IconButton(
                                                          icon: SvgPicture.asset(
                                                            'assets/minus-small.svg',
                                                            color: Colors.white, // Replace with the correct path to your SVG iconcolor: Colors.white,width: 20.0,height: 20.0,
                                                          ),
                                                          onPressed: () {
                                                            if (quantities[index] > 1) {
                                                              setState(() {
                                                                quantities[index]--;
                                                                if (globalCartLength > 0) {
                                                                  String itemcode = productresp.itemCode!;
                                                                  for (var cartItem in cartProvider.getCartItems()) {
                                                                    if (cartItem.itemCode == itemcode) {
                                                                      cartItem.updateQuantity(quantities[index]);
                                                                    }
                                                                  }
                                                                }
                                                              });
                                                              textEditingControllers[index].text = quantities[index].toString();
                                                            }
                                                          },
                                                          iconSize: 30.0,
                                                        ),
                                                        Expanded(
                                                          child: Align(
                                                            alignment: Alignment.center,
                                                            child: SizedBox(
                                                              height: 35,
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(2.0),
                                                                child: Container(
                                                                  alignment: Alignment.center,
                                                                  width: MediaQuery.of(context).size.width / 5,
                                                                  decoration: const BoxDecoration(
                                                                    color: Colors.white,
                                                                  ),
                                                                  child: TextField(
                                                                    controller: textEditingControllers[index],
                                                                    keyboardType: TextInputType.number,
                                                                    inputFormatters: <TextInputFormatter>[
                                                                      FilteringTextInputFormatter.digitsOnly,
                                                                      LengthLimitingTextInputFormatter(5),
                                                                    ],
                                                                    onChanged: (value) {
                                                                      setState(() {
                                                                        //  quantities[index] = 1;
                                                                        quantities[index] = int.parse(value.isEmpty ? '1' : value);
                                                                        if (globalCartLength > 0) {
                                                                          String itemcode = productresp.itemCode!;
                                                                          for (var cartItem in cartProvider.getCartItems()) {
                                                                            if (cartItem.itemCode == itemcode) {
                                                                              cartItem.updateQuantity(quantities[index]);
                                                                            }
                                                                          }
                                                                        }
                                                                      });
                                                                    },
                                                                    decoration: const InputDecoration(
                                                                      hintText: '1',
                                                                      hintStyle: CommonUtils.Mediumtext_o_14,
                                                                      border: InputBorder.none,
                                                                      focusedBorder: InputBorder.none,
                                                                      enabledBorder: InputBorder.none,
                                                                      contentPadding: EdgeInsets.only(bottom: 12.0),
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
                                                          icon: SvgPicture.asset(
                                                            'assets/plus-small.svg',
                                                            color: Colors.white,
                                                            width: 20.0,
                                                            height: 20.0,
                                                          ),
                                                          onPressed: () {
                                                            setState(() {
                                                              quantities[index]++;
                                                              if (globalCartLength > 0) {
                                                                String itemcode = productresp.itemCode!;
                                                                for (var cartItem in cartProvider.getCartItems()) {
                                                                  if (cartItem.itemCode == itemcode) {
                                                                    cartItem.updateQuantity(quantities[index]);
                                                                  }
                                                                }
                                                              }
                                                            });
                                                            textEditingControllers[index].text = quantities[index].toString();
                                                          },
                                                          alignment: Alignment.centerLeft,
                                                          iconSize: 30.0,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 8.0,
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        if (CompneyId == 1) {
                                                          if (!isItemAddedToCart[index]) {
                                                            setState(() {
                                                              isSelectedList[index] = !isSelectedList[index];
                                                            });

                                                            if (isSelectedList[index] && quantities[index] > 0) {
                                                              print('Adding ${quantities[index]} of ${filteredproducts[index].itemName} to the cart');

                                                              String itemGrpCod;

                                                              if (CompneyId == 1 || globalCartLength > 0) {
                                                                itemGrpCod = productresp.itmsGrpCod!;
                                                              } else {
                                                                itemGrpCod = productresp.itmsGrpCod!;
                                                              }

                                                              if (cartProvider.isSameItemGroup(itemGrpCod)) {
                                                                orderItem = OrderItemXrefType(
                                                                  id: 1,
                                                                  orderId: 1001,
                                                                  itemGrpCod: itemGrpCod,
                                                                  itemGrpName: productresp.itmsGrpNam,
                                                                  itemCode: productresp.itemCode,
                                                                  itemName: productresp.itemName,
                                                                  noOfPcs: '10',
                                                                  orderQty: quantities[index],
                                                                  price: productresp.price,
                                                                  ugpName: productresp.ugpName,
                                                                  numInSale: productresp.numInSale,
                                                                  salUnitMsr: productresp.salUnitMsr,
                                                                  gst: productresp.gst,
                                                                  totalPrice: 1.1,
                                                                  totalPriceWithGST: 1.1,
                                                                );

                                                                await cartProvider.addToCart(orderItem!);
                                                                await prefs.setBool('isItemAddedToCart_$index', true);
                                                                List<OrderItemXrefType> cartItems = cartProvider.getCartItems();
                                                                print('Added items length: ${cartItems.length}');
                                                                globalCartLength = cartItems.length;

                                                                print('Item added successfully');
                                                                setState(() {
                                                                  isItemAddedToCart[index] = true;
                                                                });
                                                              } else {
                                                                // Display an error message, as itemGrpCod is not the same
                                                                print('Error: Cannot add items with different itemGrpCod to the cart');
                                                                CommonUtils.showCustomToastMessageLong('You can add items from one category in one order. For each category, you need to place a different order.', context, 1, 4);
                                                                setState(() {
                                                                  isSelectedList[index] = false;
                                                                });
                                                              }
                                                            } else {
                                                              CommonUtils.showCustomToastMessageLong('Quantity should be greater than 0 to add item to cart', context, 1, 2);
                                                            }
                                                          }
                                                        } else if (CompneyId == 2) {
                                                          if (!isItemAddedToCart[index]) {
                                                            setState(() {
                                                              isSelectedList[index] = !isSelectedList[index];
                                                            });

                                                            if (isSelectedList[index] && quantities[index] > 0) {
                                                              print('Adding ${quantities[index]} of ${filteredproducts[index].itemName} to the cart');

                                                              String itemGrpCod;

                                                              if (CompneyId == 2 || globalCartLength > 0) {
                                                                itemGrpCod = productresp.itmsGrpCod!;
                                                              } else {
                                                                itemGrpCod = productresp.itmsGrpCod!;
                                                              }

                                                              // if (cartProvider
                                                              //     .isSameItemGroup(
                                                              //     itemGrpCod)) {
                                                              orderItem = OrderItemXrefType(
                                                                id: 1,
                                                                orderId: 1001,
                                                                itemGrpCod: itemGrpCod,
                                                                itemGrpName: productresp.itmsGrpNam,
                                                                itemCode: productresp.itemCode,
                                                                itemName: productresp.itemName,
                                                                noOfPcs: '10',
                                                                orderQty: quantities[index],
                                                                price: productresp.price,
                                                                ugpName: productresp.ugpName,
                                                                numInSale: productresp.numInSale,
                                                                salUnitMsr: productresp.salUnitMsr,
                                                                gst: productresp.gst,
                                                                totalPrice: 1.1,
                                                                totalPriceWithGST: 1.1,
                                                              );
                                                              await cartProvider.addToCart(orderItem!);
                                                              await prefs.setBool('isItemAddedToCart_$index', true);
                                                              List<OrderItemXrefType> cartItems = cartProvider.getCartItems();
                                                              print('Added items length: ${cartItems.length}');
                                                              globalCartLength = cartItems.length;
                                                              print('Item added successfully');
                                                              setState(() {
                                                                isItemAddedToCart[index] = true;
                                                              });
                                                            } else {
                                                              CommonUtils.showCustomToastMessageLong('Quantity should be greater than 0 to add item to cart', context, 1, 2);
                                                            }
                                                          }
                                                        }
                                                      },
                                                      child: Container(
                                                        height: 36,
                                                        decoration: BoxDecoration(
                                                          color: isItemAddedToCart[index] ? const Color(0xFFe78337) : const Color(0xFFffefdf),
                                                          border: Border.all(
                                                            color: const Color(0xFFe78337),
                                                            width: 1.0,
                                                          ),
                                                          borderRadius: BorderRadius.circular(8.0),
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons.add_shopping_cart,
                                                                size: 18.0,
                                                                color: isItemAddedToCart[index] ? const Color(0xFFffefdf) : const Color(0xFFe78337),
                                                              ),
                                                              const SizedBox(width: 8.0),
                                                              // Display "Added" if the item is already added to the cart
                                                              Text(
                                                                isItemAddedToCart[index] ? 'Added' : 'Add',
                                                                style: TextStyle(
                                                                  color: isItemAddedToCart[index] ? const Color(0xFFffefdf) : const Color(0xFFe78337),
                                                                  fontSize: 14,
                                                                  fontFamily: "Roboto",
                                                                  fontWeight: FontWeight.w600,
                                                                ),
                                                              ),
                                                              const SizedBox(width: 6.0),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8.0),
                                                  if (isItemAddedToCart[index]) // Render delete button only when item is added to cart
                                                    GestureDetector(
                                                      onTap: () {
                                                        FocusManager.instance.primaryFocus?.unfocus();
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
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                // )
                                );
                            // rest of your code...
                          },
                        );

      },
      );
    }
    }

    )
                  ),
              )
            ],
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
                      if (globalCartLength > 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Ordersubmit_screen(
                              cardName: widget.cardName,
                              cardCode: widget.cardCode,
                              address: widget.address,
                              state: widget.state,
                              phone: widget.phone,
                              proprietorName: widget.proprietorName,
                              gstRegnNo: widget.gstRegnNo,

                              creditLine: double.parse('${widget.creditLine}'),
                              // Convert to double
                              balance: double.parse('${widget.balance}'),
                              whsCode: widget.whsCode,
                              whsName: widget.whsName,
                              whsState: widget.whsState,
                            ),
                          ),
                        );

                        print('Download button clicked');
                      } else {
                        CommonUtils.showCustomToastMessageLong('Please Select Atleast One Product', context, 1, 4);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: const Color(0xFFe78337),
                      ),
                      child: const Center(
                        child: Text(
                          'Save & Proceed',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700, // Set the font weight to bold
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
        ));
  }
  Widget buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 20.0,
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 8.0),
          ),
          Container(
            width: 200.0, // Adjust the width as needed
            height: 16.0,
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 8.0),
          ),
          Row(
            children: [
              Container(
                width: 100.0, // Adjust the width as needed
                height: 16.0,
                color: Colors.white,
                margin: const EdgeInsets.only(right: 8.0),
              ),
              Container(
                width: 50.0, // Adjust the width as needed
                height: 16.0,
                color: Colors.white,
              ),
              Spacer(),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 85,
                  height: 85,
                  color: Colors.grey[300], // Placeholder color during shimmer
                ),
              )
            ],
          ),
          SizedBox(
            height: 5.0,
          ),
          Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
            Padding(
                padding: const EdgeInsets.only(right: 0, left: 0, bottom: 0),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 36,
                      width: MediaQuery.of(context).size.width / 2.3,
                      decoration: BoxDecoration(
                        color: const Color(0xFFe78337),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.minimize, color: Colors.white),
                            onPressed: () {}, // Placeholder onPressed function
                            iconSize: 30.0,
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                height: 35,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: MediaQuery.of(context).size.width / 5,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: SizedBox(
                                      height: 35,
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: 'Loading',
                                          // Placeholder text during shimmer
                                          hintStyle: TextStyle(color: Colors.grey[300]),
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.only(bottom: 12.0),
                                        ),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add, color: Colors.white),
                            onPressed: () {}, // Placeholder onPressed function
                            iconSize: 30.0,
                          ),
                        ],
                      ),
                    ),
                  )
                ]))
          ]),
          SizedBox(
            width: 5.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: GestureDetector(
              onTap: () async {},
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFffefdf),
                      border: Border.all(
                        color: const Color(0xFFe78337),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Row(
                        children: [
                          Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Icon(
                              Icons.add_shopping_cart,
                              size: 18.0,
                              color: const Color(0xFFe78337),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          // Display "Added" if the item is already added to the cart
                          Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Text(
                              'Add',
                              style: TextStyle(
                                color: const Color(0xFFe78337),
                                fontSize: 14,
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget buildweight(int index, String mode, Function onTap, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        onTap(); // Call the onTap function passed as a parameter
      },
      child: SizedBox(
        width: 60,
        height: 36,
        child: Card(
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.0),
            side: BorderSide(
              color: isSelected ? const Color(0xFFe78337) : const Color(0xFFe78337),
            ),
          ),
          color: isSelected ? const Color(0xFFe78337) : const Color(0xFFF8dac2),
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
        return product.itemName!.toLowerCase().contains(searchTerm) || product.itemCode!.toLowerCase().contains(searchTerm);
      }).toList();
      print('filteredproducts : $filteredproducts');
      print('filteredproducts : ${filteredproducts.length}');
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
    searchController.clear();
    totalproducts.clear();
    setState(() {
      isLoading = true; // Set loading state to true before API call
    });

    String apiUrl = baseUrl + GetProductbyItemcode;
    print('productApi: ${apiUrl}');
    final requestBody = {
      "CompanyId": '$CompneyId',
      "PartyCode": widget.cardCode,
      "ItmsGrpCod": getgropcode
    };

    print(jsonEncode(requestBody));

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('productListResponse: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic>? responseData = jsonDecode(response.body);

        if (responseData == null) {
          throw Exception('Response data is null');
        }

        final List<dynamic>? responseDataList = responseData['response']['listResult'];

        if (responseDataList == null) {
          print('List result is null');
        } else {
          // Print the length directly on the list
          print('productLength ${responseDataList.length}');
          setState(() {
            totalproducts = responseDataList.map((response) => ProductResponse.fromJson(response)).toList();
            filteredproducts = List.from(totalproducts);
            isItemAddedToCart = List.generate(filteredproducts.length, (index) => false);
            quantities = List.generate(filteredproducts.length, (index) => 1);
            isSelectedList = List.generate(filteredproducts.length, (index) => false);
            textEditingControllers = List.generate(filteredproducts.length, (index) => TextEditingController());
            isLoading = false; // Set loading state to false after data is fetched
            print('productResponse ${filteredproducts.length}');
          });
        }
      } else {
        throw Exception('Failed to fetch Products');
      }
    } catch (error) {
      print('Error: $error');
      // Handle errors
      setState(() {
        isLoading = false; // Set loading state to false if error occurs
      });
      throw Exception('Failed to connect to the API');
    }
  }

  void initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  void clearCartData(CartProvider cartProvider) {
    cartProvider.clearCart();
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
  String? salUnitMsr;
  String? fileName;
  String? fileLocation;
  String? fileExtension;
  String? itemImage;

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
    required this.salUnitMsr,
    required this.fileName,
    required this.fileLocation,
    required this.fileExtension,
    required this.itemImage,
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
      salUnitMsr: json['salUnitMsr'] ?? '',
      fileName: json['fileName'] ?? '',
      fileLocation: json['fileLocation'] ?? '',
      fileExtension: json['fileExtension'] ?? '',
      itemImage: json['itemImage'] ?? '',
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
      listResult: (json['listResult'] as List).map((itemJson) => ProductResponse.fromJson(itemJson)).toList(),
      count: json['count'],
      affectedRecords: json['affectedRecords'],
      isSuccess: json['isSuccess'],
    );
  }
}
