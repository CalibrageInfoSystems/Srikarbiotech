import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      elevation: 7.0,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      child: Container(
        width: double.infinity, // Make the width match the parent
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
              style: CommonUtils.header_Styles16,
              maxLines: 2, // Display in 2 lines
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8.0),
            Text(
              subtitle1,
              style: CommonUtils.Mediumtext_14,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8.0),
            Text(
              subtitle2,
              style: CommonUtils.Mediumtext_o_14,
              maxLines: 2, // Display in 2 lines
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8.0),
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  const TextSpan(
                      text: 'GST No. ', style: CommonUtils.Mediumtext_12),
                  TextSpan(text: subtitle3, style: CommonUtils.Mediumtext_12_0),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Address',
              style: CommonUtils.Mediumtext_12,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2.0),
            Text(
              subtitle4,
              style: CommonUtils.Mediumtext_12_0,
              maxLines: 2, // Display in 2 lines
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

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
    color:Colors.black,
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
    fontSize: 13,
    color: Colors.black,
  );
  static final txSty_13O_F6 = TextStyle(
      fontFamily: 'Roboto',
      fontSize: 13,
      color: orangeColor,
      fontWeight: FontWeight.w600);
}

Future<void> saveIntToPreferences(String key, int value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt(key, value);
}

Future<int?> getIntFromPreferences(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt(key);
}
