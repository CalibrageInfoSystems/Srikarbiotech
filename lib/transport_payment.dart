import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:srikarbiotech/Common/CommonUtils.dart';
import 'package:srikarbiotech/Ordersubmit_screen.dart';

import 'Billing_screen.dart';
import 'Model/CartHelper.dart';

class transport_payment extends StatefulWidget {
  final String cardName;
  final String cardCode;
  final String address;
  final String proprietorName;
  final String gstRegnNo;
  final String state;
  final String phone;
  final String bookingplace;
  final String preferabletransport;

  transport_payment(
      {required this.cardName,
        required this.cardCode,
        required this.address,
        required this.state,
        required this.bookingplace,
        required this.preferabletransport,
        required this.phone,
        required this.proprietorName,
        required this.gstRegnNo});

  @override
  _transportstate createState() => _transportstate();
}

class _transportstate extends State<transport_payment> {
  TextEditingController bookingplacecontroller = TextEditingController();
  TextEditingController Parcelservicecontroller = TextEditingController();
  @override
  void initState() {
    bookingplacecontroller = TextEditingController(text: widget.bookingplace);
    Parcelservicecontroller =
        TextEditingController(text: widget.preferabletransport);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFe78337),
        automaticallyImplyLeading:
        false, // This line removes the default back arrow
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              child: GestureDetector(
                onTap: () {
                  // Handle the click event for the back arrow icon
                  Navigator.of(context).pop();
                },
                child: Icon(
                  Icons.chevron_left,
                  size: 30.0,
                  color: Colors.white,
                ),
              ),
            ),
            Text(
              'Select Transport',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              // height: screenHeight / 2.8,
              width: screenWidth,
              alignment: Alignment.center,
              padding:
              EdgeInsets.only(top: 10.0, left: 10, right: 10, bottom: 10),
              child: Card(
                color: Colors.white,
                elevation: 5.0,
                // You can adjust the elevation as needed
                // Other card properties go here
                child: IntrinsicHeight(
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding:
                          EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 0.0, left: 5.0, right: 0.0),
                                child: Text(
                                  'Booking Place',
                                  style: TextStyle(
                                      color: Color(0xFF5f5f5f),
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              //  SizedBox(height: 8.0),
                              GestureDetector(
                                onTap: () {
                                  // Handle the click event for the second text view
                                  print('first textview clicked');
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    border: Border.all(
                                      color: Color(0xFFe78337),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 10.0, top: 0.0),
                                            child: TextFormField(
                                              controller: bookingplacecontroller,
                                              keyboardType: TextInputType.name,
                                              style: TextStyle(
                                                  color: Color(0xFFe78337),
                                                  fontFamily: 'Roboto',
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14),
                                              decoration: InputDecoration(
                                                hintText: 'Enter Booking Place',
                                                hintStyle: TextStyle(
                                                  fontSize: 14,
                                                  fontFamily: 'Roboto',
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xa0e78337),
                                                ),
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                          EdgeInsets.only(top: 8.0, left: 15.0, right: 15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 0.0, left: 5.0, right: 0.0),
                                child: Text(
                                  'Preferable Transport',
                                  style: TextStyle(
                                    color: Color(0xFF5f5f5f),
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              //  SizedBox(height: 8.0),
                              GestureDetector(
                                onTap: () {
                                  print('first textview clicked');
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    border: Border.all(
                                      color: Color(0xFFe78337),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 10.0, top: 0.0),
                                            child: TextFormField(
                                              controller: Parcelservicecontroller,
                                              keyboardType: TextInputType.name,
                                              style: TextStyle(
                                                  color: Color(0xFFe78337),
                                                  fontFamily: 'Roboto',
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14),
                                              decoration: InputDecoration(
                                                hintText: 'Enter Parcel Service',
                                                hintStyle: TextStyle(
                                                  fontSize: 14,
                                                  fontFamily: 'Roboto',
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xa0e78337),
                                                ),
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 15.0),
                      ],
                    )),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  // Add logic for the download button
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Ordersubmit_screen(
                        cardName: '${widget.cardName}',
                        cardCode: '${widget.cardCode}',
                        address: '${widget.address}',
                        state: '${widget.state}',
                        phone: '${widget.phone}',
                        proprietorName: '${widget.proprietorName}',
                        gstRegnNo: '${widget.gstRegnNo}',
                        BookingPlace: bookingplacecontroller.text,
                        TransportName: Parcelservicecontroller.text,
                      ),
                    ),
                  );

                  print(' button clicked');
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xFFe78337),
                  ),
                  child: const Center(
                    child: Text(
                      'Save & Proceed',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight:
                        FontWeight.w700, // Set the font weight to bold
                        fontFamily: 'Roboto', // Set the font family to Roboto
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
