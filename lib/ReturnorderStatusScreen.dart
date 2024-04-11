import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:srikarbiotech/Common/styles.dart';

import 'HomeScreen.dart';
import 'ViewReturnorder.dart';

class ReturnorderStatusScreen extends StatefulWidget {
  final Map<String, dynamic> responseData;

  const ReturnorderStatusScreen({super.key, required this.responseData});

  @override
  State<ReturnorderStatusScreen> createState() =>
      _ReturnorderStatusScreenState();
}

class _ReturnorderStatusScreenState extends State<ReturnorderStatusScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _controller2;

  String orderId = "";

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

  @override
  Widget build(BuildContext context) {
    final primaryGreen = HexColor('#11872f');
    final primaryOrange = HexColor('#dc762b');
    print('Response Data: ${widget.responseData}');
    orderId =
        widget.responseData['response']['returnOrderNumber'] ?? 'xxxxxxxxxx';
    print('orderId: $orderId');

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // DottedBorder(
              //   borderType: BorderType.Circle,
              //   strokeWidth: 3,
              //   dashPattern: const <double>[9, 5],
              //   padding: const EdgeInsets.all(30),
              //   color: primaryGreen,
              //   child: SvgPicture.asset(
              //     'assets/check.svg',
              //     width: 50,
              //     height: 50,
              //     color: primaryGreen,
              //   ),
              // ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: RotationTransition(
                      turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
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
                    turns: Tween(begin: 0.0, end: 1.0).animate(_controller2),
                    child: SvgPicture.asset(
                      'assets/check.svg',
                      width: 70,
                      height: 70,
                      color: primaryGreen,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 35,
              ),
              const Text(
                'Your Return Order Placed Successfully',
                style: CommonStyles.txSty_18g_fb,
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                          await Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ViewReturnorder()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: CommonStyles.orangeColor,
                          ),
                          child: const Center(
                            child: Text(
                              'Go to View  Return Orders',
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
                        await _shareorderdetails(widget.responseData);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: CommonStyles.orangeColor,
                          ),
                          color: CommonStyles.whiteColor,
                        ),
                        child: SvgPicture.asset(
                          'assets/share.svg',
                          color: CommonStyles.orangeColor,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
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

  Future<void> _shareorderdetails(Map<String, dynamic> responseData) async {
    try {
      if (responseData.containsKey('response')) {
        Map<String, dynamic> response = responseData['response'];
        String returnOrderNumber = response['returnOrderNumber'] ?? 'N/A';
        String returnOrderDate = response['returnOrderDate'] ?? 'N/A';
        String partyName = response['partyName'] ?? 'N/A';
        String partyCode = response['partyCode'] ?? 'N/A';
        String transportName = response['transportName'] ?? 'N/A';

        DateTime? dateTime = DateTime.tryParse(returnOrderDate);
        String formattedOrderDate = dateTime != null
            ? DateFormat('dd MMM, yyyy').format(dateTime)
            : 'Invalid Date';

        String orderDetails =
            "Return Order Number: *$returnOrderNumber* \nReturn Order Date: *$formattedOrderDate* \nParty Name (Code): *$partyName ($partyCode)* \nTransport Name: *$transportName*\n";

        await Share.share(orderDetails, subject: 'Order Details');
      } else {
        print('Invalid or incomplete response.');
      }
    } catch (error) {
      print('Error sharing order details: $error');
    }
  }
}
