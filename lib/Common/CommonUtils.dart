import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:srikarbiotech/Common/styles.dart';

class CommonUtils {
  static final orangeColor = HexColor('#e58338');

  static void showCustomToastMessageLong(
    String message,
    BuildContext context,
    int backgroundColorType,
    int length,
  ) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double textWidth = screenWidth / 1.5; // Adjust multiplier as needed

    final double toastWidth = textWidth + 32.0; // Adjust padding as needed
    final double toastOffset = (screenWidth - toastWidth) / 2;

    OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        bottom: 16.0,
        left: toastOffset,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            width: toastWidth,
            decoration: BoxDecoration(
              border: Border.all(
                color: backgroundColorType == 0 ? Colors.green : Colors.red,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Center(
                child: Text(
                  message,
                  style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                      fontFamily: 'Calibri'),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    Future.delayed(Duration(seconds: length)).then((value) {
      overlayEntry.remove();
    });
  }

  static String extractExceptionMessage(String errorMsg) {
    return errorMsg.replaceAll('Exception: ', '');
  }

  static Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true; // Connected to the internet
    } else {
      return false; // Not connected to the internet
    }
  }

  static final dividerForHorizontal = Container(
    width: double.infinity,
    height: 0.2,
    color: Colors.grey,
  );
  static final dividerForVertical = Container(
    width: 0.2,
    height: 60,
    color: Colors.grey,
  );

  static final decorationO_R10W1 = BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: const Color(0xFFe58338),
      ));
  static void myCommonMethod() {
    // Your common method logic here
    print('This is a common method');
  }

  static Widget buildCard(
    String title,
    String subtitle1,
    String subtitle2,
    String subtitle3,
    String subtitle4,
    Color backgroundColor,
    BorderRadius borderRadius,
  ) {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: backgroundColor,
        ),
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: CommonStyles.txSty_14o_f7,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8.0),
            Text(
              subtitle1,
              style: CommonStyles.txSty_14b_fb,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8.0),
            Text(
              subtitle2,
              style: CommonStyles.txSty_14o_f7,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8.0),
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  const TextSpan(
                      text: 'GST No. ', style: CommonStyles.txSty_12b_fb),
                  TextSpan(text: subtitle3, style: CommonStyles.txSty_12o_f7),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Address',
              style: CommonStyles.txSty_12b_fb,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2.0),
            Text(
              subtitle4,
              style: CommonStyles.txSty_12o_f7,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  static final borderForSearch = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Color.fromARGB(96, 141, 140, 140)),
  );

  static final focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Colors.black),
  );

  static final boxBorder = BoxDecoration(
    borderRadius: BorderRadius.circular(5.0),
    color: Colors.white,
  );

  static final borderForAppliedFilter = BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    color: const Color.fromARGB(255, 250, 214, 152),
    border: Border.all(
      color: HexColor('#e58338'),
    ),
  );

  static final borderForFilter = BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    border: Border.all(
      color: HexColor('#e58338'),
    ),
  );
  static final searchBarOutPutInlineBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Colors.black38),
  );
  static final searchBarEnabledNdFocuedOutPutInlineBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Colors.black),
  );
  static const TextStyle hintstyle_o_14 = TextStyle(
    fontSize: 14,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w700,
    color: Color(0xa0e78337),
  );

  // header style
  static const TextStyle headerStyles = TextStyle(
    fontSize: 25,
    fontFamily: "Roboto",
    fontWeight: FontWeight.w700,
    color: Colors.black87,
  );
  // header style
  static const TextStyle header_Styles18 = TextStyle(
    fontSize: 18,
    fontFamily: "Roboto",
    fontWeight: FontWeight.w700,
    color: Color(0xFFe78337),
  );
  static const TextStyle header_Styles20 = TextStyle(
    fontSize: 20,
    fontFamily: "Roboto",
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );
  static const TextStyle header_Styles16 = TextStyle(
    fontSize: 16,
    fontFamily: "Roboto",
    fontWeight: FontWeight.w700,
    color: Color(0xFFe78337),
  );
  static const TextStyle Mediumtext_o_14 = TextStyle(
    fontSize: 14,
    fontFamily: "Roboto",
    fontWeight: FontWeight.w600,
    color: Color(0xFFe78337),
  );
  static const TextStyle Mediumtext_14 = TextStyle(
    fontSize: 14,
    fontFamily: "Roboto",
    fontWeight: FontWeight.w600,
    color: Color(0xFF5f5f5f),
  );
  static const TextStyle Mediumtext_12 = TextStyle(
    fontSize: 12,
    fontFamily: "Roboto",
    fontWeight: FontWeight.w600,
    color: Color(0xFF5f5f5f),
  );
  static const TextStyle Mediumtext_12_0 = TextStyle(
    fontSize: 12,
    fontFamily: "Roboto",
    fontWeight: FontWeight.w600,
    color: Color(0xFFe78337),
  );

  static const TextStyle hintstyle_14 = TextStyle(
    fontSize: 14,
    fontFamily: "Roboto",
    fontWeight: FontWeight.w600,
    color: Color(0xFFC4C2C2),
  );

  static const TextStyle Buttonstyle = TextStyle(
    fontSize: 14,
    fontFamily: "Roboto",
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  static const TextStyle Mediumtext_14_cb = TextStyle(
    fontSize: 14,
    fontFamily: "Roboto",
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  static const txSty_14B_Fb = TextStyle(
      fontFamily: 'Roboto',
      fontSize: 14,
      color: Colors.black,
      fontWeight: FontWeight.bold);

  static const txSty_13B_Fb = TextStyle(
      fontFamily: 'Roboto',
      fontSize: 13,
      color: Colors.black,
      fontWeight: FontWeight.bold);

  static const txSty_13B = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    color: Colors.black,
  );
  static final txSty_13O_F6 = TextStyle(
      fontFamily: 'Roboto',
      fontSize: 14,
      color: orangeColor,
      fontWeight: FontWeight.w600);

  static Widget showProgressIndicator() {
    return const CircularProgressIndicator.adaptive(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
    );
  }

  static Widget shimmerEffectForCatogaries() {
    return Shimmer.fromColors(
        baseColor: Colors.grey.withOpacity(0.5),
        highlightColor: Colors.grey.withOpacity(0.2),
        child: Row(
          children: [
            _buildShimmerBox(50, 30, radius: 5),
            const SizedBox(
              width: 7,
            ),
            _buildShimmerBox(50, 30, radius: 5),
            const SizedBox(
              width: 7,
            ),
            _buildShimmerBox(50, 30, radius: 5),
            const SizedBox(
              width: 7,
            ),
            _buildShimmerBox(50, 30, radius: 5),
            const SizedBox(
              width: 7,
            ),
            _buildShimmerBox(50, 30, radius: 5),
            const SizedBox(
              width: 7,
            ),
            _buildShimmerBox(50, 30, radius: 5),
            const SizedBox(
              width: 7,
            ),
            _buildShimmerBox(50, 30, radius: 5),
            const SizedBox(
              width: 7,
            ),
            _buildShimmerBox(50, 30, radius: 5),
            const SizedBox(
              width: 7,
            ),
            _buildShimmerBox(50, 30, radius: 5),
          ],
        ));
  }

  static Widget _buildShimmerBox(double width, double height,
      {double? radius}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 0),
        color: Colors.grey,
      ),
      width: width,
      height: height,
    );
  }

  static Widget shimmerEffect(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(12),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.withOpacity(0.5),
          highlightColor: Colors.grey.withOpacity(0.2),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: ListView.separated(
                  itemCount: 22,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                color: Colors.grey,
                                // width:
                                //     MediaQuery.of(context).size.width / 1.2,
                                height: 20,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Container(
                                color: Colors.grey,
                                width: MediaQuery.of(context).size.width / 2,
                                height: 20,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Container(
                                    color: Colors.grey,
                                    width:
                                        MediaQuery.of(context).size.width / 2.6,
                                    height: 20,
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Container(
                                    color: Colors.grey,
                                    width:
                                        MediaQuery.of(context).size.width / 4,
                                    height: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          color: Colors.grey,
                          width: 70,
                          height: 70,
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      height: 33,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> saveIntToPreferences(String key, int value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt(key, value);
}

Future<int?> getIntFromPreferences(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt(key);
}
