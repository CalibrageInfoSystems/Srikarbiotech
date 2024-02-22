import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:photo_view/photo_view.dart';
import 'package:srikarbiotech/Common/CommonUtils.dart';
import 'dart:convert';
import 'dart:io';

import 'Common/SharedPrefsData.dart';
import 'HomeScreen.dart';
import 'ReturnOrdersubmit_screen.dart';

class Returntransportdetails extends StatefulWidget {
  final String cardName;
  final String cardCode;
  final String address;
  final String proprietorName;
  final String gstRegnNo;
  final String state;
  final String phone;
  final double creditLine;
  final String lrnumber;
  final String lrdate;
  final String remarks;
  final double balance;
  final String transportname;

  Returntransportdetails(
      {required this.cardName,
      required this.cardCode,
      required this.address,
      required this.state,
      required this.phone,
      required this.lrnumber,
      required this.lrdate,
      required this.remarks,
      required this.proprietorName,
      required this.gstRegnNo,
      required this.creditLine,
      required this.balance,
      required this.transportname});

  @override
  State<Returntransportdetails> createState() => _createreturnorderPageState();
}

class _createreturnorderPageState extends State<Returntransportdetails> {
  //File? _imageFile;
  String filename = '';
  String fileExtension = '';
  String base64Image = '';
  File? _imageFile;

  String filenameorderreciept = '';
  String fileExtensionorderreciept = '';
  String base64Imageorderreciept = '';
  File? _imageFileorderreciept;

  String filenameaddlattchments = '';
  String fileExtensionaddlattchments = '';
  String base64Imageaddlattchments = '';
  File? _imageFileaddlattchments;
  TextEditingController remarkstext = TextEditingController();
  TextEditingController DateController = TextEditingController();

  TextEditingController LRNumberController = TextEditingController();
  TextEditingController TransportController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  int CompneyId = 0;
  @override
  void initState() {
    // TODO: implement initState
    LRNumberController = TextEditingController(text: widget.lrnumber);
    DateController = TextEditingController(text: widget.lrdate);
    remarkstext = TextEditingController(text: widget.remarks);
    TransportController = TextEditingController(text: widget.transportname);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFe78337),
        automaticallyImplyLeading: false,
        // This line removes the default back arrow
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
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
                  'Transport Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
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
                      // Handle the click event for the home icon
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                    child: Image.asset(
                      CompneyId == 1
                          ? 'assets/srikar-home-icon.png'
                          : 'assets/seeds-home-icon.png',
                      width: 30,
                      height: 30,
                    ),
                  );
                } else {
                  // Return a placeholder or loading indicator
                  return SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          //color: Colors.white,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Colors.white,
          ),
          padding: EdgeInsets.all(10.0),
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            elevation: 5,
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                top: 0.0, left: 0.0, right: 0.0),
                            child: Text(
                              'LR Number *',
                              style: CommonUtils.Mediumtext_12,
                              textAlign: TextAlign.start,
                            ),
                          ),
                          SizedBox(height: 2.0),
                          //  SizedBox(height: 8.0),
                          GestureDetector(
                            onTap: () {
                              // Handle the click event for the second text view
                              print('first textview clicked');
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 55.0,
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
                                          controller: LRNumberController,
                                          keyboardType: TextInputType.name,
                                          maxLength: 100,
                                          style: CommonUtils.Mediumtext_o_14,
                                          decoration: InputDecoration(
                                            counterText: '',
                                            hintText: 'Enter LR Number',
                                            hintStyle:
                                                CommonUtils.hintstyle_o_14,
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
                      padding: EdgeInsets.only(left: 15, top: 15.0, right: 15),
                      child: buildDateInput(
                        context,
                        'LR Date *',
                        DateController,
                        () => _selectDate(context, DateController),
                      ),
                    ),
                    Container(
                      padding:
                      EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                top: 0.0, left: 0.0, right: 0.0),
                            child: Text(
                              'Transport Name *',
                              style: CommonUtils.Mediumtext_12,
                              textAlign: TextAlign.start,
                            ),
                          ),
                          SizedBox(height: 2.0),
                          //  SizedBox(height: 8.0),
                          GestureDetector(
                            onTap: () {
                              // Handle the click event for the second text view
                              print('first textview clicked');
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 55.0,
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
                                          controller: TransportController,
                                          keyboardType: TextInputType.name,
                                          maxLength: 100,
                                          style: CommonUtils.Mediumtext_o_14,
                                          decoration: InputDecoration(
                                            counterText: '',
                                            hintText: 'Enter Transport Name',
                                            hintStyle:
                                            CommonUtils.hintstyle_o_14,
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
                      padding: EdgeInsets.only(left: 15, top: 4.0, right: 15),
                      child: GestureDetector(
                          onTap: () async {},
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 15.0, left: 0.0, right: 0.0),
                                child: Text(
                                  'Remarks *',
                                  style: CommonUtils.Mediumtext_12,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Container(
                                height: 120,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Color(0xFFe78337), width: 1),
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: Colors.white,
                                ),
                                child:
                                TextFormField(
                                  controller: remarkstext,
                                  maxLength: 100,
                                  style: CommonUtils.Mediumtext_o_14,
                                  maxLines:
                                      null, // Set maxLines to null for multiline input
                                  decoration: InputDecoration(
                                    counterText: '',
                                    hintText: 'Enter Return Order remarks',
                                    hintStyle: CommonUtils.hintstyle_o_14,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10.0,
                                      vertical: 0.0,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15, top: 15.0, right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left:
                                    0.0), // Add left padding to move the text 20 pixels left
                            child: Text(
                              'LR Attachment *',
                              style: CommonUtils.Mediumtext_12,
                              textAlign: TextAlign.start,
                            ),
                          ),
                          SizedBox(height: 2.0),
                          if (_imageFile == null)
                            GestureDetector(
                              onTap: () {
                                // here
                                showBottomSheetForImageSelection(context);
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                padding: EdgeInsets.all(0.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: DottedBorder(
                                        borderType: BorderType.RRect,
                                        color: Color(0xFFe78337),
                                        padding: const EdgeInsets.only(
                                            top: 0, bottom: 0.0),
                                        strokeWidth: 2,
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          padding: EdgeInsets.all(10.0),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFffeee0),
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFe78337),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Icon(
                                                  Icons.folder_rounded,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 4.0,
                                              ),
                                              Text(
                                                'Choose file to upload',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFFe78337),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const Text(
                                                'Supported formats: jpg, png',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFF414141),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          GestureDetector(
                            onTap: () {
                              // Handle tap on uploaded image to show in a popup
                              if (_imageFile != null) {
                                _showImagePopup(context, _imageFile!);
                              }
                            },
                            child: SizedBox(
                              width: _imageFile != null
                                  ? MediaQuery.of(context).size.width
                                  : MediaQuery.of(context).size.width,
                              height: _imageFile != null ? 100 : 0,
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  _imageFile != null
                                      ? Image.file(
                                          _imageFile!,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          fit: BoxFit.fitWidth,
                                        )
                                      : Image.asset(
                                          'assets/shopping_bag.png',
                                          width:
                                              MediaQuery.of(context).size.width,
                                          fit: BoxFit.fitWidth,
                                        ),
                                  if (_imageFile != null)
                                    GestureDetector(
                                      onTap: () {
                                        // Handle tap on cross mark icon (optional)
                                        setState(() {
                                          _imageFile =
                                              null; // Set _imageFile to null to remove the image
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(5.0),
                                        margin: EdgeInsets.only(
                                            top: 5, right: 10.0),
                                        color: HexColor(
                                            '#ffeee0'), // Optional overlay color
                                        child: SvgPicture.asset(
                                          'assets/crosscircle.svg',
                                          color: Color(0xFFe78337),
                                          width:
                                              24.0, // Set the width as needed
                                          height:
                                              24.0, // Set the height as needed
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
                      padding: EdgeInsets.only(left: 15, top: 15.0, right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Return Order Receipt *',
                            style: CommonUtils.Mediumtext_12,
                            textAlign: TextAlign.start,
                          ),
                          SizedBox(height: 2.0),
                          if (_imageFileorderreciept == null)
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 0.0), // Add left padding
                              child: GestureDetector(
                                onTap: () {
                                  // here
                                  showBottomSheetForImageSelectionordereceipt(
                                      context);
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  padding: EdgeInsets.all(0.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: DottedBorder(
                                          borderType: BorderType.RRect,
                                          color: Color(0xFFe78337),
                                          padding: const EdgeInsets.only(
                                              top: 0, bottom: 0.0),
                                          strokeWidth: 2,
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            padding: EdgeInsets.all(10.0),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFffeee0),
                                            ),
                                            child: Column(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFe78337),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: const Icon(
                                                    Icons.folder_rounded,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 4.0,
                                                ),
                                                Text(
                                                  'Choose file to upload',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFFe78337),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const Text(
                                                  'Supported formats: jpg,png',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Color(0xFF414141),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          // SizedBox(height: 10.0),
                          GestureDetector(
                            onTap: () {
                              // Handle tap on uploaded image to show in a popup
                              if (_imageFileorderreciept != null) {
                                _showImagePopup(
                                    context, _imageFileorderreciept!);
                              }
                            },
                            child: SizedBox(
                              width: _imageFileorderreciept != null
                                  ? MediaQuery.of(context).size.width
                                  : MediaQuery.of(context).size.width,
                              height: _imageFileorderreciept != null ? 100 : 0,
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  _imageFileorderreciept != null
                                      ? Image.file(
                                          _imageFileorderreciept!,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          fit: BoxFit.fitWidth,
                                        )
                                      : Image.asset(
                                          'assets/shopping_bag.png',
                                          width:
                                              MediaQuery.of(context).size.width,
                                          fit: BoxFit.fitWidth,
                                        ),
                                  if (_imageFileorderreciept != null)
                                    GestureDetector(
                                      onTap: () {
                                        // Handle tap on cross mark icon (optional)
                                        setState(() {
                                          _imageFileorderreciept =
                                              null; // Set _imageFileOrderReceipt to null to remove the image
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(5.0),
                                        margin: EdgeInsets.only(
                                            top: 5, right: 10.0),
                                        color: HexColor(
                                            '#ffeee0'), // Optional overlay color
                                        child: SvgPicture.asset(
                                          'assets/crosscircle.svg',
                                          color: Color(0xFFe78337),
                                          width:
                                              24.0, // Set the width as needed
                                          height:
                                              24.0, // Set the height as needed
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
                      padding: EdgeInsets.only(left: 15, top: 15.0, right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Addl. Attachments',
                            style: CommonUtils.Mediumtext_12,
                            textAlign: TextAlign.start,
                          ),
                          SizedBox(height: 2.0),
                          if (_imageFileaddlattchments == null)
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 0.0), // Add left padding
                              child: GestureDetector(
                                onTap: () {
                                  // here
                                  showBottomSheetForImageSelectionaddlattachment(
                                      context);
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  padding: EdgeInsets.all(0.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: DottedBorder(
                                          borderType: BorderType.RRect,
                                          color: Color(0xFFe78337),
                                          padding: const EdgeInsets.only(
                                              top: 0, bottom: 0.0),
                                          strokeWidth: 2,
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            padding: EdgeInsets.all(10.0),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFffeee0),
                                            ),
                                            child: Column(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFe78337),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: const Icon(
                                                    Icons.folder_rounded,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 4.0,
                                                ),
                                                Text(
                                                  'Choose file to upload',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFFe78337),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const Text(
                                                  'Supported formats: jpg, png',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Color(0xFF414141),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          GestureDetector(
                            onTap: () {
                              // Handle tap on uploaded image to show in a popup
                              if (_imageFileaddlattchments != null) {
                                _showImagePopup(
                                    context, _imageFileaddlattchments!);
                              }
                            },
                            child: SizedBox(
                              width: _imageFileaddlattchments != null
                                  ? MediaQuery.of(context).size.width
                                  : MediaQuery.of(context).size.width,
                              height:
                                  _imageFileaddlattchments != null ? 100 : 0,
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  _imageFileaddlattchments != null
                                      ? Image.file(
                                          _imageFileaddlattchments!,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          fit: BoxFit.fitWidth,
                                        )
                                      : Image.asset(
                                          'assets/shopping_bag.png',
                                          width:
                                              MediaQuery.of(context).size.width,
                                          fit: BoxFit.fitWidth,
                                        ),
                                  if (_imageFileaddlattchments != null)
                                    GestureDetector(
                                      onTap: () {
                                        // Handle tap on cross mark icon (optional)
                                        setState(() {
                                          _imageFileaddlattchments =
                                              null; // Set _imageFileOrderReceipt to null to remove the image
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(5.0),
                                        margin: EdgeInsets.only(
                                            top: 5, right: 10.0),
                                        color: HexColor(
                                            '#ffeee0'), // Optional overlay color
                                        child: SvgPicture.asset(
                                          'assets/crosscircle.svg',
                                          color: Color(0xFFe78337),
                                          width:
                                              24.0, // Set the width as needed
                                          height:
                                              24.0, // Set the height as needed
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
                    SizedBox(height: 10.0),
                  ],
                )),
          ),
        ),
      ),
      bottomNavigationBar: InkWell(
        onTap: () {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //     content: Text('Payment Successful'),
          //     duration: Duration(seconds: 2),
          //   ),
          // );
          print('clicked ');
        },
        child: Padding(
          padding:
          const EdgeInsets.only(top: 0.0, left: 14.0, right: 14.0, bottom: 10.0),
          child: Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            height: 55.0,
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 45.0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      validate(context);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 45.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.0),
                        color: const Color(0xFFe78337),
                      ),
                      child: const Center(
                        child: Text(
                          'Save & Proceed',
                          style: CommonUtils.Buttonstyle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showBottomSheetForImageSelection(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Color(0xFFFFFFFF),
      shape: ShapeBorder.lerp(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        1,
      ),
      context: context,
      builder: (context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width / 4,
          child: Row(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: () {
                    pickImage(ImageSource.camera, context);
                  },
                  child: const Center(
                    child: Icon(
                      Icons.camera_alt,
                      size: 40,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    pickImage(ImageSource.gallery, context);
                  },
                  child: const Center(
                    child: Icon(
                      Icons.folder,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  pickImage(ImageSource source, BuildContext context) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        print('===> _imageFile: $_imageFile');
      });
      filename = basename(_imageFile!.path);
      fileExtension = extension(_imageFile!.path);
      List<int> imageBytes = await _imageFile!.readAsBytes();
      base64Image = base64Encode(imageBytes);

      print('===> Filename: $filename');
      print('===> File Extension: $fileExtension');
      print('===> Base64 Image: $base64Image');

      // Dismiss the bottom sheet after picking an image
      Navigator.pop(context);
    }
  }

  void showBottomSheetForImageSelectionordereceipt(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Color(0xFFFFFFFF),
      shape: ShapeBorder.lerp(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        1,
      ),
      context: context,
      builder: (context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width / 4,
          child: Row(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: () {
                    pickImageordereceipt(ImageSource.camera, context);
                  },
                  child: const Center(
                    child: Icon(
                      Icons.camera_alt,
                      size: 40,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    pickImageordereceipt(ImageSource.gallery, context);
                  },
                  child: const Center(
                    child: Icon(
                      Icons.folder,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  pickImageordereceipt(ImageSource source, BuildContext context) async {
    final pickedFile1 = await ImagePicker().pickImage(source: source);
    if (pickedFile1 != null) {
      setState(() {
        _imageFileorderreciept = File(pickedFile1.path);
        print('===> _imageFileorderreciept: $_imageFileorderreciept');
      });
      filenameorderreciept = basename(_imageFileorderreciept!.path);
      fileExtensionorderreciept = extension(_imageFileorderreciept!.path);
      List<int> imageBytes1 = await _imageFileorderreciept!.readAsBytes();
      base64Imageorderreciept = base64Encode(imageBytes1);

      print('===> filenameorderreciept: $filenameorderreciept');
      print('===> File Extension: $fileExtensionorderreciept');
      print('===> Base64 Image: $base64Imageorderreciept');

      // Dismiss the bottom sheet after picking an image
      Navigator.pop(context);
    }
  }

  void showBottomSheetForImageSelectionaddlattachment(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Color(0xFFFFFFFF),
      shape: ShapeBorder.lerp(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        1,
      ),
      context: context,
      builder: (context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width / 4,
          child: Row(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: () {
                    pickImageddlattachment(ImageSource.camera, context);
                  },
                  child: const Center(
                    child: Icon(
                      Icons.camera_alt,
                      size: 40,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    pickImageddlattachment(ImageSource.gallery, context);
                  },
                  child: const Center(
                    child: Icon(
                      Icons.folder,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  pickImageddlattachment(ImageSource source, BuildContext context) async {
    final pickedFile2 = await ImagePicker().pickImage(source: source);
    if (pickedFile2 != null) {
      setState(() {
        _imageFileaddlattchments = File(pickedFile2.path);
        print('===> _imageFileaddlattchments: $_imageFileaddlattchments');
      });
      filenameaddlattchments = basename(_imageFileaddlattchments!.path);
      fileExtensionaddlattchments = extension(_imageFileaddlattchments!.path);
      List<int> imageBytes2 = await _imageFileaddlattchments!.readAsBytes();
      base64Imageaddlattchments = base64Encode(imageBytes2);

      print('===> filenameaddlattchments: $filenameaddlattchments');
      print('===> File Extension: $fileExtensionaddlattchments');
      print('===> Base64 Image: $base64Imageaddlattchments');

      // Dismiss the bottom sheet after picking an image
      Navigator.pop(context);
    }
  }

  static Widget buildDateInput(
    BuildContext context,
    String labelText,
    TextEditingController controller,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 0.0, left: 0.0, right: 0.0),
          child: Text(
            labelText,
            style: CommonUtils.Mediumtext_12,
            textAlign: TextAlign.start,
          ),
        ),
        SizedBox(height: 2.0),
        GestureDetector(
          onTap: () async {
            // Call the onTap callback to open the date picker
            onTap();
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 55.0,
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
                      padding: EdgeInsets.only(left: 10.0, top: 0.0),
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: controller,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFe78337),
                          ),
                          decoration: InputDecoration(
                            hintText: labelText,
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
                ),
                InkWell(
                  onTap: () async {
                    // Call the onTap callback to open the date picker
                    onTap();
                  },
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.calendar_today,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime currentDate = DateTime.now();
  //  DateTime initialDate;
    DateTime initialDate = selectedDate ?? currentDate;
    // if (controller.text.isNotEmpty) {
    //   try {
    //     initialDate = DateTime.parse(controller.text);
    //   } catch (e) {
    //     // Handle the case where the current text is not a valid date format
    //     print("Invalid date format: $e");
    //     initialDate = currentDate;
    //   }
    // } else {
    //   initialDate = currentDate;
    // }

    try {
      DateTime? picked = await showDatePicker(
        context: context,
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (picked != null) {
        String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
        controller.text = formattedDate;

        // Save selected dates as DateTime objects
        selectedDate = picked;
        print("Selected Date: $selectedDate");

        // Print formatted date
        print("Selected Date: ${DateFormat('yyyy-MM-dd').format(picked)}");
      }
    } catch (e) {
      print("Error selecting date: $e");
      // Handle the error, e.g., show a message to the user or log it.
    }
  }

  void _showImagePopup(BuildContext context, File imageFile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _buildImagePopup(imageFile),
      ),
    );
  }

  Widget _buildImagePopup(File imageFile) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFe78337),
        automaticallyImplyLeading: false,
        title: Text("Attached Image"),
      ),
      body: Container(
        child: PhotoView(
          imageProvider: FileImage(imageFile),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          enableRotation: true,
        ),
      ),
    );
  }

  Future<void> getshareddata() async {
    CompneyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");

    print('Company ID: $CompneyId');
  }

  void validate(BuildContext context) {
    bool isValid = true;
    bool hasValidationFailed = false;
    if (isValid && LRNumberController.text.isEmpty) {
      CommonUtils.showCustomToastMessageLong(
          'Please Enter LR Number', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }

    if (isValid && DateController.text.isEmpty) {
      CommonUtils.showCustomToastMessageLong(
          'Please Enter LR Date', context, 1, 4);

      isValid = false;
      hasValidationFailed = true;
    }
    if (isValid && TransportController.text.isEmpty) {
      CommonUtils.showCustomToastMessageLong(
          'Please Enter Transport Name', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }
    if (isValid && remarkstext.text.isEmpty) {
      CommonUtils.showCustomToastMessageLong(
          'Please Enter Return Order Remarks', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }
    if (isValid && _imageFile == null) {
      CommonUtils.showCustomToastMessageLong(
          'Please Upload LR Attachment', context, 1, 6);

      isValid = false;
      hasValidationFailed = true;
    }
    if (isValid && _imageFileorderreciept == null) {
      CommonUtils.showCustomToastMessageLong(
          'Please Upload Return Order Receipt ', context, 1, 6);

      isValid = false;
      hasValidationFailed = true;
    }
    if (isValid) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ReturnOrdersubmit_screen(
                  cardName: '${widget.cardName}',
                  cardCode: '${widget.cardCode}',
                  address: '${widget.address}',
                  state: '${widget.state}',
                  phone: '${widget.phone}',
                  proprietorName: '${widget.proprietorName}',
                  gstRegnNo: '${widget.gstRegnNo}',
                  LrNumber: LRNumberController.text,
                  Lrdate: DateController.text,
                  Remarks: remarkstext.text,
                  LRAttachment: base64Image,
                  ReturnOrderReceipt: base64Imageorderreciept,
                  addlattchments: base64Imageaddlattchments,
                  creditLine:
                      double.parse('${widget.creditLine}'), // Convert to double
                  balance: double.parse('${widget.balance}'),
                transportname : TransportController.text,
                )),
      );
    }
  }
}

// enum ImageSource {
//   camera,
//
//   /// Opens the user's photo gallery.
//   gallery,
// }
