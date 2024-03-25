import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:srikarbiotech/Common/CommonUtils.dart';
import 'package:srikarbiotech/HomeScreen.dart';
import 'package:srikarbiotech/Model/DealerSummaryModel.dart';
import 'package:http/http.dart' as http;

class DealerSummaryScreen extends StatefulWidget {
  final String fromDateText;
  final String toDateText;
  final String stateName;
  final String slpName;
  const DealerSummaryScreen(
      {super.key,
      required this.fromDateText,
      required this.toDateText,
      required this.stateName,
      required this.slpName});

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
      String apiUrl =
          'http://182.18.157.215/Srikar_Biotech_Dev/API/api/SAP/GetGroupSummaryReportByParty';
      final requestBody = {
        "FromDate": "2024-03-20",
        "ToDate": "2024-03-22",
        "SOName": "-No Sales Employee-",
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
          List<DealerSummarylist> dealerSummarylist = listResult
              .map((house) => DealerSummarylist.fromJson(house))
              .toList();
          return dealerSummarylist;
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
              List<DealerSummarylist> data = snapshot.data!;
              if (data.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      _dateSection(),
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
                'Dealer Summary',
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
                      'slp: ',
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
                child: Column(
                  children: [
                    // row1
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Row(
                          children: [
                            const Expanded(
                                child: Text(
                              'Card Code',
                              style: CommonUtils.Mediumtext_12,
                            )),
                            Expanded(
                                child: Text(
                              data[index].cardCode!,
                              style: CommonUtils.Mediumtext_12_0,
                            )),
                          ],
                        )),
                        Expanded(
                            child: Row(
                          children: [
                            const Expanded(
                                child: Text(
                              'Slp Code',
                              style: CommonUtils.Mediumtext_12,
                            )),
                            Expanded(
                                child: Text(
                              data[index].slpCode.toString(),
                              style: CommonUtils.Mediumtext_12_0,
                            )),
                          ],
                        )),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    // row2  // single value
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Row(
                          children: [
                            const Expanded(
                                child: Text(
                              'Card Name',
                              style: CommonUtils.Mediumtext_12,
                            )),
                            Expanded(
                                child: Text(
                              data[index].cardName!,
                              style: CommonUtils.Mediumtext_12_0,
                            )),
                          ],
                        )),
                      ],
                    ),

                    const SizedBox(
                      height: 8,
                    ),
                    // row2  // single value
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Row(
                          children: [
                            const Expanded(
                                child: Text(
                              'Slp Name',
                              style: CommonUtils.Mediumtext_12,
                            )),
                            Expanded(
                                child: Text(
                              data[index].slpName!,
                              style: CommonUtils.Mediumtext_12_0,
                            )),
                          ],
                        )),
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
                                child: Text(
                              'OB',
                              style: CommonUtils.Mediumtext_12,
                            )),
                            Expanded(
                                child: Text(
                              data[index].ob.toString(),
                              style: CommonUtils.Mediumtext_12_0,
                            )),
                          ],
                        )),
                        Expanded(
                            child: Row(
                          children: [
                            const Expanded(
                                child: Text(
                              'Sales',
                              style: CommonUtils.Mediumtext_12,
                            )),
                            Expanded(
                                child: Text(
                              data[index].sales.toString(),
                              style: CommonUtils.Mediumtext_12_0,
                            )),
                          ],
                        )),
                        // Flexible(
                        //   child: ,
                        // ),
                        // const Icon(
                        //   Icons.chevron_right,
                        //   color: Colors.orange,
                        // ),
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
                                child: Text(
                              'Returns',
                              style: CommonUtils.Mediumtext_12,
                            )),
                            Expanded(
                                child: Text(
                              data[index].returns.toString(),
                              style: CommonUtils.Mediumtext_12_0,
                            )),
                          ],
                        )),
                        Expanded(
                            child: Row(
                          children: [
                            const Expanded(
                                child: Text(
                              'Receipts',
                              style: CommonUtils.Mediumtext_12,
                            )),
                            Expanded(
                                child: Text(
                              data[index].receipts.toString(),
                              style: CommonUtils.Mediumtext_12_0,
                            )),
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
                                child: Text(
                              'Others',
                              style: CommonUtils.Mediumtext_12,
                            )),
                            Expanded(
                                child: Text(
                              data[index].others.toString(),
                              style: CommonUtils.Mediumtext_12_0,
                            )),
                          ],
                        )),
                        Expanded(
                            child: Row(
                          children: [
                            const Expanded(
                                child: Text(
                              'Closing',
                              style: CommonUtils.Mediumtext_12,
                            )),
                            Expanded(
                                child: Text(
                              data[index].closing.toString(),
                              style: CommonUtils.Mediumtext_12_0,
                            )),
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

  Widget _downloadedBtn() {
    return FloatingActionButton(
      onPressed: () {
        // _downloadFile(context);
        // Add your download functionality here
      },
      backgroundColor: const Color(0xFFe78337),
      child: const Icon(Icons.download), // Change the color as needed
    );
  }
}
