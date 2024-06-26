// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

class CommonStyles {
  static const blackColor = Colors.black;
  static const blackColorShade = Color(0xFF5f5f5f);
  static const whiteColor = Colors.white;
  static const redColor = Colors.red;
  static const progressIndicator = CircularProgressIndicator.adaptive(
    backgroundColor: Colors.transparent,
    valueColor: AlwaysStoppedAnimation<Color>(orangeColor),
  );
  static const orangeColor = Color(0xFFe78337);
  static const greenColor = Color(0xFF11872f);
  static final greyShade = Colors.grey.shade100;

  static const txSty_10b_fb = TextStyle(
    fontSize: 10.0,
    fontWeight: FontWeight.bold,
    fontFamily: "Roboto",
    color: blackColor,
  );

  static const txSty_11b_fb = TextStyle(
    fontSize: 11,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w700,
    color: blackColor,
  );
  static const txSty_11w_fb = TextStyle(
    fontSize: 11,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w700,
    color: whiteColor,
  );

  static const txSty_12b_fb = TextStyle(
    fontSize: 12.0,
    color: blackColor,
    fontWeight: FontWeight.bold,
    fontFamily: "Roboto",
  );

  static const txSty_12bs_fb = TextStyle(
    fontSize: 12.0,
    color: blackColorShade,
    fontWeight: FontWeight.bold,
    fontFamily: "Roboto",
  );

  static const txSty_12o_f7 = TextStyle(
    fontSize: 12,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w700,
    color: orangeColor,
  );

  static const txSty_14b_fb = TextStyle(
    fontSize: 14,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.bold,
    color: blackColor,
  );
  static const txSty_14bs_fb = TextStyle(
    fontSize: 14,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.bold,
    color: blackColorShade,
  );

  static const txSty_14r_fb = TextStyle(
    fontSize: 14,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.bold,
    color: redColor,
  );

  static const txSty_14w_fb = TextStyle(
    fontSize: 14,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.bold,
    color: whiteColor,
  );

  static const txSty_14o_f7 = TextStyle(
    fontSize: 14,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w700,
    color: orangeColor,
  );

  static const txSty_18w_fb = TextStyle(
    fontSize: 18,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.bold,
    color: whiteColor,
  );

  static const txSty_18g_fb = TextStyle(
    fontSize: 18,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.bold,
    color: greenColor,
  );

  static const txSty_18o_f7 = TextStyle(
    fontSize: 18,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.bold,
    color: orangeColor,
  );
// style: TextStyle(
//   fontSize: 11,
//   fontFamily: 'Roboto',
//   fontWeight: FontWeight.w700,
//   color: statusColor,
// ),
}
