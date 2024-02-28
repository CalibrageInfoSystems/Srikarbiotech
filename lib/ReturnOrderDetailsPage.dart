import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:srikarbiotech/Common/CommonUtils.dart';
import 'package:srikarbiotech/Model/returnorderimagedata_model.dart';
import 'package:srikarbiotech/Model/viewreturnorders_model.dart';
import 'package:srikarbiotech/Model/viewreturnorders_model.dart';

import 'HomeScreen.dart';
import 'Model/ReturnOrderCredit.dart';
import 'Model/ReturnOrderCredit.dart';
import 'order_details.dart';

class ReturnOrderDetailsPage extends StatefulWidget {
  final int orderId;
  final Widget statusBar;
  const ReturnOrderDetailsPage(
      {super.key, required this.orderId, required this.statusBar});

  @override
  State<ReturnOrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<ReturnOrderDetailsPage> {
  final _orangeColor = HexColor('#e58338');

  late Future<Map<String, dynamic>> apiData;

  late List<ReturnOrderDetailsResult> returnOrderDetailsResultList = [];
  late List<ReturnOrderItemXrefList> returnOrderItemXrefList = [];
  late List<ReturnOrderCredit> returnOrderCredits = [];

  @override
  void initState() {
    super.initState();

    apiData = getApiData();
    apiData.then((value) => initializingApiData(value));

    ReturnOrderCreditmethod();
  }

  void initializingApiData(Map<String, dynamic> apiData) {
    try {
      if (apiData['response'] != null) {
        if (apiData['response']['returnOrderDetailsResult'] != null) {
          List<dynamic> returnOrderDetailsResultListData =
          apiData['response']['returnOrderDetailsResult'];
          returnOrderDetailsResultList = returnOrderDetailsResultListData
              .map((item) => ReturnOrderDetailsResult.fromJson(item))
              .toList();
        }

        if (apiData['response']['returnOrderItemXrefList'] != null) {
          List<dynamic> returnOrderItemXrefListData =
          apiData['response']['returnOrderItemXrefList'];
          returnOrderItemXrefList = returnOrderItemXrefListData
              .map((item) => ReturnOrderItemXrefList.fromJson(item))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error initializing data: $e');
    }
  }

  Future<Map<String, dynamic>> getApiData() async {
    String apiUrl =
        'http://182.18.157.215/Srikar_Biotech_Dev/API/api/ReturnOrder/GetReturnOrderDetailsById/${widget.orderId}';
    final response = await http.get(Uri.parse(apiUrl));
    debugPrint('###############');
    debugPrint(response.body);
    debugPrint('###############');
    debugPrint('${widget.orderId}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: _appBar(),
      body: FutureBuilder(
        future: apiData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                'No orders found!',
                style: CommonUtils.Mediumtext_14_cb,
              ),
            );
          } else {
            if (snapshot.hasData) {
              List<ReturnOrderDetailsResult> result =
              List.from(returnOrderDetailsResultList);
              if (result.isNotEmpty) {
                ReturnOrderDetailsResult data = result[0];
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        // card 1
                        CommonUtils.buildCard(
                          data.partyName,
                          data.partyCode,
                          data.proprietorName,
                          data.partyGstNumber,
                          data.partyAddress,
                          Colors.white,
                          BorderRadius.circular(5.0),
                        ),
                        const SizedBox(
                          height: 10,
                        ),

                        // card 2
                        // shipment details card
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(
                                  left:
                                  5.0), // Adjust the left padding as needed
                              child: Text(
                                'Order Details',
                                style: CommonUtils.header_Styles16,
                              ),
                            ),
                            ListView(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              children: List.generate(
                                returnOrderDetailsResultList.length,
                                    (index) => ShipmentDetailsCard(
                                  orderId: widget.orderId,
                                  data: returnOrderDetailsResultList[index],
                                ),
                              ),
                            ),
                            // const SizedBox(
                            //   height: 10,
                            // ),

                            CustomReturnExpansionTile(
                              title: const Text(
                                "Item Details",
                                style: TextStyle(
                                    color: Colors
                                        .white), // Adjust text color as needed
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10.0),
                                    //   height: screenHeight / 2,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      //        color: Colors.white,
                                    ),
                                    child: ListView(
                                      physics:
                                      const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      children: List.generate(
                                        returnOrderItemXrefList.length,
                                            (index) => ItemCard(
                                          data: returnOrderItemXrefList[index],
                                          statusBar: widget.statusBar,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5.0,
                                  ),
                                ],
                              ),
                              initiallyExpanded: false,
                            ),

                            const SizedBox(
                              height: 5.0,
                            ),
                            if (returnOrderCredits.isNotEmpty)
                              CustomReturnExpansionTile(
                                title: const Text(
                                  "Credit Note Details",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: const EdgeInsets.only(
                                          left: 0.0, right: 0.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: const PageScrollPhysics(),
                                        itemCount: returnOrderCredits.length,
                                        itemBuilder: (context, index) {
                                          ReturnOrderCredit credit =
                                          returnOrderCredits[index];
                                          String creditedDateStr = credit
                                              .creditedDate; // Assuming `creditedDate` is a String representing the date.

// Parse the creditedDate string into a DateTime object.
                                          DateTime creditedDate =
                                          DateTime.parse(creditedDateStr);

// Format the DateTime object into the desired format 'dd MMM, yyyy'.
                                          String formattedDate =
                                          DateFormat('dd MMM, yyyy')
                                              .format(creditedDate);

                                          return Container(
                                            width: screenWidth,
                                            padding: const EdgeInsets.only(
                                                left: 10.0, right: 10.0),
                                            child: Card(
                                              elevation: 7,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(10.0),
                                              ),
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                  BorderRadius.circular(10),
                                                  color: Colors.white,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                      children: <Widget>[
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                12,
                                                                vertical:
                                                                10),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                const Text(
                                                                  'Credited Amount',
                                                                  style: CommonUtils
                                                                      .txSty_13B_Fb,
                                                                ),
                                                                Text(
                                                                  '₹${formatNumber(credit.creditedAmount)}',
                                                                  style:
                                                                  TextStyle(
                                                                    fontFamily:
                                                                    'Roboto',
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    color: HexColor(
                                                                        '#e58338'),
                                                                    fontSize:
                                                                    13,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 0.2,
                                                          height: 60,
                                                          color: Colors.grey,
                                                        ),
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                12,
                                                                vertical:
                                                                10),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                const Text(
                                                                  'Credited Date',
                                                                  style: CommonUtils
                                                                      .txSty_13B_Fb,
                                                                ),
                                                                Text(
                                                                  formattedDate,
                                                                  style:
                                                                  TextStyle(
                                                                    fontFamily:
                                                                    'Roboto',
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    color: HexColor(
                                                                        '#e58338'),
                                                                    fontSize:
                                                                    13,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Visibility(
                                                      visible:
                                                      true, // Set to false if you want to hide the section when remarks are null
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            width:
                                                            double.infinity,
                                                            height: 0.2,
                                                            color: Colors.grey,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                            children: <Widget>[
                                                              Expanded(
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                      12,
                                                                      vertical:
                                                                      10),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                    children: [
                                                                      const Text(
                                                                        'Remarks',
                                                                        style: CommonUtils
                                                                            .txSty_13B_Fb,
                                                                      ),
                                                                      Text(
                                                                        credit
                                                                            .remarks,
                                                                        style:
                                                                        TextStyle(
                                                                          fontFamily:
                                                                          'Roboto',
                                                                          fontWeight:
                                                                          FontWeight.bold,
                                                                          color:
                                                                          HexColor('#e58338'),
                                                                          fontSize:
                                                                          13,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      width: double.infinity,
                                                      height: 0.2,
                                                      color: Colors.grey,
                                                    ),
                                                    Container(
                                                      padding:
                                                      const EdgeInsets.all(
                                                          8.0),
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          String? pdfUrl =
                                                              credit.fileUrl;
                                                          String? invoiceNo =
                                                              "ReturnOrderCreditNoteFile";
                                                          downloadFile(pdfUrl,
                                                              invoiceNo);

                                                          //Add your download functionality here
                                                        },
                                                        child: Container(
                                                          height: 35,
                                                          margin:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal:
                                                              4.0),
                                                          decoration:
                                                          BoxDecoration(
                                                            color: const Color(
                                                                0xFFF8dac2),
                                                            border: Border.all(
                                                              color: const Color(
                                                                  0xFFe78337),
                                                              width: 1,
                                                            ),
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                8.0),
                                                          ),
                                                          child: IntrinsicWidth(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                              children: [
                                                                Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                      5.0),
                                                                  child: Row(
                                                                    children: [
                                                                      SvgPicture
                                                                          .asset(
                                                                        'assets/file-download.svg',
                                                                        height:
                                                                        18,
                                                                        width:
                                                                        18,
                                                                        fit: BoxFit
                                                                            .fitWidth,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                          8.0),
                                                                      const Text(
                                                                          'Download Credit Note',
                                                                          style:
                                                                          CommonUtils.Mediumtext_12),
                                                                    ],
                                                                  ),
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
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                initiallyExpanded: false,
                              ),
                            const SizedBox(
                              height: 5.0,
                            ),
                          ],
                        ),

                        // card 4
                        // payment details card
                        //   PaymentDetailsCard(data: data),
                      ],
                    ),
                  ),
                );
              } else {
                return const Center(
                  child: Text('No data present'),
                );
              }
            } else {
              return const Center(
                child: Text('No Collection'),
              );
            }
          }
        },
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: _orangeColor,
      automaticallyImplyLeading: false,
      elevation: 5,
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
                'Return Order Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              // Handle the click event for the home icon
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            child: Image.asset(
              'assets/srikar-home-icon.png',
              width: 30,
              height: 30,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> ReturnOrderCreditmethod() async {
    final response = await http.get(Uri.parse('http://182.18.157.215/Srikar_Biotech_Dev/API/api/ReturnOrder/GetReturnOrderCreditById/${widget.orderId}'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData['response'] != null && jsonData['response']['listResult'] != null) {
        final List<dynamic>? listResult = jsonData['response']['listResult'];

        if (listResult != null) {
          setState(() {
            returnOrderCredits = listResult.map((data) => ReturnOrderCredit.fromJson(data)).toList();
          });
        } else {
          // Handle the case where listResult is null
          // Maybe show a message to the user or handle it accordingly
        }
      } else {
        // Handle the case where jsonData['response'] or jsonData['response']['listResult'] is null
        // Maybe show a message to the user or handle it accordingly
      }
    } else {
      throw Exception('Failed to load data');
    }
  }


  String formatNumber(double number) {
    NumberFormat formatter = NumberFormat("#,##,##,##,##,##,##0.00", "en_US");
    return formatter.format(number);
  }

  Future<void> downloadFile(String url, String invoiceNo) async {
    try {
      // Send a GET request to the provided URL
      http.Response response = await http.get(Uri.parse(url));

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Get the application documents directory

        Directory appDocDir = Directory('/storage/emulated/0/Download');
        String fileName = "srikar_invoice_$invoiceNo.pdf";

        String filePath = '${appDocDir.path}/$fileName';
        // Get the download directory

        if (!appDocDir.existsSync()) {
          appDocDir.createSync(recursive: true);
        }
        await File(filePath).writeAsBytes(response.bodyBytes);
        // Create a File instance to save the PDF

        // Show a message indicating successful download
        // print('PDF downloaded successfully');
        CommonUtils.showCustomToastMessageLong(
            'Credit Note Downloaded Successfully', context, 0, 4);
        // You can use this file path to open the PDF file, or display it in your app

        print('PDF path: $filePath');
      } else {
        // If the request was not successful, print an error message
        print('Failed to download PDF: ${response.statusCode}');
      }
    } catch (e) {
      // If an error occurs during the download process, print the error
      print('Error downloading PDF: $e');
    }
  }
}


class CustomReturnExpansionTile extends StatefulWidget {
  final Widget title;
  final Widget content;
  final bool initiallyExpanded;

  const CustomReturnExpansionTile({
    Key? key,
    required this.title,
    required this.content,
    this.initiallyExpanded = false,
  }) : super(key: key);

  @override
  _CustomExpansionTileState createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomReturnExpansionTile> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      // margin: const EdgeInsets.symmetric(horizontal: 16.0),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                // borderRadius: BorderRadius.only(
                //   topLeft: Radius.circular(8.0),
                //   topRight: Radius.circular(8.0),
                // ),
                color: const Color(0xFFe78337), // Adjust the color as needed
              ),
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(child: widget.title),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) widget.content,
        ],
      ),
    );
  }
}

class ShipmentDetailsCard extends StatefulWidget {
  final int orderId;
  final ReturnOrderDetailsResult data;
  const ShipmentDetailsCard({
    super.key,
    required this.orderId,
    required this.data,
  });

  @override
  State<ShipmentDetailsCard> createState() => _ShipmentDetailsCardState();
}

class _ShipmentDetailsCardState extends State<ShipmentDetailsCard> {
  final _orangeColor = HexColor('#e58338');

  int currentIndex = 0;
  final _titleTextStyle = const TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w700,
    color: Colors.black,
    fontSize: 15,
  );

  final _dataTextStyle = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.bold,
    color: HexColor('#e58338'),
    fontSize: 13,
  );

  final dividerForHorizontal = Container(
    width: double.infinity,
    height: 0.2,
    color: Colors.grey,
  );
  final dividerForVertical = Container(
    width: 0.2,
    height: 60,
    color: Colors.grey,
  );

  late Future<List<ReturnOrdersImageList>> imageApiData;
  late List<ReturnOrdersImageList> attchmentImageData;

  @override
  void initState() {
    super.initState();
    imageApiData = getReturnOrderImagesById();
  }

  Future<List<ReturnOrdersImageList>> getReturnOrderImagesById() async {
    String apiUrl =
        'http://182.18.157.215/Srikar_Biotech_Dev/API/api/ReturnOrder/GetReturnOrderImagesById/${widget.orderId}';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        List<dynamic> resultList = jsonResponse['response']['listResult'];
        List<ReturnOrdersImageList> returnOrdersImageList = resultList
            .map((item) => ReturnOrdersImageList.fromJson(item))
            .toList();
        return returnOrdersImageList;
      } else {
        throw Exception('unsuccess api call');
      }
    } catch (e) {
      throw Exception('catch');
    }
  }

  @override
  Widget build(BuildContext context) {
    String dateString = widget.data.lrDate;
    DateTime date = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd MMM, yyyy').format(date);
    int currentIndex = 0;

    return FutureBuilder(
      future: imageApiData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator.adaptive();
        } else if (snapshot.hasError) {
          return const Center(child: Text('No data present'));
        } else {
          if (snapshot.hasData) {
            List<ReturnOrdersImageList> data = snapshot.data!;
            return Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // row one
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Order ID',
                                style: CommonUtils.txSty_13B_Fb,
                              ),
                              Text(
                                widget.data.returnOrderNumber,
                                style: _dataTextStyle,
                              ),
                            ],
                          ),
                          // widget.statusBar,
                          ItemCard.getSvgImagesAndColors(
                              widget.data.statusTypeId, widget.data.statusName),
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
                                const Text(
                                  'LR Number',
                                  style: CommonUtils.txSty_13B_Fb,
                                ),
                                Text(
                                  widget.data.lrNumber.toString(),
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
                                const Text(
                                  'LR Date',
                                  style: CommonUtils.txSty_13B_Fb,
                                ),
                                Text(
                                  formattedDate,
                                  style: _dataTextStyle,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    //

                    if (widget.data.transportName != null) ...[
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
                                  Text(
                                    'Transport Name',
                                    style: _titleTextStyle,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.data.transportName!,
                                    style: _dataTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

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
                                const Text(
                                  'Remarks',
                                  style: CommonUtils.txSty_13B_Fb,
                                ),
                                Text(
                                  widget.data.dealerRemarks.toString(),
                                  style: _dataTextStyle,
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
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 247, 232, 211),
                          border: Border.all(
                            color: _orangeColor,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            showAttachmentsDialog(data);
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.link,
                                size: 18,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Attachments',
                                style: CommonUtils.txSty_13B_Fb,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('No data present'));
          }
        }
      },
    );
  }

  void _showZoomedAttachments(String imageString) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.white),
            width: double.infinity,
            height: 500,
            child: Stack(
              children: [
                Center(
                  child: PhotoViewGallery.builder(
                    itemCount: 1, // Only one image in the gallery
                    builder: (context, index) {
                      return PhotoViewGalleryPageOptions(
                        imageProvider: NetworkImage(imageString),
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

  Widget buildIndicator(int index) {
    debugPrint('index: $index');
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

  void showAttachmentsDialog(List<ReturnOrdersImageList> data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Attachments'),
          elevation: 5.0,
          contentPadding: const EdgeInsets.all(5.0),
          content: SizedBox(
            height: 120,
            width: 300,
            child: Stack(
              children: [
                CarouselSlider(
                  items: data.map((imageUrl) {
                    return GestureDetector(
                      onTap: () {
                        _showZoomedAttachments(imageUrl.imageString);
                      },
                      child: Image.network(
                        imageUrl.imageString,
                        fit: BoxFit.cover,
                      ),
                    );
                  }).toList(),
                  options: CarouselOptions(
                    scrollPhysics: const BouncingScrollPhysics(),
                    autoPlay: true,
                    enableInfiniteScroll: false,
                    height: MediaQuery.of(context).size.height,
                    aspectRatio: 23 / 9,
                    viewportFraction: 1,
                    onPageChanged: (index, reason) {
                      // Handle page change if needed
                      setState(() {
                        currentIndex = index;
                      });
                    },
                  ),

                  // CarouselOptions(
                  //   scrollPhysics:
                  //       const BouncingScrollPhysics(),
                  //   autoPlay: false,
                  //   enableInfiniteScroll: false,
                  //   viewportFraction: 1.0,
                  //   height: MediaQuery.of(context)
                  //       .size
                  //       .height,
                  //   aspectRatio: 23 / 9,
                  //   onPageChanged: (index, reason) {
                  //     setState(() {
                  //       currentIndex = index;
                  //     });
                  //   },
                  // ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  //  padding: EdgeInsets.all(20.0),

                  height: MediaQuery.of(context).size.height,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          // Use the number of images from assets
                          data.length, // Replace with the actual number of assets
                              (index) {
                            return buildIndicator(index);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class AttachmentImages extends StatelessWidget {
  final String imageUrl;

  const AttachmentImages({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: MediaQuery.of(context).size.width,
    );
  }
}

class ItemCard extends StatelessWidget {
  final ReturnOrderItemXrefList data;
  final Widget statusBar;
  const ItemCard({super.key, required this.data, required this.statusBar});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              data.itemName,
              style: CommonUtils.txSty_13B_Fb,
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                const Text(
                  'Qty: ',
                  style: CommonUtils.txSty_13B_Fb,
                ),
                Text(
                  data.orderQty.toString(),
                  style: CommonUtils.txSty_13O_F6,
                ),
              ],
            ),
            const SizedBox(height: 5.0),
            Container(
              width: double.infinity,
              height: 0.2,
              color: Colors.grey,
            ),
            const SizedBox(height: 5.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data.remarks != null)
                  Flexible(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Remarks:',
                              style: CommonUtils.txSty_13B_Fb,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                data.remarks!,
                                style: CommonUtils.txSty_13O_F6,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5.0),
                        CommonUtils.dividerForHorizontal,
                      ],
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  getSvgImagesAndColors(data.statusTypeId, data.statusName),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget getSvgImagesAndColors(int statusTypeId, String statusName) {
    String svgIcon;
    Color statusColor;
    Color svgIconBgColor;

    switch (statusTypeId) {
      case 1: // 'Pending'
        svgIcon = 'assets/shipping-timed.svg';
        statusColor = const Color(0xFFe58338);
        svgIconBgColor = const Color(0xFFe58338).withOpacity(0.2);
        break;
      case 13: // 'Shipped'
        svgIcon = 'assets/shipping-fast.svg';
        statusColor =const Color(0xFFe58338);
        svgIconBgColor = const Color(0xFFe58338).withOpacity(0.2);
        break;
      case 14: // 'Received'
        svgIcon = 'assets/truck-check.svg';
    statusColor = Colors.green;
    svgIconBgColor = Colors.green.shade100;
        break;
      case 15: // 'Not Received'
        svgIcon = 'assets/order-cancel.svg';
        statusColor = Colors.red;
        svgIconBgColor = Colors.red.shade100;
        break;
      case 18: // 'Partially Received'
        svgIcon = 'assets/boxes.svg';
        statusColor =const Color(0xFF31b3cc);
        svgIconBgColor =const Color(0xFF31b3cc).withOpacity(0.2);
        break;


      default:
        svgIcon = 'assets/plus-small.svg';
        statusColor = Colors.black26;
        svgIconBgColor = Colors.black26.withOpacity(0.2);
        break;
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: svgIconBgColor,
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        children: [
          SvgPicture.asset(
            svgIcon,
            fit: BoxFit.fill,
            width: 15,
            height: 15,
            color: statusColor,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            statusName,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 13,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentDetailsCard extends StatefulWidget {
  final ReturnOrderDetailsResult data;
  const PaymentDetailsCard({super.key, required this.data});

  @override
  State<PaymentDetailsCard> createState() => _PaymentDetailsCardState();
}

class _PaymentDetailsCardState extends State<PaymentDetailsCard> {
  final _titleTextStyle = const TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w700,
    color: Colors.black,
    fontSize: 15,
  );

  final _dataTextStyle = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.bold,
    color: HexColor('#e58338'),
    fontSize: 13,
  );

  final dividerForHorizontal = Container(
    margin: const EdgeInsets.symmetric(vertical: 5),
    width: double.infinity,
    height: 1,
    color: Colors.grey,
  );

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        width: double.infinity, // remove padding here
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Total',
                    style: _titleTextStyle,
                  ),
                  Text(
                    widget.data.totalCost.toString(),
                    style: _dataTextStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
