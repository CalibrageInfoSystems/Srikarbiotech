import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:srikarbiotech/Common/CommonUtils.dart';
import 'package:http/http.dart' as http;
import 'package:srikarbiotech/Common/SharedPrefsData.dart';
import 'package:srikarbiotech/HomeScreen.dart';

import 'Model/ForgotModel.dart';


class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  int companyId = 0;
  String? userId = "";

  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getshareddata();
  }

  Future<void> _submitForm() async {
    setState(() {
      _isLoading = true;
    });

    changePasswordApi().then((data) {
      setState(() {
        _isLoading = false;
      });

      ForgotModel res = forgotModelFromJson(data);
      if (res.isSuccess) {
        CommonUtils.showCustomToastMessageLong(
            res.endUserMessage, context, 0, 2);
      } else {
        CommonUtils.showCustomToastMessageLong(
            res.endUserMessage, context, 1, 2);
      }
    }).catchError((err) {
      setState(() {
        _isLoading = false;
      });
      String errMessage = err.toString();
      if (errMessage.startsWith('Exception:')) {
        errMessage = errMessage.substring('Exception:'.length).trim();
      }
      CommonUtils.showCustomToastMessageLong(errMessage, context, 1, 2);
    });
  }

  Future<dynamic> changePasswordApi() async {
    String email = await SharedPrefsData.getStringFromSharedPrefs("email");
    String url =
        'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Account/ChangePassword';
    final requestHeaders = {'Content-Type': 'application/json'};
    final requestBody = {
      "Email": email,
      "CurrentPassword": currentPasswordController.text,
      "NewPassword": newPasswordController.text
    };
print('===>${jsonEncode(requestBody)}');
    if (currentPasswordController.text.isEmpty) {
      throw Exception('Please Enter Current Password');
    }
    if (newPasswordController.text.isEmpty) {
      throw Exception('Please Enter New Password');
    }
    if (confirmPasswordController.text.isEmpty) {
      throw Exception('Please Enter Confirm Password');
    }
    if (newPasswordController.text != confirmPasswordController.text) {
      throw Exception('Confirm Password must be same as new password');
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: requestHeaders,
        body: jsonEncode(requestBody),
      );
      // debugPrint(response.toString());

      if (response.statusCode == 200) {
        currentPasswordController.text ="";
        newPasswordController.text ="";
        confirmPasswordController.text ="";

        return response.body;


      } else {
        throw Exception(
            'API call failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error Occurred!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 22.0, right: 22.0, bottom: 15.0),
          // Adjust the padding as needed
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 1.9,
            width: MediaQuery.of(context).size.width,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding:
                        EdgeInsets.only(top: 10.0, left: 12.0, right: 12.0),
                        child: Column(
                          children: [
                            Text('Change Password',
                                style: CommonUtils.header_Styles18),
                            SizedBox(height: 5.0),
                            Text(
                                'Please enter below details to change your password',
                                style: CommonUtils.Mediumtext_12),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),

                    // current password
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 15.0, left: 30.0, right: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Current Password',
                              style: CommonUtils.Mediumtext_12),
                          const SizedBox(height: 4.0),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 50.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(
                                  color: const Color(0xFFe78337),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 5.0),
                                    child: SvgPicture.asset(
                                      'assets/lock.svg',
                                      width: 20.0,
                                      color: const Color(0xFFe78337),
                                    ),
                                  ),
                                  Container(
                                    width: 2.0,
                                    height: 20.0,
                                    color: const Color(0xFFe78337),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, top: 0.0),
                                        child: TextFormField(
                                          controller: currentPasswordController,
                                          obscureText: true,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please enter your current password';
                                            }
                                            return null;
                                          },
                                          style: CommonUtils.Mediumtext_o_14,
                                          decoration: const InputDecoration(
                                            hintText: 'Enter Current Password',
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

                    // new password
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 15.0, left: 30.0, right: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                              'New Password', // Add your desired text here
                              style: CommonUtils.Mediumtext_12),
                          const SizedBox(height: 4.0),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 50.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(
                                  color: const Color(0xFFe78337),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 5.0),
                                    child: SvgPicture.asset(
                                      'assets/lock.svg',
                                      width: 20.0,
                                      color: const Color(0xFFe78337),
                                    ),
                                  ),
                                  Container(
                                    width: 2.0,
                                    height: 20.0,
                                    color: const Color(0xFFe78337),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, top: 0.0),
                                        child: TextFormField(
                                          controller: newPasswordController,
                                          obscureText: true,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please enter your new password';
                                            }
                                            return null;
                                          },
                                          style: CommonUtils.Mediumtext_o_14,
                                          decoration: const InputDecoration(
                                            hintText: 'Enter New Password',
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

                    // confirm password
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 15.0, left: 30.0, right: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                              'Confirm Password', // Add your desired text here
                              style: CommonUtils.Mediumtext_12),
                          const SizedBox(height: 4.0),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 50.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(
                                  color: const Color(0xFFe78337),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 5.0),
                                    child: SvgPicture.asset(
                                      'assets/lock.svg',
                                      width: 20.0,
                                      color: const Color(0xFFe78337),
                                    ),
                                  ),
                                  Container(
                                    width: 2.0,
                                    height: 20.0,
                                    color: const Color(0xFFe78337),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, top: 0.0),
                                        child: TextFormField(
                                          controller: confirmPasswordController,
                                          obscureText: true,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please enter your confirm password';
                                            }
                                            return null;
                                          },
                                          style: CommonUtils.Mediumtext_o_14,
                                          decoration: const InputDecoration(
                                            hintText: 'Enter Confirm Password',
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

                    const SizedBox(height: 5.0),

                    // submit button
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 15.0, left: 30.0, right: 30.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 45.0,
                            child: Center(
                              child: GestureDetector(
                                onTap: _submitForm,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 45.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6.0),
                                    color: const Color(0xFFe78337),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          const Text(
                                            'Submit',
                                            style: CommonUtils.Buttonstyle,
                                          ),
                                          if (_isLoading)
                                            const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: CircularProgressIndicator
                                                  .adaptive(),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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
      ),
    );
  }

  Future<void> getshareddata() async {
    companyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");
    userId = await SharedPrefsData.getStringFromSharedPrefs("userId");

    debugPrint('Company ID: $companyId');
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: const Color(0xFFe78337),
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                child: GestureDetector(
                  onTap: () {
                    // call clear filter method to clear the data
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
                'Change Password',
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
                    // Handle the click event for the home icon
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
}
