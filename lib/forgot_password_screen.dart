// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:srikarbiotech/Common/CommonUtils.dart';
import 'package:srikarbiotech/LoginScreen.dart';
import 'package:http/http.dart' as http;
import 'package:srikarbiotech/Services/api_config.dart';

import 'Model/ForgotModel.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final int companyId;
  final String companyName;
  const ForgotPasswordScreen({super.key, required this.companyId, required this.companyName});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController forgotEmailController = TextEditingController();
  bool _isLoading = false;

  void _submitForm() {
    final forgotEmail = forgotEmailController.text;

    setState(() {
      _isLoading = true;
    });

    forgotPassword(forgotEmail).then(
      (data) {
        setState(
          () {
            _isLoading = false;
            ForgotModel res = forgotModelFromJson(data);
            if (res.isSuccess) {
              CommonUtils.showCustomToastMessageLong(res.endUserMessage, context, 0, 2);
            } else {
              CommonUtils.showCustomToastMessageLong(res.endUserMessage, context, 1, 2);
            }
          },
        );
      },
    ).catchError((err) {
      setState(() {
        _isLoading = false;
        String errorMessage = err.toString();
        if (errorMessage.startsWith('Exception:')) {
          errorMessage = errorMessage.substring('Exception:'.length).trim();
        }
        CommonUtils.showCustomToastMessageLong(errorMessage, context, 0, 2);
      });
    });
  }

  Future<dynamic> forgotPassword(String forgotEmail) async {
    // String url = 'http://182.18.157.215/Srikar_Biotech_Dev/API/api/Account/ForgotPassword';
    String url = baseUrl + ForgotPassword;

    final requestHeaders = {'Content-Type': 'application/json'};
    final requestBody = {"UserNameorEmail": forgotEmail, "CompanyId": widget.companyId};
    if (forgotEmail.isEmpty) {
      throw Exception('Please Enter Email/Username');
    }
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: requestHeaders,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        forgotEmailController.text = "";
        return response.body;
      } else {
        throw Exception('API call failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred during forgot password request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 1.6,
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
            child: Padding(
              padding: const EdgeInsets.only(bottom: 35.0),
              child: Center(
                child: Image.asset(
                  widget.companyId == 1 ? 'assets/login_screen_logo.png' : 'assets/srikar_seeds.png',
                  width: MediaQuery.of(context).size.height / 3.2,
                  height: MediaQuery.of(context).size.height / 3.2,
                  // Other styling properties as needed
                ),
              ),
            ),
          ),
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 22.0, right: 22.0, bottom: 15.0),
              // Adjust the padding as needed
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 2.1,
                width: MediaQuery.of(context).size.width,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.only(top: 10.0, left: 12.0, right: 12.0),
                          child: Text('Forgot Password', style: CommonUtils.header_Styles18),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      const SizedBox(height: 5.0),
                      const Text('Enter your Email address or User Name', style: CommonUtils.Mediumtext_14),
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0, left: 30.0, right: 30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Email/Username', style: CommonUtils.Mediumtext_12),
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
                                      padding: const EdgeInsets.only(left: 10.0, right: 5.0),
                                      child: SvgPicture.asset(
                                        'assets/envelope.svg',
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
                                          padding: const EdgeInsets.only(left: 10.0, top: 0.0),
                                          child: TextFormField(
                                            controller: forgotEmailController,
                                            maxLength: 30,
                                            keyboardType: TextInputType.emailAddress,
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Please enter your Email/Username';
                                              }
                                              return null;
                                            },
                                            style: CommonUtils.Mediumtext_o_14,
                                            decoration: const InputDecoration(
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
                      const SizedBox(height: 5.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0, left: 30.0, right: 30.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 45.0,
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {
                                    _submitForm();
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 45.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6.0),
                                      color: const Color(0xFFe78337),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
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
                                                child: CircularProgressIndicator.adaptive(),
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
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0, left: 12.0, right: 12.0, bottom: 13.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'You want to go back to ',
                                      style: CommonUtils.Mediumtext_14,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pop(
                                          MaterialPageRoute(
                                            builder: (context) => LoginScreen(companyName: "companyName", companyId: widget.companyId),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'SignIn?',
                                        style: CommonUtils.Mediumtext_o_14,
                                      ),
                                    ),
                                  ],
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
}
