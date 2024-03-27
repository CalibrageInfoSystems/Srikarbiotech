// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:srikarbiotech/Common/CommonUtils.dart';
import 'package:srikarbiotech/Common/SharedPrefsData.dart';
import 'package:srikarbiotech/HomeScreen.dart';
import 'package:http/http.dart' as http;
import 'package:srikarbiotech/Model/state_selection_model.dart';
import 'package:srikarbiotech/slp_selection_screen.dart';

class StateSelectionScreen extends StatefulWidget {
  const StateSelectionScreen({super.key});

  @override
  State<StateSelectionScreen> createState() => _StateSelectionScreenState();
}

class _StateSelectionScreenState extends State<StateSelectionScreen> {
  int selectedCardIndex = -1;
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  DateTime? selectedFromDate;
  DateTime? selectedToDate;
  String fromDateText = 'From date';
  String toDateText = 'To date';
  String pickedfromdate = '';
  String pickedtodate = '';
  String todate = '';
  String state = '';
  late Future<List<StateListResult>> apiData;
  DateTime selectedDate = DateTime.now();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    super.initState();
    _prepopulateFromDate(fromDateController);

    print('todate$todate');
    String fromDate = DateFormat('dd-MM-yyyy').format(DateTime.now().subtract(const Duration(days: 30)));
    fromDateController.text = fromDate;
    String toDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    toDateController.text = toDate;

    fromDateText = pickedfromdate = fromDate;
    toDateText = pickedtodate = toDate;
    apiData = getStateData(fromDate, toDate, 1);
    // _selectfromDate(context, fromDateController);
  }

  Future<void> showDownloadNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'download_channel_id',
      'Download Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Download in progress',
      'Downloading file...',
      platformChannelSpecifics,
      payload: 'download',
    );
  }

  Future<List<StateListResult>> getStateData(String fromDateText, String todate, int id) async {
    try {
      print('fromDateText: $fromDateText');
      print('todate: $todate');

      if (fromDateText.isEmpty || todate.isEmpty) {
        throw Exception('Date strings are empty');
      }
      DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(fromDateText);
      String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      DateTime parsedDate2 = DateFormat('dd-MM-yyyy').parse(todate);
      String formattedtoDate = DateFormat('yyyy-MM-dd').format(parsedDate2);
      print('formattedDate: $formattedDate');
      print('formattedtoDate: $formattedtoDate');

      String apiUrl = 'http://182.18.157.215/Srikar_Biotech_Dev/API/api/SAP/GetGroupSummaryReportByState';
      print('todate:insidemethod: $todate');
      final requestBody = {"FromDate": formattedDate, "ToDate": formattedtoDate, "CompanyId": id};
      print('StateDataapi:$apiUrl');
      debugPrint('____state selection__${jsonEncode(requestBody)}');
      final jsonResponse = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(requestBody),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print('responsestate:${jsonResponse}');

      if (jsonResponse.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(jsonResponse.body);
        print('data:${data}');

        if (data['response']['listResult'] != null) {
          final List<dynamic> listResult = data['response']['listResult'];
          List<StateListResult> stateResult = listResult.map((house) => StateListResult.fromJson(house)).toList();
          return stateResult;
        } else {
          throw Exception('State list is null');
        }
      } else {
        throw Exception('Api failed');
      }
    } catch (e) {
      print('errorfromapi:$e');
      throw Exception('Catch: Api got failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          // height: MediaQuery.of(context).size.height,
          //  padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 20,
                ),
                width: MediaQuery.of(context).size.width,
                //   height: MediaQuery.of(context).size.height,
                child: _dateSection(),
              ),
              FutureBuilder(
                future: apiData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator.adaptive());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error occurred.'),
                    );
                  } else {
                    if (snapshot.hasData) {
                      List<StateListResult> data = snapshot.data!;

                      if (data.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              _stateSection(data),
                            ],
                          ),
                        );
                      } else {
                        return const Center(
                          child: Text('Collection is empty.'),
                        );
                      }
                    } else {
                      return const Center(
                        child: Text('No data available'),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _downloadedBtn(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: const Color(0xFFe78337),
      automaticallyImplyLeading: false,
      elevation: 5,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                child: GestureDetector(
                  onTap: () {
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
                'State Selection',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
            },
            child: Image.asset(
              'assets/srikar-home-icon.png',
              width: 30,
              height: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      // padding: const EdgeInsets.only(left: 0, right: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: Row(
        children: [
          buildDateInput(
            context,
            'FromDate *',
            fromDateController,
            () => _selectfromDate(context, fromDateController),
          ),

          // Expanded(
          //   child: dateField(
          //     context,
          //     fromDateText,
          //     () => _selectfromDate(context, fromDateController),
          //   ),
          // ),
          SizedBox(width: 15),
          buildDateInput(
            context,
            'ToDate *',
            toDateController,
            () => _selectDate(context, toDateController),
          ),
          // Expanded(
          //   child: dateField(
          //     context,
          //     toDateText,
          //     () => _selectDate(context),
          //   ),
          // ),
          SizedBox(
            width: 15,
          ),
          Container(
            width: 80,
            padding: const EdgeInsets.only(top: 22.0),
            child: GestureDetector(
              onTap: () {
                apiData = getStateData(pickedfromdate, pickedtodate, 1);

                // FutureBuilder(
                //   future: apiData,
                //   builder: (context, snapshot) {
                //     if (snapshot.connectionState == ConnectionState.waiting) {
                //       return Center(child: CircularProgressIndicator.adaptive());
                //     } else if (snapshot.hasError) {
                //       return Center(
                //         child: Text('Error occurred.'),
                //       );
                //     } else {
                //       if (snapshot.hasData) {
                //         List<StateListResult> data = snapshot.data!;
                //         if (data.isNotEmpty) {
                //           return Padding(
                //             padding: const EdgeInsets.all(10),
                //             child: Column(
                //               children: [
                //                 const SizedBox(
                //                   height: 10,
                //                 ),
                //                 _stateSection(data),
                //               ],
                //             ),
                //           );
                //         } else {
                //           return const Center(
                //             child: Text('Collection is empty.'),
                //           );
                //         }
                //       } else {
                //         return const Center(
                //           child: Text('No data available'),
                //         );
                //       }
                //     }
                //   },
                // );
              },
              child: Container(
                padding: const EdgeInsets.only(left: 10, right: 10.0),
                height: 40.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.0),
                  color: const Color(0xFFe78337),
                ),
                child: const Center(
                  child: Text(
                    'Search',
                    style: CommonUtils.Buttonstyle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime currentDate = DateTime.now();
    DateTime thirtyDaysAgo = currentDate.subtract(Duration(days: 30));

    DateTime initialDate = selectedDate ?? currentDate;

    try {
      DateTime? picked = await showDatePicker(
        context: context,
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        initialDate: initialDate,
        firstDate: thirtyDaysAgo, // Set the first selectable date to 30 days ago
        lastDate: currentDate, // Set the last selectable date to current date
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
        pickedtodate = DateFormat('dd-MM-yyy').format(picked);
      }
    } catch (e) {
      print("Error selecting date: $e");
      // Handle the error, e.g., show a message to the user or log it.
    }
  }

  Widget _stateSection(List<StateListResult> data) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            // setState(() {
            //   state = data[index].state!;
            // });
            state = data[index].state!;
            return SizedBox(
              // margin: const EdgeInsets.symmetric(
              //     horizontal: 16.0, vertical: 4.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCardIndex = index;
                  });

                  // navigate to slp selection screen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SlpSelection(
                        fromDateText: fromDateText,
                        toDateText: toDateText,
                        state: data[index].state!,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 0,
                  color: selectedCardIndex == index ? const Color(0xFFfff5ec) : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: BorderSide(
                      color: selectedCardIndex == index ? const Color(0xFFe98d47) : Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // row1
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        // mainAxisAlignment:
                                        //     MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'State: ',
                                            style: CommonUtils.Mediumtext_12,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            data[index].state!,
                                            style: CommonUtils.Mediumtext_12_0,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // const SizedBox(
                                    //   width: 10,
                                    // ),
                                    // Expanded(
                                    //   child: Row(
                                    //     // mainAxisAlignment:
                                    //     //     MainAxisAlignment.spaceBetween,
                                    //     children: [
                                    //       const Text(
                                    //         'OB: ',
                                    //         style: CommonUtils.Mediumtext_12,
                                    //         overflow: TextOverflow.ellipsis,
                                    //       ),
                                    //       Text(
                                    //         data[index].ob.toString(),
                                    //         style: CommonUtils.Mediumtext_12_0,
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                child: Text(
                                                  'OB',
                                                  style: CommonUtils.Mediumtext_12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                                child: Text(
                                                  data[index].ob.toString(),
                                                  style: CommonUtils.Mediumtext_12_0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    )),
                                    Expanded(
                                        child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                child: Text(
                                                  'Sales',
                                                  style: CommonUtils.Mediumtext_12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                child: Text(
                                                  data[index].sales.toString(),
                                                  style: CommonUtils.Mediumtext_12_0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    )),
                                  ],
                                ),

                                SizedBox(
                                  height: 8,
                                ),
                                // row4
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                child: Text(
                                                  'Returns',
                                                  style: CommonUtils.Mediumtext_12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                child: Text(
                                                  data[index].returns.toString(),
                                                  style: CommonUtils.Mediumtext_12_0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    )),
                                    Expanded(
                                        child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                child: Text(
                                                  'Receipts',
                                                  style: CommonUtils.Mediumtext_12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                child: Text(
                                                  data[index].receipts.toString(),
                                                  style: CommonUtils.Mediumtext_12_0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    )),
                                  ],
                                ),

                                const SizedBox(
                                  height: 8,
                                ),
                                // row5
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                child: Text(
                                                  'Others',
                                                  style: CommonUtils.Mediumtext_12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                child: Text(
                                                  data[index].others.toString(),
                                                  style: CommonUtils.Mediumtext_12_0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    )),
                                    Expanded(
                                        child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                child: Text(
                                                  'Closing',
                                                  style: CommonUtils.Mediumtext_12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                child: Text(
                                                  data[index].closing.toString(),
                                                  style: CommonUtils.Mediumtext_12_0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ));
  }

  Widget dateField(
    BuildContext context,
    String labelText,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color: CommonUtils.orangeColor,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          labelText,
          style: CommonUtils.Mediumtext_12_0,
        ),
      ),
    );
  }

  static Widget buildDateInput(
    BuildContext context,
    String labelText,
    TextEditingController controller,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: Column(
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
            onTap: onTap,
            child: Container(
              height: 40.0,
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
                  // InkWell(
                  //   onTap: onTap,
                  //   child: Padding(
                  //     padding:  EdgeInsets.only(left: 10.0, top: 10.0),
                  //     child: Icon(
                  //       Icons.calendar_today,
                  //       color: Colors.orange,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _prepopulateFromDate(TextEditingController controller) {
    // Calculate the date 30 days ago from the current date
    DateTime currentDate = DateTime.now();
    DateTime thirtyDaysAgo = currentDate.subtract(Duration(days: 30));

    // Format the date as per your desired format
    fromDateText = DateFormat('dd-MM-yyyy').format(thirtyDaysAgo);
    print('fromDateText$fromDateText');
    // Set the text in the controller
    controller.text = fromDateText;
  }

  // Future<void> _selectfromDate(
  //   BuildContext context,
  //   TextEditingController controller,
  // ) async {
  //   DateTime currentDate = DateTime.now();
  //   DateTime initialDate = selectedFromDate ?? currentDate;
  //
  //   // Calculate the date 30 days ago from the current date
  //   DateTime thirtyDaysAgo = currentDate.subtract(Duration(days: 30));
  //
  //   try {
  //     DateTime? picked = await showDatePicker(
  //       context: context,
  //       initialEntryMode: DatePickerEntryMode.calendarOnly,
  //       initialDate: initialDate,
  //       firstDate: thirtyDaysAgo, // Set the first selectable date to 30 days ago
  //       lastDate: currentDate, // Set the last selectable date to the current date
  //       builder: (BuildContext context, Widget? child) {
  //         return Theme(
  //           data: ThemeData.light().copyWith(
  //             colorScheme: ColorScheme.light(
  //               primary: Color(0xFFe78337), // Change the primary color here
  //               onPrimary: Colors.white,
  //               // onSurface: Colors.blue,// Change the text color here
  //             ),
  //             dialogBackgroundColor: Colors.white, // Change the dialog background color here
  //           ),
  //           child: child!,
  //         );
  //       },
  //     );
  //
  //     if (picked != null) {
  //       String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
  //       setState(() {
  //         fromDateText = formattedDate;
  //         controller.text = fromDateText;
  //       });
  //
  //       // Save selected dates as DateTime objects
  //       selectedFromDate = picked;
  //       print("Selected From Date: $selectedFromDate");
  //
  //       // Print formatted date
  //       print("Selected To Date: ${DateFormat('yyyy-MM-dd').format(picked)}");
  //     }
  //   } catch (e) {
  //     print("Error selecting date: $e");
  //     // Handle the error, e.g., show a message to the user or log it.
  //   }
  // }
  Future<void> _selectfromDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime currentDate = DateTime.now();

    // Calculate the date 30 days ago from the current date
    DateTime thirtyDaysAgo = currentDate.subtract(Duration(days: 30));

    // Use thirtyDaysAgo as the initialDate if selectedFromDate is null
    DateTime initialDate = selectedFromDate ?? thirtyDaysAgo;

    try {
      DateTime? picked = await showDatePicker(
        context: context,
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        initialDate: initialDate,
        firstDate: DateTime(1900), // Set the first selectable date to a past date (e.g., January 1, 1900)
        lastDate: currentDate, // Set the last selectable date to the current date
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: Color(0xFFe78337), // Change the primary color here
                onPrimary: Colors.white,
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
        setState(() {
          fromDateText = formattedDate;
          controller.text = fromDateText;
        });

        // Save selected dates as DateTime objects
        selectedFromDate = picked;
        print("Selected From Date: $selectedFromDate");

        // Print formatted date
        print("SelectedfromDate: ${DateFormat('yyyy-MM-dd').format(picked)}");
        pickedfromdate = DateFormat('dd-MM-yyyy').format(picked);
      }
    } catch (e) {
      print("Error selecting date: $e");
      // Handle the error, e.g., show a message to the user or log it.
    }
  }

  Future<void> _downloadFile(BuildContext context) async {
    const url = 'http://182.18.157.215/Srikar_Biotech_Dev/API/api/SAP/ExportStateGroupSummaryReport';

    final List<Map<String, dynamic>> requestBody = [
      {"State": "AP", "OB": 2.0, "Sales": 3.0, "Returns": 4.0, "Receipts": 5.0, "Others": 6.0, "Closing": 7.0},
    ];

    try {
      final response = await http.post(Uri.parse(url), headers: {'Content-Type': 'application/json'}, body: jsonEncode(requestBody));
      print('response${response.body}');
      print('jsonEncode${jsonEncode(requestBody)}');
      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        Directory downloadsDirectory = Directory('/storage/emulated/0/Download/Srikar_Groups');
        //  final decodedResponse = utf8.decode(base64.decode(response.body['response']));
        //showDownloadNotification();
        if (!downloadsDirectory.existsSync()) {
          downloadsDirectory.createSync(recursive: true);
        }
        // List<int> inData = base64.decode(base64String);
        List<int> pdfBytes = base64.decode(jsonResponse['response']);
        // Get external storage directory
        Directory? directory = await getExternalStorageDirectory();
        String filePath = '${directory!.path}/3F_${DateTime.now().toString()}.xlsx';

        // Write decoded data to file
        File file = File(filePath);
        await file.writeAsBytes(pdfBytes);

        // Show toast message
        //Fluttertoast.showToast(msg: 'File downloaded successfully');

        // Add completed download
        // Note: flutter_downloader package can be used for more advanced download management
        // Here, we're using http package to download file
        // Replace this with appropriate download method as per your requirement
        // and update DownloadManager accordingly
        DownloadManager.addCompletedDownload(file.path, file.path, '3F Akshaya', 'application/octet-stream');

        // String filePath = downloadsDirectory.path;

        //  File file = File('$filePath/file_example_XLS_10.xls');
        // await file.create(recursive: true);
        // await file.writeAsBytes(response.bodyBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File downloaded successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to download file')),
        );
      }
    } catch (e) {
      print('Error downloading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error downloading file')),
      );
    }
  }

  Widget _downloadedBtn() {
    Color buttonColor = const Color(0xFFe78337); // Set your desired color here

    return ClipRRect(
      borderRadius: BorderRadius.circular(10), // Adjust the radius as needed
      child: SizedBox(
        width: 40, // Adjust width as needed
        height: 40, // Adjust height as needed
        child: FloatingActionButton(
          onPressed: () {
            _downloadFile(context);

            // Add your download functionality here
          },
          backgroundColor: buttonColor,
          mini: true, // Make the button mini
          child: const Icon(Icons.download),
          shape: BeveledRectangleBorder(), // Beveled rectangle shape
        ),
      ),
    );
  }
}

class DownloadManager {
  static void addCompletedDownload(String filePath, String fileName, String title, String mimeType) {
    // Implement your method to add completed download here
  }
}
