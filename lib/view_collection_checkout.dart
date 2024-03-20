import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'Common/CommonUtils.dart';
import 'Common/SharedPrefsData.dart';
import 'HomeScreen.dart';
import 'Model/card_collection.dart';

class ViewCollectionCheckOut extends StatefulWidget {
  final ListResult listResult;
  final int position;
  final Widget statusBar;

  const ViewCollectionCheckOut({super.key, required this.listResult, required this.position, required this.statusBar});
  //const ViewCollectionCheckOut({super.key});

  @override
  State<ViewCollectionCheckOut> createState() => _ViewCollectionCheckOutState();
}

class _ViewCollectionCheckOutState extends State<ViewCollectionCheckOut> {
  final _titleTextStyle = const TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w700,
    color: Colors.black,
    fontSize: 18,
  );

  final _tableCellPadding = const EdgeInsets.all(10);

  final _dataTextStyle = const TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w600,
    color: Color(0xFFe78337),
    fontSize: 12,
  );


  int CompneyId = 0;
  String checkdate = "";
  String payment_mode = "";
  final dividerForHorizontal = Container(
    width: double.infinity,
    height: 0.2,
    color: Colors.grey,
  );
  final dividerForVertical = Container(
    width: 0.2,
    height: 60,
    color: Colors.grey,
  );

  @override
  void initState() {
    super.initState();

    getshareddata();
  }

  @override
  Widget build(BuildContext context) {
    //  final arguments = ModalRoute.of(context)?.settings?.arguments as ListResult;
    String dateString = widget.listResult.date;
    payment_mode = widget.listResult.paymentTypeName;
    DateTime date = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd-MM-yyyy').format(date);
    String checkdateString = widget.listResult.checkDate;
    String checkdate = '';

    try {
      DateTime date2 = DateTime.parse(checkdateString);
      checkdate = DateFormat('dd-MM-yyyy').format(date2);
    } catch (e) {
      print('Error parsing date: $e');
      // Handle the error as needed, e.g., set a default date or display an error message
    }


    return Scaffold(
      appBar: AppBar(
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
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
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
                      CompneyId == 1 ? 'assets/srikar-home-icon.png' : 'assets/seeds-home-icon.png',
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        // adject padding as you want
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // small box
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
              // big box
              Card(
                elevation: 7,
                child: Container(
                  // padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
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
                                  style: CommonUtils.txSty_13B_Fb,
                                ),
                                const SizedBox(
                                  height: 2.0,
                                ),
                                Text(
                                  widget.listResult.collectionNumber,
                                  style: const TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 13,
                                      color: Color(0xFFe58338),
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            widget.statusBar,
                          ],
                        ),
                      ),

                      Visibility(
                          visible: payment_mode == "Online",
                          child: Column(
                            children: [
                      dividerForHorizontal,

                      // row two
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Date',
                                    style: CommonUtils.txSty_13B_Fb,
                                  ),
                                  const SizedBox(
                                    height: 2.0,
                                  ),
                                  Text(
                                    formattedDate,
                                    style: _dataTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          dividerForVertical,
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Amount',
                                    style: CommonUtils.txSty_13B_Fb,
                                  ),
                                  const SizedBox(
                                    height: 2.0,
                                  ),
                                  Text(
                                    '₹${formatNumber(widget.listResult.amount)}',
                                    style: _dataTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      dividerForHorizontal,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Payment Mode',
                                            style: CommonUtils.txSty_13B_Fb,
                                          ),
                                          const SizedBox(
                                            height: 2.0,
                                          ),
                                          Text(
                                            widget.listResult.paymentTypeName,
                                            style: _dataTextStyle,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                  if (widget.listResult.virtualBankCode == "Other") ...[
                                  dividerForVertical,
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Bank Name ',
                                            style: CommonUtils.txSty_13B_Fb,
                                          ),
                                          const SizedBox(
                                            height: 2.0,
                                          ),
                                          Text(
                                            widget.listResult.otherBankName +
                                                ' ( ${widget.listResult.otherBankCode} )',
                                            style: _dataTextStyle,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  ],
                                ],
                              ),
                              dividerForHorizontal,
                      // row two
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          if (widget.listResult.virtualBankCode != "Other") ...[

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Virtual Bank Code',
                                      style: CommonUtils.txSty_13B_Fb,
                                    ),
                                    const SizedBox(
                                      height: 2.0,
                                    ),
                                    Text(
                                      widget.listResult.virtualBankCode,
                                      style: _dataTextStyle,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          dividerForVertical,



                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'UTR Number',
                                    style: CommonUtils.txSty_13B_Fb,
                                  ),
                                  const SizedBox(
                                    height: 2.0,
                                  ),
                                  Text(
                                    widget.listResult.utrNumber,
                                    style: _dataTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        ],
                      ),
                      dividerForHorizontal,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                              if (widget.listResult.virtualBankCode == "Other") ...[
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Account No',
                                          style: CommonUtils.txSty_13B_Fb,
                                        ),
                                        const SizedBox(
                                          height: 2.0,
                                        ),
                                        Text(
                                          widget.listResult.otherAccountNo,
                                          style: _dataTextStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                  dividerForVertical,



                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'UTR Number',
                                          style: CommonUtils.txSty_13B_Fb,
                                        ),
                                        const SizedBox(
                                          height: 2.0,
                                        ),
                                        Text(
                                          widget.listResult.utrNumber,
                                          style: _dataTextStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],

                                ],
                              ),

                      dividerForHorizontal,

                      // row two
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Purpose',
                                    style: CommonUtils.txSty_13B_Fb,
                                  ),
                                  const SizedBox(
                                    height: 2.0,
                                  ),
                                  Text(
                                    widget.listResult.purposeName,
                                    style: _dataTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          dividerForVertical,
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Category',
                                    style: CommonUtils.txSty_13B_Fb,
                                  ),
                                  const SizedBox(
                                    height: 2.0,
                                  ),
                                  Text(
                                    widget.listResult.categoryName,
                                    style: _dataTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                              dividerForHorizontal,
                            ],
                          ),
                      ),
                      // Table for Cheque

                        Visibility(
                          visible: payment_mode == "Cheque",
                          child: Column(
                            children: [
                        dividerForHorizontal,
                      // row two
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Date',
                                    style: CommonUtils.txSty_13B_Fb,
                                  ),
                                  const SizedBox(
                                    height: 2.0,
                                  ),
                                  Text(
                                    formattedDate,
                                    style: _dataTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          dividerForVertical,
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Amount',
                                    style: CommonUtils.txSty_13B_Fb,
                                  ),
                                  Text(
                                    '₹${formatNumber(widget.listResult.amount)}',
                                    style: _dataTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      dividerForHorizontal,

                      // row two
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Payment Mode',
                                    style: CommonUtils.txSty_13B_Fb,
                                  ),
                                  const SizedBox(
                                    height: 2.0,
                                  ),
                                  Text(
                                    widget.listResult.paymentTypeName,
                                    style: _dataTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          dividerForVertical,
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Cheque Number',
                                    style: CommonUtils.txSty_13B_Fb,
                                  ),
                                  Text(
                                    widget.listResult.checkNumber,
                                    style: _dataTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      dividerForHorizontal,

                      // row two
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Cheque Date',
                                    style: CommonUtils.txSty_13B_Fb,
                                  ),
                                  const SizedBox(
                                    height: 2.0,
                                  ),
                                  Text(
                                    checkdate,
                                    style: _dataTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          dividerForVertical,
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Cheque Issued Bank',
                                    style: CommonUtils.txSty_13B_Fb,
                                  ),
                                  const SizedBox(
                                    height: 2.0,
                                  ),
                                  Text(
                                    widget.listResult.checkIssuedBank,
                                    style: _dataTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      dividerForHorizontal,

                      // row two
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Purpose',
                                    style: CommonUtils.txSty_13B_Fb,
                                  ),
                                  const SizedBox(
                                    height: 2.0,
                                  ),
                                  Text(
                                    widget.listResult.purposeName,
                                    style: _dataTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          dividerForVertical,
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Category',
                                    style: CommonUtils.txSty_13B_Fb,
                                  ),
                                  const SizedBox(
                                    height: 2.0,
                                  ),
                                  Text(
                                    widget.listResult.categoryName,
                                    style: _dataTextStyle,
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
                        visible: widget.listResult.remarks != null && widget.listResult.remarks.isNotEmpty,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (widget.listResult.remarks != null && widget.listResult.remarks.isNotEmpty)
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
                                        style: CommonUtils.txSty_13B_Fb,
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        widget.listResult.remarks,
                                        style: const TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 13,
                                          color: Color(0xFFe58338),
                                          fontWeight: FontWeight.w600,
                                        ),
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
                  child:Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ignore: prefer_const_constructors
                          Text(
                            'Attachment',
                            style: CommonUtils.txSty_14B_Fb,
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
                                  showZoomedAttachments(widget.listResult.fileUrl);
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
                  )]),
                  ),
                ),

            ],
          ),
        ),
      ),
    );
  }

  Future<void> getshareddata() async {
    CompneyId = await SharedPrefsData.getIntFromSharedPrefs("companyId");

    print('Company ID: $CompneyId');
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
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white),
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
                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
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
}
