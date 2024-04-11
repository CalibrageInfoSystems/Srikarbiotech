import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikarbiotech/Common/CommonUtils.dart';
import 'package:http/http.dart' as http;
import 'package:srikarbiotech/Common/styles.dart';
import 'package:srikarbiotech/Returntransportdetails.dart';
import 'package:srikarbiotech/Services/api_config.dart';

import 'CartProvider.dart';
import 'Common/SharedPrefsData.dart';
import 'HomeScreen.dart';
import 'Model/ReturnOrderItemXrefType.dart';
import 'ReturnorderStatusScreen.dart';

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
  bool _isButtonDisabled = false;

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
    LrDate1 = formatDate(dateString, "dd MMM, yyyy");
    LrDate2 = formatDate(dateString, "yyyy-MM-dd");
    return Scaffold(
      appBar: _appBar(),
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
                    CommonStyles.whiteColor,
                    BorderRadius.circular(5.0),
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0),
              child: IntrinsicHeight(
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Container(
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
            FutureBuilder(
              future: Future.value(),
              builder: (context, snapshot) {
                cartItems =
                    Provider.of<CartProvider>(context).getReturnCartItems();
                return buildListView(cartItems, ValueKey(cartItems));
              },
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 0.0, left: 10.0, right: 10.0),
              child: IntrinsicHeight(
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: CommonStyles.whiteColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              const Text(
                                'Transport Details',
                                style: CommonStyles.txSty_14b_fb,
                              ),
                              InkWell(
                                onTap: () {
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
                                                proprietorName:
                                                    widget.proprietorName,
                                                gstRegnNo: widget.gstRegnNo,
                                                lrnumber: widget.LrNumber,
                                                lrdate: widget.Lrdate,
                                                remarks: widget.Remarks,
                                                creditLine: double.parse(
                                                    '${widget.creditLine}'),
                                                balance: double.parse(
                                                    '${widget.balance}'),
                                                transportname:
                                                    widget.transportname,
                                                whsCode: widget.whsCode,
                                                whsName: widget.whsName,
                                                whsState: widget.whsState)),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: SvgPicture.asset(
                                    'assets/edit.svg',
                                    width: 20,
                                    height: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        dividerForHorizontal,
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
                                    const Text(
                                      'LR Number',
                                      style: CommonStyles.txSty_12b_fb,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.LrNumber,
                                      style: CommonStyles.txSty_12o_f7,
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
                                    const Text(
                                      'LR Date',
                                      style: CommonStyles.txSty_12b_fb,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      LrDate1,
                                      style: CommonStyles.txSty_12o_f7,
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Transport Name',
                                      style: CommonStyles.txSty_12b_fb,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.transportname,
                                      style: CommonStyles.txSty_12o_f7,
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Remarks',
                                      style: CommonStyles.txSty_12b_fb,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.Remarks,
                                      style: CommonStyles.txSty_12o_f7,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        dividerForHorizontal,
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                border: Border.all(
                                  color: CommonStyles.orangeColor,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  showAttachmentsDialog(attachments);
                                },
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.link),
                                    SizedBox(width: 5),
                                    Text(
                                      'Attachment',
                                      style: CommonStyles.txSty_12b_fb,
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
                              CommonUtils.checkInternetConnectivity().then(
                                (isConnected) {
                                  if (isConnected) {
                                    addReturnOrders();
                                    print('The Internet Is Connected');
                                  } else {
                                    CommonUtils.showCustomToastMessageLong(
                                        'Please check your internet connection',
                                        context,
                                        1,
                                        4);
                                    print('The Internet Is not Connected');
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
                          'Place Your Return Order',
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
      ),
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
    return ListView.builder(
      key: key,
      shrinkWrap: true,
      physics: const PageScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        ReturnOrderItemXrefType cartItem = cartItems[index];
        if (cartItems.length != textEditingControllers.length) {
          textEditingControllers = List.generate(
              cartItems.length, (index) => TextEditingController());
        }
        double orderQty = cartItem.orderQty?.toDouble() ?? 0.0;
        double price = cartItem.price ?? 0.0;
        return CartItemWidget(
          key: ValueKey(cartItem),
          cartItem: cartItem,
          onDelete: () {
            setState(() {
              cartItems.removeAt(index);

              textEditingControllers.removeAt(index);
            });
          },
          cartItems: cartItems,
          onQuantityChanged: () {},
        );
      },
    );
  }

  double calculateTotalSum(List<ReturnOrderItemXrefType> cartItems) {
    double sum = 0.0;
    for (ReturnOrderItemXrefType cartItem in cartItems) {
      double orderQty = cartItem.orderQty?.toDouble() ?? 0.0;
      double price = cartItem.price ?? 0.0;

      sum += orderQty * price;
    }
    return sum;
  }

  void clearCartData(CartProvider cartProvider) {
    cartProvider.clearreturnCart();
  }

  void addReturnOrders() async {
    DateTime currentDate = DateTime.now();
    String formattedcurrentDate = DateFormat('yyyy-MM-dd').format(currentDate);
    String apiUrl = baseUrl + AddReturnorder;
    bool isValid = true;
    bool hasValidationFailed = false;
    List<Map<String, dynamic>> returnorderItemList = cartItems.map((cartItem) {
      double orderQty = cartItem.orderQty?.toDouble() ?? 0.0;
      double price = cartItem.price ?? 0.0;
      if (isValid && orderQty == 0.0) {
        CommonUtils.showCustomToastMessageLong(
            'Please add quantity to selected product(s)', context, 1, 4);
        isValid = false;
        hasValidationFailed = true;
      }
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

    if (hasValidationFailed) {
      return;
    } else {
      setState(() {
        _isButtonDisabled = true;
      });
    }
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
        String returnOrderNumber =
            responseData['response']['returnOrderNumber'];
        final cartProvider = context.read<CartProvider>();
        clearCartData(cartProvider);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ReturnorderStatusScreen(responseData: responseData),
          ),
        );
      } else {
        print('Error: ${response.reasonPhrase}');
        setState(() {
          _isButtonDisabled = false;
        });
      }
    } catch (e) {
      print('catch: $e');
    }
  }

  void printRemainingCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? cartItems = prefs.getStringList('cartItems');
    int remainingCartItems = cartItems?.length ?? 0;
  }

  void clearCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
  }

  String formatDate(String inputDate, String outputFormat) {
    DateTime parsedDate = DateFormat("dd-MM-yyyy").parse(inputDate);
    String formattedDate = DateFormat(outputFormat).format(parsedDate);
    return formattedDate;
  }

  void showAttachmentsDialog(List data) {
    int? currentPage = 0;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: CommonStyles.whiteColor,
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
                        color: CommonStyles.whiteColor,
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
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: currentPage == index
                                    ? CommonStyles.orangeColor
                                    : CommonStyles.whiteColor,
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
                        onTap: () {
                          Navigator.of(context).pop();
                          currentPage = 0;
                        },
                        child: Container(
                          padding: const EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.red.withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 15,
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
                'Return Order Submission ',
                style: CommonStyles.txSty_18w_fb,
              ),
              FutureBuilder(
                future: getshareddata(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    cartItems =
                        Provider.of<CartProvider>(context).getReturnCartItems();

                    globalCartLength = cartItems.length;
                  }

                  return Text(
                    '($globalCartLength)',
                    style: const TextStyle(
                      color: CommonStyles.whiteColor,
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
  final ReturnOrderItemXrefType cartItem;
  final Function onDelete;

  final List<ReturnOrderItemXrefType> cartItems;

  final VoidCallback onQuantityChanged;

  const CartItemWidget(
      {Key? key,
      required this.cartItem,
      required this.onDelete,
      required this.cartItems,
      required this.onQuantityChanged})
      : super(key: key);

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

    _orderQty = widget.cartItem.orderQty ?? 1;
    Quantity = widget.cartItem.orderQty!;
    _textController = TextEditingController(text: _orderQty.toString());
  }

  @override
  Widget build(BuildContext context) {
    double totalWidth = MediaQuery.of(context).size.width;
    widget.onQuantityChanged();
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        color: CommonStyles.whiteColor,
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
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [],
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
                          widget.onQuantityChanged();
                        });
                      },
                      deleteQuantity: () {
                        setState(() {
                          if (_orderQty > 1) {
                            Quantity--;
                            formatNumber(totalSumForProduct);
                            formatNumber(totalSumForProduct);
                            _orderQty = (_orderQty ?? 0) - 1;
                            _textController.text = _orderQty.toString();
                            widget.cartItem.updateQuantity(_orderQty);
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
                        style: CommonUtils.Mediumtext_o_14,
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
    setAttachments(
        widget.LRAttachment, widget.ReturnOrderReceipt, widget.addlattchments);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: CommonStyles.whiteColor,
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
                    color: CommonStyles.whiteColor,
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
  }

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
