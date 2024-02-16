// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:srikarbiotech/Common/CommonUtils.dart';
import 'package:http/http.dart' as http;
import 'Common/SharedPrefsData.dart';
import 'Model/ForgotModel.dart';


class ChangePassword extends StatefulWidget {
  final int companyId;
  const ChangePassword({super.key, required this.companyId});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
String useremail = "";

  Future<void> changePassword() async {

    useremail  = await SharedPrefsData.getStringFromSharedPrefs("email");
    print('useremail: $useremail');
    String url =
        'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Account/ChangePassword';
    final requestHeaders = {'Content-Type': 'application/json'};
    final requestBody = {
      "Email": useremail,
      "CurrentPassword": currentPasswordController.text,
      "NewPassword": newPasswordController.text
    };

    if (currentPasswordController.text.isEmpty) {
      CommonUtils.showCustomToastMessageLong(
          'Please Enter Current Password', context, 1, 4);
      return;
    }
    if (newPasswordController.text.isEmpty) {
      CommonUtils.showCustomToastMessageLong(
          'Please Enter New Password', context, 1, 4);
      return;
    }
    if (confirmPasswordController.text.isEmpty) {
      CommonUtils.showCustomToastMessageLong(
          'Please Enter Confirm Password', context, 1, 4);
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      CommonUtils.showCustomToastMessageLong(
          'Confirm Password must be same as new password', context, 1, 4);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: requestHeaders,
        body: jsonEncode(requestBody),
      );
      debugPrint(response.toString());

      if (response.statusCode == 200) {
        ForgotModel forgotModel = forgotModelFromJson(response.body);
        if (forgotModel.isSuccess) {
          debugPrint('Valid email.');
          CommonUtils.showCustomToastMessageLong(
              forgotModel.endUserMessage, context, 0, 4);
          return;
        } else {
          debugPrint('Invalid email.');
          CommonUtils.showCustomToastMessageLong(
              forgotModel.endUserMessage, context, 1, 4);
          return;
        }
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
      body: Stack(
        children: [
          // First half of the screen - ImageView
          Container(
            height: MediaQuery.of(context).size.height / 1.8,
            decoration: const BoxDecoration(
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
                widget.companyId == 1
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
              const EdgeInsets.only(left: 22.0, right: 22.0, bottom: 15.0),
              // Adjust the padding as needed
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 1.9,
                width: MediaQuery.of(context).size.width,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 10.0, left: 12.0, right: 12.0),
                          child: Text('Change Password',
                              style: CommonUtils.header_Styles18),
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
                                            controller:
                                            currentPasswordController,
                                            obscureText: true,
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Please enter your current password';
                                              }
                                              return null;
                                            },
                                            style: CommonUtils.Mediumtext_o_14,
                                            decoration: const InputDecoration(
                                              hintText:
                                              'Enter Current Password',
                                              hintStyle:
                                              CommonUtils.hintstyle_14,
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
                                              hintStyle:
                                              CommonUtils.hintstyle_14,
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
                                            controller:
                                            confirmPasswordController,
                                            obscureText: true,
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Please enter your confirm password';
                                              }
                                              return null;
                                            },
                                            style: CommonUtils.Mediumtext_o_14,
                                            decoration: const InputDecoration(
                                              hintText:
                                              'Enter Confirm Password',
                                              hintStyle:
                                              CommonUtils.hintstyle_14,
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
                                  onTap: changePassword,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 45.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6.0),
                                      color: const Color(0xFFe78337),
                                    ),
                                    child: const Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Submit',
                                          style: CommonUtils.Buttonstyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.only(
                          //       top: 12.0,
                          //       left: 12.0,
                          //       right: 12.0,
                          //       bottom: 13.0),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.center,
                          //     children: [
                          //       Text('want to go back to',
                          //           style: CommonUtils.Mediumtext_14),
                          //       SizedBox(width: 8.0),
                          //       GestureDetector(
                          //         onTap: () {},
                          //         child: Text('Login?',
                          //             style: CommonUtils.Mediumtext_o_14),
                          //       )
                          //     ],
                          //   ),
                          // ),
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
}
