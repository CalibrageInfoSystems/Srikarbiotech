import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
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

  late Future<List<ReturnOrderDetailsResult>> apiData;

  late List<ReturnOrderDetailsResult> returnOrderDetailsResultList = [];
  late List<ReturnOrderItemXrefList> returnOrderItemXrefList = [];

  @override
  void initState() {
    super.initState();
    apiData = tempApi();
    apiDataInitialization();
  }

  Future<void> apiDataInitialization() async {
    try {
      Map<String, dynamic> apiResult = await getApiData();

      List<Map<String, dynamic>> returnOrderDetailsResultListData =
      List<Map<String, dynamic>>.from(
          apiResult['response']['returnOrderDetailsResult']);

      returnOrderDetailsResultList = returnOrderDetailsResultListData
          .map((item) => ReturnOrderDetailsResult.fromJson(item))
          .toList();

      List<Map<String, dynamic>> returnOrderItemXrefListData =
      List<Map<String, dynamic>>.from(
          apiResult['response']['returnOrderItemXrefList']);
      returnOrderItemXrefList = returnOrderItemXrefListData
          .map((item) => ReturnOrderItemXrefList.fromJson(item))
          .toList();
    } catch (e) {
      print('Error initializing data: $e');
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

  Future<List<ReturnOrderDetailsResult>> tempApi() async {
    String apiUrl =
        'http://182.18.157.215/Srikar_Biotech_Dev/API/api/ReturnOrder/GetReturnOrderDetailsById/${widget.orderId}';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['isSuccess']) {
        List<dynamic> data =
        jsonResponse['response']['returnOrderDetailsResult'];
        List<ReturnOrderDetailsResult> result = data
            .map((item) => ReturnOrderDetailsResult.fromJson(item))
            .toList();
        return result;
      } else {
        throw Exception('Failed to load data');
      }
    } else {
      throw Exception('unsuccess api call');
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
            return const CircularProgressIndicator.adaptive();
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                'No collection found!',
                style: CommonUtils.Mediumtext_14_cb,
              ),
            );
          } else {
            if (snapshot.hasData) {
              List<ReturnOrderDetailsResult> data =
              List.from(returnOrderDetailsResultList);

              print('....................');
              print(data[0].partyName);
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Card(
                        elevation: 5,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Party Details',
                                style: _titleTextStyle,
                              ),
                              Text(
                                data[0].partyName,
                                style: _dataTextStyle,
                              ),
                              Text(
                                data[0].partyCode,
                                style: _dataTextStyle,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Address',
                                style: _titleTextStyle,
                              ),
                              Text(
                                data[0].partyAddress,
                                style: _dataTextStyle,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // shipment details card
                      ShipmentDetailsCard(orderId: widget.orderId, data: data),

                      // item card
                      ListView(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        children: List.generate(
                          returnOrderItemXrefList.length,
                              (index) =>
                              ItemCard(data: returnOrderItemXrefList[index]),
                        ),
                      ),
                      // Expanded(
                      //   child: ListView.builder(
                      //     physics: const NeverScrollableScrollPhysics(),
                      //     shrinkWrap: true,
                      //     itemCount: 2, // Provide the itemCount here
                      //     itemBuilder: (context, index) {
                      //       return const ItemCard(); // ItemCard should not be const if it needs to be built dynamically
                      //     },
                      //   ),
                      // ),

                      const SizedBox(
                        height: 20,
                      ),

                      // payment details card
                      const PaymentDetailsCard(),
                    ],
                  ),
                ),
              );
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
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            child: const Icon(
              Icons.home,
              size: 30,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class ShipmentDetailsCard extends StatefulWidget {
  final int orderId;
  final List<ReturnOrderDetailsResult> data;
  const ShipmentDetailsCard(
      {super.key, required this.orderId, required this.data});

  @override
  State<ShipmentDetailsCard> createState() => _ShipmentDetailsCardState();
}

class _ShipmentDetailsCardState extends State<ShipmentDetailsCard> {
  final _orangeColor = HexColor('#e58338');

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
    height: 1,
    color: Colors.grey,
  );
  final dividerForVertical = Container(
    width: 1,
    height: 60,
    color: Colors.grey,
  );

  late Future<List<ReturnOrdersImageList>> imageApiData;

  @override
  void initState() {
    super.initState();
    imageApiData = getReturnOrderImagesById();
  }

// here
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
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LR Number',
                                style: _titleTextStyle,
                              ),
                              Text(
                                widget.data[0].lrNumber,
                                style: _dataTextStyle,
                              ),
                            ],
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
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
                                  'LR Date',
                                  style: _titleTextStyle,
                                ),
                                Text(
                                  widget.data[0].lrDate.toString(),
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
                                  'Total',
                                  style: _titleTextStyle,
                                ),
                                Text(
                                  widget.data[0].totalCost.toString(),
                                  style: _dataTextStyle,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    dividerForHorizontal,

                    // row three
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
                                  'Transport Mode',
                                  style: _titleTextStyle,
                                ),
                                Text(
                                  'xxxxx',
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
                                  'Transport Name',
                                  style: _titleTextStyle,
                                ),
                                Text(
                                  'Railway Parcel Service',
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
            );
          } else {
            return const Center(child: Text('No data present'));
          }
        }
      },
    );
  }
}

// class ItemCard extends StatelessWidget {
//   const ItemCard({super.key});

//   final _titleTextStyle = const TextStyle(
//     fontFamily: 'Roboto',
//     fontWeight: FontWeight.w700,
//     color: Colors.black,
//     fontSize: 15,
//   );
//   final _dataTextStyle = const TextStyle(
//     fontFamily: 'Roboto',
//     fontWeight: FontWeight.w600,
//     color: Color.fromARGB(255, 185, 105, 0),
//     fontSize: 14,
//   );

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//         itemCount: 1,
//         itemBuilder: (context, index) {
//           return ClipRRect(
//             borderRadius: BorderRadius.circular(25.0),
//             child: Card(
//               elevation: 5,
//               child: Container(
//                 color: Colors.white,
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     Text(
//                       'Nuca-11 (Calcium 11% SC) - 1 Liter',
//                       style: _titleTextStyle,
//                     ),
//                     Row(
//                       children: [
//                         Text(
//                           'Qty: ',
//                           style: _titleTextStyle,
//                         ),
//                         Text(
//                           '12',
//                           style: _dataTextStyle,
//                         ),
//                       ],
//                     ),
//                     const SizedBox(
//                       height: 10,
//                     ),
//                     Row(
//                       children: [
//                         Text(
//                           '\$5475.00 ',
//                           style: _dataTextStyle,
//                         ),
//                         const SizedBox(
//                           width: 10,
//                         ),
//                         const Text(
//                           '\$8500.00 ',
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontFamily: 'Roboto',
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         });
//   }
// }

class ItemCard extends StatelessWidget {
  final ReturnOrderItemXrefList data;
  const ItemCard({super.key, required this.data});

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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              data.itemCode,
              style: _titleTextStyle,
            ),
            Row(
              children: [
                Text(
                  'Qty: ',
                  style: _titleTextStyle,
                ),
                Text(
                  data.orderQty.toString(),
                  style: _dataTextStyle,
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Text(
                  '\$${data.price.toString()} ',
                  style: _dataTextStyle,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  '\$${data.price.toString()} ',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold,
                  ),
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
  const PaymentDetailsCard({super.key});

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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
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
                    'xxxxx',
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