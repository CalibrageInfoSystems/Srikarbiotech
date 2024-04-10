import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:srikarbiotech/Common/styles.dart';

import 'Common/CommonUtils.dart';
import 'Common/SharedPrefsData.dart';
import 'HomeScreen.dart';
import 'Model/card_collection.dart';

class ViewCollectionCheckOut extends StatefulWidget {
  final ListResult listResult;
  final int position;
  final Widget statusBar;

  const ViewCollectionCheckOut(
      {super.key,
        required this.listResult,
        required this.position,
        required this.statusBar});
  //const ViewCollectionCheckOut({super.key});

  @override
  State<ViewCollectionCheckOut> createState() => _ViewCollectionCheckOutState();
}

class _ViewCollectionCheckOutState extends State<ViewCollectionCheckOut> {
  final _dataTextStyle = const TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w600,
    color: Color(0xFFe78337),
    fontSize: 12,
  );

  int companyId = 0;
  String checkdate = "";
  String paymentMode = "";

  @override
  void initState() {
    super.initState();
    getshareddata();
  }

  @override
  Widget build(BuildContext context) {
    String dateString = widget.listResult.date;
    paymentMode = widget.listResult.paymentTypeName;
    DateTime date = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd-MM-yyyy').format(date);
    String checkdateString = widget.listResult.checkDate;
    String checkdate = '';

    try {
      DateTime date2 = DateTime.parse(checkdateString);
      checkdate = DateFormat('dd-MM-yyyy').format(date2);
    } catch (e) {
      print('Error parsing date: $e');
    }

    return Scaffold(
      appBar: _appBar(),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8.0),
              CommonUtils.buildCard(
                widget.listResult.partyName,
                widget.listResult.partyCode,
                widget.listResult.proprietorName,
                widget.listResult.partyGSTNumber,
                widget.listResult.address,
                Colors.white,
                BorderRadius.circular(5.0),
              ),
              const SizedBox(height: 16.0),
              Card(
                elevation: 7,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Column(children: [
                    // Table
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Collection ID',
                                textAlign: TextAlign.start,
                                style: CommonStyles.txSty_12b_fb,
                              ),
                              const SizedBox(
                                height: 2.0,
                              ),
                              Text(
                                widget.listResult.collectionNumber,
                                style: CommonStyles.txSty_12o_f7,
                              ),
                            ],
                          ),
                          widget.statusBar,
                        ],
                      ),
                    ),

                    Visibility(
                      visible: paymentMode == "Online",
                      child: Column(
                        children: [
                          CommonUtils.dividerForHorizontal,

                          // row two
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Date',
                                        style: CommonStyles.txSty_12b_fb,
                                      ),
                                      const SizedBox(
                                        height: 2.0,
                                      ),
                                      Text(
                                        formattedDate,
                                        style: CommonStyles.txSty_12o_f7,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              CommonUtils.dividerForVertical,
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Total Amount',
                                        style: CommonStyles.txSty_12b_fb,
                                      ),
                                      const SizedBox(
                                        height: 2.0,
                                      ),
                                      Text(
                                        '₹${formatNumber(widget.listResult.amount)}',
                                        style: CommonStyles.txSty_12o_f7,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          CommonUtils.dividerForHorizontal,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Payment Mode',
                                        style: CommonStyles.txSty_12b_fb,
                                      ),
                                      const SizedBox(
                                        height: 2.0,
                                      ),
                                      Text(
                                        widget.listResult.paymentTypeName,
                                        style: CommonStyles.txSty_12o_f7,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (widget.listResult.virtualBankCode ==
                                  "Other") ...[
                                CommonUtils.dividerForVertical,
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Bank Name ',
                                          style: CommonStyles.txSty_12b_fb,
                                        ),
                                        const SizedBox(
                                          height: 2.0,
                                        ),
                                        Text(
                                          '${widget.listResult.otherBankName} ( ${widget.listResult.otherBankCode} )',
                                          style: CommonStyles.txSty_12o_f7,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          CommonUtils.dividerForHorizontal,
                          // row two
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              if (widget.listResult.virtualBankCode !=
                                  "Other") ...[
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Virtual Bank Code',
                                          style: CommonStyles.txSty_12b_fb,
                                        ),
                                        const SizedBox(
                                          height: 2.0,
                                        ),
                                        Text(
                                          widget.listResult.virtualBankCode,
                                          style: CommonStyles.txSty_12o_f7,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                CommonUtils.dividerForVertical,
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'UTR Number',
                                          style: CommonStyles.txSty_12b_fb,
                                        ),
                                        const SizedBox(
                                          height: 2.0,
                                        ),
                                        Text(
                                          widget.listResult.utrNumber,
                                          style: CommonStyles.txSty_12o_f7,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          CommonUtils.dividerForHorizontal,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              if (widget.listResult.virtualBankCode ==
                                  "Other") ...[
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Account No',
                                          style: CommonStyles.txSty_12b_fb,
                                        ),
                                        const SizedBox(
                                          height: 2.0,
                                        ),
                                        Text(
                                          widget.listResult.otherAccountNo,
                                          style: CommonStyles.txSty_12o_f7,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                CommonUtils.dividerForVertical,
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'UTR Number',
                                          style: CommonStyles.txSty_12b_fb,
                                        ),
                                        const SizedBox(
                                          height: 2.0,
                                        ),
                                        Text(
                                          widget.listResult.utrNumber,
                                          style: CommonStyles.txSty_12o_f7,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),

                          CommonUtils.dividerForHorizontal,

                          // row two
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Purpose',
                                        style: CommonStyles.txSty_12b_fb,
                                      ),
                                      const SizedBox(
                                        height: 2.0,
                                      ),
                                      Text(
                                        widget.listResult.purposeName,
                                        style: CommonStyles.txSty_12o_f7,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              CommonUtils.dividerForVertical,
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Category',
                                        style: CommonStyles.txSty_12b_fb,
                                      ),
                                      const SizedBox(
                                        height: 2.0,
                                      ),
                                      Text(
                                        widget.listResult.categoryName,
                                        style: CommonStyles.txSty_12o_f7,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          CommonUtils.dividerForHorizontal,
                        ],
                      ),
                    ),
                    // Table for Cheque

                    Visibility(
                      visible: paymentMode == "Cheque",
                      child: Column(
                        children: [
                          CommonUtils.dividerForHorizontal,
                          // row two
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Date',
                                        style: CommonStyles.txSty_12b_fb,
                                      ),
                                      const SizedBox(
                                        height: 2.0,
                                      ),
                                      Text(
                                        formattedDate,
                                        style: CommonStyles.txSty_12o_f7,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              CommonUtils.dividerForVertical,
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Total Amount',
                                        style: CommonStyles.txSty_12b_fb,
                                      ),
                                      Text(
                                        '₹${formatNumber(widget.listResult.amount)}',
                                        style: CommonStyles.txSty_12o_f7,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          CommonUtils.dividerForHorizontal,

                          // row two
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Payment Mode',
                                        style: CommonStyles.txSty_12b_fb,
                                      ),
                                      const SizedBox(
                                        height: 2.0,
                                      ),
                                      Text(
                                        widget.listResult.paymentTypeName,
                                        style: CommonStyles.txSty_12o_f7,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              CommonUtils.dividerForVertical,
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Cheque Number',
                                        style: CommonStyles.txSty_12b_fb,
                                      ),
                                      Text(
                                        widget.listResult.checkNumber,
                                        style: CommonStyles.txSty_12o_f7,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          CommonUtils.dividerForHorizontal,

                          // row two
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Cheque Date',
                                        style: CommonStyles.txSty_12b_fb,
                                      ),
                                      const SizedBox(
                                        height: 2.0,
                                      ),
                                      Text(
                                        checkdate,
                                        style: CommonStyles.txSty_12o_f7,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              CommonUtils.dividerForVertical,
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Cheque Issued Bank',
                                        style: CommonStyles.txSty_12b_fb,
                                      ),
                                      const SizedBox(
                                        height: 2.0,
                                      ),
                                      Text(
                                        widget.listResult.checkIssuedBank,
                                        style: CommonStyles.txSty_12o_f7,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          CommonUtils.dividerForHorizontal,

                          // row two
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Purpose',
                                        style: CommonStyles.txSty_12b_fb,
                                      ),
                                      const SizedBox(
                                        height: 2.0,
                                      ),
                                      Text(
                                        widget.listResult.purposeName,
                                        style: CommonStyles.txSty_12o_f7,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              CommonUtils.dividerForVertical,
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Category',
                                        style: CommonStyles.txSty_12b_fb,
                                      ),
                                      const SizedBox(
                                        height: 2.0,
                                      ),
                                      Text(
                                        widget.listResult.categoryName,
                                        style: CommonStyles.txSty_12o_f7,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Visibility(
                      visible: widget.listResult.remarks.isNotEmpty,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (widget.listResult.remarks.isNotEmpty)
                            Flexible(
                              // Add Flexible widget here
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Remarks',
                                      textAlign: TextAlign.start,
                                      style: CommonStyles.txSty_12b_fb,
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      widget.listResult.remarks,
                                      style: CommonStyles.txSty_12o_f7,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Space
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      // Attachment
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ignore: prefer_const_constructors
                          Text(
                            'Attachment',
                            style: CommonStyles.txSty_12b_fb,
                          ),
                          const SizedBox(
                            height: 4.0,
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 150,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: GestureDetector(
                                onTap: () {
                                  showZoomedAttachments(
                                      widget.listResult.fileUrl);
                                },
                                child: widget.listResult.fileUrl != null
                                    ? Image.network(
                                  widget.listResult.fileUrl,
                                  fit: BoxFit.fill,
                                )
                                    : Image.asset(
                                  'assets/sreekar_seeds.png',
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getshareddata() async {
    companyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");

    print('Company ID: $companyId');
  }

  String formatNumber(double number) {
    NumberFormat formatter = NumberFormat("#,##,##,##,##,##,##0.00", "en_US");
    return formatter.format(number);
  }

  void showZoomedAttachments(String imageString) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.white),
            width: double.infinity,
            height: 500,
            child: Stack(
              children: [
                Center(
                  child: PhotoViewGallery.builder(
                    itemCount: 1,
                    builder: (context, index) {
                      return PhotoViewGalleryPageOptions(
                        imageProvider: NetworkImage(imageString),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered,
                      );
                    },
                    scrollDirection: Axis.vertical,
                    scrollPhysics: const PageScrollPhysics(),
                    allowImplicitScrolling: true,
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20)),
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: const Color(0xFFe78337),
      automaticallyImplyLeading: false,
      // This line removes the default back arrow
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                child: GestureDetector(
                  onTap: () {
                    // Handle the click event for the back button
                    Navigator.of(context).pop();
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
                'View Collection',
                style: CommonStyles.txSty_18w_fb,
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
