import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikarbiotech/Common/styles.dart';
import 'Common/CommonUtils.dart';
import 'Common/Constants.dart';
import 'Common/SharedPreferencesHelper.dart';
import 'Common/SharedPrefsData.dart';
import 'HomeScreen.dart';
import 'Services/api_config.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final String companyName;
  final int companyId;

  const LoginScreen({
    super.key,
    required this.companyName,
    required this.companyId,
  });
  @override
  State<LoginScreen> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  int compneyid = 0;
  String? userId;
  String? slpCode;
  bool isLoading = false;
  bool _obscureText = true;

  @override
  initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    compneyid = widget.companyId;
    // emailController.text = "Superadmin";
    // passwordController.text = "Abcd@123";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
                compneyid == 1
                    ? 'assets/login_screen_logo.png'
                    : 'assets/srikar_seeds.png',
                width: MediaQuery.of(context).size.height / 3.2,
                height: MediaQuery.of(context).size.height / 3.2,
              ),
            ),
          ),
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 22.0, right: 22.0, bottom: 15.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 1.9,
                width: MediaQuery.of(context).size.width,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: 10.0, left: 12.0, right: 12.0),
                              child: Text('Login',
                                  style: CommonStyles.txSty_18o_f7),
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Text('Hi, Welcome to ${widget.companyName} ',
                              style: CommonStyles.txSty_14o_f7),
                          const SizedBox(height: 10.0),
                          const Text(
                            'Enter your login credentials to continue',
                            style: CommonStyles.txSty_14bs_fb,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 30.0, left: 30.0, right: 30.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Email/Username',
                                  style: CommonStyles.txSty_12b_fb,
                                ),
                                const SizedBox(height: 4.0),
                                GestureDetector(
                                  onTap: () {
                                    print('first textview clicked');
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border.all(
                                        color: CommonStyles.orangeColor,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10.0, right: 5.0),
                                          child: SvgPicture.asset(
                                            'assets/envelope.svg',
                                            width: 20.0,
                                            color: CommonStyles.orangeColor,
                                          ),
                                        ),
                                        Container(
                                          width: 2.0,
                                          height: 20.0,
                                          color: CommonStyles.orangeColor,
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0, top: 0.0),
                                              child: TextFormField(
                                                controller: emailController,
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                maxLength: 30,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Please enter your Email/Username';
                                                  }
                                                  return null;
                                                },
                                                style:
                                                    CommonStyles.txSty_12o_f7,
                                                decoration:
                                                    const InputDecoration(
                                                  counterText: "",
                                                  hintText:
                                                      'Enter Email or Username',
                                                  hintStyle:
                                                      CommonStyles.txSty_12o_f7,
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
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 15.0, left: 30.0, right: 30.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Password',
                                  style: CommonStyles.txSty_12b_fb,
                                ),
                                const SizedBox(height: 4.0),
                                GestureDetector(
                                  onTap: () {
                                    print('first textview clicked');
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border.all(
                                        color: CommonStyles.orangeColor,
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
                                            color: CommonStyles.orangeColor,
                                          ),
                                        ),
                                        Container(
                                          width: 2.0,
                                          height: 20.0,
                                          color: CommonStyles.orangeColor,
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0, top: 0.0),
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
                                                style:
                                                    CommonStyles.txSty_12o_f7,
                                                decoration: InputDecoration(
                                                  counterText: "",
                                                  hintText: 'Enter Password',
                                                  hintStyle:
                                                      CommonStyles.txSty_12o_f7,
                                                  border: InputBorder.none,
                                                  suffixIcon: IconButton(
                                                    icon: Icon(
                                                      _obscureText
                                                          ? Icons.visibility_off
                                                          : Icons.visibility,
                                                      color: Colors.black,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _obscureText =
                                                            !_obscureText;
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
                        ],
                      ),
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
                                  onTap: () {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    CommonUtils.checkInternetConnectivity()
                                        .then(
                                      (isConnected) {
                                        if (isConnected) {
                                          _login();
                                          print('The Internet Is Connected');
                                        } else {
                                          CommonUtils.showCustomToastMessageLong(
                                              'Please check your internet  connection',
                                              context,
                                              1,
                                              4);
                                          print(
                                              'The Internet Is not  Connected');
                                        }
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 45.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6.0),
                                      color: CommonStyles.orangeColor,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'LogIn',
                                          style: CommonStyles.txSty_14w_fb,
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
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text(
                                  'Forgot Password? ',
                                  style: CommonStyles.txSty_12b_fb,
                                ),
                                // const SizedBox(width: 8.0),
                                GestureDetector(
                                  onTap: () {
                                    print('Click here! clicked');

                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ForgotPasswordScreen(
                                                companyId: widget.companyId,
                                                companyName:
                                                    widget.companyName),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Click here',
                                    style: CommonStyles.txSty_12o_f7,
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
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
      isLoading = true;
    });
    final apiUrl = baseUrl + post_Login;

    final payload = {
      "Username": emailController.text,
      "Password": passwordController.text,
      "CompanyId": compneyid,
      "IsWeb": false
    };

    print('object==${jsonEncode(payload)}');
    if (emailController.text.isEmpty) {
      CommonUtils.showCustomToastMessageLong(
          'Please Enter Email/Username', context, 1, 4);
      return;
    }
    if (passwordController.text.isEmpty) {
      CommonUtils.showCustomToastMessageLong(
          'Please Enter Password', context, 1, 4);
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
        CommonUtils.showCustomToastMessageLong(
            "Login Successful", context, 0, 3);

        final Map<String, dynamic> responseData = json.decode(response.body);

        print('Savedresponse: $responseData');
        await SharedPreferencesHelper.saveCategories(responseData);

        await SharedPreferencesHelper.getCategories();
        SharedPreferencesHelper.putBool(Constants.IS_LOGIN, true);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        SharedPrefsData.updateStringValue("userId", jsonResponse['response']['userId']);
        SharedPrefsData.updateStringValue("slpCode", jsonResponse['response']['slpCode'] ?? '');
        SharedPrefsData.updateIntValue("companyId", jsonResponse['response']['companyId']);

        prefs.setString("userId", jsonResponse['response']['userId']);
        prefs.setString("slpCode", jsonResponse['response']['slpCode'] ?? '');
        prefs.setInt("companyId", jsonResponse['response']['companyId']);
        prefs.setString("companyName", jsonResponse['response']['companyName']);
        prefs.setString("companyCode", jsonResponse['response']['companyCode']);
        prefs.setString("email", jsonResponse['response']['email']);
        prefs.setString("userName", jsonResponse['response']['userName']);
        prefs.setString("roleName", jsonResponse['response']['roleName']);

        print("===========>companyId ${jsonResponse['response']['companyId']}");

        // startLocationService();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        CommonUtils.showCustomToastMessageLong(
            jsonResponse['endUserMessage'], context, 1, 4);
      }
    } else {
      print('Login failed. Please check your credentials.');
    }
    setState(() {
      isLoading = false;
    });
  }

  void _startService() {}

  static const platform =
      MethodChannel('com.calibrage.srikarbiotech.srikarbiotech');
}
