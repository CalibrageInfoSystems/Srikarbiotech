import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikarbiotech/ViewOrders.dart';

import 'package:srikarbiotech/view_collection_page.dart';
import 'package:http/http.dart' as http;
import 'ChangePassword.dart';
import 'Common/CommonUtils.dart';
import 'Common/Constants.dart';
import 'Common/SharedPreferencesHelper.dart';
import 'Common/SharedPrefsData.dart';
import 'Companiesselection.dart';
import 'LoginScreen.dart';
import 'Selectpartyscreen.dart';
import 'Services/api_config.dart';
import 'StateSelectionScreen.dart';
import 'ViewGroupreportsStatewise.dart';
import 'ViewReturnorder.dart';
import 'Viewpendingorder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _home_Screen createState() => _home_Screen();
}

class _home_Screen extends State<HomeScreen> {
  int currentIndex = 0;
  int CompneyId = 0;
  String? userId = "";
  String? companyName = "";
  String? slpCode = "";
  String? userName = "";
  String? roleName = "";
  String? fullname = "";
  String? phoneNumber = "";
  String? email = "";
  String? reporingManagerName = "";
  Map<String, dynamic>? categories;
  List<String> categoriesList = [];

  late ExpandedTileController _expandedTileController;

  @override
  void initState() {
    super.initState();

    _expandedTileController = ExpandedTileController(isExpanded: false);
    // getshareddata();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height / 3;

    getshareddata();
    return WillPopScope(
      onWillPop: () async {
        // Show a confirmation dialog
        bool confirmClose = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Exit'),
              content: Text('Are you sure you want to close the app?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), // Close the dialog and return false
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true), // Close the dialog and return true
                  child: Text('Yes'),
                ),
              ],
            );
          },
        );

        // Close the app if user confirms
        if (confirmClose == true) {
          // Close the app
          SystemNavigator.pop();
        }

        // Return false to prevent default back button behavior
        return false;
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
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                // final companyName = snapshot.data['companyName'];

                Widget logoWidget = CompneyId == 1 ? SvgPicture.asset('assets/srikar_biotech_logo.svg') : Image.asset('assets/srikar-seed.png', width: 60.0, height: 40.0);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                      child: GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openDrawer();
                        },
                        child: const Icon(
                          Icons.menu,
                          color: Color(0xFFe78337),
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2.0),
                    SizedBox(
                      width: 50.0,
                      height: 50.0,
                      child: logoWidget,
                    ),
                    const SizedBox(width: 2.0),
                    Text(
                      '$companyName',
                      style: const TextStyle(
                        color: Color(0xFF414141),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 10.0),
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
          width: MediaQuery.of(context).size.width / 1.5,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: SingleChildScrollView(
            child: FutureBuilder(
              future: getshareddata(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(50),
                      ),
                      color: Colors.white10,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              // Container(
                              //   margin: const EdgeInsets.only(left: 35),
                              //   width: MediaQuery.of(context).size.height / 5,
                              //   height: MediaQuery.of(context).size.height / 5,
                              //   padding: const EdgeInsets.all(20),
                              //   child: Center(
                              //     child: CompneyId == 1
                              //         ? SvgPicture.asset(
                              //         'assets/srikar_biotech_logo.svg')
                              //         : Image.asset(
                              //       'assets/srikar-seed.png',
                              //       // width: MediaQuery.of(context).size.height / 4,
                              //       // height:
                              //       //     MediaQuery.of(context).size.height / 4,
                              //     ),
                              //   ),
                              // ),
                              Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  margin: CompneyId == 1 ? const EdgeInsets.only(left: 35.0) : EdgeInsets.zero,
                                  width: MediaQuery.of(context).size.height / 5,
                                  height: MediaQuery.of(context).size.height / 5,
                                  padding: const EdgeInsets.all(20),
                                  // padding: CompneyId == 1 ? const EdgeInsets.all(20) : EdgeInsets.zero,
                                  child: Center(
                                    child: CompneyId == 1
                                        ? SvgPicture.asset('assets/srikar_biotech_logo.svg')
                                        : Image.asset(
                                            'assets/srikar-seed.png',
                                          ),
                                  ),
                                ),
                              ),
                              Container(
                                color: Colors.transparent,
                                child: Column(
                                  children: [
                                    Text('$fullname', style: CommonUtils.header_Styles18),
                                    SizedBox(height: 2.0),
                                    Text('$roleName', style: CommonUtils.Mediumtext_12),
                                    // Text('slpCode - $slpCode',
                                    //     style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: double.infinity,
                                height: 0.2,
                                color: Colors.grey,
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 13),
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                child: ExpandedTile(
                                  controller: _expandedTileController,
                                  theme: const ExpandedTileThemeData(
                                    headerColor: Colors.transparent,
                                    headerPadding: EdgeInsets.all(0),
                                    headerSplashColor: Colors.transparent,
                                    contentBackgroundColor: Colors.transparent,
                                    // contentPadding: EdgeInsets.all(15),
                                    // contentRadius: 12.0,
                                  ),
                                  leading: const Icon(
                                    Icons.person,
                                    color: Colors.black,
                                    size: 22,
                                  ),
                                  title: const Text(
                                    ' User Profile',
                                    style: CommonUtils.txSty_14B_Fb,
                                  ),
                                  content: Container(
                                    color: Colors.transparent,
                                    child: Column(
                                      children: [
                                        ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: Container(
                                            padding: const EdgeInsets.all(10), // Adjust padding as needed
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: const Icon(
                                              Icons.code_outlined,
                                              size: 20, // Reduce the size of the icon
                                              color: Colors.blue,
                                            ),
                                          ),
                                          title: Text(
                                            '$slpCode',
                                            style: CommonUtils.txSty_14B_Fb,
                                          ),
                                          subtitle: const Text(
                                            'SlpCode',
                                            style: CommonUtils.Mediumtext_12,
                                          ),
                                        ),
                                        ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: Container(
                                            padding: const EdgeInsets.all(10), // Set padding to zero
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: const Icon(
                                              Icons.email_outlined,
                                              size: 20,
                                              color: Colors.orange,
                                            ),
                                          ),
                                          title: Text(
                                            addEllipsisIfNeeded(email as String),
                                            style: CommonUtils.txSty_14B_Fb,
                                          ),
                                          subtitle: const Text(
                                            'Email',
                                            style: CommonUtils.Mediumtext_12,
                                          ),
                                        ),
                                        ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: const Icon(
                                                Icons.call,
                                                size: 20,
                                                color: Colors.red,
                                              )),
                                          title: Text('$phoneNumber', style: CommonUtils.txSty_14B_Fb),
                                          subtitle: const Text(
                                            'Phone Number',
                                            style: CommonUtils.Mediumtext_12,
                                          ),
                                        ),
                                        ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: const Icon(
                                                Icons.add_business_rounded,
                                                size: 20,
                                                color: Colors.green,
                                              )),
                                          title: Text('$companyName', style: CommonUtils.txSty_14B_Fb),
                                          subtitle: const Text(
                                            'Company Name',
                                            style: CommonUtils.Mediumtext_12,
                                          ),
                                        ),
                                        if (reporingManagerName != null)
                                          ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: Container(
                                                padding: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFe78337).withOpacity(0.2),
                                                  // color: const Color.fromARGB(
                                                  //     255, 178, 236, 180),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: const Icon(
                                                  Icons.manage_accounts_rounded,
                                                  size: 20,
                                                  color: Color(0xFFe78337),
                                                )),
                                            title: Text('$reporingManagerName', style: CommonUtils.txSty_14B_Fb),
                                            subtitle: const Text(
                                              'Reporing Manager Name',
                                              style: CommonUtils.Mediumtext_12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              ListTile(
                                horizontalTitleGap: 0, // Remove spacing before the icon
                                leading: const Icon(
                                  Icons.key,
                                  color: Colors.black,
                                ),
                                title: const Text(
                                  'Change Password',
                                  style: CommonUtils.txSty_14B_Fb,
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const ChangePassword(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                          horizontalTitleGap: 0, // Remove spacing before the icon
                          leading: const Icon(
                            Icons.logout,
                            color: Colors.black,
                          ),
                          title: const Text('Logout', style: CommonUtils.txSty_14B_Fb),
                          onTap: () async {
                            logOutDialog();
                          },
                        ),
                      ],
                    ),
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ),
        ),
        body: imageslider(categoriesList),
      ),
    );
  }

  String addEllipsisIfNeeded(String inputString) {
    if (inputString.length > 13) {
      return '${inputString.substring(0, 12)}...';
    } else {
      return inputString;
    }
  }

  Future<void> getshareddata() async {
    userId = await SharedPrefsData.getStringFromSharedPrefs("userId");
    slpCode = await SharedPrefsData.getStringFromSharedPrefs("slpCode");
    companyName = await SharedPrefsData.getStringFromSharedPrefs("companyName");
    CompneyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
    userName = await SharedPrefsData.getStringFromSharedPrefs("userName");
    roleName = await SharedPrefsData.getStringFromSharedPrefs("roleName");
    final categories = await SharedPreferencesHelper.getCategories();

    fullname = categories!['response']['fullName'];
    phoneNumber = categories['response']['phoneNumber'];
    email = categories['response']['email'];
    reporingManagerName = categories['response']['reporingManagerName'];

    // Access the "response" object and then the "activityRights" array
    List<dynamic> activityRights = categories['response']['activityRights'];

    // Extract the "name" values from the "activityRights" array
    List<String> categoriesList = [];
    for (var activityRight in activityRights) {
      String name = activityRight['name'];
      categoriesList.add(name);
    }

    // Print the extracted "name" values
    print('Categories: $categoriesList');

// Print the fetched categories
  }

  void logOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to Logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirmLogout();
              },
              child: const Text('Logout'),
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
      MaterialPageRoute(builder: (context) => const Companiesselection()),
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
  const imageslider(List<String> categoriesList, {super.key});

  @override
  _imagesliderState createState() => _imagesliderState();
}

class _imagesliderState extends State<imageslider> {
  int currentIndex = 0;
  List<BannerImages> imageList = [];
  List<String> categoriesList = [];
  int CompneyId = 0;
  final CarouselController carouselController = CarouselController();

  late final Future<Map<String, dynamic>?> categoriesFuture = SharedPreferencesHelper.getCategories();

  @override
  initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    // getshareddata();
    CommonUtils.checkInternetConnectivity().then(
          (isConnected) {
        if (isConnected) {
          fetchImages();
          print('The Internet Is Connected');
        } else {
          CommonUtils.showCustomToastMessageLong(
              'Please check your internet  connection', context, 1, 4);
          print('The Internet Is not  Connected');
        }
      },
    );

    //  imageList.length = 3;
  }

  Future<void> fetchImages() async {
    CompneyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
    final apiurl = '${baseUrl + GetBanners + CompneyId.toString() + "/null"}';

    //final url = Uri.parse('http://182.18.157.215/Srikar_Biotech_Dev/API/api/Banner/GetBannersDataInfo/$CompneyId/null');
    print('BannersApi: $apiurl');
    try {
      final response = await http.get(
        Uri.parse(apiurl),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        List<BannerImages> bannerImages = [];
        for (var item in jsonData['response']['listResult']) {
          bannerImages.add(BannerImages(FilePath: item['fileUrl'], Id: item['id']));
        }

        setState(() {
          imageList = bannerImages;
        });
      } else {
        // Handle error if the API request was not successful
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any exception that occurred during the API call
      print('Error: $error');
    }
  }

  // Future<void> getshareddata() async {
  //   CompneyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
        future: categoriesFuture,
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>?> categories) {
          if (categories.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Or any other loading indicator
          } else if (categories.hasError || categories.data == null) {
            return Text('Error: Failed to fetch categories');
          } else {
            final categoriesData = categories.data!;
            List<dynamic>? activityRights = categoriesData['response']['activityRights'];
            if (activityRights == null) {
              return Text('Error: No activity rights found');
            }
            print('activityRights: $activityRights');

            List<String> categoriesList = [];
            for (var activityRight in activityRights) {
              String name = activityRight['name'];
              categoriesList.add(name);
            }

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
                        Visibility(
                            visible: imageList != null && imageList.isNotEmpty,
                            child: Expanded(
                                //   child: SingleChildScrollView(
                                child: Container(
                                    // width: MediaQuery.of(context).size.width,
                                    //  padding: EdgeInsets.all(20.0),

                                    height: MediaQuery.of(context).size.height,
                                    padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                                    width: MediaQuery.of(context).size.width,
                                    child: Stack(
                                      children: [

                                        Align(
                                          alignment: Alignment.topCenter,
                                          child: CarouselSlider(
                                            items: imageList
                                                .map((item) => Image.network(
                                                      item.FilePath,
                                                      fit: BoxFit.fitWidth,
                                                      width: MediaQuery.of(context).size.width,
                                                    ))
                                                .toList(),
                                            carouselController: carouselController,
                                            options: CarouselOptions(
                                              scrollPhysics: const BouncingScrollPhysics(),
                                              autoPlay: true,
                                              height: MediaQuery.of(context).size.height,
                                              aspectRatio: 23 / 9,
                                              viewportFraction: 1,
                                              onPageChanged: (index, reason) {
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
                                                children: imageList.asMap().entries.map((entry) {
                                                  final index = entry.key;
                                                  return buildIndicator(index);
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ))

                                //  )
                                )),
                        SizedBox(
                          height: 5.0,
                        ),
                        Expanded(
                            flex: 4,
                            child: SingleChildScrollView(
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // First Container with single card view
                                        Expanded(
                                          child: Container(
                                            height: MediaQuery.of(context).size.height / 3,
                                            child: _customheightCard(
                                              imageUrl: "receipt.svg",
                                              item: "Ledger",
                                              color: Color(0xFFe78337),
                                              item_1: "All Incoming and Outgoing Transactions record",
                                              color_1: Color(0xFFF8dac2),
                                              textcolor: Colors.white,
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => Selectpartyscreen(from: 'Ledger'),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        // Second Container divided into two equal-sized containers
                                        Expanded(
                                          child: Container(
                                            height: MediaQuery.of(context).size.height / 3, // Match height with the first container
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    child: _customcontainerCard(
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
                                                            builder: (context) => Selectpartyscreen(from: 'CreateOrder'),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Expanded(
                                                  child: Container(
                                                    child: _customcontainerCard(
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
                                                            builder: (context) => ViewOrders(),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 5), // Add some spacing between the rows
                                    // Second Row
                                    Row(
                                      children: [
                                        // First Container with single card view
                                        Expanded(
                                          child: Container(
                                            height: MediaQuery.of(context).size.height / 3, // Match height with the first container
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    child: _customcontainerCard(
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
                                                            builder: (context) => Selectpartyscreen(from: 'CreateCollections'),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Expanded(
                                                  child: Container(
                                                    child: _customcontainerCard(
                                                      imageUrl: "arrows_repeat.svg",
                                                      item: "Create Return order",
                                                      item1: "Create a Reorder",
                                                      color: Color(0xFFF8dac2),
                                                      color_1: Color(0xFFec9d62),
                                                      textcolor: Color(0xFFe78337),
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => Selectpartyscreen(from: 'CreatereturnOrder'),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Second Container divided into two equal-sized containers

                                        Expanded(
                                          child: Container(
                                            height: MediaQuery.of(context).size.height / 3, // Match height with the first container
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    child: _customcontainerCard(
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
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Expanded(
                                                  child: Container(
                                                    child: _customcontainerCard(
                                                      imageUrl: "bags-orders.svg",
                                                      item: "View Return order",
                                                      item1: "View All Reorders",
                                                      color: Color(0xFFb7dbc1),
                                                      color_1: Color(0xFF43a05a),
                                                      textcolor: Color(0xFF118730),
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(builder: (context) => ViewReturnorder()),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (categoriesList.contains("CanSHApprovalRejectOrder"))
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically centered
                                        children: [
                                          // First Container with single card view
                                          Expanded(
                                            child: Container(
                                              height: MediaQuery.of(context).size.height / 10, // Match height with the first container
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Align items vertically centered
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      child: _customcontainernewCard(
                                                        imageUrl: "bags-orders.svg",
                                                        item: "Approve Orders",
                                                        item1: "View All Pending Orders ",
                                                        color: Color(0xFFb7dbc1),
                                                        color_1: Color(0xFF43a05a),
                                                        textcolor: Color(0xFF118730),
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(builder: (context) => Viewpendingorder()),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Second Container divided into two equal-sized containers
                                        ],
                                      ),




                                    // Row(
                                    //   children: [
                                    //     // First Container with single card view
                                    //     Expanded(
                                    //       child: Container(
                                    //         height: MediaQuery.of(context).size.height / 10, // Match height with the first container
                                    //         child: Column(
                                    //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    //           children: [
                                    //             Expanded(
                                    //               child: Container(
                                    //                 child: _customcontainernewCard(
                                    //                   imageUrl: "bags-orders.svg",
                                    //                   item: "Group Summary Report ",
                                    //                   item1: "View Group Summary Report ",
                                    //                   color: Color(0xFFF8dac2),
                                    //                   color_1: Color(0xFFec9d62),
                                    //                   textcolor: Color(0xFFe78337),
                                    //                   onTap: () {
                                    //                     Navigator.push(
                                    //                       context,
                                    //                       MaterialPageRoute(builder: (context) => StateSelectionScreen()),
                                    //                     );
                                    //                   },
                                    //                 ),
                                    //               ),
                                    //             ),
                                    //           ],
                                    //         ),
                                    //       ),
                                    //     ),
                                    //     // Second Container divided into two equal-sized containers
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ),
                            ))
                        // width: 300.0,
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        });
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
        height: MediaQuery.of(context).size.height / 3.3,
        // height: height,
        width: MediaQuery.of(context).size.width / 2,
        child: Card(
          color: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 8,
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
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
                SizedBox(height: 15),
                Container(
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
                        style: TextStyle(fontSize: 14, color: textcolor, fontFamily: "Roboto", fontWeight: FontWeight.w600),
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
                          TextSpan(text: 'All Incoming and Outgoing Transactions record', style: TextStyle(height: 2))
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 15, top: 7, bottom: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color_1,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: SvgPicture.asset(
                    "assets/$imageUrl",
                    width: 20.0,
                    height: 22.0,
                    color: const Color(0xFF414141),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      item,
                      maxLines: 1,
                      style: TextStyle(fontSize: 16, fontFamily: "Roboto", fontWeight: FontWeight.w700, color: textcolor),
                    ),
                  ),
                ),
                // SizedBox(
                //   height: 8.0,
                // ),
                Text(
                  item1,
                  style: const TextStyle(fontSize: 12, fontFamily: "Roboto", fontWeight: FontWeight.w500, color: Color(0xFF414141)),
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
    required String item1,
    required Color color,
    required VoidCallback? onTap,
    required Color color_1,
    required Color textcolor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        //height: 260 / 2,
        height: MediaQuery.of(context).size.height / 6,
        width: MediaQuery.of(context).size.width / 2,
        child: Card(
          color: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color_1,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SvgPicture.asset(
                    "assets/$imageUrl",
                    width: 20.0,
                    height: 22.0,
                    color: const Color(0xFF414141),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      item,
                      maxLines: 1,
                      style: TextStyle(fontSize: 16, fontFamily: "Roboto", fontWeight: FontWeight.w700, color: textcolor),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                Text(
                  item1,
                  style: const TextStyle(fontSize: 12, fontFamily: "Roboto", fontWeight: FontWeight.w500, color: Color(0xFF414141)),
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
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: index == currentIndex ? Colors.orange : Colors.grey,
      ),
    );
  }

  _customcontainernewCard({
    required String imageUrl,
    required String item,
    required String item1,
    required Color color,
    required VoidCallback? onTap,
    required Color color_1,
    required Color textcolor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 10,
        width: MediaQuery.of(context).size.width,
        child: Card(
          color: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color_1,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SvgPicture.asset(
                    "assets/$imageUrl",
                    width: 20.0,
                    height: 22.0,
                    color: const Color(0xFF414141),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Adjusted to center
                    mainAxisAlignment: MainAxisAlignment.center, // Added to center
                    children: [
                      Text(
                        item,
                        maxLines: 1,
                        style: TextStyle(fontSize: 16, fontFamily: "Roboto", fontWeight: FontWeight.w700, color: textcolor),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        item1,
                        style: const TextStyle(fontSize: 12, fontFamily: "Roboto", fontWeight: FontWeight.w500, color: Color(0xFF414141)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}
