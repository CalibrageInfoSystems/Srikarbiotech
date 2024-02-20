import 'dart:convert';

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

class ReturnOrderDetailsPage extends StatefulWidget {
  final int orderId;
  const ReturnOrderDetailsPage({super.key, required this.orderId});

  @override
  State<ReturnOrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<ReturnOrderDetailsPage> {
  final _orangeColor = HexColor('#e58338');
  final _titleTextStyle = const TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w700,
    color: Colors.black,
    fontSize: 15,
  );
  final _dataTextStyle = const TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w600,
    color: Color.fromARGB(255, 185, 105, 0),
    fontSize: 14,
  );

  late Future<Map<String, dynamic>> apiData;

  late List<ReturnOrderDetailsResult> returnOrderDetailsResultList = [];
  late List<ReturnOrderItemXrefList> returnOrderItemXrefList = [];

  @override
  void initState() {
    super.initState();
    apiData = getApiData();
    apiData.then((value) => initializingApiData(value));
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
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0), // Adjust the left padding as needed
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
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0), // Adjust the left padding as needed
                              child: Text(
                                'Item Details',
                                style: CommonUtils.header_Styles16,
                              ),
                            ),
                            ListView(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              children: List.generate(
                                returnOrderItemXrefList.length,
                                    (index) => ItemCard(data: returnOrderItemXrefList[index]),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
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
                MaterialPageRoute(builder: (context) =>  HomeScreen()),
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
}

class ShipmentDetailsCard extends StatefulWidget {
  final int orderId;
  final ReturnOrderDetailsResult data;
  const ShipmentDetailsCard(
      {super.key, required this.orderId, required this.data});

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
  final dividerForHorizontal1 = Container(
    width: double.infinity,
    height: 0.2,
    color: Colors.grey,
  );
  final dividerForHorizontal2 = Container(
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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 243, 214, 175),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              child: Row(
                                children: [
                                  // Icon(
                                  //   Icons.shopify,
                                  //   color: _orangeColor,
                                  // ),
                                  SvgPicture.asset(
                                    'assets/shipping-fast.svg',
                                    fit: BoxFit.fill,
                                    width: 15,
                                    height: 15,
                                    color: _orangeColor,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Shipped',
                                    style: _dataTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),

                    dividerForHorizontal1,

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
                                SizedBox(height: 4),
                                Text(
                                '',
                                  style: _dataTextStyle,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    dividerForHorizontal1,

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
                    dividerForHorizontal1,
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
  const ItemCard({super.key, required this.data});

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
        child:
        Column(
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
            SizedBox(height: 5.0),
            Container(
              width: double.infinity,
              height: 0.2,
              color: Colors.grey,
            ),
            SizedBox(height: 5.0),
            Row(
              children: [
                if (data.remarks != null)
                  Expanded(
                    child: Row(
                      children: [
                        const Text(
                          'Remarks:',
                          style: CommonUtils.txSty_13B_Fb,
                        ),
                        Text(
                          data.remarks!,
                          style: CommonUtils.txSty_13O_F6,
                        ),
                      ],
                    ),
                  ),
                if (data.remarks == null)
                  Expanded(
                    child: SizedBox(), // Empty container to occupy space
                  ),
                Spacer(), // Spacer to push statusName to the end
                Text(
                  data.statusName,
                  style: CommonUtils.txSty_13O_F6,
                ),
              ],
            ),
          ],
        ),


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

// apply code in OrderDetailsPage
