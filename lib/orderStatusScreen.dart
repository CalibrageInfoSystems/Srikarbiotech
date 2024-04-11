import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:share_extend/share_extend.dart';
import 'package:srikarbiotech/Common/styles.dart';
import 'package:srikarbiotech/ViewOrders.dart';
import 'HomeScreen.dart';

class orderStatusScreen extends StatefulWidget {
  final Map<String, dynamic> responseData;
  final String? Compneyname;

  const orderStatusScreen(
      {super.key, required this.responseData, required this.Compneyname});

  @override
  State<orderStatusScreen> createState() => _orderStatusScreenState();
}

class _orderStatusScreenState extends State<orderStatusScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _controller2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller2.dispose();
    super.dispose();
  }

  String orderId = "";

  @override
  Widget build(BuildContext context) {
    orderId = widget.responseData['response']['orderNumber'] ?? 'xxxxxxxxxx';

    final primaryGreen = HexColor('#11872f');
    final primaryOrange = HexColor('#dc762b');

    return WillPopScope(
      onWillPop: () async {
        // Disable the back button functionality
        return false;
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: RotationTransition(
                          turns:
                              Tween(begin: 0.0, end: 1.0).animate(_controller),
                          child: DottedBorder(
                            borderType: BorderType.Circle,
                            strokeWidth: 3,
                            dashPattern: const <double>[9, 5],
                            padding: const EdgeInsets.all(30),
                            color: primaryGreen,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      RotationTransition(
                        turns:
                            Tween(begin: 0.0, end: 1.0).animate(_controller2),
                        child: SvgPicture.asset(
                          'assets/check.svg',
                          width: 70,
                          height: 70,
                          color: primaryGreen,
                        ),
                      )
                    ],
                  ),
                ],
              ),

              // DottedBorder(
              //   borderType: BorderType.Circle,
              //   strokeWidth: 3,
              //   dashPattern: const <double>[9, 5], //const <double>[3, 1]
              //   padding: const EdgeInsets.all(30),
              //   color: primaryGreen,
              //   child: SvgPicture.asset(
              //     'assets/check.svg',
              //     width: 50,
              //     height: 50,
              //     color: primaryGreen,
              //     // colorFilter: ColorFilter.mode(primaryGreen, BlendMode.srcIn),
              //   ),
              // ),
              const SizedBox(
                height: 35,
              ),
              const Text(
                'Your Order Placed Successfully',
                style: CommonStyles.txSty_18g_fb,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Thank you for shopping with ${widget.Compneyname}',
                style: CommonStyles.txSty_14b_fb,
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Display the orderId in the UI
                  const Text(
                    'Order ID: ',
                    style: CommonStyles.txSty_14b_fb,
                  ),
                  Text(
                    orderId,
                    style: CommonStyles.txSty_14o_f7,
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          print('Go to View Orders button clicked');

                          // Add logic for the download button
                          await Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ViewOrders()),
                          );

                          // Once the ViewOrders screen is popped, the orderId should be updated
                          print('orderId: $orderId');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFFe78337),
                          ),
                          child: const Center(
                            child: Text(
                              'Go to View Orders',
                              style: CommonStyles.txSty_14w_fb,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    InkWell(
                      onTap: () async {
                        String formattedData = _formatData(widget.responseData);
                        await _shareorderdetails(widget.responseData);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFe78337),
                          ),
                          color: const Color(0xFFF8dac2),
                        ),
                        child: SvgPicture.asset(
                          'assets/share.svg',
                          color: const Color(0xFFe78337),
                          width: 20,
                          height: 20,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                      ((route) => false),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        border: Border.all(
                          color: primaryOrange,
                        )),
                    child: const Center(
                      child: Text(
                        'Back to Home',
                        style: CommonStyles.txSty_14o_f7,
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
  }

  String _formatData(dynamic data) {
    if (data is Map) {
      return data.entries
          .map((entry) => '${entry.key}: ${_formatData(entry.value)}')
          .join('\n');
    } else if (data is Iterable) {
      return data.map((item) => _formatData(item)).join('\n');
    } else {
      return '$data';
    }
  }

//Future<void> saveDataToTextDocument(String data) async {
  Future<void> _shareorderdetails(Map<String, dynamic> responseData) async {
    try {
      if (responseData.containsKey('response')) {
        Map<String, dynamic> response = responseData['response'];
        String orderDate = response['orderDate'];

        DateTime date = DateTime.parse(orderDate);
        String formattedOrderDate = DateFormat('dd MMM, yyyy').format(date);

        // DateTime dateTime = DateTime.parse(orderDate);
        // DateFormat formatter = DateFormat('dd-MM-yyyy');
        // String formattedOrderDate = formatter.format(dateTime);
        String orderNumber = response['orderNumber'];
        String partyName = response['partyName'];
        String partyCode = response['partyCode'];
        String bookingPlace = response['bookingPlace'];
        String transportName = response['transportName'];

        NumberFormat amountFormatter =
            NumberFormat("#,##,##,##,##,##,##0.00", "en_US");
        double totalCost = response['totalCostWithGST'];
        String formattedOrderAmount = '₹${amountFormatter.format(totalCost)}';

        String orderDetails =
            "Order ID: *$orderNumber* \nOrder Date: *$formattedOrderDate* \nOrder Amount: *$formattedOrderAmount* \nParty Name (Code): *$partyName ($partyCode)* \nBooking Place: *$bookingPlace* \nTransport Name: *$transportName* \n";

        await Share.share(orderDetails, subject: 'Order Details');
      } else {
        print('Invalid or incomplete response.');
      }
    } catch (error) {
      print('Error sharing order details: $error');
    }
  }
}
