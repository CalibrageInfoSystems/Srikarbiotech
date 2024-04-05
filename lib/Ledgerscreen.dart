// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikarbiotech/Common/CommonUtils.dart';
import 'package:http/http.dart' as http;
import 'package:srikarbiotech/Services/api_config.dart';

import 'Common/SharedPrefsData.dart';
import 'HomeScreen.dart';

class Ledgerscreen extends StatefulWidget {
  final String cardName;
  final String cardCode;
  final String address;
  final String proprietorName;
  final String gstRegnNo;
  final String state;
  final String phone;
  final double creditLine;
  final double balance;

  const Ledgerscreen(
      {super.key,
        required this.cardName,
        required this.cardCode,
        required this.address,
        required this.state,
        required this.phone,
        required this.proprietorName,
        required this.gstRegnNo,
        required this.creditLine,
        required this.balance});
  @override
  Ledger_screen createState() => Ledger_screen();
}

class Ledger_screen extends State<Ledgerscreen> {
  bool downloading = false;
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  // CalendarFormat calendarFormat = CalendarFormat.month;
  DateTime? selectedFromDate;

  DateTime? selectedToDate;
  int CompneyId = 0;
  String companyCode = "";

  String? downloadedFilePath;
  int notificationId = 1;
  @override
  initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    getshareddata();
    checkStoragePermission();
    print('cardName: ${widget.cardName}');
    print('cardCode: ${widget.cardCode}');
    print('address: ${widget.address}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFe78337),
        automaticallyImplyLeading: false,
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
                  'Ledger',
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
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()),
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
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),

      body: Column(children: [
        Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
            child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CommonUtils.buildCard(
                widget.cardName,
                widget.cardCode,
                widget.proprietorName,
                widget.gstRegnNo,
                widget.address,
                Colors.white,
                BorderRadius.circular(5.0),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.only(top: 5.0, left: 0.0, right: 0.0),
                child: IntrinsicHeight(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(10.0),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Credit Limit',
                                  style: TextStyle(
                                    color: Color(0xFF5f5f5f),
                                    fontFamily: "Roboto",
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '₹${widget.creditLine}',
                                  style: const TextStyle(
                                    color: Color(0xFF5f5f5f),
                                    fontFamily: "Roboto",
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.0,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                              height: 5.0), // Add some space between rows
                          // Third Row: Outstanding Amount
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Outstanding Amount',
                                  style: TextStyle(
                                    color: Color(0xFF5f5f5f),
                                    fontFamily: "Roboto",
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '₹${widget.balance}',
                                  style: const TextStyle(
                                    color: Color(0xFF5f5f5f),
                                    fontFamily: "Roboto",
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.0,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Card(
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  color: Colors.white,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // From Date TextFormField with Calendar Icon
                        buildDateInput(
                          context,
                          'From Date',
                          fromDateController,
                              () => _selectfromDate(context, fromDateController),
                        ),
                        const SizedBox(height: 16.0),
                        // To Date TextFormField with Calendar Icon
                        buildDateInput(
                          context,
                          'To Date',
                          toDateController,
                              () => _selectDate(context, toDateController),
                        ),

                        const SizedBox(height: 16.0),

                        // Download and Share buttons
                      ],
                    ),
                  ))
            ]))
      ]),
      bottomNavigationBar: Container(
        height: 60,
        margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  CommonUtils.checkInternetConnectivity().then(
                        (isConnected) {
                      if (isConnected) {
                        downloadData();
                      } else {
                        CommonUtils.showCustomToastMessageLong(
                            'Please check your internet  connection',
                            context,
                            1,
                            4);
                      }
                    },
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
                      'Download',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight:
                        FontWeight.bold, // Set the font weight to bold
                        fontFamily: 'Roboto', // Set the font family to Roboto
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Add a progress indicator based on the downloading state
            if (downloading)
              LinearProgressIndicator(
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),

            const SizedBox(
              width: 15,
            ),
            GestureDetector(
              onTap: () {
                print('Share button clicked');
                CommonUtils.checkInternetConnectivity().then(
                      (isConnected) {
                    if (isConnected) {
                      // shareData();
                      downloadPdf();
                    } else {
                      CommonUtils.showCustomToastMessageLong(
                          'Please check your internet  connection',
                          context,
                          1,
                          4);
                      print('The Internet Is not  Connected');
                    }
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFe78337),
                  ),
                  color: const Color(
                      0xFFF8dac2), // Replace with the desired background color
                ),
                child: SvgPicture.asset(
                  'assets/share.svg', // Replace with your SVG file path
                  color: const Color(0xFFe78337),
                  width: 25,
                  height: 25,
                ),
              ),
            )
          ],
        ),
      ),

      //    ),
    );
  }

  Future<void> downloadPdf() async {
    bool isValid = true;
    bool hasValidationFailed = false;

    if (isValid && fromDateController.text.isEmpty) {
      CommonUtils.showCustomToastMessageLong(
          'Please Select From Date', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }
    if (isValid && toDateController.text.isEmpty) {
      CommonUtils.showCustomToastMessageLong(
          'Please Select To Date', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }
    String fromdate = DateFormat('yyyy-MM-dd').format(selectedFromDate!);
    String todate = DateFormat('yyyy-MM-dd').format(selectedToDate!);
    String pdffromdate = DateFormat('ddMMyyyy').format(selectedFromDate!);
    String pdftodate = DateFormat('ddMMyyyy').format(selectedToDate!);
    print('pdffromdate: $pdffromdate');
    print('pdftodate: $pdftodate');
    if (isValid && todate.compareTo(fromdate) < 0) {
      CommonUtils.showCustomToastMessageLong(
          "To Date is less than From Date", context, 1, 5);
      isValid = false;
      hasValidationFailed = true;
    }

    if (isValid) {
      final apiUrl = baseUrl + GetLedgerReport;
      print('GetLedgerReportApi:$apiUrl');
      final requestHeaders = {'Content-Type': 'application/json'};

      final requestBody = {
        "CompanyId": '$CompneyId',
        "PartyCode": widget.cardCode,
        "FromDate": fromdate,
        "ToDate": todate
      };
      try {
        String fromdate = DateFormat('yyyy-MM-dd').format(selectedFromDate!);
        String todate = DateFormat('yyyy-MM-dd').format(selectedToDate!);
        String pdffromdate = DateFormat('ddMMyyyy').format(selectedFromDate!);
        String pdftodate = DateFormat('ddMMyyyy').format(selectedToDate!);
        print('pdffromdate: $pdffromdate');
        print('pdftodate: $pdftodate');

        final apiUrl = baseUrl + GetLedgerReport;
        final requestHeaders = {"Content-Type": "application/json"};

        final requestBody = {
          "CompanyId": '$CompneyId',
          "PartyCode": widget.cardCode,
          "FromDate": fromdate,
          "ToDate": todate
        };

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: requestHeaders,
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);

          setState(() {
            downloading = false;
          });
          if (jsonResponse['result']['isSuccess']) {
            if (jsonResponse['result']['response'] == null) {
              CommonUtils.showCustomToastMessageLong(
                  'PDF is not available.', context, 1, 4);
              return;
            } else {
              print('jsonResponse: $jsonResponse');
            }
            List<int> pdfBytes =
            base64.decode(jsonResponse['result']['response']);
            // create a directory for storing the report
            Directory directoryPath =
            Directory('/storage/emulated/0/Download/Srikar_Groups/ledger');
            if (!directoryPath.existsSync()) {
              directoryPath.createSync(recursive: true);
            }
            String filePath = directoryPath.path;
            String fileName =
                "${companyCode}_${widget.cardCode}_${pdffromdate}_$pdftodate.pdf";

            final File file = File('$filePath/$fileName');

            await file.create(recursive: true);
            await file.writeAsBytes(pdfBytes);

            sharePDF(file.path);
            CommonUtils.showCustomToastMessageLong(
                'Ledger Report Downloaded Successfully', context, 0, 4);
          } else {
            CommonUtils.showCustomToastMessageLong(
                '${jsonResponse['result']['endUserMessage']}', context, 1, 4);
          }
        } else {
          print('else Error: ${response.reasonPhrase}');
        }
      } catch (error) {
        print('catchError: $error');
      }
    }
  }

  void sharePDF(String? filePath) async {
    try {
      if (filePath != null) {
        await Share.shareFiles([filePath], text: 'Sharing pdf');
      } else {
        CommonUtils.showCustomToastMessageLong('No path found!', context, 0, 4);
      }
    } catch (e) {
      print('Error sharing pdf: $e');
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
            style: const TextStyle(
              fontSize: 12.0,
              color: Color(0xFF5f5f5f),
              fontWeight: FontWeight.bold,
            ),
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
              borderRadius: BorderRadius.circular(5.0),
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
                            fontWeight: FontWeight.w700,
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

  Future<void> _selectfromDate(
      BuildContext context,
      TextEditingController controller,
      ) async {
    DateTime currentDate = DateTime.now();
    // DateTime initialDate;
    DateTime initialDate = selectedFromDate ?? currentDate;
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
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFe78337), // Change the primary color here
                onPrimary: Colors.white,
                // onSurface: Colors.blue,// Change the text color here
              ),
              dialogBackgroundColor:
              Colors.white, // Change the dialog background color here
            ),
            child: child!,
          );
        },
      );
      if (picked != null) {
        String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
        controller.text = formattedDate;

        // Save selected dates as DateTime objects
        selectedFromDate = picked;
        print("Selected From Date: $selectedFromDate");

        // Print formatted date
        print("Selected To Date: ${DateFormat('yyyy-MM-dd').format(picked)}");
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
    DateTime initialDate = selectedToDate ?? currentDate;
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
        initialDatePickerMode: DatePickerMode.day, // Add this line
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFe78337), // Change the primary color here
                onPrimary: Colors.white,
                // onSurface: Colors.blue,// Change the text color here
              ),
              dialogBackgroundColor:
              Colors.white, // Change the dialog background color here
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
        controller.text = formattedDate;

        // Save selected dates as DateTime objects
        selectedToDate = picked;
        print("Selected to Date: $selectedToDate");

        // Print formatted date
        print("Selected To Date: ${DateFormat('yyyy-MM-dd').format(picked)}");
      }
    } catch (e) {
      print("Error selecting date: $e");
      // Handle the error, e.g., show a message to the user or log it.
    }
  }

  Future<void> downloadData() async {
    bool isValid = true;
    bool hasValidationFailed = false;

    if (isValid && fromDateController.text.isEmpty) {
      CommonUtils.showCustomToastMessageLong(
          'Please Select From Date', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }
    if (isValid && toDateController.text.isEmpty) {
      CommonUtils.showCustomToastMessageLong(
          'Please Select To Date', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }
    String fromdate = DateFormat('yyyy-MM-dd').format(selectedFromDate!);
    String todate = DateFormat('yyyy-MM-dd').format(selectedToDate!);
    String pdffromdate = DateFormat('ddMMyyyy').format(selectedFromDate!);
    String pdftodate = DateFormat('ddMMyyyy').format(selectedToDate!);
    print('pdffromdate: $pdffromdate');
    print('pdftodate: $pdftodate');
    if (isValid && todate.compareTo(fromdate) < 0) {
      CommonUtils.showCustomToastMessageLong(
          "To Date is less than From Date", context, 1, 5);
      isValid = false;
      hasValidationFailed = true;
    }

    if (isValid) {
      final apiUrl = baseUrl + GetLedgerReport;
      print('GetLedgerReportApi:$apiUrl');
      final requestHeaders = {'Content-Type': 'application/json'};

      final requestBody = {
        "CompanyId": '$CompneyId',
        "PartyCode": widget.cardCode,
        "FromDate": fromdate,
        "ToDate": todate
      };
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: requestHeaders,
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);

          setState(() {
            downloading = false;
          });
          if (jsonResponse['result']['isSuccess']) {
            // Convert base64 string to bytes
            if (jsonResponse['result']['response'] == null) {
              CommonUtils.showCustomToastMessageLong(
                  'PDF is not available.', context, 1, 4);
              return;
            } else {
              print('jsonResponse: $jsonResponse');
            }
            List<int> pdfBytes =
            base64.decode(jsonResponse['result']['response']);
            // create a directory for storing the report
            Directory downloadsDirectory =
            Directory('/storage/emulated/0/Download/Srikar_Groups/');
            if (!downloadsDirectory.existsSync()) {
              downloadsDirectory.createSync(recursive: true);
            }
            String filePath = downloadsDirectory.path;
            String fileName =
                "${companyCode}_${widget.cardCode}_${pdffromdate}_$pdftodate.pdf";

            final File file = File('$filePath/$fileName');

            await file.create(recursive: true);
            await file.writeAsBytes(pdfBytes);

            downloadedFilePath = file.path;
            createNotification(downloadedFilePath);
            CommonUtils.showCustomToastMessageLong(
                'Ledger Report Downloaded Successfully', context, 0, 4);
          } else {
            CommonUtils.showCustomToastMessageLong(
                '${jsonResponse['result']['endUserMessage']}', context, 1, 4);
          }
        } else {
          print('else Error: ${response.reasonPhrase}');
        }
      } catch (error) {
        print('catchError: $error');
      }
    }
  }

//   Future<void> downloadData() async {
//     print('ledger: downloadData');

//     bool isValid = true;
//     bool hasValidationFailed = false;

//     if (isValid && fromDateController.text.isEmpty) {
//       CommonUtils.showCustomToastMessageLong(
//           'Please Select From Date', context, 1, 4);
//       isValid = false;
//       hasValidationFailed = true;
//     }
//     if (isValid && toDateController.text.isEmpty) {
//       CommonUtils.showCustomToastMessageLong(
//           'Please Select To Date', context, 1, 4);
//       isValid = false;
//       hasValidationFailed = true;
//     }
//     String fromdate = DateFormat('yyyy-MM-dd').format(selectedFromDate!);
//     String todate = DateFormat('yyyy-MM-dd').format(selectedToDate!);
//     String pdffromdate = DateFormat('ddMMyyyy').format(selectedFromDate!);
//     String pdftodate = DateFormat('ddMMyyyy').format(selectedToDate!);
//     print('pdffromdate: $pdffromdate');
//     print('pdftodate: $pdftodate');
//     if (isValid && todate.compareTo(fromdate) < 0) {
//       CommonUtils.showCustomToastMessageLong(
//           "To Date is less than From Date", context, 1, 5);
//       isValid = false;
//       hasValidationFailed = true;
//     }

//     if (isValid) {
//       // final apiUrl =
//       //     'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Party/GetCustomerLedgerReport';
//       final apiUrl = baseUrl + GetLedgerReport;
//       print('GetLedgerReportApi:$apiUrl');
//       final requestHeaders = {'Content-Type': 'application/json'};
//       // final requestBody = {
//       //   "PartyCode": "SRIKARTS00139",
//       //   "FromDate": "2023-05-24",
//       //   "ToDate": "2023-06-05"
//       // };

//       final requestBody = {
//         "CompanyId": '$CompneyId',
//         "PartyCode": widget.cardCode,
//         "FromDate": fromdate,
//         "ToDate": todate
//       };
//       try {
//         final response = await http.post(
//           Uri.parse(apiUrl),
//           headers: requestHeaders,
//           body: jsonEncode(requestBody),
//         );

//         if (response.statusCode == 200) {
//           final jsonResponse = json.decode(response.body);

//           setState(() {
//             downloading = false;
//           });
//           if (jsonResponse['result']['isSuccess']) {
//             // Convert base64 string to bytes
//             if (jsonResponse['result']['response'] == null) {
//               // Handle null response
//               CommonUtils.showCustomToastMessageLong(
//                   'PDF is not available.', context, 1, 4);
//               print('Response is null.');
//             } else {
//               // Handle non-null response
//               print(jsonResponse);
//               // Your further processing logic here
//             }
//             List<int> pdfBytes =
//                 base64.decode(jsonResponse['result']['response']);
//             var status = await Permission.storage.request();
//             var manageExternalStorage =
//                 await Permission.manageExternalStorage.request();
//             if (status.isGranted || manageExternalStorage.isGranted) {
//               // create a directory for storing the report
//               Directory downloadsDirectory =
//                   Directory('/storage/emulated/0/Download/Srikar_Groups/');
//               if (!downloadsDirectory.existsSync()) {
//                 downloadsDirectory.createSync(recursive: true);
//               }
//               String filePath = downloadsDirectory.path;
//               String fileName =
//                   "${companyCode}_${widget.cardCode}_${pdffromdate}_$pdftodate.pdf";

//               final File file = File('$filePath/$fileName');
//               if (!downloadsDirectory.existsSync()) {
//                 downloadsDirectory.createSync(recursive: true);
//               }
//               await file.create(recursive: true);
//               await file.writeAsBytes(pdfBytes);

//               downloadedFilePath = file.path;
//               createNotification(downloadedFilePath);
//               CommonUtils.showCustomToastMessageLong(
//                   'Ledger Report Downloaded Successfully', context, 0, 4);
//             } else {
//               print('Permission denied');

//               CommonUtils.showCustomToastMessageLong(
//                   'Permission denied', context, 0, 4);
//             }

//             // Get the directory for saving files
//           } else {
//             CommonUtils.showCustomToastMessageLong(
//                 '${jsonResponse['result']['endUserMessage']}', context, 1, 4);
//           }
//         } else {
//           print('else Error: ${response.reasonPhrase}');
//         }
//       } catch (error) {
//         print('catchError: $error');
//       }
//     }
//   }

  Future<void> shareData() async {
    print('ledger: shareData');
    bool isValid = true;
    bool hasValidationFailed = false;
    String fromdate = DateFormat('yyyy-MM-dd').format(selectedFromDate!);
    String todate = DateFormat('yyyy-MM-dd').format(selectedToDate!);
    String pdffromdate = DateFormat('ddMMyyyy').format(selectedFromDate!);
    String pdftodate = DateFormat('ddMMyyyy').format(selectedToDate!);

    if (isValid && fromDateController.text.isEmpty) {
      CommonUtils.showCustomToastMessageLong(
          'Please Select From Date', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }
    if (isValid && toDateController.text.isEmpty) {
      CommonUtils.showCustomToastMessageLong(
          'Please Select To Date', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }

    if (isValid && todate.compareTo(fromdate) < 0) {
      CommonUtils.showCustomToastMessageLong(
          "To Date is less than From Date", context, 1, 5);
      isValid = false;
      hasValidationFailed = true;
    }

    if (isValid) {
      // final apiUrl =
      //     'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Party/GetCustomerLedgerReport';
      final apiUrl = baseUrl + GetCustomerLedgerReport;
      print('GetCustomerLedgerReportApi:$apiUrl');
      final requestHeaders = {'Content-Type': 'application/json'};
      final requestBody = {
        "CompanyId": '$CompneyId',
        "PartyCode": widget.cardCode,
        "FromDate": fromdate,
        "ToDate": todate
      };
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: requestHeaders,
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);

          if (jsonResponse['result']['isSuccess']) {
            List<int> pdfBytes =
            base64.decode(jsonResponse['result']['response']);
            final status = await Permission.storage.request();
            var manageExternalStorage =
            await Permission.manageExternalStorage.request();
            if (status.isGranted || manageExternalStorage.isGranted) {
              Directory downloadsDirectory = Directory(
                  '/storage/emulated/0/Download/Srikar_Groups/ledgerSummaryReports');
              if (!downloadsDirectory.existsSync()) {
                downloadsDirectory.createSync(recursive: true);
              }
              String fileName =
                  "${companyCode}_${widget.cardCode}_${pdffromdate}_$pdftodate.pdf";

              String filePath = '${downloadsDirectory.path}/$fileName';

              final File file = File(filePath);

              await file.create(recursive: true);
              await file.writeAsBytes(pdfBytes);
              downloadedFilePath = file.path;
              sharePDF(downloadedFilePath);
              // await _sharePdf(filePath);
            } else {
              //  requestPermission();
              print('Permission denied');
            }

            // Get the directory for saving files
          } else {
            CommonUtils.showCustomToastMessageLong(
                '${jsonResponse['result']['endUserMessage']}', context, 1, 4);
          }
        } else {
          print('elseError: ${response.reasonPhrase}');
        }
      } catch (error) {
        print('catch Error: $error');
      }
    }
  }

  // void sharePDF(String? filePath) async {
  //   if (downloadedFilePath != null) {
  //     final file = File(downloadedFilePath!);
  //     if (await file.exists()) {
  //       try {
  //         if (filePath != null) {
  //           await Share.shareFiles([filePath], text: 'Check out this PDF file');
  //         } else {
  //           print('sharePDF: filePath has null');
  //         }
  //       } catch (e) {
  //         print('catch sharePDF: $e');
  //       }
  //     } else {
  //       print('Error: File path is null or empty.');
  //     }
  //   }
  // }

  // Future<void> _sharePdf(String filePath) async {
  //   try {
  //     // Check if the file exists
  //     File file = File(filePath);
  //     if (await file.exists()) {
  //       // Share the file
  //       await Share.shareFiles([filePath], text: 'Check out this PDF file');
  //     } else {
  //       print('File not found: $filePath');
  //     }
  //   } catch (error) {
  //     print('Error sharing PDF: $error');
  //   }
  // }

  Future<void> checkStoragePermission() async {
    print('ledger: checkStoragePermission');
    bool permissionStatus;
    final deviceInfo = await DeviceInfoPlugin().androidInfo;

    if (deviceInfo.version.sdkInt > 32) {
      permissionStatus = await Permission.storage.request().isGranted;
    } else {
      permissionStatus = await Permission.storage.request().isGranted;
    }
    print('Storage permission is granted $permissionStatus');
    if (await Permission.storage.request().isGranted) {
      // Permission is granted, you can proceed with your tasks
      print('Storage permission is granted');
    } else {
      // Permission is not granted, request it
      Map<Permission, PermissionStatus> status = await [
        Permission.storage,
      ].request();

      if (status[Permission.storage] == PermissionStatus.granted) {
        // Permission granted, you can proceed with your tasks
        print('Storage permission is granted');
      } else {
        // Permission denied, handle accordingly
        print('Storage permission is denied');
        // You might want to show a dialog or message to inform the user
      }
    }
  }

  Future<void> getshareddata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    CompneyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
    companyCode = await SharedPrefsData.getStringFromSharedPrefs("companyCode");
    print('companyCode: $companyCode');
    print('Company ID: $CompneyId');
  }

  void createNotification(String? filePath) async {
    if (filePath != null && filePath.isNotEmpty) {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: notificationId++,
            channelKey: 'sb_channel_key',
            title: 'Ledger Summary Report',
            body: filePath,
            backgroundColor: Colors.green),
      );
    } else {
      print('Error: File path is null or empty.');
    }
  }

  @pragma("vm:entry-point")
  Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction,
      ) async {
    if (downloadedFilePath != null) {
      final file = File(downloadedFilePath!);
      if (await file.exists()) {
        try {
          await OpenFile.open(
            downloadedFilePath!,
            type: 'application/pdf',
          );
        } catch (e) {
          print('Error opening file: $e');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error: Downloaded XLS sheet not found.')),
        );
      }
    }
  }
}
