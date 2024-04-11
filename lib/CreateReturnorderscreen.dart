import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:srikarbiotech/Common/styles.dart';
import 'package:srikarbiotech/Services/api_config.dart';

import '../CartProvider.dart';
import '../Common/CommonUtils.dart';
import '../Model/GetItemGroups.dart';
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
  final String whsCode;
  final String whsName;
  final String whsState;

  const CreateReturnorderscreen(
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
  State<CreateReturnorderscreen> createState() => _ProductListState();
}

class _ProductListState extends State<CreateReturnorderscreen> {
  bool isLoading = false;
  List<bool> isItemAddedToCart = [];

  List<int> quantities = [];
  List<TextEditingController> textEditingControllers = [];
  int selectedIndex = -1;
  late List<bool> isSelectedList;
  List<ItemGroup> filtereditemgroup = [];
  TextEditingController searchController = TextEditingController();
  bool isButtonClicked = false;
  int globalCartLength = 0;

  String groupName = "";
  String itemCode = "";
  int? selectindex;
  List<ProductResponse> totalproducts = [];
  List<ProductResponse> filteredproducts = [];
  String getgropcode = "";
  ApiResponse? apiResponse;
  String parts = "";

  List<String>? cartItemsJson = [];
  List<ReturnOrderItemXrefType> savedDataList = [];
  int cartitemslength = 0;
  int companyId = 0;
  String? userId = "";
  String? slpCode = "";
  ReturnOrderItemXrefType? returnorderItem;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    print('Total items in the cart: ${cartItemsJson!.length}');

    selectindex = 0;
    getshareddata();
    fetchproductlist("");
    initSharedPreferences();
  }

  Future<ApiResponse> fetchProducts() async {
    final apiurl = "$baseUrl$GetItemGroups$companyId/null";
    try {
      final response = await http.get(Uri.parse(apiurl));
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
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    savedDataList = Provider.of<CartProvider>(context).getReturnCartItems();

    globalCartLength = savedDataList.length;
    return WillPopScope(
        onWillPop: () async {
          final cartProvider = context.read<CartProvider>();

          clearCartData(cartProvider);

          return true;
        },
        child: Scaffold(
          appBar: _appBar(),
          body: RefreshIndicator(
            onRefresh: () async {
              CommonUtils.checkInternetConnectivity().then(
                (isConnected) {
                  if (isConnected) {
                    getshareddata();
                    fetchproductlist("");
                    initSharedPreferences();
                    print('The Internet Is Connected');
                  } else {
                    CommonUtils.showCustomToastMessageLong(
                        'Please check your internet  connection',
                        context,
                        1,
                        4);
                    print('The Internet Is not  Connected');
                  }
                },
              );

              try {
                ApiResponse response = await fetchProducts();
                setState(() {});
              } catch (error) {
                print('catch: $error');
              }
            },
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding:
                      const EdgeInsets.only(top: 5.0, left: 8.0, right: 10.0),
                  child: IntrinsicHeight(
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: CommonStyles.whiteColor,
                        ),
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.cardName,
                              style: CommonUtils.header_Styles16,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5.0),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Credit Limit',
                                    style: CommonStyles.txSty_12b_fb,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '₹${widget.creditLine}',
                                    style: CommonStyles.txSty_12o_f7,
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
                                    style: CommonStyles.txSty_12b_fb,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '₹${widget.balance}',
                                    style: CommonStyles.txSty_12o_f7,
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
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8.0),
                      GestureDetector(
                        onTap: () {
                          print('first textview clicked');
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: searchController,
                                onChanged: (value) {
                                  filterproducts();
                                },
                                keyboardType: TextInputType.name,
                                style: CommonStyles.txSty_14b_fb,
                                decoration: InputDecoration(
                                  hintText: 'Product Search',
                                  hintStyle: CommonStyles.txSty_14bs_fb,
                                  border: CommonUtils.borderForSearch,
                                  focusedBorder: CommonUtils.focusedBorder,
                                  suffixIcon: const Icon(Icons.search),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0.0),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    side: const BorderSide(
                                      color: CommonStyles.orangeColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  color: isSelected
                                      ? CommonStyles.orangeColor
                                      : const Color(0xFFffefdf),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectindex = i;
                                      });

                                      if (isAll) {
                                        getgropcode = "";
                                        print('getitemgroupcode: All');
                                        fetchproductlist("");
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
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                        horizontal: 12.0,
                                      ),
                                      child: Text(
                                        isAll
                                            ? 'All'
                                            : '${apiResponse?.listResult[i - 1].itmsGrpNam}',
                                        style: TextStyle(
                                          color: isSelected
                                              ? CommonStyles.whiteColor
                                              : CommonStyles.blackColor,
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
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, top: 0.0),
                      child: Consumer<CartProvider>(
                          builder: (context, cartProvider, _) {
                        print('responselist ${filteredproducts.length}');
                        if (isLoading) {
                          return CommonUtils.shimmerEffect(context);
                        } else if (filteredproducts.isEmpty) {
                          return const Center(
                            child: Text(
                              'No products available',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Color(0xFF424242),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        } else {
                          return Consumer<CartProvider>(
                            builder: (context, cartProvider, _) {
                              List<ReturnOrderItemXrefType> cartItems =
                                  cartProvider.getReturnCartItems();

                              globalCartLength = cartItems.length;
                              print('Added cart: $globalCartLength');
                              return ListView.builder(
                                itemCount:
                                    isLoading ? 5 : filteredproducts.length,
                                itemBuilder: (context, index) {
                                  if (index < 0 ||
                                      index >= filteredproducts.length) {
                                    return Container(
                                      child: const Text(
                                          'Error: Index out of bounds'),
                                    );
                                  }
                                  final productresp = filteredproducts[index];
                                  if (globalCartLength > 0) {
                                    String itemcode = productresp.itemCode!;
                                    for (var cartItem
                                        in cartProvider.getReturnCartItems()) {
                                      if (cartItem.itemCode == itemcode) {
                                        isItemAddedToCart[index] = true;
                                        textEditingControllers[index].text =
                                            cartItem.orderQty.toString();
                                        int productIndex = filteredproducts
                                            .indexWhere((product) =>
                                                product.itemCode == itemcode);
                                        if (productIndex != -1) {
                                          quantities[productIndex] =
                                              cartItem.orderQty!;
                                        }
                                        print(
                                            'previousscreen:${textEditingControllers[index].text}');
                                        break;
                                      }
                                    }
                                  }

                                  return GestureDetector(
                                    onTap: () {
                                      print(
                                          'Tapped on ID: ${productresp.itemCode}');
                                    },
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      elevation: 5.0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          color: CommonStyles.whiteColor,
                                        ),
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  flex: 6,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      RichText(
                                                        overflow:
                                                            TextOverflow.clip,
                                                        text: TextSpan(
                                                          text: productresp
                                                              .itemName
                                                              .toString(),
                                                          style: CommonStyles
                                                              .txSty_14b_fb,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 5.0,
                                                      ),
                                                      Text(
                                                        productresp.itmsGrpNam
                                                            .toString(),
                                                        style: CommonStyles
                                                            .txSty_12b_fb,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 10.0,
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 0,
                                                          left: 0,
                                                          bottom: 0),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        height: 36,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            2.3,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: CommonStyles
                                                              .orangeColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            IconButton(
                                                              icon: SvgPicture
                                                                  .asset(
                                                                'assets/minus-small.svg',
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              onPressed: () {
                                                                if (quantities[
                                                                        index] >
                                                                    1) {
                                                                  setState(() {
                                                                    quantities[
                                                                        index]--;
                                                                    if (globalCartLength >
                                                                        0) {
                                                                      String
                                                                          itemcode =
                                                                          productresp
                                                                              .itemCode!;
                                                                      for (var cartItem
                                                                          in cartProvider
                                                                              .getReturnCartItems()) {
                                                                        if (cartItem.itemCode ==
                                                                            itemcode) {
                                                                          cartItem
                                                                              .updateQuantity(quantities[index]);
                                                                        }
                                                                      }
                                                                    }
                                                                  });
                                                                  textEditingControllers[
                                                                          index]
                                                                      .text = quantities[
                                                                          index]
                                                                      .toString();
                                                                }
                                                              },
                                                              iconSize: 30.0,
                                                            ),
                                                            Expanded(
                                                              child: Align(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: SizedBox(
                                                                  height: 35,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            2.0),
                                                                    child:
                                                                        Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          5,
                                                                      decoration:
                                                                          const BoxDecoration(
                                                                        color: CommonStyles
                                                                            .whiteColor,
                                                                      ),
                                                                      child:
                                                                          TextField(
                                                                        controller:
                                                                            textEditingControllers[index],
                                                                        keyboardType:
                                                                            TextInputType.number,
                                                                        inputFormatters: <TextInputFormatter>[
                                                                          FilteringTextInputFormatter
                                                                              .digitsOnly,
                                                                          LengthLimitingTextInputFormatter(
                                                                              5),
                                                                        ],
                                                                        onChanged:
                                                                            (value) {
                                                                          setState(
                                                                              () {
                                                                            quantities[index] = int.parse(value.isEmpty
                                                                                ? '1'
                                                                                : value);
                                                                            if (globalCartLength >
                                                                                0) {
                                                                              String itemcode = productresp.itemCode!;
                                                                              for (var cartItem in cartProvider.getReturnCartItems()) {
                                                                                if (cartItem.itemCode == itemcode) {
                                                                                  cartItem.updateQuantity(quantities[index]);
                                                                                }
                                                                              }
                                                                            }
                                                                          });
                                                                        },
                                                                        decoration:
                                                                            const InputDecoration(
                                                                          hintText:
                                                                              '1',
                                                                          hintStyle:
                                                                              CommonUtils.Mediumtext_o_14,
                                                                          border:
                                                                              InputBorder.none,
                                                                          focusedBorder:
                                                                              InputBorder.none,
                                                                          enabledBorder:
                                                                              InputBorder.none,
                                                                          contentPadding:
                                                                              EdgeInsets.only(bottom: 12.0),
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: CommonUtils
                                                                            .Mediumtext_o_14,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            IconButton(
                                                              icon: SvgPicture
                                                                  .asset(
                                                                'assets/plus-small.svg',
                                                                color: Colors
                                                                    .white,
                                                                width: 20.0,
                                                                height: 20.0,
                                                              ),
                                                              onPressed: () {
                                                                setState(() {
                                                                  quantities[
                                                                      index]++;
                                                                  if (globalCartLength >
                                                                      0) {
                                                                    String
                                                                        itemcode =
                                                                        productresp
                                                                            .itemCode!;
                                                                    for (var cartItem
                                                                        in cartProvider
                                                                            .getReturnCartItems()) {
                                                                      if (cartItem
                                                                              .itemCode ==
                                                                          itemcode) {
                                                                        cartItem
                                                                            .updateQuantity(quantities[index]);
                                                                      }
                                                                    }
                                                                  }
                                                                });
                                                                textEditingControllers[
                                                                        index]
                                                                    .text = quantities[
                                                                        index]
                                                                    .toString();
                                                              },
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              iconSize: 30.0,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 8.0,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    4.0),
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            if (companyId ==
                                                                1) {
                                                              if (!isItemAddedToCart[
                                                                  index]) {
                                                                setState(() {
                                                                  isSelectedList[
                                                                          index] =
                                                                      !isSelectedList[
                                                                          index];
                                                                });

                                                                if (isSelectedList[
                                                                        index] &&
                                                                    quantities[
                                                                            index] >
                                                                        0) {
                                                                  print(
                                                                      'Adding ${quantities[index]} of ${filteredproducts[index].itemName} to the cart');

                                                                  String
                                                                      itemGrpCod;

                                                                  if (companyId ==
                                                                          1 ||
                                                                      globalCartLength >
                                                                          0) {
                                                                    itemGrpCod =
                                                                        productresp
                                                                            .itmsGrpCod!;
                                                                  } else {
                                                                    itemGrpCod =
                                                                        productresp
                                                                            .itmsGrpCod!;
                                                                  }

                                                                  if (cartProvider
                                                                      .isSameItemGroup(
                                                                          itemGrpCod)) {
                                                                    returnorderItem = ReturnOrderItemXrefType(
                                                                        id: 1,
                                                                        returnOrderId:
                                                                            1001,
                                                                        itemGrpCod:
                                                                            itemGrpCod,
                                                                        itemGrpName:
                                                                            productresp
                                                                                .itmsGrpNam,
                                                                        itemCode:
                                                                            productresp
                                                                                .itemCode,
                                                                        itemName:
                                                                            productresp
                                                                                .itemName,
                                                                        statusTypeId:
                                                                            13,
                                                                        orderQty:
                                                                            quantities[
                                                                                index],
                                                                        price:
                                                                            productresp
                                                                                .price,
                                                                        remarks:
                                                                            "",
                                                                        totalPrice:
                                                                            null);

                                                                    await cartProvider
                                                                        .addToreturnorderCart(
                                                                            returnorderItem!);

                                                                    await prefs
                                                                        .setBool(
                                                                            'isItemAddedToCart_$index',
                                                                            true);
                                                                    List<ReturnOrderItemXrefType>
                                                                        cartItems =
                                                                        cartProvider
                                                                            .getReturnCartItems();
                                                                    print(
                                                                        'Added items length: ${cartItems.length}');
                                                                    globalCartLength =
                                                                        cartItems
                                                                            .length;

                                                                    print(
                                                                        'Item added successfully');
                                                                    setState(
                                                                        () {
                                                                      isItemAddedToCart[
                                                                              index] =
                                                                          true;
                                                                    });
                                                                  } else {
                                                                    print(
                                                                        'Error: Cannot add items with different itemGrpCod to the cart');
                                                                    CommonUtils.showCustomToastMessageLong(
                                                                        'You can add items from one category in one order. For each category, you need to place a different order.',
                                                                        context,
                                                                        1,
                                                                        4);
                                                                    setState(
                                                                        () {
                                                                      isSelectedList[
                                                                              index] =
                                                                          false;
                                                                    });
                                                                  }
                                                                } else {
                                                                  CommonUtils
                                                                      .showCustomToastMessageLong(
                                                                          'Quantity should be greater than 0 to add item to cart',
                                                                          context,
                                                                          1,
                                                                          2);
                                                                }
                                                              }
                                                            } else if (companyId ==
                                                                2) {
                                                              if (!isItemAddedToCart[
                                                                  index]) {
                                                                setState(() {
                                                                  isSelectedList[
                                                                          index] =
                                                                      !isSelectedList[
                                                                          index];
                                                                });

                                                                if (isSelectedList[
                                                                        index] &&
                                                                    quantities[
                                                                            index] >
                                                                        0) {
                                                                  print(
                                                                      'Adding ${quantities[index]} of ${filteredproducts[index].itemName} to the cart');

                                                                  String
                                                                      itemGrpCod;

                                                                  if (companyId ==
                                                                          2 ||
                                                                      globalCartLength >
                                                                          0) {
                                                                    itemGrpCod =
                                                                        productresp
                                                                            .itmsGrpCod!;
                                                                  } else {
                                                                    itemGrpCod =
                                                                        productresp
                                                                            .itmsGrpCod!;
                                                                  }

                                                                  returnorderItem = ReturnOrderItemXrefType(
                                                                      id: 1,
                                                                      returnOrderId:
                                                                          1001,
                                                                      itemGrpCod:
                                                                          itemGrpCod,
                                                                      itemGrpName:
                                                                          productresp
                                                                              .itmsGrpNam,
                                                                      itemCode: productresp
                                                                          .itemCode,
                                                                      itemName:
                                                                          productresp
                                                                              .itemName,
                                                                      statusTypeId:
                                                                          13,
                                                                      orderQty:
                                                                          quantities[
                                                                              index],
                                                                      price: productresp
                                                                          .price,
                                                                      remarks:
                                                                          "",
                                                                      totalPrice:
                                                                          null);

                                                                  await cartProvider
                                                                      .addToreturnorderCart(
                                                                          returnorderItem!);

                                                                  await prefs
                                                                      .setBool(
                                                                          'isItemAddedToCart_$index',
                                                                          true);
                                                                  List<ReturnOrderItemXrefType>
                                                                      cartItems =
                                                                      cartProvider
                                                                          .getReturnCartItems();
                                                                  print(
                                                                      'Added items length: ${cartItems.length}');
                                                                  globalCartLength =
                                                                      cartItems
                                                                          .length;
                                                                  print(
                                                                      'Item added successfully');
                                                                  setState(() {
                                                                    isItemAddedToCart[
                                                                            index] =
                                                                        true;
                                                                  });
                                                                } else {
                                                                  CommonUtils
                                                                      .showCustomToastMessageLong(
                                                                          'Quantity should be greater than 0 to add item to cart',
                                                                          context,
                                                                          1,
                                                                          2);
                                                                }
                                                              }
                                                            }
                                                          },
                                                          child: Container(
                                                            height: 36,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: isItemAddedToCart[
                                                                      index]
                                                                  ? CommonStyles
                                                                      .orangeColor
                                                                  : CommonStyles
                                                                      .whiteColor,
                                                              border:
                                                                  Border.all(
                                                                color: CommonStyles
                                                                    .orangeColor,
                                                                width: 1.0,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          6.0),
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .add_shopping_cart,
                                                                    size: 18.0,
                                                                    color: isItemAddedToCart[
                                                                            index]
                                                                        ? CommonStyles
                                                                            .whiteColor
                                                                        : CommonStyles
                                                                            .orangeColor,
                                                                  ),
                                                                  const SizedBox(
                                                                      width:
                                                                          8.0),
                                                                  Text(
                                                                    isItemAddedToCart[
                                                                            index]
                                                                        ? 'Added'
                                                                        : 'Add',
                                                                    style:
                                                                        TextStyle(
                                                                      color: isItemAddedToCart[
                                                                              index]
                                                                          ? CommonStyles
                                                                              .whiteColor
                                                                          : CommonStyles
                                                                              .orangeColor,
                                                                      fontSize:
                                                                          14,
                                                                      fontFamily:
                                                                          "Roboto",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width:
                                                                          6.0),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width: 8.0),
                                                      if (isItemAddedToCart[
                                                          index])
                                                        GestureDetector(
                                                          onTap: () {
                                                            FocusManager
                                                                .instance
                                                                .primaryFocus
                                                                ?.unfocus();

                                                            setState(() {
                                                              isItemAddedToCart[
                                                                      index] =
                                                                  false;
                                                              quantities[
                                                                  index] = 1;
                                                            });

                                                            int deleteIndex =
                                                                cartItems
                                                                    .indexWhere(
                                                              (item) =>
                                                                  item.itemCode ==
                                                                  productresp
                                                                      .itemCode,
                                                            );

                                                            if (deleteIndex !=
                                                                -1) {
                                                              cartItems.removeAt(
                                                                  deleteIndex);
                                                              textEditingControllers
                                                                  .removeAt(
                                                                      deleteIndex);
                                                            }

                                                            fetchproductlist(
                                                                getgropcode);
                                                          },
                                                          child: Container(
                                                            height: 36,
                                                            width: 40,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color(
                                                                  0xFFF8dac2),
                                                              border:
                                                                  Border.all(
                                                                color: CommonStyles
                                                                    .orangeColor,
                                                                width: 1.0,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                            child:
                                                                const Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          4.0),
                                                              child: Align(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .delete,
                                                                      size:
                                                                          18.0,
                                                                      color: Colors
                                                                          .red,
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
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }
                      })),
                )
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
                        onTap: () {
                          if (globalCartLength > 0) {
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
                                    creditLine:
                                        double.parse('${widget.creditLine}'),
                                    balance: double.parse('${widget.balance}'),
                                    lrnumber: '',
                                    lrdate: '',
                                    remarks: '',
                                    transportname: '',
                                    whsCode: widget.whsCode,
                                    whsName: widget.whsName,
                                    whsState: widget.whsState),
                              ),
                            );
                          } else {
                            CommonUtils.showCustomToastMessageLong(
                                'Please Select Atleast One Product',
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
                            color: CommonStyles.orangeColor,
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
        onTap();
      },
      child: SizedBox(
        width: 60,
        height: 36,
        child: Card(
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.0),
            side: BorderSide(
              color: isSelected
                  ? CommonStyles.orangeColor
                  : CommonStyles.orangeColor,
            ),
          ),
          color:
              isSelected ? CommonStyles.orangeColor : const Color(0xFFF8dac2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                mode,
                style: TextStyle(
                  color: isSelected ? CommonStyles.whiteColor : null,
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
      print('filteredproducts : $filteredproducts');
      print('filteredproducts : ${filteredproducts.length}');
    });
  }

  Future<void> getshareddata() async {
    userId = await SharedPrefsData.getStringFromSharedPrefs("userId");
    slpCode = await SharedPrefsData.getStringFromSharedPrefs("slpCode");
    companyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
    print('User ID: $userId');
    print('SLP Code: $slpCode');
    print('Company ID: $companyId');

    fetchProducts().then((response) {
      setState(() {
        isLoading = true;

        apiResponse = response;
        fetchproductlist("");
      });
    });
  }

  void fetchproductlist(String getgropcode) async {
    searchController.clear();
    totalproducts.clear();
    setState(() {
      isLoading = true;
    });

    String apiUrl = baseUrl + GetProductbyItemcode;
    print('productApi: $apiUrl');
    final requestBody = {
      "CompanyId": '$companyId',
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

        final List<dynamic>? responseDataList =
            responseData['response']['listResult'];

        if (responseDataList == null) {
          print('List result is null');
        } else {
          print('productLength ${responseDataList.length}');
          setState(() {
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
            isLoading = false;
            print('productResponse ${filteredproducts.length}');
          });
        }
      } else {
        throw Exception('Failed to fetch Products');
      }
    } catch (error) {
      print('Error: $error');

      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to connect to the API');
    }
  }

  void initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  void clearCartData(CartProvider cartProvider) {
    cartProvider.clearreturnCart();
  }

//   Widget buildShimmerEffect() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: double.infinity,
//             height: 20.0,
//             color: CommonStyles.whiteColor,
//             margin: const EdgeInsets.only(bottom: 8.0),
//           ),
//           Container(
//             width: 200.0,
//             height: 16.0,
//             color: CommonStyles.whiteColor,
//             margin: const EdgeInsets.only(bottom: 8.0),
//           ),
//           Row(
//             children: [
//               Container(
//                 width: 100.0,
//                 height: 16.0,
//                 color: CommonStyles.whiteColor,
//                 margin: const EdgeInsets.only(right: 8.0),
//               ),
//               Container(
//                 width: 50.0,
//                 height: 16.0,
//                 color: CommonStyles.whiteColor,
//               ),
//             ],
//           ),
//           const SizedBox(
//             height: 5.0,
//           ),
//           Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Padding(
//                     padding:
//                         const EdgeInsets.only(right: 0, left: 0, bottom: 0),
//                     child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           Shimmer.fromColors(
//                             baseColor: Colors.grey[300]!,
//                             highlightColor: Colors.grey[100]!,
//                             child: Container(
//                               height: 36,
//                               width: MediaQuery.of(context).size.width / 2.3,
//                               decoration: BoxDecoration(
//                                 color: CommonStyles.orangeColor,
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                               child: Row(
//                                 children: [
//                                   IconButton(
//                                     icon: const Icon(Icons.minimize,
//                                         color: CommonStyles.whiteColor),
//                                     onPressed: () {},
//                                     iconSize: 30.0,
//                                   ),
//                                   Expanded(
//                                     child: Align(
//                                       alignment: Alignment.center,
//                                       child: SizedBox(
//                                         height: 35,
//                                         child: Padding(
//                                           padding: const EdgeInsets.all(2.0),
//                                           child: Container(
//                                             alignment: Alignment.center,
//                                             width: MediaQuery.of(context)
//                                                     .size
//                                                     .width /
//                                                 5,
//                                             decoration: const BoxDecoration(
//                                               color: CommonStyles.whiteColor,
//                                             ),
//                                             child: const SizedBox(
//                                               height: 35,
//                                               child: TextField(
//                                                 keyboardType:
//                                                     TextInputType.number,
//                                                 decoration: InputDecoration(
//                                                   hintText: 'Loading',
//                                                   hintStyle: CommonStyles
//                                                       .txSty_14bs_fb,
//                                                   border: InputBorder.none,
//                                                   focusedBorder:
//                                                       InputBorder.none,
//                                                   enabledBorder:
//                                                       InputBorder.none,
//                                                   contentPadding:
//                                                       EdgeInsets.only(
//                                                           bottom: 12.0),
//                                                 ),
//                                                 textAlign: TextAlign.center,
//                                                 style: TextStyle(
//                                                     color: CommonStyles
//                                                         .whiteColor),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   IconButton(
//                                     icon: const Icon(Icons.add,
//                                         color: CommonStyles.whiteColor),
//                                     onPressed: () {},
//                                     iconSize: 30.0,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           )
//                         ]))
//               ]),
//           const SizedBox(
//             width: 5.0,
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 4.0),
//             child: GestureDetector(
//               onTap: () async {},
//               child: Shimmer.fromColors(
//                 baseColor: Colors.grey[300]!,
//                 highlightColor: Colors.grey[100]!,
//                 child: Shimmer.fromColors(
//                   baseColor: Colors.grey[300]!,
//                   highlightColor: Colors.grey[100]!,
//                   child: Container(
//                     height: 36,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFffefdf),
//                       border: Border.all(
//                         color: CommonStyles.orangeColor,
//                         width: 1.0,
//                       ),
//                       borderRadius: BorderRadius.circular(8.0),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 6.0),
//                       child: Row(
//                         children: [
//                           Shimmer.fromColors(
//                             baseColor: Colors.grey[300]!,
//                             highlightColor: Colors.grey[100]!,
//                             child: const Icon(
//                               Icons.add_shopping_cart,
//                               size: 18.0,
//                               color: CommonStyles.orangeColor,
//                             ),
//                           ),
//                           const SizedBox(width: 8.0),
//                           Shimmer.fromColors(
//                             baseColor: Colors.grey[300]!,
//                             highlightColor: Colors.grey[100]!,
//                             child: const Text(
//                               'Add',
//                               style: CommonStyles.txSty_14o_f7,
//                             ),
//                           ),
//                           const SizedBox(width: 6.0),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: CommonStyles.orangeColor,
      leading: IconButton(
        icon: const Icon(Icons.chevron_left, color: CommonStyles.whiteColor),
        onPressed: () {
          final cartProvider = context.read<CartProvider>();

          clearCartData(cartProvider);
          Navigator.pop(context);
        },
      ),
      title: const Row(
        children: [
          SizedBox(width: 10),
          Text(
            'Select Products',
            style: CommonStyles.txSty_18w_fb,
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
              child: SizedBox(
                width: 30,
                height: 30,
                child: Image.asset(
                  companyId == 1
                      ? 'assets/srikar-home-icon.png'
                      : 'assets/seeds-home-icon.png',
                  width: 30,
                  height: 30,
                ),
              ),
            ),
            Stack(
              children: [
                IconButton(
                  onPressed: () {},
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
                      color: CommonStyles.whiteColor,
                    ),
                    child: Text(
                      '$globalCartLength',
                      style: const TextStyle(
                        color: CommonStyles.orangeColor,
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
    );
  }
}
