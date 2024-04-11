// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:srikarbiotech/Common/CommonUtils.dart';
import 'package:srikarbiotech/Common/styles.dart';

import 'package:srikarbiotech/Services/api_config.dart';
import 'dart:convert';

import 'Common/SharedPrefsData.dart';
import 'CreateCollectionscreen.dart';
import 'HomeScreen.dart';
import 'Ledgerscreen.dart';
import 'Model/Dealer.dart';
import 'WareHouseScreen.dart';

class Selectpartyscreen extends StatefulWidget {
  String from;
  Selectpartyscreen({super.key, required this.from});

  @override
  Selectparty_screen createState() => Selectparty_screen();
}

class Selectparty_screen extends State<Selectpartyscreen> {
  bool _isLoading = false;
  List<Dealer> dealers = [];
  late String screenFrom;
  int selectedCardIndex = -1; // Variable to track selected card index
  int CompneyId = 0;
  String? userId = "";
  String? slpCode = "";
  List<Dealer> filteredDealers = [];
  TextEditingController searchController = TextEditingController();
  // SharedPreferences prefs = await SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    CommonUtils.checkInternetConnectivity().then(
      (isConnected) {
        if (isConnected) {
          getshareddata();
          print('The Internet Is Connected');
        } else {
          print('The Internet Is not  Connected');
          CommonUtils.showCustomToastMessageLong(
              'Please check your internet  connection', context, 1, 4);
        }
      },
    );

//getslpcode();

    print("screenFrom: ${widget.from}");

    screenFrom = widget.from.trim();
    print("screenFrom: $screenFrom");
  }

  Future<void> fetchData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final apiUrl =
          baseUrl + GetAllDealersBySlpCode + '$CompneyId' + "/" + '$slpCode';
      print("apiUrl: $apiUrl");

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final dynamic listResult = data['response']['listResult'];

        if (listResult != null) {
          final List<dynamic> listResult = data['response']['listResult'];

          setState(() {
            dealers = listResult.map((json) => Dealer.fromJson(json)).toList();
            filteredDealers = List.from(dealers);
          });
        } else {
          print("listResult is null");
          setState(() {
            dealers = [];
            filteredDealers = [];
          });
        }

        setState(() {
          _isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load data. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions here
      print('Error in fetchData: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    print('first textview clicked');
                  },
                  child: Expanded(
                    child: TextFormField(
                      controller: searchController,
                      onChanged: (value) {
                        filterDealers();
                      },
                      keyboardType: TextInputType.name,
                      style: CommonStyles.txSty_12b_fb,
                      decoration: InputDecoration(
                        hintText: 'Search for Party Name or Code or City',
                        hintStyle: CommonStyles.txSty_14bs_fb,
                        suffixIcon: const Icon(Icons.search),
                        border: CommonUtils.borderForSearch,
                        focusedBorder: CommonUtils.focusedBorder,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
              ],
            ),
            // Add Expanded around the ListView.builder
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CommonStyles.progressIndicator,
                    )
                  : filteredDealers.isEmpty // Check if filteredDealers is empty
                      ? const Center(
                          child: Text(
                            'No Data Found',
                            style: CommonStyles.txSty_12b_fb,
                          ), // Display this text when filteredDealers is empty
                        )
                      : ListView.builder(
                          itemCount: filteredDealers.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCardIndex =
                                      index; // Update selected index
                                });
                                // onTap: () {
                                //   if (!FocusScope.of(context).hasPrimaryFocus) {
                                //     return;
                                //   }
                                print(
                                    "Tapped on dealer with cardName: ${filteredDealers[index].cardName}");
                                print("screenFrom: $screenFrom");

                                if (screenFrom == "CreateOrder") {
                                  print(
                                      "Tapped on dealer with cardName:2 ${filteredDealers[index].cardName}");
                                  try {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WareHouseScreen(
                                            from: 'CreateOrder',
                                            cardName:
                                                filteredDealers[index].cardName,
                                            cardCode:
                                                filteredDealers[index].cardCode,
                                            address: filteredDealers[index]
                                                .fullAddress,
                                            state: filteredDealers[index].state,
                                            phone: filteredDealers[index]
                                                .phoneNumber,
                                            proprietorName:
                                                filteredDealers[index]
                                                    .proprietorName,
                                            gstRegnNo: filteredDealers[index]
                                                .gstRegnNo,
                                            creditLine: filteredDealers[index]
                                                .creditLine,
                                            balance:
                                                filteredDealers[index].balance),
                                      ),
                                    );
                                  } catch (e) {
                                    print("Error navigating: $e");
                                  }
                                } else if (screenFrom == "CreateCollections") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CreateCollectionscreen(
                                              cardName: filteredDealers[index]
                                                  .cardName,
                                              cardCode: filteredDealers[index]
                                                  .cardCode,
                                              address: filteredDealers[index]
                                                  .fullAddress,
                                              state:
                                                  filteredDealers[index].state,
                                              phone: filteredDealers[index]
                                                  .phoneNumber,
                                              proprietorName:
                                                  filteredDealers[index]
                                                      .proprietorName,
                                              code: filteredDealers[index]
                                                  .cardCode,
                                              gstRegnNo: filteredDealers[index]
                                                  .gstRegnNo),
                                    ),
                                  );
                                } else if (screenFrom == "Ledger") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Ledgerscreen(
                                          cardName:
                                              filteredDealers[index].cardName,
                                          cardCode:
                                              filteredDealers[index].cardCode,
                                          address: filteredDealers[index]
                                              .fullAddress,
                                          state: filteredDealers[index].state,
                                          phone: filteredDealers[index]
                                              .phoneNumber,
                                          proprietorName: filteredDealers[index]
                                              .proprietorName,
                                          gstRegnNo:
                                              filteredDealers[index].gstRegnNo,
                                          creditLine:
                                              filteredDealers[index].creditLine,
                                          balance:
                                              filteredDealers[index].balance),
                                    ),
                                  );
                                } else if (screenFrom == "CreatereturnOrder") {
                                  print(
                                      "Tapped on dealer with cardName:2 ${filteredDealers[index].cardName}");
                                  try {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WareHouseScreen(
                                            from: 'CreatereturnOrder',
                                            cardName:
                                                filteredDealers[index].cardName,
                                            cardCode:
                                                filteredDealers[index].cardCode,
                                            address: filteredDealers[index]
                                                .fullAddress,
                                            state: filteredDealers[index].state,
                                            phone: filteredDealers[index]
                                                .phoneNumber,
                                            proprietorName:
                                                filteredDealers[index]
                                                    .proprietorName,
                                            gstRegnNo: filteredDealers[index]
                                                .gstRegnNo,
                                            creditLine: filteredDealers[index]
                                                .creditLine,
                                            balance:
                                                filteredDealers[index].balance),
                                      ),
                                    );
                                  } catch (e) {
                                    print("Error navigating: $e");
                                  }
                                }
                              },
                              child: Card(
                                elevation: 0,
                                color: selectedCardIndex == index
                                    ? const Color(0xFFfff5ec)
                                    : null,
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              filteredDealers[index].cardName,
                                              style: CommonStyles.txSty_14o_f7,
                                              maxLines: 2, // Display in 2 lines
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8.0),
                                            Text(
                                              filteredDealers[index].cardCode,
                                              style: CommonStyles.txSty_14b_fb,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8.0),
                                            Text(
                                              filteredDealers[index]
                                                  .proprietorName,
                                              style: CommonStyles.txSty_12o_f7,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8.0),
                                            RichText(
                                              text: TextSpan(
                                                style:
                                                    DefaultTextStyle.of(context)
                                                        .style,
                                                children: <TextSpan>[
                                                  const TextSpan(
                                                    text: 'GST No. ',
                                                    style: CommonStyles
                                                        .txSty_12b_fb,
                                                  ),
                                                  TextSpan(
                                                    text: filteredDealers[index]
                                                        .gstRegnNo,
                                                    style: CommonStyles
                                                        .txSty_12o_f7,
                                                  ),
                                                ],
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8.0),
                                            const Text(
                                              'Address',
                                              style: CommonStyles.txSty_12b_fb,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2.0),
                                            Text(
                                              filteredDealers[index]
                                                  .fullAddress,
                                              style: CommonStyles.txSty_12o_f7,
                                              maxLines: 2, // Display in 2 lines
                                              overflow: TextOverflow.ellipsis,
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
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void filterDealers() {
    final String searchTerm = searchController.text.toLowerCase();
    setState(() {
      filteredDealers = dealers.where((dealer) {
        return dealer.cardCode.toLowerCase().contains(searchTerm) ||
            dealer.cardName.toLowerCase().contains(searchTerm) ||
            dealer.fullAddress.toLowerCase().contains(searchTerm);
      }).toList();
    });
  }

  Future<void> getshareddata() async {
    userId = await SharedPrefsData.getStringFromSharedPrefs("userId");
    slpCode = await SharedPrefsData.getStringFromSharedPrefs("slpCode");
    CompneyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
    print('User ID: $userId');
    print('SLP Code:2 $slpCode');
    if (slpCode!.isEmpty) {
      slpCode = null;
    }
    print('SLP Code:3 $slpCode');
    print('Company ID: $CompneyId');
    fetchData();
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: CommonStyles.orangeColor,
      automaticallyImplyLeading: false,
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
                'Select Party',
                style: CommonStyles.txSty_18w_fb,
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
              CompneyId == 1
                  ? 'assets/srikar-home-icon.png'
                  : 'assets/seeds-home-icon.png',
              width: 30,
              height: 30,
            ),
          )
        ],
      ),
    );
  }
}
