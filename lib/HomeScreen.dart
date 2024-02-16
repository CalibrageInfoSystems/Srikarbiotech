import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikarbiotech/ViewOrders.dart';

import 'package:srikarbiotech/forgot_password_screen.dart';
import 'package:srikarbiotech/view_collection_page.dart';

import 'ChangePassword.dart';
import 'Common/CommonUtils.dart';
import 'Common/Constants.dart';
import 'Common/SharedPreferencesHelper.dart';
import 'Common/SharedPrefsData.dart';
import 'Companiesselection.dart';
import 'LoginScreen.dart';
import 'Selectpartyscreen.dart';
import 'ViewReturnorder.dart';

class HomeScreen extends StatefulWidget {
  @override
  _home_Screen createState() => _home_Screen();
}

class _home_Screen extends State<HomeScreen> {
  int currentIndex = 0;
  int CompneyId = 0;
  String? userId = "";
  String? companyName = "";
  String? slpCode = "";
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    CommonUtils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        print('Connected to the internet');
        getshareddata();
      } else {
        CommonUtils.showCustomToastMessageLong(
            'No Internet Connection', context, 1, 4);
        print('Not connected to the internet'); // Not connected to the internet
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height / 3;
    return WillPopScope(
      onWillPop: () async {
        // Handle back button press here
        // You can add any custom logic before closing the app
        return true; // Return true to allow back button press and close the app
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 5.0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: FutureBuilder(
            future: getshareddata(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                Widget logoWidget = CompneyId == 1
                    ? SvgPicture.asset('assets/srikar_biotech_logo.svg')
                    : Image.asset('assets/srikar-seed.png',
                    width: 60.0, height: 40.0);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                    ),
                    GestureDetector(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: const Icon(Icons.menu,color: Color(0xFFe78337), size: 30,),
                    ),
                    const SizedBox(
                      width: 2.0,
                    ),
                    SizedBox(
                      width: 50.0,
                      height: 50.0,
                      child: logoWidget,
                    ),
                    const SizedBox(
                      width: 2.0,
                    ),
                    Text(
                      '$companyName',
                      style: const TextStyle(
                        color: Color(0xFF414141),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(
                      width: 10.0,
                    ),
                  ],
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
        drawer: Drawer(
          elevation: 16,
          width: MediaQuery.of(context).size.width / 1.8,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(50),
              ),
              color: Colors.white10,
            ),
            child: Column(
              children: [
                // header
                DrawerHeader(
                  child: Center(
                    child:  CompneyId == 1
            ? SvgPicture.asset('assets/srikar_biotech_logo.svg')
                  : Image.asset('assets/srikar-seed.png',

                      width: MediaQuery.of(context).size.height / 3.2,
                      height: MediaQuery.of(context).size.height / 3.2,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                // options

                ListTile(
                  leading: const Icon(Icons.key),
                  title: const Text('Change Password',
                      style: CommonUtils.txSty_14B_Fb),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ChangePassword(
                          companyId: 1,),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text(
                    'Logout',
                    style: CommonUtils.txSty_14B_Fb,
                  ),
                  onTap: () async {
                    logOutDialog();
                  },
                ),
              ],
            ),
          ),
        ),
        body: imageslider(),
      ),
    );
  }

  Future<void> getshareddata() async {
    userId = await SharedPrefsData.getStringFromSharedPrefs("userId");
    slpCode = await SharedPrefsData.getStringFromSharedPrefs("slpCode");
    companyName = await SharedPrefsData.getStringFromSharedPrefs("companyName");
    CompneyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
    print('User ID: $userId');
    print('SLP Code: $slpCode');
    print('Company ID: $CompneyId');
    print('companyName: $companyName');
  }

  void logOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to Logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirmLogout();
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void onConfirmLogout() {
    SharedPreferencesHelper.putBool(Constants.IS_LOGIN, false);
    CommonUtils.showCustomToastMessageLong("Logout Successful", context, 0, 3);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => Companiesselection()),
          (route) => false,
    );
  }
}

class BannerImages {
  final String FilePath;
  final int Id;

  BannerImages({required this.FilePath, required this.Id});
}

class imageslider extends StatefulWidget {
  @override
  _imagesliderState createState() => _imagesliderState();
}

class _imagesliderState extends State<imageslider> {
  int currentIndex = 0;
  List<BannerImages> imageList = [];

  @override
  initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    //  imageList.length = 3;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: 10.0,
              right: 10.0,
            ),
            child: Column(
              children: [
                Expanded(
                  //   child: SingleChildScrollView(
                    child: Container(
                      // width: MediaQuery.of(context).size.width,
                      //  padding: EdgeInsets.all(20.0),

                        height: MediaQuery.of(context).size.height,
                        padding:
                        EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                        width: MediaQuery.of(context).size.width,
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: CarouselSlider(
                                items: [
                                  Image.asset(
                                    'assets/slider1.png',
                                    fit: BoxFit.fitWidth,
                                    width: MediaQuery.of(context).size.width,
                                  ),
                                  Image.asset(
                                    'assets/slider2.png',
                                    fit: BoxFit.fitWidth,
                                    width: MediaQuery.of(context).size.width,
                                  ),
                                  Image.asset(
                                    'assets/slider3.png',
                                    fit: BoxFit.fitWidth,
                                    width: MediaQuery.of(context).size.width,
                                  ),
                                  // Add more static images as needed
                                ],
                                options: CarouselOptions(
                                  scrollPhysics: const BouncingScrollPhysics(),
                                  autoPlay: true,
                                  height: MediaQuery.of(context).size.height,
                                  aspectRatio: 23 / 9,
                                  viewportFraction: 1,
                                  onPageChanged: (index, reason) {
                                    // Handle page change if needed
                                    setState(() {
                                      currentIndex = index;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              //  padding: EdgeInsets.all(20.0),

                              height: MediaQuery.of(context).size.height,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 25.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      // Use the number of images from assets
                                      3, // Replace with the actual number of assets
                                          (index) => buildIndicator(index),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ))
                  //  )
                ),
                SizedBox(
                  height: 5.0,
                ),
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(
                        left: 10.0,
                        right: 10.0,
                        top: 0.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            //mainAxisAlignment: MainAxisAlignment.end,
                            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height / 3,
                                child: Row(
                                  children: [
                                    _customheightCard(
                                      imageUrl: "receipt.svg",
                                      item: "Ledger",
                                      color: Color(0xFFe78337),
                                      item_1:
                                      "All Incoming and Outgoing Transactions record",
                                      color_1: Color(0xFFF8dac2),
                                      textcolor: Colors.white,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                Selectpartyscreen(
                                                    from: 'Ledger'),
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(
                                      width: 5.0,
                                    ),
                                    Container(
                                      height:
                                      MediaQuery.of(context).size.height /
                                          3,
                                      //     (4 / 9) -
                                      // 160 / 2,

                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          _customcontainerCard(
                                            imageUrl: "shopping_cart_add.svg",
                                            item: "Create Order",
                                            item1: "Create a New Order",
                                            color: Color(0xFFF8dac2),
                                            color_1: Color(0xFFec9d62),
                                            textcolor: Color(0xFFe78337),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      Selectpartyscreen(
                                                          from: 'CreateOrder'),
                                                ),
                                              );
                                            },
                                          ),
                                          // Spacer(),
                                          // SizedBox(
                                          //   height: 4.0,
                                          // ),
                                          // SizedBox(
                                          //   height: MediaQuery.of(context).size.height *
                                          //       0.02, // 2% of the screen height
                                          // ),
                                          _customcontainerCard(
                                            imageUrl: "bags-orders.svg",
                                            item: "View Orders",
                                            item1: "View All Order",
                                            color: Color(0xFFb7dbc1),
                                            color_1: Color(0xFF43a05a),
                                            textcolor: Color(0xFF118730),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ViewOrders()),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    // _customheightCard(
                                    //   imageUrl: "receipt.svg",
                                    //   item: "Ledger",
                                    //   color: Color(0xFFe78337),
                                    //   item_1:
                                    //       "All Incoming and Outgoing Transactions record",
                                    //   color_1: Color(0xFFF8dac2),
                                    //   textcolor: Colors.white,
                                    //   onTap: () {
                                    //     Navigator.push(
                                    //       context,
                                    //       MaterialPageRoute(
                                    //         builder: (context) =>
                                    //             Selectpartyscreen(from: 'Ledger'),
                                    //       ),
                                    //     );
                                    //   },
                                    // ),
                                    // SizedBox(
                                    //   width: 7.0,
                                    // ),
                                    // Container(
                                    //   height: MediaQuery.of(context).size.height / 3,
                                    //   //     (4 / 9) -
                                    //   // 160 / 2,
                                    //
                                    //   child: Column(
                                    //     mainAxisAlignment:
                                    //         MainAxisAlignment.spaceBetween,
                                    //     children: [
                                    //       _customcontainerCard(
                                    //         imageUrl: "shopping_cart_add.svg",
                                    //         item: "Create Order",
                                    //         item1: "Create a New Order",
                                    //         color: Color(0xFFF8dac2),
                                    //         color_1: Color(0xFFec9d62),
                                    //         textcolor: Color(0xFFe78337),
                                    //         onTap: () {
                                    //           Navigator.push(
                                    //             context,
                                    //             MaterialPageRoute(
                                    //               builder: (context) =>
                                    //                   Selectpartyscreen(
                                    //                       from: 'CreateOrder'),
                                    //             ),
                                    //           );
                                    //         },
                                    //       ),
                                    //       // Spacer(),
                                    //       // SizedBox(
                                    //       //   height: 4.0,
                                    //       // ),
                                    //       // SizedBox(
                                    //       //   height: MediaQuery.of(context).size.height *
                                    //       //       0.02, // 2% of the screen height
                                    //       // ),
                                    //       _customcontainerCard(
                                    //         imageUrl: "shoppingbag.svg",
                                    //         item: "View Orders",
                                    //         item1: "View All Order",
                                    //         color: Color(0xFFb7dbc1),
                                    //         color_1: Color(0xFF43a05a),
                                    //         textcolor: Color(0xFF118730),
                                    //         onTap: () {
                                    //           Navigator.push(
                                    //             context,
                                    //             MaterialPageRoute(
                                    //                 builder: (context) =>
                                    //                     ViewOrders()),
                                    //           );
                                    //         },
                                    //       ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            // mainAxisAlignment: MainAxisAlignment.spaceAround,
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height:
                                  MediaQuery.of(context).size.height / 6,
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                    children: [
                                      _customwidthCard(
                                        imageUrl: "creditcard.svg",
                                        item: "Create Collections",
                                        item1: "Create a New Collection ",
                                        color: Color(0xFFb7dbc1),
                                        color_1: Color(0xFF43a05a),
                                        textcolor: Color(0xFF118730),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  Selectpartyscreen(
                                                      from:
                                                      'CreateCollections'),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Container(
                                  height:
                                  MediaQuery.of(context).size.height / 6,
                                  child: Row(
                                    // mainAxisAlignment:
                                    //     MainAxisAlignment.spaceAround,
                                    children: [
                                      _customcontainerCard(
                                        imageUrl: "album_collection.svg",
                                        item: "View Collections",
                                        item1: "View All Collections",
                                        color: Color(0xFFF8dac2),
                                        color_1: Color(0xFFec9d62),
                                        textcolor: Color(0xFFe78337),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewCollectionPage()),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                // _customwidthCard(
                                //   imageUrl: "creditcard.svg",
                                //   item: "Create Collections",
                                //   item1: "Create a New Collection",
                                //   color: Color(0xFFb7dbc1),
                                //   color_1: Color(0xFF43a05a),
                                //   textcolor: Color(0xFF118730),
                                //   onTap: () {
                                //     Navigator.push(
                                //       context,
                                //       MaterialPageRoute(
                                //         builder: (context) => Selectpartyscreen(
                                //             from: 'CreateCollections'),
                                //       ),
                                //     );
                                //   },
                                // ),
                                // SizedBox(
                                //   width: 8.0,
                                // ),
                                // _customwidthCard(
                                //   imageUrl: "album_collection.svg",
                                //   item: "View Collections",
                                //   item1: "View All Collections",
                                //   color: Color(0xFFF8dac2),
                                //   color_1: Color(0xFFec9d62),
                                //   textcolor: Color(0xFFe78337),
                                //   onTap: () {
                                //     Navigator.push(
                                //       context,
                                //       MaterialPageRoute(
                                //           builder: (context) =>
                                //               ViewCollectionPage()),
                                //     );
                                //   },
                                // ),
                              ]),
                          SizedBox(height: 5), // Add spacing between rows

                          Row(
                            //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height:
                                  MediaQuery.of(context).size.height / 6,
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                    children: [
                                      _customwidthCard(
                                        imageUrl: "arrows_repeat.svg",
                                        item: "Create Return order",
                                        item1: "Create a Return order",
                                        color: Color(0xFFF8dac2),
                                        color_1: Color(0xFFec9d62),
                                        textcolor: Color(0xFFe78337),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  Selectpartyscreen(
                                                      from:
                                                      'CreatereturnOrder'),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Container(
                                  height:
                                  MediaQuery.of(context).size.height / 6,
                                  child: Row(
                                    // mainAxisAlignment:
                                    //     MainAxisAlignment.spaceAround,
                                    children: [
                                      _customcontainerCard(
                                        imageUrl: "bags-orders.svg",
                                        item: "View Return order",
                                        item1: "View All Reorders",
                                        color: Color(0xFFb7dbc1),
                                        color_1: Color(0xFF43a05a),
                                        textcolor: Color(0xFF118730),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewReturnorder()),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                // _customwidthCard(
                                //   imageUrl: "arrows_repeat.svg",
                                //   item: "Create Return order",
                                //   item1: "Create a Reorder",
                                //   color: Color(0xFFF8dac2),
                                //   color_1: Color(0xFFec9d62),
                                //   textcolor: Color(0xFFe78337),
                                //   onTap: () {
                                //     Navigator.push(
                                //       context,
                                //       MaterialPageRoute(
                                //         builder: (context) => Selectpartyscreen(
                                //             from: 'CreatereturnOrder'),
                                //       ),
                                //     );
                                //   },
                                // ),
                                // SizedBox(
                                //   width: 8.0,
                                // ),
                                // _customwidthCard(
                                //   imageUrl: "shoppingbag.svg",
                                //   item: "View Return order",
                                //   item1: "View All Reorders",
                                //   color: Color(0xFFb7dbc1),
                                //   color_1: Color(0xFF43a05a),
                                //   textcolor: Color(0xFF118730),
                                //   onTap: () {
                                //     Navigator.push(
                                //       context,
                                //       MaterialPageRoute(
                                //           builder: (context) =>
                                //               ViewReturnorder()),
                                //     );
                                //   },
                                // ),
                              ]),
                        ],
                      ),
                    ),
                  ),
                )
                // width: 300.0,
              ],
            ),
          ),
        ),
      ],
    );
  }

  _customheightCard({
    required String imageUrl,
    required String item,
    required String item_1,
    required Color color,
    required Color color_1,
    required Color textcolor,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        //  height: MediaQuery.of(context).size.height * (4 / 9) - 250 / 2,
        height: MediaQuery.of(context).size.height / 3,
        // height: height,
        width: MediaQuery.of(context).size.width / 2.25,
        child: Card(
          color: color,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 8,
          child: Padding(
            padding: EdgeInsets.only(left: 18, right: 15, top: 20, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 0),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color_1,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: SvgPicture.asset(
                    "assets/" + imageUrl,
                    width: 30.0,
                    height: 30.0,
                    color: Color(0xFF414141),
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w700,
                        color: textcolor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                            fontSize: 14,
                            color: textcolor,
                            fontFamily: "Roboto",
                            fontWeight: FontWeight.w600),
                        children: [
                          // TextSpan(
                          //   text: 'All Incoming and\n',
                          // ),
                          // WidgetSpan(
                          //   child: SizedBox(height: 25),
                          // ),
                          // TextSpan(
                          //   text: 'Outgoing Transactions\n',
                          // ),
                          // WidgetSpan(
                          //   child: SizedBox(height: 25),
                          // ),
                          // TextSpan(
                          //   text: 'Record',
                          // ),
                          TextSpan(
                              text:
                              'All Incoming and Outgoing Transactions record',
                              style: TextStyle(height: 1.5))
                        ],
                      ),
                    ),
                  ),
                ),
                // SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _customwidthCard({
    required String imageUrl,
    required String item,
    required Color color,
    required String item1,
    required VoidCallback? onTap,
    required Color color_1,
    required Color textcolor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        //  height: MediaQuery.of(context).size.width * (3.8 / 9) - 110 / 2,
        width: MediaQuery.of(context).size.width / 2.25,
        //  height: 275 / 2,
        height: MediaQuery.of(context).size.height / 6,
        child: Card(
          color: color,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 8,
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 15, top: 7, bottom: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 8),
                Container(
                  margin: EdgeInsets.only(bottom: 6),
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color_1,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: SvgPicture.asset(
                    "assets/" + imageUrl,
                    width: 20.0,
                    height: 22.0,
                    color: Color(0xFF414141),
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      item,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w700,
                          color: textcolor),
                    ),
                  ),
                ),
                // SizedBox(
                //   height: 8.0,
                // ),
                Text(
                  item1,
                  style: TextStyle(
                      fontSize: 12,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF414141)),
                ),
                // Expanded(
                //   child: Align(
                //     alignment: Alignment.topLeft,
                //     child: Text(
                //       item1,
                //       style: TextStyle(
                //           fontSize: 12,
                //           fontFamily: "Roboto",
                //           fontWeight: FontWeight.w500,
                //           color: Color(0xFF414141)),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _customcontainerCard({
    required String imageUrl,
    required String item,
    required Color color,
    required String item1,
    required VoidCallback? onTap,
    required Color color_1,
    required Color textcolor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        //height: 260 / 2,
        height: MediaQuery.of(context).size.height / 6,
        width: MediaQuery.of(context).size.width / 2.3,
        child: Card(
          color: color,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 8,
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 15, top: 7, bottom: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 8),
                Container(
                  margin: EdgeInsets.only(bottom: 6),
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color_1,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: SvgPicture.asset(
                    "assets/" + imageUrl,
                    width: 20.0,
                    height: 22.0,
                    color: Color(0xFF414141),
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      item,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w700,
                          color: textcolor),
                    ),
                  ),
                ),
                // SizedBox(
                //   height: 8.0,
                // ),
                Text(
                  item1,
                  style: TextStyle(
                      fontSize: 12,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF414141)),
                ),
                // Expanded(
                //   child: Align(
                //     alignment: Alignment.topLeft,
                //     child: Text(
                //       item1,
                //       style: TextStyle(
                //           fontSize: 12,
                //           fontFamily: "Roboto",
                //           fontWeight: FontWeight.w500,
                //           color: Color(0xFF414141)),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildIndicator(int index) {
    return Container(
      width: 8,
      height: 8,
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: index == currentIndex ? Colors.orange : Colors.grey,
      ),
    );
  }
}
