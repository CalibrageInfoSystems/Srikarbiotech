import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:srikarbiotech/Common/CommonUtils.dart';
import 'package:srikarbiotech/HomeScreen.dart';
import 'package:http/http.dart' as http;
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            dateSection(),
            const SizedBox(
              height: 10,
            ),
            stateSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _downloadFile(context);
          // Add your download functionality here
        },
        child: Icon(Icons.download),
        backgroundColor: Color(0xFFe78337), // Change the color as needed
      ),
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                    );
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
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

  Widget dateSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child:
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: buildDateInput(
              context,
              'From Date',
              fromDateController,
                  () => _selectfromDate(context, fromDateController),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: buildDateInput(
              context,
              'To Date',
              toDateController,
                  () => _selectDate(context, toDateController),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Handle the button tap
              },
              child: Container(
                height: 40.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.0),
                  color: Color(0xFFe78337),
                ),
                child: Center(
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

  Widget stateSection() {
    return Expanded(
        child: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) {
            return SizedBox(
              // margin: const EdgeInsets.symmetric(
              //     horizontal: 16.0, vertical: 4.0),
              child: GestureDetector(
                onTap: () {
                  // setState(() {
                  //   selectedCardIndex = index;
                  // });
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
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Padding(
                            padding: EdgeInsets.only(right: 10),
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
                                          Text(
                                            'State: ',
                                            style: CommonUtils.Mediumtext_12,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'data',
                                            style: CommonUtils.Mediumtext_12_0,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Row(
                                        // mainAxisAlignment:
                                        //     MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'OB: ',
                                            style: CommonUtils.Mediumtext_12,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'data',
                                            style: CommonUtils.Mediumtext_12_0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(
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
                                          Text(
                                            'Sales: ',
                                            style: CommonUtils.Mediumtext_12,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'data',
                                            style: CommonUtils.Mediumtext_12_0,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Row(
                                        // mainAxisAlignment:
                                        //     MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Returns: ',
                                            style: CommonUtils.Mediumtext_12,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'data',
                                            style: CommonUtils.Mediumtext_12_0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(
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
                                          Text(
                                            'Receipts: ',
                                            style: CommonUtils.Mediumtext_12,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'data',
                                            style: CommonUtils.Mediumtext_12_0,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Row(
                                        // mainAxisAlignment:
                                        //     MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Others: ',
                                            style: CommonUtils.Mediumtext_12,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'data',
                                            style: CommonUtils.Mediumtext_12_0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                // row4
                                Row(
                                  children: [
                                    Text(
                                      'Closing: ',
                                      style: CommonUtils.Mediumtext_12,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'data',
                                      style: CommonUtils.Mediumtext_12_0,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Icon(
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
            padding: EdgeInsets.only(top: 0.0, left: 5.0, right: 0.0),
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
          SizedBox(height: 8.0),
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 40.0,
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
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0, top: 0.0),
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: controller,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
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


  Future<void> _selectfromDate(
      BuildContext context,
      TextEditingController controller,
      ) async {
    DateTime currentDate = DateTime.now();
    // DateTime initialDate;
    DateTime initialDate = selectedFromDate ?? currentDate;


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

  void _downloadFile(BuildContext context) async {
    final url = 'https://file-examples.com/wp-content/storage/2017/02/file_example_XLS_10.xlsx';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Directory downloadsDirectory = Directory('/storage/emulated/0/Download/Srikar_Groups');
      if (!downloadsDirectory.existsSync()) {
        downloadsDirectory.createSync(recursive: true);
      }
      String filePath = '${downloadsDirectory.path}';


      final File file = File('$filePath/file_example_XLS_10.xls');
      await file.create(recursive: true);
      await file.writeAsBytes(response.bodyBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File downloaded successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download file')),
      );
    }
  }

}
