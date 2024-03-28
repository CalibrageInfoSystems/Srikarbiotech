import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:srikarbiotech/Common/CommonUtils.dart';
import 'package:srikarbiotech/HomeScreen.dart';
import 'package:srikarbiotech/Model/DealerSummaryModel.dart';
import 'package:http/http.dart' as http;

class DealerSummaryScreen extends StatefulWidget {
  final String fromDateText;
  final String toDateText;
  final String stateName;
  final String soname;
  final String slpName;
  const DealerSummaryScreen({super.key, required this.fromDateText, required this.toDateText, required this.stateName, required this.slpName, required this.soname});

  @override
  State<DealerSummaryScreen> createState() => _DealerSummaryScreenState();
}

class _DealerSummaryScreenState extends State<DealerSummaryScreen> {
  late Future<List<DealerSummarylist>> apiData;

  @override
  void initState() {
    super.initState();
    apiData = getSlpData();
  }

  int selectedCardIndex = -1;

  Future<List<DealerSummarylist>> getSlpData() async {
    try {
      DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(widget.fromDateText);
      String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      DateTime parsedDate2 = DateFormat('dd-MM-yyyy').parse(widget.toDateText);
      String formattedtoDate = DateFormat('yyyy-MM-dd').format(parsedDate2);
      print('formattedDate: $formattedDate');
      print('formattedtoDate: $formattedtoDate');
      String apiUrl = 'http://182.18.157.215/Srikar_Biotech_Dev/API/api/SAP/GetGroupSummaryReportByParty';
      final requestBody = {"FromDate": "$formattedDate", "ToDate": "$formattedtoDate", "SOName": "${widget.soname}", "CompanyId": 1};

      debugPrint('slp selection__${jsonEncode(requestBody)}');
      final jsonResponse = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(requestBody),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (jsonResponse.statusCode == 200) {
        // final Map<String, dynamic> data = json.decode(jsonResponse.body);
        //
        // if (data['response']['listResult'] != null) {
        //   final List<dynamic> listResult = data['response']['listResult'];
        //   List<DealerSummarylist> dealerSummarylist = listResult.map((house) => DealerSummarylist.fromJson(house)).toList();
        //   return dealerSummarylist;
        // } else {
        //   throw Exception('SLP list is null');
        // }
        final Map<String, dynamic> data = json.decode(jsonResponse.body);

        if (data['response']['listResult'] != null) {
          final List<dynamic> listResult = data['response']['listResult'];
          List<DealerSummarylist> dealerSummarylist = listResult.map((house) => DealerSummarylist.fromJson(house)).toList();
          return dealerSummarylist;
        } else {
          throw Exception('SLP list is null');
        }
      } else {
        throw Exception('Api failed');
      }
    } catch (e) {
      print('dealersapierror:$e');
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
              List<DealerSummarylist> data = snapshot.data!;
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
                      _dealerSummarySection(data),
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
                List<DealerSummarylist> data =
                snapshot.data!.cast<DealerSummarylist>();
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
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat
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
                'Party Summary',
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
                      'Slp Code: ',
                      style: CommonUtils.Mediumtext_12,
                    ),
                    Text(
                      widget.slpName,
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
                      'State: ',
                      style: CommonUtils.Mediumtext_12,
                    ),
                    Text(
                      widget.stateName,
                      style: CommonUtils.Mediumtext_12_0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dealerSummarySection(List<DealerSummarylist> data) {
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
              // Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (context) => const SlpSelection(),
              //   ),
              // );
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
                child: Column(
                  children: [
                    // row1
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Expanded(
                    //         child: Row(
                    //       children: [
                    //         Text(
                    //           'Card Name',
                    //           style: CommonUtils.Mediumtext_12,
                    //         ),
                    //         SizedBox(
                    //           width: 10,
                    //         ),
                    //         Flexible(
                    //           child: Text(
                    //             data[index].cardName!,
                    //             style: CommonUtils.Mediumtext_12_0,
                    //             overflow: TextOverflow.clip, // Optional: handle overflow with ellipsis
                    //           ),
                    //         ),
                    //       ],
                    //     )),
                    //   ],
                    // ),
                    Row(
                      children: [
                        // Expanded(
                        //   flex: 4,
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       const Padding(
                        //         padding: EdgeInsets.fromLTRB(12, 5, 0, 0),
                        //         child: Text(
                        //           "Card Name",
                        //           style: CommonUtils.Mediumtext_12,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                child: Text(
                                  data[index].cardName!,
                                  style: CommonUtils.Mediumtext_12_0,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Expanded(
                    //         child: Row(
                    //       children: [
                    //         const Expanded(
                    //             child: Text(
                    //           'Card Code',
                    //           style: CommonUtils.Mediumtext_12,
                    //         )),
                    //         Expanded(
                    //             child: Text(
                    //           data[index].cardCode!,
                    //           style: CommonUtils.Mediumtext_12_0,
                    //         )),
                    //       ],
                    //     )),
                    //     Expanded(
                    //         child: Row(
                    //       children: [
                    //         const Expanded(
                    //             child: Text(
                    //           'Slp Code',
                    //           style: CommonUtils.Mediumtext_12,
                    //         )),
                    //         Expanded(
                    //             child: Text(
                    //           data[index].slpCode.toString(),
                    //           style: CommonUtils.Mediumtext_12_0,
                    //         )),
                    //       ],
                    //     )),
                    //   ],
                    // ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Text(
                                  "Party Code",
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
                                padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                child: Text(
                                  data[index].cardCode!,
                                  style: CommonUtils.Mediumtext_12_0,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    //  SizedBox(
                    //   height: 8,
                    // ),
                    //

                    const SizedBox(
                      height: 8,
                    ),
                    // row2  // single value
                    Row(
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(3, 0, 0, 0),
                                child: Text(
                                  data[index].slpName!,
                                  style: CommonUtils.Mediumtext_12_0,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),

                    const SizedBox(
                      height: 8,
                    ),
                    // row3

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Row(
                              children: [
                                const Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
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
                                        padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        child: Text(
                                          '₹${data[index].ob}',
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
                                const Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
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
                                        padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        child: Text(
                                          '₹${data[index].sales}',
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
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
                                        padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        child: Text(
                                          '₹${data[index].returns}',
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
                                const Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
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
                                        padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        child: Text(
                                          '₹${data[index].receipts}',
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
                                const Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
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
                                        padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        child: Text(
                                          '₹${data[index].others}',
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
                                const Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
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
                                        padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        child: Text(
                                          '₹${data[index].closing}',
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
          ),
        );
      },
        ));
  }

  // Widget _downloadedBtn() {
  //   return FloatingActionButton(
  //     onPressed: () {
  //       // _downloadFile(context);
  //       // Add your download functionality here
  //     },
  //     backgroundColor: const Color(0xFFe58338),
  //     child: const Icon(Icons.download), // Change the color as needed
  //   );
  // }

  Widget downloadedBtn(List<DealerSummarylist> partyResult) {
    Color buttonColor = const Color(0xFFe78337); // Set your desired color here

    return ClipRRect(
      borderRadius: BorderRadius.circular(10), // Adjust the radius as needed
      child: SizedBox(
        width: 40, // Adjust width as needed
        height: 40, // Adjust height as needed
        child: FloatingActionButton(
          onPressed: () {
            // Call the exportStateGroupSummaryReport function when button is clicked
            exportStateGroupSummaryReport(partyResult);
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
      List<DealerSummarylist>PartyResult) async {
    try {
      // Request storage permission

      // Create the request body directly from stateResult
      final requestBody = PartyResult
          .map((partyResult) => {

        "CardCode": partyResult.cardCode,
        "CardName": partyResult.cardName,
        'SlpCode': partyResult.slpCode,
        'SlpName':partyResult.slpName,
        'OB':partyResult.ob,
        'Sales': partyResult.sales,
        'Returns': partyResult.returns,
        'Receipts': partyResult.receipts,
        'Others': partyResult.others,
        'Closing': partyResult.closing,
      })
          .toList();

      // API endpoint for exporting state group summary report
      const apiUrl = 'http://182.18.157.215/Srikar_Biotech_Dev/API/api/SAP/ExportPartyGroupSummaryReport';

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
