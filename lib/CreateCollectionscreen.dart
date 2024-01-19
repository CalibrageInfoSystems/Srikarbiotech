import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikarbiotech/Payment_model.dart';
import 'package:srikarbiotech/categroy_model.dart';
import 'package:srikarbiotech/sb_status.dart';
import 'Common/CommonUtils.dart';
import 'HomeScreen.dart';
import 'OrctResponse.dart';

class CreateCollectionscreen extends StatefulWidget {
  final String cardName;
  final String cardCode;
  final String address;
  final String state;
  final String phone;
  final String proprietorName;
  final String gstRegnNo;


  CreateCollectionscreen(
      {required this.cardName, required this.cardCode, required this.address, required  this.state, required  this.phone,
        required  this.proprietorName, required  this.gstRegnNo});

  @override
  Createcollection_screen createState() => Createcollection_screen();
}

class Createcollection_screen extends State<CreateCollectionscreen> {
  TextEditingController DateController = TextEditingController();
  TextEditingController checkDateController = TextEditingController();
  TextEditingController Amounttext = TextEditingController();
  TextEditingController checknumbercontroller = TextEditingController();
  TextEditingController checkissuedbankcontroller = TextEditingController();
  TextEditingController accountnumcontroller = TextEditingController();
  TextEditingController creditbankcontroller = TextEditingController();
  String? userId;
  String? slpCode;
  File? _imageFile;
  PaymentMode? paymode;
  String? chooseDate = 'dd-mm-yyyy';
  String? checkDate = 'dd-mm-yyyy';
  DateTime selectedDate = DateTime.now();
  DateTime selectedCheckDate = DateTime.now();
  String? selectedValue;
  int selectedIndex = -1;
  bool isImageAdded = false;
  int indexselected = -1;
  String filename = '';
  String fileExtension = '';
  String base64Image = '';
  String ? Selected_PaymentMode = "";
  int? payid;
  List<PaymentMode> paymentmode = [];
  bool status = false;
  // Define a variable to store the selected paymode outside the build method
  PaymentMode? selectedPaymode;
  ApiResponse? apiResponse;
  String paymentname = "";
  int paymentid = 0;

  String? selectedPurpose;

  Purpose? selectedPurposeObj; // Declare it globally
  String? categroyname;
 // List of category names
  List<ItemGroup> itemGroups = []; // List of ItemGroup objects
  List<Purpose> purposeList = [];
  ItemGroup? selectedcategoryObj;
  String selectedItmsGrpCod = '';
  String selectedItmsGrpNam = '';
  bool isLoading = false;
  @override
  initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    print('cardName: ${widget.cardName}');
    print('cardCode: ${widget.cardCode}');
    print('address: ${widget.address}');
    print('gstRegnNo: ${widget.gstRegnNo}');
    print('proprietorName: ${widget.proprietorName}');

    CommonUtils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
getpaymentmethods();
selectedIndex = 0;
fetchdropdownitems();
getslpcode();
fetchdropdownitemscategory();


        print('The Internet Is Connected');
      } else {
        print('The Internet Is not  Connected');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFe78337),
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
                    child: Icon(
                      Icons.chevron_left,
                      size: 30.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                Text(
                  'Create Collection',
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
              child: Icon(
                Icons.home,
                size: 30,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.0),
                  CommonUtils.buildCard(
                    widget.cardName,
                    widget.cardCode,
                    widget.proprietorName,
                    widget.gstRegnNo,
                    widget.address,
                    Colors.white,
                    BorderRadius.circular(10.0),
                  ),
                  SizedBox(height: 16.0),
                  Card(
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: Colors.white,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildDateInput(
                            context,
                            ' Date',
                            DateController,
                                () => _selectDate(context, DateController),
                          ),

                          // From Date TextFormField with Calendar Icon
                          SizedBox(height: 5.0),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 10.0, left: 0.0, right: 0.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 0.0, left: 5.0, right: 0.0),
                                  child: Text(
                                    'Amount',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Color(0xFF5f5f5f),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                //  SizedBox(height: 8.0),
                                SizedBox(height: 4.0),
                                GestureDetector(
                                  onTap: () {
                                    // Handle the click event for the second text view
                                    print('first textview clicked');
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 55.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.0),
                                      border: Border.all(
                                        color: Color(0xFFe78337),
                                        width: 2,
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
                                                controller: Amounttext,
                                                keyboardType: TextInputType.number,
                                                maxLength: 10,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontFamily: 'Roboto',
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFFe78337),
                                                ),
                                                decoration: InputDecoration(
                                                  counterText: '',
                                                  hintText: 'Enter  Amount',
                                                  hintStyle: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: 'Roboto',
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFFe78337),
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
                          SizedBox(height: 5.0),
                          Padding(
                            padding: EdgeInsets.only(top: 10.0, left: 0.0, right: 0.0),
                            child: Text(
                              'Payment Mode',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF5f5f5f),
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Container(
                            height: 50,
                            child: Expanded(
                              child: apiResponse == null
                                  ? Center(child: CircularProgressIndicator())
                                  : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: apiResponse!.listResult.length,
                                itemBuilder: (BuildContext context, int index) {
                                  bool isSelected = index == indexselected;
                                  PaymentMode currentPaymode = apiResponse!.listResult[index]; // Store the current paymode in a local variable

                                  IconData iconData;
                                  switch (currentPaymode.desc) {
                                    case 'Cheque':
                                      iconData = Icons.payment;
                                      break;
                                    case 'Online':
                                      iconData = Icons.access_alarm;
                                      break;
                                    case 'UPI':
                                      iconData = Icons.payment;
                                      break;
                                  // Add more cases as needed
                                    default:
                                      iconData = Icons.payment; // Default icon
                                      break;
                                  }

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        indexselected = index;
                                        selectedPaymode = currentPaymode; // Update the selectedPaymode outside the build method
                                      });
                                      payid = currentPaymode.typeCdId;
                                      Selected_PaymentMode = currentPaymode.desc;
                                      print('payid:$payid');
                                      print('Selected Payment Mode: ${currentPaymode.desc}, TypeCdId: $payid');
                                      print('Selected Payment Mode: ${Selected_PaymentMode}, TypeCdId: $payid');
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                                      decoration: BoxDecoration(
                                        color: isSelected ? Color(0xFFe78337) : Colors.white,
                                        border: Border.all(
                                          color: isSelected ? Color(0xFFe78337) : Color(0xFFe78337),
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      child: IntrinsicWidth(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    iconData, // Use the dynamically determined icon
                                                    color: isSelected ? Colors.white : Colors.black,
                                                  ),
                                                  SizedBox(width: 8.0), // Add some spacing between icon and text
                                                  Text(
                                                    '${currentPaymode.desc.toString()}',
                                                    style: TextStyle(
                                                      color: isSelected ? Colors.white : Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 5.0),
                          Visibility(
                              visible:Selected_PaymentMode == 'Cheque',

                              child:
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 0.0, left: 5.0, right: 0.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 0.0, left: 5.0, right: 0.0),
                                      child: Text(
                                        'Check Number',
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          color: Color(0xFF5f5f5f),
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    GestureDetector(
                                      onTap: () {
                                        // Handle the click event for the second text view
                                        print('first textview clicked');
                                      },
                                      child: Container(

                                        width: MediaQuery.of(context).size.width,
                                        height: 55.0,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12.0),
                                          border: Border.all(
                                            color: Color(0xFFe78337),
                                            width: 2,
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
                                                    controller: checknumbercontroller,
                                                    keyboardType: TextInputType.number,
                                                    maxLength: 25,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontFamily: 'Roboto',
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xFFe78337),
                                                    ),
                                                    decoration: InputDecoration(
                                                      counterText: '',
                                                      hintText: 'XXXXXXXXXX',
                                                      hintStyle: TextStyle(
                                                        fontSize: 14,
                                                        fontFamily: 'Roboto',
                                                        fontWeight: FontWeight.w600,
                                                        color: Color(0xFFe78337),
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
                              )
                          ),
                          // Check Number
                          SizedBox(height: 5.0),
                          Visibility(

                            visible:Selected_PaymentMode == 'Cheque',

                            child:
                            buildDateInput(
                              context,
                              'Check Date ',
                              checkDateController,
                                  () => _selectcheckDate(context, checkDateController),
                            ),),
                          SizedBox(height: 5.0),
                          Visibility(
                              visible:Selected_PaymentMode == 'Cheque',
                              child:
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 10.0, left: 0.0, right: 0.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 0.0, left: 5.0, right: 0.0),
                                      child: Text(
                                        'Check Issued Bank',
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          color: Color(0xFF5f5f5f),
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                    //  SizedBox(height: 8.0),
                                    SizedBox(height: 4.0),
                                    GestureDetector(
                                      onTap: () {
                                        // Handle the click event for the second text view
                                        print('first textview clicked');
                                      },
                                      child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        height: 55.0,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12.0),
                                          border: Border.all(
                                            color: Color(0xFFe78337),
                                            width: 2,
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
                                                    controller:checkissuedbankcontroller ,
                                                    keyboardType:
                                                    TextInputType.name,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontFamily: 'Roboto',
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xFFe78337),
                                                    ),
                                                    decoration: InputDecoration(
                                                      hintText: 'Enter Issued Bank',
                                                      hintStyle: TextStyle(
                                                        fontSize: 14,
                                                        fontFamily: 'Roboto',
                                                        fontWeight: FontWeight.w600,
                                                        color: Color(0xFFe78337),
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
                              )),
                          SizedBox(height: 5.0),
                          Visibility(
                              visible:Selected_PaymentMode == 'Online',
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: 10.0, left: 0.0, right: 0.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 0.0, left: 5.0, right: 0.0),
                                      child: Text(
                                        'Credit Account No',
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          color: Color(0xFF5f5f5f),
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                      SizedBox(height: 4.0),
                                    GestureDetector(
                                      onTap: () {
                                        // Handle the click event for the second text view
                                        print('first textview clicked');
                                      },
                                      child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        height: 55.0,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12.0),
                                          border: Border.all(
                                            color: Color(0xFFe78337),
                                            width: 2,
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
                                                    controller:accountnumcontroller ,
                                                    keyboardType:
                                                    TextInputType.number,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontFamily: 'Roboto',
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xFFe78337),
                                                    ),
                                                    decoration: InputDecoration(
                                                      hintText:
                                                      'Enter Credit Account No',
                                                      hintStyle: TextStyle(
                                                        fontSize: 14,
                                                        fontFamily: 'Roboto',
                                                        fontWeight: FontWeight.w600,
                                                        color: Color(0xFFe78337),
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
                              )),
                          SizedBox(height: 5.0),
                          Visibility(
                              visible:Selected_PaymentMode == 'Online',
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: 10.0, left: 0.0, right: 0.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 0.0, left: 5.0, right: 0.0),
                                      child: Text(
                                        'Credit Bank',
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          color: Color(0xFF5f5f5f),
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                     SizedBox(height: 4.0),
                                    GestureDetector(
                                      onTap: () {
                                        // Handle the click event for the second text view
                                        print('first textview clicked');
                                      },
                                      child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        height: 55.0,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12.0),
                                          border: Border.all(
                                            color: Color(0xFFe78337),
                                            width: 2,
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
                                                    controller: creditbankcontroller,
                                                    keyboardType:
                                                    TextInputType.name,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontFamily: 'Roboto',
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xFFe78337),
                                                    ),
                                                    decoration: InputDecoration(
                                                      hintText: 'Enter Credit Bank',
                                                      hintStyle: TextStyle(
                                                        fontSize: 14,
                                                        fontFamily: 'Roboto',
                                                        fontWeight: FontWeight.w600,
                                                        color: Color(0xFFe78337),
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
                              )),
                          SizedBox(height: 5.0),
                          Visibility(
                              visible:Selected_PaymentMode == 'Online',
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: 10.0, left: 0.0, right: 0.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 0.0, left: 5.0, right: 0.0),
                                      child: Text(
                                        'UTR Number',
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          color: Color(0xFF5f5f5f),
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w600,

                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                   SizedBox(height: 5.0),
                                    GestureDetector(
                                      onTap: () {
                                        // Handle the click event for the second text view
                                        print('first textview clicked');
                                      },
                                      child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        height: 55.0,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12.0),
                                          border: Border.all(
                                            color: Color(0xFFe78337),
                                            width: 2,
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
                                                    keyboardType:
                                                    TextInputType.name,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontFamily: 'Roboto',
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xFFe78337),
                                                    ),
                                                    decoration: InputDecoration(
                                                      hintText: 'Enter UTR Number',
                                                      hintStyle: TextStyle(
                                                        fontSize: 14,
                                                        fontFamily: 'Roboto',
                                                        fontWeight: FontWeight.w600,
                                                        color: Color(0xFFe78337),
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
                              )),
                          // Download and Share buttons



                          // Purpose
                          Padding(
                            padding:
                            EdgeInsets.only(top: 0.0, left: 0.0, right: 0.0),
                            child: Text(
                              'Purpose',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Color(0xFF5f5f5f),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          GestureDetector(
                            onTap: () {
                              // Handle the click event for the container
                              print('Container clicked');
                            },
                            child:
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 55.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: Color(0xFFe78337),
                                  width: 2,
                                ),
                              ),
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: purposeList.isEmpty
                                  ? CircularProgressIndicator() // Show a loading indicator
                                  : DropdownButton<String>(
                                hint: Text(
                                  'Select Purpose',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFe78337),
                                  ),
                                ),
                                value: selectedPurpose,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedPurpose = newValue;

                                    // Find the selected Purpose object
                                    selectedPurposeObj = purposeList.firstWhere(
                                          (purpose) => purpose.fldValue == newValue,
                                      orElse: () => Purpose(fldValue: '', descr: '', purposeName: ''),
                                    );

                                    // Print the selected values
                                    print('fldValue: ${selectedPurposeObj?.fldValue}');
                                    print('descr: ${selectedPurposeObj?.descr}');
                                    print('purposeName: ${selectedPurposeObj?.purposeName}');
                                  });
                                },
                                items: purposeList.map((Purpose purpose) {
                                  return DropdownMenuItem<String>(
                                    value: purpose.fldValue,
                                    child: Text(
                                      purpose.purposeName,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFe78337),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                icon: Icon(Icons.arrow_drop_down),
                                iconSize: 24,
                                isExpanded: true,
                                underline: SizedBox(),
                              ),
                            )
                          ),
                          ),

                          SizedBox(height: 4.0),

                          Padding(
                            padding:
                            EdgeInsets.only(top: 0.0, left: 0.0, right: 0.0),
                            child: Text(
                              'Category',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Color(0xFF5f5f5f),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          GestureDetector(
                              onTap: () {
                                // Handle the click event for the container
                                print('Container clicked');
                              },
                              child:
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: 55.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: Color(0xFFe78337),
                                    width: 2,
                                  ),
                                ),
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0), // Adjust the padding as needed
                                child: itemGroups.isEmpty
                                    ? CircularProgressIndicator() // Show a loading indicator
                                    : DropdownButton<String>(
                                  hint: Text(
                                    'Select Category',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFe78337),
                                    ),
                                  ),
                                  value: categroyname,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      categroyname = newValue;

                                      // Find the selected Purpose object
                                      selectedcategoryObj = itemGroups.firstWhere(
                                            (category) => category.itmsGrpNam == newValue,
                                        orElse: () => ItemGroup(itmsGrpCod: '', itmsGrpNam: '', itemClass: ''),
                                      );

                                      // Print the selected values
                                      print('itmsGrpCod: ${selectedcategoryObj?.itmsGrpCod}');
                                      print('itmsGrpNam: ${selectedcategoryObj?.itmsGrpNam}');

                                    });
                                  },
                                  items: itemGroups.map((ItemGroup category) {
                                    return DropdownMenuItem<String>(
                                      value: category.itmsGrpNam,
                                      child: Text(
                                        category.itmsGrpNam,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFe78337),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  icon: Icon(Icons.arrow_drop_down),
                                  iconSize: 24,
                                  isExpanded: true,
                                  underline: SizedBox(),
                                ),
                              )
                          ),

                          ),
                          Padding(
                            padding:
                            EdgeInsets.only(top: 10.0, left: 0.0, right: 0.0),
                            child: Text(
                              'Attachment',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Color(0xFF5f5f5f),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          SizedBox(height: 4.0),

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
                              child: DottedBorder(
                                borderType: BorderType.RRect,
                                color: Color(0xFFe78337),
                                padding: const EdgeInsets.only(top: 0, bottom: 0.0),
                                strokeWidth: 2,
                                child: Container(
                                  //padding: const EdgeInsets.all(15),
                                  // margin: const EdgeInsets.only(top: 3, bottom: 15),
                                  //   height: 70,
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.all(10.0),

                                  decoration: BoxDecoration(
//                                borderRadius: BorderRadius.circular(12.0),

                                    color: HexColor('#ffeee0'),
                                    //  borderRadius: BorderRadius.circular(10),
                                    // border: Border.all(
                                    //   color: _orangeColor,
                                    //   width:      1, // You can adjust the width of the border as needed
                                    //   //style: BorderStyle.solid, // Use dotted style
                                    // ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        // margin: const EdgeInsets.only(bottom: 5),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFe78337),
                                          borderRadius: BorderRadius.circular(10),
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
                          ),
                          SizedBox(height: 10.0),


                          GestureDetector(
                            onTap: () {
                              // Handle tap on uploaded image to remove it
                              setState(() {
                                _imageFile =
                                null; // Set _imageFile to null to remove the image
                              });
                            },
                            child: SizedBox(
                              width: _imageFile != null
                                  ? MediaQuery.of(context).size.width
                                  : MediaQuery.of(context).size.width,
                              height: _imageFile != null ? 100 : 0,
                              child: Stack(
                                alignment: Alignment.topRight,
                                // Align cross mark icon to the top right
                                children: [
                                  _imageFile != null
                                      ? Image.file(
                                    _imageFile!,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.fitWidth,
                                  )
                                      : Image.asset(
                                    'assets/shopping_bag.png',
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.fitWidth,
                                  ),
                                  if (_imageFile != null)
                                    GestureDetector(
                                      onTap: () {
                                        // Handle tap on cross mark icon (optional)
                                        setState(() {
                                          _imageFile = null; // Set _imageFile to null to remove the image
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(5.0),
                                        margin:
                                        EdgeInsets.only(top: 5, right: 10.0),
                                        color: HexColor(
                                            '#ffeee0'), // Optional overlay color
                                        child: SvgPicture.asset(
                                          'assets/crosscircle.svg',
                                          color: Color(0xFFe78337),
                                          width: 24.0, // Set the width as needed
                                          height: 24.0, // Set the height as needed
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          // Submit Button
                          SizedBox(height: 18.0),

                          // Submit Button
                          Container(
                              padding: const EdgeInsets.all(10),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0xFFe78337),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  // Call Submit submit function or perform the desired action here
                                  print('Submit button clicked');
                                  AddUpdateCollections(context);
                                },
                                child: Center(
                                  child: Text(
                                    'Submit',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                          ),

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> AddUpdateCollections(BuildContext context) async {

    bool isValid = true;
    bool hasValidationFailed = false;
    DateTime currentDate = DateTime.now();

    // Format the date as 'yyyy-MM-dd'
    String formattedcurrentDate = DateFormat('yyyy-MM-dd').format(currentDate);
    print('Formatted Date: $formattedcurrentDate');

    String selecteddate = DateFormat('yyyy-MM-dd').format(selectedDate);
    String checkdate = DateFormat('yyyy-MM-dd').format(selectedCheckDate);
    print('Formatted Date: $selecteddate');
    print('Formatted Date: $checkdate');



    if (isValid && DateController.text.isEmpty) {
      CommonUtils.showCustomToastMessageLong(
          'Please Select  Date', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }

    if (isValid && Amounttext.text.isEmpty) {
      CommonUtils.showCustomToastMessageLong(
          'Please Enter Amount', context, 1, 6);

      isValid = false;
      hasValidationFailed = true;
    }
    // if (isValid && checknumbercontroller.text.isEmpty) {
    //   CommonUtils.showCustomToastMessageLong(
    //       'Please Enter check Number', context, 1, 6);
    //
    //   isValid = false;
    //   hasValidationFailed = true;
    // }
    // if (isValid && checkDateController.text.isEmpty) {
    //   CommonUtils.showCustomToastMessageLong(
    //       'Please Select Check Date', context, 1, 4);
    //   isValid = false;
    //   hasValidationFailed = true;
    // }
    // if (isValid && checkissuedbankcontroller.text.isEmpty) {
    //   CommonUtils.showCustomToastMessageLong(
    //       'Please Enter Check Issued Bank', context, 1, 6);
    //
    //   isValid = false;
    //   hasValidationFailed = true;
    // }

    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> requestData = {

      "Id": "",
      "Date": selecteddate,
      "SlpCode": '$slpCode',
      "PartyCode": '${widget.cardCode}',
      "PartyName": '${widget.cardName}',
      "Address": '${widget.address}',
      "StateName": '${widget.state}',
      "PhoneNumber": '${widget.phone}',
      "Amount": Amounttext.text,
      "PaymentType": '$payid',
      "PaymentTypeName": Selected_PaymentMode,
      "PurposeValue": '${selectedPurposeObj?.fldValue}',
      "PurposeDesc": '${selectedPurposeObj?.descr}',
      "Category": '${selectedcategoryObj?.itmsGrpCod}',
      "CategoryName": '${selectedcategoryObj?.itmsGrpNam}',
      "CheckNumber": checknumbercontroller.text,
      "CheckDate": checkdate,
      "CheckIssuedBank": checkissuedbankcontroller.text,
      // Default values for Online payment mode
      "CreditAccountNo": "",
      "CreditBank": "",
      "UTRNumber": "",
      if (Selected_PaymentMode == 'Online') ...{
        "CreditAccountNo": accountnumcontroller.text,
        "CreditBank": creditbankcontroller.text,
      },
      "FileName": filename,
      "FileLocation": "",
      "FileExtension": fileExtension,
      "Remarks": "",
      "CompanyId": 2,
      "StatusTypeId": 7,
      "IsActive": true,
      "CreatedBy": '$userId',
      "CreatedDate": formattedcurrentDate,
      "UpdatedBy": '$userId',
      "UpdatedDate": formattedcurrentDate,
      "PartyGSTNumber":'${widget.gstRegnNo}',
     "ProprietorName":'${widget.proprietorName}',
      "FileString": '$base64Image'

    };

    print(requestData);
    print(jsonEncode(requestData));
    // URL for the API endpoint
    String apiUrl = "http://182.18.157.215/Srikar_Biotech_Dev/API/api/Collections/AddUpdateCollections";

    // Encode the JSON data
    String requestBody = jsonEncode(requestData);

    // Set up the headers
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    try {
      // Make the HTTP POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: requestBody,
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Handle the response here (e.g., print or process the data)
        Map<String, dynamic> responseData = json.decode(response.body);

        print("Response: ${response.body}");
        setState(() {
          isLoading = false;
        });
        bool isSuccessFromApi = responseData['isSuccess'];

        if (isSuccessFromApi) {
          // Navigate to the next screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StatusScreen()),
          );
        }
        else{
          CommonUtils.showCustomToastMessageLong(
              'Error', context, 1, 6);
        }
        //  CommonUtils.showCustomToastMessageLong(' Successfully', context, 0, 4);
      } else {
        // Handle the error if the request was not successful
        print("Error: ${response.statusCode}, ${response.reasonPhrase}");
      }
    } catch (error) {
      // Handle any exceptions that may occur during the request
      print("Error: $error");
      setState(() {
        isLoading = false;
      });
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
          padding: EdgeInsets.only(top: 10.0, left: 5.0, right: 0.0),
          child: Text(
            labelText,
            style: TextStyle(
              fontSize: 12.0,
              color: Color(0xFF5f5f5f),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
        ),
        SizedBox(height: 8.0), // Add space between labelText and TextFormField
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 55.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: Color(0xFFe78337),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0, top: 0.0),
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
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFe78337),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.calendar_today,
                      color: Color(0xFFe78337),
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


  Future<void> _selectcheckDate(
      BuildContext context,
      TextEditingController controller,
      ) async {
    DateTime currentDate = DateTime.now();
    DateTime initialDate;

    if (controller.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(controller.text);
      } catch (e) {
        // Handle the case where the current text is not a valid date format
        print("Invalid date format: $e");
        initialDate = currentDate;
      }
    } else {
      initialDate = currentDate;
    }

    try {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (picked != null) {
        String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
        controller.text = formattedDate;

        // Save selected dates as DateTime objects
        selectedCheckDate = picked;
        print("Selected check Date: $selectedCheckDate");


        // Print formatted date
        print("Selected check Date: ${DateFormat('yyyy-MM-dd').format(picked)}");
      }
    } catch (e) {
      print("Error selecting date: $e");
      // Handle the error, e.g., show a message to the user or log it.
    }
  }

  Future<void> _selectDate(
      BuildContext context,
      TextEditingController controller,
      ) async {
    DateTime currentDate = DateTime.now();
    DateTime initialDate;

    if (controller.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(controller.text);
      } catch (e) {
        // Handle the case where the current text is not a valid date format
        print("Invalid date format: $e");
        initialDate = currentDate;
      }
    } else {
      initialDate = currentDate;
    }

    try {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (picked != null) {
        String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
        controller.text = formattedDate;

        // Save selected dates as DateTime objects
        selectedDate = picked;
        print("Selected  Date: $selectedDate");


        // Print formatted date
        print("Selected  Date: ${DateFormat('yyyy-MM-dd').format(picked)}");
      }
    } catch (e) {
      print("Error selecting date: $e");
      // Handle the error, e.g., show a message to the user or log it.
    }
  }


  Future<void> getslpcode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

// Retrieve userId and slpCode
    userId = prefs.getString("userId");
    slpCode = prefs.getString("slpCode");

// Check if they are not null before using them
    if (userId != null && slpCode != null) {
      // Use userId and slpCode in your code
      print('Retrieved userId: $userId');
      print('Retrieved slpCode: $slpCode');

    } else {
      // Handle the case where userId or slpCode is null
      print('User not logged in or missing required data.');
    }
  }
  Future<void> getpaymentmethods() async {
    final response = await http.get(Uri.parse('http://182.18.157.215/Srikar_Biotech_Dev/API/api/Master/GetAllTypeCdDmt/2'));

    if (response.statusCode == 200) {
      setState(() {
        apiResponse = ApiResponse.fromJson(jsonDecode(response.body));
        print('========>apiResponse$apiResponse');
      });
    } else {
      throw Exception('Failed to load data');
    }
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




  Future<void> fetchdropdownitems() async {
    final apiUrl = 'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Collections/GetPurposes';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final listResult = data['response']['listResult'] as List;

        setState(() {
          purposeList = listResult.map((item) => Purpose.fromJson(item)).toList();
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  Future<void> fetchdropdownitemscategory() async {
    final apiUrl = 'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Item/GetItemGroups/null';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('response') &&
            responseData['response'].containsKey('listResult') &&
            responseData['isSuccess']) {
          setState(() {
            itemGroups = (responseData['response']['listResult'] as List)
                .map((item) => ItemGroup.fromJson(item))
                .toList();
          });
        } else {
          print('Unexpected response format or unsuccessful request.');
        }
      } else {
        print('Error: ${response.statusCode}, ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}

