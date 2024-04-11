import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:srikarbiotech/Common/CommonUtils.dart';
import 'package:srikarbiotech/Common/styles.dart';
import 'package:srikarbiotech/Model/returnorderimagedata_model.dart';
import 'package:srikarbiotech/Model/viewreturnorders_model.dart';
import 'package:srikarbiotech/Services/api_config.dart';

import 'Common/SharedPrefsData.dart';
import 'HomeScreen.dart';
import 'Model/ReturnOrderCredit.dart';

class ReturnOrderDetailsPage extends StatefulWidget {
  final int orderId;
  final Widget statusBar;

  const ReturnOrderDetailsPage(
      {super.key, required this.orderId, required this.statusBar});

  @override
  State<ReturnOrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<ReturnOrderDetailsPage> {
  late Future<Map<String, dynamic>> apiData;

  late List<ReturnOrderDetailsResult> returnOrderDetailsResultList = [];
  late List<ReturnOrderItemXrefList> returnOrderItemXrefList = [];
  late List<ReturnOrderCredit> returnOrderCredits = [];
  int? companyId = 0;

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
    try {
      // String apiUrl =
      //     'http://182.18.157.215/Srikar_Biotech_Dev/API/api/ReturnOrder/GetReturnOrderDetailsById/${widget.orderId}';
      String apiUrl =
          baseUrl + GetReturnOrderDetailsById + widget.orderId.toString();
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed api call: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e);
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
            return const SizedBox();
            //return const Center(child: CommonStyles.progressIndicator);
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                'No orders found!',
                style: CommonStyles.txSty_12b_fb,
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 5.0),
                              child: Text(
                                'Order Details',
                                style: CommonStyles.txSty_14o_f7,
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
                            CustomReturnExpansionTile(
                              title: const Text(
                                "Item Details",
                                style: CommonStyles.txSty_14w_fb,
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
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
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
                                                        // Expanded(
                                                        //   child: Padding(
                                                        //     padding:
                                                        //     const EdgeInsets
                                                        //         .symmetric(
                                                        //         horizontal:
                                                        //         12,
                                                        //         vertical:
                                                        //         10),
                                                        //     child: Column(
                                                        //       crossAxisAlignment:
                                                        //       CrossAxisAlignment
                                                        //           .start,
                                                        //       children: [
                                                        //         const Text(
                                                        //           'Credited Amount',
                                                        //           style: CommonUtils
                                                        //               .txSty_13B_Fb,
                                                        //         ),
                                                        //         Text(
                                                        //           '₹${formatNumber(credit.creditedAmount)}',
                                                        //           style:
                                                        //           TextStyle(
                                                        //             fontFamily:
                                                        //             'Roboto',
                                                        //             fontWeight:
                                                        //             FontWeight
                                                        //                 .bold,
                                                        //             color: HexColor(
                                                        //                 '#e58338'),
                                                        //             fontSize:
                                                        //             13,
                                                        //           ),
                                                        //         ),
                                                        //       ],
                                                        //     ),
                                                        //   ),
                                                        // ),
                                                        // Container(
                                                        //   width: 0.2,
                                                        //   height: 60,
                                                        //   color: Colors.grey,
                                                        // ),
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
                                                    Row(
                                                      children: [
                                                        const Spacer(), // This will push the container to the right corner
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () async {
                                                              String? pdfUrl =
                                                                  credit
                                                                      .fileUrl;

                                                              String?
                                                                  invoiceNo =
                                                                  "ReturnOrderCreditNoteFile_";
                                                              downloadFile(
                                                                  pdfUrl,
                                                                  invoiceNo);
                                                              // Add your download functionality here
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
                                                                border:
                                                                    Border.all(
                                                                  color: const Color(
                                                                      0xFFe78337),
                                                                  width: 1,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                              ),
                                                              child:
                                                                  IntrinsicWidth(
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
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          SvgPicture
                                                                              .asset(
                                                                            'assets/file-download.svg',
                                                                            height:
                                                                                18,
                                                                            width:
                                                                                18,
                                                                            fit:
                                                                                BoxFit.fitWidth,
                                                                            color:
                                                                                Colors.black,
                                                                          ),
                                                                          const SizedBox(
                                                                              width: 8.0),
                                                                          const Text(
                                                                            'Download Credit Note',
                                                                            style:
                                                                                CommonUtils.Mediumtext_12,
                                                                          ),
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
      backgroundColor: CommonStyles.orangeColor,
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
                style: CommonStyles.txSty_18w_fb,
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                    );
                  },
                  child: Image.asset(
                    companyId == 1
                        ? 'assets/srikar-home-icon.png'
                        : 'assets/seeds-home-icon.png',
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
    );
  }

  Future<void> ReturnOrderCreditmethod() async {
    String apiurl =
        baseUrl + GetReturnOrderCreditById + widget.orderId.toString();
    print('ReturnOrderCredit==>$apiurl');
    final response = await http.get(Uri.parse(apiurl));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData['response'] != null) {
        final List<dynamic>? listResult = jsonData['response']['listResult'];

        if (listResult != null) {
          setState(() {
            returnOrderCredits = listResult
                .map((data) => ReturnOrderCredit.fromJson(data))
                .toList();
          });
        } else {
          throw Exception('No collection found');
        }
      } else {
        throw Exception('No response found');
      }
    } else {
      throw Exception('Failed api call');
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
        String formattedDateTime =
            DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        Directory appDocDir =
            Directory('/storage/emulated/0/Download/Srikar_Groups');
        String fileName = "srikar_Credit_$invoiceNo$formattedDateTime.pdf";

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

  Future<void> getshareddata() async {
    companyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
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
                color: CommonStyles.orangeColor,
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
  List<ReturnOrdersImageList>? receivedAttachs;
  int currentIndex = 0;

  late Future<List<ReturnOrdersImageList>> imageApiData;
  late List<ReturnOrdersImageList> attchmentImageData;

  @override
  void initState() {
    super.initState();
    imageApiData = getReturnOrderImagesById();
    getReturnOrderReceivedAttchImagesById();
  }

  Future<List<ReturnOrdersImageList>> getReturnOrderImagesById() async {
    String apiUrl = "$baseUrl$GetReturnOrderImagesById${widget.orderId}/19";
    //  String apiUrl = 'http://182.18.157.215/Srikar_Biotech_Dev/API/api/ReturnOrder/GetReturnOrderImagesById/${widget.orderId}/19';
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
          return const Center(child: CommonStyles.progressIndicator);
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
                                style: CommonStyles.txSty_12o_f7,
                              ),
                            ],
                          ),
                          // widget.statusBar,
                          ItemCard.getSvgImagesAndColors(
                              widget.data.statusTypeId, widget.data.statusName),
                        ],
                      ),
                    ),

                    CommonUtils.dividerForHorizontal,

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
                                  style: CommonStyles.txSty_12o_f7,
                                ),
                              ],
                            ),
                          ),
                        ),
                        CommonUtils.dividerForVertical,
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
                                  style: CommonStyles.txSty_12o_f7,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    //

                    if (widget.data.transportName != null) ...[
                      CommonUtils.dividerForHorizontal,
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
                                    widget.data.transportName!,
                                    style: CommonStyles.txSty_12o_f7,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (widget.data.whsName != null) ...[
                            CommonUtils.dividerForVertical,
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Warehouse',
                                      style: CommonUtils.txSty_13B_Fb,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          widget.data.whsName.toString(),
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.bold,
                                            color: HexColor('#e58338'),
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          ' (${widget.data.whsCode.toString()})',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.bold,
                                            color: HexColor('#e58338'),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ]
                        ],
                      ),
                    ],

                    CommonUtils.dividerForHorizontal,

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
                                  style: CommonStyles.txSty_12o_f7,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    CommonUtils.dividerForHorizontal,
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 247, 232, 211),
                              border: Border.all(
                                color: CommonStyles.orangeColor,
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
                                    style: CommonStyles.txSty_11b_fb,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          receivedAttachs == null
                              ? const SizedBox()
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 247, 232, 211),
                                    border: Border.all(
                                      color: CommonStyles.orangeColor,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      showAttachmentsDialog(receivedAttachs!);
                                      //  showReceivedAttach(receivedAttachs);
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
                                          'Received Attch',
                                          style: CommonUtils.txSty_13B_Fb,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ],
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

  Future<void> getReturnOrderReceivedAttchImagesById() async {
    String apiUrl = "$baseUrl$GetReturnOrderImagesById${widget.orderId}/20";
    //  String apiUrl = 'http://182.18.157.215/Srikar_Biotech_Dev/API/api/ReturnOrder/GetReturnOrderImagesById/${widget.orderId}/20';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        List<dynamic> resultList = jsonResponse['response']['listResult'];

        // Check if listResult is not null
        List<ReturnOrdersImageList> returnOrdersReceivedAttachImageList =
            resultList
                .map((item) => ReturnOrdersImageList.fromJson(item))
                .toList();
        receivedAttachs = returnOrdersReceivedAttachImageList;
      } else {
        throw Exception('Failed api call: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('catch');
    }
  }

  void showAttachmentsDialog(List<ReturnOrdersImageList> data) {
    int? currentPage = 0; // Initialize to the first page index

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
                  color: Colors.white,
                ),
                width: double.infinity,
                height: 500,
                child: Stack(
                  children: [
                    Center(
                      child: PhotoViewGallery.builder(
                        itemCount: data.length,
                        builder: (context, index) {
                          return PhotoViewGalleryPageOptions(
                            imageProvider:
                                NetworkImage(data[index].imageString),
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
                            currentPage =
                                index; // Update currentPage when page changes
                          });
                        },
                      ),
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
                                    ? Colors.orange
                                    : Colors.grey,
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

class ItemCard extends StatefulWidget {
  final ReturnOrderItemXrefList data;
  final Widget statusBar;

  const ItemCard({super.key, required this.data, required this.statusBar});

  @override
  State<ItemCard> createState() => _ItemCardState();

  static Widget getSvgImagesAndColors(int statusTypeId, String statusName) {
    String svgIcon;
    Color statusColor;
    Color svgIconBgColor;

    switch (statusTypeId) {
      case 1: // 'Pending'
        svgIcon = 'assets/shipping-timed.svg';
        statusColor = CommonStyles.orangeColor;
        svgIconBgColor = CommonStyles.orangeColor.withOpacity(0.2);
        break;
      case 13: // 'Shipped'
        svgIcon = 'assets/shipping-fast.svg';
        statusColor = CommonStyles.orangeColor;
        svgIconBgColor = CommonStyles.orangeColor.withOpacity(0.2);
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
        statusColor = const Color(0xFF31b3cc);
        svgIconBgColor = const Color(0xFF31b3cc).withOpacity(0.2);
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
              fontSize: 11,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemCardState extends State<ItemCard> {
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
              widget.data.itemName,
              style: CommonStyles.txSty_14b_fb,
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Qty: ',
                      style: CommonStyles.txSty_12b_fb,
                    ),
                    Text(
                      widget.data.orderQty.toString(),
                      style: CommonStyles.txSty_12o_f7,
                    ),
                  ],
                ),
                if (widget.data.partialQty != null)
                  Row(
                    children: [
                      const Text(
                        'Partially Received Qty: ',
                        style: CommonStyles.txSty_12b_fb,
                      ),
                      Text(
                        widget.data.partialQty.toString(),
                        style: CommonStyles.txSty_12o_f7,
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 5.0),
            if (widget.data.remarks != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonUtils.dividerForHorizontal,
                  const SizedBox(height: 5.0),
                  const Text(
                    'Remarks',
                    style: CommonStyles.txSty_12b_fb,
                  ),
                  Text(
                    widget.data.remarks!,
                    style: CommonStyles.txSty_12o_f7,
                  ),
                  const SizedBox(height: 5.0),
                ],
              ),
            CommonUtils.dividerForHorizontal,
            const SizedBox(height: 5.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widget.data.fileUrl == null
                    ? const SizedBox()
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 247, 232, 211),
                          border: Border.all(
                            color: CommonUtils.orangeColor,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            showItemDetailsAttachments(widget.data.fileUrl!);
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
                                'Item Attch',
                                style: CommonStyles.txSty_12b_fb,
                              ),
                            ],
                          ),
                        ),
                      ),
                ItemCard.getSvgImagesAndColors(
                    widget.data.statusTypeId, widget.data.statusName),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showItemDetailsAttachments(String fileUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                  child: PhotoViewGallery.builder(
                    itemCount: 1,
                    builder: (context, index) {
                      return PhotoViewGalleryPageOptions(
                        imageProvider: NetworkImage(fileUrl),
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
                      // onPageChanged callback if needed
                    },
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
  }
}

class PaymentDetailsCard extends StatefulWidget {
  final ReturnOrderDetailsResult data;

  const PaymentDetailsCard({super.key, required this.data});

  @override
  State<PaymentDetailsCard> createState() => _PaymentDetailsCardState();
}

class _PaymentDetailsCardState extends State<PaymentDetailsCard> {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Total',
                    style: CommonStyles.txSty_12b_fb,
                  ),
                  Text(
                    widget.data.totalCost.toString(),
                    style: CommonStyles.txSty_12o_f7,
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
