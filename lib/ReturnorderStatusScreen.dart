import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:srikarbiotech/ViewOrders.dart';
import 'package:srikarbiotech/view_collection_page.dart';

import 'HomeScreen.dart';
import 'ViewReturnorder.dart';

class ReturnorderStatusScreen extends StatelessWidget {
  final String returnOrderNumber;

  ReturnorderStatusScreen({required this.returnOrderNumber});

  @override
  Widget build(BuildContext context) {
    final primaryGreen = HexColor('#11872f');
    final primaryOrange = HexColor('#dc762b');

    // Assign returnOrderNumber to orderId
    String orderId = returnOrderNumber;

    return WillPopScope(
      onWillPop: () async {
        // Disable the back button functionality
        return false;
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DottedBorder(
                borderType: BorderType.Circle,
                strokeWidth: 3,
                dashPattern: const <double>[9, 5],
                padding: const EdgeInsets.all(30),
                color: primaryGreen,
                child: SvgPicture.asset(
                  'assets/check.svg',
                  width: 50,
                  height: 50,
                  color: primaryGreen,
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              Text(
                'Your Return Order got Placed successfully',
                style: TextStyle(
                  fontSize: 19,
                  letterSpacing: 0,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
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
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    orderId, // Display the orderId
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: primaryOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () {
                    // Navigate to the "View Collections" screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ViewReturnorder()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: primaryOrange,
                    ),
                    child: const Center(
                      child: Text(
                        'Go to View  Return Orders',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () {
                    // Navigate to the "View Collections" screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
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
                    child: Center(
                      child: Text(
                        'Back to Home',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryOrange,
                        ),
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
}

