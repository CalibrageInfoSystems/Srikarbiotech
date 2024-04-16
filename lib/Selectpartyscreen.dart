import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikarbiotech/Common/CommonUtils.dart';

import 'package:srikarbiotech/Services/api_config.dart';
import 'dart:convert';

import 'Common/SharedPreferencesHelper.dart';
import 'Common/SharedPrefsData.dart';
import 'CreateCollectionscreen.dart';
import 'CreateReturnorderscreen.dart';
import 'Createorderscreen.dart';
import 'HomeScreen.dart';
import 'Ledgerscreen.dart';
import 'Model/Dealer.dart';
import 'WareHouseScreen.dart';

class Selectpartyscreen extends StatefulWidget {
  String from;
  Selectpartyscreen({required this.from});

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

    screenFrom = '${widget.from}'.trim();
    print("screenFrom: ${screenFrom}");
  }

  Future<void> fetchData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final apiUrl = baseUrl + GetAllDealersBySlpCode + '$CompneyId' + "/" + '$slpCode';
      print("apiUrl: ${apiUrl}");

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
          // Handle the case where listResult is null
          print("listResult is null");
          // You might want to set dealers to an empty list or do any other appropriate action.
          setState(() {
            dealers = [];
            filteredDealers = [];
          });
        }

        setState(() {
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load data. Status Code: ${response.statusCode}');
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
      appBar: AppBar(
        backgroundColor: Color(0xFFe78337),
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
                  'Select Party',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                // Handle the click event for the home icon
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: Image.asset(
                CompneyId == 1 ? 'assets/srikar-home-icon.png' : 'assets/seeds-home-icon.png',
                width: 30,
                height: 30,
              ),
            )
          ],
        ), // This line removes the default back arrow
      ),
      body: Column(children: [
        Padding(
          padding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.0),
              GestureDetector(
                onTap: () {
                  // Handle the click event for the second text view
                  print('first textview clicked');
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(
                      color: Colors.black26,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: TextFormField(
                            controller: searchController,
                            onChanged: (value) {
                              filterDealers();
                            },
                            keyboardType: TextInputType.name,
                            style: CommonUtils.Mediumtext_12,
                            decoration: InputDecoration(
                              hintText: 'Search for Party Name or Code or City ',
                              hintStyle: CommonUtils.hintstyle_14,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Icon(
                          Icons.search,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10.0),
            ],
          ),
        ),
        // Add Expanded around the ListView.builder
        Expanded(
          child: _isLoading
              ? Center(
            child: CircularProgressIndicator(),
          )
              : filteredDealers.isEmpty // Check if filteredDealers is empty
              ? Center(
            child: Text(
              'No Data Found',
              style: CommonUtils.Mediumtext_12,
            ), // Display this text when filteredDealers is empty
          )
              : ListView.builder(
            itemCount: filteredDealers.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCardIndex = index; // Update selected index
                  });
                  // onTap: () {
                  //   if (!FocusScope.of(context).hasPrimaryFocus) {
                  //     return;
                  //   }
                  print("Tapped on dealer with cardName: ${filteredDealers[index].cardName}");
                  print("screenFrom: $screenFrom");

                  if (screenFrom == "CreateOrder") {
                    print("Tapped on dealer with cardName:2 ${filteredDealers[index].cardName}");
                    try {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WareHouseScreen(
                              from: 'CreateOrder',
                              cardName: filteredDealers[index].cardName,
                              cardCode: filteredDealers[index].cardCode,
                              address: filteredDealers[index].fullAddress,
                              state: filteredDealers[index].state,
                              phone: filteredDealers[index].phoneNumber,
                              proprietorName: filteredDealers[index].proprietorName,
                              gstRegnNo: filteredDealers[index].gstRegnNo,
                              creditLine: filteredDealers[index].creditLine,
                              balance: filteredDealers[index].balance),
                        ),
                      );
                    } catch (e) {
                      print("Error navigating: $e");
                    }
                  } else if (screenFrom == "CreateCollections") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateCollectionscreen(
                            cardName: filteredDealers[index].cardName,
                            cardCode: filteredDealers[index].cardCode,
                            address: filteredDealers[index].fullAddress,
                            state: filteredDealers[index].state,
                            phone: filteredDealers[index].phoneNumber,
                            proprietorName: filteredDealers[index].proprietorName,
                            code: filteredDealers[index].cardCode,
                            gstRegnNo: filteredDealers[index].gstRegnNo),
                      ),
                    );
                  } else if (screenFrom == "Ledger") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Ledgerscreen(
                            cardName: filteredDealers[index].cardName,
                            cardCode: filteredDealers[index].cardCode,
                            address: filteredDealers[index].fullAddress,
                            state: filteredDealers[index].state,
                            phone: filteredDealers[index].phoneNumber,
                            proprietorName: filteredDealers[index].proprietorName,
                            gstRegnNo: filteredDealers[index].gstRegnNo,
                            creditLine: filteredDealers[index].creditLine,
                            balance: filteredDealers[index].balance),
                      ),
                    );
                  } else if (screenFrom == "CreatereturnOrder") {
                    print("Tapped on dealer with cardName:2 ${filteredDealers[index].cardName}");
                    try {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WareHouseScreen(
                              from: 'CreatereturnOrder',
                              cardName: filteredDealers[index].cardName,
                              cardCode: filteredDealers[index].cardCode,
                              address: filteredDealers[index].fullAddress,
                              state: filteredDealers[index].state,
                              phone: filteredDealers[index].phoneNumber,
                              proprietorName: filteredDealers[index].proprietorName,
                              gstRegnNo: filteredDealers[index].gstRegnNo,
                              creditLine: filteredDealers[index].creditLine,
                              balance: filteredDealers[index].balance),
                        ),
                      );
                    } catch (e) {
                      print("Error navigating: $e");
                    }
                  }
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Card(
                    elevation: 0,
                    color: selectedCardIndex == index ? Color(0xFFfff5ec) : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      side: BorderSide(
                        color: selectedCardIndex == index
                            ? Color(0xFFe98d47) // Border color for selected item
                            : Colors.grey, // Border color for unselected items
                        width: 1,
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  filteredDealers[index].cardName,
                                  style: CommonUtils.header_Styles16,
                                  maxLines: 2, // Display in 2 lines
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  filteredDealers[index].cardCode,
                                  style: CommonUtils.Mediumtext_14,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  filteredDealers[index].proprietorName,
                                  style: CommonUtils.Mediumtext_12_0,
                                  maxLines: 2, // Display in 2 lines
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8.0),
                                RichText(
                                  text: TextSpan(
                                    style: DefaultTextStyle.of(context).style,
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: 'GST No. ',
                                        style: CommonUtils.Mediumtext_12,
                                      ),
                                      TextSpan(
                                        text: filteredDealers[index].gstRegnNo,
                                        style: CommonUtils.Mediumtext_12_0,
                                      ),
                                    ],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'Address',
                                  style: CommonUtils.Mediumtext_12,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2.0),
                                Text(
                                  filteredDealers[index].fullAddress,
                                  style: CommonUtils.Mediumtext_12_0,
                                  maxLines: 2, // Display in 2 lines
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
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
          ),
        ),
      ]),
    );
  }

  void filterDealers() {
    final String searchTerm = searchController.text.toLowerCase();
    setState(() {
      filteredDealers = dealers.where((dealer) {
        return dealer.cardCode.toLowerCase().contains(searchTerm) || dealer.cardName.toLowerCase().contains(searchTerm) || dealer.fullAddress.toLowerCase().contains(searchTerm);
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
    // final loadedData = await SharedPreferencesHelper.getCategories();
    // print('loadedData: $loadedData');
    // if (loadedData != null) {
    //   userId = loadedData['response']['userId'];
    //   slpCode = loadedData['response']['slpCode'];
    //   CompneyId = loadedData['response']['companyId'];
    //   print('User ID: $userId');
    //   print('SLP Code: $slpCode');
    //   print('Company ID: $CompneyId');
    //   fetchData();
    // }
  }
}
