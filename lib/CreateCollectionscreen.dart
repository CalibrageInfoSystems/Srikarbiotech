import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path/path.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikarbiotech/Model/account_modal.dart';
import 'package:srikarbiotech/Payment_model.dart';
import 'package:srikarbiotech/Services/api_config.dart';
import 'package:srikarbiotech/categroy_model.dart';
import 'package:srikarbiotech/sb_status.dart';
import 'Common/CommonUtils.dart';
import 'Common/SharedPrefsData.dart';
import 'HomeScreen.dart';
import 'Model/VirtualCodeItem.dart';

import 'OrctResponse.dart';

class CreateCollectionscreen extends StatefulWidget {
  final String cardName;
  final String cardCode;
  final String address;
  final String state;
  final String phone;
  final String proprietorName;
  final String gstRegnNo;
  final String code;

  const CreateCollectionscreen({super.key, required this.cardName, required this.code, required this.cardCode, required this.address, required this.state, required this.phone, required this.proprietorName, required this.gstRegnNo});

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
  TextEditingController utrcontroller = TextEditingController();
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
  bool isButtonEnabled = true;
  String filename = '';
  String fileExtension = '';
  String base64Image = '';
  String? Selected_PaymentMode = "Online";
  int? payid;
  List<PaymentMode> paymentmode = [];
  bool status = false;
  // Define a variable to store the selected paymode outside the build method
  PaymentMode? selectedPaymode;
  ApiResponse? apiResponse;
  String paymentname = "";
  int paymentid = 0;
  String? accountValue;
  String? accountno;
  String? bankcode;
  String? bankbranch;
  String? selectedPurpose;

  Purpose? selectedPurposeObj; // Declare it globally
  String? categroyname;
  // List of category names
  List<ItemGroup> itemGroups = []; // List of ItemGroup objects
  List<Purpose> purposeList = [];
  List<AccountList> accountList = [];
  String? virtualcodeValue;
  List<VirtualCodeItem> VirtualModelList = [];

  ItemGroup? selectedcategoryObj;
  String selectedItmsGrpCod = '';
  String selectedItmsGrpNam = '';
  bool isLoading = false;
  int CompneyId = 0;
  int indexselected = 0;
  String? Compneyname;
  @override
  initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    getshareddata();
    DateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    CommonUtils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        getpaymentmethods();
        selectedIndex = 0;
        fetchdropdownitems();
        fetchvirtualcode();
        print('srikarcode${widget.code}');
        fetchdropdownitemscategory();
        getAccountsData();
      } else {
        print('The Internet Is not  Connected');
      }
    });
  }

  Future<void> fetchvirtualcode() async {
    final apiurl = baseUrl + GetVirtualCode + CompneyId.toString() + "/" + '${widget.code}';
    print('Virtual code API URL: $apiurl'); // Add this print statement

    try {
      final response = await http.get(Uri.parse(apiurl));
      print('Response status code: ${response.statusCode}'); // Add this print statement

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        debugPrint('====jsonResponse $jsonResponse');
        List<dynamic> resultList = jsonResponse['response']['listResult'];
        VirtualModelList = resultList.map((account) => VirtualCodeItem.fromJson(account)).toList();
        debugPrint('====VirtualModelList $VirtualModelList');
        print('Virtual Model List Size: ${VirtualModelList.length}');
      } else {
        debugPrint('Error: API failed with status code ${response.statusCode}');
        throw Exception('Error: API failed with status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception occurred: $e');
      throw Exception('Exception occurred: $e');
    }
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
                  'Create Collection',
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
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    },
                    child: Image.asset(
                      CompneyId == 1 ? 'assets/srikar-home-icon.png' : 'assets/seeds-home-icon.png',
                      width: 30,
                      height: 30,
                    ),
                  );
                } else {
                  // Return a placeholder or loading indicator
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8.0),
                  CommonUtils.buildCard(
                    widget.cardName,
                    widget.cardCode,
                    widget.proprietorName,
                    widget.gstRegnNo,
                    widget.address,
                    Colors.white,
                    BorderRadius.circular(5.0),
                  ),
                  const SizedBox(height: 16.0),
                  Card(
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    // color: Colors.white,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.white,

                        // color: Colors.white
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildDateInput(
                            context,
                            ' Date *',
                            DateController,
                            () => _selectDate(context, DateController),
                          ),

                          // From Date TextFormField with Calendar Icon
                          const SizedBox(height: 5.0),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0, left: 0.0, right: 0.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 0.0, left: 5.0, right: 0.0),
                                  child: Text(
                                    'Amount * ',
                                    style: CommonUtils.Mediumtext_12,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                GestureDetector(
                                  onTap: () {
                                    // Handle the click event for the second text view
                                    print('first textview clicked');
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 55.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(
                                        color: const Color(0xFFe78337),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 10.0, top: 0.0),
                                              child: TextFormField(
                                                controller: Amounttext,
                                                keyboardType: TextInputType.number,
                                                maxLength: 10,
                                                style: CommonUtils.Mediumtext_o_14,
                                                decoration: const InputDecoration(
                                                  counterText: '',
                                                  hintText: 'Enter  Amount',
                                                  hintStyle: CommonUtils.hintstyle_o_14,
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
                          const Padding(
                            padding: EdgeInsets.only(top: 10.0, left: 5.0, right: 0.0),
                            child: Text(
                              'Payment Mode * ',
                              style: CommonUtils.Mediumtext_12,
                              textAlign: TextAlign.start,
                            ),
                          ),
                          const SizedBox(height: 5.0),

                          SizedBox(
                            height: 40,
                            // child: Expanded(
                            child: apiResponse == null
                                ? Center(child: CommonUtils.showProgressIndicator())
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: apiResponse!.listResult.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      bool isSelected = index == indexselected;
                                      PaymentMode currentPaymode = apiResponse!.listResult[index]; // Store the current paymode in a local variable

                                      String iconData;
                                      switch (currentPaymode.desc) {
                                        case 'Online':
                                          iconData = 'assets/site-alt.svg';
                                          break;
                                        case 'Cheque':
                                          iconData = 'assets/money-bills.svg';
                                          break;
                                        // Add more cases as needed
                                        default:
                                          iconData = 'assets/money-bills.svg'; // Default icon
                                          break;
                                      }
                                      if (isSelected) {
                                        print('Default selected item: ${currentPaymode.desc}, TypeCdId: ${currentPaymode.typeCdId}');
                                        payid = currentPaymode.typeCdId;
                                        Selected_PaymentMode = currentPaymode.desc;
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
                                          print('Selected Payment Mode: $Selected_PaymentMode, TypeCdId: $payid');
                                          if (Selected_PaymentMode == 'Online') {
                                            checknumbercontroller.text = "";
                                            checkissuedbankcontroller.text = "";
                                            checkDateController.text = "";
                                          }
                                          if (Selected_PaymentMode == 'Cheque') {

                                            utrcontroller.text = "";
                                            setState(() {
                                              accountValue = null;
                                              virtualcodeValue =  null;
                                            });
                                          }
                                        },
                                        child: Container(
                                          // color: Color(0xFFF8dac2),

                                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                          decoration: BoxDecoration(
                                            color: isSelected ? const Color(0xFFe78337) : const Color(0xFFF8dac2),
                                            border: Border.all(
                                              color: isSelected ? const Color(0xFFe78337) : const Color(0xFFe78337),
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          child: IntrinsicWidth(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                  child: Row(
                                                    children: [
                                                      SvgPicture.asset(
                                                        iconData,
                                                        height: 18,
                                                        width: 18,
                                                        fit: BoxFit.fitWidth,
                                                        color: isSelected ? Colors.white : Colors.black,
                                                      ),
                                                      const SizedBox(width: 8.0), // Add some spacing between icon and text
                                                      Text(
                                                        currentPaymode.desc.toString(),
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

                          Visibility(
                            visible: Selected_PaymentMode == 'Online',
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15.0, left: 0.0, right: 0.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 0.0, left: 5.0, right: 0.0),
                                    child: Text(
                                      'Virtual Bank Code *',
                                      style: CommonUtils.Mediumtext_12,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  GestureDetector(
                                    onTap: () {
                                      // Handle the click event for the second text view
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 55.0,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8.0),
                                        border: Border.all(
                                          color: const Color(0xFFe78337),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 10.0, top: 0.0),

                                                child: VirtualModelList.length == 0
                                                    ? LoadingAnimationWidget.newtonCradle(
                                                        color: Colors.blue,
                                                        size: 40.0,
                                                      )
                                                    : DropdownButton<String>(
                                                        hint: Text(
                                                          'Select Virtual Bank Code',
                                                          style: TextStyle(
                                                          fontSize: 14,
                                                          fontFamily: 'Roboto',
                                                          fontWeight: FontWeight.w700,
                                                          color: Color(0xa0e78337),
                                                        ),
                                                        ),

                                                        value: virtualcodeValue, // String? accountValue;
                                                        onChanged: (String? newValue) {
                                                          setState(() {
                                                            virtualcodeValue = newValue;
                                                            accountValue = null;
                                                            print('Selected Virtual Code: ${virtualcodeValue}');
                                                            VirtualCodeItem selectedModel = VirtualModelList.firstWhere((model) => model.virtualCode == newValue);
                                                            //print('Selected Virtual Code: ${selectedModel.virtualCode}');
                                                          });
                                                        },
                                                        items: VirtualModelList.map((VirtualCodeItem model) {
                                                          return DropdownMenuItem<String>(
                                                            value: model.virtualCode,
                                                            child: Text(
                                                              '${model.virtualCode}',
                                                              style: CommonUtils.txSty_13O_F6,
                                                            ),
                                                          );
                                                        }).toList(),
                                                        icon: const Icon(Icons.arrow_drop_down),
                                                        iconSize: 20,
                                                        isExpanded: true,
                                                        underline: const SizedBox(),
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
                          ),
                          if (virtualcodeValue == 'Other')
                            // account
                            Visibility(
                                visible: Selected_PaymentMode == 'Online',
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 15.0, left: 0.0, right: 0.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(top: 0.0, left: 5.0, right: 0.0),
                                        child: Text(
                                          'Account Number *',
                                          style: CommonUtils.Mediumtext_12,
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      GestureDetector(
                                        onTap: () {
                                          // Handle the click event for the second text view
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: 55.0,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8.0),
                                            border: Border.all(
                                              color: const Color(0xFFe78337),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 10.0, top: 0.0),
                                                    child: accountList.isEmpty
                                                        ? LoadingAnimationWidget.newtonCradle(
                                                            color: Colors.blue,
                                                            size: 40.0,
                                                          )
                                                        : DropdownButton<String>(
                                                            hint: Text(
                                                              'Select Account Number',
                                                              style:  TextStyle(
                                                              fontSize: 14,
                                                              fontFamily: 'Roboto',
                                                              fontWeight: FontWeight.w700,
                                                              color: Color(0xa0e78337),
                                                            ),
                                                            ),
                                                            value: accountValue, // String? accountValue;
                                                            onChanged: (String? newValue) {
                                                              setState(() {
                                                                accountValue = newValue;
                                                                AccountList accounts = accountList.firstWhere((account) => account.bankCode == newValue);
                                                                accountno = accounts.account;
                                                                bankcode = accounts.bankCode;
                                                                bankbranch = accounts.branch;
                                                                print('Selected Account code details: ${accounts.account}, bankCode: ${accounts.bankCode} , branch: ${accounts.branch}');
                                                              });
                                                            },
                                                            items: accountList.map((AccountList account) {
                                                              return DropdownMenuItem<String>(
                                                                value: account.bankCode,
                                                                child: Text(
                                                                  '${account.account} (${account.bankCode})',
                                                                  style: CommonUtils.txSty_13O_F6,
                                                                ),
                                                              );
                                                            }).toList(),
                                                            icon: const Icon(Icons.arrow_drop_down),
                                                            iconSize: 20,
                                                            isExpanded: true,
                                                            underline: const SizedBox(),
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

                          Visibility(
                              visible: Selected_PaymentMode == '#Online',
                              child: Padding(
                                padding: const EdgeInsets.only(top: 15.0, left: 0.0, right: 0.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 0.0, left: 5.0, right: 0.0),
                                      child: Text(
                                        'Credit Account No *',
                                        style: CommonUtils.Mediumtext_12,
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    GestureDetector(
                                      onTap: () {
                                        // Handle the click event for the second text view
                                        print('first textview clicked');
                                      },
                                      child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        height: 55.0,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8.0),
                                          border: Border.all(
                                            color: const Color(0xFFe78337),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 10.0, top: 0.0),
                                                  child: TextFormField(
                                                    controller: accountnumcontroller,
                                                    keyboardType: TextInputType.number,
                                                    maxLength: 20,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontFamily: 'Roboto',
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xFFe78337),
                                                    ),
                                                    decoration: const InputDecoration(
                                                      counterText: '',
                                                      hintText: 'Enter Credit Account No',
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
                              )),
                          //  SizedBox(height: 5.0),
                          Visibility(
                              visible: Selected_PaymentMode == '#Online',
                              child: Padding(
                                padding: const EdgeInsets.only(top: 15.0, left: 0.0, right: 0.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 0.0, left: 5.0, right: 0.0),
                                      child: Text(
                                        'Credit Bank *',
                                        style: CommonUtils.Mediumtext_12,
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    GestureDetector(
                                      onTap: () {
                                        // Handle the click event for the second text view
                                        print('first textview clicked');
                                      },
                                      child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        height: 55.0,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8.0),
                                          border: Border.all(
                                            color: const Color(0xFFe78337),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 10.0, top: 0.0),
                                                  child: TextFormField(
                                                    controller: creditbankcontroller,
                                                    keyboardType: TextInputType.name,
                                                    maxLength: 25,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontFamily: 'Roboto',
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xFFe78337),
                                                    ),
                                                    decoration: const InputDecoration(
                                                      counterText: '',
                                                      hintText: 'Enter Credit Bank',
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
                              )),
                          //  SizedBox(height: 5.0),
                          Visibility(
                              visible: Selected_PaymentMode == 'Online',
                              child: Padding(
                                padding: const EdgeInsets.only(top: 15.0, left: 0.0, right: 0.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 0.0, left: 5.0, right: 0.0),
                                      child: Text(
                                        'UTR Number *',
                                        style: CommonUtils.Mediumtext_12,
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    GestureDetector(
                                      onTap: () {
                                        // Handle the click event for the second text view
                                        print('first textview clicked');
                                      },
                                      child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        height: 55.0,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8.0),
                                          border: Border.all(
                                            color: const Color(0xFFe78337),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 10.0, top: 0.0),
                                                  child: TextFormField(
                                                    controller: utrcontroller,
                                                    keyboardType: TextInputType.name,
                                                    maxLength: 25,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontFamily: 'Roboto',
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xFFe78337),
                                                    ),
                                                    decoration: const InputDecoration(
                                                      counterText: '',
                                                      hintText: 'Enter UTR Number',
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
                              )),
                          //   ),
                          //  SizedBox(height: 5.0),
                          Visibility(
                              visible: Selected_PaymentMode == 'Cheque',
                              child: Padding(
                                padding: const EdgeInsets.only(top: 15.0, left: 0.0, right: 0.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 0.0, left: 5.0, right: 0.0),
                                      child: Text(
                                        'Check Number',
                                        style: CommonUtils.Mediumtext_12,
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    GestureDetector(
                                      onTap: () {
                                        // Handle the click event for the second text view
                                        print('first textview clicked');
                                      },
                                      child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        height: 55.0,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8.0),
                                          border: Border.all(
                                            color: const Color(0xFFe78337),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 10.0, top: 0.0),
                                                  child: TextFormField(
                                                    controller: checknumbercontroller,
                                                    keyboardType: TextInputType.number,
                                                    maxLength: 25,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontFamily: 'Roboto',
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xFFe78337),
                                                    ),
                                                    decoration: const InputDecoration(
                                                      counterText: '',
                                                      hintText: 'XXXXXXXXXX',
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
                              )),
                          // Check Number
                          //    SizedBox(height: 5.0),

                          Visibility(
                            visible: Selected_PaymentMode == 'Cheque',
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15.0, bottom: 0.0), // Adjust the padding as needed
                              child: buildDateInput(
                                context,
                                'Check Date *',
                                checkDateController,
                                () => _selectcheckDate(context, checkDateController),
                              ),
                            ),
                          ),

                          //  SizedBox(height: 5.0),
                          Visibility(
                              visible: Selected_PaymentMode == 'Cheque',
                              child: Padding(
                                padding: const EdgeInsets.only(top: 15.0, left: 0.0, right: 0.0, bottom: 5.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 0.0, left: 5.0, right: 0.0),
                                      child: Text(
                                        'Check Issued Bank *',
                                        style: CommonUtils.Mediumtext_12,
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                    //  SizedBox(height: 8.0),
                                    const SizedBox(height: 8.0),
                                    GestureDetector(
                                      onTap: () {
                                        // Handle the click event for the second text view
                                        print('first textview clicked');
                                      },
                                      child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        height: 55.0,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8.0),
                                          border: Border.all(
                                            color: const Color(0xFFe78337),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 10.0, top: 0.0),
                                                  child: TextFormField(
                                                    controller: checkissuedbankcontroller,
                                                    keyboardType: TextInputType.name,
                                                    maxLength: 25,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontFamily: 'Roboto',
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xFFe78337),
                                                    ),
                                                    decoration: const InputDecoration(
                                                      counterText: '',
                                                      hintText: 'Enter Issued Bank',
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
                              )),

                          // Download and Share buttons

                          // Purpose
                          const Padding(
                            padding: EdgeInsets.only(top: 10.0, left: 5.0, right: 0.0),
                            child: Text(
                              'Purpose *',
                              style: CommonUtils.Mediumtext_12,
                              textAlign: TextAlign.start,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          GestureDetector(
                            onTap: () {
                              // Handle the click event for the container
                              print('Container clicked');
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 55.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color: const Color(0xFFe78337),
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: purposeList.isEmpty
                                      ? LoadingAnimationWidget.newtonCradle(
                                          color: Colors.blue, // Set the color as needed
                                          size: 40.0,
                                        ) // Show a loading indicator
                                      : DropdownButton<String>(
                                          hint: const Text(
                                            'Select Purpose',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xa0e78337),
                                            ),
                                          ),
                                          value: selectedPurpose,
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              selectedPurpose = newValue;

                                              // Find the selected Purpose object
                                              selectedPurposeObj = purposeList.firstWhere(
                                                (purpose) => purpose.fldValue == newValue,
                                                orElse: () => Purpose(
                                                  fldValue: '',
                                                  descr: '',
                                                  purposeName: '',
                                                ),
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
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontFamily: 'Roboto',
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFFe78337),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          icon: const Icon(Icons.arrow_drop_down),
                                          iconSize: 24,
                                          isExpanded: true,
                                          underline: const SizedBox(),
                                        ),
                                )),
                          ),

                          SizedBox(height: 5.0),

                          Padding(
                            padding: EdgeInsets.only(top: 10.0, left: 5.0, right: 0.0),
                            child: Text(
                              'Category * ',
                              style: CommonUtils.Mediumtext_12,
                              textAlign: TextAlign.start,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          GestureDetector(
                            onTap: () {
                              // Handle the click event for the container
                              print('Container clicked');
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 55.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color: const Color(0xFFe78337),
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0), // Adjust the padding as needed
                                  child: itemGroups.isEmpty
                                      ? LoadingAnimationWidget.newtonCradle(
                                          color: Colors.blue, // Set the color as needed
                                          size: 40.0,
                                        ) // S // Show a loading indicator
                                      : DropdownButton<String>(
                                          hint: const Text(
                                            'Select Category',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xa0e78337),
                                            ),
                                          ),
                                          value: categroyname,
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              categroyname = newValue;

                                              // Find the selected Purpose object
                                              selectedcategoryObj = itemGroups.firstWhere(
                                                (category) => category.itmsGrpNam == newValue,
                                                orElse: () => ItemGroup(itmsGrpCod: '', itmsGrpNam: ''),
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
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontFamily: 'Roboto',
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFFe78337),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          icon: const Icon(Icons.arrow_drop_down),
                                          iconSize: 24,
                                          isExpanded: true,
                                          underline: const SizedBox(),
                                        ),
                                )),
                          ),
                          const SizedBox(height: 5.0),
                          const Padding(
                            padding: EdgeInsets.only(top: 10.0, left: 0.0, right: 0.0),
                            child: Text(
                              'Attachment *',
                              style: CommonUtils.Mediumtext_12,
                              textAlign: TextAlign.start,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          if (_imageFile == null)
                            GestureDetector(
                              onTap: () {
                                // here
                                showBottomSheetForImageSelection(context);
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                padding: const EdgeInsets.all(0.0),
                                child: DottedBorder(
                                  borderType: BorderType.RRect,
                                  color: const Color(0xFFe78337),
                                  padding: const EdgeInsets.only(top: 0, bottom: 0.0),
                                  strokeWidth: 1,
                                  child: Container(
                                    //padding: const EdgeInsets.all(15),
                                    // margin: const EdgeInsets.only(top: 3, bottom: 15),
                                    //   height: 70,
                                    width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.all(10.0),

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
                                            color: const Color(0xFFe78337),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.folder_rounded,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 4.0,
                                        ),
                                        const Text(
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
                          const SizedBox(height: 10.0),

                          GestureDetector(
                            onTap: () {
                              // Handle tap on uploaded image to show in a popup
                              if (_imageFile != null) {
                                _showImagePopup(context, _imageFile!);
                              }
                            },
                            child: SizedBox(
                              width: _imageFile != null ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width,
                              height: _imageFile != null ? 100 : 0,
                              child: Stack(
                                alignment: Alignment.topRight,
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
                                        padding: const EdgeInsets.all(5.0),
                                        margin: const EdgeInsets.only(top: 5, right: 10.0),
                                        color: HexColor('#ffeee0'), // Optional overlay color
                                        child: SvgPicture.asset(
                                          'assets/crosscircle.svg',
                                          color: const Color(0xFFe78337),
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
                          const SizedBox(height: 18.0),

                          // Submit Button
                          Container(
                            padding: const EdgeInsets.all(10),
                            width: double.infinity,
                            height: 50,
                            margin: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: isButtonEnabled ? const Color(0xFFe78337) : Colors.grey, // Change color based on button state
                            ),
                            child: GestureDetector(
                              onTap: isButtonEnabled ? () async {
                                var connectivityResult = await Connectivity().checkConnectivity();
                                if (connectivityResult == ConnectivityResult.none) {
                                  // No internet connection, show a message or handle it accordingly
                                  CommonUtils.showCustomToastMessageLong(
                                      'Please check your internet  connection', context, 1, 4);
                                } else {
                                  // Internet connection is available, proceed with button action
                                  AddUpdateCollections(context);
                                }
                              } : null,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: isButtonEnabled ? const Color(0xFFe78337) : Colors.grey, // Change color based on button state
                                ),
                                child: const Center(
                                  child: Text(
                                    'Submit',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
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
      CommonUtils.showCustomToastMessageLong('Please Select Date', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }

    if (isValid && Amounttext.text.isEmpty) {
      CommonUtils.showCustomToastMessageLong('Please Enter Amount', context, 1, 6);

      isValid = false;
      hasValidationFailed = true;
    }
    if (Selected_PaymentMode == 'Online') {
      // if (isValid && accountnumcontroller.text.isEmpty) {
      //   CommonUtils.showCustomToastMessageLong('Please Enter Credit Account No ', context, 1, 6);
      //
      //   isValid = false;
      //   hasValidationFailed = true;
      // }
      // if (isValid && creditbankcontroller.text.isEmpty) {
      //   CommonUtils.showCustomToastMessageLong('Please Enter  Credit Bank ', context, 1, 4);
      //   isValid = false;
      //   hasValidationFailed = true;
      // }
      if (isValid && (virtualcodeValue == null || virtualcodeValue!.isEmpty)) {
        CommonUtils.showCustomToastMessageLong('Please Select Virtual Bank Code', context, 1, 6);

        isValid = false;
        hasValidationFailed = true;
      } else if (virtualcodeValue == 'Other') {
        if (accountValue == null || accountValue!.isEmpty) {
          CommonUtils.showCustomToastMessageLong('Please Select Account Number', context, 1, 6);

          isValid = false;
          hasValidationFailed = true;
        }
      }
      if (isValid && utrcontroller.text.isEmpty) {
        CommonUtils.showCustomToastMessageLong('Please Enter UTR Number ', context, 1, 6);

        isValid = false;
        hasValidationFailed = true;
      }
    } else if (Selected_PaymentMode == 'Cheque') {
      if (isValid && checknumbercontroller.text.isEmpty) {
        CommonUtils.showCustomToastMessageLong('Please Enter Check Number', context, 1, 6);

        isValid = false;
        hasValidationFailed = true;
      }
      if (isValid && checkDateController.text.isEmpty) {
        CommonUtils.showCustomToastMessageLong('Please Select Check Date', context, 1, 4);
        isValid = false;
        hasValidationFailed = true;
      }
      if (isValid && checkissuedbankcontroller.text.isEmpty) {
        CommonUtils.showCustomToastMessageLong('Please Enter Check Issued Bank', context, 1, 6);

        isValid = false;
        hasValidationFailed = true;
      }
    }

    if (isValid && (selectedPurpose == null || selectedPurpose!.isEmpty)) {
      // Show an error message or perform any action for invalid purpose

      CommonUtils.showCustomToastMessageLong('Please Select Purpose', context, 1, 6);

      isValid = false;
      hasValidationFailed = true;
    }

    if (isValid && (categroyname == null || categroyname!.isEmpty)) {
      // Show an error message or perform any action for invalid category

      CommonUtils.showCustomToastMessageLong('Please Select Category', context, 1, 6);

      isValid = false;
      hasValidationFailed = true;
    }
    if (isValid && _imageFile == null) {
      CommonUtils.showCustomToastMessageLong('Please Upload Attachment', context, 1, 6);

      isValid = false;
      hasValidationFailed = true;
    }
    setState(() {
      isLoading = true;
    });
    if (isValid) {
      // Disable the button after validation
      disableButton();
      Map<String, dynamic> requestData = {
        "Id": "",
        "Date": selecteddate,
        "SlpCode": '$slpCode',
        "PartyCode": widget.cardCode,
        "PartyName": widget.cardName,
        "Address": widget.address,
        "StateName": widget.state,
        "PhoneNumber": widget.phone,
        "Amount": Amounttext.text,
        "PaymentType": '$payid',
        "PaymentTypeName": Selected_PaymentMode,
        "PurposeValue": '${selectedPurposeObj?.fldValue}',
        "PurposeDesc": '${selectedPurposeObj?.descr}',
        "Category": '${selectedcategoryObj?.itmsGrpCod}',
        "CategoryName": '${selectedcategoryObj?.itmsGrpNam}',

        // Default values for Online payment mode
        "CreditAccountNo": "",
        "CreditBank": "",

        if (Selected_PaymentMode == 'Online') ...{
          // "CreditAccountNo": accountnumcontroller.text,
          // "CreditBank": creditbankcontroller.text,
          "UTRNumber": utrcontroller.text,
          "VirtualBankCode": "$virtualcodeValue",

          if (virtualcodeValue == "Other") ...{
            "OtherAccountNo": "$accountno",
            "OtherBankName": "$bankbranch",
            "OtherBankCode": "$bankcode",
          } else ...{
            "OtherAccountNo": " ",
            "OtherBankName": " ",
            "OtherBankCode": " ",
          }
        },
        if (Selected_PaymentMode == 'Cheque') ...{
          "CheckNumber": checknumbercontroller.text,
          "CheckDate": checkdate,
          "CheckIssuedBank": checkissuedbankcontroller.text,
        },
        "FileName": filename,
        "FileLocation": "",
        "FileExtension": fileExtension,
        "Remarks": "",
        "CompanyId": CompneyId,
        "StatusTypeId": 7,
        "IsActive": true,
        "CreatedBy": '$userId',
        "CreatedDate": formattedcurrentDate,
        "UpdatedBy": '$userId',
        "UpdatedDate": formattedcurrentDate,
        "PartyGSTNumber": widget.gstRegnNo,
        "ProprietorName": widget.proprietorName,
        "FileString": base64Image
      };

      print(requestData);
      print(jsonEncode(requestData));
      // URL for the API endpoint
      String apiUrl = baseUrl + addCollections;
      print('SubmitCreateCollectionApi:$apiUrl');
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
              MaterialPageRoute(builder: (context) => StatusScreen(Compneyname!, responseData['response']['collectionNumber'])),
            );
          } else {
            CommonUtils.showCustomToastMessageLong('Error', context, 1, 6);
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
          padding: const EdgeInsets.only(top: 0.0, left: 5.0, right: 0.0),
          child: Text(
            labelText,
            style: CommonUtils.Mediumtext_12,
            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(height: 8.0),
        GestureDetector(
          onTap: () async {
            // Call the onTap callback to open the date picker
            onTap();
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 55.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: const Color(0xFFe78337),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0, top: 0.0),
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: controller,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFe78337),
                          ),
                          decoration: InputDecoration(
                            hintText: labelText,
                            hintStyle: const TextStyle(
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
                  child: const Padding(
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

  Future<void> _selectcheckDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime currentDate = DateTime.now();
    DateTime initialDate = selectedCheckDate ?? currentDate;

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
        firstDate: currentDate,
        lastDate: DateTime(2101),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: Color(0xFFe78337), // Change the primary color here
                onPrimary: Colors.white,
                // onSurface: Colors.blue,// Change the text color here
              ),
              dialogBackgroundColor: Colors.white, // Change the dialog background color here
            ),
            child: child!,
          );
        },

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
        firstDate: currentDate,
        lastDate: DateTime(2101),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: Color(0xFFe78337), // Change the primary color here
                onPrimary: Colors.white,
                // onSurface: Colors.blue,// Change the text color here
              ),
              dialogBackgroundColor: Colors.white, // Change the dialog background color here
            ),
            child: child!,
          );
        },
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

  Future<void> getpaymentmethods() async {
    String apiUrl = baseUrl + GetPaymentMode;
    print('GetPaymentMode$apiUrl');
    final response = await http.get(Uri.parse(apiUrl));

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
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width / 4,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            color: Color(0xFFF8dac2),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    pickImage(ImageSource.camera, context);
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      // margin: const EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFe78337),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 35,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    pickImage(ImageSource.gallery, context);
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      // margin: const EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFe78337),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.folder,
                        size: 35,
                      ),
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
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          print('===> _imageFile: $_imageFile');
        });
        filename = basename(_imageFile!.path);
        fileExtension = extension(_imageFile!.path);
        List<int> imageBytes = await _imageFile!.readAsBytes();
        Uint8List compressedBytes = Uint8List.fromList(imageBytes);
        compressedBytes = await FlutterImageCompress.compressWithList(
          compressedBytes,
          minHeight: 800,
          minWidth: 800,
          quality: 80,
        );

        base64Image = base64Encode(compressedBytes);

        print('===> Filename: $filename');
        print('===> File Extension: $fileExtension');
        print('===> Base64 Image: $base64Image');

        // Dismiss the bottom sheet after picking an image
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error picking image: $e');
      // Handle error gracefully, show error message or retry logic.
    }
  }

  Future<void> fetchdropdownitems() async {
    // final apiUrl = 'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Collections/GetPurposes/'
    //     '$CompneyId';
    final purpose = baseUrl + GetPurpose + CompneyId.toString();
    print('GetPurposeApi:$purpose');
    try {
      final response = await http.get(Uri.parse(purpose));

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

  Future<void> getAccountsData() async {
    // final apiUrl = 'http://182.18.157.215/Srikar_Biotech_Dev/API/api/SAP/GetBankDetails/$CompneyId';
    final apiUrl = baseUrl + GetbankDetails + CompneyId.toString();
    print('GetBankDetailsApi: $apiUrl');
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<dynamic> resultList = jsonResponse['response']['listResult'];
        accountList = resultList.map((account) => AccountList.fromJson(account)).toList();

        // debugPrint('getAccountsData: ${accountList[1].bankCode}');
      } else {
        debugPrint('Error: api failed');
        throw Exception('Error: api failed');
      }
    } catch (e) {
      debugPrint('catch: $e');
      throw Exception('catch: $e');
    }
  }

  Future<void> fetchdropdownitemscategory() async {
    // final apiUrl = 'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Item/GetItemGroups/$CompneyId/null';
    final apiUrl = baseUrl + GetProductName + CompneyId.toString() + "/null";
    print('Getproductnames: $apiUrl');
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('response') && responseData['response'].containsKey('listResult') && responseData['isSuccess']) {
          setState(() {
            itemGroups = (responseData['response']['listResult'] as List).map((item) => ItemGroup.fromJson(item)).toList();
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

  Future<void> getshareddata() async {
    userId = await SharedPrefsData.getStringFromSharedPrefs("userId");
    slpCode = await SharedPrefsData.getStringFromSharedPrefs("slpCode");
    CompneyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
    Compneyname = await SharedPrefsData.getStringFromSharedPrefs("companyName");
    print('User ID: $userId');

    print('SLP Code:2 $slpCode');
    if (slpCode!.isEmpty) {
      slpCode = null;
    }
    print('SLP Code:3 $slpCode');
    print('Company ID: $CompneyId');
    print('Compneyname : $Compneyname');
    print('Retrieved CompneyId: $CompneyId');
    fetchvirtualcode();
  }

  void disableButton() {
    setState(() {
      isButtonEnabled = false;
    });
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
        backgroundColor: const Color(0xFFe78337),
        automaticallyImplyLeading: false,
        title: const Text("Attached Image"),
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
}
