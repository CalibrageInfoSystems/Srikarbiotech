import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:srikarbiotech/vieworders_provider.dart';
import 'Common/CommonUtils.dart';
import 'Common/SharedPrefsData.dart';
import 'HomeScreen.dart';
import 'OrctResponse.dart';
import 'OrderResponse.dart';
import 'Payment_model.dart';
import 'Services/api_config.dart';
import 'order_details.dart';

class Viewpendingorder extends StatefulWidget {
  const Viewpendingorder({super.key});

  @override
  State<Viewpendingorder> createState() => _VieworderPageState();
}

class _VieworderPageState extends State<Viewpendingorder> {
  final _orangeColor = HexColor('#e58338');

  List<OrderResult> orderesponselist = [];

  List<OrderResult> filterorderesponselist = [];

  TextEditingController searchController = TextEditingController();

  late Future<List<OrderResult>?> apiData;

  late ViewOrdersProvider viewOrdersProvider;
  int companyId = 0;
  String? userId = "";
  @override
  void initState() {
    super.initState();
    initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    viewOrdersProvider = Provider.of<ViewOrdersProvider>(context);
  }

  void initializeData() {
    apiData = getorder();
    apiData.then((data) {
      if (data != null) {
        setState(() {
          viewOrdersProvider.storeIntoViewOrderProvider(data);
        });
      } else {
        print('Error initializing data: Invalid data format');
      }
    }).catchError((error) {
      print('Error initializing data: $error');
    });
  }

  Future<List<OrderResult>> getorder() async {
    companyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
    userId = await SharedPrefsData.getStringFromSharedPrefs("userId");
  String currentdate= DateFormat('yyyy-MM-dd').format(DateTime.now());
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
          orderesponselist = listResult.map((json) => OrderResult.fromJson(json)).toList();
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
        viewOrdersProvider.storeIntoViewOrderProvider(data!
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
    return Consumer<ViewOrdersProvider>(
      builder: (context, ordersProvider, _) => Scaffold(
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
              List<OrderResult> data = ordersProvider.viewOrderProviderData;

              return Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _viewOrdersSearchBarAndFilter(),
                    const SizedBox(
                      height: 10.0,
                    ),
                    if (ordersProvider.viewOrderProviderData.isNotEmpty)
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
                                orderResult: data[index],
                                formattedDate: formattedDate);
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
                                  'No Orders found!',
                                  style: CommonUtils.Mediumtext_14_cb,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                  ],
                ),
              );
            }
          },
        ),
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
                    // Handle the click event for the back button
                    viewOrdersProvider.clearFilter();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
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
                    viewOrdersProvider.clearFilter();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
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
}





class OrderCard extends StatefulWidget {
  final OrderResult orderResult;
  final String formattedDate;
  const OrderCard({
    super.key,
    required this.orderResult,
    required this.formattedDate,
  });

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

  late ViewOrdersProvider viewOrdersProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    viewOrdersProvider = Provider.of<ViewOrdersProvider>(context);
  }

// start

  @override
  Widget build(BuildContext context) {
    // String dateString = widget.listResult.date;
    // DateTime date = DateTime.parse(dateString);
    // String formattedDate = DateFormat('dd MMM, yyyy').format(date);
    return GestureDetector(
      onTap: () {
        viewOrdersProvider.clearFilter();
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
                partyAddress: widget.orderResult.partyAddress),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        color: Colors.transparent,
        child: Card(
          elevation: 5,
          child: Container(
            padding:  EdgeInsets.all(12),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.orderResult.partyName,
                                style: CommonUtils.Mediumtext_14_cb,
                                softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                height: 5.0,
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
                                  // const Text(
                                  //   'Total Amount : ',
                                  //   style: CommonUtils.txSty_13B_Fb,
                                  // ),
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
                const SizedBox(
                  height: 5.0,
                ),
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 5.0),
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 7),
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
                          const Expanded(child: SizedBox()),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Row(
                              //   children: [
                              //     Text(
                              //       widget.formattedDate,
                              //       style: CommonUtils.txSty_13O_F6,
                              //     ),
                              //   ],
                              // ),
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
                )
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
}