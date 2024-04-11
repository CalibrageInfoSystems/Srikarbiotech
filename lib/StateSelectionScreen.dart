// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:srikarbiotech/Common/CommonUtils.dart';
import 'package:srikarbiotech/Common/styles.dart';
import 'package:srikarbiotech/HomeScreen.dart';
import 'package:http/http.dart' as http;
import 'package:srikarbiotech/Model/state_selection_model.dart';

import 'package:srikarbiotech/slp_selection_screen.dart';

import 'notification_controller.dart';

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
  bool isLoading = false;
  late Future<List<StateListResult>> apiData;
  DateTime selectedDate = DateTime.now();

  String? downloadedFilePath;
  int notificationId = 1;
  @override
  void initState() {
    super.initState();
    _prepopulateFromDate(fromDateController);

    String fromDate = DateFormat('dd-MM-yyyy')
        .format(DateTime.now().subtract(const Duration(days: 30)));
    fromDateController.text = fromDate;
    String toDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    toDateController.text = toDate;

    fromDateText = pickedfromdate = fromDate;
    toDateText = pickedtodate = toDate;
    apiData = getStateData(fromDate, toDate, 1);
    setListenersForUserActionsOnNotifications();
  }

  void setListenersForUserActionsOnNotifications() async {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod:
          NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:
          NotificationController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod:
          NotificationController.onDismissActionReceivedMethod,
    );
  }

  Future<List<StateListResult>> getStateData(
      String fromDateText, String todate, int id) async {
    try {
      if (fromDateText.isEmpty || todate.isEmpty) {
        throw Exception('Date strings are empty');
      }
      DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(fromDateText);
      String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      DateTime parsedDate2 = DateFormat('dd-MM-yyyy').parse(todate);
      String formattedtoDate = DateFormat('yyyy-MM-dd').format(parsedDate2);
      print('pickedDate F: $formattedDate');
      print('pickedDate F: $formattedtoDate');

      String apiUrl =
          'http://182.18.157.215/Srikar_Biotech_Dev/API/api/SAP/GetGroupSummaryReportByState';
      final requestBody = {
        "FromDate": formattedDate,
        "ToDate": formattedtoDate,
        "CompanyId": id
      };
      debugPrint('____state selection__${jsonEncode(requestBody)}');
      final jsonResponse = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(requestBody),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      debugPrint('____state selection__${jsonResponse.body}');

      if (jsonResponse.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(jsonResponse.body);

        if (data['response']['listResult'] != null) {
          final List<dynamic> listResult = data['response']['listResult'];
          List<StateListResult> stateResult = listResult
              .map((house) => StateListResult.fromJson(house))
              .toList();
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
      body: Container(
        color: CommonStyles.greyShade,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: _dateSection(),
            ),
            Expanded(
              child: FutureBuilder(
                future: apiData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: const Center(
                        child: CommonStyles.progressIndicator,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        CommonUtils.extractExceptionMessage(snapshot.error
                            .toString()), //'Error occurred.: ${snapshot.error}',
                        style: CommonStyles.txSty_12b_fb,
                      ),
                    );
                  } else {
                    if (snapshot.hasData) {
                      List<StateListResult> data = snapshot.data!;

                      if (data.isNotEmpty) {
                        return isLoading
                            ? const Center(
                                child: CircularProgressIndicator.adaptive(),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(5),
                                child: _stateSection(data),
                              );
                      } else {
                        return const Center(
                          child: Text(
                            ' No data available.',
                            style: CommonStyles.txSty_12b_fb,
                          ),
                        );
                      }
                    } else {
                      return const Center(
                        child: Text(
                          'No data available',
                          style: CommonStyles.txSty_12b_fb,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FutureBuilder(
        future: apiData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(); // Return an empty SizedBox while waiting for data
          } else if (snapshot.hasError) {
            return const SizedBox(); // Return an empty SizedBox if an error occurred
          } else {
            if (snapshot.hasData) {
              List<StateListResult> data =
                  snapshot.data!.cast<StateListResult>();
              if (data.isNotEmpty) {
                return downloadedBtn(data); // Pass data to downloadedBtn widget
              } else {
                return const SizedBox(); // Return an empty SizedBox if data is empty
              }
            } else {
              return const SizedBox(); // Return an empty SizedBox if no data is available
            }
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: CommonStyles.orangeColor,
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
                style: CommonStyles.txSty_18w_fb,
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false);
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
      padding: const EdgeInsets.all(10),
      // padding: const EdgeInsets.only(left: 0, right: 0),
      decoration: BoxDecoration(
        color: Colors.white,
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
          const SizedBox(width: 15),
          buildDateInput(
            context,
            'ToDate *',
            toDateController,
            () => _selectDate(context, toDateController),
          ),
          const SizedBox(
            width: 15,
          ),
          Container(
            width: 80,
            padding: const EdgeInsets.only(top: 22.0),
            child: GestureDetector(
              onTap: () async {
                setState(() {
                  isLoading = true;
                });
                fromDateText = pickedfromdate;
                toDateText = pickedtodate;

                apiData = getStateData(pickedfromdate, pickedtodate, 1);
                apiData.then((value) {
                  setState(() {
                    isLoading = false;
                  });
                });
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
    DateTime thirtyDaysAgo = currentDate.subtract(const Duration(days: 30));

    DateTime initialDate = selectedDate ?? currentDate;

    try {
      DateTime? picked = await showDatePicker(
        context: context,
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        initialDate: initialDate,
        firstDate:
            thirtyDaysAgo, // Set the first selectable date to 30 days ago
        lastDate: currentDate, // Set the last selectable date to current date
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
    return Expanded(
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          state = data[index].state!;
          return GestureDetector(
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
              color:
                  selectedCardIndex == index ? const Color(0xFFfff5ec) : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
                side: BorderSide(
                  color: selectedCardIndex == index
                      ? CommonStyles.orangeColor
                      : Colors.grey,
                  width: 1,
                ),
              ),
              child: Padding(
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
                                    children: [
                                      const Text(
                                        'State: ',
                                        style: CommonStyles.txSty_12b_fb,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        data[index].state!,
                                        style: CommonStyles.txSty_12o_f7,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: Row(
                                  children: [
                                    const Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 0),
                                            child: Text(
                                              'OB',
                                              style: CommonStyles.txSty_12b_fb,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 5, 0),
                                            child: Text(
                                              '₹${formatNumber(data[index].ob)}',
                                              style: CommonStyles.txSty_12o_f7,
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
                                    const Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 0),
                                            child: Text(
                                              'Sales',
                                              style: CommonStyles.txSty_12b_fb,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 0, 0),
                                            child: Text(
                                              '₹${formatNumber(data[index].sales)}',
                                              style: CommonStyles.txSty_12o_f7,
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
                            // row4
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: Row(
                                  children: [
                                    const Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 0),
                                            child: Text(
                                              'Returns',
                                              style: CommonStyles.txSty_12b_fb,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 0, 0),
                                            child: Text(
                                              '₹${formatNumber(data[index].returns)}',
                                              style: CommonStyles.txSty_12o_f7,
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
                                    const Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 0),
                                            child: Text(
                                              'Receipts',
                                              style: CommonStyles.txSty_12b_fb,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 0, 0),
                                            child: Text(
                                              '₹${formatNumber(data[index].receipts)}',
                                              style: CommonStyles.txSty_12o_f7,
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
                                    const Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 0),
                                            child: Text(
                                              'Others',
                                              style: CommonStyles.txSty_12b_fb,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 0, 0),
                                            child: Text(
                                              '₹${formatNumber(data[index].others)}',
                                              style: CommonStyles.txSty_12o_f7,
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
                                      const Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 0, 0),
                                              child: Text(
                                                'Closing',
                                                style:
                                                    CommonStyles.txSty_12b_fb,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 0, 0, 0),
                                              child: Text(
                                                '₹${formatNumber(data[index].closing)}',
                                                style:
                                                    CommonStyles.txSty_12o_f7,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: CommonStyles.orangeColor,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
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
            color: CommonStyles.orangeColor,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          labelText,
          style: CommonStyles.txSty_12b_fb,
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
              style: CommonStyles.txSty_12b_fb,
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
                  color: CommonStyles.orangeColor,
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
                          style: CommonStyles.txSty_14o_f7,
                          decoration: InputDecoration(
                            hintText: labelText,
                            hintStyle: CommonStyles.txSty_14o_f7,
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
    );
  }

  void _prepopulateFromDate(TextEditingController controller) {
    // Calculate the date 30 days ago from the current date
    DateTime currentDate = DateTime.now();
    DateTime thirtyDaysAgo = currentDate.subtract(const Duration(days: 30));

    // Format the date as per your desired format
    fromDateText = DateFormat('dd-MM-yyyy').format(thirtyDaysAgo);
    print('fromDateText$fromDateText');
    // Set the text in the controller
    controller.text = fromDateText;
  }

  Future<void> _selectfromDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime currentDate = DateTime.now();

    // Calculate the date 30 days ago from the current date
    DateTime thirtyDaysAgo = currentDate.subtract(const Duration(days: 30));

    // Use thirtyDaysAgo as the initialDate if selectedFromDate is null
    DateTime initialDate = selectedFromDate ?? thirtyDaysAgo;

    try {
      DateTime? picked = await showDatePicker(
        context: context,
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        initialDate: initialDate,
        firstDate: DateTime(
            1900), // Set the first selectable date to a past date (e.g., January 1, 1900)
        lastDate:
            currentDate, // Set the last selectable date to the current date
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
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
    const url =
        'http://182.18.157.215/Srikar_Biotech_Dev/API/api/SAP/ExportStateGroupSummaryReport';

    final List<Map<String, dynamic>> requestBody = [
      {
        "State": "AP",
        "OB": 2.0,
        "Sales": 3.0,
        "Returns": 4.0,
        "Receipts": 5.0,
        "Others": 6.0,
        "Closing": 7.0
      },
    ];

    try {
      final response = await http.post(Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody));
      print('response${response.body}');
      print('jsonEncode${jsonEncode(requestBody)}');
      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        Directory downloadsDirectory =
            Directory('/storage/emulated/0/Download/Srikar_Groups');
        //  final decodedResponse = utf8.decode(base64.decode(response.body['response']));
        //showDownloadNotification();
        if (!downloadsDirectory.existsSync()) {
          downloadsDirectory.createSync(recursive: true);
        }
        // List<int> inData = base64.decode(base64String);
        List<int> pdfBytes = base64.decode(jsonResponse['response']);
        // Get external storage directory
        Directory? directory = await getExternalStorageDirectory();
        String filePath =
            '${directory!.path}/3F_${DateTime.now().toString()}.xlsx';

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
        DownloadManager.addCompletedDownload(
            file.path, file.path, '3F Akshaya', 'application/octet-stream');

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
    Color buttonColor = const Color(0xFFe78337);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 40,
        height: 40,
        child: FloatingActionButton(
          onPressed: () {
            _downloadFile(context);
          },
          backgroundColor: buttonColor,
          mini: true,
          shape: const BeveledRectangleBorder(),
          child: const Icon(Icons.download),
        ),
      ),
    );
  }

  Widget downloadedBtn(List<StateListResult> stateResult) {
    Color buttonColor = const Color(0xFFe78337);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 40, // Adjust width as needed
        height: 40, // Adjust height as needed
        child: FloatingActionButton(
          onPressed: () {
            exportStateGroupSummaryReport(stateResult);
          },
          backgroundColor: buttonColor,
          mini: true,
          shape: const BeveledRectangleBorder(),
          child: const Icon(Icons.download),
        ),
      ),
    );
  }

  List<int> tempPdfBytes = [];
  File? xlSheet;

  Future<void> exportStateGroupSummaryReport(
      List<StateListResult> stateResult) async {
    try {
      final requestBody = stateResult
          .map((state) => {
                'State': state.state,
                'OB': state.ob,
                'Sales': state.sales,
                'Returns': state.returns,
                'Receipts': state.receipts,
                'Others': state.others,
                'Closing': state.closing,
              })
          .toList();

      // API endpoint for exporting state group summary report
      const apiUrl =
          'http://182.18.157.215/Srikar_Biotech_Dev/API/api/SAP/ExportStateGroupSummaryReport';

      // Send HTTP POST request
      final jsonResponse = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode(requestBody),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Check response status code
      if (jsonResponse.statusCode == 200) {
        final jsonData = json.decode(jsonResponse.body);

        Directory downloadsDirectory = Directory(
            '/storage/emulated/0/Download/Srikar_Groups/GroupSummaryReports/');
        if (!downloadsDirectory.existsSync()) {
          downloadsDirectory.createSync(recursive: true);
        }
        String filePath = downloadsDirectory.path;

        List<int> pdfBytes = base64.decode(jsonData['response']);
        DateTime now = DateTime.now();
        String timestamp = DateFormat('yyyyMMdd_HHmmss').format(now);
        String filename = 'GroupSummary_$timestamp.xlsx';
        final File file = File('$filePath/$filename');
        await file.create(recursive: true);
        await file.writeAsBytes(pdfBytes);

        downloadedFilePath = file.path;
        createNotification(downloadedFilePath);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File downloaded successfully')),
        );
      } else {
        throw Exception(
            'Export failed with status code: ${jsonResponse.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      print('Error exporting state group summary report: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error exporting state group summary report: $e')),
      );
    }
  }

  void createNotification(String? filePath) {
    if (filePath != null && filePath.isNotEmpty) {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId++,
          channelKey: "sb_channel_key",
          title: "State Summary Report",
          body: filePath,
        ),
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
            type:
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
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

  String formatNumber(double? number) {
    NumberFormat formatter = NumberFormat("#,##,##,##,##,##,##0.00", "en_US");
    return formatter.format(number);
  }
}

class DownloadManager {
  static void addCompletedDownload(
      String filePath, String fileName, String title, String mimeType) {
    // Implement your method to add completed download here
  }
}
