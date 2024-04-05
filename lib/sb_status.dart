import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

import 'package:srikarbiotech/view_collection_page.dart';

import 'HomeScreen.dart';

class StatusScreen extends StatefulWidget {
  final String Compneyname;
  final Map<String, dynamic> orderData;

  const StatusScreen(this.Compneyname, this.orderData, {super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen>
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

  @override
  Widget build(BuildContext context) {
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
              // mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
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
                Text(
                  'Your Collection Submitted Successfully',
                  style: TextStyle(
                    fontSize: 19,
                    letterSpacing: 0,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
                Text(
                  'Thank you for shopping with ${widget.Compneyname}',
                  style: const TextStyle(
                      fontSize: 18, letterSpacing: 0, height: 1.5),
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
                      'Collection ID: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.orderData['collectionNumber'].toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: primaryOrange,
                      ),
                    ),
                  ],
                ),
                // const SizedBox(
                //   height: 5,
                // ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   children: [
                //     const Text(
                //       'Order ID: ',
                //       style: TextStyle(fontWeight: FontWeight.bold),
                //     ),
                //     Text(
                //       orderId,
                //       style: TextStyle(
                //         fontWeight: FontWeight.bold,
                //         fontSize: 20,
                //         color: primaryOrange,
                //       ),
                //     ),
                //   ],
                // ),
                const SizedBox(
                  height: 20,
                ),
// here
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            // Add logic for the download button
                            await Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const ViewCollectionPage()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(0xFFe78337),
                            ),
                            child: const Center(
                              child: Text(
                                'Go to View Collections',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      GestureDetector(
                        onTap: () async {
                          debugPrint('state section: clicked');

                         await _shareorderdetails(widget.orderData);
                        //  shareImage();
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

                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 20),
                //   child: Row(
                //     children: [
                //       Expanded(
                //         child: GestureDetector(
                //           onTap: () {
                //             // Navigate to the "View Collections" screen
                //             Navigator.push(
                //               context,
                //               MaterialPageRoute(builder: (context) => const ViewCollectionPage()),
                //             );
                //           },
                //         child:
                //         Container(
                //           padding: const EdgeInsets.all(13),
                //           decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(12),
                //             color: primaryOrange,
                //           ),
                //           child: const Center(
                //             child: Text(
                //               'Go to View Collections',
                //               style: TextStyle(
                //                   fontWeight: FontWeight.bold, color: Colors.white),
                //             ),
                //           ),
                //         ),
                //                     ),
                //       ),

                //     ],
                //   ),
                // ),
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
        ));
  }

  // Future<void> _shareorderdetails(Map<String, dynamic> responseData) async {
  //   try {

  //     String partyCode = responseData['partyCode'];
  //     String partyName = responseData['partyName'];
  //     String address = responseData['address'];

  //     String orderDetails =
  //         "partyCode: $partyCode \npartyName: $partyName \naddress: $address \n";
  //     await Share.share(orderDetails, subject: 'Order Details');

  //   } catch (error) {
  //     debugPrint('catch: $error');

  //   }
  // }
  Future<void> _shareorderdetails(Map<String, dynamic> responseData) async {
    try {
      String partyCode = responseData['partyCode'];
      String partyName = responseData['partyName'];
      String address = responseData['address'];
      String base64Image = responseData['fileString']; // assuming this is the correct key for the base64 image

      String orderDetails =
          "Party Code: $partyCode \nParty Name: $partyName \nAddress: $address \n";

      // Create a temporary directory to store the image
      Directory tempDir = await getTemporaryDirectory();
      String imagePath = '${tempDir.path}/order_image.jpg';


      // Create a new File object from dart:io
      File imageFile = File(imagePath);

      // Write base64 encoded image data to the file
      await imageFile.writeAsBytes(base64Decode(base64Image));

      // Share both text and image
      await Share.shareFiles(
        [imagePath],
        text: orderDetails,
        subject: 'Order Details',
      );
    } catch (error) {
      debugPrint('Error sharing order details: $error');
    }
  }

  }

