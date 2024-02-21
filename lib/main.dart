import 'dart:async';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:srikarbiotech/vieworders_provider.dart';
import 'package:srikarbiotech/viewreturnorders_provider.dart';


import 'CartProvider.dart';
import 'Common/Constants.dart';
import 'Common/SharedPreferencesHelper.dart';
import 'Companiesselection.dart';
import 'HomeScreen.dart';
import 'LoginScreen.dart';

import 'ViewCollectionProvider.dart';
import 'ViewPendingOrdersProvider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => ViewCollectionProvider()),
        ChangeNotifierProvider(create: (context) => ViewOrdersProvider()),
        ChangeNotifierProvider(create: (context) => ViewReturnOrdersProvider()),
        ChangeNotifierProvider(create: (context) => ViewPendingOrdersProvider()),
      ],
      child:  MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    checkStoragePermission();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => CartProvider()),
          ChangeNotifierProvider(create: (context) => ViewCollectionProvider()),
          ChangeNotifierProvider(create: (context) => ViewOrdersProvider()),
        ],
        child: MyHomePage(),
      ),
    );
    //
    // return MultiProvider(
    //   providers: [
    //     ChangeNotifierProvider(create: (context) => ViewCollectionProvider()),
    //     ChangeNotifierProvider(create: (context) => CartProvider()),
    //     // Add other providers as needed
    //   ],
    //   child: MaterialApp(
    //     debugShowCheckedModeBanner: false,
    //     home: MyHomePage(),
    //   ),
    // );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //   debugShowCheckedModeBanner: false,
  //     home: MyHomePage(),
  //   );
  // }

  Future<void> checkStoragePermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.manageExternalStorage,
    ].request();

    var storage = statuses[Permission.storage];
    print('Storage permission is granted $storage');
    var manageExternalStorage = statuses[Permission.manageExternalStorage];
    print('Storage permission is granted $manageExternalStorage');
    if (storage!.isGranted || manageExternalStorage!.isGranted) {
      // // do something
      // Navigator.of(context).pushReplacement(
      //     MaterialPageRoute(builder: (context) =>  MyApp())
      //   );
    } else {
      openAppSettings();
    }
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late bool isLogin;
  late bool welcome;
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1), // Move from bottom to top
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        isLogin = await SharedPreferencesHelper.getBool(Constants.IS_LOGIN);
        welcome = await SharedPreferencesHelper.getBool(Constants.WELCOME);
        print('isLogin:$isLogin');
        print('welcome:$welcome');
        // Add any additional logic or navigation based on the retrieved values
        if (isLogin) {
          navigateToHome();
        } else {
          if (welcome) {
            navigateToLogin();
          } else {
            navigateTocompneyselection();
          }
        }
      }
    });

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/background.jpg', // Replace with your image path
            fit: BoxFit.cover,
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Image.asset(
                    'assets/Srikar-GROUP.png', // Replace with your PNG image path
                    height: 200.0,
                    width: 200.0,
                    // Adjust the height and width as needed
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => Companiesselection()),
    );
  }

  void navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  void navigateTocompneyselection() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => Companiesselection()),
    );
  }
}
