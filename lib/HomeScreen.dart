import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:srikarbiotech/view_collection_page.dart';

import 'Selectpartyscreen.dart';


class HomeScreen extends StatefulWidget {
  @override
  _home_Screen createState() => _home_Screen();
}

class _home_Screen extends State<HomeScreen> {
  int currentIndex = 0;

  @override
  initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    // CommonUtils.checkInternetConnectivity().then((isConnected) {
    //   if (isConnected) {
    //     print('Connected to the internet');
    //     fetchImages();
    //     _getData();
    //   } else {
    //     CommonUtils.showCustomToastMessageLong('No Internet Connection', context, 1, 4);
    //     print('Not connected to the internet');  // Not connected to the internet
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    double  height = MediaQuery.of(context).size.height / 3;
    return Scaffold(
      appBar: AppBar(
        elevation: 5.0,
        backgroundColor: Colors.white,
        //  centerTitle: true,
        automaticallyImplyLeading:
        false, // Set this to false to remove back arrow
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            ),
            SvgPicture.asset(
              'assets/srikar_biotech_logo.svg',
              width: 60.0,
              height: 40.0,
              //color: Color(0xFFe78337),
            ),
            Text(
              'Srikar Bio Tech',
              style: TextStyle(
                  color: Color(0xFF414141), fontWeight: FontWeight.w600),
            ),
            Spacer(),
            SvgPicture.asset(
              'assets/bell.svg',
              width: 18.0,
              height: 25.0,
              color: Color(0xFFe78337),
            ),
            SizedBox(
              width: 15.0,
            ),
            SvgPicture.asset(
              'assets/sign-out-alt.svg',
              width: 18.0,
              height: 25.0,
              color: Color(0xFFe78337),
            ),
            SizedBox(
              width: 20.0,
            )
          ],
        ),
      ),
      body: imageslider(),
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
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                Expanded(
                    child: SingleChildScrollView(
                        child: Container(
                            padding: EdgeInsets.only(
                                left: 0.0, right: 0.0, top: 20.0),
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
                                        width:
                                        MediaQuery.of(context).size.width,
                                      ),
                                      Image.asset(
                                        'assets/slider2.png',
                                        fit: BoxFit.fitWidth,
                                        width:
                                        MediaQuery.of(context).size.width,
                                      ),
                                      Image.asset(
                                        'assets/slider3.png',
                                        fit: BoxFit.fitWidth,
                                        width:
                                        MediaQuery.of(context).size.width,
                                      ),
                                      // Add more static images as needed
                                    ],
                                    options: CarouselOptions(
                                      scrollPhysics:
                                      const BouncingScrollPhysics(),
                                      autoPlay: true,
                                      aspectRatio: 23 / 9,
                                      viewportFraction: 1,
                                      onPageChanged: (index, reason) {
                                        // Handle page change if needed
                                      },
                                    ),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 100,
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 0.0),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
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
                            )))),
                SizedBox(
                  height: 10.0,
                ),
                Expanded(
                  flex:
                  3,
                  child: SingleChildScrollView(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            //mainAxisAlignment: MainAxisAlignment.end,
                            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                          Selectpartyscreen( from: 'Ledger'),
                                    ),
                                  );

                                },
                              ),
                              SizedBox(
                                width: 7.0,
                              ),
                              Container(
                                height: MediaQuery.of(context).size.height / 3,
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
                                                Selectpartyscreen( from: 'CreateOrder'),
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
                                      imageUrl: "shoppingbag.svg",
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
                                                Selectpartyscreen( from: 'CreateOrder'),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            // crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _customwidthCard(
                                  imageUrl: "creditcard.svg",
                                  item: "Create Collections",
                                  item1: "Create a New Collection",
                                  color: Color(0xFFb7dbc1),
                                  color_1: Color(0xFF43a05a),
                                  textcolor: Color(0xFF118730),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            Selectpartyscreen( from: 'CreateCollections'),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(
                                  width: 8.0,
                                ),
                                _customwidthCard(
                                  imageUrl: "album_collection.svg",
                                  item: "View Collections",
                                  item1: "View All Collections",
                                  color: Color(0xFFF8dac2),
                                  color_1: Color(0xFFec9d62),
                                  textcolor: Color(0xFFe78337),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ViewCollectionPage()),
                                    );
                                  },
                                ),
                              ]),
                          SizedBox(height: 10), // Add spacing between rows

                          Row(
                            //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _customwidthCard(
                                  imageUrl: "arrows_repeat.svg",
                                  item: "Create Reorder",
                                  item1: "Create a Reorder",
                                  color: Color(0xFFF8dac2),
                                  color_1: Color(0xFFec9d62),
                                  textcolor: Color(0xFFe78337),
                                  onTap: () {
                                    print('Card tapped!');
                                  },
                                ),
                                SizedBox(
                                  width: 8.0,
                                ),
                                _customwidthCard(
                                  imageUrl: "shoppingbag.svg",
                                  item: "View Reorder",
                                  item1: "View All Reorders",
                                  color: Color(0xFFb7dbc1),
                                  color_1: Color(0xFF43a05a),
                                  textcolor: Color(0xFF118730),
                                  onTap: () {
                                    print('Card tapped!');
                                  },
                                ),
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
        width: MediaQuery.of(context).size.width / 2.1,
        child: Card(
          color: color,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 8,
          child: Padding(
            padding: EdgeInsets.only(left: 18, right: 15, top: 15, bottom: 8),
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
                SizedBox(height: 18),
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      item,
                      style: TextStyle(
                          fontSize: 20,
                          color: textcolor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item_1,
                      style: TextStyle(fontSize: 14, color: textcolor),
                    ),
                  ),
                ),
                SizedBox(height: 12),
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
        width: MediaQuery.of(context).size.width / 2.2,
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
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color_1,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: SvgPicture.asset(
                    "assets/" + imageUrl,
                    width: 20.0,
                    height: 25.0,
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
                      style: TextStyle(fontSize: 16, color: textcolor),
                    ),
                  ),
                ),
                // SizedBox(
                //   height: 8.0,
                // ),
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      item1,
                      style: TextStyle(fontSize: 10, color: Color(0xFF414141)),
                    ),
                  ),
                ),
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
      child: SizedBox(
        //height: 260 / 2,
        height:  MediaQuery.of(context).size.height / 6,
        width: MediaQuery.of(context).size.width / 2.2,
        child: Card(
          color: color,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 8,
          child: Padding(
            padding: EdgeInsets.only(left: 13, right: 15, top: 5, bottom: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 5),
                Container(
                  //  margin: EdgeInsets.only(bottom: 3),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color_1,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: SvgPicture.asset(
                    "assets/" + imageUrl,
                    width: 20.0,
                    height: 20.0,
                    color: Color(0xFF414141),
                  ),
                ),
                SizedBox(height: 8),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    item,
                    maxLines: 1,
                    style: TextStyle(fontSize: 16, color: textcolor),
                  ),
                ),
                SizedBox(
                  height: 3.0,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    item1,
                    style: TextStyle(fontSize: 10, color: Color(0xFF414141)),
                  ),
                ),
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
