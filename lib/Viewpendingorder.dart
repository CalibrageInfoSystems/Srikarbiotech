import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'Common/CommonUtils.dart';
import 'Common/SharedPrefsData.dart';
import 'HomeScreen.dart';
import 'OrctResponse.dart';
import 'OrderResponse.dart';
import 'Payment_model.dart';
import 'Services/api_config.dart';
import 'ViewPendingOrdersProvider.dart';
import 'order_details.dart';

class Viewpendingorder extends StatefulWidget {
  const Viewpendingorder({super.key});

  @override
  State<Viewpendingorder> createState() => _VieworderPageState();
}

class _VieworderPageState extends State<Viewpendingorder> {
  List<OrderResult> orderesponselist = [];

  List<OrderResult> filterorderesponselist = [];

  TextEditingController searchController = TextEditingController();

  late Future<List<OrderResult>?> apiData;
  bool isSelectedAll = false;

  late ViewPendingOrdersProvider viewPendingOrders;
  int companyId = 0;
  String? userId = "";

  List<OrderResult> selectedOrders = [];
  TextEditingController remarkstext = TextEditingController();
  @override
  void initState() {
    super.initState();
    initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    viewPendingOrders = Provider.of<ViewPendingOrdersProvider>(context);
  }

  void initializeData() {

    apiData = getorder();
    apiData.then((data) {
      if (data != null) {
        setState(() {
          viewPendingOrders.storeIntoViewPendingOrders(data);
        });
      } else {
        debugPrint('Error initializing data: Invalid data format');
      }
    }).catchError((error) {
      debugPrint('Error initializing data: $error');
    });
  }

  Future<List<OrderResult>> getorder() async {
    companyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
    userId = await SharedPrefsData.getStringFromSharedPrefs("userId");
    String currentdate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    DateTime oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    String oneWeekdate = DateFormat('yyyy-MM-dd').format(oneWeekAgo);

    final url = Uri.parse(
        'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Order/GetAppOrdersBySearch');
    final requestBody = {
      "PartyCode": null,
      "StatusId": 1,
      "FormDate": oneWeekdate,
      "ToDate": currentdate,
      "CompanyId": companyId,
      "UserId": userId
    };

    debugPrint('_______pending orders____1___');
    debugPrint(jsonEncode(requestBody));

    final response = await http.post(
      url,
      body: json.encode(requestBody),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['response']['listResult'] != null) {
        final List<dynamic> listResult = data['response']['listResult'];
        print('===========>$listResult');

        setState(() {
          orderesponselist =
              listResult.map((json) => OrderResult.fromJson(json)).toList();
          filterorderesponselist = List.from(orderesponselist);
        });

        if (filterorderesponselist.isEmpty) {
          print('No records found.');
          // Display a message or set a variable to show a message in your UI.
        }

        return filterorderesponselist;
      } else {
        print('ListResult is null.');
        // Handle the case where "listResult" is null.
        // You can return an empty list or handle it based on your application's requirements.
        return [];
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  void filterOrderBasedOnProduct(String input) {
    apiData.then((data) {
      setState(() {
        viewPendingOrders.storeIntoViewPendingOrders(data!
            .where((item) =>
            item.partyName.toLowerCase().contains(input.toLowerCase()))
            .toList());
      });
    });
  }

  void filterDealers() {
    final String searchTerm = searchController.text.toLowerCase();
    setState(() {
      filterorderesponselist = orderesponselist.where((dealer) {
        return dealer.partyName.toLowerCase().contains(searchTerm) ||
            dealer.partyGSTNumber!.toLowerCase().contains(searchTerm);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {

        return WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>  HomeScreen()),

          );
        //  viewPendingOrders.Clearpendingcheckbox();

      return true;
    },
     child: Consumer<ViewPendingOrdersProvider>(
      builder: (context, pendingsProvider, _) => Scaffold(
        appBar: _appBar(),
        body: FutureBuilder(
          future: apiData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator.adaptive());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error occurred: ${snapshot.error}'),
              );
            } else {
              List<OrderResult> data = pendingsProvider.viewPendingData;

              return Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _viewOrdersSearchBarAndFilter(),

                    // select filter
                    if (pendingsProvider.viewPendingData.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [

                          isSelectedAll
                              ? GestureDetector(
                            onTap: () {
                              pendingsProvider.toggleUnSelectAll();
                              setState(() {
                                isSelectedAll = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color:Color(0xFFe78337)),
                              child: const Text('Unselect All' , style: CommonUtils.Buttonstyle,),
                            ),
                          )
                              : GestureDetector(
                            onTap: () {
                              pendingsProvider.toggleSelectAll();
                              setState(() {
                                isSelectedAll = true;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color:Color(0xFFe78337)),
                              child: const Text('Select All',
                              style: CommonUtils.Buttonstyle,),
                            ),
                          )
                      ],
                    ),

                    const SizedBox(
                      height: 5.0,
                    ),
                    if (pendingsProvider.viewPendingData.isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: data.length,
                          // Change this to the number of static items you want
                          itemBuilder: (context, index) {
                            String dateString = data[index].orderDate;
                            DateTime date = DateTime.parse(dateString);
                            String formattedDate =
                            DateFormat('dd MMM, yyyy').format(date);

                            return OrderCard(
                              orderIndex: index,
                              orderResult: data[index],
                              formattedDate: formattedDate,
                              // Add isSelected parameter to determine if the item is selected
                              isSelected: selectedOrders.contains(data[index]),
                              // Pass a callback function to handle selection
                              onSelected: (isSelected) {
                                setState(() {
                                  if (isSelected) {
                                    selectedOrders.add(data[index]);
                                  } else {
                                    selectedOrders.remove(data[index]);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      )
                    else
                      const Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Text(
                                  'No Pending Orders found!',
                                  style: CommonUtils.Mediumtext_14_cb,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (pendingsProvider.viewPendingData.isNotEmpty)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () {
                          // Add your logic here for when the button is clicked
                          print('Approve button clicked');
                          print('Approve button clicked ${pendingsProvider.getSelectedOrderIds().length}');
                          if (pendingsProvider.getSelectedOrderIds().length > 0) {
                            showRemarksBottomSheet(context, pendingsProvider.getSelectedOrderIds());
                          }{

                          }
                        },
                        child: Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(16),
                          child: SizedBox(
                            width: double.infinity,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Color(0xFFe78337),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center, // Aligns children horizontally to the center
                                children: [
                                  SvgPicture.asset(
                                    'assets/check.svg',
                                    height: 18,
                                    width: 18,
                                    fit: BoxFit.fitWidth,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8.0),
                                  Text(
                                    'Approve',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      ),
                      ),


                  ],
            ));
          }
          },
        ),
      ),
    ));
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
                    // Handle the click event for the back button
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>  HomeScreen()),

                    );
               //     viewPendingOrders.Clearpendingcheckbox();
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
                'My Orders',
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
                // Access the companyId after shared data is retrieved

                return GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>  HomeScreen()),
                    );
              //
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
                // Return a placeholder or loading indicator
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _viewOrdersSearchBarAndFilter() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
              height: 45,
              child: TextField(
                onChanged: (input) => filterOrderBasedOnProduct(input),
                decoration: InputDecoration(
                  hintText: 'Order Search',
                  hintStyle: CommonUtils.hintstyle_14,
                  suffixIcon: const Icon(Icons.search),
                  border: CommonUtils.searchBarOutPutInlineBorder,
                  focusedBorder:
                  CommonUtils.searchBarEnabledNdFocuedOutPutInlineBorder,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getshareddata() async {
    companyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
  }

  void handleApprove(List<int> selectedOrderIds, String remarks) async {

      // Construct the request body
      var requestBody = {
        "Id": selectedOrderIds.join(","), // Join the IDs with commas
        "StatusTypeId": 17,
        "Remarks": remarks,
        "UpdatedBy": "e39536e2-89d3-4cc7-ae79-3dd5291ff156",
        "UpdatedDate": "2024-02-20"
      };
print('==>${jsonEncode(requestBody)}');
      // Make the HTTP POST request
      var response = await http.post(
        Uri.parse('http://182.18.157.215/Srikar_Biotech_Dev/API/api/Order/UpdateOrderStatus'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      // Check the response status
      if (response.statusCode == 200) {
        // Request successful, handle response here
        print('Request successful');
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Viewpendingorder()),
        );
      } else {
        // Request failed, handle error here
        print('Request failed with status: ${response.statusCode}');
      }
    }

  void showRemarksBottomSheet(BuildContext context, List<int> selectedOrderIds) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Padding(
                  padding: EdgeInsets.only(
                      top: 15.0, left: 0.0, right: 0.0, bottom: 5.0),
                  child: Text(
                    'Remarks',
                    style:CommonUtils.Mediumtext_o_14,
                    textAlign: TextAlign.start,
                  ),
                ),
                Container(
                  height: 70,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    border:
                    Border.all(color: const Color(0xFFe78337), width: 1),
                    borderRadius: BorderRadius.circular(5.0),
                    color: Colors.white,
                  ),
                  child: TextFormField(
                    controller: remarkstext,
                    maxLength: 100,
                    style: CommonUtils.Mediumtext_o_14,
                    maxLines: null, // Set maxLines to null for multiline input
                    decoration:  InputDecoration(
                      counterText: '',
                      hintText: 'Enter Remarks',
                      hintStyle: CommonUtils.hintstyle_o_14,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 0.0,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        String remarks = remarkstext.text.trim();

                          // Call the API to update invoice status with remarks
                          handleApprove(selectedOrderIds, remarks);
                          Navigator.of(context).pop();


                        // updateInvoiceStatus(ordernumber!, invoiceNo);
                        // Navigator.of(context).pop(); // Close the bottom sheet
                      },
                      child: Container(
                        height: 35,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8dac2),
                          border: Border.all(
                            color: const Color(0xFFe78337),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: IntrinsicWidth(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/check.svg',
                                      height: 18,
                                      width: 18,
                                      fit: BoxFit.fitWidth,
                                      color: const Color(0xFFe78337),
                                    ),
                                    const SizedBox(width: 8.0),
                                    const Text(
                                      ' Submit',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 12,
                                        color: Color(0xFFe78337),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     // Implement your logic to handle the remarks
                    //     Navigator.of(context).pop(); // Close the bottom sheet
                    //   },
                    //   child: Text('Submit'),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }





  }




class OrderCard extends StatefulWidget {
  final int orderIndex;
  final OrderResult orderResult;
  final String formattedDate;
  final bool isSelected; // Add isSelected parameter
  final ValueChanged<bool>? onSelected; // Add onSelected parameter

  const OrderCard({
    Key? key,
    required this.orderResult,
    required this.formattedDate,
    required this.orderIndex,
    required this.isSelected,
    this.onSelected,
  }) : super(key: key);

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  final _boxBorder = BoxDecoration(
    borderRadius: BorderRadius.circular(5.0),
    color: Colors.white,
  );

  final _iconBoxBorder = BoxDecoration(
    borderRadius: BorderRadius.circular(5.0),
    color: Colors.white,
  );
  TextEditingController remarkstext = TextEditingController();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

// start

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Orderdetails(
                orderid: widget.orderResult.id,
                orderdate: widget.formattedDate,
                totalCostWithGST: widget.orderResult.totalCostWithGST!,
                bookingplace: widget.orderResult.bookingPlace,
                transportmode: widget.orderResult.transportName,
                lrnumber: 1,
                lrdate: "",
                statusname: widget.orderResult.statusName,
                partyname: widget.orderResult.partyName,
                partycode: widget.orderResult.partyCode,
                proprietorName: widget.orderResult.proprietorName!,
                partyGSTNumber: widget.orderResult.partyGSTNumber!,
                ordernumber: widget.orderResult.orderNumber!,
                partyAddress: widget.orderResult.partyAddress,
              statusBar: sendingSvgImagesAndColors(
                widget.orderResult.statusTypeId,
                widget.orderResult.statusName,
              ),),

          ),
        );
      },
      child:
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        color: Colors.transparent,
        child: Card(
          elevation: 5,
          child: Container(
            padding: const EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: CommonUtils.boxBorder,
                  child: Row(
                    children: [
                      // starting icon of card
                      Card(
                        elevation: 3,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Container(
                          height: 65,
                          width: 65,
                          padding: const EdgeInsets.all(10),
                          decoration: _iconBoxBorder,
                          child: Center(
                            child: getSvgImagesAndColors(
                              widget.orderResult.statusTypeId,
                            ),
                          ),
                        ),
                      ),

                      // beside info
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10, top: 0, bottom: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.orderResult.partyName,
                                      style: CommonUtils.Mediumtext_14_cb,
                                      softWrap: true,
                                      maxLines: 2,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                  Consumer<ViewPendingOrdersProvider>(
                                    builder: (context, pendingOrders, _) {
                                      return Checkbox(
                                        activeColor: const Color(0xFFe78337),
                                        value: pendingOrders.getCheckBoxValues[widget.orderIndex],
                                        onChanged: (bool? newValue) {
                                          pendingOrders.setCheckBoxStatusByIndex(
                                              widget.orderIndex, newValue);
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),

                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Order ID : ',
                                        style: CommonUtils.txSty_13B_Fb,
                                      ),
                                      Text(
                                        widget.orderResult.orderNumber
                                            .toString(),
                                        style: CommonUtils.txSty_13O_F6,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '₹${formatNumber(widget.orderResult.totalCostWithGST!)}',
                                    style: CommonUtils.txSty_13O_F6,
                                  ),
                                  Text(
                                    widget.formattedDate,
                                    style: CommonUtils.txSty_13O_F6,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                Row(
                  children: [
                   Container(
                        margin: const EdgeInsets.only(left: 5.0),
                        padding: const EdgeInsets.symmetric(
                            vertical: 3, horizontal:5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: statusBgColor,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.orderResult.statusName,
                              style: TextStyle(
                                fontSize: 11,
                                color: statusColor,
                                // Add other text styles as needed
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'No.of Items: ',
                                    style: CommonUtils.txSty_13B_Fb,
                                  ),
                                  Text(
                                    '${widget.orderResult.noOfItems}',
                                    style: CommonUtils.txSty_13O_F6,
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5.0,
                ),
                Container(
                  width: double.infinity,
                  height: 0.2,
                  color: Colors.grey,
                ),
                const SizedBox(
                  height: 5.0,
                ),
                // Clear button
               Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[

                    GestureDetector(
                      onTap: () {
                        // Show confirmation dialog
                        showRemarksBottomSheet(context,widget.orderResult.id);
                      },
                      child:
                      Container(
                        decoration: BoxDecoration(
                          color: HexColor('#ffecee'), // Background color of the card
                          borderRadius: BorderRadius.circular(20), // Adjust the radius as needed
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Adjust padding as needed
                        child:
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/crosscircle.svg',
                              height: 18,
                              width: 18,
                              fit: BoxFit.fitWidth,
                              color: HexColor('#ee1d23'),
                            ),
                            SizedBox(width: 8.0), // Add some spacing between icon and text
                            Text(
                              'Reject',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold,
                                color: HexColor('#ee1d23'),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                  ],
                ),

                // GestureDetector(
                //   onTap: () {
                //     // showClearDialog();
                //     showRemarksBottomSheet(context,widget.orderResult.id);
                //   },
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.end,
                //     children: [
                //       Container(
                //         margin: const EdgeInsets.only(left: 5.0),
                //         padding: const EdgeInsets.symmetric(
                //             vertical: 5, horizontal: 10),
                //         decoration: BoxDecoration(
                //           borderRadius: BorderRadius.circular(8),
                //           color:Color(0xFFe78337),
                //         ),
                //         child: Center(
                //           child: Text('Reject' , style: CommonUtils.Buttonstyle,),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),

    );
  }

  late Color statusColor;
  late Color statusBgColor;
  Widget getSvgImagesAndColors(int statusTypeCode) {
    String assetPath;
    late Color iconColor;
    switch (statusTypeCode) {
      case 1: // 'Pending'
        assetPath = 'assets/shipping-timed.svg';
        iconColor = const Color(0xFFE58338);
        statusColor = const Color(0xFFe58338);
        statusBgColor = const Color(0xFFe58338).withOpacity(0.2);
        break;
      case 2: // 'Shipped'
        assetPath = 'assets/shipping-fast.svg';
        iconColor = const Color(0xFF0d6efd);
        statusColor = const Color(0xFF0d6efd);
        statusBgColor = const Color(0xFF0d6efd).withOpacity(0.2);
        break;
      case 3: // 'Delivered'
        assetPath = 'assets/box-circle-check.svg';
        iconColor = Colors.green;
        statusColor = Colors.green;
        statusBgColor = Colors.green.withOpacity(0.2);
        break;
      case 10: // 'Partially Shipped'
        assetPath = 'assets/boxes.svg';
        iconColor = const Color(0xFF0dcaf0);
        statusColor = const Color(0xFF0dcaf0);
        statusBgColor = const Color(0xFF0dcaf0).withOpacity(0.2);
        break;
      case 11: // 'Accepted'
        assetPath = 'assets/shipping-timed.svg';
        iconColor = Colors.green;
        statusColor = Colors.green;
        statusBgColor = Colors.green.withOpacity(0.2);
        break;
      case 12: // 'Rejected'
        assetPath = 'assets/reject.svg';
        iconColor = HexColor('#C42121');
        statusColor = HexColor('#C42121');
        statusBgColor = HexColor('#C42121').withOpacity(0.2);
        break;
      case 16: // 'Cancelled'
        assetPath = 'assets/order-cancel.svg';
        iconColor = HexColor('#dc3545');
        statusColor = HexColor('#dc3545');
        statusBgColor = HexColor('#dc3545').withOpacity(0.2);
        break;
      default:
        assetPath = 'assets/sb_home.svg';
        iconColor = Colors.black26;
        statusColor = Colors.black26;
        statusBgColor = Colors.black26.withOpacity(0.2);
        break;
    }
    return SvgPicture.asset(
      assetPath,
      width: 50,
      height: 50,
      fit: BoxFit.fill,
      color: iconColor,
    );
  }

  String formatNumber(double number) {
    NumberFormat formatter = NumberFormat("#,##,##,##,##,##,##0.00", "en_US");
    return formatter.format(number);
  }

  void showRemarksBottomSheet(BuildContext context, int id) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Padding(
                  padding: EdgeInsets.only(
                      top: 15.0, left: 0.0, right: 0.0, bottom: 5.0),
                  child: Text(
                    'Remarks',
                    style:CommonUtils.Mediumtext_o_14,
                    textAlign: TextAlign.start,
                  ),
                ),
                Container(
                  height: 70,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    border:
                    Border.all(color: const Color(0xFFe78337), width: 1),
                    borderRadius: BorderRadius.circular(5.0),
                    color: Colors.white,
                  ),
                  child: TextFormField(
                    controller: remarkstext,
                    maxLength: 100,
                    style: CommonUtils.Mediumtext_o_14,
                    maxLines: null, // Set maxLines to null for multiline input
                    decoration:  InputDecoration(
                      counterText: '',
                      hintText: 'Enter Remarks',
                      hintStyle: CommonUtils.hintstyle_o_14,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 0.0,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        String remarks = remarkstext.text.trim();
                        if (remarks.isEmpty) {
                          CommonUtils.showCustomToastMessageLong(
                              'Please Enter Remarks', context, 1, 4);
                        } else {
                          // Call the API to update invoice status with remarks
                          handlereject(id, remarks);
                          remarkstext.text ="";
                          Navigator.of(context).pop();

                        }
                        // updateInvoiceStatus(ordernumber!, invoiceNo);
                        // Navigator.of(context).pop(); // Close the bottom sheet
                      },
                      child: Container(
                        height: 35,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8dac2),
                          border: Border.all(
                            color: const Color(0xFFe78337),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: IntrinsicWidth(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child:
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/check.svg',
                                      height: 18,
                                      width: 18,
                                      fit: BoxFit.fitWidth,
                                      color: const Color(0xFFe78337),
                                    ),
                                    const SizedBox(width: 8.0),
                                    const Text(
                                      ' Submit',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 12,
                                        color: Color(0xFFe78337),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     // Implement your logic to handle the remarks
                    //     Navigator.of(context).pop(); // Close the bottom sheet
                    //   },
                    //   child: Text('Submit'),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void handlereject(int id, String remarks)  async {

    // Construct the request body
    var requestBody = {
      "Id":id, // Join the IDs with commas
      "StatusTypeId": 12,
      "Remarks": remarks,
      "UpdatedBy": "e39536e2-89d3-4cc7-ae79-3dd5291ff156",
      "UpdatedDate": "2024-02-20"
    };
    print('==>${jsonEncode(requestBody)}');
    // Make the HTTP POST request
    var response = await http.post(
      Uri.parse('http://182.18.157.215/Srikar_Biotech_Dev/API/api/Order/UpdateOrderStatus'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    // Check the response status
    if (response.statusCode == 200) {
      // Request successful, handle response here
      print('Request successful');
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                Viewpendingorder()),
      );

    } else {
      // Request failed, handle error here
      print('Request failed with status: ${response.statusCode}');
    }
  }

  Widget sendingSvgImagesAndColors(int statusTypeId, String statusName) {
    String svgIcon;
    Color svgIconBgColor;

    switch (statusTypeId) {
      case 1: // 'Pending'
        svgIcon = 'assets/shipping-timed.svg';
        statusColor = const Color(0xFFe58338);
        svgIconBgColor = const Color(0xFFe58338).withOpacity(0.2);
        break;
      case 2: // 'Shipped'
        svgIcon = 'assets/shipping-fast.svg';
        statusColor = const Color(0xFF0d6efd);
        svgIconBgColor = const Color(0xFF0d6efd).withOpacity(0.2);
        break;
      case 3: // 'Delivered'
        svgIcon = 'assets/box-circle-check.svg';
        statusColor = Colors.green;
        svgIconBgColor = Colors.green.withOpacity(0.2);
        break;
      case 10: // 'Partially Shipped'
        svgIcon = 'assets/boxes.svg';
        statusColor = const Color(0xFF0dcaf0);
        svgIconBgColor = const Color(0xFF0dcaf0).withOpacity(0.2);
        break;
      case 11: // 'Accepted'
        svgIcon = 'assets/shipping-timed.svg';
        statusColor = Colors.green;
        svgIconBgColor = Colors.green.withOpacity(0.2);
        break;
      case 12: // 'Rejected'
        svgIcon = 'assets/reject.svg';
        statusColor = HexColor('#C42121');
        svgIconBgColor = HexColor('#C42121').withOpacity(0.2);
        break;
      case 16: // 'Cancelled'
        svgIcon = 'assets/order-cancel.svg';
        statusColor = HexColor('#dc3545');
        svgIconBgColor = HexColor('#dc3545').withOpacity(0.2);
        break;
      default:
        svgIcon = 'assets/sb_home.svg';
        statusColor = Colors.black26;
        svgIconBgColor = Colors.black26.withOpacity(0.2);
        break;
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: svgIconBgColor,
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        children: [
          SvgPicture.asset(
            svgIcon,
            fit: BoxFit.fill,
            width: 15,
            height: 15,
            color: statusColor,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            statusName,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 13,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }


}
