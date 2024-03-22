// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  late Future<List<StateListResult>> apiData;

  @override
  void initState() {
    super.initState();
    apiData = getStateData();
  }

  Future<List<StateListResult>> getStateData() async {
    try {
      String apiUrl =
          'http://182.18.157.215/Srikar_Biotech_Dev/API/api/SAP/GetGroupSummaryReportByState';
      final requestBody = {
        "FromDate": "2024-03-20",
        "ToDate": "2024-03-22",
        "CompanyId": 1
      };

      debugPrint('____state selection__${jsonEncode(requestBody)}');
      final jsonResponse = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(requestBody),
        headers: {
          'Content-Type': 'application/json',
        },
      );

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
      throw Exception('Catch: Api got failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: FutureBuilder(
        future: apiData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else if (snapshot.hasError) {
            return const Center(
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
                      _dateSection(),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: dateField(
              context,
              fromDateText,
                  () => _selectfromDate(context),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: dateField(
              context,
              toDateText,
                  () => _selectDate(context),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(10),
                height: 40.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.0),
                  color: const Color(0xFFe78337),
                ),
                child: const Center(
                  child: Text(
                    'Submit',
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

  Widget _stateSection(List<StateListResult> data) {
    return Expanded(
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
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
                  color:
                  selectedCardIndex == index ? const Color(0xFFfff5ec) : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: BorderSide(
                      color: selectedCardIndex == index
                          ? const Color(0xFFe98d47)
                          : Colors.grey,
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
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Row(
                                        // mainAxisAlignment:
                                        //     MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'OB: ',
                                            style: CommonUtils.Mediumtext_12,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            data[index].ob.toString(),
                                            style: CommonUtils.Mediumtext_12_0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: 5,
                                ),

                                // row2
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        // mainAxisAlignment:
                                        //     MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Sales: ',
                                            style: CommonUtils.Mediumtext_12,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            data[index].sales.toString(),
                                            style: CommonUtils.Mediumtext_12_0,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Row(
                                        // mainAxisAlignment:
                                        //     MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Returns: ',
                                            style: CommonUtils.Mediumtext_12,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            data[index].returns.toString(),
                                            style: CommonUtils.Mediumtext_12_0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: 5,
                                ),

                                // row3
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        // mainAxisAlignment:
                                        //     MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Receipts: ',
                                            style: CommonUtils.Mediumtext_12,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            data[index].receipts.toString(),
                                            style: CommonUtils.Mediumtext_12_0,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Row(
                                        // mainAxisAlignment:
                                        //     MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Others: ',
                                            style: CommonUtils.Mediumtext_12,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            data[index].others.toString(),
                                            style: CommonUtils.Mediumtext_12_0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                // row4
                                Row(
                                  children: [
                                    const Text(
                                      'Closing: ',
                                      style: CommonUtils.Mediumtext_12,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      data[index].closing.toString(),
                                      style: CommonUtils.Mediumtext_12_0,
                                    ),
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

  Future<void> _selectfromDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime initialDate = selectedFromDate ?? currentDate;

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
        setState(() {
          fromDateText = formattedDate;
        });

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
        setState(() {
          toDateText = formattedDate;
        });

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

  void _downloadFile(BuildContext context) async {
    const url =
        'https://file-examples.com/wp-content/storage/2017/02/file_example_XLS_10.xlsx';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Directory downloadsDirectory =
      Directory('/storage/emulated/0/Download/Srikar_Groups');
      if (!downloadsDirectory.existsSync()) {
        downloadsDirectory.createSync(recursive: true);
      }
      String filePath = downloadsDirectory.path;

      final File file = File('$filePath/file_example_XLS_10.xls');
      await file.create(recursive: true);
      await file.writeAsBytes(response.bodyBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File downloaded successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to download file')),
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
