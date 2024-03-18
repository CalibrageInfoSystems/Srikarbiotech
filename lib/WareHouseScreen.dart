import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:srikarbiotech/Common/CommonUtils.dart';
import 'package:srikarbiotech/Common/SharedPrefsData.dart';
import 'package:srikarbiotech/Createorderscreen.dart';
import 'package:srikarbiotech/HomeScreen.dart';
import 'package:http/http.dart' as http;
import 'package:srikarbiotech/Model/warehouse_model.dart';

import 'CreateReturnorderscreen.dart';

class WareHouseScreen extends StatefulWidget {
  final String cardName;
  final String cardCode;
  final String address;
  final String proprietorName;
  final String gstRegnNo;
  final String state;
  final String phone;
  final double creditLine;
  final double balance;
  final String from;
  const WareHouseScreen(
      {super.key,
        required this.cardName,
        required this.cardCode,
        required this.address,
        required this.proprietorName,
        required this.gstRegnNo,
        required this.state,
        required this.phone,
        required this.creditLine,
        required this.balance,
      required this.from});

  @override
  State<WareHouseScreen> createState() => _WareHouseScreenState();
}

class _WareHouseScreenState extends State<WareHouseScreen> {
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
    print("screenFrom: ${widget.from}");

    screenFrom = '${widget.from}'.trim();
    wareHousesData = getWareHouses();
  }

  Future<List<WareHouseList>> getWareHouses() async {
    String userId = await SharedPrefsData.getStringFromSharedPrefs("userId");
    int companyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");

    try {
      String apiUrl = "http://182.18.157.215/Srikar_Biotech_Dev/API/api/Account/GetWarehousesByUserandCompany/$userId/$companyId";


      // String apiUrl = '$baseUrl$GetWarehousesByUserandCompany$userId 1';
      final jsonResponse = await http.get(Uri.parse(apiUrl));
      if (jsonResponse.statusCode == 200) {
        Map<String, dynamic> response = jsonDecode(jsonResponse.body);
        if (response['response']['listResult'] != null) {
          List<dynamic> wareHouseList = response['response']['listResult'];

          debugPrint('wareHouseList: ${wareHouseList[0]['whsName']}');
          return wareHouseList
              .map((house) => WareHouseList.fromJson(house))
              .toList();
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
      body: FutureBuilder(
        future: wareHousesData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else if (snapshot.hasError) {
            return const Center(
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
                      setState(() {
                        selectedCardIndex = index;
                      });
    if (screenFrom == "CreateOrder") {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              Createorderscreen(
                cardName: widget.cardName,
                cardCode: widget.cardCode,
                address: widget.address,
                state: widget.state,
                phone: widget.phone,
                proprietorName: widget.proprietorName,
                gstRegnNo: widget.gstRegnNo,
                creditLine: widget.creditLine,
                balance: widget.balance,
                whsCode: data[index].whsCode,
                whsName: data[index].whsName,
                whsState: data[index].whsState,
              ),
        ),
      );
    }
    else if (screenFrom == "CreatereturnOrder") {
      try {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateReturnorderscreen(
              cardName: widget.cardName,
              cardCode: widget.cardCode,
              address: widget.address,
              state: widget.state,
              phone: widget.phone,
              proprietorName: widget.proprietorName,
              gstRegnNo: widget.gstRegnNo,
              creditLine: widget.creditLine,
              balance: widget.balance,
              whsCode: data[index].whsCode,
              whsName: data[index].whsName,
              whsState: data[index].whsState
            ),
          ),
        );
      } catch (e) {
        print("Error navigating: $e");
      }

    }
                    },
                    child: SizedBox(
                      // margin: const EdgeInsets.symmetric(
                      //     horizontal: 16.0, vertical: 4.0),
                      child: Card(
                        elevation: 0,
                        color: selectedCardIndex == index
                            ? const Color(0xFFfff5ec)
                            : null,
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data[index].whsName + ' ('+  data[index].whsCode +') ',
                                      style: CommonUtils.header_Styles16,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    // const SizedBox(height: 5.0),
                                    // Text(
                                    //   data[index].whsCode,
                                    //   style: CommonUtils.Mediumtext_14,
                                    //   overflow: TextOverflow.ellipsis,
                                    // ),
                                    // const SizedBox(height: 5.0),
                                    // Text(
                                    //   data[index].whsState,
                                    //   style: CommonUtils.Mediumtext_12_0,
                                    //   maxLines: 2,
                                    //   overflow: TextOverflow.ellipsis,
                                    // ),
                                    // if (data[index].email != null)
                                    //   Column(
                                    //     crossAxisAlignment:
                                    //     CrossAxisAlignment.start,
                                    //     children: [
                                    //       const SizedBox(height: 5.0),
                                    //       RichText(
                                    //         text: TextSpan(
                                    //           style:
                                    //           DefaultTextStyle.of(context)
                                    //               .style,
                                    //           children: <TextSpan>[
                                    //             const TextSpan(
                                    //               text: 'Email: ',
                                    //               style:
                                    //               CommonUtils.Mediumtext_12,
                                    //             ),
                                    //             TextSpan(
                                    //               text: data[index].email,
                                    //               style: CommonUtils
                                    //                   .Mediumtext_12_0,
                                    //             ),
                                    //           ],
                                    //         ),
                                    //         overflow: TextOverflow.ellipsis,
                                    //       ),
                                    //     ],
                                    //   ),
                                    if (data[index].address != null &&
                                        data[index].address!.isNotEmpty)
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 5.0),
                                          const Text(
                                            'Address',
                                            style: CommonUtils.Mediumtext_12,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2.0),
                                          Text(
                                            data[index].address!,
                                            style: CommonUtils.Mediumtext_12_0,
                                          ),
                                        ],
                                      )
                                  ],
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
              ),
            );
          }
        },
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
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()),
                            (route) => false);
                  },
                  child: Image.asset(
                    companyId == 1
                        ? 'assets/srikar-home-icon.png'
                        : 'assets/seeds-home-icon.png',
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
}

// class WareHouse extends StatelessWidget {
//   final WareHouseList wareHouseData;
//   const WareHouse({super.key, required this.wareHouseData});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Card(
//         elevation: 7.0,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Container(
//           width: double.infinity,
//           height: 300,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10.0),
//             color: Colors.white,
//           ),
//           padding: const EdgeInsets.all(10.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 'wareHouseData.whsName', //'General Warehouse - TS',
//                 style: CommonUtils.header_Styles16,
//                 maxLines: 2, // Display in 2 lines
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 8.0),
//               const Text(
//                 'wareHouseData.whsCode', //'AP01',
//                 style: CommonUtils.Mediumtext_14,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 8.0),
//               const Text(
//                 'Hyderabad',
//                 style: CommonUtils.Mediumtext_o_14,
//                 maxLines: 2, // Display in 2 lines
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 8.0),
//               RichText(
//                 text: const TextSpan(
//                   children: <TextSpan>[
//                     TextSpan(text: 'Email: ', style: CommonUtils.Mediumtext_12),
//                     TextSpan(
//                         text: 'test@test.com',
//                         style: CommonUtils.Mediumtext_12_0),
//                   ],
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 8.0),
//               const Text(
//                 'Address',
//                 style: CommonUtils.Mediumtext_12,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 2.0),
//               const Text(
//                 'feoowefoiwehfiowheoifwohoihgohegortgotghorthgohtgoeoghoerhgohg - 522503',
//                 style: CommonUtils.Mediumtext_12_0,
//                 maxLines: 2, // Display in 2 lines
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class WareHouse extends StatefulWidget {
//   final WareHouseList wareHouseData;
//   final String cardName;
//   final String cardCode;
//   final String address;
//   final String proprietorName;
//   final String gstRegnNo;
//   final String state;
//   final String phone;
//   final double creditLine;
//   final double balance;
//   const WareHouse(
//       {Key? key,
//       required this.wareHouseData,
//       required this.cardName,
//       required this.cardCode,
//       required this.address,
//       required this.proprietorName,
//       required this.gstRegnNo,
//       required this.state,
//       required this.phone,
//       required this.creditLine,
//       required this.balance})
//       : super(key: key);

//   @override
//   State<WareHouse> createState() => _WareHouseState();
// }

// class _WareHouseState extends State<WareHouse> {

//   int selectedCardIndex = -1;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (context) => Createorderscreen(
//               cardName: widget.cardName,
//               cardCode: widget.cardCode,
//               address: widget.address,
//               state: widget.state,
//               phone: widget.phone,
//               proprietorName: widget.proprietorName,
//               gstRegnNo: widget.gstRegnNo,
//               creditLine: widget.creditLine,
//               balance: widget.balance,
//               whsCode: widget.wareHouseData.whsCode,
//               whsName: widget.wareHouseData.whsName,
//               whsState: widget.wareHouseData.whsState,
//             ),
//           ),
//         );
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
//         child: Card(
//           elevation: 0,
//           color: selectedCardIndex == index ? const Color(0xFFfff5ec) : null,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(5.0),
//             side: BorderSide(
//               color: selectedCardIndex == index
//                   ? const Color(0xFFe98d47) // Border color for selected item
//                   : Colors.grey, // Border color for unselected items
//               width: 1,
//             ),
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(10.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Flexible(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'cardName',
//                         style: CommonUtils.header_Styles16,
//                         maxLines: 2, // Display in 2 lines
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 8.0),
//                       Text(
//                         'cardCode',
//                         style: CommonUtils.Mediumtext_14,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 8.0),
//                       Text(
//                         'proprietorName',
//                         style: CommonUtils.Mediumtext_12_0,
//                         maxLines: 2, // Display in 2 lines
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 8.0),
//                       RichText(
//                         text: TextSpan(
//                           style: DefaultTextStyle.of(context).style,
//                           children: <TextSpan>[
//                             const TextSpan(
//                               text: 'GST No. ',
//                               style: CommonUtils.Mediumtext_12,
//                             ),
//                             TextSpan(
//                               text: 'gstRegnNo',
//                               style: CommonUtils.Mediumtext_12_0,
//                             ),
//                           ],
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 8.0),
//                       const Text(
//                         'Address',
//                         style: CommonUtils.Mediumtext_12,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 2.0),
//                       Text(
//                         'fullAddress',
//                         style: CommonUtils.Mediumtext_12_0,
//                         maxLines: 2, // Display in 2 lines
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),
//                 const Icon(
//                   Icons.chevron_right,
//                   color: Colors.orange,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
