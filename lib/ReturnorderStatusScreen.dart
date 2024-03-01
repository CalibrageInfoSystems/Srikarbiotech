import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:srikarbiotech/ViewOrders.dart';
import 'package:srikarbiotech/view_collection_page.dart';

import 'HomeScreen.dart';
import 'ViewReturnorder.dart';

class ReturnorderStatusScreen extends StatelessWidget {

  final Map<String, dynamic> responseData;
  String orderId = "";

  ReturnorderStatusScreen({required this.responseData});
  @override
  Widget build(BuildContext context) {
    final primaryGreen = HexColor('#11872f');
    final primaryOrange = HexColor('#dc762b');
    print('Response Data: $responseData');
    orderId = responseData['response']['returnOrderNumber'] ?? 'xxxxxxxxxx';
    print('orderId: $orderId');


    // Assign returnOrderNumber to orderId


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
                'Your Return Order Placed Successfully',
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
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          print('Go to View Orders button clicked');

                          // Add logic for the download button
                          await Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => ViewReturnorder()),
                          );

                          // Once the ViewOrders screen is popped, the orderId should be updated
                          print('orderId: $orderId');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xFFe78337),
                          ),
                          child: const Center(
                            child:  Text(
                              'Go to View  Return Orders',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold, // Set the font weight to bold
                                fontFamily: 'Roboto', // Set the font family to Roboto
                              ),
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
                        print('Share button clicked');

                        // Create a formatted string with remaining data
                        // String formattedData = _formatData(responseData);
                        // print('Formatted Data:\n$formattedData');

                        // Save the formatted data to a text document
                        //await saveDataToTextDocument(formattedData);
                        await _shareorderdetails(responseData);

                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Color(0xFFe78337),
                          ),
                          color: Color(0xFFF8dac2),
                        ),
                        child: SvgPicture.asset(
                          'assets/share.svg',
                          color: Color(0xFFe78337),
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

//   Future<void> _shareorderdetails(Map<String, dynamic> responseData) async {
//     try {
//
// // Retrieve orderDate from responseData
//       String orderDate = responseData['response']['returnOrderDate'];
//
// // Parse the orderDate string into a DateTime object
//       DateTime dateTime = DateTime.parse(orderDate);
//
// // Define the desired date format
//       DateFormat formatter = DateFormat('dd-MM-yyyy');
//
// // Format the DateTime object to the desired format
//       String formattedOrderDate = formatter.format(dateTime);
//
//       // Format the order amount with Rupee symbol
//       NumberFormat amountFormatter = NumberFormat("#,##,##,##,##,##,##0.00", "en_US");
//       String formattedOrderAmount = '₹${amountFormatter.format(responseData['response']['totalCostWithGST'])}';
//
//       String orderDetails =
//           "Return Order Number: * " + responseData['response']['returnOrderNumber'] + " * \n";
//       // +
//       //         "Return Order Date: *" + formattedOrderDate + " * \n" +
//       //         "Party Name (Code): *" + responseData['response']['partyName'] + " (" + responseData['response']['partyCode'] + ") * \n" +
//       //         "Transport Name: * " + responseData['response']['transportName']+ " *\n";
//
//
//       await Share.share(orderDetails, subject: 'Order Details');
//     } catch (error) {
//       print('Error sharing order details: $error');
//     }
//   }
  Future<void> _shareorderdetails(Map<String, dynamic> responseData) async {
    try {
      if (responseData != null && responseData.containsKey('response')) {
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
            "Return Order Number: *$returnOrderNumber* \n" +
                "Return Order Date: *$formattedOrderDate* \n" +
                "Party Name (Code): *$partyName ($partyCode)* \n" +
                "Transport Name: *$transportName*\n";

        await Share.share(orderDetails, subject: 'Order Details');
      } else {
        print('Invalid or incomplete response.');
      }
    } catch (error) {
      print('Error sharing order details: $error');
    }
  }

}

