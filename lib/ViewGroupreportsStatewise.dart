import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:srikarbiotech/Common/CommonUtils.dart';
import 'package:srikarbiotech/Common/SharedPrefsData.dart';
import 'package:srikarbiotech/Createorderscreen.dart';
import 'package:srikarbiotech/HomeScreen.dart';
import 'package:http/http.dart' as http;
import 'package:srikarbiotech/Model/warehouse_model.dart';
import 'package:srikarbiotech/Services/api_config.dart';

import 'CreateReturnorderscreen.dart';

class ViewGroupreportsStatewise extends StatefulWidget {

  const ViewGroupreportsStatewise();

  @override
  State<ViewGroupreportsStatewise> createState() => _WareHouseScreenState();
}

class _WareHouseScreenState extends State<ViewGroupreportsStatewise> {
  int selectedCardIndex = -1;
  int companyId = 0;
  late Future<List<WareHouseList>> wareHousesData;
  late String screenFrom;
  Future<void> getshareddata() async {
    companyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
  }

  @override
  void initState() {
    super.initState();

    CommonUtils.checkInternetConnectivity().then(
          (isConnected) {
        if (isConnected) {
          print('The Internet Is Connected');
        } else {
          CommonUtils.showCustomToastMessageLong(
              'Please check your internet  connection', context, 1, 4);
          print('The Internet Is not  Connected');
        }
      },
    );
    wareHousesData = getWareHouses();

  }

  Future<List<WareHouseList>> getWareHouses() async {
    String userId = await SharedPrefsData.getStringFromSharedPrefs("userId");
    int companyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");

    try {
      //String apiUrl = "http://182.18.157.215/Srikar_Biotech_Dev/API/api/Account/GetWarehousesByUserandCompany/$userId/$companyId";
      String apiUrl = baseUrl + GetWarehouse + userId + "/" + companyId.toString();

      print('WareHouseapi:$apiUrl');

      // String apiUrl = '$baseUrl$GetWarehousesByUserandCompany$userId 1';
      final jsonResponse = await http.get(Uri.parse(apiUrl));
      if (jsonResponse.statusCode == 200) {
        Map<String, dynamic> response = jsonDecode(jsonResponse.body);
        if (response['response']['listResult'] != null) {
          List<dynamic> wareHouseList = response['response']['listResult'];

          debugPrint('wareHouseList: ${wareHouseList[0]['whsName']}');
          return wareHouseList.map((house) => WareHouseList.fromJson(house)).toList();
        } else {
          debugPrint('warehouse list is empty');
          throw Exception('error: warehouse list is empty');
        }
      } else {
        debugPrint('error: api call failed');
        throw Exception('error: api call failed');
      }
    } catch (e) {
      throw Exception('catch: $e');
    }

    // String apiUrl =
    //     "http://182.18.157.215/Srikar_Biotech_Dev/API/api/Account/GetWarehousesByUserandCompany/e39536e2-89d3-4cc7-ae79-3dd5291ff156/1";

    // final jsonResponse = await http.get(Uri.parse(apiUrl));
    // Map<String, dynamic> response = jsonDecode(jsonResponse.body);
    // List<dynamic> wareHouseList = response['response']['listResult'];
    // return wareHouseList.map((house) => WareHouseList.fromJson(house)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),

      body: Column(
        children: [
          Card(
            elevation: 0,
            color: Colors.transparent,
            margin: EdgeInsets.all(12.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'From Date',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        // Replace the below TextFormField with your date selection widget
                        TextFormField(
                          // Your code for From Date selection goes here
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'To Date',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        // Replace the below TextFormField with your date selection widget
                        TextFormField(
                          // Your code for To Date selection goes here
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        SizedBox(height: 48),
                        ElevatedButton(
                          onPressed: () {
                            // Handle Submit button tap
                          },
                          child: Text('Submit'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        SizedBox(height: 48),
                        ElevatedButton(
                          onPressed: () {
                            _downloadFile(context);
                            // Handle Export button tap
                          },
                          child: Text('Export'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: wareHousesData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator.adaptive());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('No warehouses present'),
                  );
                } else {
                  List<WareHouseList> data = snapshot.data!;

                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // Handle warehouse item tap
                          },
                          child: SizedBox(
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
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data[index].whsName + ' (' + data[index].whsCode + ') ',
                                            style: CommonUtils.header_Styles16,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (data[index].address != null && data[index].address!.isNotEmpty)
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(height: 5.0),
                                                Text(
                                                  'Address',
                                                  style: CommonUtils.Mediumtext_12,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 2.0),
                                                Text(
                                                  data[index].address!,
                                                  style: CommonUtils.Mediumtext_12_0,
                                                ),
                                              ],
                                            )
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
                  );
                }
              },
            ),
          ),
        ],
      ),

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
                    // navigation here
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
                'Select Warehouse',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          FutureBuilder(
            future: getshareddata(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
                  },
                  child: Image.asset(
                    companyId == 1 ? 'assets/srikar-home-icon.png' : 'assets/seeds-home-icon.png',
                    width: 30,
                    height: 30,
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
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


