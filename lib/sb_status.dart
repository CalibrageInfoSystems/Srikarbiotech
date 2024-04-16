import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'dart:ui' as ui;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:srikarbiotech/Common/styles.dart';

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
        return false;
      },
      child: Scaffold(
        body: Center(
          child: Column(
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
              const SizedBox(
                height: 35,
              ),
              const Text(
                'Your Collection Submitted Successfully',
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
                  const Text(
                    'Collection ID: ',
                    style: CommonStyles.txSty_14b_fb,
                  ),
                  Text(
                    widget.orderData['collectionNumber'].toString(),
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
                              style: CommonStyles.txSty_14w_fb,
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
                        await shareOrderDetails(widget.orderData);
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

  Future<void> shareOrderDetails(Map<String, dynamic> responseData) async {
    try {
      String partyCode = responseData['partyCode'];
      String partyName = responseData['partyName'];
      String address = responseData['address'];
      String base64Image = responseData['fileString'];

      String orderDetails =
          "Party Code: $partyCode\nParty Name: $partyName\nAddress: $address";

      // Decode base64 image
      Uint8List bytes = base64Decode(base64Image);

      // Convert bytes to Image
      ui.Image image = await decodeImageFromList(bytes);

      // Convert Image to ByteData
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Get temporary directory
      Directory tempDir = await getTemporaryDirectory();
      String imagePath = '${tempDir.path}/order_image.png';

      // Save the image to file
      File(imagePath).writeAsBytesSync(pngBytes);

      // Combine text and image into a single message
      final List<String> files = [imagePath];
      final String text = orderDetails;

      // Share the combined message
      await Share.shareFiles(files, text: text, subject: 'Order Details');
    } catch (error) {
      debugPrint('Error sharing order details: $error');
    }
  }
//
  // Future<void> shareOrderDetails(Map<String, dynamic> responseData) async {
  //   try {
  //     String partyCode = responseData['partyCode'];
  //     String partyName = responseData['partyName'];
  //     String address = responseData['address'];
  //     String base64Image = responseData['fileString'];
  //
  //     String orderDetails =
  //         "Party Code: $partyCode\nParty Name: $partyName\nAddress: $address\n";
  //
  //     Directory tempDir = await getTemporaryDirectory();
  //     String imagePath = '${tempDir.path}/order_image.jpg';
  //     File imageFile = File(imagePath);
  //     await imageFile.writeAsBytes(base64Decode(base64Image));
  //
  //     await Share.shareFiles(
  //       [imagePath],
  //       text: orderDetails,
  //       subject: 'Order Details',
  //     );
  //   } catch (error) {
  //     debugPrint('Error sharing order details: $error');
  //   }
  // }
}
