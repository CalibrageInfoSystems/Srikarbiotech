import 'dart:convert';
import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:photo_view/photo_view.dart';
import 'package:srikarbiotech/Common/CommonUtils.dart';
import 'package:srikarbiotech/Common/styles.dart';
import 'dart:io';

import 'Common/SharedPrefsData.dart';
import 'HomeScreen.dart';
import 'ReturnOrdersubmit_screen.dart';

class Returntransportdetails extends StatefulWidget {
  final String cardName;
  final String cardCode;
  final String address;
  final String proprietorName;
  final String gstRegnNo;
  final String state;
  final String phone;
  final double creditLine;
  final String lrnumber;
  final String lrdate;
  final String remarks;
  final double balance;
  final String transportname;
  final String whsCode;
  final String whsName;
  final String whsState;

  const Returntransportdetails(
      {super.key,
      required this.cardName,
      required this.cardCode,
      required this.address,
      required this.state,
      required this.phone,
      required this.lrnumber,
      required this.lrdate,
      required this.remarks,
      required this.proprietorName,
      required this.gstRegnNo,
      required this.creditLine,
      required this.balance,
      required this.transportname,
      required this.whsCode,
      required this.whsName,
      required this.whsState});

  @override
  State<Returntransportdetails> createState() => _CreateReturnOrdersPageState();
}

class _CreateReturnOrdersPageState extends State<Returntransportdetails> {
  String filename = '';
  String fileExtension = '';
  String base64Image = '';
  File? _imageFile;

  String filenameorderreciept = '';
  String fileExtensionorderreciept = '';
  String base64Imageorderreciept = '';
  File? _imageFileorderreciept;

  String filenameaddlattchments = '';
  String fileExtensionaddlattchments = '';
  String base64Imageaddlattchments = '';
  File? _imageFileaddlattchments;
  TextEditingController remarkstext = TextEditingController();
  TextEditingController dateController = TextEditingController();

  TextEditingController lRNumberController = TextEditingController();
  TextEditingController transportController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  int companyId = 0;

  @override
  void initState() {
    super.initState();
    lRNumberController = TextEditingController(text: widget.lrnumber);
    dateController = TextEditingController(text: widget.lrdate);
    remarkstext = TextEditingController(text: widget.remarks);
    transportController = TextEditingController(text: widget.transportname);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: CommonStyles.whiteColor,
          ),
          padding: const EdgeInsets.all(10.0),
          child: Card(
            color: CommonStyles.whiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            elevation: 5,
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: CommonStyles.whiteColor,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(
                          top: 15.0, left: 15.0, right: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(
                                top: 0.0, left: 0.0, right: 0.0),
                            child: Text(
                              'LR Number *',
                              style: CommonStyles.txSty_12b_fb,
                              textAlign: TextAlign.start,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          GestureDetector(
                            onTap: () {
                              print('first textview clicked');
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 55.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(
                                  color: CommonStyles.orangeColor,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, top: 0.0),
                                        child: TextFormField(
                                          controller: lRNumberController,
                                          keyboardType: TextInputType.name,
                                          maxLength: 15,
                                          style: CommonStyles.txSty_12o_f7,
                                          decoration: const InputDecoration(
                                            counterText: '',
                                            hintText: 'Enter LR Number',
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
                      padding:
                          const EdgeInsets.only(left: 15, top: 15.0, right: 15),
                      child: buildDateInput(
                        context,
                        'LR Date *',
                        dateController,
                        () => _selectDate(context, dateController),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          top: 15.0, left: 15.0, right: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(
                                top: 0.0, left: 0.0, right: 0.0),
                            child: Text(
                              'Transport Name *',
                              style: CommonStyles.txSty_12b_fb,
                              textAlign: TextAlign.start,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          GestureDetector(
                            onTap: () {
                              print('first textview clicked');
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 55.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(
                                  color: CommonStyles.orangeColor,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, top: 0.0),
                                        child: TextFormField(
                                          controller: transportController,
                                          keyboardType: TextInputType.name,
                                          maxLength: 50,
                                          style: CommonStyles.txSty_12o_f7,
                                          decoration: const InputDecoration(
                                            counterText: '',
                                            hintText: 'Enter Transport Name',
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
                      padding:
                          const EdgeInsets.only(left: 15, top: 4.0, right: 15),
                      child: GestureDetector(
                          onTap: () async {},
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(
                                    top: 15.0, left: 0.0, right: 0.0),
                                child: Text(
                                  'Remarks *',
                                  style: CommonStyles.txSty_12b_fb,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: CommonStyles.orangeColor,
                                      width: 1),
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: CommonStyles.whiteColor,
                                ),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: remarkstext,
                                      maxLength: 100,
                                      style: CommonStyles.txSty_12o_f7,
                                      maxLines: null,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter Return Order remarks',
                                        hintStyle: CommonStyles.txSty_12o_f7,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10.0,
                                          vertical: 0.0,
                                        ),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 15, top: 15.0, right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 0.0),
                            child: Text(
                              'LR Attachment *',
                              style: CommonStyles.txSty_12b_fb,
                              textAlign: TextAlign.start,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          if (_imageFile == null)
                            GestureDetector(
                              onTap: () {
                                showBottomSheetForImageSelection(context);
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                padding: const EdgeInsets.all(0.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    DottedBorder(
                                      borderType: BorderType.RRect,
                                      color: CommonStyles.orangeColor,
                                      padding: const EdgeInsets.only(
                                          top: 0, bottom: 0.0),
                                      strokeWidth: 2,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        padding: const EdgeInsets.all(10.0),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFffeee0),
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: CommonStyles.orangeColor,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                Icons.folder_rounded,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 4.0,
                                            ),
                                            const Text(
                                              'Choose file to upload',
                                              style: CommonStyles.txSty_14o_f7,
                                            ),
                                            const Text(
                                              'Supported formats: jpg, png',
                                              style: CommonStyles.txSty_10b_fb,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          GestureDetector(
                            onTap: () {
                              if (_imageFile != null) {
                                _showImagePopup(context, _imageFile!);
                              }
                            },
                            child: SizedBox(
                              width: _imageFile != null
                                  ? MediaQuery.of(context).size.width
                                  : MediaQuery.of(context).size.width,
                              height: _imageFile != null ? 100 : 0,
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  _imageFile != null
                                      ? Image.file(
                                          _imageFile!,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          fit: BoxFit.fitWidth,
                                        )
                                      : Image.asset(
                                          'assets/shopping_bag.png',
                                          width:
                                              MediaQuery.of(context).size.width,
                                          fit: BoxFit.fitWidth,
                                        ),
                                  if (_imageFile != null)
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _imageFile = null;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(5.0),
                                        margin: const EdgeInsets.only(
                                            top: 5, right: 10.0),
                                        color: HexColor('#ffeee0'),
                                        child: SvgPicture.asset(
                                          'assets/crosscircle.svg',
                                          color: CommonStyles.orangeColor,
                                          width: 24.0,
                                          height: 24.0,
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
                      padding:
                          const EdgeInsets.only(left: 15, top: 15.0, right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Return Order Receipt *',
                            style: CommonStyles.txSty_12b_fb,
                            textAlign: TextAlign.start,
                          ),
                          const SizedBox(height: 2.0),
                          if (_imageFileorderreciept == null)
                            Padding(
                              padding: const EdgeInsets.only(left: 0.0),
                              child: GestureDetector(
                                onTap: () {
                                  showBottomSheetForImageSelectionordereceipt(
                                      context);
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  padding: const EdgeInsets.all(0.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      DottedBorder(
                                        borderType: BorderType.RRect,
                                        color: CommonStyles.orangeColor,
                                        padding: const EdgeInsets.only(
                                            top: 0, bottom: 0.0),
                                        strokeWidth: 2,
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          padding: const EdgeInsets.all(10.0),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFffeee0),
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color:
                                                      CommonStyles.orangeColor,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Icon(
                                                  Icons.folder_rounded,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 4.0,
                                              ),
                                              const Text(
                                                'Choose file to upload',
                                                style:
                                                    CommonStyles.txSty_14o_f7,
                                              ),
                                              const Text(
                                                'Supported formats: jpg,png',
                                                style:
                                                    CommonStyles.txSty_10b_fb,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          GestureDetector(
                            onTap: () {
                              if (_imageFileorderreciept != null) {
                                _showImagePopup(
                                    context, _imageFileorderreciept!);
                              }
                            },
                            child: SizedBox(
                              width: _imageFileorderreciept != null
                                  ? MediaQuery.of(context).size.width
                                  : MediaQuery.of(context).size.width,
                              height: _imageFileorderreciept != null ? 100 : 0,
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  _imageFileorderreciept != null
                                      ? Image.file(
                                          _imageFileorderreciept!,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          fit: BoxFit.fitWidth,
                                        )
                                      : Image.asset(
                                          'assets/shopping_bag.png',
                                          width:
                                              MediaQuery.of(context).size.width,
                                          fit: BoxFit.fitWidth,
                                        ),
                                  if (_imageFileorderreciept != null)
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _imageFileorderreciept = null;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(5.0),
                                        margin: const EdgeInsets.only(
                                            top: 5, right: 10.0),
                                        color: HexColor('#ffeee0'),
                                        child: SvgPicture.asset(
                                          'assets/crosscircle.svg',
                                          color: CommonStyles.orangeColor,
                                          width: 24.0,
                                          height: 24.0,
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
                      padding:
                          const EdgeInsets.only(left: 15, top: 15.0, right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Addl. Attachments',
                            style: CommonStyles.txSty_12b_fb,
                            textAlign: TextAlign.start,
                          ),
                          const SizedBox(height: 2.0),
                          if (_imageFileaddlattchments == null)
                            Padding(
                              padding: const EdgeInsets.only(left: 0.0),
                              child: GestureDetector(
                                onTap: () {
                                  showBottomSheetForImageSelectionaddlattachment(
                                      context);
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  padding: const EdgeInsets.all(0.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      DottedBorder(
                                        borderType: BorderType.RRect,
                                        color: CommonStyles.orangeColor,
                                        padding: const EdgeInsets.only(
                                            top: 0, bottom: 0.0),
                                        strokeWidth: 2,
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          padding: const EdgeInsets.all(10.0),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFffeee0),
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color:
                                                      CommonStyles.orangeColor,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Icon(
                                                  Icons.folder_rounded,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 4.0,
                                              ),
                                              const Text(
                                                'Choose file to upload',
                                                style:
                                                    CommonStyles.txSty_14o_f7,
                                              ),
                                              const Text(
                                                'Supported formats: jpg, png',
                                                style:
                                                    CommonStyles.txSty_10b_fb,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          GestureDetector(
                            onTap: () {
                              if (_imageFileaddlattchments != null) {
                                _showImagePopup(
                                    context, _imageFileaddlattchments!);
                              }
                            },
                            child: SizedBox(
                              width: _imageFileaddlattchments != null
                                  ? MediaQuery.of(context).size.width
                                  : MediaQuery.of(context).size.width,
                              height:
                                  _imageFileaddlattchments != null ? 100 : 0,
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  _imageFileaddlattchments != null
                                      ? Image.file(
                                          _imageFileaddlattchments!,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          fit: BoxFit.fitWidth,
                                        )
                                      : Image.asset(
                                          'assets/shopping_bag.png',
                                          width:
                                              MediaQuery.of(context).size.width,
                                          fit: BoxFit.fitWidth,
                                        ),
                                  if (_imageFileaddlattchments != null)
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _imageFileaddlattchments = null;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(5.0),
                                        margin: const EdgeInsets.only(
                                            top: 5, right: 10.0),
                                        color: HexColor('#ffeee0'),
                                        child: SvgPicture.asset(
                                          'assets/crosscircle.svg',
                                          color: CommonStyles.orangeColor,
                                          width: 24.0,
                                          height: 24.0,
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
                    const SizedBox(height: 10.0),
                  ],
                )),
          ),
        ),
      ),
      bottomNavigationBar: InkWell(
        onTap: () {
          print('clicked ');
        },
        child: Padding(
          padding: const EdgeInsets.only(
              top: 0.0, left: 14.0, right: 14.0, bottom: 10.0),
          child: Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            height: 55.0,
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 45.0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      validate(context);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 45.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.0),
                        color: CommonStyles.orangeColor,
                      ),
                      child: const Center(
                        child: Text(
                          'Save & Proceed',
                          style: CommonStyles.txSty_14w_fb,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showBottomSheetForImageSelection(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width / 4,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            color: Color(0xFFF8dac2),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    pickImage(ImageSource.camera, context);
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: CommonStyles.orangeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 35,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    pickImage(ImageSource.gallery, context);
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: CommonStyles.orangeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.folder,
                        size: 35,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  pickImage(ImageSource source, BuildContext context) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          print('===> _imageFile: $_imageFile');
        });
        filename = basename(_imageFile!.path);
        fileExtension = extension(_imageFile!.path);
        List<int> imageBytes = await _imageFile!.readAsBytes();

        Uint8List compressedBytes = Uint8List.fromList(imageBytes);
        compressedBytes = await FlutterImageCompress.compressWithList(
          compressedBytes,
          minHeight: 800,
          minWidth: 800,
          quality: 80,
        );

        base64Image = base64Encode(compressedBytes);
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void showBottomSheetForImageSelectionordereceipt(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width / 4,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            color: Color(0xFFF8dac2),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    pickImageordereceipt(ImageSource.camera, context);
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: CommonStyles.orangeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 35,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    pickImageordereceipt(ImageSource.gallery, context);
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: CommonStyles.orangeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.folder,
                        size: 35,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  pickImageordereceipt(ImageSource source, BuildContext context) async {
    final pickedFile1 = await ImagePicker().pickImage(source: source);
    if (pickedFile1 != null) {
      setState(() {
        _imageFileorderreciept = File(pickedFile1.path);
      });
      filenameorderreciept = basename(_imageFileorderreciept!.path);
      fileExtensionorderreciept = extension(_imageFileorderreciept!.path);
      List<int> imageBytes1 = await _imageFileorderreciept!.readAsBytes();

      Uint8List compressedBytes = Uint8List.fromList(imageBytes1);
      compressedBytes = await FlutterImageCompress.compressWithList(
        compressedBytes,
        minHeight: 800,
        minWidth: 800,
        quality: 80,
      );

      base64Imageorderreciept = base64Encode(compressedBytes);
      Navigator.pop(context);
    }
  }

  void showBottomSheetForImageSelectionaddlattachment(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width / 4,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            color: Color(0xFFF8dac2),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    pickImageddlattachment(ImageSource.camera, context);
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: CommonStyles.orangeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 35,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    pickImageddlattachment(ImageSource.gallery, context);
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: CommonStyles.orangeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.folder,
                        size: 35,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  pickImageddlattachment(ImageSource source, BuildContext context) async {
    final pickedFile2 = await ImagePicker().pickImage(source: source);
    if (pickedFile2 != null) {
      setState(() {
        _imageFileaddlattchments = File(pickedFile2.path);
      });
      filenameaddlattchments = basename(_imageFileaddlattchments!.path);
      fileExtensionaddlattchments = extension(_imageFileaddlattchments!.path);
      List<int> imageBytes2 = await _imageFileaddlattchments!.readAsBytes();

      Uint8List compressedBytes = Uint8List.fromList(imageBytes2);
      compressedBytes = await FlutterImageCompress.compressWithList(
        compressedBytes,
        minHeight: 800,
        minWidth: 800,
        quality: 80,
      );

      base64Imageaddlattchments = base64Encode(compressedBytes);
      Navigator.pop(context);
    }
  }

  static Widget buildDateInput(
    BuildContext context,
    String labelText,
    TextEditingController controller,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 0.0, left: 0.0, right: 0.0),
          child: Text(
            labelText,
            style: CommonStyles.txSty_12b_fb,
            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(height: 2.0),
        GestureDetector(
          onTap: () async {
            onTap();
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 55.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(
                color: CommonStyles.orangeColor,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0, top: 0.0),
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: controller,
                          style: CommonStyles.txSty_12o_f7,
                          decoration: const InputDecoration(
                            hintText: 'Select LR date',
                            hintStyle: CommonStyles.txSty_12o_f7,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    onTap();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.calendar_today,
                      color: CommonStyles.orangeColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime currentDate = DateTime.now();

    DateTime initialDate = selectedDate ?? currentDate;

    try {
      DateTime? picked = await showDatePicker(
        context: context,
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: CommonStyles.orangeColor,
                onPrimary: CommonStyles.whiteColor,
              ),
              dialogBackgroundColor: CommonStyles.whiteColor,
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
        controller.text = formattedDate;
        selectedDate = picked;

        print("Selected Date: ${DateFormat('yyyy-MM-dd').format(picked)}");
      }
    } catch (e) {
      print("Error selecting date: $e");
    }
  }

  void _showImagePopup(BuildContext context, File imageFile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _buildImagePopup(imageFile),
      ),
    );
  }

  Widget _buildImagePopup(File imageFile) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CommonStyles.orangeColor,
        automaticallyImplyLeading: false,
        title: const Text("Attached Image"),
      ),
      body: PhotoView(
        imageProvider: FileImage(imageFile),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
        enableRotation: true,
      ),
    );
  }

  Future<void> getshareddata() async {
    companyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");

    print('Company ID: $companyId');
  }

  void validate(BuildContext context) {
    bool isValid = true;
    bool hasValidationFailed = false;
    if (isValid && lRNumberController.text.trim().isEmpty) {
      CommonUtils.showCustomToastMessageLong(
          'Please Enter LR Number', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }

    if (isValid && dateController.text.isEmpty) {
      CommonUtils.showCustomToastMessageLong(
          'Please Select LR Date', context, 1, 4);

      isValid = false;
      hasValidationFailed = true;
    }
    if (isValid && transportController.text.trim().isEmpty) {
      CommonUtils.showCustomToastMessageLong(
          'Please Enter Transport Name', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }
    if (isValid && remarkstext.text.trim().isEmpty) {
      CommonUtils.showCustomToastMessageLong(
          'Please Enter Return Order Remarks', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }
    if (isValid && _imageFile == null) {
      CommonUtils.showCustomToastMessageLong(
          'Please Upload LR Attachment', context, 1, 6);

      isValid = false;
      hasValidationFailed = true;
    }
    if (isValid && _imageFileorderreciept == null) {
      CommonUtils.showCustomToastMessageLong(
          'Please Upload Return Order Receipt ', context, 1, 6);

      isValid = false;
      hasValidationFailed = true;
    }
    if (isValid) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ReturnOrdersubmit_screen(
                cardName: widget.cardName,
                cardCode: widget.cardCode,
                address: widget.address,
                state: widget.state,
                phone: widget.phone,
                proprietorName: widget.proprietorName,
                gstRegnNo: widget.gstRegnNo,
                LrNumber: lRNumberController.text,
                Lrdate: dateController.text,
                Remarks: remarkstext.text,
                LRAttachment: base64Image,
                ReturnOrderReceipt: base64Imageorderreciept,
                addlattchments: base64Imageaddlattchments,
                creditLine: double.parse('${widget.creditLine}'),
                balance: double.parse('${widget.balance}'),
                transportname: transportController.text,
                whsCode: widget.whsCode,
                whsName: widget.whsName,
                whsState: widget.whsState)),
      );
    }
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: CommonStyles.orangeColor,
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
                    Navigator.of(context).pop();
                  },
                  child: const Icon(
                    Icons.chevron_left,
                    size: 30.0,
                    color: CommonStyles.whiteColor,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              const Text(
                'Transport Details',
                style: CommonStyles.txSty_18w_fb,
              ),
            ],
          ),
          FutureBuilder(
            future: getshareddata(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
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
                print('else got execute');
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }
}
