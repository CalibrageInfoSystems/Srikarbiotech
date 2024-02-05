import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommonUtils {
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
                color: backgroundColorType == 0 ? Color(0xFF54B471) : Color(0xFFDE5242),
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
              // Add background color based on backgroundColorType
              color: backgroundColorType == 0 ? Color(0xFF54B471).withOpacity(0.2) : Color(0xFFDE5242).withOpacity(0.2),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Center(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                    fontFamily: 'Calibri',
                  ),
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
    return
      Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      color: backgroundColor,
      child: Container(
        width: double.infinity, // Make the width match the parent
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:CommonUtils.header_Styles16,
              maxLines: 2, // Display in 2 lines
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.0),
            Text(
              subtitle1,
              style: CommonUtils.Mediumtext_14,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.0),
            Text(
              subtitle2,
                style: CommonUtils.Mediumtext_14,
              maxLines: 2, // Display in 2 lines
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.0),
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: 'GST No. ',
                    style: CommonUtils.Mediumtext_12
                  ),
                  TextSpan(
                    text: subtitle3,
                    style: CommonUtils.Mediumtext_12_0
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.0),
            Text(
              'Address',
              style: CommonUtils.Mediumtext_12,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.0),
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
  static final searchBarOutPutInlineBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Colors.black38),
  );
  static final searchBarEnabledNdFocuedOutPutInlineBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Colors.black),
  );

  // header style
  static final TextStyle headerStyles = TextStyle(
    fontSize: 25,
    fontFamily: "Roboto",
    fontWeight: FontWeight.w700,
    color: Colors.black87,
  );
  // header style
  // header style
  static final TextStyle header_Styles18 = TextStyle(
    fontSize: 18,
    fontFamily: "Roboto",
    fontWeight: FontWeight.w700,
    color: Color(0xFFe78337),
  );

  static final TextStyle header_Styles16 = TextStyle(
    fontSize: 16,
    fontFamily: "Roboto",
    fontWeight: FontWeight.w700,
    color: Color(0xFFe78337),
  );
  static final TextStyle Mediumtext_o_14 = TextStyle(
    fontSize: 14,
    fontFamily: "Roboto",
    fontWeight: FontWeight.w600,
    color: Color(0xFFe78337),
  );

  static final TextStyle Mediumtext_14 = TextStyle(
    fontSize: 14,
    fontFamily: "Roboto",
    fontWeight: FontWeight.w600,
    color: Color(0xFF5f5f5f),
  );
  static final TextStyle Mediumtext_12 = TextStyle(
    fontSize: 12,
    fontFamily: "Roboto",
    fontWeight: FontWeight.w600,
    color: Color(0xFF5f5f5f),
  );
  static final TextStyle Mediumtext_12_0 = TextStyle(
    fontSize: 12,
    fontFamily: "Roboto",
    fontWeight: FontWeight.w600,
    color: Color(0xFFe78337),
  );

  static final TextStyle hintstyle_14 = TextStyle(
    fontSize: 14,
    fontFamily: "Roboto",
    fontWeight: FontWeight.w600,
    color: Color(0xFFC4C2C2),
  );
  static final TextStyle hintstyle_o_14 = TextStyle(

    fontSize: 14,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w700,
    color: Color(0xa0e78337),

  );
  static final TextStyle Buttonstyle = TextStyle(
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
}

Future<void> saveIntToPreferences(String key, int value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt(key, value);
}

Future<int?> getIntFromPreferences(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt(key);
}

