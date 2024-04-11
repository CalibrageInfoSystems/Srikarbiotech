import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'Common/CommonUtils.dart';
import 'Common/Constants.dart';
import 'Common/SharedPreferencesHelper.dart';
import 'Common/SharedPrefsData.dart';
import 'HomeScreen.dart';
import 'Model/CompanyModel.dart';
import 'Services/LocationUpdatesService.dart';
import 'Services/api_config.dart';
import 'Services/background_service.dart';
import 'forgot_password_screen.dart';
import 'location_service/logic/location_controller/location_controller_cubit.dart';

class LoginScreen extends StatefulWidget {
  // Assuming you have a class named Company
  final String companyName;
  final int companyId;

  LoginScreen({
    required this.companyName,
    required this.companyId,
  });
  @override
  State<LoginScreen> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  int compneyid = 0; // Assuming companyId is an int
  String? userId;
  String? slpCode;
  bool isLoading = false;
  bool _obscureText = true;
  bool isLocationEnabled = false;

  //final LocationUpdatesService locationService = LocationUpdatesService();
  @override
  initState() {
    super.initState();
   SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    checkLocationEnabled();
    print("Company Name: ${widget.companyName}");
    print("Company ID: ${widget.companyId}");
    compneyid = widget.companyId;
    print("Company ID: $compneyid");
    //  emailController.text = "Superadmin";
    // passwordController.text = "Abcd@123";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // First half of the screen - ImageView
          Container(
            height: MediaQuery.of(context).size.height / 1.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            child: Center(
              child: Image.asset(
                compneyid == 1 ? 'assets/login_screen_logo.png' : 'assets/srikar_seeds.png',
                width: MediaQuery.of(context).size.height / 3.2,
                height: MediaQuery.of(context).size.height / 3.2,
                // Other styling properties as needed
              ),
            ),
          ),

          Align(
            alignment: FractionalOffset.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 22.0, right: 22.0, bottom: 15.0),
              // Adjust the padding as needed
              child: Container(
                height: MediaQuery.of(context).size.height / 1.9,
                width: MediaQuery.of(context).size.width,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0, left: 12.0, right: 12.0),
                          child: Text('LogIn', style: CommonUtils.header_Styles18),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        'Hi, Welcome to ${widget.companyName} ',
                        style: CommonUtils.header_Styles16,
                      ),
                      SizedBox(height: 10.0),
                      Text('Enter your login credentials to continue', style: CommonUtils.Mediumtext_14),
                      Padding(
                        padding: EdgeInsets.only(top: 30.0, left: 30.0, right: 30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email/Username', // Add your desired text here
                                style: CommonUtils.Mediumtext_12),
                            SizedBox(height: 4.0),
                            GestureDetector(
                              onTap: () {
                                // Handle the click event for the second text view
                                print('first textview clicked');
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(
                                    color: Color(0xFFe78337),
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 10.0, right: 5.0),
                                      child: SvgPicture.asset(
                                        'assets/envelope.svg',
                                        width: 20.0,
                                        color: Color(0xFFe78337),
                                      ),
                                    ),
                                    Container(
                                      width: 2.0,
                                      height: 20.0,
                                      color: Color(0xFFe78337),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 10.0, top: 0.0),
                                          child: TextFormField(
                                            controller: emailController,
                                            keyboardType: TextInputType.emailAddress,
                                            maxLength: 30,
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Please enter your Email/Username';
                                              }
                                              return null;
                                            },
                                            style: CommonUtils.Mediumtext_o_14,
                                            decoration: InputDecoration(
                                              counterText: "",
                                              hintText: 'Enter Email or Username',
                                              hintStyle: CommonUtils.hintstyle_14,
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Padding(
                      //   padding: const EdgeInsets.all(0.0),
                      //   // Adjust the padding as needed
                      //   child: Text(
                      //     'LogIn',
                      //     style: TextStyle(
                      //       fontSize: 14.0,
                      //       color: Color(0xFFe78337),
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // ),
                      Padding(
                        padding: EdgeInsets.only(top: 15.0, left: 30.0, right: 30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Password', // Add your desired text here
                                style: CommonUtils.Mediumtext_12),
                            SizedBox(height: 4.0),
                            GestureDetector(
                              onTap: () {
                                // Handle the click event for the second text view
                                print('first textview clicked');
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(
                                    color: Color(0xFFe78337),
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 10.0, right: 5.0),
                                      child: SvgPicture.asset(
                                        'assets/lock.svg',
                                        width: 20.0,
                                        color: Color(0xFFe78337),
                                      ),
                                    ),
                                    Container(
                                      width: 2.0,
                                      height: 20.0,
                                      color: Color(0xFFe78337),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 10.0, top: 0.0),
                                          child: TextFormField(
                                            controller: passwordController,
                                            obscureText: _obscureText,
                                            maxLength: 20,
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Please enter your password';
                                              }
                                              return null;
                                            },
                                            style: CommonUtils.Mediumtext_o_14,
                                            decoration: InputDecoration(
                                              counterText: "",
                                              hintText: 'Enter Password',
                                              hintStyle: CommonUtils.hintstyle_14,
                                              border: InputBorder.none,
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscureText ? Icons.visibility_off : Icons.visibility,
                                                  color: Colors.black,
                                                ),
                                                onPressed: () {
                                                  // Toggle the password visibility
                                                  setState(() {
                                                    _obscureText = !_obscureText;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 15.0, left: 30.0, right: 30.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 45.0,
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {
                                    FocusManager.instance.primaryFocus?.unfocus();
                                    CommonUtils.checkInternetConnectivity().then(
                                      (isConnected) {
                                        if (isConnected) {
                                          _login();
                                          print('The Internet Is Connected');
                                        } else {
                                          CommonUtils.showCustomToastMessageLong('Please check your internet  connection', context, 1, 4);
                                          print('The Internet Is not  Connected');
                                        }
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 45.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6.0),
                                      color: Color(0xFFe78337),
                                    ),
                                    child:
                                        // isLoading // Show loading indicator if isLoading is true
                                        //     ? Center(
                                        //         child:
                                        //             CircularProgressIndicator())
                                        //     :
                                        Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'LogIn',
                                          style: CommonUtils.Buttonstyle,
                                        ),
                                        Image.asset(
                                          'assets/right_arrow.png',
                                          width: 20,
                                          height: 10,
                                          color: Colors.white,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0, bottom: 13.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Forgot Password?', style: CommonUtils.Mediumtext_14),
                                SizedBox(width: 8.0),
                                GestureDetector(
                                  onTap: () {
                                    // Handle the click event for the "Click here!" text
                                    print('Click here! clicked');
                                    // Add your custom logic or navigation code here
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ForgotPasswordScreen(companyId: widget.companyId, companyName: widget.companyName),
                                      ),
                                    );
                                  },
                                  child: Text('Click here!', style: CommonUtils.Mediumtext_o_14),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _login() async {
    setState(() {
      isLoading = true; // Set loading state to true
    });
    final apiUrl = baseUrl + post_Login;

    final payload = {"Username": emailController.text, "Password": passwordController.text, "CompanyId": compneyid, "IsWeb": false};

    print('object==${jsonEncode(payload)}');
    if (emailController.text.isEmpty) {
      CommonUtils.showCustomToastMessageLong('Please Enter Email/Username', context, 1, 4);
      return;
    }
    if (passwordController.text.isEmpty) {
      CommonUtils.showCustomToastMessageLong('Please Enter Password', context, 1, 4);
      return;
    }
    final response = await http.post(Uri.parse(apiUrl), headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print('LoginjsonResponse ==>$jsonResponse');
      if (jsonResponse['isSuccess'] == true) {
        print('Login successful');
        CommonUtils.showCustomToastMessageLong("Login Successful", context, 0, 3);

        // Save boolean value in SharedPreferences
        final Map<String, dynamic> responseData = json.decode(response.body);
        //await AuthService.saveSecondApiResponse(responseData);
        print('Savedresponse: ${responseData}');
        await SharedPreferencesHelper.saveCategories(responseData);

        await SharedPreferencesHelper.getCategories();
        SharedPreferencesHelper.putBool(Constants.IS_LOGIN, true);
        SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs.setString("userId", jsonResponse['response']['userId']);
        prefs.setString("slpCode", jsonResponse['response']['slpCode'] ?? '');
        prefs.setInt("companyId", jsonResponse['response']['companyId']);
        prefs.setString("companyName", jsonResponse['response']['companyName']);
        prefs.setString("companyCode", jsonResponse['response']['companyCode']);
        prefs.setString("email", jsonResponse['response']['email']);
        prefs.setString("userName", jsonResponse['response']['userName']);
        prefs.setString("roleName", jsonResponse['response']['roleName']);
        SharedPrefsData.updateStringValue("userId", jsonResponse['response']['userId']);
        SharedPrefsData.updateStringValue("slpCode", jsonResponse['response']['slpCode'] ?? '');
        SharedPrefsData.updateIntValue("companyId", jsonResponse['response']['companyId']);
        print("===========>companyId ${jsonResponse['response']['companyId']}");

        // startLocationService();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );

        // Start the foreground service after successful login
        // FlutterForegroundTask.initialize(isolateService: LocationUpdatesService(), androidServiceOptions: AndroidServiceOptions(channelId: "ForegroundChannel"));
      } else {
        print('Login failed. Please check your credentials.');
        CommonUtils.showCustomToastMessageLong(jsonResponse['endUserMessage'], context, 1, 4);
      }
    } else {
      print('Login failed. Please check your credentials.');
    }
    setState(() {
      isLoading = false; // Set loading state back to false after the response
    });
  }

  void _startService() {
    // Start your service here
    // For example:
    // Intent serviceIntent = Intent(context, YourServiceClass);
    // context.startService(serviceIntent);
  }

  static const platform = MethodChannel('com.calibrage.srikarbiotech.srikarbiotech');

  Future<void> checkLocationEnabled() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    setState(() {
      isLocationEnabled = serviceEnabled;
    });
    if (!serviceEnabled) {
      // Location service is not enabled, prompt the user to enable it
      showLocationAlertDialog();
    }
  }

  void showLocationAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Location Service Disabled"),
          content: Text("Please enable location services to use this feature."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                // Open location settings
                Geolocator.openLocationSettings();
              },
            ),
          ],
        );
      },
    );
  }
  //
  // void startLocationService() {
  //   locationService.startLocationService((success, result, msg) {
  //     if (success) {
  //       // Location service started successfully
  //       print(msg);
  //     } else {
  //       // Failed to start location service
  //       print(msg);
  //     }
  //   });
  // }



  
}
