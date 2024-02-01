import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'Common/CommonUtils.dart';
import 'Common/Constants.dart';
import 'Common/SharedPreferencesHelper.dart';
import 'Common/SharedPrefsData.dart';
import 'HomeScreen.dart';
import 'Model/CompanyModel.dart';
import 'Services/api_config.dart';

class LoginScreen extends StatefulWidget {
  // Assuming you have a class named Company
  final String companyName;
  final int companyId;
  LoginScreen({required this.companyName,
    required this.companyId,});
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
  @override
  initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    print("Company Name: ${widget.companyName}");
    print("Company ID: ${widget.companyId}");
    compneyid = widget.companyId;
    print("Company ID: $compneyid");
    emailController.text = "Superadmin";
    passwordController.text = "Abcd@123";
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
                compneyid == 1
                    ? 'assets/login_screen_logo.png'
                    : 'assets/srikar_seeds.png',
                width: MediaQuery.of(context).size.height / 3.2,
                height: MediaQuery.of(context).size.height / 3.2,
                // Other styling properties as needed
              ),
            ),

          ),
        
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 22.0, right: 22.0, bottom: 20.0),
              // Adjust the padding as needed
              child: Container(
                height: MediaQuery.of(context).size.height / 2,
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
                          padding: const EdgeInsets.only(
                              top: 10.0, left: 12.0, right: 12.0),
                          child: Text(
                            'LogIn',
                            style: CommonUtils.header_Styles18
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        compneyid == 1
                            ? 'Hi, Welcome to Srikar Bio Tech'
                            : 'Hi, Welcome to Srikar Seeds ',
                        style: CommonUtils.header_Styles16,
                      ),                SizedBox(height: 10.0),
                      Text(
                        'Enter your credentials to continue',
    style: CommonUtils.Mediumtext_14

                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: 30.0, left: 30.0, right: 30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email/Username', // Add your desired text here
                              style: CommonUtils.Mediumtext_12
                            ),
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
                                      padding: EdgeInsets.only(
                                          left: 10.0, right: 5.0),
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
                                          padding: EdgeInsets.only(
                                              left: 10.0, top: 0.0),
                                          child: TextFormField(
                                            controller: emailController,
                                            keyboardType: TextInputType.emailAddress,
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Please enter your Email/Username';
                                              }
                                              return null;
                                            },
                                            style: CommonUtils.Mediumtext_o_14,
                                            decoration: InputDecoration(
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
                        padding:
                            EdgeInsets.only(top: 15.0, left: 30.0, right: 30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password', // Add your desired text here
                             style: CommonUtils.Mediumtext_12
                            ),
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
                                      padding: EdgeInsets.only(
                                          left: 10.0, right: 5.0),
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
                                          padding: EdgeInsets.only(
                                              left: 10.0, top: 0.0),
                                          child: TextFormField(
                                            controller: passwordController,
                                            obscureText: true,
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Please enter your password';
                                              }
                                              return null;
                                            },
                                            style: CommonUtils.Mediumtext_o_14,
                                            decoration: InputDecoration(
                                              hintText: 'Enter Password',
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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                top: 8.0, left: 30.0, right: 30.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 55.0,
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {
                                    _login();
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 55.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6.0),
                                      color: Color(0xFFe78337),
                                    ),
                                    child: isLoading // Show loading indicator if isLoading is true
                                        ? Center(child: CircularProgressIndicator())
                                        : Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
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
                            padding: const EdgeInsets.only(
                                top: 12.0,
                                left: 12.0,
                                right: 12.0,
                                bottom: 13.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Forgot Password?',
                                  style: CommonUtils.Mediumtext_14
                                ),
                                SizedBox(width: 8.0),
                                GestureDetector(
                                  onTap: () {
                                    // Handle the click event for the "Click here!" text
                                    print('Click here! clicked');
                                    // Add your custom logic or navigation code here
                                  },
                                  child: Text(
                                    'Click here!',
                                    style:CommonUtils.Mediumtext_o_14
                                  ),
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
    final apiUrl = baseUrl+post_Login;

    final payload = {
      "Username": emailController.text,
      "Password": passwordController.text,
      "CompanyId": compneyid
    };

    if (emailController.text.isEmpty) {
      CommonUtils.showCustomToastMessageLong('Please Enter Username', context, 1, 4);
      return;
    }
    if (passwordController.text.isEmpty) {
      CommonUtils.showCustomToastMessageLong('Please Enter Password', context, 1, 4);
      return;
    }
    final response = await http.post(Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print('LoginjsonResponse ==>$jsonResponse');
      if (jsonResponse['isSuccess'] == true) {
        print('Login successful');
        // Save boolean value in SharedPreferences
        final Map<String, dynamic> responseData = json.decode(response.body);
        //await AuthService.saveSecondApiResponse(responseData);
        print('Savedresponse: ${responseData}');
        await SharedPreferencesHelper.saveCategories(responseData);

        SharedPreferencesHelper.putBool(Constants.IS_LOGIN, true);
        SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs.setString("userId", jsonResponse['response']['userId']);
        prefs.setString("slpCode", jsonResponse['response']['slpCode']);
        prefs.setInt("companyId", jsonResponse['response']['companyId']);

        SharedPrefsData.updateStringValue("userId",  jsonResponse['response']['userId']);
        SharedPrefsData.updateStringValue("slpCode",  jsonResponse['response']['slpCode']);
        SharedPrefsData.updateIntValue("companyId",  jsonResponse['response']['companyId']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );

      } else {
        print('Login failed. Please check your credentials.');
        CommonUtils.showCustomToastMessageLong('Login failed. Please check your credentials.', context, 1, 4);
      }
    } else {
      print('Login failed. Please check your credentials.');
    }
    setState(() {
      isLoading = false; // Set loading state back to false after the response
    });
  }

}
