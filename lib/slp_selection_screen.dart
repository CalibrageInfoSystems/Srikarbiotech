import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:srikarbiotech/Common/CommonUtils.dart';
import 'package:srikarbiotech/HomeScreen.dart';
import 'package:srikarbiotech/Model/slp_selection_model.dart';
import 'package:http/http.dart' as http;
import 'package:srikarbiotech/Model/state_selection_model.dart';

import 'DealerSummaryScreen.dart';

class SlpSelection extends StatefulWidget {
  final String fromDateText;
  final String toDateText;
  final String state;
  const SlpSelection(
      {super.key,
        required this.fromDateText,
        required this.toDateText,
        required this.state});

  @override
  State<SlpSelection> createState() => _SlpSelectionState();
}

class _SlpSelectionState extends State<SlpSelection> {
  late Future<List<SlpListResult>> apiData;

  @override
  void initState() {
    super.initState();
    apiData = getSlpData();
  }

  int selectedCardIndex = -1;

  Future<List<SlpListResult>> getSlpData() async {
    try {
      DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(widget.fromDateText);
      String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      DateTime parsedDate2 = DateFormat('dd-MM-yyyy').parse(widget.toDateText);
      String formattedtoDate = DateFormat('yyyy-MM-dd').format(parsedDate2);
      print('formattedDate: $formattedDate');
      print('formattedtoDate: $formattedtoDate');

      String apiUrl =
          'http://182.18.157.215/Srikar_Biotech_Dev/API/api/SAP/GetGroupSummaryReportBySlp';
      final requestBody = {
        "FromDate": formattedDate,
        "ToDate": formattedtoDate,
        "State": widget.state,
        "CompanyId": 1
      };

      debugPrint('slp selection__${jsonEncode(requestBody)}');
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
          List<SlpListResult> slpResult =
          listResult.map((house) => SlpListResult.fromJson(house)).toList();
          return slpResult;
        } else {
          throw Exception('SLP list is null');
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
              List<SlpListResult> data = snapshot.data!;
              if (data.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                          left: 5,
                          right: 5,
                          top: 10,
                        ),
                        width: MediaQuery.of(context).size.width,
                        //   height: MediaQuery.of(context).size.height,
                        child: _dateSection(),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      _slpSection(data),
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
      floatingActionButton: FutureBuilder(
        future: apiData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(); // Return an empty SizedBox while waiting for data
          } else if (snapshot.hasError) {
            return const SizedBox(); // Return an empty SizedBox if an error occurred
          } else {
            if (snapshot.hasData) {
              List<SlpListResult> data =
              snapshot.data!.cast<SlpListResult>();
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
      // floatingActionButton: _downloadedBtn(),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                'Slp Selection',
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                // padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  // border: Border.all(
                  //   color: CommonUtils.orangeColor,
                  // ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    const Text(
                      'From Date: ',
                      style: CommonUtils.Mediumtext_12,
                    ),
                    Text(
                      widget.fromDateText,
                      style: CommonUtils.Mediumtext_12_0,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                // padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  // border: Border.all(
                  //   color: CommonUtils.orangeColor,
                  // ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    const Text(
                      'To Date: ',
                      style: CommonUtils.Mediumtext_12,
                    ),
                    Text(
                      widget.toDateText,
                      style: CommonUtils.Mediumtext_12_0,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                // padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  // border: Border.all(
                  //   color: CommonUtils.orangeColor,
                  // ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    const Text(
                      'State: ',
                      style: CommonUtils.Mediumtext_12,
                    ),
                    Text(
                      widget.state,
                      style: CommonUtils.Mediumtext_12_0,
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _slpSection(List<SlpListResult> data) {
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DealerSummaryScreen(
                        fromDateText: widget.fromDateText,
                        toDateText: widget.toDateText,
                        slpName: data[index].slpCode.toString(),
                        stateName: widget.state,
                        soname: data[index].slpName!,
                      ),
                    ),
                  );
                  // navigate to slp selection screen
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => const SlpSelection(),
                  //   ),
                  // );
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
                                    // Expanded(
                                    //   child: Row(
                                    //     // mainAxisAlignment:
                                    //     //     MainAxisAlignment.spaceBetween,
                                    //     children: [
                                    //       const Text(
                                    //         'Slp Name: ',
                                    //         style: CommonUtils.Mediumtext_12,
                                    //         overflow: TextOverflow.ellipsis,
                                    //       ),
                                    //       Text(
                                    //         data[index].slpName!,
                                    //         style: CommonUtils.Mediumtext_12_0,
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    Expanded(
                                        child: Row(
                                          children: [
                                            const Expanded(
                                              flex: 1,
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                    EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                    child: Text(
                                                      'Slp Name',
                                                      style: CommonUtils.Mediumtext_12,
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
                                                        3, 0, 0, 0),
                                                    child: Text(
                                                      data[index].slpName!,
                                                      style:
                                                      CommonUtils.Mediumtext_12_0,
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

                                // row2
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Expanded(
                                    //   child: Row(
                                    //     // mainAxisAlignment:
                                    //     //     MainAxisAlignment.spaceBetween,
                                    //     children: [
                                    //       // const Text(
                                    //       //   'Slp Code: ',
                                    //       //   style: CommonUtils.Mediumtext_12,
                                    //       //   overflow: TextOverflow.ellipsis,
                                    //       // ),
                                    //       // Text(
                                    //       //   data[index].slpCode.toString(),
                                    //       //   style: CommonUtils.Mediumtext_12_0,
                                    //       // ),
                                    //
                                    //     ],
                                    //   ),
                                    // ),
                                    Expanded(
                                        child: Row(
                                          children: [
                                            const Expanded(
                                              flex: 1,
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                    EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                    child: Text(
                                                      'Slp Code',
                                                      style: CommonUtils.Mediumtext_12,
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
                                                        3, 0, 0, 0),
                                                    child: Text(
                                                      '${data[index].slpCode}',
                                                      style:
                                                      CommonUtils.Mediumtext_12_0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        )),
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
                                                      style: CommonUtils.Mediumtext_12,
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
                                                      '₹${data[index].ob}',
                                                      style:
                                                      CommonUtils.Mediumtext_12_0,
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
                                                      style: CommonUtils.Mediumtext_12,
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
                                                      '₹${data[index].sales}',
                                                      style:
                                                      CommonUtils.Mediumtext_12_0,
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
                                                      style: CommonUtils.Mediumtext_12,
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
                                                      '₹${data[index].returns}',
                                                      style:
                                                      CommonUtils.Mediumtext_12_0,
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
                                                      style: CommonUtils.Mediumtext_12,
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
                                                      '₹${data[index].receipts}',
                                                      style:
                                                      CommonUtils.Mediumtext_12_0,
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
                                                      style: CommonUtils.Mediumtext_12,
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
                                                      '₹${data[index].others}',
                                                      style:
                                                      CommonUtils.Mediumtext_12_0,
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
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.fromLTRB(
                                                        0, 0, 0, 0),
                                                    child: Text(
                                                      '₹${data[index].closing}',
                                                      style:
                                                      CommonUtils.Mediumtext_12_0,
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

  Widget _downloadedBtn() {
    Color buttonColor = const Color(0xFFe78337); // Set your desired color here

    return ClipRRect(
      borderRadius: BorderRadius.circular(10), // Adjust the radius as needed
      child: SizedBox(
        width: 40, // Adjust width as needed
        height: 40, // Adjust height as needed
        child: FloatingActionButton(
          onPressed: () {
            //  _downloadFile(context);
            // Add your download functionality here
          },
          backgroundColor: buttonColor,
          mini: true,
          shape: const BeveledRectangleBorder(), // Make the button mini
          child: const Icon(Icons.download), // Beveled rectangle shape
        ),
      ),
    );
  }

  Widget downloadedBtn(List<SlpListResult> stateResult) {
    Color buttonColor = const Color(0xFFe78337); // Set your desired color here

    return ClipRRect(
      borderRadius: BorderRadius.circular(10), // Adjust the radius as needed
      child: SizedBox(
        width: 40, // Adjust width as needed
        height: 40, // Adjust height as needed
        child: FloatingActionButton(
          onPressed: () {
            // Call the exportStateGroupSummaryReport function when button is clicked
            exportStateGroupSummaryReport(stateResult);
          },
          backgroundColor: buttonColor,
          mini: true,
          shape: const BeveledRectangleBorder(), // Make the button mini
          child: const Icon(Icons.download), // Beveled rectangle shape
        ),
      ),
    );
  }

  Future<void> exportStateGroupSummaryReport(
      List<SlpListResult> slpresultResult) async {
    try {
      // Request storage permission

      // Create the request body directly from stateResult
      final requestBody = slpresultResult
          .map((slpresult) => {
        'SlpCode': slpresult.slpCode,
        'SlpName':slpresult.slpName,
        'State': slpresult.state,
        'OB':slpresult.ob,
        'Sales': slpresult.sales,
        'Returns': slpresult.returns,
        'Receipts': slpresult.receipts,
        'Others': slpresult.others,
        'Closing': slpresult.closing,
      })
          .toList();

      // API endpoint for exporting state group summary report
      const apiUrl = 'http://182.18.157.215/Srikar_Biotech_Dev/API/api/SAP/ExportSlpGroupSummaryReport';

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

        Directory downloadsDirectory =
        Directory('/storage/emulated/0/Download/Srikar_Groups/GroupSummaryReports/');
        if (!downloadsDirectory.existsSync()) {
          downloadsDirectory.createSync(recursive: true);
        }
        String filePath = downloadsDirectory.path;

        List<int> pdfBytes = base64.decode(jsonData['response']);
        DateTime now = DateTime.now();
        String timestamp = DateFormat('yyyyMMdd_HHmmss').format(now);
        String filename = 'slpReports_$timestamp.xlsx';
        final File file = File('$filePath/$filename');
        //  final File file = File('$filePath/GroupSummary_${DateTime.now().toString()}.xls');
        await file.create(recursive: true);
        await file.writeAsBytes(pdfBytes);

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
}
