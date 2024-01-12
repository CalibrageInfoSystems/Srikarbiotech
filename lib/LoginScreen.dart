import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'Common/CommonUtils.dart';
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
                    : 'assets/sreekar_seeds.png',
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
                              top: 6.0, left: 12.0, right: 12.0),
                          child: Text(
                            'LogIn',
                            style: TextStyle(
                              fontSize: 24.0,
                              color: Color(0xFFe78337),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Hi, Welcome to Srikar Bio Tech',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Color(0xFFe78337),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Enter your credentials to continue',
                        style: TextStyle(
                          fontSize: 15.0,
                          color: Color(0xFF5f5f5f),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: 14.0, left: 30.0, right: 30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email/Username', // Add your desired text here
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Color(0xFF5f5f5f),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            //  SizedBox(height: 8.0),
                            GestureDetector(
                              onTap: () {
                                // Handle the click event for the second text view
                                print('first textview clicked');
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 55.0,
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
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w300,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: 'Enter Email or Username',
                                              hintStyle: TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'Roboto-Bold',
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFFC4C2C2),
                                              ),
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
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Color(0xFF5f5f5f),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            //  SizedBox(height: 8.0),
                            GestureDetector(
                              onTap: () {
                                // Handle the click event for the second text view
                                print('first textview clicked');
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 55.0,
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
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w300,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: 'Enter Password',
                                              hintStyle: TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'Roboto-Bold',
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFFC4C2C2),
                                              ),
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
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //       builder: (context) => HomeScreen()),
                                    // );
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 55.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6.0),
                                      color: Color(0xFFe78337),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'LogIn',
                                          style: TextStyle(
                                            fontFamily: 'Calibri',
                                            fontSize: 14,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
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
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Color(0xFFe78337),
                                      fontWeight: FontWeight.bold,
                                    ),
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
    final apiUrl = baseUrl+post_Login;
  //  final apiUrl = 'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Account/Login';
    final payload = {
      "Username": "Superadmin",
      "Password": "Abcd@123",
      "CompanyId": 2
    };
    // final payload = {
    //   "Username": emailController.text,
    //   "Password": passwordController.text,
    //   "CompanyId": compneyid
    // };

    // if (emailController.text.isEmpty || passwordController.text.isEmpty) {
    //   CommonUtils.showCustomToastMessageLong('Please fill in all fields', context, 1, 4);
    //   return;
    // }

    final response = await http.post(Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse['isSuccess'] == true) {
        print('Login successful');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        // Navigate to the next activity based on your logic
        // if (jsonResponse['response']['roleName'] == 'SuperAdmin') {
        //   Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(builder: (context) => SuperAdminScreen()),
        //   );
        // } else {
        //   // Add additional conditions for other roles or activities
        //   // Navigator.pushReplacement(
        //   //   context,
        //   //   MaterialPageRoute(builder: (context) => OtherScreen()),
        //   // );
        // }
      } else {
        print('Login failed. Please check your credentials.');
        CommonUtils.showCustomToastMessageLong('Login failed. Please check your credentials.', context, 1, 4);
      }
    } else {
      print('Login failed. Please check your credentials.');
    }
  }

}
