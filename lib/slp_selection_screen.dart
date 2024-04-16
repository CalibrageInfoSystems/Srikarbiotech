// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:srikarbiotech/Common/CommonUtils.dart';
import 'package:srikarbiotech/Common/styles.dart';
import 'package:srikarbiotech/HomeScreen.dart';
import 'package:srikarbiotech/Model/slp_selection_model.dart';
import 'package:http/http.dart' as http;

import 'DealerSummaryScreen.dart';
import 'notification_controller.dart';

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
  String? downloadedFilePath;
  int selectedCardIndex = -1;
  int notificationId = 1;
  @override
  void initState() {
    super.initState();
    apiData = getSlpData();
    setListenersForUserActions();
  }

  void setListenersForUserActions() async {
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
      body: Container(
        color: CommonStyles.greyShade,
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: _dateSection(),
            ),
            const SizedBox(
              height: 5,
            ),
            Expanded(
              child: FutureBuilder(
                future: apiData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CommonStyles.progressIndicator);
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Error occurred.',
                        style: CommonStyles.txSty_12b_fb,
                      ),
                    );
                  } else {
                    if (snapshot.hasData) {
                      List<SlpListResult> data = snapshot.data!;
                      if (data.isNotEmpty) {
                        return _slpSection(data);
                      } else {
                        return const Center(
                          child: Text(
                            'Collection is empty.',
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
              List<SlpListResult> data = snapshot.data!.cast<SlpListResult>();
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
                'Slp Selection',
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    const Text(
                      'From Date: ',
                      style: CommonStyles.txSty_12b_fb,
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
                      style: CommonStyles.txSty_12b_fb,
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
                      style: CommonStyles.txSty_12b_fb,
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
    return Column(
      children: [
        Expanded(
            child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            return GestureDetector(
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
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
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
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 0, 0),
                                              child: Text(
                                                'Slp Code',
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
        )),
      ],
    );
  }

  Widget downloadedBtn(List<SlpListResult> stateResult) {
    Color buttonColor = const Color(0xFFe78337);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 40,
        height: 40,
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

  Future<void> exportStateGroupSummaryReport(
      List<SlpListResult> slpresultResult) async {
    try {
      final requestBody = slpresultResult
          .map((slpresult) => {
                'SlpCode': slpresult.slpCode,
                'SlpName': slpresult.slpName,
                'State': slpresult.state,
                'OB': slpresult.ob,
                'Sales': slpresult.sales,
                'Returns': slpresult.returns,
                'Receipts': slpresult.receipts,
                'Others': slpresult.others,
                'Closing': slpresult.closing,
              })
          .toList();
      const apiUrl =
          'http://182.18.157.215/Srikar_Biotech_Dev/API/api/SAP/ExportSlpGroupSummaryReport';

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
            '/storage/emulated/0/Download/Srikar_Groups/GroupSummaryReports');
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
          title: "Slp Summary Report",
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
          OpenResult result = await OpenFile.open(
            downloadedFilePath!,
            type:
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          );
          if (result.type == ResultType.noAppToOpen) {
            print('No suitable app found to open the file.');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('No suitable app found to open the file.')),
            );
          }
          if (result.type == ResultType.permissionDenied) {
            print('permission required to view the file.');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('permission required to view the file.')),
            );
          } else {
            print('${result.type}');
          }
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
